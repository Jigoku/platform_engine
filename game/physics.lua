--[[
 * Copyright (C) 2015 Ricky K. Thomson
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

physics = {}

function physics:applyVelocity(object, dt) 
	if object.alive then
		-- x-axis friction
		if object.dir == "right" then
			if object.xvel < object.speed  then
				if object.jumping then
					object.xvel = (object.xvel + object.speed *dt)
				else
					object.xvel = (object.xvel + object.speed*1.3 *dt)
				end
			end
		end
		if object.dir == "left"  then
			if not (object.xvel < -object.speed)  then
				if object.jumping then
					object.xvel = (object.xvel - object.speed *dt)
				else
					object.xvel = (object.xvel - object.speed*1.3 *dt)
				end
			end
		end
		
		-- increase friction when 'idle' until velocity is nullified
		if object.dir == "idle" and object.xvel ~= 0 then
			if object.xvel > 0 then
				object.xvel = math.max(0,object.xvel - ((object.mass*2)/8 *dt))
			elseif object.xvel < 0 then
				object.xvel = math.min(0,object.xvel + ((object.mass*2)/8 *dt))
			end
		end
		
		-- velocity limits
		--if object.xvel > object.speed then object.xvel = object.speed end
		--if object.xvel < -object.speed then object.xvel = -object.speed end
				

		object.newX =object.x + ((object.xvel +object.xvelboost)  *dt)

		
	end
end


function physics:applyGravity(object, dt)
	--simulate gravity
	object.yvel = object.yvel - ((world.gravity+object.mass*2) *dt)
	object.newY = object.y - (object.yvel *dt)
end


function physics:applyRotation(object,n,dt)
	if object.jumping then
		object.angle = object.angle + dt * n
		object.angle = object.angle % (2*math.pi)
	else
		object.angle = 0
	end
end

function physics:swing(object,dt)
	
	if not editing then 
	
		if object.reverse then
			object.angle = object.angle -(object.movespeed * dt)
		else
			object.angle = object.angle + (object.movespeed * dt)
		end

		if object.angle > math.pi then
			object.angle = math.pi
			object.reverse = true
		end

		if object.angle < 0 then
			object.angle = 0
			object.reverse = false
		end
		
	end
	
	object.x = object.radius * math.cos(object.angle) + object.xorigin 
	object.y = object.radius * math.sin(object.angle) + object.yorigin
			
end

function physics:movex(object, dt)
	-- traverse x-axis
	if object.x >= object.xorigin + object.movedist then
		object.x = object.xorigin + object.movedist 
		object.movespeed = -object.movespeed
		object.dir = "left"
	end	
	if object.x <= object.xorigin then
		object.x = object.xorigin
		object.movespeed = -object.movespeed
		object.dir = "right"
	end
	object.newX = object.x + math.round(object.movespeed *dt)
end


function physics:movey(object, dt)
	--traverse y-axis
	if object.y >= object.yorigin + object.movedist then
		object.y = object.yorigin + object.movedist
		object.movespeed = -object.movespeed 
	end
	if object.y <= object.yorigin  then
		object.y = object.yorigin
		object.movespeed = -object.movespeed
	end
	object.newY = object.y + math.round(object.movespeed *dt)
end


function physics:world(dt)
	-- moving platforms etc
	local i, object
	for i, object in ipairs(platforms) do
		if object.movex == 1 then self:movex(object, dt) end
		if object.movey == 1 then self:movey(object, dt) end
		if object.swing == 1 then self:swing(object, dt) end
		self:update(object)
	end
	
	self:player(dt)
	self:pickups(dt)
	self:enemies(dt)		
	self:trapsworld(dt)
	
end


function physics:crates(object,dt)
	
	local i, crate
	for i, crate in ipairs(crates) do
			if collision:check(crate.x,crate.y,crate.w,crate.h,
				object.newX,object.newY,object.w,object.h) and not crate.destroyed then
				object.candrop = false

				if object.jumping and mode == "game" then 
					console:print("crate(" .. i..") destroyed, item ="..crate.item)
					popups:add(crate.x-crate.w,crate.y+crate.h/2,"+"..crate.score)
					crate.destroyed = true
					player.score = player.score+crate.score
					sound:play(sound.effects["crate"])
					crates:addpickup(crate, i,true)	
				end
					
				if collision:right(object,crate) and not collision:top(object,crate) then
				object.xvelboost = 0
					if object.jumping then
						object.newX = crate.x+crate.w +1 *dt
						object.xvel = -object.xvel
					else
						object.newX = crate.x+crate.w +1 *dt
						object.xvel = 0
					end
				elseif collision:left(object,crate) and not collision:top(object,crate) then
				object.xvelboost = 0
					if object.jumping then
						object.newX = crate.x-object.w -1 *dt
						object.xvel = -object.xvel
					else
						object.newX = crate.x-object.w -1 *dt
						object.xvel = 0
					end
				elseif collision:bottom(object,crate) then
					if object.jumping then
						object.newY = crate.y +crate.h +1 *dt
						object.yvel = -object.yvel
					else
						object.newY = crate.y +crate.h  +1 *dt
						object.yvel = 0
					end
				elseif collision:top(object,crate) then
					if object.jumping then
						object.newY = crate.y - object.h -1 *dt
						object.yvel = -object.yvel
						
					else
						object.newY = crate.y - object.h -1 *dt
						object.yvel = 0
					end
				end		
			end
		end
end





function physics:bumpers(object,dt)
	local i, bumper
	for i, bumper in ipairs(bumpers) do
		if collision:check(bumper.x,bumper.y,bumper.w,bumper.h,
				object.newX,object.newY,object.w,object.h) then
			
			object.jumping = true
			
			if bumper.score > 0 then
				player.score = player.score + 50
				bumper.score = bumper.score - 50
				popups:add(bumper.x-bumper.w,bumper.y+bumper.h/2,"+50")
			end
			
			sound:play(sound.effects["bumper"])
			
			if collision:right(object,bumper) and not collision:top(object,bumper) then
					object.newX = bumper.x+bumper.w +1 *dt
					object.xvel = bumper.force
					
				elseif collision:left(object,bumper) and not collision:top(object,bumper) then
					object.newX = bumper.x-object.w -1 *dt
					object.xvel = -bumper.force

				elseif collision:bottom(object,bumper) then
					object.newY = bumper.y +bumper.h +1 *dt
					object.yvel = -bumper.force
			
				elseif collision:top(object,bumper) then
					object.newY = bumper.y - object.h -1 *dt
					object.yvel = bumper.force
				end		
			
		end
	end
end



function physics:platforms(object, dt)
	--loop platforms
		
	local i, platform
	for i, platform in ipairs(platforms) do	
			if collision:check(platform.x,platform.y,platform.w,platform.h,
					object.newX,object.newY,object.w,object.h) then
					
				-- if anything collides, check which sides did
				-- adjust position/velocity if neccesary
				
				-- only check these when clip is true
				if platform.clip == 1 then
					
					-- right side
					if collision:right(object,platform) 
					and not collision:top(object,platform) then
						object.xvel = 0
						object.xvelboost = 0
						object.newX = platform.x+platform.w +1 *dt
						
					-- left side
					elseif collision:left(object,platform) 
					and not collision:top(object,platform) then
						object.xvel = 0
						object.xvelboost = 0
						object.newX = platform.x-object.w -1 *dt
						
					-- bottom side	
					elseif collision:bottom(object,platform) 
					and not collision:right(object,platform) 
					and not collision:left(object,platform) then	
						object.yvel = 0		
						object.newY = platform.y +platform.h +1 *dt
			
					end
				end

				-- top side
				object.carried = false
				platform.carrying = false
				if collision:top(object,platform)  then
					
					
					if platform.clip == 0 then
						object.candrop = true
					else
						object.candrop = false
					end
					if platform.name == "platform" then
						--sounds on collision
						if object.jumping and (object.yvel < 0) then 
							sound:play(sound.effects["hit"])
						end
						
						--if we are jumping upwards go through the platform
						--only  'fix' to surface if we are going down
						if not (object.yvel > 0 and object.jumping ) then
							object.yvel = 0
							object.jumping = false
							object.newY = platform.y - object.h +1 *dt
						end
					
						if platform.movex == 1 and object.yvel == 0 then
							-- move along x-axis with platform	
							object.newX = object.newX + math.round(platform.movespeed *dt)
							object.carried = true
							platform.carrying = true
						end
							
						if platform.movey == 1 and object.yvel <= 0 then
							if platform.movespeed <= 0 then
								--going up
								object.yvel = 0
								object.newY = platform.y - object.h - platform.movespeed *dt
							else
								--going down
								object.yvel = platform.movespeed *dt
								object.newY = platform.y - object.h + platform.movespeed *dt
							end
							object.carried = true
							platform.carrying = true
						end		
						
						
						if platform.swing == 1 then
							object.yvel = -world.gravity
							object.xvel = 0
								
							object.newX =  platform.radius * math.cos(platform.angle) + platform.xorigin +platform.w/2 - object.w/2

						end
					end
				end

			end
		

	end
	
end


function physics:update(object)
	if object.newY then object.y = math.round(object.newY,2) end
	if object.newX then object.x = math.round(object.newX,2) end
end


function physics:pickups(dt)
	local i, pickup
		for i, pickup in ipairs(pickups) do
		
			--pulls all gems to player when attract = true
			if pickup.attract then
				if player.alive then
					local angle = math.atan2(player.y+player.h/2 - pickup.h/2 - pickup.y, player.x+player.w/2 - pickup.w/2 - pickup.x)
					pickup.newX = pickup.x + (math.cos(angle) * pickup.mass/2 * dt)
					pickup.newY = pickup.y + (math.sin(angle) * pickup.mass/2 * dt)
				else
					self:applyGravity(pickup, dt)
				end
			else
			
			
				self:applyGravity(pickup, dt)
				pickup.newX = pickup.x + (pickup.xvel *dt)
			
				self:traps(pickup,dt)
				self:platforms(pickup, dt)
				self:crates(pickup, dt)			
				
			end
			
			self:update(pickup)
			
			if pickup.y+pickup.h > world.bedrock  then
				pickup.yvel = 0
				pickup.jumping = false
				pickup.y = world.bedrock - pickup.h +1 *dt
			end
		end
end



function physics:enemies(dt)
	local i, enemy
	for i, enemy in ipairs(enemies) do
		if type(enemy) == "table" and enemy.alive then
		
			if enemy.name == "walker" then
				self:applyGravity(enemy, dt)
				self:movex(enemy, dt)
				self:traps(enemy, dt)
				self:platforms(enemy, dt)
				--self:crates(enemy, dt)
				
				self:update(enemy)
				
				if enemy.y+enemy.h > world.bedrock  then
					enemy.yvel = 0
					enemy.jumping = false
					enemy.y = world.bedrock - enemy.h +1 *dt
				end
				
				
				--[[if enemy.y +enemy.h > world.groundLevel  then
					--ai suicide (also editor misplacement, remove from world)
					console:print(enemy.name .. "("..i..") suicided")
					sound:play(sound.effects["kill"])
					table.remove(enemies, i)
					
				end--]]
			end	
			
			if enemy.name == "floater" then
				self:movex(enemy, dt)
				self:update(enemy)
			end
			
			if enemy.name == "icicle" then
				
				if enemy.falling then
					
					self:applyGravity(enemy, dt)
					
					--kill enemies hit by icicle
					local i,e
					for i, e in ipairs(enemies) do
						if type(e) == "table" and e.alive and not (e.name == "icicle") then
							if collision:check(e.x,e.y,e.w,e.h,
							enemy.x,enemy.newY,enemy.w,enemy.h) then
								enemies:die(e)
							end

						end
					end
					
					--stop falling when colliding with platform
					local i,platform
					for i,platform in ipairs(platforms) do
							if collision:check(platform.x,platform.y,platform.w,platform.h,
								enemy.x,enemy.newY,enemy.w,enemy.h) then
								
								if platform.clip == 1 and platform.movex == 0 and platform.movey == 0 then
									enemy.falling = false
									sound:play(sound.effects["slice"])
									enemy.gfx = icicle_d_gfx
									enemy.h = icicle_d_gfx:getHeight()
									enemy.newY = platform.y-enemy.h
								end
							end
						
					end
					
					self:update(enemy)
					
					
					if enemy.y+enemy.h > world.bedrock  then
						enemy.falling = false
						enemy.alive = false
					end
				
					
				else
				
					--make dropped spikes act like platforms???
				end
			end
			
			
			if enemy.name == "spikeball" then
				if not editing then
					enemy.angle = enemy.angle - (enemy.speed * dt)
				
					if enemy.angle > math.pi*2 then enemy.angle = 0 end
		
					enemy.newX = enemy.radius * math.cos(enemy.angle) + enemy.xorigin
					enemy.newY = enemy.radius * math.sin(enemy.angle) + enemy.yorigin
					
					self:update(enemy)
				end
			end
			
			
		end
	end
end




function physics:player(dt)
	if editing then return end
		if player.alive  then
			self:applyVelocity(player, dt)
			self:applyGravity(player, dt)
			self:applyRotation(player,math.pi*8,dt)
	
			self:traps(player,dt)
			self:crates(player,dt)
			self:bumpers(player,dt)
			self:platforms(player, dt)
			self:update(player)
			
			if player.y+player.h > world.bedrock  then
				player.yvel = 0
				player.jumping = false
				player.y = world.bedrock - player.h +1 *dt
			end
			
			
			
		--	if mode == "game" and player.y+player.h > world.groundLevel  then
		--		player:die("out of bounds")
		--	end
			



			
		else
			--death physics (float up)
			player.y = player.y - (250 * dt)
			if player.y < player.newY-600 then
				player.lives = player.lives -1
				player:respawn()
			end
			
		end
	
end

function physics:trapsworld(dt)
	for i, trap in ipairs(traps) do
		if trap.falling then
			trap.timer = math.max(0, trap.timer - dt)
				
			if trap.timer <= 0 then
			
				if trap.name == "brick" then
					trap.segments[1].x = trap.segments[1].x - trap.xvel *dt
					trap.segments[2].x = trap.segments[2].x + trap.xvel *dt
					trap.segments[3].x = trap.segments[3].x - trap.xvel*0.5 *dt
					trap.segments[4].x = trap.segments[4].x + trap.xvel*0.5 *dt
				end
			
				physics:applyGravity(trap, dt)
				physics:update(trap)
				if not world:inview(trap) then
					table.remove(trap, i)
				end
						
			end
		end	
	end
end



function physics:traps(object, dt)
	
	for i, trap in ipairs(traps) do
		
			if collision:check(object.newX,object.newY,object.w,object.h, trap.x,trap.y,trap.w,trap.h) then
			
				if trap.name == "log" or trap.name == "bridge" then
					if collision:top(object,trap) and object.yvel < 0 then
						object.newY = trap.y - object.h -1 *dt
						object.yvel = 0
						object.jumping = false

						-- only player can make logs fall
						if mode == "game" and object.name == "player" then
							trap.falling = true
							sound:play(sound.effects["creek"])
						end
					end		
				end	
				
				if trap.name == "brick" then
				
					if collision:right(object,trap) and not collision:top(object,trap) then
						object.newX = trap.x+trap.w +1 *dt
						object.xvel = 0
					
					elseif collision:left(object,trap) and not collision:top(object,trap) then
						object.newX = trap.x-object.w -1 *dt
						object.xvel = 0

					elseif collision:bottom(object,trap) then
						object.newY = trap.y +trap.h +1 *dt
						object.yvel = 0
			
					elseif collision:top(object,trap) then
						if object.jumping then
							object.newY = trap.y - object.h -1 *dt
							object.yvel = -object.yvel
								if mode == "game" and object.name == "player" then
									popups:add(trap.x-trap.w,trap.y+trap.h/2,"+"..trap.score)
									world:sendtofront(traps,i)
									trap.yvel = 500							
									trap.falling = true
									sound:play(sound.effects["brick"])
								end
						else
							object.newY = trap.y - object.h -1 *dt
							object.yvel = 0
						end
					end		
				end	
			end
		
	end
end

