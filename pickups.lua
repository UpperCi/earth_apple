pickups = {}

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
            e:damage()
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
            self.y += 0.6
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
