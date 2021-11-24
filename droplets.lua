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