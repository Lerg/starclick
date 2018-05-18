--[[
check(glm::vec3 ray_origin, glm::vec3 ray_direction, glm::mat4 model, glm::vec3 vmin, glm::vec3 vmax, GLfloat &intersection_distance) {
		GLfloat t_min = 0.0f;
		GLfloat t_max = 100000.0f;
		const glm::vec3 delta = glm::vec3(model[3].x, model[3].y, model[3].z) - ray_origin;

		for (uint8_t i = 0; i < 3; ++i) {
			// Test intersection with the 2 planes perpendicular to the OBB's axis (in order X, Y, Z).
			const glm::vec3 axis = glm::vec3(model[i].x, model[i].y, model[i].z);
			const GLfloat e = glm::dot(axis, delta);
			const GLfloat f = glm::dot(ray_direction, axis);

			if (fabs(f) > 0.001f) { // Standard case.
				GLfloat t1 = (e + vmin[i]) / f; // Intersection with the "left" plane.
				GLfloat t2 = (e + vmax[i]) / f; // Intersection with the "right" plane.
				// t1 and t2 now contain distances betwen ray origin and ray-plane intersections.

				// We want t1 to represent the nearest intersection,
				// so if it's not the case, invert t1 and t2.
				if (t1 > t2) {
					GLfloat w = t1;
					t1 = t2;
					t2 = w;
				}

				// t_max is the nearest "far" intersection (amongst the X,Y and Z planes pairs).
				if (t2 < t_max ) t_max = t2;
				// t_min is the farthest "near" intersection (amongst the X,Y and Z planes pairs).
				if (t1 > t_min) t_min = t1;
				// If "far" is closer than "near", then there is NO intersection.
				if (t_max < t_min ) return false;
			} else if (-e + vmin.x > 0.0f || -e + vmax.x < 0.0f) {
				// Rare case : the ray is almost parallel to the planes, so they don't have any "intersection".
				return false;
			}
		}

		intersection_distance = t_min;
		return true;
	}
]]

local _M = {}

function _M.check(ray_origin, ray_direction, position, model, vmin, vmax)
	local t_min, t_max = 0, 100000
	local delta = position - ray_origin
	local xyz = {'x', 'y', 'z'}
	
	for i = 1, 3 do
		-- Test intersection with the 2 planes perpendicular to the OBB's axis (in order X, Y, Z).
		local axis = vmath.vector3(model['m' .. (i - 1) .. '0'], model['m' .. (i - 1) .. '1'], model['m' .. (i - 1) .. '2'])
		local e = vmath.dot(axis, delta)
		local f = vmath.dot(ray_direction, axis)
		
		if math.abs(f) > 0.001 then -- Standard case.
			local t1 = (e + vmin[xyz[i]]) / f -- Intersection with the "left" plane.
			local t2 = (e + vmax[xyz[i]]) / f -- Intersection with the "right" plane.
			-- t1 and t2 now contain distances betwen ray origin and ray-plane intersections.

			-- We want t1 to represent the nearest intersection,
			-- so if it's not the case, invert t1 and t2.
			if t1 > t2 then
				t1, t2 = t2, t1
			end

			-- t_max is the nearest "far" intersection (amongst the X,Y and Z planes pairs).
			if t2 < t_max then t_max = t2 end
			-- t_min is the farthest "near" intersection (amongst the X,Y and Z planes pairs).
			if t1 > t_min then t_min = t1 end
			-- If "far" is closer than "near", then there is NO intersection.
			if t_max < t_min then return false end
		elseif vmin.x - e > 0 or vmax.x - e < 0 then
			-- Rare case : the ray is almost parallel to the planes, so they don't have any "intersection".
			return false
		end
	end
	
	-- Return true if there is intersection and the distance
	return true, t_min
end

return _M