local _M = {}

local touch_focus_id

function _M.set_touch(id)
	touch_focus_id = id
end

function _M.release_touch()
	touch_focus_id = nil
end

function _M.check_touch(id)
	return not touch_focus_id or touch_focus_id == id	
end

return _M