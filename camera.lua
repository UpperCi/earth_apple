s = {};
s.x = 3
s.y = 3
s.scrollx = 3
s.scrolly = 3
s.region = 3
s.xm = 48
s.ym = 48

function update_cam()
	px = player.x * 8 - s.x
	py = player.y * 8 - s.y
	
	xr = 128 - s.xm;
	yr = 128 - s.ym;

	rgn = regions[s.region]

	rx_start = rgn.x
	rx_end = rgn.x + rgn.w - 128
	ry_start = rgn.y
	ry_end = rgn.y + rgn.h - 128

	if px > xr then
		s.scrollx = player.x * 8 - xr
	elseif px < s.xm then
		s.scrollx = player.x * 8 - s.xm
	end

	if py > yr then
		s.scrolly = player.y * 8 - yr
	elseif py < s.ym then
		s.scrolly = player.y * 8 - s.ym
	end

	if s.scrollx < rx_start then
		s.scrollx = rx_start
	elseif s.scrollx > rx_end then
		s.scrollx = rx_end
	end
	if s.scrolly < ry_start then
		s.scrolly = ry_start
	elseif s.scrolly > ry_end then
		s.scrolly = ry_end
	end

	rel_x = player.x - rx_start / 8
	rel_y = player.y - ry_start / 8
	rel_w = rgn.w / 8
	rel_h = rgn.h / 8

	for i, r in pairs(rgn.exits) do
		local dir_x = 0
		local dir_y = 0
		if r.dir == "left" then
			dir_x = -1
		elseif r.dir == "right" then
			dir_x = 1
		elseif r.dir == "top" then
			dir_y = -1
		else
			dir_y = 1
		end

		local xdiff = r.x - (player.x - dir_x * 1.5 - 0.5)
		local ydiff = r.y - (player.y - dir_y * 1.5 - 0.5)

		if abs(xdiff) < 2 and abs(ydiff) < 2 then
			switch_region(r, dir_x * 1, dir_y * 1)
		end
	end

	for i, p in pairs(pickups) do
		p_rel_y = p.y - ry_start / 8
		if p_rel_y > rel_h - 0.5 then
			if rgn.bottom then
				p.x = rgn.bottom.x
				p.y = rgn.bottom.y
			end
		end
	end
	s.x = flr(s.scrollx)
	s.y = flr(s.scrolly)
end
