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
