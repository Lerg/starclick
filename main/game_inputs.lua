local camera = require('libs.camera')
local flux = require('libs.flux')
local focus = require('libs.focus')
local hashed = require('libs.hashed')
local ray_intersection = require('libs.ray_intersection')
local utils = require('libs.utils')

local g = {}

function g:on_mouse_click(action)
	if action.button == hashed.left then
		local margin = 256 * 1280 / camera.width
		if action.x <= margin then
			return
		end
		if action.pressed then
			if self.tween then
				self.tween:stop()
				self.tween = nil
			end
			local x, z = self:find_selection_xz(action)
			if x then
				local object = self:find_selected_object(x, z)
				if object and not self.player.building then
					self.selection_rects.selected.x, self.selection_rects.selected.z = x, z
					self.selection_rects.selected.is_visible = true
					self.selection_rects.selected.object = object
					msg.post('/ui', hashed.selection)
					msg.post('/audio#click', 'play_sound')
					if object and object.is_unit and not object.is_alien then
						msg.post('/ui', hashed.info, {info = 'Right click to move or attack.'})
					elseif object and object.name == 'base' then
						self.last_selected_base = object
					end
				else
					local deselect = true
					if self.player.building then
						if not object or self.player.building == 'plate' then
							deselect = self:spawn_building(x, z)
						else
							deselect = false
						end
					end
					if deselect then
						local base = self:find_base()
						if base then
							self.selection_rects.selected.x, self.selection_rects.selected.z = base.x, base.z
							self.selection_rects.selected.object = base
						else
							self.selection_rects.selected.is_visible = false
							self.selection_rects.selected.object = nil
						end
						msg.post('/ui', hashed.selection)
					elseif self.player.building ~= 'plate' then
						msg.post('/ui', hashed.info, {info = 'Place the building on a plate.'})
					end
				end
			else
				focus.set_touch(self)
				self.is_focused = true
				self.start_x, self.start_y = action.screen_x, action.screen_y
				self.start_alpha = camera.alpha
			end
		elseif self.is_focused then
			if action.released then
				focus.release_touch(self)
				self.is_focused = false
				local snap_angle = math.pi / 6
				if math.abs(camera.alpha / snap_angle) > 0.001 then
					local alpha = camera.alpha + action.screen_dx / 30
					self.tween = flux.to(camera, 0.5, {alpha = utils.round(alpha / snap_angle) * snap_angle}):ease('quadout')
				end
			else
				camera.alpha = self.start_alpha + math.pi / 2 * ((action.screen_x - self.start_x) / camera.width)
			end
		end
	else
		if action.pressed then
			local x, z = self:find_selection_xz(action)
			if x then
				local object = self:find_selected_object(x, z)
				if self.selection_rects.selected.object and self.selection_rects.selected.object.is_unit and not self.selection_rects.selected.object.is_alien then
					deselect = false
					self:move_unit(self.selection_rects.selected.object, x, z)
					self.selection_rects.selected.object.prefered_target = object
					msg.post('/audio#click', 'play_sound')
				end
			else
				focus.set_touch(self)
				self.is_focused = true
				self.mouse_right_start_x, self.mouse_right_start_y = action.x, action.y
				self.camera_pan_start = camera.pan
			end
		elseif self.is_focused then
			if action.released then
				focus.release_touch(self)
				self.is_focused = false
			else
				local px, pz = self.mouse_right_start_x - action.x, self.mouse_right_start_y - action.y
				camera.pan_by(self.camera_pan_start, px, pz)
			end
		end
	end
end

function g:on_mouse_move(action)
	local x, z = self:find_selection_xz(action)
	if x then
		self.selection_rects.cursor.x, self.selection_rects.cursor.z = x, z
		self.selection_rects.cursor.is_visible = true
		--msg.post('/ui', hashed.info, {info = 'x = ' .. x .. ' z = ' .. z})
	else
		self.selection_rects.cursor.is_visible = false
	end
end

function g:on_mouse_wheel(action)
	camera.zoom_step(action.value)
end

function g:find_selection_xz(action)
	local origin, direction = camera.ray(action.screen_x, action.screen_y)
	local vmin, vmax = vmath.vector3(-4, 3, -4), vmath.vector3(4, 4, 4)
	local selected_id, min_distance
	for i = 1, #self.tiles do
		local id = self.tiles[i]
		local position = go.get_world_position(id)
		local rotation = go.get_world_rotation(id)
		local scale = go.get_scale_uniform(id)
		local world = vmath.matrix4()
		world.m03 = position.x
		world.m13 = position.y
		world.m23 = position.z
		local is_intersection, distance = ray_intersection.check(origin, direction, position, world, vmin * scale, vmax * scale)
		if is_intersection and (not min_distance or min_distance > distance) then
			selected_id, min_distance = self.tiles[i], distance
		end
	end
	local x, z
	if selected_id then
		for i = 1, #self.map do
			if self.map[i].go == selected_id then
				x, z = self.map[i].x, self.map[i].z
				break
			end
		end
	end
	return x, z
end

function g:find_selected_object(x, z)
	for i = 1, #self.units do
		local u = self.units[i]
		if u.x == x and u.z == z then
			return u
		end
	end
	for i = 1, #self.buildings do
		local b = self.buildings[i]
		if b.x == x and b.z == z then
			return b
		end
	end
end

return g