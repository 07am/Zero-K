
function gadget:GetInfo()
  return {
    name      = "Float Toggle",
    desc      = "Adds a float/sink toggle to units, currently static while floating",
    author    = "Google Frog",
    date      = "9 March 2012",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
  }
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

if (not gadgetHandler:IsSyncedCode()) then
    return
end

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Commands

local DEFAULT_FLOAT = 1

include("LuaRules/Configs/customcmds.h.lua")

local unitFloatIdleBehaviour = {
	id      = CMD_UNIT_FLOAT_STATE,
	type    = CMDTYPE.ICON_MODE,
	name    = 'Float State',
	action  = 'floatstate',
	tooltip	= '\255\90\255\90Green\255\255\255\255:Always float \n\255\90\90\90Grey\255\255\255\255:Float to fire\n\255\255\90\90Red\255\255\255\255:Never float',
	params 	= {DEFAULT_FLOAT, 'Sink','Attack','Float'}
}

local FLOAT_NEVER = 0
local FLOAT_ATTACK = 1
local FLOAT_ALWAYS = 2

-------------------------------------------------------------------------------------
-- Config

local sinkCommand = {
	[CMD.MOVE] = true,
	[CMD.GUARD] = true,
	[CMD.FIGHT] = true,
	[CMD.PATROL] = true,
	[CMD_WAIT_AT_BEACON] = true,
}

local floatDefs = include("LuaRules/Configs/float_defs.lua")

do --add weapon duration info to floatDefs
	for unitDefID, _ in pairs(floatDefs) do
		local weaponNo1 = UnitDefs[unitDefID].weapons[1] --select weapon no.1 only
		local weaponDuration = 1
		if weaponNo1 then
			local weaponDefinition = WeaponDefs[weaponNo1.weaponDef]
			if weaponDefinition.type == "MissileLauncher" or  weaponDefinition.type == "Cannon" then
				weaponDuration = weaponDefinition.salvoSize*weaponDefinition.salvoDelay*30 --how many frame weapon fire,
			elseif weaponDefinition.type == "BeamLaser" then
				if weaponDefinition.beamBurst then
					weaponDuration = weaponDefinition.salvoSize*weaponDefinition.salvoDelay*30
				else
					weaponDuration = weaponDefinition.beamtime*30 --how many frame weapon fire. second*frame-per-second
				end
			end
		end
		floatDefs[unitDefID].weaponDuration = weaponDuration --add weapon duration info to floatDefs
	end
end
--------------------------------------------------------------------------------
-- Local Vars

local float = {}
local floatByID = {data = {}, count = 0}

local floatState = {}
local aimWeapon = {}

--------------------------------------------------------------------------------
-- Communication to script

local function callScript(unitID, funcName, args)
	local func = Spring.UnitScript.GetScriptEnv(unitID)[funcName]
	if func then
		Spring.UnitScript.CallAsUnit(unitID,func, args)
	end
end
--------------------------------------------------------------------------------
-- Float Table Manipulation

local function addFloat(unitID, unitDefID)
	if not float[unitID] then
		local def = floatDefs[unitDefID]
		local x,y,z = Spring.GetUnitBasePosition(unitID)
		if y < def.depthRequirement then
			Spring.MoveCtrl.Enable(unitID)
			Spring.MoveCtrl.SetNoBlocking(unitID, true)
			local place, feature = Spring.TestBuildOrder(unitDefID, x, y ,z, 1)
			Spring.MoveCtrl.SetNoBlocking(unitID, false)
			if place == 2 then
				Spring.SetUnitRulesParam(unitID, "disable_tac_ai", 1)
				floatByID.count = floatByID.count + 1
				floatByID.data[floatByID.count] = unitID
				float[unitID] = {
					index = floatByID.count,
					surfacing = true,
					prevSurfacing = true,
					onSurface = false,
					justStarted = true,
					sinkTank = 0,
					nextSpecialDrag = 1,
					speed = def.initialRiseSpeed,
					x = x, y = y, z = z,
					unitDefID = unitDefID,
					paraData = {want = false, para = false},
				}
				Spring.MoveCtrl.SetRotation(unitID, 0, Spring.GetUnitHeading(unitID)*2^-15*math.pi, 0)
			else
				Spring.MoveCtrl.Disable(unitID)
			end
		end
	end
end

local function removeFloat(unitID)
	float[floatByID.data[floatByID.count] ].index = float[unitID].index
	floatByID.data[float[unitID].index] = floatByID.data[floatByID.count]
	floatByID.data[floatByID.count] = nil
	float[unitID] = nil
	floatByID.count = floatByID.count - 1
end

local function setSurfaceState(unitID, unitDefID, surfacing)
	local stun = float[unitID].paraData.para or Spring.GetUnitIsStunned(unitID)
	local data = float[unitID]
	surfacing = surfacing and true --true if surfacing is not false, else false
	if not stun then
		data.surfacing = surfacing
	else
		data.paraData.want = surfacing 
		if not data.paraData.para then
			local def = floatDefs[data.unitDefID]
			if def.sinkOnPara then
				data.surfacing = false
			end
		end
		data.paraData.para = true
	end
end

function gadget:UnitLoaded(unitID, unitDefID, unitTeam, transportID, transportTeam)
	if float[unitID] then
		Spring.SetUnitRulesParam(unitID, "disable_tac_ai", 0)
		Spring.MoveCtrl.Disable(unitID)
		Spring.GiveOrderToUnit(unitID,CMD.WAIT, {}, {})
		Spring.GiveOrderToUnit(unitID,CMD.WAIT, {}, {})
		callScript(unitID, "script.StopMoving")
		removeFloat(unitID)
	end
end

--------------------------------------------------------------------------------
-- Script calls

local function checkAlwaysFloat(unitID)
	if not select(1, Spring.GetUnitIsStunned(unitID)) then
		local unitDefID = Spring.GetUnitDefID(unitID)
		local cQueue = Spring.GetCommandQueue(unitID, 1)
		local moving = cQueue and #cQueue > 0 and sinkCommand[cQueue[1].id]
		if not moving then
			addFloat(unitID, unitDefID)
		end
	end
end

function GG.Floating_StopMoving(unitID)
	if floatState[unitID] == FLOAT_ALWAYS  then
		checkAlwaysFloat(unitID)
	end
end

function GG.Floating_AimWeapon(unitID) --will be called until weapon reload
	if floatState[unitID] == FLOAT_ATTACK and not select(1, Spring.GetUnitIsStunned(unitID)) then
		local unitDefID = Spring.GetUnitDefID(unitID)
		local cQueue = Spring.GetCommandQueue(unitID, 1)
		local moving = cQueue and #cQueue > 0 and cQueue[1].id == CMD.MOVE and not cQueue[1].options.internal
		if not moving then
			addFloat(unitID, unitDefID)
		end
	end
	aimWeapon[unitID] = Spring.GetGameFrame()
end


function GG.Floating_UnitTeleported(unitID, position)
	if float[unitID] then
		local data = float[unitID]
		local def = floatDefs[data.unitDefID]
		data.x, data.y, data.z = position[1], position[2], position[3]
		--data.speed = 0.1
		local height = Spring.GetGroundHeight(data.x, data.z)
		if height <= def.depthRequirement then
			data.onSurface = false
			Spring.MoveCtrl.SetPosition(unitID, data.x, data.y, data.z)
			return true
		else
			Spring.SetUnitRulesParam(unitID, "disable_tac_ai", 0)
			callScript(unitID, "script.StopMoving")
			removeFloat(unitID)
			return false
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- Update that moves things around

function gadget:GameFrame(f)

	local checkStun = f%16 == 4
	local checkOrder = f%16 == 12

	local i = 1
	while i <= floatByID.count do
		local unitID = floatByID.data[i]

		if Spring.ValidUnitID(unitID) then
			local data = float[unitID]
			local def = floatDefs[data.unitDefID]
			
			-- This cannot be done when the float is added because that will often be
			-- the result of a unit script. Strange trigger inheritence bleh!
			if data.justStarted then
				callScript(unitID, "Float_startFromFloor")
				data.justStarted = nil
			end
			
			-- Check various paralysis conditions
			if checkStun then
				local stun
				-- Units that are paralysed cannot change state so change
				-- state when they become unstunned
				if data.paraData.para then
					stun = select(1, Spring.GetUnitIsStunned(unitID))
					if not stun then
						data.surfacing = data.paraData.want
						data.paraData.para = false
					end
				end
				-- Some units may sink when paralised, ie they require power to stay afloat.
				if def.sinkOnPara and not data.paraData.para then
					stun = stun or select(1, Spring.GetUnitIsStunned(unitID))
					if stun then
						data.paraData.want = data.surfacing 
						data.surfacing = false
						data.paraData.para = true
					end
				end
			end
			
			-- Check if the unit should sink
			if checkOrder then
				if floatState[unitID] == FLOAT_ALWAYS then
					local cQueue = Spring.GetCommandQueue(unitID, 1)
					local moving = cQueue and #cQueue > 0 and sinkCommand[cQueue[1].id]
					setSurfaceState(unitID, data.unitDefID, not moving)
				elseif floatState[unitID] == FLOAT_ATTACK then
					local cQueue = Spring.GetCommandQueue(unitID, 1)
					local moving = cQueue and #cQueue > 0 and cQueue[1].id == CMD.MOVE and not cQueue[1].options.internal
					setSurfaceState(unitID, data.unitDefID, (not moving and aimWeapon[unitID]) or false)
				elseif floatState[unitID] == FLOAT_NEVER then
					setSurfaceState(unitID, data.unitDefID, false)
				end
			end
			
			-- Animation
			if data.prevSurfacing ~= data.surfacing then
				if data.surfacing then
					callScript(unitID, "Float_rising")
				else
					callScript(unitID, "Float_sinking")
				end
				data.prevSurfacing = data.surfacing
			end
			
			-- Fill tank
			if def.sinkTankRequirement then
				if not data.surfacing then
					if data.y <= def.floatPoint and data.sinkTank <= def.sinkTankRequirement then
						data.sinkTank = data.sinkTank + 1
					end
				else
					data.sinkTank = 0
				end
			end
			
			-- Accelerate the speed
			if data.y <= def.floatPoint then
				if not data.surfacing then
					if (not def.sinkTankRequirement or data.sinkTank > def.sinkTankRequirement) then
						data.speed = (data.speed + def.sinkAccel)*(data.speed > 0 and def.sinkUpDrag or def.sinkDownDrag)*data.nextSpecialDrag
						data.onSurface = false
					else
						data.speed = data.speed*(data.speed > 0 and def.sinkUpDrag or def.sinkDownDrag)*data.nextSpecialDrag
					end
				elseif not data.onSurface then
					data.speed = (data.speed + def.riseAccel)*(data.speed > 0 and def.riseUpDrag or def.riseDownDrag)*data.nextSpecialDrag
				end
			else
				data.speed = (data.speed + def.airAccel)*def.airDrag*data.nextSpecialDrag
			end
			
			-- Speed the position
			local height = Spring.GetGroundHeight(data.x, data.z)
			if data.speed ~= 0 or data.y <= height or not data.onSurface then
				
				data.nextSpecialDrag = 1
				-- Splash animation and slowdown
				if not data.onSurface then
					local waterline = data.y - def.floatPoint
					-- enter water
					if data.speed < 0 and waterline > 0 and waterline < -data.speed then
						callScript(unitID, "Float_crossWaterline", {data.speed})
						data.nextSpecialDrag = data.nextSpecialDrag*def.waterHitDrag
					end
					
					--leave water
					if data.speed > 0 and waterline < 0 and -waterline < data.speed then
						callScript(unitID, "Float_crossWaterline", {data.speed})
					end
				end
				
				data.y = data.y + data.speed
				
				if data.y > height then
					if data.surfacing and def.stopSpeedLeeway > math.abs(data.speed) and def.stopPositionLeeway > math.abs(data.y - def.floatPoint) then
						data.speed = 0
						data.y = def.floatPoint
						if not data.onSurface then
							callScript(unitID, "Float_stationaryOnSurface")
							data.onSurface = true
						end
					end
					Spring.MoveCtrl.SetPosition(unitID, data.x, data.y, data.z)
				else
					Spring.SetUnitRulesParam(unitID, "disable_tac_ai", 0)
					Spring.SetUnitPosition(unitID, data.x, height, data.z)
					Spring.MoveCtrl.Disable(unitID)
					Spring.GiveOrderToUnit(unitID,CMD.WAIT, {}, {})
					Spring.GiveOrderToUnit(unitID,CMD.WAIT, {}, {})
					callScript(unitID, "Float_stopOnFloor")
					removeFloat(unitID)
					
					i = i - 1 
				end
			end
			
			i = i + 1
		else
			removeFloat(unitID)
		end
	end
	
	if f%16 == 12 then -- repeat every 16 frame at the 12th frame
		for unitID, weaponlastfire in pairs(aimWeapon) do --iterate content of aimWeapon
			local unitDefID = float[unitID].unitDefID
			local weaponDuration = floatDefs[unitDefID].weaponDuration
			if f >= weaponlastfire + weaponDuration then --clear aimWeapon list by basing on expire date. Clear when current frame is > weapon last fire 
				aimWeapon[unitID] = nil
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Command Handling

local function FloatToggleCommand(unitID, cmdParams, cmdOptions)
	if floatState[unitID] then
		local state = cmdParams[1]
		local cmdDescID = Spring.FindUnitCmdDesc(unitID, CMD_UNIT_FLOAT_STATE)
		if cmdOptions.right then
			state = (state + 1)%3
		end
		if (cmdDescID) then
			unitFloatIdleBehaviour.params[1] = state
			Spring.EditUnitCmdDesc(unitID, cmdDescID, { params = unitFloatIdleBehaviour.params})
		end
		floatState[unitID] = state
		if state == FLOAT_ALWAYS then
			checkAlwaysFloat(unitID)
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if (cmdID ~= CMD_UNIT_FLOAT_STATE) then
		return true  -- command was not used
	end
	FloatToggleCommand(unitID, cmdParams, cmdOptions)  
	return false  -- command was used
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if floatDefs[unitDefID] then
		floatState[unitID] = DEFAULT_FLOAT
		Spring.InsertUnitCmdDesc(unitID, unitFloatIdleBehaviour)
	end
end

function gadget:Initialize()
	-- register command
	gadgetHandler:RegisterCMDID(CMD_UNIT_FLOAT_STATE)
	-- load active units
	for _, unitID in ipairs(Spring.GetAllUnits()) do
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID)
	end
end







