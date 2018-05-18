local utils = require('libs.utils')

local _M = {
	view = vmath.matrix4(), -- Camera view matrix.
	projection = vmath.matrix4(), -- Camera projection matrix.
	width = 1, -- Screen width.
	height = 1, -- Screen height.
	alpha = 0,
	beta = 0,
	distance = 0,
	view_width = 0,
	target = vmath.vector3(),
	alpha_offset = 0,
	beta_offset = 0,
	dt = 0,
	zoom = 0.08,
	pan = vmath.vector3(-20, 0, 0)
}
local pl = 75
local pan_limit = {x = {min = -pl, max = pl}, z = {min = -pl, max = pl}}

-- Returns origin point of the ray and it's direction
function _M.ray(x, y)
	local ray_start_screen = vmath.vector4((x / _M.width - 0.5) * 2.0, (y / _M.height - 0.5) * 2.0, -1.0, 1.0);
	local ray_end_screen = vmath.vector4(ray_start_screen)
	ray_end_screen.z = 0
	
	local m = vmath.inv(_M.projection * _M.view)
	local ray_start_world = m * ray_start_screen
	local ray_end_world = m * ray_end_screen
	local w = ray_start_world.w
	local origin = vmath.vector3(ray_start_world.x / w, ray_start_world.y / w, ray_start_world.z / w)
	w = ray_end_world.w
	local direction = vmath.normalize(vmath.vector3(
		ray_end_world.x / w - ray_start_world.x,
		ray_end_world.y / w - ray_start_world.y,
		ray_end_world.z / w - ray_start_world.z
	))
	
	-- Origin of the ray.
	-- Direction, in world space, of the ray that goes "through" the screen point.
	return origin, direction
end

function _M.zoom_step(value)
	_M.zoom = utils.clamp(_M.zoom + value / 100, 0.04, 0.16)
end

function _M.pan_by(start, px, pz)
	local sx = 2 * _M.zoom
	local sy = 3.55 * sx * _M.height / _M.width
	px = utils.clamp(start.x + px * sx, pan_limit.x.min, pan_limit.x.max)
	pz = utils.clamp(start.z - pz * sy, pan_limit.z.min, pan_limit.z.max)
	_M.pan = vmath.vector3(px, 0, pz)
end

return _M