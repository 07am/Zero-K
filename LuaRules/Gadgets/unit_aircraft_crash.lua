function gadget:GetInfo()
  return {
    name      = "Aircraft Crashing",
    desc      = "Handles crashing planes",
    author    = "KingRaptor",
    date      = "22 Jan 2011",
    license   = "GNU LGPL, v2.1 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
  }
end
--Revision 3
--------------------------------------------------------------------------------
-- speedups
--------------------------------------------------------------------------------
local spGetUnitIsStunned	= Spring.GetUnitIsStunned
local spGetUnitHealth		= Spring.GetUnitHealth

local aircraftDefIDs = {}

function gadget:Initialize()
	for i=1,#UnitDefs do
		if UnitDefs[i].canFly then
			aircraftDefIDs[i] = UnitDefs[i].health
		end
	end
end

local DAMAGE_MEMORY = 60	-- gameframes

if (gadgetHandler:IsSyncedCode()) then
--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
local recentDamage = {}	-- indexed by unitID
local gameFrame = 0

function gadget:GameFrame(n)
	gameFrame = n
	if n%16 == 0 then
		for unitID, damList in pairs(recentDamage) do
			for frame in pairs(damList) do
				if frame + DAMAGE_MEMORY < n then
					damList[frame] = nil
				end
			end
		end
	end
end

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, attackerID, attackerDefID, attackerTeam)
	if (not recentDamage[unitID]) or select(3, spGetUnitIsStunned(unitID)) then return end
	--Spring.Echo("Plane damaged")
	recentDamage[unitID][gameFrame] = (recentDamage[unitID][gameFrame] or 0) + damage
	
	if spGetUnitHealth(unitID) < 0 then
		--Spring.Echo("Plane shot down")
		local rDam = 0
		for frame, damage in pairs(recentDamage[unitID] or {}) do
			rDam = rDam + damage
		end
		local maxHealth = aircraftDefIDs[unitDefID]
		local severity = rDam/maxHealth
		if severity < 0.5 then
			Spring.SetUnitCrashing(unitID, true)
			Spring.SetUnitNoSelect(unitID, true)
			-- note that we let the unit keep its airlos
			Spring.SetUnitSensorRadius(unitID, "los", 0)
			Spring.SetUnitSensorRadius(unitID, "radar", 0)
			Spring.SetUnitSensorRadius(unitID, "sonar", 0)
		end	
		recentDamage[unitID] = nil	-- no longer need to track this plane
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	recentDamage[unitID] = nil
end

function gadget:UnitFinished(unitID, unitDefID, unitTeam)
	if (not aircraftDefIDs[unitDefID]) or select(3, spGetUnitIsStunned(unitID)) then return end
	recentDamage[unitID] = {}
end


else
--------------------------------------------------------------------------------
-- UNSYNCED
--------------------------------------------------------------------------------


end
