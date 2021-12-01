pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- earthapple
-- upper 🐱
text = {}
tick = 0
truetick = 0
beantimer = -1
beanbottom = 12
boss_state = 0 -- 0 = nonexistent, 1 = same room, 2 = alive, 3 = defeated
game_state = 1 -- 0 = gameplay, 1 = title screen, 2 = tutorial, 3 = difficulty select, 4 = victory

difficulty = 1
speedmod = 0

check_point_x = 37.5
check_point_y = 28
check_point_rgn = 3

stopped = false

function _init()
    init_pickups()
    init_exits()    
    -- switch_region({region = 12, dx = 119, dy = 60}, 0, 0)
end

function update_bean()
    if beantimer > 0 then
        beantimer -= 1
    elseif beantimer == 0 then
        if beanbottom < 0 then
            beantimer = -1
        else
            mset(122, beanbottom, 46)
            beantimer = 8
            beanbottom -= 1
            make_splash_particle(122.75 * 8, (beanbottom + 2) * 8 - 3, 8, 2.5, 3)
        end
    end
end

function add_text(x, y, content, col)
    text[#(text) + 1] = {
        x = x, y = y, content = content, col = col
    }
end

function draw_text()
    for i, t in pairs(text) do
        if flr(tick / 8) % 3 < 2 then
            print(t.content, t.x * 8 - s.x, t.y * 8 - s.y, t.col)
        end
    end
end

function update_apple(finish)
    local xdiff = player.x - 99.5
    local ydiff = player.y - 58.5

    if abs(xdiff) < 1.5 and abs(ydiff) < 1.5 then
        if finish then
            game_state = 4
        else
            boss_state = 2
            init_path()
            local w = make_worm(99, 59, 12, 3)
            music(36)
            w.respawn = true
            w.inv_timer = 60
            player.dy = -0.9
        end
    end
end

function draw_apple()
    spr(66, 784 - s.x, 464 - s.y, 1, 2)
    spr(88, 792 - s.x, 464 - s.y, 1, 2)
end

function update_health()

end

function _update()
    truetick += 1
    if game_state == 0 or game_state == 3 then
        player:update()
        if boss_state == 2 then
            make_rain_particle(rnd(54) + 784, 272)
            make_rain_particle(rnd(54) + 838, 272)
            make_rain_particle(rnd(54) + 892, 272)
            make_rain_particle(rnd(54) + 946, 272)
        end
        update_enemies()
        if boss_state == 1 then
            update_apple(false)
        elseif boss_state == 2 then
            update_boss()
        elseif boss_state == 3 then
            update_apple(true)
        end
        update_droplet()
        update_bean()
        update_pickups()
        update_particles()
        update_cam()
        update_tt()
        tick += 1

        if game_state == 3 then
            if player.x > 124.5 and player.y > 22 and player.just_doact then
                game_state = 2
            end
        end

    elseif game_state == 1 then
        if btnp(🅾️) then
            game_state = 3
            switch_region({region = 13, dx = 114, dy = 29.9}, 0, 0)
        end
    elseif game_state == 2 then
        if btnp(⬆️) then
            difficulty -= 1
        elseif btnp(⬇️) then
            difficulty += 1
        end
        if difficulty < 0 then difficulty = 2 end
        difficulty = difficulty % 3
        
        if btnp(🅾️) then
            game_state = 0
            music(0)
            if difficulty == 2 then speedmod = 1 
            elseif difficulty == 0 then player.hp = 0 end
            switch_region({region = 3, dx = 0, dy = 0}, 0, 0)
            player.x = 37.5
            player.y = 28
        end
    end
end

function draw_space()
    if s.region == 3 then
        local x = 41.5
        local y = 11.5
        local s_sx, s_sy = tomap(x, y)
        local s_sw, s_sh = tomap(x + 4, y + 4)
        s_scroll = flr(tick / 5)
        rectfill(s_sx, s_sy, s_sw, s_sh, 1)

        local function draw_star(b_x, b_y, b_w, star_x, star_y)
            temp_x = (star_x + s_scroll / 8) % (b_w + 1 / 8)

            local sx, sy = tomap(temp_x + b_x, star_y + b_y)
            pset(sx, sy, 7)
        end

        local star_coords = {
            3, 3,
            1, 12,
            11, 8,
            23, 7,
            18, 15,
            6, 23,
            28, 21,
            15, 28
        }
        
        for i = 1, #star_coords, 2 do
            draw_star(x, y, 4, star_coords[i] / 8, star_coords[i + 1] / 8)
        end

        if mget(43, 13) == 20 and abs(player.x - x - 1.5) < 1 and abs(player.y - y - 1.5) < 1 then
            mset(43, 13, 21)
            add_text(42, 16, tick / 30, 1)
        end

        pset(s_sx, s_sy, 12)
        pset(s_sx, s_sh, 12)
        pset(s_sw, s_sy, 12)
        pset(s_sw, s_sh, 12)
    end

end

function _draw()
    if not stopped and (game_state == 0 or game_state == 3) then
        cls()
        if boss_state == 1 or boss_state == 2 then
            rectfill(0, 0, 128, 128, 1)
        elseif regions[s.region].bg <= 16 then
            rectfill(0, 0, 128, 128, regions[s.region].bg)
        else
            rectfill(0, 0, 128, 128, 0)
        end
        if regions[s.region].clouds then
            draw_clouds()
        end
        draw_exits()
        draw_space()
        draw_droplet()
        draw_tiles()
        draw_webs()
        draw_enemies()
        if boss_state == 2 then
            draw_boss()
        end
        if boss_state > 1 then
            draw_apple()
        end
        draw_pickups()

        if game_state == 3 then
            print("⬅️➡️/ad to move", 12, 24, 6)
            print("⬆️/z/n to (double) jump", 12, 32, 6)
            print("⬇️/x/m to grab/drop", 12, 40, 6)
        end

        player:draw()

        draw_particles()
        draw_text()

        draw_tt()
    elseif game_state == 1 then
        pal(0, 128, 1)
        rectfill(0, 0, 128, 128, 0)        
        spr(90, 40, 40, 6, 3)

        if truetick % 32 > 7 then
            print("press [z] to start", 28, 78, 6)
        end
    elseif game_state == 2 then
        rectfill(0, 0, 128, 128, 1)
        
        for i = 1, 3 do
            local col = 2
            local border = 1
            if i == difficulty + 1 then
                col = 13
                border = 7
            end
            local y = i * 24 + 8
            rectfill(33, y - 1, 95, y + 19, border)
            rectfill(34, y, 94, y + 18, col)
        end

        print("⬆️,⬇️ to select", 34, 8, 7)
        print("[z] to confirm", 36, 18, 7)
        print("easy", 57, 39, 7)
        print("normal", 53, 64, 7)
        print("hard", 57, 87, 7)

        if difficulty == 0 then
            print("you cannot die", 37, 112, 7)
        elseif difficulty == 1 then
            print("default difficulty", 29, 112, 7)
        else
            print("enemies are faster", 29, 112, 7)
        end
    elseif game_state == 4 then
        pal()
        cls()
        rectfill(23, 31, 105, 73, 13)
        rectfill(24, 32, 104, 72, 1)
        print("time:", 28, 36, 6)
        print(tick / 30, 50, 36, 7)
        
        print("difficulty:", 28, 48, 6)
        local diff_str = "normal"

        if difficulty == 0 then
            diff_str = "easy"
        elseif difficulty == 2 then
            diff_str = "hard"
        end
        print(diff_str, 74, 48, 7)
        
        print("congratulations!", 32, 64, 7)
    end
end



function get_length(x, y)
    return min(sqrt(x * x + y * y), 10000)
end

function get_normalized(x, y)
    local l = get_length(x, y)
    if l == 0 then l = 1 end
    return {x = x / l, y = y / l}
end

function in_web(w, x, y)
    local dx = x - w.center.x
    local dy = y - w.center.y
    local l = get_length(dx, dy)
    local v = get_normalized(dx, dy)

    for i = 1, #(web_dirs), 2 do

        if abs(web_dirs[i] - v.x) + abs(web_dirs[i + 1] - v.y) < 0.75 then
            return (l - 1.5 <= w.anchors[(i + 1) / 2])
        end
    end
    return false
end

function tomap(x, y)
    return x * 8 - s.x, y * 8 - s.y
end

function add_attributes(t1, t2) -- saves tokens
    for k, v in pairs(t2) do
        t1[k] = v
    end
end



function solid(x, y, v)
    tile = mget(x, y)
    if v then
        return fget(tile, 0, 1)
    else
        return fget(tile, 0)
    end
end

function solid_area(x, y, w, h)
    return solid(x - w, y - h) or solid(x + w, y - h) or solid(x - w, y + h) or solid(x + w, y + h)
end

function oneway(x, y, h, dy)
    if dy > 0 then
        if flr(y + dy + h) > flr(y) then
            tile = mget(x, y + dy + h)
            return fget(tile, 1)
        end
    end
    return false
end



function make_actor(x,y)
	return {
		x = x,
		y = y,
		dx = 0,
		dy = 0,
		w = 0.33,
		h = 0.2
	}
end

function move_actor_x(a)
	-- move along x if no solids
	if not solid_area(
		a.x+a.dx,a.y,a.w,a.h) then
		a.x += a.dx
	else
		ax = a.x
		if a.dx > 0 then
			if abs(a.dx) >= 0.5 then
				ax += 0.5
			end
			a.x = ceil(ax) - a.w - 0.05
		else
			if abs(a.dy) <= -0.5 then
				ax -= 0.5
			end
			a.x = flr(ax) + a.w + 0.05	
		end
		a.dx = 0
	end
end

function move_actor_y(a) -- 100 extra tokens
	if not (solid_area(
		a.x,a.y+a.dy,a.w,a.h) or
		oneway(a.x, a.y, a.h, a.dy)) then
		a.y+=a.dy
	else
		ay = a.y
		if a.dy > 0 then
			if abs(a.dy) >= 0.3 then
				ay += 0.3
			end
			a.y = ceil(ay) - a.h - 0.05
		else
			if abs(a.dy) <= -0.3 then
				ay -= 0.3
			end
			a.y = flr(ay) + a.h + 0.05
		end
		a.dy = 0
	end
end

function move_actor(a)
	move_actor_x(a)
	move_actor_y(a)
end


player = make_actor(0,0)

add_attributes(player, { 
	h=0.3,
	max_spd=0.4,
	max_fall=1,
	hold=0.1,
	buf=0,
	coy=0,
	fliph=false,
	jumptime=5,
	holding=false,
	held=0,
	last_jumpact=false,
	jumpact=false,
	just_jumpact=false,
	last_doact=false,
	doact=false,
	just_doact=false,
	hp = 5,
	maxHP = 5,
	inv_timer = 0,
	do_draw = true,
	doublejump = false
})


function player:damage()
	if self.inv_timer > 0 then return false end

	self.hp += (difficulty == 0) and 1 or -1

	for i = 0, 10, 1 do
		make_particle(self.x * 8 + self.w / 2, self.y * 8 + self.h / 2, rnd(6) + 5, rnd(4) - 2, rnd(4) - 2, 7)
	end

	if self.hp <= 0 then
		self.x = check_point_x
		self.y = check_point_y
		switch_region({region = check_point_rgn, dx = 0, dy = 0}, 0, 0)
		if boss_state > 0 then
			music(16)
		end
		self:heal()
	end

	self.inv_timer = 45

	sfx(24, 3)

	return true
end

function player:heal()
	if difficulty > 0 then
		self.hp = 5
		make_splash_particle(self.x * 8, self.y * 8, 20, 3, 11)
		sfx(26, 3)
	end
end

function player:update_input()
	self.jumpact = btn(⬆️) or btn(🅾️)
	self.just_jumpact = btn(⬆️) or btn(🅾️)

	if self.last_jumpact then
		if self.jumpact then
			self.just_jumpact = false
		else
			self.last_jumpact = false
		end
	elseif self.jumpact then
		self.last_jumpact = true
	end

	self.doact = btn(⬇️) or btn(❎)
	self.just_doact = btn(⬇️) or btn(❎)

	if self.last_doact then
		if self.doact then
			self.just_doact = false
		else
			self.last_doact = false
		end
	elseif self.doact then
		self.last_doact = true
	end
end

function player:update_speed()
	local _dx = self.dx

	if btn(➡️) or btn(⬇️, 1) then
		_dx += 0.15
		self.fliph = false

	elseif btn(⬅️) or btn(❎, 1) then
		_dx-= 0.15
		self.fliph=true
		
	else
		if abs(_dx)<0.1 then
			_dx=0
			
		elseif _dx>0 then
			_dx-=0.1
		
		elseif _dx<0 then
			_dx+=0.1
		end
	end

	if _dx> 0.4 then
		_dx= 0.4

	elseif _dx< - 0.4 then
		_dx= - 0.4
	end

	-- update gravity
	self.dy+=0.1
	self.dy = min(self.dy, self.max_fall)

	self.dx = _dx
end

function player:update_jump()
	if self.just_jumpact then
		self.buf=4
	
	elseif self.buf>0 then
		self.buf-=1
	end

	local _x = self.x
	local _y = self.y
	local _dy = self.dy
	
	local grounded = ((solid(_x - 0.33, _y + 0.5, true) or (solid(_x + 0.33, _y + 0.5, true)) or oneway(_x, _y, self.h, _dy))) and _dy > 0
	
	if grounded then
		self.coy=3
		self.doublejump = true
	elseif self.coy>0 then
	 	self.coy-=1
	end
	
	validjump=self.coy>0 and self.buf>0
	validdouble=not validjump and self.doublejump and self.just_jumpact
	validhold=self.jumptime>0 and self.jumpact
	
	if validjump then
		_dy=-0.475
		self.coy=0
		self.jumptime = 6
		sfx(22, 3)
	elseif validdouble then
		_dy = -0.5
		self.dx /= 1.5
		self.doublejump = false
		self.jumptime = 4
		sfx(23, 3)
	elseif validhold then
		_dy-=self.hold
	end
	
	if self.jumptime>0 then
		self.jumptime-=1
	end
	-- update pos

	if _dy > 0.2 then
		if solid(_x, _y + _dy * 1.2, true) or oneway(_x, _y, self.h, _dy * 1.2) then
			xoff = rnd(4 + _dy) - (2 + _dy / 2)
			make_splash_particle(_x * 8 + xoff, _y * 8 + 4, 5, 1.5, 7)
		end
	end

	self.dy = _dy
end

function player:update()
	self:update_speed()
	self:update_input()
	self:update_jump()

	move_actor(self)
	
	self.do_draw = true

	if self.inv_timer > 0 then
		self.inv_timer -= 1
		if tick % 2 == 0 then
			self.do_draw = false
		end
	end
end

function player:draw_hearts()
	if difficulty > 0 then
		for i = 1, player.maxHP, 1 do
			x = -8 + i * 10
			if player.hp >= i then
				spr(4, x, 1)
			else
				spr(5, x, 1)
			end
		end
	else
		spr(120, 1, 1)
		print('x', 10, 3, 7)
		print(player.hp, 15, 3, 7)
	end
end

function player:draw()
	self:draw_hearts()
	
	if self.do_draw then
		sx, sy = tomap(self.x-0.5, self.y-0.5)
	
		spr(1, sx, sy, 1, 1, self.fliph)
	end
end


function draw_tiles()
	xt = ceil(s.x / 8) - 1
	yt = ceil(s.y / 8) - 1
	xoff = -s.x % 8 - 8
	yoff = -s.y % 8 - 8
	map(xt,yt,xoff,yoff,18,18,16)
end


pickups = {}
new_music = false

function make_pickup(_spr)
    local p = make_actor(-1, -1)
    p.held = false
    p.spr = _spr
    return p
end

function init_pickups()
    local leaf = make_pickup(3)
    leaf.h = 0.4
    leaf.w = 0.3
    leaf.tt = "hold 🅾️ (jump) to glide"
    function leaf:update()
        move_actor(self)
        if self.held and player.dy > 0.05 and player.jumpact then
            player.dy = 0.05
        end
    end
    function leaf:drop()
        self.dy = 0.15
    end

    local nut = make_pickup(15) -- while holding it's 31/47
    nut.h = 0.4
    nut.w = 0.4
    nut.tt = "can hold water"
    nut.full = false

    function nut:update()
        move_actor(self)
        if self.held then
            self.spr = 31
            if self.full then
                self.spr = 47
            end
        end
    end

    function nut:drop()
        self.dy = 0.5
        if self.full then
            self.full = false
            splash_particles(self.x * 8, self.y * 8 + 4)
            local bean_x = 122
            local bean_y = 13
            
            if abs(bean_x - player.x) < 2 and abs(bean_y - player.y) < 2 then
                beantimer = 10
            end

            if self.held then
                self.spr = 31
            end
        end
    end

    local pebble = make_pickup(54)
    pebble.h = 0.4
    pebble.w = 0.5
    pebble.tt = "can be thrown at enemies"
    pebble.falling = false

    function pebble:collision(e, ex, ey, ew, eh)
        local xdiff = (ex + ew) - (self.x + self.w)
        local ydiff = (ey + eh) - (self.y + self.h)

        if abs(xdiff) < ew + 0.2 + self.w and abs(ydiff) < eh + 0.2 + self.h then
            sfx(21, 3)
            if not (e.inv_timer > 0) then
                e:damage()
            end
        end
    end

    function pebble:update()
        if self.held then
            self.dx = 0
            self.dy = 0
        end
        if self.falling then
            self.dy += 0.07
            self.dx -= sgn(self.dx) * min(0.03, abs(self.dx))
        elseif abs(self.dx) > 0 then
            self.dx -= sgn(self.dx) * min(0.08, abs(self.dx))
            self.dy = 0.5
        end
        
        move_actor(self)

        local grounded = (solid(self.x, self.y + 0.5, true) or oneway(self.x, self.y, self.h, 0.5))
        
        if self.dy == 0 and self.falling and grounded then
            self.falling = false
            self.dy = 0.5
        end

        if (abs(self.dx) + abs(self.dy)) > 0.3 then
            for i, e in pairs(enemies) do
                if not e.is_spring then
                    self:collision(e, e.x, e.y, e.w, e.h)
                end
            end

            for i, w in pairs(worms) do
                for j, s in pairs(w.true_segments) do
                    self:collision(w, s.x, s.y, 0.5, 0.5)
                end
            end
        end
    end

    function pebble:drop()
        if self.held then
            self.y += 0.3
            self.dy = -0.4 + player.dy / 3
            self.dx = 0.85
            if player.fliph then
                self.dx *= -1
            end
            self.falling = true
        else
            self.dy = 0.6
        end
    end

    pickups['leaf'] = leaf
    pickups['nut'] = nut
    pickups['pebble'] = pebble
end

function update_pickups()
    for i, p in pairs(pickups) do 
        p:update()
    end

    if player.just_doact then
        if player.holding then
            pickups[player.held]:drop(pickups[player.held])
            pickups[player.held].held = false
            player.holding = false
        else
            for i, p in pairs(pickups) do
                local dx = abs(player.x - p.x)
                local dy = abs(player.y - p.y)
                if dx + dy < 2 then
                    player.holding = true
                    player.held = i
                    p.held = true
                    if p.tt then
                        show_tt(p.tt)
                        player:heal()
                        check_point_x = p.x
                        check_point_y = p.y
                        check_point_rgn = s.region
                        p.tt = false
                    end
                    break
                end
            end
        end
    end

    if player.holding then
        i = player.held
        pickups[i].x = player.x
        pickups[i].y = player.y - pickups[i].h - player.h
    end
end

function draw_pickups()
    for i, p in pairs(pickups) do
        sx = p.x * 8 - 4 - s.x
        sy = p.y * 8 - 4 - s.y
        spr(p.spr, sx, sy)
    end
end



drop_x = 98.5
drop_y = 10

function splash_particles(x, y)
    make_splash_particle(x, y, 15, 3, 13)
end

function update_droplet()
    if s.region == 5 then

        drop_y += 0.5
        if drop_y > 29 then
            drop_y = 10
            splash_particles(drop_x * 8 + 4, 29.5 * 8)
        end

        if abs(player.x - drop_x - 0.5) < 1 and abs(drop_y - player.y + 0.5) < 0.5 then
            if pickups['nut'].held and not pickups['nut'].full then
                pickups['nut'].full = true
            else
                splash_particles(drop_x * 8 + 4, drop_y * 8)
            end
            drop_y = 10
        end
    end
end

function draw_tree()
    local x = 783 - s.x
    local y = 130 - s.y
    rectfill(x - 2, y, x + 1, y + 112, 4)
    rectfill(x + 33 - 1, y, x + 33 + 2, y + 112, 4)
    rectfill(x, y, x + 33, y + 112, 0)
end

function draw_droplet()
    if s.region == 5 then
        draw_tree()
        spr(62, drop_x * 8 - s.x, drop_y * 8 - s.y)
    end
end


enemies = {}
webs = {}
web_dirs = {0,-1,1,-1, 1,0,1,1,0,1,-1,1,-1,0,-1,-1,0,-1}

function make_enemy(x, y, hp)
    local e = make_actor(x, y)
    e.hp = hp
    e.inv_timer = -3

    function e:damage()
        if self.inv_timer > 0 then return false end
        xpos = self.x * 8 + self.w * 8
        ypos = self.y * 8 + self.h * 8
        for i = 0, 10, 1 do
            make_particle(xpos, ypos, rnd(6) + 5, rnd(4) - 2, rnd(4) - 2, 7)
        end
        self.inv_timer = 25
        self.hp -= 1

        return true
    end

    function e:update_timer()
        if self.inv_timer > 0 then
            self.inv_timer -= 1
        elseif self.hp <= 0 then
            del(enemies, self)
        end
    end

    return e
end

function make_beetle(x, y)
    local b = make_enemy(x, y, 1)
	b.w = 0.95
    b.h = 0.45
    b.left = true
    b.charging = false
    b.charge_timer = 0

    function b:update()
        self:update_timer()

        move_dir = 0.06 + speedmod * 0.02
        if self.left then move_dir *= -1 end
        if self.charging then move_dir *= 3 + speedmod end

        -- check for wall
        check_x = self.x + 1 + move_dir + sgn(move_dir)
        to_wall = solid(check_x, self.y)
        -- check foor lack of floor
        to_hole = not solid(check_x, self.y + 1, true)

        xdiff = player.x - self.x - player.w * 2
        ydiff = player.y - self.y - 1
        facing_player = abs(xdiff) < 6 and sgn(xdiff) == sgn(move_dir)

        if abs(player.y - self.y) < 1 and facing_player and not self.charging then
            self.charging = true
            self.charge_timer = 7 - speedmod * 3
        end

        if self.inv_timer < 0 and abs(xdiff) < 1 and abs(ydiff) < 1 then
            if player:damage() then
                player.dy = -0.5
                player.dx = sgn(xdiff) * 0.5
            end
        end

        if to_wall or to_hole then
            self.left = not self.left
            if self.charging then
                self.charging = false
            end
        end

        self.dx = move_dir

        if self.charge_timer > 0 then
            self.charge_timer -= 1
        else
            self.x += 1
            move_actor(self)
            self.x -= 1
        end
    end

    function b:draw()
        if self.inv_timer % 4 > 1 then return end
        xpos = self.x * 8 - s.x
        ypos = self.y * 8 - s.y

        sprite = flr((tick / 6) % 4)

        if self.charge_timer > 0 then
            sprite = 1
        elseif self.charging then
            sprite = flr((tick / 2) % 4)
        end
        
        if sprite == 3 then sprite = 1 end

        sspr(0, 32 + sprite * 8, 16, 8, xpos, ypos, 16, 8, self.left)
    end

    enemies[#(enemies) + 1] = b
    return b
end

function make_bee(x, y)
    local b = make_enemy(x, y, 1)
	b.w = 0.45
    b.h = 0.45
    b.base_x = x
    b.base_y = y
    b.left = true
    
    function b:update()
        self:update_timer()

        local h_speed = 0.7 + speedmod * 0.4
        local v_speed = 0.5 + speedmod * 0.4
        local m_timer = 90 / h_speed
        diffx = abs((tick % m_timer) - m_timer / 2) / 8 * h_speed
        self.x = self.base_x + diffx
        self.left = (tick % m_timer) <= m_timer / 2
        self.y = b.base_y + sin(tick / 40 * v_speed)

        diff_x = abs(player.x - self.x - 0.5)
        diff_y = abs(player.y - self.y - 0.5)

        if self.inv_timer < 0 and diff_x < 0.5 and diff_y < 0.5 then
            if player:damage()  then
                player.dy = -0.5
                player.dx = 0
            end
        end
    end

    function b:draw()
        if self.inv_timer % 4 > 1 then return end
        spr(112 + flr((tick % 6) / 3), self.x * 8 - s.x, self.y * 8 - s.y, 1, 1, self.left)
    end

    enemies[#(enemies) + 1] = b
    return b
end

function make_web(x, y)
    local web = {}
    web.center = {x = x, y = y}
    web.anchors = {}
    web.chains = {}

    for i = 1, #(web_dirs) - 2, 2 do
        local dir_length = 0
        local dx = web_dirs[i]
        local dy = web_dirs[i + 1]
        
        for j = 0, 5, 1 do
            local nx = x + dx * j
            local ny = y + dy * j

            if ny < 0 or nx < 0 then break end
            
            local tile = mget(nx, ny)

            if fget(tile, 2) then break end
            dir_length = j
        end
        
        if dir_length == 5 then
            web.anchors[#(web.anchors) + 1] = -1
        else
            web.anchors[#(web.anchors) + 1] = dir_length
        end
    end

    for i, a in pairs(web.anchors) do
        local next_i = (i) % (#(web.anchors)) + 1
        local next_l = web.anchors[next_i]
        
        local l = min(a, next_l)
        local cx = web.center.x * 8
        local cy = web.center.y * 8
        local dx = web_dirs[i * 2 - 1] * 8
        local dy = web_dirs[i * 2] * 8
        local edx = web_dirs[next_i * 2 - 1] * 8
        local edy = web_dirs[next_i * 2] * 8
        if i % 2 == 0 then
            dx *= 0.7
            dy *= 0.7
        else
            edx *= 0.7
            edy *= 0.7
        end

        for j = 1, l, 1 do
            local chain = {}

            chain.x = cx + dx * j
            chain.y = cy + dy * j
            chain.ex = cx + edx * j
            chain.ey = cy + edy * j

            web.chains[#(web.chains) + 1] = chain
        end
    end
    
    webs[#webs + 1] = web

    return web
end

function draw_webs()
    for i, w in pairs(webs) do
        for j, c in pairs(w.chains) do
            line(c.x - s.x, c.y - s.y, c.ex - s.x, c.ey - s.y, 6)
        end

        for j, a in pairs(w.anchors) do
            local bx = w.center.x * 8
            local by = w.center.y * 8

            local dx = web_dirs[j * 2 - 1]
            local dy = web_dirs[j * 2]

            local lx = (a + 0.6) * dx * 8
            local ly = (a + 0.6) * dy * 8
            line(bx - s.x, by - s.y, bx + lx - s.x, by + ly - s.y, 7)
        end
    end
end

function make_spider(x, y)
    local sp = make_enemy(x, y, 1)
    sp.w = 0.95
    sp.h = 0.95
    sp.web = make_web(x, y)
    sp.target = {x, y}
    sp.frametick = 0

    function sp:draw()
        if self.inv_timer % 4 > 1 then return end
        local sx = self.x * 8 - 8 - s.x
        local sy = self.y * 8 - 8 - s.y
        local draw_spr = 98 + (flr(self.frametick / 2) % 2)
        spr(draw_spr, sx, sy, 1, 2, false)
        spr(draw_spr, sx + 8, sy, 1, 2, true)
    end

    function sp:update()
        self:update_timer()

        if in_web(self.web, player.x - 0.5, player.y - 0.5) then
            self.target = {x = player.x, y = player.y}
        else
            self.target = {x = self.web.center.x, y = self.web.center.y}
        end

        local dx = self.x - self.target.x
        local dy = self.y - self.target.y
        local spd = 0.075 + speedmod * 0.05
        if get_length(dx, dy) > spd then
            local v = get_normalized(-dx, -dy)
            self.x += v.x * spd
            self.y += v.y * spd
            self.frametick += 1
        end

        if self.inv_timer < 0 and abs(self.x - player.x) < 1.25 and abs(self.y - player.y) < 1.25 then
            if player:damage() then
                player.dy = -0.5
                player.dx /= 2
            end
        end
    end

    enemies[#(enemies) + 1] = sp
    return sp
end

function make_spring(x, y)
    local b = {}
    b.x = x
    b.y = y
    b.animTimer = 0
    b.is_spring = true
    
    function b:update()
        diff_x = abs(player.x - self.x - 0.5)
        diff_y = player.y - self.y - 0.3

        if diff_x < 1 and diff_y > -0.4 and diff_y < player.dy and player.dy > 0 then
            player.dy = -1.2
            player.doublejump = true
            self.animTimer = 12
            sfx(25, 3)
        end

        if self.animTimer > 0 then
            self.animTimer -= 1
        end
    end

    function b:draw()
        local sprite = 6
        sprite += (flr(self.animTimer / 4)) * 16
        spr(sprite, self.x * 8 - s.x, self.y * 8 - s.y, 1, 1, false)
    end
    
    enemies[#(enemies) + 1] = b
    return b
end

function update_enemies()
    for i, e in pairs(enemies) do
        e:update()
    end
end

function draw_enemies()
    for i, e in pairs(enemies) do
        e:draw()
    end
end



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


s = {};
s.x = 3
s.y = 3
s.scrollx = 3
s.scrolly = 3
s.region = 3
s.xm = 48
s.ym = 48

function update_cam()
	px = player.x * 8 - s.x
	py = player.y * 8 - s.y
	
	xr = 128 - s.xm;
	yr = 128 - s.ym;

	rgn = regions[s.region]

	rx_start = rgn.x
	rx_end = rgn.x + rgn.w - 128
	ry_start = rgn.y
	ry_end = rgn.y + rgn.h - 128

	if px > xr then
		s.scrollx = player.x * 8 - xr
	elseif px < s.xm then
		s.scrollx = player.x * 8 - s.xm
	end

	if py > yr then
		s.scrolly = player.y * 8 - yr
	elseif py < s.ym then
		s.scrolly = player.y * 8 - s.ym
	end

	if s.scrollx < rx_start then
		s.scrollx = rx_start
	elseif s.scrollx > rx_end then
		s.scrollx = rx_end
	end
	if s.scrolly < ry_start then
		s.scrolly = ry_start
	elseif s.scrolly > ry_end then
		s.scrolly = ry_end
	end

	rel_x = player.x - rx_start / 8
	rel_y = player.y - ry_start / 8
	rel_w = rgn.w / 8
	rel_h = rgn.h / 8

	for i, r in pairs(rgn.exits) do
		local dir_x = 0
		local dir_y = 0
		if r.dir == "left" then
			dir_x = -1
		elseif r.dir == "right" then
			dir_x = 1
		elseif r.dir == "top" then
			dir_y = -1
		else
			dir_y = 1
		end

		local xdiff = r.x - (player.x - dir_x * 1.5 - 0.5)
		local ydiff = r.y - (player.y - dir_y * 1.5 - 0.5)

		if abs(xdiff) < 2 and abs(ydiff) < 2 then
			switch_region(r, dir_x * 1, dir_y * 1)
		end
	end

	for i, p in pairs(pickups) do
		p_rel_y = p.y - ry_start / 8
		if p_rel_y > rel_h - 0.5 then
			if rgn.bottom then
				p.x = rgn.bottom.x
				p.y = rgn.bottom.y
			end
		end
	end
	s.x = flr(s.scrollx)
	s.y = flr(s.scrolly)
end



particles = {}

function make_particle(x, y, t, dx, dy, c)
    local p = {
        x = x,
        y = y,
        t = t,
        dx = dx,
        dy = dy,
        xfric = 0, 
        yfric = 0,
        c = c,
        check_collision = false
    }
    function p:on_collision() end
    
    particles[#(particles) + 1] = p
    return p
end

function update_particles()
    for i, p in pairs(particles) do
        p.x += p.dx
        p.y += p.dy
        p.dx -= p.xfric
        p.dy -= p.yfric
        p.t -= 1

        if p.check_collision then
            if solid((p.x + p.dx) / 8, (p.y + p.dy) / 8, true) then
                if p:on_collision() then
                    p.t = 0
                end
            end
        end
    end
end

function draw_particles()
    removequeue = {}
    for i, p in pairs(particles) do
        pset(p.x - s.x, p.y - s.y, p.c)
        if p.t <= 0 then
            removequeue[#(removequeue) + 1] = p
        end
    end

    for i, r in pairs(removequeue) do
        del(particles, r)
    end
end

function make_splash_particle(x, y, n, st, c)
    for i = 0, n - 1, 1 do
        xdir = (rnd(2) - 1)
        p = make_particle(x, y, 3 * st, xdir, -st * 0.7, c)
        p.yfric = rnd(0.1) - 0.15 * st
        p.t += rnd(5)
    end
end

function make_rain_particle(x, y)
    for i = 1, 4, 1 do
        local p = make_particle(x - flr(i / 2 - 0.5), y + i, 100, -2, 8, 13)
        p.check_collision = true
        function p:on_collision()
            local pt = make_splash_particle(self.x, self.y, 1, 1.5, 13)
            return true
        end
    end
end



tt_timer = 0
tt_text = ""
tt_active = false

function show_tt(text)
    tt_text = text
    tt_active = true
    tt_timer = 0
end

function update_tt()
    if tt_active then
        tt_timer += 1
    end
end

function draw_tt()
    if tt_active then
        y = 121
        if tt_timer < 14 then
            y = 128 - tt_timer / 2
        elseif tt_timer > 194 then
            tt_active = false
            y = 128
        elseif tt_timer > 104 then
            time = tt_timer - 104
            y = 121 + time / 2
        end
        rectfill(0, y, 128, y + 7, 12)
        print(tt_text, 2, y + 1, 1)
    end
end


path_data = {}
worms = {}
currentpath = {}

function bigsgn(n, min_val)
    if abs(n) >= min_val then
        return sgn(n)
    end
    return 0
end

function round(n)
    local p = n % 1
    if (p >= 0.5 and n > 0) or (p < 0.5 and n < 0) then
        return ceil(n)
    end
    return flr(n)
end

function make_worm(wx, wy, n, hp)
    local w = make_enemy(x, y, hp)
    -- head is first element in array
    w.segments = {}
    w.respawn = false
    w.main_target = player
    w.targets = {}
    for i = 1, n, 1 do
        w.segments[i] = {x = wx, y = wy}
        w.targets[i] = {x = wx + 1, y = wy}
    end
    w.true_segments = {}
    w.move_tick = #(worms) * 0.5
    w.next_path = {}

    function w:update()
        self.true_segments = {}
        self.move_tick += 0.2 + speedmod * 0.1
        if #(self.segments) <= 6 then
            self.move_tick += 0.05 + speedmod * 0.05
            if #(worms) == 1 then
                self.move_tick += speedmod * 0.05
            end
        end
        for i, sm in pairs(w.segments) do
            local diffx = self.targets[i].x - sm.x
            local diffy = self.targets[i].y - sm.y
            self.true_segments[i] = {x = sm.x + diffx * self.move_tick, y = sm.y + diffy * self.move_tick}

            local pdx = self.true_segments[i].x - player.x + 0.5
            local pdy = self.true_segments[i].y - player.y + 0.5

            if abs(pdx) < 0.5 and abs(pdy) < 0.5 and self.inv_timer <= 0 and self.hp > 0 then
                if player:damage() then
                    player.dy = -0.5
                end
            end

            if self.move_tick >= 1 then
                if i == 1 then
                    self:next_target()
                    self.move_tick -= 1
                end
            end
            if i == 1 then
                self.x = self.true_segments[1].x
                self.y = self.true_segments[1].y
            end
        end

        
        if self.hp <= 0 and self.inv_timer <= 0 then
            del(worms, self)
            if self.respawn then
                make_worm(round(self.x), round(self.y), 6, 2)
                make_worm(round(self.x), round(self.y), 6, 2)
            elseif #(worms) > 0 then
                worms[1].main_target = player
            else
                music(16)
                boss_state = 3
            end
        end
    end

    function w:draw()
        if self.inv_timer % 4 > 1 then return end
        for i, sm in pairs(self.true_segments) do
            local v = false
            local fh = false
            local fv = false
            local sx = self.segments[i].x
            local sy = self.segments[i].y
            local diffx = sx - self.targets[i].x
            local diffy = sy - self.targets[i].y

            if abs(diffy) >= abs(diffx) then
                v = true
                if diffy > 0 then -- down
                    fv = true
                end
                fh = fget(mget(sx + 1, sy), 0)
            else
                if diffx > 0 then
                    fh = true
                end
                fv = fget(mget(sx, sy - 1), 0)
            end

            local sp = 69
            local seg_len = #(self.true_segments)

            if v then
                if i % seg_len == 0 then -- butt
                    sp = 53
                elseif i == 1 then -- head
                    sp = 2
                else
                    sp = 52
                end
            else
                if i % seg_len == 0 then
                    sp = 37
                elseif i == 1 then
                    sp = 70
                end
            end

            spr(sp, sm.x * 8 - s.x, sm.y * 8 - s.y, 1, 1, fh, fv)
        end
    end

    function w:next_target()
        local tx = round(self.x)
        local ty = round(self.y)
        local path = dijkstra(tx, ty, flr(self.main_target.x), flr(self.main_target.y))
        local new_targets = {}

        for i, t in pairs(self.targets) do
            self.segments[i] = self.targets[i]
            if i < #(self.targets) then
                new_targets[i + 1] = t
            end
        end

        self.next_path = path[#(path) - 1]
        local last_x = self.next_path % 128
        local last_y = flr(self.next_path / 128)
        local last_v = get_normalized(tx - last_x, ty - last_y)
        new_targets[1] = {x = tx - last_v.x, y = ty - last_v.y}
        self.targets = new_targets
    end

    worms[#(worms) + 1] = w
    return w
end

function to_v(x, y)
    return x + y * 128
end

function calc_tiles()
    local rgn = regions[s.region]
    local m_x = flr(rgn.x) / 8
    local m_y = flr(rgn.y) / 8

    -- index tiles adjacent to ground
    for x = m_x, m_x + flr(rgn.w) / 8, 1 do
        for y = m_y, m_y + flr(rgn.h) / 8, 1 do
            local tile = mget(x, y)
            if fget(tile, 5) then
                for dx = -1, 1, 1 do
                    for dy = -1, 1, 1 do
                        local tx = x + dx
                        local ty = y + dy
                        local d_tile = mget(tx, ty)
                        if not fget(d_tile, 6) then
                            path_data.tiles[to_v(tx, ty)] = true
                        end
                    end
                end
            end
        end
    end
end

function calc_bridges()
    for i, d in pairs(path_data.tiles) do
        local tx = i % 128
        local ty = flr(i / 128)

        calc_tile_bridge(tx, ty, false)
        calc_tile_bridge(tx, ty, true)
    end
end

function calc_tile_bridge(tx, ty, do_y)
    for delta = 1, 5, 1 do
        local ttx = tx
        local tty = ty
        if do_y then
            tty += delta
        else
            ttx += delta
        end
        local t_tile = mget(ttx, tty)
        local v = to_v(ttx, tty)

        if fget(t_tile, 5) then break
        
        elseif path_data.tiles[v] then
            if delta <= 1 then break end
            for i = 1, delta - 1, 1 do
                if do_y then
                    path_data.bridges[to_v(tx, ty + i)] = true
                else
                    path_data.bridges[to_v(tx + i, ty)] = true
                end
            end
            break
        end
    end
end

function calc_anchors()
    for i, t in pairs(path_data.tiles) do
        local adjacent_x = calc_tile_anchor(i, false)
        local adjacent_y = calc_tile_anchor(i, true)

        if adjacent_x and adjacent_y then
            path_data.nodes[i] = true
        end
    end
end

function calc_tile_anchor(i, do_y)
    local diff = 1
    if do_y then diff = 128 end
    for j, v in pairs({-diff, diff}) do
        if path_data.tiles[i + v] then
            return true
        elseif path_data.bridges[i + v] then
            for delta = v, v * 5, v do
                local px = (i + delta) % 128
                local py = flr((i + delta) / 128)
                if path_data.tiles[i + delta] then return true
                elseif fget(mget(px, py), 4) then break
                end
            end
        end
    end
    return false
end

function init_path()
    path_data.tiles = {}
    path_data.bridges = {}
    path_data.nodes = {}

    -- index possible tiles to move to
    calc_tiles()
    -- index bridges
    calc_bridges()
    -- calculate cross-sections
    calc_anchors()

    -- draw_path_data()
end

function get_node_axis_connections(nx, ny, do_y, target)
    local connections = {}
    local skip = 0

    for delta = 1, 20, 1 do
        for sn = -1, 1, 2 do
            if sn != skip then
                local tx = nx
                local ty = ny
                if do_y then
                    ty += delta * sn
                else
                    tx += delta * sn
                end

                local v = to_v(tx, ty)

                if path_data.tiles[v] or path_data.bridges[v] then
                    if path_data.nodes[v] or v == target then
                        connections[v] = delta
                        if skip != 0 then
                            return connections
                        else
                            skip = sn
                        end
                    end
                else
                    if skip != 0 then
                        return connections
                    else
                        skip = sn
                    end
                end
            end
        end
    end

    return connections
end

function get_node_connections(nx, ny, target)
    local connections = get_node_axis_connections(nx, ny, false, target)
    for i, c in pairs(get_node_axis_connections(nx, ny, true, target)) do
        connections[i] = c
    end
    return connections
end

function nearest_path(x, y)
    for delta = 0, 100, 1 do
        local ny = to_v(x, y + delta)
        if path_data.tiles[ny] then
            return ny
        end
    end
end

function dijkstra(sx, sy, ex, ey)
    local v = to_v(sx, sy) -- node keys are their id
    local data = {path = {}, nodes = {}}
    data.nodes[v] = {dist = 0, prev = 'start', explored = false}
    local target = nearest_path(ex, ey)

    if v == target then return {target, target} end

    while true do
        local lowest_dist = 10000
        local key = 0

        for i, n in pairs(data.nodes) do
            if not n.explored then
                if n.dist < lowest_dist then
                    lowest_dist = n.dist
                    key = i
                end
            end
        end

        local nx = key % 128
        local ny = flr(key / 128)
        if key == 0 then return {target, target} end
        data.nodes[key].explored = true

        local cons = get_node_connections(nx, ny, target)

        for i, c in pairs(cons) do
            local ds = lowest_dist + c
            if i == target then
                local path = {i}
                local last_node = i
                data.nodes[i] = {
                    dist = ds, prev = key, explored = false
                }
                while true do
                    local prev = data.nodes[last_node].prev
                    if prev == 'start' then return path end
                    last_node = prev
                    path[#(path) + 1] = prev
                end
            end

            if data.nodes[i] then
                if data.nodes[i].dist > ds then
                    data.nodes[i].dist = ds
                    data.nodes[i].prev = key
                end
            else
                data.nodes[i] = {
                    dist = ds, prev = key, explored = false
                }
            end
        end
    end
end

function update_boss()
    -- currentpath = dijkstra(109, 55, flr(player.x), flr(player.y))
    if #(worms) > 1 then
        local t = tick % 120
        local tar = {x = 108, y = 55}
        if t < 30 then
            worms[1].main_target = player
            worms[2].main_target = tar
        elseif t >= 60 and t < 90 then
            worms[1].main_target = tar
            worms[2].main_target = player
        else
            worms[1].main_target = player
            worms[2].main_target = player
        end
    end
    for i, w in pairs(worms) do
        w:update_timer()
        w:update()
    end
end

function draw_boss()
    for i, w in pairs(worms) do
        w:draw()
    end
end

-- for delta = 0, 100, 1 do
--     for sn = -1, 1, 2 do
--         local nx = to_v(x + delta * sn, y)
--         if path_data.tiles[nx] then
--             return nx
--         end
--         local ny = to_v(x, y + delta * sn)
--         if path_data.tiles[ny] then
--             return ny
--         end
--     end
-- end





__gfx__
0000000000000000efffffff0000000000000000000000000bbbbbbb00ffffffffffffffffffff0000ffffffffffffffffffff00555555550000500000005505
0000000000000000efeeeeff000000000880880008808400003333300ffffffffffffffffffffff00ffffffffffffffffffffff0555555550000500000445550
0070070000888000deffffef000000308f88884080040040000050000f44444444444444444444f00f44444444444444444444f0555555550005050004f44551
0007700008881810effffffe00003b3b88888840800000400000500005ffffffffffffffffffff5005ffffffffffffffffffff50555455550000050044444411
0007700088188861df1ff11f003bb3bb8888844080000040000000000f44444444444444444444f00f44444444444444444444f0544554450000000044444440
00700700444444110d1ff17fb3333b3b088844000400040000000000054444444444444444444450054444444444444444444450555445550000000044444550
000000000d0d0d00001fffff0b3b3bb0004440000040400000000000054444555555555555444450054444444444444444444450555555550000000044445500
0000000000000000000dfff0000bb300000400000004000000000000054445444444444444544450054444444444444444444450555555550000000004555000
00bbbbbbbbbbbbbbbbbbbb005555555500888000000000000bbb3bbb054454555555555555454450054444444444444444444450000000000000300000000000
0bbbbbbbbbbbbbbbbbbbbbb0555555550888880000606000033355550544545555555555554544500544444444444444444444500000000000003b0000000000
bbbbb5555bbbbb55555bbbbb555555d506666880000600000055533005445455555555555545445005444444444444444444445000000000000b300050000005
bbb55333355bb53333355bbb55d55555066668800556558000035300054454555555555555454450054444444444444444444450000300000000340050000005
5b53333333355333333335b555d55555088888800855588000005000054454555555555555454450054444444444444444444450003530000004344055555551
0533333333333333333333505555555508888840088888400000000005445455555555555545445005444444444444444444445000553500044f445005555510
05333333333333333333335055555d55088884000888840000000000054454555555555555454450054444444444444444444450003553000444455000111100
05333333555333553333335055555555088044000880440000000000054454555555555555454450054444444444444444444450000350000055550000051000
0533335555555555553333505555d5555533335b000efffe0bbb3bbb0544545555555555554544500ffffffffffffffffffffff0000530000bbbbbbb00000000
053333555555555555333350555555555533333500efffef0bbb5555054454555555555555454450ffffffffffffffffffffffff003553000033333000000000
0533335555555555553333505d555555555333330efffeff03335333054445444444444444544450f4444444444444444444444f00535500000050005777c7c5
053333355555555553333350555555d555533333eefffeff055553330544445555555555554444505ffffffffffffffffffffff500035300000050005cccccc5
0533333555555555533333505555555555533333eefffeff00335550054444444444444444444450f4444444444444444444444f000030000033500055555551
0533333555555555533333505555555555553333eefffeff00055300054444444444444444444450544444444444444444444445000000000003533005555510
05333355555555555533335055d5555555555533deefffef00005000005544444444444444445500544444444444444444444445000000000000530000111100
05333355555555555533335055555555555555550ddeeede00000000000055555555555555550000055555555555555555555550000000000000500000051000
05333355555555555533335000000000efffffff0deee0000000000055555555555555555545445ff5445455555555550ffffff000000000000cc00000000000
05333335553335555333335000000000efeeeeffdeeeee00000000005555555555555555554544455444545555555555ffffffff00000000000cc00000444000
05333333333333333333335000000000deffffefdeffffe00066600044445555555544445545444ff444545555555555f444444f0000000000c7cc0004f44400
05333333333333333333335000000000effffffeeffffffe0677666055544555555445555545444444445455555555555ffffff50000000000c7cc0044444440
00533333333333333333350000000000efffffffefffffff676666664445445555445444554544444444545555544445f444444f000500000cccccd044444450
00533333333333333333350000b00000efeeeeffefeeeeff6666666d444454555545444455445444444544555444455554444445000505000cccccd044444550
000533333335553333335000000b00b0deffffefdeffffef6666dddd444454555545444455544555555445555555555554444445000050000ccccdd044445500
000055555550005555550000000b0b00effffffeeffffffe0dddddd05444545555454445555544444444555555555555055555500000500000cddd0004555000
0000000000000000000000005000000055555555fffefffefffefff0bb535445555555556666dddd02d7d7d00000000000000000000000000000000000000000
0dd6d666ddd00006000088885888000055555555ffefffefffef71ff35335445555555556666dddd027d7d7d0000000000000000000000000000000000000000
dddddddddd1d0660008888455488880053335555fefffefffeff11ff33355445555355556666dddd02d7d7d70088800000000000000000000000000000000000
dddddddddddddd000888f8844888888055355555fefffefffeffffff55554445553344556666dddd027d7d700888181000000000000000000000000000000000
1ddddddddddd0000088f88888888888055555555fefffefffefffffd4444445555544555dddd6666020000008818886100000000000000000000000000000000
011d11d11d110000888888888888888455553335fefffefffeff11104444455555555555dddd6666020000004444441100000000000000000000000000000000
0100d00d00d00000888888888888888455555355ffefffefffeffd005555555555555555dddd6666020000000d0d0d0000000000000000000000000000000000
1001d01d00d00000888888888888884455555555eedeeedeeeded0005555555555555555dddd6666222000000000000000000000000000000000000000000000
0dd6d666ddd00006888888888888884400b0bbbbbbb0bbbbbbbb0b00544535bb5000000000000000000000000000000500000000055000000000000000000000
dddddddddd1d066088888888888888440b3b3333333b33333333b3b0544533535888000008000080000000555500005500000555533500555500000000000050
dddddddddddddd000888888888888440053333333333333333333350544553335488880000800800005555335000053350000533300350053555550500000550
1ddddddddddd00000888888888884440053335555553355555533350544455554888888000088000005333000000053035000530000350000353500550000350
011d11d11d1100000888888888444440005354444445544444453500554444448888888000088000005300000000530035000530000350000350000530000350
010d10d10d0000000088888444444400053344444444444444443350555444448888888400800800005300550000530003500530033350000350000530005350
010d10d10d0000000044444444444400053544455544445554445350555555558888888408000080005555550000533003500533355500000330000533553350
010d10d10d0000000004444554444000053354455555555554453350555555558888882200000000005555000005355533500535553300000330000535500350
0000000000000000000100000000100005354455555555555544535055555555888882ff00000000005300000005300055350530005500000530000530000350
0dd6d666ddd0000600010000010010000535445555555555554453505555555588882ff000000000005300335005500000350550000550000530000530000350
dddddddddd1d066010010000010010000533544555555555544533505554444488882ff000000000005333555505500000550550000550000530000530000550
dddddddddddddd0010010000010010000053544555555555544535005544444488882ff000000000005555000005000000550550000050000550000550000050
1ddddddddddd000001001011001001000533544555555555544533505444555588442f0000000000000000000000000000050500000000000050000500000000
011d11d11d11000000100111001000110535544555555555544553505445553344442f0000000000000000000000000000000000000000000000000000000000
01d01d01d000000000011118000111110533544555555555544533505444533344442f000000000000000f88800000f88800000f8880000f20000000f8888000
00d00d00d000000000000118000001180533544555555555544533505444533554444200000000000000f82288000f82288000f8228800082000000f88222200
00000000000000000001111800011118053355455555555554553350555555550777770000000000000882008820082008820082008820082000000882000000
00060000000000000010011100101118053335445544444544533350555555556117116000000000000820000820082000820082000820082000000820000000
00066000006600000100101100100111005335444444444444533500444445556117116000000000000820000820082008820082008820082000000888880000
001a6aa000166aa01001000101001011053355444455555444553350444444556dd7dd6000000000000888888820088888200088888200082000000882220000
1a1a1a1a1a1a1a1a1001008101001011053335555553335555533350555544456777776000000000000882222820088222000088222000082000000820000000
0a1a1aaa0a1a1aaa0001001101001081053333353333333353333350335554450666660000000000000820000820082000000082000000088200000888000000
001a1aa0001a1aa00001000100001011005533333333555333335500333544450000000000000000000820000820082000000082000000028888200288888200
00000000000000000000000000001001000055555555000555550000533544450d666d0000000000000020000200002000000002000000002222000022222000
93808080808080a3819100000000007181938080a3819100d30000000000d1005666000000477756565656565656565656565656565656565656565656565656
565656565656565656565656565656563010f2911547200000000000000000005666000000000000000000000000000000000000000000000000000000004655
81818181b38181818191000000d100718181818181b3938080900000007080805666000000004644565656565676575757575777565656565656565684565656
565656565656565656565656565656561020b000c7fb300000000000000000005666000000000000000000000000000000000000000000000000000000004656
838282828282828282920000007080a38181818181818181d0910000007282734466000000004656565656565666000000000046565644565656565656565656
56565656445656565656565656845656103000d0fac810c000000000000000005666000000000000000000000000000000000000000000000000000000004656
91e000d20000e000d2000000007181818181b3818181838282920000000000715666000000004656565656845666000000000047575757575757575757775656
565656565656565656565656565656561040f0a0182b200000000000000000005666000000000000000000000000000000000000000000000000000000004656
910000000000000000000000007181d081818181818392e000000000000000717667000000004656565656565666000000000000000000000000000000465656
56565656565656565644565656565656201070f34814400000000000000000005666000000000000000000000000000000000000000000000000000000004656
91000000000000000000000000718181818181818392000000006000000000716600000000457456564456565666000000070007000700000000000000465644
565656565656565656565656565656562040f03118f6200000000000000000005666000000000000000000000000000000000000000000000000000000004656
910000000000d30014d10000007181818181818191e0000000000000000000716600000000475757575757575767000000000000000000000000000000465656
5656565656765757575757575777845620600041fc6710c000000000000000005666000000000000000000000000000000000000000000000000000000004656
9100000070808080808090000071818181b3818191000000000000000000d3716600000000000000000000000000000045556500000000000000000000465656
56565684566600000000000000477756209070014ef7300000000000000000005666000000000000000000000000000000000000000000000000000000004656
91000700718181d08181910000718181818181819100000000000000007080a36600000000000000000000000000000046566600000000000000000000475757
57575757576700000000000000004656401001c3f7e4100000000000000000005666000000000000000000000000000000000000000000000000000000004656
9100000072828282828292000071b381818181819100000000000000007181817565000000000000002600000000000046567555555555556500000000000000
00000000e2000000000000000000465640200120f719100000000000000000005666000000000000000000000000000000000000000000000000000000004656
91000000000000d20000e00000727381818181b391000000000000000072827356660000000000c3000000000000000046845656565656566600000000070000
00000000e200000000000000000046564050f1f11b3720c000000000000000005666000000000000000000000000000000000000000000000000000000004656
9390000000000000000000000000718181818181910000600000000000d2007144660000001400c3000000000000000046565656565644566600000000000000
00000000e2000000000000000000465650400521f4d8100000000000000000005666000000000000000000000000000000000000000000000000000000004656
8191d10000d30000000000000000718181d0818191d1000000000000000000715675555555555555555555650000000046565656565656566600000000001400
00456500e200000000000000000046446020f4a013a8200000000000000000005666000000000000000000000000000000000000000000000000000000004656
81938080808090000000000000007181818181819390000000000000000000715656565656565656845656755555555574565656565656567555555555555555
55746600e2000000000000000000465660700320f989100000000000000000005666000000000000000000000000000000000000000000000000000000004656
b381818181819100000000000070a38181818181819100d300000000000000715656565644565656565656565656565656565644565656565656565656565684
56566600e200000000004555555574567060f4a1168620c000000000000000005666000000000000000000000000000000000000000000000000000000004656
818181818181910000001700007181818181b3818193809000000000000000715656565656565656565656565644565656565656565656565656445656565656
56566600e20045555555745644565656708053f1e9164000000000000000000056660000000000000000000000d3000000000000000000000000000000004656
81818181d08191000000000000718181818181818181819100000000000000715656565656565656565656565656765757575757575777565656565656565656
565656565656565676670000004777568070350026f9300000000000000000005666000000000000000000004555556500000000000000000000000000004656
81b381818181910000000000007181b3838282828282829200000060000000715656565656565684565656565656660000000000000046565684565656565656
565684565656565666000000000046569020b6f0c118400000000000000000005666000000000000000000004656567555650000000000000000000000004656
8181818181b3910000000000007282739100e00000e0000000000000000000715656565656565656765757575757670000000000000047577756565656565656
5656565656565656660000000000465690a0a700a4fa3000000000000000000076670000000000d1000000004656765757670000000000000000000000004656
81818181818191000000000000e00071910000000000000000000000000000715644565656565656660000000000000000000000000000004656565656564456
56565656565644566600000000004656a09044f26b154000000000000000000066d20000004555556500000046566600d20000000000d3000000000000004656
81818181818191000060000000000071910000000000000000d1000000d300715656567657575757670000000000000000000000000000004656565656565656
56565656565656566600606060004656a0b0320228f93000000000000000000066000000004656566600000047576700000000000045555565d1000000004656
81d08181818191000000000000000071939000000000007080808080808080a35656566600000000000000000000000000455555556500004656565656567657
57575757575757576700000000004656b0a052f3e71640000000000000000000660000004574765767000000e000000000000045557456567555650000004656
83828282828292000000000000000071819100000700007181818181b38181815656446600000000000000000000000000465656566600004656445656566600
00000000000000000000000000004656b0c0b403cae8300000000000000000006600000047576700000000000000000000000046565676775676670000004656
910000d20000e000000000a0b0c00071839200000000007273818181818181817657576700000000000000455565000000465684566600004777565656566600
00000000000000000000000000004656000000000000000000000000000000006600000000d20000000000d3000000d100000046567667475767000000004656
9100000000000000000000a1b1c1007191e00000000000d27181d081818181816600000000000000000000477766002600465656566600000047575757576700
00000000140000c300000014000046560000000000000000828282828282828266d100000000000000004555555555650000004757670000d200000000d34656
91000000d300d10000d314a1b1c1d1719100000000000000718181818181d0816600000000000000000000457466000000477776576700000000000700000000
00455555555555555555555555557456000000000000000000000000000000007565000000000000000046565656566600000000e00000000000000045557456
910000708080808080808080808080a3920000000000000071818181818181816600000000000000000000465666000000457475556500000000000700000000
00465656445656565656565656845656000000000000000000000000000700005666243400000000000047575757576700000000000000000000000046565656
9100007282828282827381818181818100000000600000007181b381818181816600000000000000000000475767006000465656567565000000000700000000
004656565656565656565656565656560000000000000000000010000000000056662535000000000000000000e0000000000000000000000000d30046565656
91000000e00000d20071b3818181818100000000000000007181818181b381816600000000000000000000000000000000465656565675555555555555555555
55745656565656565656564456565656000000000000000000000000007080805675555555555565000000000000000000640000000000000045555574565656
9100000000000000007181818181d08100d1000000d3000071818181818181566600000000000000000000000000000000465644565656565656565684565656
5656565656565656845656565656565600000000000000000004140000718181565656565656566600d100000000d30000000000d10000000046565656565656
91d300d10000000000718181818181818080808080808080a38181b3818181817555650000000000455555650000000000465656565656565656565656565644
5656565656565656565656565656445600000000000000008080808080a3818156565656565656755555555555555555555555555565a0b0c046565656565656
93808080809000000071818181b381818181b3818181818181818181818181815656756500000045744456755555555555745656565656445656565656565656
565656564456565656565656565656560000000000000000818181818181818156565656565656565656565656565656565656565666a1b1c146565656565656
__label__
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000050000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000055550000550000055553350055550000000000005000000000000000000000000000000000000000000000000000008880000000000000000
00000000000555533500005335000053330035005355555050000055000000000000000000000000000000000000000000000000008888888800000000000000
00000000000533300000005303500053000035000035350055000035000000000000000000000000000000000000000000000000888118888811000000000000
00000000000530000000053003500053000035000035000053000035000000000000000000000666000000000000000000000008881118118877100000000000
00000000000530055000053000350053003335000035000053000535000000000000000000000666600000000000000000000088881188111817100000000000
00000000000555555000053300350053335550000033000053355335000000000000000000001166600000000000000000000081188888811811100000000000
00000000000555500000535553350053550035000033000053550035000000000000000100aa11a661a000000000000000000088118888888811100000000000
0000000000053000000053000553505300005500005300005300003500000000000000011aaa11a661aaa0000000000000000088888884444400000000000000
0000000000053003350055000003505500005500005300005300003500000000000000001aa111aa11aaaa00000000000000004444444dd11ddd000000000000
0000000000053335555055000005505500005500005300005300005500000000000000000aa11aaa11aa1aa000000000000000010d01100d0000000000000000
0000000000055550000050000005505500000500005500005500000500000000000000000aa11aa111a11aa0000000000000000100d001000000000000000000
00000000000000000000000000005050000000000005000050000000000000000000000000a11aa11aaaaaa00000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000011aa11aaaaaa00000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000001a11aaaaa000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000011aaa0000000000000000000000000000000000000000000
00000000000000f88800002f88800002f8880000f20000000f888800000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000f82288000f82288000f8228800082000000f8822220000000000000000000000000000000000000000000000000000000000000000000000000
00000000000088200882008200882008200882008200000088200000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000082000082008200082008200082008200000082000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000082000082008200882008200882008200000088888000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000088888882008888820008888820008200000088222000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000088222282008822200008822200008200000082000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000082000082008200000008200000008820000088800000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000082000082008200000008200000008888820088888820000000000000000000000000000000000000000000000000000000000000000000000000
00000000000022000022002200000002200000000222220002222200000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffffffffffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffffffffffffffffffffffffffffffffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000000000000004fff444444444444444444444444444444444444444444
00000000000000000000000000000000000000000000000000000000000000000000000000000000004f44444444444444444444444444444444444444444444
00000000000000000000000000000000000000000000000000000000000000000000000000000000004544ffffffffffffffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000000000000000000000000000000000000045ffffffffffffffffffffffffffffffffffffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000000000000004fff444444444444444444444444444444444444444444
00000000000000000000000000000000000000000000000000000000000000000000000000000000005f44444444444444444444444444444444444444444444
00000000000000000000000000000000000000000000000000000000000000000000000000000000005544444444444444444444444444444444444444444444
00000000000000000000000000000000000000000000000000000000000000000000000000000000004544444444444444444444444444444444444444444444
00000000000000000000000000000000000000000000000000000000000000000000000000000000004544444444455555555555555555555555555555555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000005544444445555555555555555555555555555555555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000005544444455554444444444444444444444444444444444
00000000000000000000000000000000000000000000000000000000000000000000000000000000005544444555444444444444444444444444444444444444
00000000000000000000000000000000000000000000000000000000000000000000000000000000005544444554444455555555555555555555555555555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000005544445554445555555555555555555555555555555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000005544445544455555555555555555555555555555555555
00000000000000000000000000000000000000000000000000600000000000000000000000000000005544445544455555555555555555555555555555555555
00000000000000000000dd6d6666d666666ddd000000000006d00000000000000000000000000000005544445544555555555555555555555555555555555555
000000000000000000dddddddddddddddddddddd000000006d100000000000000000000000000000005544445544555555555555555555555555555555555555
00000000000000000dddddddddddddddddddd11ddd00d666d1000000000000000000000000000000005544445544555555555555555555555555555555555555
00000000000000000ddddddddddddddddddddd11dd66dddd10000000000000000000000000000000005544445544555555555555555555555555555555555555
00000000000000000ddddddddddddddddddddddddddddd1100000000000000000000000000000000005544445544555555555555555555555555555555555555
00000000000000000dddddddddddddddddddddddddd1110000000000000000000000000000000000005544445544555555555555555555555555555555555555
000000000000000000ddddddddddddddddddddddddd0000000000000000000000000000000000000005544445544555555555555555555555555555555555555
0000000000000000000ddddddddddddddddddddddd00000000000000000000000000000000000000005544445544555555555555555555555555555555555555
0000000000000000000000ddd1111ddd1111ddd00000000000000000000000000000000000000000005544445544555555555555555555555555555555555555
00000000000000000000011ddd0011ddd0011ddd0000000000000000000000000000000000000000005544445544555555555555555555555555555555555555
000000000000000000001110ddd1110ddd1110ddd000000000000000000000000000000000000000005544445544555555555555555555555555555555555555
0000000000000000000011000dd11000dd11000dd000000000000000000000000000000000000000005544445544555555555555555555555555555555555555
0000000000000000000011000dd11000dd11000dd000000000000000000000000000000000000000055444445544555555555555555555555555555555555555
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff55444445544555555555555555555555555555555555555
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff55444445544555555555555555555555555555555555555
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff55f444445544555555555555555555555555555555555555
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff45ff444445544555555555555555555555555555555555555
44444444444444444444444444444444444444444444444444444444444444444444444444444444ff4444445544555555555555555555555555555555555555
444444444444444444444444444444444444444444444444444444444444444444444444444444ffff4444445544555555555555555555555555555555555555
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff44444445544555555555555555555555555555555555555
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff4444444445544555555555555555555555555555555555555
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444455544555555555555555555555555555555555555
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444455444555555555555555555555555555555555555
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444555444555555555555555555555555555555555555
44444444444444444444444444444444444444444444444444444444444444444444444444444444444455554445555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555544445555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555554444455555555555555555555555555555555555555
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444555555555555555555555555555555555555555
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444455555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555

__gff__
0000000000000815151572727210101011111110101008151415707070101010111111101000081515151515151012101111111000000014141414141510101008081010100000511411100000000000080810107575755110010000000000000808080875547550100000000000000008080808757575500000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3b181818183828282829000000272837282828282828282828282828282837185959595959595917181818181818181875757575757575757575760000000000000000000000002728371818183b181838290000001718181818181818181818183b1818181818180d1818181818181818181818181818181900000017181818
1818183b181900002d00000000000017002d0000000e000000000e0000002737590000000000001718181818181818180000000e00000000000000000000000000000000000000000e2728282828371819000000001718181818183b1818181818181818181818181818181818181818181818183b1818181900000017183b18
18183828282900000000000a0b0c00170000000000007000000000000000001759000000000000171818181818181818000000000000000000000000000000000000000000000000000000002d00171819000000001718382828282828282837181818180d1818181818181818180d1818181818183828282900000027371818
181819000e0000000000001a1b1c001700003d0000001d00000000000000001759000000000000171818181818181818003d000000001d0000000000000000000000000000000000000000000000170d1900003d00173b19002d00002d000017181818181818183b1818181818382828282828282829000e0000000000171818
0d181900000000000000001a1b1c1d170808080808080808090000000000001759000000000000171818181818181818555555555555555555560000000000000000000000000000000000000000273719000708083a181900000000000000171818183b1818181838282828282900002d00000e000000000000000000171818
1818190000000000000007080808083a18181818181818181900000000000017590000000000002737181818181818181818181818181844186600000000000000000000000000000000000000000e171900272828371819003f000000000017181818181818181819000e00002d000000000000000000000000000000171818
18181900000000000000272828282837183b1818181818181900000000000017590000000000000017181818181818184418181818481818186600000000000070000000000000000000000000000017190000712d17183908080900000000171838282828282828290000000000000000000000000000000000000000171818
183b1900001d000000000e00002d00171818181818180d181900000000000017590000000000000017181818181818181818184418181818486600000000000000000000000000000a0b0b0c000000171900000000171818180d1900000000170d192d000e00002d000000000000000000000000710000000000000000173b18
1818390808080900000000000000002718181818181818181900000000000017590000007070700017181818181818187575757575757575757600000000000000000000000000001a1b1b1c00000027190000000027282828282900000000171819000000000000000000000000000000000000000000000000000000171818
3828282828282900000000000000000e1818183b1818181819001d000000001759000070700000001718181818181818080900002d0000002d0000000000000000000000000000001a1b1b1c0000000039090000000000000e0000000a0c00171819000000000000000000000000000000000000000000000000000000171818
192d000e00002d00000a0b0b0c00000018181818181818183908080900000017590000707070700027282828282837181819000000000000000000000000000000000000000000001a1b1b1c000000001819000000000000000000001a1c00171819000000000000000000000000000000000000000000000000000000171818
2900000000000000001a1b1b1c000000183b1818181818181818181900000017590000007070700000000000000017181819000000001d00003d000000000000000000000000001d1a1b1b1c3d00001d181900000000000000001d411a1c3d171819001d07091d000000000000000000001d00003d411d000000000000171818
00000000000000001d1a1b1b1c1d41071818181818181818183b18190000001759000000700070000000000000001718181900000007080808080808091d0000001d00003d000007080808080808080818191d0000000000070808080808083a181900073a39090000000000000000000708080808080809000000000017180d
0000000000000007080808080808083a18180d18181818181818181900000017590000000000000000000014000017181839093d00170d181818181839080808080808080808091718183b18181818181839080809003d001718181818183b1818191d27282829001d000000000000001718181818183b19001d1e1d00171818
003d00001d0000171818181818180d183828282828282828282828290000001759000000000000000000000000001718183b3908092728282828283718183b1818181818180d19170d18181818183b1818183b18390808083a183b1818181818183908080808080808090000000708083a18183b1818183908080808083a1818
080808080808083a18183b181818181819000e0000000e00002d00000000001759000000000000000000000000001718181818183908080809000027282828282828282828282917181818181818181818181818181818181818181818181818181818180d181818181900000017181818181818181818181818181818181818
181818181819000000171818183b1818190000000000000000000000000006175900000000003d000000000000073a1818197475757575757575757575757577656567757575757577656565486565652828282828282828371818181900000000646565677576000000173b1818181859595959595959595959595959595959
181838282829000000272828282828281900000000000000000000000000001759000000002a2b2b2b2b2b2b2b0d18181819000000000000000000000000007477677600002d0000747575757575776500002d00000e000017180d181900000000747575762d0000000017181818181859000000000000000000000000000059
2828292d00000000000000002d00002d19000000000000000000000000000017111200000000000000000e0000171818181900000000000000001d000000000064660000000000000000000000007477000000000000000027282828290000000000000000000000000017181818183b49000000000000000000000000000059
000000000000000006000000000000001900000000003d0041001d00000000172122000000007000000070000017181818390900000000000708080900000000646600000000000000000000000000643d00000000000000002d000e00000000000000000000000000002728370d181849000000000000000000000000000059
0000000000000000000000000000000019000000070808080808080900000017212200000000001d00003d0000171818183829000000000027370d190000000064660000000000000000000000000064080808090000000000000000000000000000000000000000000007083a18181849000000000000000000000000000059
001d00000000000000000000002a2b2b19000000272828282828282900000017212233000000070808080808083a0d1818190e0000000000001718190000000064660000000000000000000000000064183b181900000000000000000000000000000000000000000000173b1838371849000000000000000000000000000059
0808080809000000000000000000001719007000002d0000000e000000000017212411120000272828282828283718181819000000060000001718190000000674760000000000003d004100000000641818181900000000000000000000000000000000000000000000171818393a1849000000000000000000000000000059
18183b18190000002a2b2b2b2c0000171900000000000000000000000000001721232122000000000e0000002d272828181900000000000000173b19000000000071000000005455555555560000006418181819001d000000000000000000000000000000000000000017180d181818490000000000000000000000004a0059
3828282829000000000000000000001719000600000000000000000000000017212121220000000000000000000000003b190000006200000017181900000000000000000000646565656566000000741818183908080808090000000000000000000000000000000000171818183b1849000000000000000000000049494949
1900002d0000000000000000000000171900000000003d0000003d000000001721212122000000000000000000000000181900000000000000272829000000000000000000006465654865660000000018180d18183b181819003d00000000000000000000000000000027371818181849000000000000000000000049494949
1900000071000000000000000000001719001d0007080808080809000000073a2121212200000000000000000000000018190000000000000007080900001d00004100000000646565656566000000003718181818181818390808090000000000000000000000000000073a1818181849000000000000000000000049494949
19000000000000000000000000000017390808083a181838282829000000273721211322000000000000000007080808181900001d000000001718195455555555555555555547656565656600003d001718181818181818181818191d0000000000000000000000000017183b18181849000000000000000000000049494949
19000a0b0b0c000000000000000000170d18181818183829002d000000000017212121220033000000003300171818180d1900002a2b2c00001718196465446565656565654865656565655755555555272837181818183b18181839080809000000000000000000000017382837181849000000000000000000000049494949
19001a1b1b1c00003d0000000000001718181818183b1900000000000000002721212124111111111111111217183b1818190000002d000000171819646565656565656565656565654465656565656500002728283718181818181818181900003d00001d00003d000017193c170d1849000000000049494949494949494949
19001a1b1b1c000708090000000000171838282837181900000000060000000023212121212121212121212217181818181900000000000000173b1964656565654465656565656565656565656544650000000000272837181818180d183908080808080808080808091739083a181849000000000049494949494949494949
19001a1b1b1c00170d1900000000001718191d2d171819000000000000000000212121212123212121212122171818181839080900000007083a18196465654865656565656565656565654865656565000000000000002728283718181818181818180d18181818181917181818181849494949494949494949494949494949
__sfx__
0113000017152171521715221152201521f1521a1521d1521f15218152181522615221152201521f1521d1521a1521d1521f1521a1521a1522615221152201521a1521f1521d1521a1521d1521f152181521c152
012800001c6431c6431c6431c6431c6431c6431c6431c643216432164321643216432164321643216432164323643236432364323643236432364323643236431d6431d6431d6431d6431d6431d6431d6431d643
011400001504015040150401504010040100401004010040110401104011040110401304013040130401304015040150401504015040100401004010040100401104011040110401104013040130401304013040
011400001103011030110301103010030100301003010030130301303013030130301503015030150301503011030110301103011030100301003010030100301703017030170301703015030150301503015030
011400001a3451a3051d3451d3051f3451f3051f3051f3051a3451a3051c3451c3051d3451d3051d3051d3051a3451a3051d3451d3051f3451f3051d3451c3451a3451a3051c3451c3051d3451d3051c34518345
001400000215102151021510215102151021510215102151021510215102151021510215102151021510210105151051510515105151051510515105151051510515105151051510515105151051510515105101
001400000015100151001510015100151001510015100151001510015100151001510015100151001510010104151041510415104151041510415104151041510415104151041510415104151041510415104101
01140000280252d025280252d025280252d025280252d0252402529025240252902524025290252402529025280252d025280252d025280252d025280252d0252402529025240252902524025290252402529025
010600000213002130001000010002130021300010000100021300213000100001000213002130001000010003130031300010000100031300313000100001000313003130001000010003130031300010000100
010600000513005130001000010005130051300010000100051300513000100001000513005130001000010007130071300010000100071300713000100001000713007130001000010007130071300010000100
010600002d620006000060000600006000060000600006001b6201b6200f6300f630006000060000600006002d620006000060000600006000060000600006001b6201b6200f6300f63000600006000060000600
01060000294202942000400004002b4202b42000400004002742027420264202642000400004002742027420294202942000400004002b4202b42000400004002942029420274202742000400004000040000400
010600002942029420264202642029420294202b4202b42027420274202642026420294202942027420274202942029420274202742029420294202b4202b4202942029420274202742026420264202942029420
0106000029420294202642026420294202942027420274202b4202b4202b4202b4202b4202b4202b4202b42027420274202b4202b42029420294202b4202b4202d4202d4202d4202d4202d4202d4202d4202d420
010600000e0200e0200e0200e0200e0200e0200e0200e0200e0200e0200e0200e0200e0200e0200e0200e0200c0200c0200c0200c0200c0200c0200c0200c0200c0200c0200c0200c0200c0200c0200c0200c020
01060000110201102011020110201102011020110201102011020110201102011020110201102011020110200f0200f0200f0200f0200f0200f0200f0200f0200f0200f0200f0200f0200f0200f0200f0200f020
010600001b7301b7301b7301b730187301873018730187301a7301a7301a7301a7301b7301b7301b7301b7301d7301d7301d7301d7301a7301a7301a7301a7301b7301b7301b7301b7301d7301d7301d7301d730
010600001f7301f7301f7301f7301b7301b7301b7301b7301d7301d7301d7301d7301f7301f7301f7301f730217302173021730217301d7301d7301d7301d7301f7301f7301f7301f73021730217302173021730
010600001f7301f7301a7301a7301b7301b7301d7301d7301f7301f7301a7301a7301b7301b7301d7301d73021730217301b7301b7301d7301d7301f7301f73021730217301d7301d7301f7301f7302173021730
010600002d6200060000600006002d6300000000600006002d6200060000600006002d6300060000600006002d6200060000600006002d6300060000600006002d6300060000600006002d630006000060000600
010600002d6200060000600006002d6300000000600006002d6200060000600006002d63000600006000060027620276302763027630000000000000000000002763027630276302763000000000000000000000
000100001f6301f6301e6301d6301d6301d6301f6201e6201c6201a620196201762014620126100f6100d6100a6100661003610006000a6000a600086000560003600026000060000600006000a6000860006600
000100000e7600d760107601276016760187601a7601e760207602276024760257602676027760277602776027760007000070000700007000070000700007000070000700007000070000700007000070000700
000100000e7600d760107601276016760187601a7601e760207602176020760207601c7601b760147601376011760117600070000700007000070000700007000070000700007000070000700007000070000700
0001000016470184701b4701f4702247024470274702847026470254701f4701d4701b470174701646015460124600f4600d4600c4600b4500a4500a450084500040000400004000040000400004000040000400
000100001075011750137501475016760197601c760207602376025760287602b7602e760307603276034760367603070036700297002b7002e70030700317000070001700017000170001700017000070000700
000200000d5601056015560175601b5601e560205602356025560295602a56014560195601c5601f56022560275602b5602f5603356033560155601b5601f56024560285602c5603056033560375603a5603d560
00030000267502575023750217501e7501a75017750137500d7502775025750227501f7501c7501875015750117502475023750207501b7501775012750107500b750207501d7501975017750147500d75008750
011000002454224542265422654229542295422b5422b5422b5422b5422954200502295422954200502005022b5422b5422954229542285422854226542265422654226542285420050228542285420050200502
01100000265422654228542285422b5422b542295422954229542295422b542000002b542000002b542000002d5422d5422954229542285422854229542295422854228542245422454226542265422354223542
0110000018020180201802018020180201802018020180201c0201c0201c0201c0201c0201c0201c0201c0201a0201a0201a0201a0201a0201a0201a0201a0201d0201d0201d0201d0201d0201d0201d0201d020
0110000018020180201802018020180201802018020180201c0201c0201c0201c0201c0201c0201c0201c0201a0201a0201a0201a0201a0201a0201a0201a0201d0201d0201d0201d0201c0201c0201802018020
011000000c740007000c740007000c740007000c7400070013740007001374000700137400070013740007000e740007000e740007000e740007000e740007001574000700157400070015740007001574000700
011000001075000000107500000013750000001375000000177500000017750000001375013750137500000015750000001575000000117500000011750000001a750000001a7500000017750000001775000000
011000001075000000107500000013750000001375017750000000000017750000001375013750137500000015750000001575000000117500e750117500e7501a750000001a7500000017750137501775013750
011000001c0101c0101c0101c0101c0101c0101c0101c0101f0101f0101f0101f0101f0101f0101f0101f01023010230102301023010230102301023010230101f0101f0101f0101f0101f0101f0101f0101f010
01100000245422454229542295422b5422b5422954228542265422654229542295422854228542285422854226542265422854228542295422b5422d5422d5422b5422b542285422854229542295422854228542
0110000024542245422654226542285422854229542295422454224542295422954228542285422854228542265422654229542295422b5422b5422d5422d5422b5422954228542265422b542295422854226542
__music__
01 1c1e4344
00 1d1f4344
00 1c1e4344
00 1d1f4344
00 241e2044
00 251f2044
00 241e2044
00 251f2044
00 1c1e2044
00 1d1f2044
00 1c1e2044
00 1d1f2044
00 21234344
00 22234344
00 21234344
02 22234344
01 02040544
00 03040644
00 02040544
00 03040644
00 02074344
00 03074344
00 02070544
00 03070644
00 02040544
00 03040644
00 02040544
00 03040644
00 02070504
00 03070604
00 02070504
02 03070504
00 41424344
00 41424344
00 41424344
00 41424344
00 084a4344
00 094a4344
00 080a4344
00 090a4344
01 080a0b44
00 090a0c44
00 080a0b44
00 090a0d44
00 080a0b44
00 090a0c44
00 080a0b44
00 090a0d44
00 080e0b0a
00 090f0c0a
00 080e0b0a
00 090f0d0a
00 080e0b0a
00 090f0c0a
00 080e0b0a
00 090f0d0a
00 0e104344
00 0f114344
00 0e104344
00 0f124344
00 0e101344
00 0f111444
00 0e101344
02 0f121444

