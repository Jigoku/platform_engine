pickups = {}


function createCoin(x,y,w,h)
		table.insert(pickups, {
				x =x or 0,
				y =y or 0,
				w =w or 0,
				h =h or 0,
				name = "coin"
		})
end

function createCrate(x,y,w,h)
		table.insert(pickups, {
				x =x or 0,
				y =y or 0,
				w =w or 0,
				h =h or 0,
				name = "crate",
				destroyed = 0,
				item = "life"
		})
end

function drawPickups()
	local i, pickup
		for i, pickup in ipairs(pickups) do
			
			if pickup.name == "coin" then
				love.graphics.setColor(155,50,20, 255)	
				love.graphics.circle("fill", pickup.x, pickup.y, pickup.w, pickup.h)
				love.graphics.setColor(205,100,100,255)
				love.graphics.circle("line", pickup.x, pickup.y, pickup.w, pickup.h)
			end
			
			if pickup.name == "crate" then
				if pickup.destroyed == 0 then
					love.graphics.setColor(60,30,10,255)
					love.graphics.rectangle("fill", pickup.x, pickup.y, pickup.w, pickup.h)
					love.graphics.setColor(80,40,10,255)
					love.graphics.rectangle("line", pickup.x, pickup.y, pickup.w, pickup.h)
				end
			end
			
			if debug == 1 then
				drawCoordinates(pickup)
			end
		end
end


function countPickups()
	local count = 0
	for n in pairs(pickups) do count = count + 1 end
	return count
	
end
