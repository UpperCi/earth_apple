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
            15, 28,
            1, 28
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
        draw_debug()
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
        print(tick / 30, 4, 4, 1)
    end
end
