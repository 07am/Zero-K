local unitArray = {}
local UPDATE_FREQUNECY = 30

local units = {

	puppy = { 
		drain = 4.25, 
		cost = 50, 
		spawns = "puppy",
		range = 120
	},
}

for unit, data in pairs(units) do
	data.drain = data.drain*UPDATE_FREQUNECY/30
end

for i=1,#UnitDefs do
	for unit, data in pairs(units) do
		if UnitDefs[i].name == unit then 
			unitArray[i] = data 
		end
	end
end

return UPDATE_FREQUNECY, unitArray