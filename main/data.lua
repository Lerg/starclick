return {
	units = {
		motoquad = {health = 10, speed = 4, attack = 2, cooldown = 1, is_alien = false},
		hovercraft = {health = 20, speed = 6, attack = 3, cooldown = 1, is_alien = false},
		tower = {health = 40, speed = 0.5, attack = 30, cooldown = 3, is_alien = false, is_tall = true},
		robot = {health = 100, speed = 2, attack = 30, cooldown = 2, is_alien = false, is_tall = true},

		alien_lvl1 = {health = 5, speed = 2, attack = 1, cooldown = 1, is_alien = true},
		alien_lvl2 = {health = 20, speed = 2, attack = 3, cooldown = 1, is_alien = true},
		alien_lvl3 = {health = 60, speed = 1, attack = 15, cooldown = 2, is_alien = true, is_tall = true},
		alien_lvl4 = {health = 500, speed = 1, attack = 30, cooldown = 3, is_alien = true, is_tall = true}
	},
	buildings = {
		base = {
			health = 100, is_alien = false, is_tall = true, click = {name = 'resources', amount = 1},
			production = {
				{name = 'plate', price = 2},
				{name = 'auto_click', price = 10},
				{name = 'double_click', price = 10},
				{name = 'factory', price = 50},
				{name = 'heavy_factory', price = 500},
			},
			info = 'Build plates first then factories and units.\nDestroy all alien hives.'
		},
		factory = {
			health = 100, is_alien = false, is_tall = true, production = {{name = 'motoquad', price = 3}, {name = 'hovercraft', price = 5}},
			info = 'Produces basic units to fight aliens.'
		},
		heavy_factory = {
			health = 500, is_alien = false, is_tall = true, production = {{name = 'tower', price = 50}, {name = 'robot', price = 100}},
			info = 'Produces basic units to fight aliens.'
		},
		double_click = {
			health = 50, is_alien = false, resources_multiplier = 2,
			info = 'Double resources on each click.'
		},
		auto_click = {
			health = 50, is_alien = false, action = {is_click = true}, cooldown = 0.5,
			info = 'Automatically clicks for resources.'
		},
		hive_lvl1 = {health = 100, is_alien = true, action = {spawn = 'alien_lvl1'}, cooldown = 10},
		hive_lvl2 = {health = 200, is_alien = true, action = {spawn = 'alien_lvl2'}, cooldown = 15},
		hive_lvl3 = {health = 400, is_alien = true, action = {spawn = 'alien_lvl3'}, cooldown = 20},
		hive_lvl4 = {health = 1000, is_alien = true, is_tall = true, action = {spawn = 'alien_lvl4'}, cooldown = 30}
	},
}
