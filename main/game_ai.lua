local utils = require('libs.utils')

local g = {}

function g:find_nearby_targets(x, z, is_alien)
	local targets = {}
	local distance = 1
	for i = 1, #self.units do
		local u = self.units[i]
		if u.is_alien == is_alien and math.abs(u.x - x) <= distance and math.abs(u.z - z) <= distance then
			table.insert(targets, u)
		end
	end
	for i = 1, #self.buildings do
		local b = self.buildings[i]
		if b.is_alien == is_alien and math.abs(b.x - x) <= distance and math.abs(b.z - z) <= distance then
			table.insert(targets, b)
		end
	end
	if #targets > 0 then
		return targets
	end
end

function g:find_humans()
	local targets = {}
	for i = 1, #self.units do
		local u = self.units[i]
		if not u.is_alien then
			table.insert(targets, u)
		end
	end
	for i = 1, #self.buildings do
		local b = self.buildings[i]
		if not b.is_alien then
			table.insert(targets, b)
		end
	end
	if #targets > 0 then
		return targets
	end
end

function g:find_free_spot_around(around_x, around_z, is_alien)
	local spots = {
		true, true, true,
		true, true, true,
		true, true, true
	}
	for dx = -1, 1 do
		for dz = -1, 1 do
			local x = utils.clamp(around_x + dx, 0, self.map_width)
			local z = utils.clamp(around_z + dz, 0, self.map_height)
			local value = self.ground[x + (z - 1) * self.map_width]
			if value == 0 then
				spots[dx + 2 + (dz + 1) * 3] = false
			end
		end
	end
	for i = 1, #self.units do
		local u = self.units[i]
		local dx, dz = u.x - around_x, u.z - around_z
		if math.abs(dx) <= 1 and math.abs(dz) <= 1 then
			spots[dx + 2 + (dz + 1) * 3] = false
		end
	end
	for i = 1, #self.buildings do
		local b = self.buildings[i]
		local dx, dz = b.x - around_x, b.z - around_z
		if math.abs(dx) <= 1 and math.abs(dz) <= 1 then
			spots[dx + 2 + (dz + 1) * 3] = false
		end
	end
	local human_spots = {8, 7, 9,  4, 6,  2, 1, 3}
	local alien_spots = {2, 1, 3,  4, 6,  8, 7, 9}
	for j = 1, 8 do
		local i = is_alien and alien_spots[j] or human_spots[j]
		if spots[i] then
			local dx, dz = (i - 1) % 3 - 1, math.floor((i - 1) / 3) - 1
			return around_x + dx, around_z + dz
		end
	end
end

function g:update_ai()
	for i = 1, #self.units do
		local u = self.units[i]
		if not u.is_moving then
			if u.target and not u.prefered_target then
				local distance = 1
				-- Check if target is alive.
				if u.target.health == 0 then
					u.target = nil
				-- Check if target has moved away.
				elseif math.abs(u.target.x - u.x) > distance or math.abs(u.target.z - u.z) > distance then
					u.target = nil
				end
			else
				-- Check for nearby enemy.
				local targets = self:find_nearby_targets(u.x, u.z, not u.is_alien)
				if targets then
					if u.prefered_target then
						for j = 1, #targets do
							if targets[j] == u.prefered_target then
								u.target = u.prefered_target
								break
							end
						end
						u.prefered_target = nil
					end
					if not u.target then
						u.target = targets[math.random(1, #targets)]
					end
				elseif u.is_alien and math.random() < 0.01 then
					-- Move somewhere.
					local targets = self:find_humans()
					if targets then
						local target = targets[math.random(1, #targets)]
						u.prefered_target = target
						self:move_unit(u, target.x, target.z)
					end
				end
			end
		end
	end

	for i = 1, #self.buildings do
		local b = self.buildings[i]
		if b.action then
			if self.current_time >= b.last_action_time + b.cooldown then
				b.last_action_time = self.current_time
				if b.action.spawn then
					local x, z = self:find_free_spot_around(b.x, b.z, b.is_alien)
					if x then
						self:spawn_unit{name = b.action.spawn, x = x, z = z}
					end
				elseif b.action.is_click then
					self:click_resources()
				end
			end
		end
	end
end

return g