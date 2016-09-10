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

util = {}


-- this function redefine love.graphics.newImage( ), so all images are
-- not put through linear filter, which makes things more crisp on the
--  pixel level (less blur)... should this be used?

--[[
local _newImage = love.graphics.newImage
function love.graphics.newImage(...)
	local img = _newImage(...)
	img:setFilter('nearest', 'nearest')
	return img
end
--]]



function math.round(num, idp)
	-- round integer to decimal places
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function ripairs(t)
	--same as ipairs, but itterate from last to first
	local function ripairs_it(t,i)
		i=i-1
		local v=t[i]
		if v==nil then return v end
		return i,v
	end
	return ripairs_it, t, #t+1
end


function split(s, delimiter)
	--split string into a table
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end


function util:togglefullscreen()
	paused = true
	local fs, fstype = love.window.getFullscreen()
	
	if fs then
		--camera.scaleX = 1
		--camera.scaleY = 1
		local success = love.window.setFullscreen( false )

	else
		--camera.scaleX = 0.75
		--camera.scaleY = 0.75
		local success = love.window.setFullscreen( true, "desktop" )

	end
			
	if not success then
		console:print("Failed to toggle fullscreen mode!")
	end
	paused = false
end
