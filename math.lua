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
