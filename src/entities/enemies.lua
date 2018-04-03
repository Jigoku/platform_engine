--[[
 * Copyright (C) 2015 - 2018 Ricky K. Thomson
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * u should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 --]]
 
enemies = {}

enemies.textures = {
	["walker"] = love.graphics.newImage( "data/images/enemies/walker.png"),
	["floater"] = love.graphics.newImage( "data/images/enemies/floater.png"),
	["spike"] = love.graphics.newImage( "data/images/enemies/spike.png"),
	["spike_large"] = love.graphics.newImage( "data/images/enemies/spike_large.png"),
	["icicle"] = love.graphics.newImage( "data/images/enemies/icicle.png"),
	["icicle_d"] = love.graphics.newImage( "data/images/enemies/icicle_d.png"),
	["spikeball"] = love.graphics.newImage( "data/images/enemies/spikeball.png"),
}


table.insert(editor.entities, {"spike", "enemy"})
table.insert(editor.entities, {"spike_large", "enemy"})
table.insert(editor.entities, {"icicle", "enemy"})
table.insert(editor.entities, {"walker", "enemy"})
table.insert(editor.entities, {"floater",  "enemy"})
table.insert(editor.entities, {"spikeball", "enemy"})


function enemies:add(x,y,movespeed,movedist,dir,type)

	if type == "walker" then
		table.insert(world.entities.enemy, {
			movespeed = movespeed or 100,
			movedist = movedist or 200,
			movex = 1,
			dir = 0,
			xorigin = x,
			yorigin = y,
			x = love.math.random(x,x+movedist) or 0,
			y = y or 0,
			w = self.textures[type]:getWidth(),
			h = self.textures[type]:getHeight(),
			group = "enemy",
			type = type,
			xvel = 0,
			yvel = 0,
			dir = 0,
			alive = true,
			score = 100
		})
		
	elseif type == "hopper" then
		table.insert(world.entities.enemy, {
			movespeed = movespeed or 100,
			movedist = movedist or 200,
			movex = 0,
			dir = 0,
			xorigin = x,
			yorigin = y,
			x = love.math.random(x,x+movedist) or 0,
			y = y or 0,
			w = self.textures[type]:getWidth(),
			h = self.textures[type]:getHeight(),
			group = "enemy",
			type = type,
			xvel = 0,
			yvel = 0,
			dir = 0,
			alive = true,
			score = 100
		})

	elseif type == "spike" then
		if dir == 0 or dir == 2 then
			width = self.textures[type]:getWidth()
			height = self.textures[type]:getHeight()
		end
		if dir == 3 or dir == 1 then
			width = self.textures[type]:getHeight()
			height = self.textures[type]:getWidth()
		end
		table.insert(world.entities.enemy, {		
			x = x or 0,
			y = y or 0,
			xorigin = x,
			yorigin = y,
			w = width,
			h = height,
			group = "enemy",
			type = type,
			alive = true,
			movedist = 0,
			dir = dir,
			movespeed = 0,
			movedist = 0,
			editor_canrotate = true
		})

	elseif type == "spike_large" then
		if dir == 0 or dir == 2 then
			width = self.textures[type]:getWidth()
			height = self.textures[type]:getHeight()
		end
		if dir == 3 or dir == 1 then
			width = self.textures[type]:getHeight()
			height = self.textures[type]:getWidth()
		end
		table.insert(world.entities.enemy, {		
			x = x or 0,
			y = y or 0,
			xorigin = x,
			yorigin = y,
			w = width,
			h = height,
			group = "enemy",
			type = type,
			alive = true,
			movedist = 0,
			movespeed = 0,
			dir = dir,
			
			editor_canrotate = true
		})

	elseif type == "icicle" then
		table.insert(world.entities.enemy, {		
			x = x or 0,
			y = y or 0,
			xorigin = x,
			yorigin = y,
			w = self.textures[type]:getWidth(),
			h = self.textures[type]:getHeight(),
			group = "enemy",
			type = type,
			alive = true,
			falling = false,
			yvel = 0,
			jumping = 0,
			movespeed = 0,
			movedist = 0,
			dir = 0,
		})

	elseif type == "floater" then
		table.insert(world.entities.enemy, {
			movespeed = movespeed or 100,
			movedist = movedist or 400,
			movex = 1,
			xorigin = x,
			yorigin = y,
			ticks = love.math.random(100),
			yspeed = 0.01,
			x = love.math.random(x,x+movedist) or 0,
			y = y or 0,
			w = self.textures[type]:getWidth(),
			h = self.textures[type]:getHeight(),
			group = "enemy",
			type = type,
			xvel = 0,
			yvel = 0,
			dir = 0,
			alive = true,
			score = 150,
		})
	
	elseif type == "spikeball" then
		table.insert(world.entities.enemy, {
			w = self.textures[type]:getWidth(),
			h = self.textures[type]:getHeight(),
			xorigin = x,
			yorigin = y,
			x = x or 0,
			y = y or 0,
			group = "enemy",
			type = type,
			speed = 3,
			alive = true,
			swing = 1,
			angle = 0, --should restore set angleorigin here TODO
			radius = 200,
			movespeed = 0,
			movedist = 0,
			dir = 0,
		})
	end
	print( type .. " added @  X:"..x.." Y: "..y)
end



function enemies:update(dt)
	for i, enemy in ipairs(world.entities.enemy) do
		if enemy.alive then
			enemy.carried = false
		
			if enemy.type == "walker" then
			
				physics:applyGravity(enemy, dt)
				--enemy.yorigin = enemy.newY

				physics:movex(enemy, dt)	
				physics:crates(enemy,dt)
				physics:traps(enemy, dt)
				physics:platforms(enemy, dt)
				
				--test
				--hopper enemy, move this statement to a new entity TODO
				--this is broken, enemy.carried when true for traps, gets reset to false for platforms.
				if enemy.carried then
					if enemy.x <= enemy.xorigin or enemy.x >= enemy.xorigin + enemy.movedist then
						enemy.yvel=500	
					end
				end
				
				physics:update(enemy)
				
				-- NOT ACTIVE WHILST EDITING
				if mode == "game" and player.alive and collision:check(player.newX,player.newY,player.w,player.h,
					enemy.x+5,enemy.y+5,enemy.w-10,enemy.h-10) then
					-- if we land on top, kill enemy
					if collision:above(player,enemy) then	
						if player.jumping or player.invincible then
							
							if player.y > enemy.y then
								player.yvel = -player.jumpheight
							elseif player.y < enemy.y then
								player.yvel = player.jumpheight
							end
							popups:add(enemy.x+enemy.w/2,enemy.y+enemy.h/2,"+"..enemy.score)
							player.score = player.score + enemy.score
							enemy.alive = false
							sound:play(sound.effects["kill"])
							console:print(enemy.group .." killed")
							joystick:vibrate(0.5,0.5,0.5)
							return true
							
						else
							player:die(enemy.group)
						end
					end
				end
				
			end	
			
			if enemy.type == "floater" then
				enemy.y = enemy.yorigin - (10*math.sin(enemy.ticks*enemy.yspeed*math.pi)) + 20
				enemy.ticks = enemy.ticks +1
				physics:movex(enemy, dt)
				physics:update(enemy)
				
				-- NOT ACTIVE WHILST EDITING
				if mode == "game" and player.alive and collision:check(player.newX,player.newY,player.w,player.h,
					enemy.x+5,enemy.y+5,enemy.w-10,enemy.h-10) then

					if player.jumping or player.invincible then			
						if player.y > enemy.y then
							player.yvel = -player.jumpheight
						elseif player.y < enemy.y then
							player.yvel = player.jumpheight
						end

						popups:add(enemy.x+enemy.w/2,enemy.y+enemy.h/2,"+"..enemy.score)
						player.score = player.score + enemy.score
						enemy.alive = false
						sound:play(sound.effects["kill"])
						console:print(enemy.group .." killed")
						joystick:vibrate(0.5,0.5,0.5)
					else			
						-- otherwise we die			
						player:die(enemy.group)
					end
				end
			
			end
			
			if enemy.type == "spike" or enemy.type == "spike_large" then
				-- NOT ACTIVE WHILST EDITING
				if mode == "game" and player.alive and  collision:check(player.newX,player.newY,player.w,player.h,
					enemy.x+5,enemy.y+5,enemy.w-10,enemy.h-10) then
					player.yvel = -player.yvel
					player:die(enemy.group)
				end
			end
			
			
			if enemy.type == "icicle" then
				if enemy.falling then
					
					physics:applyGravity(enemy, dt)
					
					--kill enemies hit by icicle
					local i,e
					for i, e in ipairs(world.entities.enemy) do
						if e.alive and not (e.type == "icicle") then
							if collision:check(e.x,e.y,e.w,e.h,
							enemy.x,enemy.newY,enemy.w,enemy.h) then
								e.alive = false
								sound:play(sound.effects["kill"])
								console:print(e.group .. " killed by " .. enemy.group)
							end
						end
					end
					
					--stop falling when colliding with platform
					local i,platform
					for i,platform in ipairs(world.entities.platform) do
							if collision:check(platform.x,platform.y,platform.w,platform.h,
								enemy.x,enemy.newY,enemy.w,enemy.h) then
								
								if platform.clip and not platform.movex and not platform.movey then
									enemy.falling = false
									sound:play(sound.effects["slice"])
									enemy.type = "icicle_d"
									enemy.h = enemies.textures[enemy.type]:getHeight()
									enemy.newY = platform.y-enemy.h
									joystick:vibrate(0.35,0.35,0.5)
								end
							end
						
					end
					
					physics:update(enemy)

				else
					--make dropped spikes act like platforms???
				end
				
				-- NOT ACTIVE WHILST EDITING
				if mode == "game" and player.alive then
					if collision:check(player.newX,player.newY,player.w,player.h,
						enemy.x-50,enemy.y,enemy.w+50,enemy.h+200) and enemy.y == enemy.yorigin then
						enemy.falling = true
					end
			
					if collision:check(player.newX,player.newY,player.w,player.h,
						enemy.x+5,enemy.y+5,enemy.w-10,enemy.h-10) and enemy.falling then
						if not player.invincible then
							player.yvel = -player.yvel
							player:die(enemy.group)
						end
					end
				end
			end
			
			if enemy.type == "spikeball" then
				enemy.angle = enemy.angle - (enemy.speed * dt)
				
				if enemy.angle > math.pi*2 then enemy.angle = 0 end
		
				enemy.newX = enemy.radius * math.cos(enemy.angle) + enemy.xorigin
				enemy.newY = enemy.radius * math.sin(enemy.angle) + enemy.yorigin
					
				physics:update(enemy)
				
				-- NOT ACTIVE WHILST EDITING
				if mode == "game" and player.alive and collision:check(player.newX,player.newY,player.w,player.h,
					enemy.x-enemy.w/2+5,enemy.y-enemy.h/2+5,enemy.w-10,enemy.h-10)  then
					
					if not player.invincible then
						player.yvel = -player.yvel
						player:die(enemy.group)
					end
				end
			end
	
		end
	end	
end


function enemies:draw()
	local count = 0

	for i, enemy in ipairs(world.entities.enemy) do
		if enemy.alive and world:inview(enemy) then
			count = count + 1
			
			local texture = self.textures[enemy.type]
			
			if enemy.type == "walker" or enemy.type == "floater" then
				love.graphics.setColor(255,255,255,255)
				if enemy.movespeed < 0 then
					love.graphics.draw(texture, enemy.x, enemy.y, 0, 1, 1)
				elseif enemy.movespeed > 0 then
					love.graphics.draw(texture, enemy.x+texture:getWidth(), enemy.y, 0, -1, 1)
				end
			end
			
			love.graphics.setColor(255,255,255,255)
			if enemy.type == "spike" or enemy.type == "spike_large" then
			
				if enemy.dir == 1 then
					love.graphics.draw(texture, enemy.x, enemy.y, math.rad(90),1,(enemy.flip and -1 or 1),0,(enemy.flip and 0 or enemy.w))
				elseif enemy.dir == 2 then
					love.graphics.draw(texture, enemy.x, enemy.y, 0,(enemy.flip and 1 or -1),-1,(enemy.flip and 0 or enemy.w),enemy.h)	
				elseif enemy.dir == 3 then
					love.graphics.draw(texture, enemy.x, enemy.y, math.rad(-90),1,(enemy.flip and -1 or 1),enemy.h,(enemy.flip and enemy.w or 0))
				else
					love.graphics.draw(texture, enemy.x, enemy.y, 0,(enemy.flip and -1 or 1),1,(enemy.flip and enemy.w or 0),0,0)
				end
			end
			
			if enemy.type == "icicle" or enemy.type == "icicle_d" then
				love.graphics.draw(texture, enemy.x, enemy.y, 0,1,1)
			end
			
			
			if enemy.type == "spikeball" then
				platforms:drawlink(enemy)
				love.graphics.draw(texture, enemy.x, enemy.y, -enemy.angle*2,1,1,enemy.w/2,enemy.h/2)
			end
			
			if editing or  debug then
				enemies:drawdebug(enemy, i)
			end
		end
	end
	world.enemies = count
end


function enemies:drawdebug(enemy, i)
	local texture = self.textures[enemy.type]

	if enemy.type == "spikeball" then
		--bounds
		love.graphics.setColor(255,0,0,255)
		love.graphics.rectangle("line", enemy.x-texture:getWidth()/2+5, enemy.y-texture:getHeight()/2+5, texture:getWidth()-10, texture:getHeight()-10)
		--hitbox
		love.graphics.setColor(255,200,100,255)
		love.graphics.rectangle("line", enemy.x-texture:getWidth()/2, enemy.y-texture:getHeight()/2, texture:getWidth(), texture:getHeight())

		--waypoint
		love.graphics.setColor(255,0,255,100)
		love.graphics.line(enemy.xorigin,enemy.yorigin,enemy.x,enemy.y)	
		love.graphics.circle("line", enemy.xorigin,enemy.yorigin, enemy.radius,enemy.radius)	
		
		--selectable area in editor
		love.graphics.setColor(255,0,0,100)
		love.graphics.rectangle("line", 
			enemy.xorigin-platform_link_origin:getWidth()/2,enemy.yorigin-platform_link_origin:getHeight()/2,
			platform_link_origin:getWidth(),platform_link_origin:getHeight()
		)

	else
	--all other enemies
		--bounds
		love.graphics.setColor(255,0,0,255)
		love.graphics.rectangle("line", enemy.x+5, enemy.y+5, enemy.w-10, enemy.h-10)
		--hitbox
		love.graphics.setColor(255,200,100,255)
		love.graphics.rectangle("line", enemy.x, enemy.y, enemy.w, enemy.h)
	end

	--waypoint	
	if enemy.type == "walker" or enemy.type == "floater" then
		
		love.graphics.setColor(255,0,255,50)
		love.graphics.rectangle("fill", enemy.xorigin, enemy.y, enemy.movedist+texture:getWidth(), texture:getHeight())
		love.graphics.setColor(255,0,255,255)
		love.graphics.rectangle("line", enemy.xorigin, enemy.y, enemy.movedist+texture:getWidth(), texture:getHeight())
	end

	
	editor:drawid(enemy,i)
	editor:drawcoordinates(enemy)
end






