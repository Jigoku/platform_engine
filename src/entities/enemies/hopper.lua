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
 
hopper = {}
table.insert(enemies.list, "hopper")
table.insert(editor.entities, {"hopper", "enemy"})
enemies.textures["hopper" ] = textures:load("data/images/enemies/hopper/")

function hopper.worldInsert(x,y,movespeed,movedist,dir,name)
	
	local texture = self.textures["hopper"][1]
	table.insert(world.entities.enemy, {
		movespeed = movespeed or 100,
		movedist = movedist or 200,
		movex = 1,
		dir = 0,
		xorigin = x,
		yorigin = y,
		x = love.math.random(x,x+movedist) or 0,
		y = y or 0,
		texture = texture,
		w = texture:getWidth(),
		h = texture:getHeight(),
		framecycle = 0,
		frame = 1,
		framedelay = 0.025,
		group = "enemy",
		type = name,
		xvel = 0,
		yvel = 0,
		dir = 0,
		alive = true,
		score = 100
	})
end


function hopper.checkCollision(enemy, dt)
	
	physics:applyGravity(enemy, dt)

	physics:movex(enemy, dt)	
	physics:crates(enemy,dt)
	physics:traps(enemy, dt)
	physics:platforms(enemy, dt)
	
	if enemy.carried then
		if enemy.x <= enemy.xorigin or enemy.x >= enemy.xorigin + enemy.movedist then
			enemy.yvel=600
		end
	end
	
	physics:update(enemy)
	
	-- NOT ACTIVE WHILST EDITING
	if mode == "game" and player.alive and collision:check(player.newX,player.newY,player.w,player.h,
		enemy.x+5,enemy.y+5,enemy.w-10,enemy.h-10) then
		
		-- if we land on top, kill enemy
		if collision:above(player,enemy) then	
			if player.jumping or player.invincible or player.sliding then
				
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

