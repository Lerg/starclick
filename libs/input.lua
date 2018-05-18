local hashed = require('libs.hashed')

local _M = {}

local mouse_move_listeners = {}
local mouse_click_listeners = {}
local mouse_wheel_listeners = {}

local focused = {}

function _M.add_mouse_move_listener(listener)
	table.insert(mouse_move_listeners, listener)
end
function _M.remove_mouse_move_listener(listener)
	for i = #mouse_move_listeners, 1, -1 do
		if mouse_move_listeners[i] == listener then
			table.remove(mouse_move_listeners, i)
			break
		end
	end
end

function _M.add_mouse_click_listener(listener)
	table.insert(mouse_click_listeners, listener)
end
function _M.remove_mouse_click_listener(listener)
	for i = #mouse_click_listeners, 1, -1 do
		if mouse_click_listeners[i] == listener then
			table.remove(mouse_click_listeners, i)
			break
		end
	end
end

function _M.add_mouse_wheel_listener(listener)
	table.insert(mouse_wheel_listeners, listener)
end
function _M.remove_mouse_wheel_listener(listener)
	for i = #mouse_wheel_listeners, 1, -1 do
		if mouse_wheel_listeners[i] == listener then
			table.remove(mouse_wheel_listeners, i)
			break
		end
	end
end

local function on_mouse_move(action)
	if focused.mouse_move then
		local l = focused.mouse_move
		if type(l) == 'table' and l.on_mouse_move then
			if l:on_mouse_move(action) then
				return
			end
		else
			if l(action) then
				return
			end
		end
	end
	for i = 1, #mouse_move_listeners do
		local l = mouse_move_listeners[i]
		if type(l) == 'function' then
			if l(action) then
				break
			end
		elseif l.on_mouse_move then
			if l:on_mouse_move(action) then
				break
			end
		end
	end
end

local function on_mouse_click(action)
	if focused.mouse_click then
		local l = focused.mouse_click
		if type(l) == 'function' then
			if l(action) then
				return
			end
		elseif l.on_mouse_click then
			if l:on_mouse_click(action) then
				return
			end
		end
	end
	for i = 1, #mouse_click_listeners do
		local l = mouse_click_listeners[i]
		if type(l) == 'function' then
			if l(action) then
				break
			end
		elseif l.on_mouse_click then
			if l:on_mouse_click(action) then
				break
			end
		end
	end
end

local function on_mouse_wheel(action)
	if focused.mouse_wheel then
		local l = focused.mouse_wheel
		if type(l) == 'function' then
			if l(action) then
				return
			end
		elseif l.on_mouse_wheel then
			if l:on_mouse_wheel(action) then
				return
			end
		end
	end
	for i = 1, #mouse_wheel_listeners do
		local l = mouse_wheel_listeners[i]
		if type(l) == 'function' then
			if l(action) then
				break
			end
		elseif l.on_mouse_wheel then
			if l:on_mouse_wheel(action) then
				break
			end
		end
	end
end

function _M.on_input(action_id, action)
	if not action_id then
		on_mouse_move(action)
	elseif action_id == hashed.mouse_click or action_id == hashed.mouse_right_click then
		action.button = action_id == hashed.mouse_click and hashed.left or hashed.right
		on_mouse_click(action)
	elseif action_id == hashed.mouse_wheel_up or action_id == hashed.mouse_wheel_down then
		if action_id == hashed.mouse_wheel_down then
			action.value = -action.value
		end
		on_mouse_wheel(action)
	end
end

return _M