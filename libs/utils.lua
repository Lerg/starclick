local _M = {}

function _M.clamp(value, min, max)
	if value < min then
		return min
	elseif value > max then
		return max
	else
		return value
	end	
end

function _M.round(value)
	return math.floor(value + 0.5)	
end

function _M.copy(t)
	local c = {}
	for k, v in pairs(t) do
		c[k] = v
	end
	return c
end

function _M.deep_copy(t, out)
	local c = out or {}
	for k, v in pairs(t) do
		if type(v) == 'table' then
			c[k] = _M.deep_copy(v)
		else
			c[k] = v
		end
	end
	return c
end

function _M.capitalize(s)
	return s:sub(1, 1):upper() .. s:sub(2):gsub('_', ' ')
end

return _M