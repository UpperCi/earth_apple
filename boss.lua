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
