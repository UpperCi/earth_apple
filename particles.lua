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
