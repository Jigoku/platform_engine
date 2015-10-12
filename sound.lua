sound = {}

local fx = "sounds/effect/"
local mt = "sounds/music/"

-- place sound filepaths here
sound.jump = love.audio.newSource(fx .. "jump.wav", "static")
sound.gem = love.audio.newSource(fx .. "gem.wav", "static")
sound.hit = love.audio.newSource(fx .. "hit.wav", "static")
sound.beep = love.audio.newSource(fx .. "beep.wav", "static")
sound.die = love.audio.newSource(fx .. "die.wav", "static")
sound.crate = love.audio.newSource(fx .. "crate.wav", "static")
sound.lifeup = love.audio.newSource(fx .. "lifeup.wav", "static")
sound.kill = love.audio.newSource(fx .. "kill.wav", "static")
sound.checkpoint = love.audio.newSource(fx .. "checkpoint.wav", "static")

-------------
-- map music specific test
sound.music01 = love.audio.newSource(mt .. "jungle.ogg")
sound.music02 = love.audio.newSource(mt .. "underwater.ogg")
sound.music03 = love.audio.newSource(mt .. "walking.ogg")
sound.music04 = love.audio.newSource(mt .. "intense.ogg")
sound.music05 = love.audio.newSource(mt .. "busy.ogg")

--implement this in map files?
sound.music05:setLooping(true)
sound.music05:play()
-------------



function sound:play(effect)
	--improve this (temporary fix)
	if effect:isPlaying() then
		effect:stop()
	end
	effect:play()
end

function sound:decide(source)
	if source.name == "platform" then
		self:play(sound.hit)
	elseif source.name == "crate" then
		self:play(sound.crate)
	elseif source.name == "death" then
		self:play(sound.die)
	elseif source.name == "checkpoint" then
		self:play(sound.checkpoint)
	end
end
