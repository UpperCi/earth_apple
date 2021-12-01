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