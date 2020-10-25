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

--[[
	editor binds (see editbinds.lua) or
	https://github.com/Jigoku/boxclip/wiki/Controls#editor-controls
	
	some may be undocumented, check this when adding help menu for editor
--]]


editor = {}


require("editor/editbinds")
require("editor/editorVars")
require("editor/editorHelp")
require("editor/editorMouse")

editing = false



-- allow themes to be added by simply placing a theme.lua file
function editor:getthemes()
	local files = love.filesystem.getDirectoryItems( "themes/" )
	local themes = {}
	for i,f in ipairs(files) do
		table.insert(themes, f:match("^(.+).lua$"))
	end
	
	return themes
end
editor.themes = editor:getthemes()


function editor:showtexmenu(textures)
	--make the texture browser display visible
	self.texlist = textures
	self.texmenutimer = editor.texmenuduration
	self.texmenuopacity = 1
end


function editor:showmusicmenu()
	--make the music menu display visible
	self.musicmenuopacity = 1
	self.musicmenutimer = editor.musicmenuduration
end


function editor:settexture(dy)

	if editor.selname == "platform" then
		--update the texture value
		for _,platform in ripairs(world.entities.platform) do
			if platform.selected then
				self:showtexmenu(platforms.textures)
				self.texturesel = math.max(1,math.min(#self.texlist,self.texturesel - dy))
				--TODO, change platforms to polygons, shouldn't need this function when fixed
				platforms:settexture(platform,self.texturesel)
				break
			end
		end
		
	elseif editor.selname == "decal" then
		
		for _,decal in ripairs(world.entities.decal) do
			if decal.selected then
				self:showtexmenu(decals.textures)
				self.texturesel = math.max(1,math.min(#self.texlist,self.texturesel - dy))
				decal.texture = self.texturesel
				break
			end		
		end
	else 
		--empty list
		self:showtexmenu({ nil })
		self.texturesel = 1
	end
	
end


function editor:update(dt)
	--update world before anything else
	if editor.paused then
		--only update these when paused
		camera:update(dt)
		player:update(dt)
		camera:follow(player.x+player.w/2, player.y+player.h/2)
	else
		world:update(dt) 
	end
	
	--update active entity selection
	self:selection()
		
	--adjust mmap scale
	self.mmapscale = camera.scale/4
		
	--texture browser display
	self.texmenutimer = math.max(0, self.texmenutimer - dt)
		
	if self.texmenutimer == 0 then
		if self.texmenuopacity > 0 then
			self.texmenuopacity = math.max(0,self.texmenuopacity - self.texmenufadespeed * dt)
		end
	end
	
	--music browser display
	self.musicmenutimer = math.max(0, self.musicmenutimer - dt)
		
	if self.musicmenutimer == 0 then
		if self.musicmenuopacity > 0 then
			self.musicmenuopacity = math.max(0,self.musicmenuopacity - self.musicmenufadespeed * dt)
		end
	end
	
	if love.mouse.isDown(1) then self.placing = true else self.placing = false end
end


function editor:settheme()
	world.theme = self.themes[self.themesel]
	world:settheme(world.theme)

	self.themesel = self.themesel +1
	if self.themesel > #self.themes then self.themesel = 1 end
end


function editor:warn(func)
	if not func then
		console:print("action cannot be performed on selected entity")
	end
end



function editor:clearsel()
	-- clear selection on active entities
	for _, i in ipairs(self.entorder) do
		for n,e in ipairs(world.entities[i]) do
			e.selected = false
		end
	end
	
	editor.isSelected = false
	editor.entitySelected = {}
	
end

function editor:keypressed(key)
	
	if key == self.binds.edittoggle then 
		editing = not editing
		player.xvel = 0
		player.yvel = 0
		player.angle = 0
		player.jumping = false
		player.xvelboost = 0
		
		self:clearsel()

	end

	if key == self.binds.helptoggle then editorHelp.showhelpmenu = not editorHelp.showhelpmenu end	
	if key == self.binds.maptoggle then self.showmmap = not self.showmmap end
	
	--free roaming	
	if editing then
		if key == self.binds.entselup then self.entsel = self.entsel +1 end
		if key == self.binds.entseldown then self.entsel = self.entsel -1 end
		if key == self.binds.pause then self.paused = not self.paused end
		if key == self.binds.delete then self:remove() end
		if key == self.binds.entcopy then self:copy() end
		if key == self.binds.entpaste then self:paste() end
		if key == self.binds.entmenutoggle then self.showentmenu = not self.showentmenu end
		if key == self.binds.flip then self:flip() end
		if key == self.binds.guidetoggle then self.showgrid = not self.showgrid end
		if key == self.binds.respawn then self:sendtospawn() end
		if key == self.binds.showinfo then self.showinfo = not self.showinfo end
		if key == self.binds.showid then self.showid = not self.showid end
		if key == self.binds.savemap then mapio:savemap(world.map) end
	
		if key == self.binds.musicprev then 
			if world.mapmusic == 0 then 
				world.mapmusic = #sound.music
			else
				world.mapmusic = world.mapmusic -1
			end
		
			self:showmusicmenu()
			sound:playbgm(world.mapmusic)
			sound:playambient(world.mapambient)	
		end
		
		if key == self.binds.musicnext then 
			if world.mapmusic == #sound.music then 
				world.mapmusic = 0 
			else
				world.mapmusic = world.mapmusic +1
			end
			
			self:showmusicmenu()
			sound:playbgm(world.mapmusic)
			sound:playambient(world.mapambient)	
		end
	
	
		if key == self.binds.themecycle then self:settheme() end
		
		
		if(editor.isSelected and editor.drawsel==false) then 
			console:print("move entity keyboard");
			if love.keyboard.isDown(self.binds.moveup) then 
				--weird bug, needs to be "11" to actually save to proper position?
				--maybe it's being rounded down? So that expected "10" becomes "9" ?
				
				editor.entitySelected.y = math.round(editor.entitySelected.y - 11,-1) --up
				editorMouse.mouse.y = editorMouse.mouse.y -10
				if(editor.entitySelected.yorigin~=nil) then editor.entitySelected.yorigin = editor.entitySelected.yorigin - 10 end 
			end 
			
			if love.keyboard.isDown(self.binds.movedown) then 
				editor.entitySelected.y = math.round(editor.entitySelected.y + 10,-1) --down
				if(editor.entitySelected.yorigin~=nil) then editor.entitySelected.yorigin = editor.entitySelected.yorigin + 10 end
				editorMouse.mouse.y = editorMouse.mouse.y +10
			end 
			
			if love.keyboard.isDown(self.binds.moveleft) then 
				editor.entitySelected.x = math.round(editor.entitySelected.x - 10,-1) --left
				editor.entitySelected.xorigin = editor.entitySelected.x
				editorMouse.mouse.x = editorMouse.mouse.x -10
			end 
			
			if love.keyboard.isDown(self.binds.moveright) then 
				editor.entitySelected.x = math.round(editor.entitySelected.x + 10,-1)  --right
				editor.entitySelected.xorigin = editor.entitySelected.x
				editorMouse.mouse.x = editorMouse.mouse.x+10
			end

			return true
		
		end
		
		--[[
		for _, i in ipairs(self.entorder) do	
			for _,e in ipairs(world.entities[i]) do
				--fix this for moving platform (yorigin,xorigin etc)
				if e.selected then
					if love.keyboard.isDown(self.binds.moveup) then 
						--weird bug, needs to be "11" to actually save to proper position?
						--maybe it's being rounded down? So that expected "10" becomes "9" ?
						
						e.y = math.round(e.y - 11,-1) --up
						editorMouse.mouse.y = editorMouse.mouse.y -10
						
						if(e.yorigin~=nil) then e.yorigin = e.yorigin - 10 end 
					end
					if love.keyboard.isDown(self.binds.movedown) then 
						e.y = math.round(e.y + 10,-1) --down
						if(e.yorigin~=nil) then e.yorigin = e.yorigin + 10 end
						
						editorMouse.mouse.y = editorMouse.mouse.y +10
					end 
					if love.keyboard.isDown(self.binds.moveleft) then 
						e.x = math.round(e.x - 10,-1) --left
						e.xorigin = e.x
						editorMouse.mouse.x = editorMouse.mouse.x -10
					end 
					if love.keyboard.isDown(self.binds.moveright) then 
						e.x = math.round(e.x + 10,-1)  --right
						e.xorigin = e.x
						editorMouse.mouse.x = editorMouse.mouse.x+10
					end
	
					return true
					
				end
			end
		end
		--]]
		
		
	end
end


function editor:checkkeys(dt)
	if console.active then return end
	if love.keyboard.isDown(self.binds.right)  then
		player.x = player.x + self.floatspeed /camera.scale *dt
	end
	if love.keyboard.isDown(self.binds.left)  then
		player.x = player.x - self.floatspeed /camera.scale *dt
	end
	if love.keyboard.isDown(self.binds.up) then
		player.y = player.y - self.floatspeed /camera.scale *dt
	end
	if love.keyboard.isDown(self.binds.down) then
		player.y = player.y + self.floatspeed /camera.scale *dt
	end
	
	if love.keyboard.isDown(self.binds.decmovedist) then
		self:setattribute(-1,dt)
	end
	if love.keyboard.isDown(self.binds.incmovedist) then
		self:setattribute(1,dt)
	end
end


function editor:setattribute(dir,dt)
	--horizontal size adjustment
	local should_break = false
					
	for _,type in pairs(world.entities) do
		if should_break then break end
		for _,e in ipairs(type) do
			if e.selected then
				
				if e.swing then
					e.angleorigin = math.max(0,math.min(math.pi,e.angle - dir*2 *dt))
					e.angle = e.angleorigin

				elseif e.movex then
					e.movedist = math.round(e.movedist + dir*2,1)
					if e.movedist < e.w then e.movedist = e.w end

				elseif e.movey then
					
					e.movedist = math.round(e.movedist + dir*2,1)
					
					if e.movedist < e.h then 
						if(e.type=="crusher") then 
							e.movedist = e.movedist + dir * 2 
						else 
							e.movedist = e.h 
						end
					end

				elseif e.scrollspeed then
					e.scrollspeed = math.round(e.scrollspeed + dir*2,1)
					
				end
					
					should_break = true
					break
			end
		end
	end
end



function editor:sendtospawn()
	-- find the spawn entity
	for _, portal in ipairs(world.entities.portal) do
		if portal.type == "spawn" then
			player.x = portal.x
			player.y = portal.y
		end
	end	
	camera.scale = 1
end


function editor:placedraggable(x1,y1,x2,y2)

	-- this function is used for placing entities which 
	-- can be dragged/resized when placing
	
	local ent = self.entities[self.entsel][1]

	--we must drag down and right
	if not (x2 < x1 or y2 < y1) then
		--min sizes (we don't want impossible to select/remove platforms)
		if x2-x1 < self.entsizemin  then x2 = x1 + self.entsizemin end
		if y2-y1 < self.entsizemin  then y2 = y1 + self.entsizemin end

		local x = math.round(x1,-1)
		local y = math.round(y1,-1)
		local w = (x2-x1)
		local h = (y2-y1)
		
		--place the platform
		-- TODO should be moved to entities/init.lua as function
		if ent == "platform" then platforms:add(x,y,w,h,true,false,false,0,0,false,0,self.texturesel) end
		if ent == "platform_b" then platforms:add(x,y,w,h,false,false,false,0,0,false,0,self.texturesel) end
		if ent == "platform_x" then platforms:add(x,y,w,h,false,true,false,100,200,false,0,self.texturesel) end
		if ent == "platform_y" then platforms:add(x,y,w,h,false,false,true,100,200,false,0,self.texturesel) end
		
		if ent == "decal" then decals:add(x,y,w,h,100,1) end
		
		if ent == "death" then materials:add(x,y,w,h,"death") end
	end
end


function editor:drawgrid()
	--draw crosshairs/grid

	if self.showgrid then

		--grid
		love.graphics.setColor(1,1,1,0.09)
		-- horizontal
		for x=camera.x-love.graphics.getWidth()/2/camera.scale,
			camera.x+love.graphics.getWidth()/2/camera.scale,10 do
			love.graphics.line(
				math.round(x,-1), camera.y-love.graphics.getHeight()/2/camera.scale,
				math.round(x,-1), camera.y+love.graphics.getHeight()/2/camera.scale
			)
		end
		-- vertical
		for y=camera.y-love.graphics.getHeight()/2/camera.scale,
			camera.y+love.graphics.getHeight()/2/camera.scale,10 do
			love.graphics.line(
				camera.x-love.graphics.getWidth()/2/camera.scale, math.round(y,-1),
				camera.x+love.graphics.getWidth()/2/camera.scale, math.round(y,-1)
			)
		end

		--crosshair
		love.graphics.setColor(0.78,0.78,1,0.3)
		--vertical
		love.graphics.line(
			math.round(editorMouse.mouse.x,-1),
			math.round(editorMouse.mouse.y+love.graphics.getHeight()/camera.scale,-1),
			math.round(editorMouse.mouse.x,-1),
			math.round(editorMouse.mouse.y-love.graphics.getHeight()/camera.scale,-1)
		)
		--horizontal
		love.graphics.line(
			math.round(editorMouse.mouse.x-love.graphics.getWidth()/camera.scale,-1),
			math.round(editorMouse.mouse.y,-1),
			math.round(editorMouse.mouse.x+love.graphics.getWidth()/camera.scale-1),
			math.round(editorMouse.mouse.y,-1)
		)
		

	end
end


function editor:drawcursor()
--[[ -- old cursor
	--draw the cursor
	love.graphics.setColor(255,255,255,255)
	love.graphics.line(
		math.round(editorMouse.mouse.x,-1),
		math.round(editorMouse.mouse.y,-1),
		math.round(editorMouse.mouse.x,-1)+10,
		math.round(editorMouse.mouse.y,-1)
	)
	love.graphics.line(
		math.round(editorMouse.mouse.x,-1),
		math.round(editorMouse.mouse.y,-1),
		math.round(editorMouse.mouse.x,-1),
		math.round(editorMouse.mouse.y,-1)+10
	)
	--]]
	
	-- detach camera so cursor doesn't scale in size
	camera:detach()
		
	local x,y = camera:toCameraCoords(editorMouse.mouse.x,editorMouse.mouse.y)
	
	-- draw the cursor	
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(editorMouse.mouse.cursors[editorMouse.mouse.cur], x - editorMouse.mouse.hotspotx, y - editorMouse.mouse.hotspoty)
	
	-- print active entity selection info
	self:drawinfo(x+40,y+60)
	
	camera:attach()
	
end


function editor:drawmusicmenu()
	if self.musicmenuopacity > 0 then
		love.graphics.setCanvas(self.musicmenu)
		love.graphics.clear()
		
		local x = self.musicmenupadding
		local y = self.musicmenupadding
		
		love.graphics.setColor(0,0,0,0.58)
		love.graphics.rectangle("fill",0,0,self.musicmenu:getWidth(), self.musicmenu:getHeight(),10)
		
		love.graphics.setColor(1,1,1,1)
		
		local oldfont = love.graphics.getFont()
		love.graphics.setFont(fonts.hud)
		
		local str = "bgm track: " .. (world.mapmusic or "0")
		
		-- center the text within canvas
		love.graphics.printf(
			str, 
			self.musicmenu:getWidth()/2-love.graphics.getFont():getWidth(str)/2, 
			self.musicmenu:getHeight()/2-love.graphics.getFont():getHeight(str)/2, 
			love.graphics.getFont():getWidth(str)
		)
		love.graphics.setFont(oldfont)
		love.graphics.setCanvas()
	
		love.graphics.setColor(1,1,1,self.musicmenuopacity)
		love.graphics.draw(self.musicmenu, love.graphics.getWidth()/2-self.musicmenu:getWidth()/2, 20)
	end
end


function editor:drawtexturesel()

	-- temporary fix... whitelist entity types that can be textured above^^^^
	if self.selname ~= ("platform" or "decal") then return false end

	if self.texmenuopacity > 0 then
	
		love.graphics.setCanvas(self.texmenu)
		love.graphics.clear()
	
		local x = self.texmenupadding
		local y = self.texmenupadding
		local n = 0
	
		love.graphics.setColor(0,0,0,0.5)
		love.graphics.rectangle("fill",0,0,self.texmenu:getWidth(), self.texmenu:getHeight(),0)
		
		local lw = love.graphics.getLineWidth()
		love.graphics.setLineWidth(5)
		love.graphics.setColor(1,1,1,0.5)
		love.graphics.rectangle("line",0,0,self.texmenu:getWidth(), self.texmenu:getHeight(),0)
		love.graphics.setLineWidth(lw)

		--[[
			this loop fails (crash) when changing texture of decal or platform, 
			then moving mouse over an enemy entity, whilst texture menu is visible...
			fix this...
		--]]
	
		
		for i = math.max(-self.texmenuoffset,self.texturesel-self.texmenuoffset), 
			math.min(#self.texlist+self.texmenuoffset,self.texturesel+self.texmenuoffset) do
			
			if type(self.texlist[i]) == "userdata" then
			
				love.graphics.setColor(1,1,1,1)
				love.graphics.draw(
					self.texlist[i],
					x,
					y+(n*self.texmenutexsize)+n*(self.texmenupadding),
					0,
					self.texmenutexsize/self.texlist[i]:getWidth(),
					self.texmenutexsize/self.texlist[i]:getHeight()
				)
				
				if self.texturesel == i then
					local lw = love.graphics.getLineWidth()
					love.graphics.setLineWidth(3)
					love.graphics.setColor(0,1,0,1)
					love.graphics.rectangle(
						"line",
						x,
						y+(n*self.texmenutexsize)+n*(self.texmenupadding),
						self.texmenutexsize,self.texmenutexsize
					)
					love.graphics.setLineWidth(lw)
				end
				
				love.graphics.setColor(0,0,0,1)
				love.graphics.print(i,x+5,y+(n*self.texmenutexsize)+n*(self.texmenupadding)+5)
			
			else
				
				love.graphics.setColor(1,1,1,0.5)
				
				love.graphics.draw(
					self.errortex,
					x,
					y+(n*self.texmenutexsize)+n*(self.texmenupadding),
					0,
					self.texmenutexsize/self.errortex:getWidth(),
					self.texmenutexsize/self.errortex:getHeight()
				)
				
			end
			
			n = n + 1	
		end
			
		love.graphics.setCanvas()
	
		love.graphics.setColor(1,1,1,self.texmenuopacity)
		love.graphics.draw(self.texmenu, 10, 10)
	end
end


function editor:draw()
	
	--editor hud
	love.graphics.setColor(0,0,0,0.49)
	love.graphics.rectangle("fill", love.graphics.getWidth() -130, 10, 120,(editing and 120 or 70),10)
	love.graphics.setFont(fonts.large)
	love.graphics.setColor(1,1,1,0.68)
	love.graphics.print("editing",love.graphics.getWidth()-120, 20,0,1,1)
	love.graphics.setFont(fonts.default)
	love.graphics.print("press [h] for help",love.graphics.getWidth()-120, 50,0,1,1)
	
	
	--interactive editing
	if editing then
		
		camera:attach()
			self:drawgrid()
			self:drawselbox()
			self:drawcursor()
		camera:detach()
		
		
		if world.collision == 0 then
			--notify keybind for camera reset when 
			--no entities are in view
			love.graphics.setColor(1,1,1,1)
			love.graphics.setFont(fonts.menu)
			love.graphics.print("(Tip: press \"".. self.binds.respawn .. "\" to reset camera)", 200, love.graphics.getHeight()-50,0,1,1)
			love.graphics.setFont(fonts.default)
		end
		
		love.graphics.setFont(fonts.console)
		love.graphics.setColor(1,1,1,2155)
		love.graphics.print("selection:",love.graphics.getWidth()-115, 65,0,1,1)
	
		love.graphics.setColor(1,0.60,0.21,1)
		love.graphics.print(editor.selname or "",love.graphics.getWidth()-115, 80,0,1,1)
	
		love.graphics.setColor(1,1,1,1)
		love.graphics.print("theme:",love.graphics.getWidth()-115, 95,0,1,1)
	
		love.graphics.setColor(1,0.60,0.21,1)
		love.graphics.print(world.theme or "default",love.graphics.getWidth()-115, 110,0,1,1)
		--love.graphics.setFont(fonts.default)
	
		if self.showentmenu then self:drawentmenu() end
		self:drawmusicmenu()
		self:drawtexturesel()
	end
	
	if self.showmmap then self:drawmmap() end
	if editorHelp.showhelpmenu then editorHelp:drawhelpmenu() end
	
	
end


function editor:drawselbox()
	--draw an outline when dragging mouse if 
	-- entsel is one of these types
	if self.drawsel then
		for _,entity in ipairs(self.draggable) do
			if self.entities[self.entsel][1] == entity then
				love.graphics.setColor(0,1,1,1)
				love.graphics.rectangle(
					"line", 
					editorMouse.mouse.pressed.x,editorMouse.mouse.pressed.y, 
					editorMouse.mouse.x - editorMouse.mouse.pressed.x, editorMouse.mouse.y - editorMouse.mouse.pressed.y
				)
			end
		end
		
		else
		
			--draw box  for actively selected entity
			if self.selbox then
			local lw = love.graphics.getLineWidth()
			love.graphics.setLineWidth(3)
			--frame
			love.graphics.setColor(0,0.9,0,1)
			love.graphics.rectangle("line", self.selbox.x, self.selbox.y, self.selbox.w, self.selbox.h)
		
			--corner markers
			local size = 5
			love.graphics.setColor(0,1,0,1)
			--top left
			love.graphics.rectangle("fill", self.selbox.x-size/2, self.selbox.y-size/2, size, size)
			--top right
			love.graphics.rectangle("fill", self.selbox.x+self.selbox.w-size/2, self.selbox.y-size/2, size, size)
			--bottom left
			love.graphics.rectangle("fill", self.selbox.x-size/2, self.selbox.y+self.selbox.h-size/2, size, size)
			--bottom right
			love.graphics.rectangle("fill", self.selbox.x+self.selbox.w-size/2, self.selbox.y+self.selbox.h-size/2, size, size)
			love.graphics.setLineWidth(lw)
		end
	end
	

end



function editor:drawentmenu()
	--gui scrolling list for entity selection
	if not editing then return end
	
	love.graphics.setFont(fonts.menu)
	love.graphics.setCanvas(self.entmenu)
	love.graphics.clear()
		
	--frame
	love.graphics.setColor(0,0,0,0.58)
	love.graphics.rectangle(
		"fill",0,0, self.entmenu:getWidth(), self.entmenu:getHeight(),10
	)
	
	--border
	love.graphics.setColor(1,1,1,0.58)
	love.graphics.rectangle(
		"fill",0,0, self.entmenu:getWidth(), 5
	)
	
	love.graphics.setColor(1,1,1,1)
	love.graphics.print("entity selection",10,10)
	
	--hrule
	love.graphics.setColor(1,1,1,0.58)
	love.graphics.rectangle(
		"fill",10,25, self.entmenu:getWidth()-10, 1
	)
	
	local s = 20 -- vertical spacing
	local empty = "*"
	local padding = 2
	

	local n = 1
	for i=-5,15 do 
		if self.entities[self.entsel+i] and self.entities[self.entsel+i][1] then
			n = n +1
			local texture = self.bullettex --placeholder
			love.graphics.setColor(1,1,1,1)
			love.graphics.draw(texture,10,s*n,0,s/texture:getWidth(), s/texture:getHeight())
			
			if i == 0 then 
				love.graphics.setColor(0.58,0.58,0.58,1)

				love.graphics.rectangle(
					"fill",s/texture:getWidth()+s*2,-padding+s*n, self.entmenu:getWidth()-20+padding*2, 15+padding*2
				)
			
				love.graphics.setColor(0,0,0,1)
				love.graphics.print(self.entities[self.entsel+i][1],s/texture:getWidth()+s*2,s*n)
			else
				love.graphics.setColor(0.58,0.58,0.58,1)
				love.graphics.print(self.entities[self.entsel+i][1],s/texture:getWidth()+s*2,s*n)
			end
		end
	end
	
	love.graphics.setFont(fonts.default)
	love.graphics.setCanvas()
	
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(self.entmenu, 10, love.graphics.getHeight()-self.entmenu:getHeight()-10 )
end


function editor:selection()
	if not editing then return false end

	-- no need to find a selection if we are placing a new entity
	if self.placing then return end
	
	editor.isSelected = false 
	editor.entitySelected = {}
	
	-- selects the entity when mouseover 	
	for _, i in ipairs(self.entorder) do
		for n,e in ipairs(world.entities[i]) do
			--deselect all entities before continuing
			e.selected = false
		end
	end
	
	-- this let's us break nested loops below
	-- and not have multiple entities selected, resulting in a crash
	local break_entities = false 
	local break_entorder = false 
	
	for _, i in ipairs(self.entorder) do
		if break_entorder then break end
		--reverse loop
		for n,e in ripairs(world.entities[i]) do
			if break_entities then break end
			if world:inview(e) then
				editor.selname = (e.type or e.group)
				editor.id = n
				
				if e.movex then
					--collision area for moving entity
					if collision:check(editorMouse.mouse.x,editorMouse.mouse.y,1,1,e.xorigin, e.y, e.movedist+e.w, e.h) then
						self.selbox = { 
							x = e.xorigin, 
							y = e.y, 
							w = e.movedist+e.w, 
							h = e.h 
						}
						e.selected = true
						editor.isSelected = true
						editor.entitySelected = e
						
					end
				elseif e.movey then
					--collision area for moving entity
					if collision:check(editorMouse.mouse.x,editorMouse.mouse.y,1,1,e.xorigin, e.yorigin, e.w, e.h+e.movedist) then
						self.selbox = { 	
							x = e.xorigin , 
							y = e.yorigin , 
							w = e.w , 
							h = e.h + e.movedist 
						}
						e.selected = true
						editor.isSelected = true
						editor.entitySelected = e
					
					end
				elseif e.swing then
					--collision area for swinging entity
					if collision:check(editorMouse.mouse.x,editorMouse.mouse.y,1,1,
						e.xorigin-chainlink.textures["origin"]:getWidth()/2, e.yorigin-chainlink.textures["origin"]:getHeight()/2,  
						chainlink.textures["origin"]:getWidth(),chainlink.textures["origin"]:getHeight()) then
						self.selbox = {	
							x = e.xorigin-chainlink.textures["origin"]:getWidth()/2, 
							y = e.yorigin-chainlink.textures["origin"]:getHeight()/2,  
							w = chainlink.textures["origin"]:getWidth(),
							h = chainlink.textures["origin"]:getHeight()
						}
						e.selected = true
						editor.isSelected = true
						editor.entitySelected = e
					
					end
				elseif collision:check(editorMouse.mouse.x,editorMouse.mouse.y,1,1,e.x,e.y,e.w,e.h) then
					--collision area for static entities
					self.selbox = { 
						x = e.x, 
						y = e.y, 
						w = e.w, 
						h = e.h 
					} 
					e.selected = true
					editor.isSelected = true
					editor.entitySelected = e

				else
					self.selbox = nil
					editor.selname = "null"
				end
				
				
				if e.selected then
					-- selection cursor 
					editorMouse.mouse.cur = 2
					
					-- update texture selection (platforms only for now)
					-- temporary, until other entities use numeric texture id slot
					-- otherwise enemy texture = nil and causes crashing
					if e.group == "platform" then
						self.texturesel = e.texture
					end
					
					-- exit both loops
					break_entities = true
					break_entorder = true
					
					return
				else
					-- default cursor
					editorMouse.mouse.cur = 1
					
				end
				
			end
		end
	end
end


function editor:removeall(group,type)
	--removes all entity types of given entity
	for _, enttype in pairs(world.entities) do
		for i, e in ripairs(enttype) do
			if e.group == group and e.type == type then
				table.remove(enttype,i)
			end
		end
	end
end


function editor:remove()
	--removes the currently selected entity from the world
	local should_break = false
	for _, i in ipairs(self.entorder) do
		if should_break then break end
		for n,e in ipairs(world.entities[i]) do
			if e.selected then
				table.remove(world.entities[i],n)
				console:print( e.group .. " (" .. n .. ") removed" )
				self.selbox = nil
				should_break = true
				
				editor.isSelected = false
				editor.entitySelected = {}
				
				break
			end
		end
	end
end


function editor:flip()
	local should_break = false
	for _, i in ipairs(self.entorder) do
		if should_break then break end
		for n,e in ipairs(world.entities[i]) do
			if e.selected and e.editor_canflip then
				e.flip = not e.flip
				console:print( e.group .. " (" .. n .. ") flipped" )
				e.selected = false
				should_break = true
				editor.isSelected = false
				editor.entitySelected = {}
				
				break
			end
		end
	end
end


function editor:rotate(dy)
	--set rotation value for the entity
	--four directions, 0,1,2,3 at 90degree angles
	local should_break = false
	for _, i in ipairs(self.entorder) do
		if should_break then break end
		for n,e in ipairs(world.entities[i]) do
			if e.selected and e.editor_canrotate then
			
				e.dir = e.dir + dy
				if e.dir > 3 then
					e.dir = 0
				elseif e.dir < 0 then
					e.dir = 3
				end
				
				local w = e.w
				local h = e.h
				
				e.w = h
				e.h = w
					
				console:print( e.group .. " (" .. n .. ") rotated, direction = "..e.dir)
				e.selected = false
				should_break = true
				
				editor.isSelected = false
				editor.entitySelected = {}
				
				break

			end
		end
	end
end


function editor:copy()
	for _,type in pairs(world.entities) do
		for i, e in ipairs(type) do
			if e.selected then
				console:print("copied "..e.group.."("..i..")")
				self.clipboard = e
				return true
			end
		end
	end
end


function editor:paste()
	local x = math.round(editorMouse.mouse.x,-1)
	local y = math.round(editorMouse.mouse.y,-1)
	
	--paste the cloned entity
	local p = table.deepcopy(self.clipboard)
	if type(p) == "table" then
		p.x = x
		p.y = y
		p.xorigin = x + (p.x-x)
		p.yorigin = y + (p.y-y)
		table.insert(world.entities[p.group],p)
		console:print("paste "..p.group.."("..#world.entities[p.group]..")")
	end
end


function editor:drawmmap()
	-- TODO define a mmap colour for each entity in its own file, 
	-- then loop over world.entities and apply colour, so that
	-- editor does not specify actual entity names
	love.graphics.setCanvas(self.mmapcanvas)
	love.graphics.clear()

	love.graphics.setColor(0,0,0,0.58)
	love.graphics.rectangle("fill", 0,0,self.mmapw,self.mmaph)
	
	for i, platform in ipairs(world.entities.platform) do
		if platform.clip then
			love.graphics.setColor(
				platform_r,
				platform_g,
				platform_b,
				1
			)
		else
			love.graphics.setColor(
				platform_behind_r,
				platform_behind_g,
				platform_behind_b,
				1
			)
		end
		love.graphics.rectangle(
			"fill", 
			(platform.x*self.mmapscale)-(camera.x*self.mmapscale)+self.mmapw/2, 
			(platform.y*self.mmapscale)-(camera.y*self.mmapscale)+self.mmaph/2, 
			platform.w*self.mmapscale, 
			platform.h*self.mmapscale
		)
	end

	love.graphics.setColor(0,1,1,1)
	for i, crate in ipairs(world.entities.crate) do
		love.graphics.rectangle(
			"fill", 
			(crate.x*self.mmapscale)-camera.x*self.mmapscale+self.mmapw/2, 
			(crate.y*self.mmapscale)-camera.y*self.mmapscale+self.mmaph/2, 
			crate.w*self.mmapscale, 
			crate.h*self.mmapscale
		)
	end
	
	love.graphics.setColor(1,0.19,0.19,1)
	for i, enemy in ipairs(world.entities.enemy) do
		love.graphics.rectangle(
			"fill", 
			(enemy.x*self.mmapscale)-camera.x*self.mmapscale+self.mmapw/2, 
			(enemy.y*self.mmapscale)-camera.y*self.mmapscale+self.mmaph/2, 
			enemy.w*self.mmapscale, 
			enemy.h*self.mmapscale
		)
	end
	
	love.graphics.setColor(0.58,1,0.58,1)
	for i, pickup in ipairs(world.entities.pickup) do
		love.graphics.rectangle(
			"fill", 
			(pickup.x*self.mmapscale)-camera.x*self.mmapscale+self.mmapw/2, 
			(pickup.y*self.mmapscale)-camera.y*self.mmapscale+self.mmaph/2, 
			pickup.w*self.mmapscale, 
			pickup.h*self.mmapscale
		)
	end
	
	love.graphics.setColor(0,1,1,1)
	for i, checkpoint in ipairs(world.entities.checkpoint) do
		love.graphics.rectangle(
			"fill", 
			(checkpoint.x*self.mmapscale)-camera.x*self.mmapscale+self.mmapw/2, 
			(checkpoint.y*self.mmapscale)-camera.y*self.mmapscale+self.mmaph/2, 
			checkpoint.w*self.mmapscale, 
			checkpoint.h*self.mmapscale
		)
	end

	love.graphics.setColor(1,0.11,1,1)
	for i, spring in ipairs(world.entities.spring) do
		love.graphics.rectangle(
			"fill", 
			(spring.x*self.mmapscale)-camera.x*self.mmapscale+self.mmapw/2, 
			(spring.y*self.mmapscale)-camera.y*self.mmapscale+self.mmaph/2, 
			spring.w*self.mmapscale, 
			spring.h*self.mmapscale
		)
	end

	love.graphics.setColor(1,0.58,0,1)
	for i, bumper in ipairs(world.entities.bumper) do
		love.graphics.rectangle(
			"fill", 
			(bumper.x*self.mmapscale)-camera.x*self.mmapscale+self.mmapw/2, 
			(bumper.y*self.mmapscale)-camera.y*self.mmapscale+self.mmaph/2, 
			bumper.w*self.mmapscale, 
			bumper.h*self.mmapscale
		)
	end
	
	love.graphics.setColor(1,1,1,1)
	for i, trap in ipairs(world.entities.trap) do
		love.graphics.rectangle(
			"fill", 
			(trap.x*self.mmapscale)-camera.x*self.mmapscale+self.mmapw/2, 
			(trap.y*self.mmapscale)-camera.y*self.mmapscale+self.mmaph/2, 
			trap.w*self.mmapscale, 
			trap.h*self.mmapscale
		)
	end
	
	love.graphics.setColor(1,1,1,1)
	love.graphics.rectangle(
		"line", 
		(player.x*self.mmapscale)-(camera.x*self.mmapscale)+self.mmapw/2, 
		(player.y*self.mmapscale)-(camera.y*self.mmapscale)+self.mmaph/2, 
		player.w*self.mmapscale, 
		player.h*self.mmapscale
	)
	
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(self.mmapcanvas, love.graphics.getWidth()-10-self.mmapw,love.graphics.getHeight()-10-self.mmaph )

end


function editor:drawinfo(x,y)
	if editor.showinfo then
		love.graphics.setFont(fonts.console)
		
		for _, t in pairs(world.entities) do
			for i, e in pairs(t) do
				if e.selected and world:inview(e) then	
					local info = "x ".. math.round(e.x) ..", y " .. math.round(e.y) 
					local padding = 5
					love.graphics.setColor(0.1,0.1,0.1,0.75)
					love.graphics.rectangle("fill", x-20-padding,y-40-padding,love.graphics.getFont():getWidth(info)+padding*2,50,5)
					love.graphics.setColor(0,1,0,1)
					love.graphics.print(e.group .. "(" .. i .. ")", x-20, y-40, 0)
					love.graphics.setColor(1,1,1,0.5)
					love.graphics.print(info, x-20,y-20,0)  
					
					return
				end
			end
		end
	end
end


