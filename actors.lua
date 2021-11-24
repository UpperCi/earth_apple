function make_actor(x,y)
	return {
		x = x,
		y = y,
		dx = 0,
		dy = 0,
		w = 0.33,
		h = 0.2
	}
end

function move_actor_x(a)
	-- move along x if no solids
	if not solid_area(
		a.x+a.dx,a.y,a.w,a.h) then
		a.x += a.dx
	else
		ax = a.x
		if a.dx > 0 then
			if abs(a.dx) >= 0.5 then
				ax += 0.5
			end
			a.x = ceil(ax) - a.w - 0.05
		else
			if abs(a.dy) <= -0.5 then
				ax -= 0.5
			end
			a.x = flr(ax) + a.w + 0.05	
		end
		a.dx = 0
	end
end

function move_actor_y(a) -- 100 extra tokens
	if not (solid_area(
		a.x,a.y+a.dy,a.w,a.h) or
		oneway(a.x, a.y, a.h, a.dy)) then
		a.y+=a.dy
	else
		ay = a.y
		if a.dy > 0 then
			if abs(a.dy) >= 0.3 then
				ay += 0.3
			end
			a.y = ceil(ay) - a.h - 0.05
		else
			if abs(a.dy) <= -0.3 then
				ay -= 0.3
			end
			a.y = flr(ay) + a.h + 0.05
		end
		a.dy = 0
	end
end

function move_actor(a)
	move_actor_x(a)
	move_actor_y(a)
end