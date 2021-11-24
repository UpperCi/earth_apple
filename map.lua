function draw_tiles()
	xt = ceil(s.x / 8) - 1
	yt = ceil(s.y / 8) - 1
	xoff = -s.x % 8 - 8
	yoff = -s.y % 8 - 8
	map(xt,yt,xoff,yoff,18,18,16)
end