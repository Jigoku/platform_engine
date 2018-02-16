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
 
entities = {}

require("entities/platforms")
require("entities/materials")
require("entities/props")
require("entities/decals")
require("entities/springs")
require("entities/traps")
require("entities/crates")
require("entities/enemies")
require("entities/checkpoints")
require("entities/pickups")
require("entities/bumpers")
require("entities/portals")


--find item in table containing "name"
--return found items as table
--
--   eg; test[1].name = "blah"
--   #entities.match(test,"blah") = 1

function entities.match(t,name)
	local match = {}
	for i=1,#t do
		if t[i].name == name then
			table.insert(match,t[i])
		end
	end
	return match
end

return entities
