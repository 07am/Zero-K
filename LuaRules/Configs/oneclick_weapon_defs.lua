-- reloadTime is in seconds

local oneClickWepDefs = {}

local oneClickWepDefNames = {
	corcrw = {
		{ functionToCall = "ClusterBomb", reloadTime = 854, name = "Carpet Bomb", tooltip = "Drop a huge number of bombs in a circle under the Krow", weaponToReload = 3,},
	},
	fighter = {
		{ functionToCall = "Sprint", reloadTime = 850, name = "Speed Boost", tooltip = "Speed Boost", useSpecialReloadFrame = true, weaponToReload = 3,},
	},
}


for name, data in pairs(oneClickWepDefNames) do
	if UnitDefNames[name] then oneClickWepDefs[UnitDefNames[name].id] = data	end
end

return oneClickWepDefs