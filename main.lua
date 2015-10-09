
require("camera")
require("sound")
require("physics")
require("collision")
require("world")
require("util")
require("structures")
require("pickups")
require("enemies")
require("player")
require("input")
require("editor")

	
debug = 0
mode = 1

math.randomseed(os.time())
function love.load()

	world:init()
	player:init()
	world:loadMap("maps/test.map")

end

function love.draw()
	world:draw()
	
	-- draw world
	if debug == 1 then
		-- debug info
		util:drawConsole()
	end
	
end

function love.update(dt)

	-- process keyboard events
	input:check(dt)
	
	world:run(dt)
	
	if debug == 1 then
		editor:run(dt)
	end
	

end

