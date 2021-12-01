regions = {
	{ -- 1x1 tree near entrance | 1
		x = 0,
		y = 0,
		w = 128,
		h = 128,
        bg = 0, -- 0 for tree, 12 for outside, 133 for foliage
		exits = {
			-- { start = y-33
			-- 	x = 11, y = -1,
			-- 	dir = 'top',
			-- 	dx = -4, dy = 63,
			-- 	region = 2
			-- },
			-- {
			-- 	x = 0, y = 13,
			-- 	dir = 'left',
			-- 	dx = 47, dy = 12,
			-- 	region = 3,
			-- 	col = 12
			-- },
			-- {
			-- 	x = 15, y = 10,
			-- 	dir = 'right',
			-- 	dx = 1, dy = 50,
			-- 	region = 4
			-- }
		}
	},
	{ -- 3-high | 2
		x = 0,
		y = 128,
		w = 128,
		h = 384,
        bg = 0,
		exits = {
			-- { start = y-36
			-- 	x = 7,
			-- 	y = 63,
			-- 	dir = "bottom",
			-- 	dx = 4,
			-- 	dy = -64,
			-- 	region = 1
			-- },
			-- {
			-- 	x = 15, y = 19,
			-- 	dir = 'right',
			-- 	dx = 1, dy = -17,
			-- 	region = 4
			-- },
			-- {
			-- 	x = 0, y = 20,
			-- 	dir = 'left',
			-- 	dx = 79, dy = -10,
			-- 	col = 12,
			-- 	region = 6
			-- },
			-- {
			-- 	x = 7, y = 16, dir = "top", 
			-- 	region = 9, dx = 100, dy = -1
			-- }
		}
	},
    { -- outside room | 3
		x = 256,
		y = 0,
		w = 128,
		h = 256,
        bg = 12,
		exits = {
			-- { start = y-32
			-- 	x = 47,
			-- 	y = 25,
			-- 	dir = 'right',
			-- 	region = 1,
			-- 	dx = -47,
			-- 	dy = -12,
			-- 	col = 0
			-- }
		}
    },
	{ -- 4-high | 4
		x = 128,
		y = 0,
		w = 128,
		h = 512,
		bg = 0,
		exits = {
			-- { start = y-40
			-- 	dir = 'left',
			-- 	x = 16, y = 60,
			-- 	dx = -1, dy = -50,
			-- 	region = 1
			-- },
			-- {
			-- 	dir = 'left',
			-- 	x = 16, y = 2,
			-- 	dx = -1, dy = 17,
			-- 	region = 2
			-- },
			-- {
			-- 	x = 31, y = 31,
			-- 	dir = 'right',
			-- 	dx = 49 , dy = -13,
			-- 	col = 12,
			-- 	region = 5
			-- }
		},
	},
	{ -- water branch | 5
	 	x = 640, y = 128, w = 256, h = 128,
		bg = 12, clouds = true,

		exits = {
			-- { start = y-43
			-- 	x = 80, y = 18, dir = "left", col = 0,
			-- 	dx = -49, dy = 13, region = 4
			-- }
		}
	},
	{ -- leaf-required branch | 6
		x = 384, y = 0,
		w = 256, h = 128,
		bg = 12,
		clouds = true,	
		exits = {
			-- { start = y-44
			-- 	x = 79, y = 10,
			-- 	dir = 'right',
			-- 	region = 2, 
			-- 	dx = -79, dy = 10,
			-- 	col = 0	
			-- },
			-- {
			-- 	x = 48, y = 2,
			-- 	dir = 'left',
			-- 	region = 7, 
			-- 	dx = 31, dy = 24,
			-- 	col = 0	
			-- }
		}
	},
	{ -- leaf-gated treetop | 7
		x = 384, y = 128,
		w = 256, h = 128,
		bg = 133,
		exits = {
			-- { start = y-46
			-- 	x = 79, y = 26,
			-- 	dir = 'right',
			-- 	region = 6, 
			-- 	dx = -31, dy = -24,
			-- 	col = 12
			-- },
			-- {
			-- 	x = 53, y = 31,
			-- 	dir = 'bottom',
			-- 	region = 8, 
			-- 	dx = 30, dy = -31
			-- }
		}
	},
	{ -- nut room | 8
		x = 640, y = 0, w = 128, h = 128,
		bg = 0,
		exits = {
			-- { start = y-48
			-- 	x = 83, y = 0, 
			-- 	dir = 'top',
			-- 	region = 7,
			-- 	dx = -30, dy = 31
			-- }
		},

		pickups = {
			nut = {
				x = 89.5, y = 5.5
			}
		}
	},
	{ -- leaf room | 9
		x = 768, y = 0, w = 256, h = 128,
		bg = 0, 

		exits = {
			-- { start = y-49
			-- 	x = 107, y = 15, dir = "bottom", 
			-- 	region = 2, dx = -100, dy = 1
			-- },
			-- {
			-- 	x = 122, y = 0, dir = "top",
			-- 	region = 10, dx = -54, dy = 47
			-- }
		},

		pickups = {
			leaf = {
				x = 101, y = 10.5
			}
		}
	},
	{ -- bottom foliage | 10
		x = 256, y = 256, w = 384, h = 128,
		bg = 133, 

		exits = {
			-- { start = y-51
			-- 	x = 68, y = 47, dir = "bottom",
			-- 	region = 9, dx = 54, dy = -47
			-- },
			-- {
			-- 	x = 35, y = 32, dir = "top", 
			-- 	region = 11, dx = 2, dy = 31
			-- }
		},
		pickups = {
			pebble = {
				x = 75.5, y = 45
			}
		}
	},
	{ -- top foliage | 11
		x = 256, y = 384, w = 384, h = 128,
		bg = 133, 

		exits = {
			-- { start = y-53
			-- 	x = 37, y = 63, dir = "bottom", 
			-- 	region = 10, dx = -2, dy = -31
			-- },
			-- {
			-- 	x = 75, y = 48, dir = "top", 
			-- 	region = 12, dx = 44, dy = 14
			-- }
		}
	},
	{ -- boss room | 12
		bg = 12, 
		x = 768, y = 256, w = 256, h = 256, 
		clouds = true,
		pickups = {
			pebble = {
				x = 119.5, y = 61
			}
		}
	},
	{ -- tutorial room | 13
		x = 896, y = 128, w = 128, h = 128, bg = 1
	}
}

dirs = {
	'left',
	'right',
	'top',
	'bottom'
}

function make_exit(y)
	local rgn = mget(80, y)
	if rgn == 0 then return end
	regions[rgn].exits[#regions[rgn].exits + 1] = {
		region = mget(81, y),
		x = mget(82, y),
		y = mget(83, y),
		dx = mget(84, y) - 128,
		dy = mget(85, y) - 128,
		dir = dirs[mget(86, y)],
		col = mget(87, y)
	}
end

function init_exits()
	-- x = 80 y = 32
	for i = 32, 64, 1 do
		make_exit(i)
	end
end

function draw_exits() 
	rgn = regions[s.region]

	for i, r in pairs(rgn.exits) do
		if r.col then
			local mx = r.x * 8 + 4 - s.x
			local my = r.y * 8 + 4 - s.y

			if r.dir == "right" then
				my -= 15
				rectfill(mx, my, mx + 8, my + 30, r.col)
				rectfill(mx - 2, my, mx - 2, my + 30, r.col)
			elseif r.dir == "left" then
				my -= 15
				mx -= 1
				rectfill(mx, my, mx - 8, my + 30, r.col)
				rectfill(mx + 2, my, mx + 2, my + 30, r.col)
			end
		end
	end
end

function draw_cloud(x, y, w, h, col)
	for i = 0, w, 1 do
		line(x + i, y, x + i - h / 2, y + h + 1, col)
	end
end

function draw_clouds()
	local clouds = {
		-- x, y, w, h, xscroll, yscroll
		0, 10, 32, 16, 0.75, 34,
		10, 35, 42, 6, 2, 24,
		20, 60, 48, 24, 0.4, 40,
		30, 0, 24, 10, 1.25, 50,
		40, 40, 36, 14, 1, 60,
		54, 48, 18, 18, 1, 60
	}
	local margin = 50
	local tot = margin * 2 + 128
	for i = 1, #(clouds), 6 do
		local cx = (clouds[i] + truetick * clouds[i + 4]) % tot - margin
		local cycles = flr((clouds[i] + truetick * clouds[i + 4]) / tot)
		local cy = (clouds[i+1] + (cycles * clouds[i + 5])) % 64
		if boss_state == 1 or boss_state == 2 then
			draw_cloud(cx, cy, clouds[i+2], clouds[i+3], 2)
		else
			draw_cloud(cx, cy, clouds[i+2], clouds[i+3], 7)
		end
	end
end

function init_enemies(x, y, w, h)
	for i = x, x + w, 1 do
		for j = y, y + h, 1 do
			local tile = mget(i, j)
			if fget(tile, 3) then
				if tile == 112 then
					make_bee(i - 2.75, j)
				elseif tile == 113 then
					make_bee(i - 3.25, j)
				elseif tile == 65 then
					make_beetle(i - 1, j)
				elseif tile == 98 then
					make_spider(i + 0.5, j + 0.5)
				elseif tile == 6 then
					make_spring(i, j)
				end
			end
		end
	end
end

function switch_region(data, dir_x, dir_y)
	player.x += data.dx + dir_x
	player.y += data.dy + dir_y
	s.region = data.region
	rgn = regions[s.region]
	s.scrollx = rgn.x + 64
	s.scrolly = rgn.y + 64

	if not dir_x == 0 then
		player.dx /= 3
	end

	pal()
	if rgn.bg > 16 then
		pal(0, rgn.bg, 1)
	else
		pal(0, 128, 1)
	end

	enemies = {}
	worms = {}
	boss_state = 0
	webs = {}

	init_enemies(rgn.x / 8, rgn.y / 8, rgn.w / 8, rgn.h / 8)

	if rgn.pickups then
		for i, p in pairs(rgn.pickups) do
			if not pickups[i].held then
				pickups[i].x = p.x
				pickups[i].y = p.y
				pickups[i].drop(pickups[i])
				if i == 'nut' then
					pickups[i].spr = 15
				end
			end
		end
	end

	if data.region == 12 then
		boss_state = 1
		check_point_x = 119
		check_point_y = 61
		check_point_rgn = 12
		player:heal()
		-- make_worm(108, 55, 6)
	elseif data.region == 10 then
        if not new_music then
            music(16)
            new_music = true
        end
	end
	update_cam()
end