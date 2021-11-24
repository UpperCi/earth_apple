tt = {
    text = "", line = 7, timer = 0, scroll_time = 14, hold_time = 90, active = false
}

function show_tt(text)
    tt.text = text
    tt.active = true
    tt.timer = 0
end

function update_tt()
    if tt.active then
        tt.timer += 1
    end
end

function draw_tt()
    if tt.active then
        y = 121
        if tt.timer < tt.scroll_time then
            y = 128 - tt.timer / tt.scroll_time * 7
        elseif tt.timer > tt.scroll_time + tt.hold_time * 2 then
            tt.active = false
            y = 128
        elseif tt.timer > tt.scroll_time + tt.hold_time then
            time = tt.timer - tt.scroll_time - tt.hold_time
            y = 121 + time / tt.scroll_time * 7
        end
        rectfill(0, y, 128, y + 7, 12)
        print(tt.text, 2, y + 1, 1)
    end
end