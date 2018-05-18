-- Converts functions into on_message actions.
local _M = {}

local hashed_key_mt = {
	__newindex = function(t, key, value)
		rawset(t, hash(key), value)
	end
}

local function add_messages(g)
	local messages = {}
	setmetatable(messages, hashed_key_mt)
	function _G.on_message(self, message_id, message, sender)
		local field = messages[message_id]
		if field then
			return field(self.g, message, sender)
		end
	end
	g.messages = messages
end

local h_mouse_move = hash('mouse_move')
local function add_inputs(g)
	local inputs = {}
	setmetatable(inputs, hashed_key_mt)
	function _G.on_input(self, action_id, action)
		action_id = action_id or h_mouse_move
		local field = inputs[action_id]
		if field then
			return field(self.g, action)
		end
	end
	g.inputs = inputs
end

return function(params)
	local g = {}
	if params.messages then
		add_messages(g)
	end
	if params.inputs then
		add_inputs(g)
	end
	function _G.init(self)
		self.g = {instance = self}
		for k, v in pairs(g) do
			self.g[k] = v	
		end
		g = nil
		if self.g.init then
			self.g:init()	
		end
	end
	function _G.update(self, dt)
		if self.g.update then
			self.g:update(dt)	
		end
	end
	function _G.on_reload(self)
		if self.g.on_reload then
			self.g:on_reload()	
		end
	end
	function _G.final(self)
		if self.g.final then
			self.g:final()	
		end
		self.g = nil
	end
	return g
end