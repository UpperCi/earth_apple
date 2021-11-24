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
