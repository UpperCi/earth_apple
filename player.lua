player = make_actor(0,0)

add_attributes(player, { 
	h=0.3,
	max_spd=0.4,
	max_fall=1,
	hold=0.1,
	buf=0,
	coy=0,
	fliph=false,
	jumptime=5,
	holding=false,
	held=0,
	last_jumpact=false,
	jumpact=false,
	just_jumpact=false,
	last_doact=false,
	doact=false,
	just_doact=false,
	hp = 5,
	maxHP = 5,
	inv_timer = 0,
	do_draw = true,
	doublejump = false
})


function player:damage()
	if self.inv_timer > 0 then return false end

	self.hp += (difficulty == 0) and 1 or -1

	for i = 0, 10, 1 do
		make_particle(self.x * 8 + self.w / 2, self.y * 8 + self.h / 2, rnd(6) + 5, rnd(4) - 2, rnd(4) - 2, 7)
	end

	if self.hp <= 0 then
		self.x = check_point_x
		self.y = check_point_y
		switch_region({region = check_point_rgn, dx = 0, dy = 0}, 0, 0)
		self:heal()
	end

	self.inv_timer = 45

	return true
end

function player:heal()
	if difficulty > 0 then
		self.hp = 5
		make_splash_particle(self.x * 8, self.y * 8, 20, 3, 11)
	end
end

function player:update_input()
	self.jumpact = btn(⬆️) or btn(🅾️)
	self.just_jumpact = btn(⬆️) or btn(🅾️)

	if self.last_jumpact then
		if self.jumpact then
			self.just_jumpact = false
		else
			self.last_jumpact = false
		end
	elseif self.jumpact then
		self.last_jumpact = true
	end

	self.doact = btn(⬇️) or btn(❎)
	self.just_doact = btn(⬇️) or btn(❎)

	if self.last_doact then
		if self.doact then
			self.just_doact = false
		else
			self.last_doact = false
		end
	elseif self.doact then
		self.last_doact = true
	end
end

function player:update_speed()
	-- amogus was here

	local _dx = self.dx

	if btn(➡️) then
		_dx += 0.15
		self.fliph = false

	elseif btn(⬅️) then
		_dx-= 0.15
		self.fliph=true
		
	else
		if abs(_dx)<0.1 then
			_dx=0
			
		elseif _dx>0 then
			_dx-=0.1
		
		elseif _dx<0 then
			_dx+=0.1
		end
	end

	if _dx> 0.4 then
		_dx= 0.4

	elseif _dx< - 0.4 then
		_dx= - 0.4
	end

	-- update gravity
	self.dy+=0.1
	self.dy = min(self.dy, self.max_fall)

	self.dx = _dx
end

function player:update_jump()
	if self.just_jumpact then
		self.buf=4
	
	elseif self.buf>0 then
		self.buf-=1
	end

	local _x = self.x
	local _y = self.y
	local _dy = self.dy
	
	local grounded = ((solid(_x - 0.33, _y + 0.5, true) or (solid(_x + 0.33, _y + 0.5, true)) or oneway(_x, _y, self.h, _dy))) and _dy > 0
	
	if grounded then
		self.coy=3
		self.doublejump = true
	elseif self.coy>0 then
	 	self.coy-=1
	end
	
	validjump=self.coy>0 and self.buf>0
	validdouble=not validjump and self.doublejump and self.just_jumpact
	validhold=self.jumptime>0 and self.jumpact
	
	if validjump then
		_dy=-0.475
		self.coy=0
		self.jumptime = 6
	elseif validdouble then
		_dy = -0.5
		self.dx /= 1.5
		self.doublejump = false
		self.jumptime = 4
	elseif validhold then
		_dy-=self.hold
	end
	
	if self.jumptime>0 then
		self.jumptime-=1
	end
	-- update pos

	if _dy > 0.2 then
		if solid(_x, _y + _dy * 1.2, true) or oneway(_x, _y, self.h, _dy * 1.2) then
			xoff = rnd(4 + _dy) - (2 + _dy / 2)
			make_splash_particle(_x * 8 + xoff, _y * 8 + 4, 5, 1.5, 7)
		end
	end

	self.dy = _dy
end

function player:update()
	self:update_speed()
	self:update_input()
	self:update_jump()

	move_actor(self)
	
	self.do_draw = true

	if self.inv_timer > 0 then
		self.inv_timer -= 1
		if tick % 2 == 0 then
			self.do_draw = false
		end
	end
end

function player:draw_hearts()
	if difficulty > 0 then
		for i = 1, player.maxHP, 1 do
			x = -8 + i * 10
			if player.hp >= i then
				spr(4, x, 1)
			else
				spr(5, x, 1)
			end
		end
	else
		spr(120, 1, 1)
		print('x', 10, 3, 7)
		print(player.hp, 15, 3, 7)
	end
end

function player:draw()
	self:draw_hearts()
	
	if self.do_draw then
		sx, sy = tomap(self.x-0.5, self.y-0.5)
	
		spr(1, sx, sy, 1, 1, self.fliph)
	end
end