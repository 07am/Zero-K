function gadget:GetInfo()
	return {
		name    = "Command Raw Move",
		desc    = "Make unit move ahead at all cost!",
		author  = "xponen, GoogleFrog",
		date    = "June 12 2014",
		license = "GNU GPL, v2 or later",
		layer   = 0,
		enabled = true,
	}
end
include("LuaRules/Configs/customcmds.h.lua")

if gadgetHandler:IsSyncedCode() then

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Speedups

local spGetUnitPosition   = Spring.GetUnitPosition
local spInsertUnitCmdDesc = Spring.InsertUnitCmdDesc
local spMoveCtrlGetTag    = Spring.MoveCtrl.GetTag
local spGetCommandQueue   = Spring.GetCommandQueue
local spGiveOrderToUnit   = Spring.GiveOrderToUnit
local spGetUnitCurrentCommand = Spring.GetUnitCurrentCommand

local mapSizeX = Game.mapSizeX
local mapSizeZ = Game.mapSizeZ

local CMD_STOP    = CMD.STOP
local CMD_INSERT  = CMD.INSERT
local CMD_REMOVE  = CMD.REMOVE
local CMD_REPAIR  = CMD.REPAIR
local CMD_RECLAIM = CMD.RECLAIM
local CMD_MOVE    = CMD.MOVE

local CMD_OPT_ALT = CMD.OPT_ALT

local MAX_UNITS = Game.maxUnits

local rawBuildUpdateIgnore = include("LuaRules/Configs/state_commands.lua")

local stopCommand = {
	[CMD.GUARD] = true,
	[CMD.REPAIR] = true,
	[CMD.RECLAIM] = true,
	[CMD.RESURRECT] = true,
	[CMD_JUMP] = true,
	[CMD.PATROL] = true,
	[CMD.FIGHT] = true,
	[CMD.MOVE] = true,
}

local queueFrontCommand = {
	[CMD.WAIT] = true,
	[CMD.TIMEWAIT] = true,
	[CMD.DEATHWAIT] = true,
	[CMD.SQUADWAIT] = true,
	[CMD.GATHERWAIT] = true,
}

local canMoveDefs = {}
local canFlyDefs = {}
local goalDist = {}
local turnDiameterSq = {}
local turnPeriods = {}
local stopDistSq = {}
local loneStopDistSq = {}
local stoppingRadiusIncrease = {}
local stuckTravelOverride = {}
local startMovingTime = {}

local constructorBuildDistDefs = {}

-- Check unit queues because perhaps CMD_RAW_MOVE is not the first command anymore
local unitQueueCheckRequired = false
local unitQueuesToCheck = {}

for i = 1, #UnitDefs do
	local ud = UnitDefs[i]
	if ud.canMove then
		if ud.isMobileBuilder and (not ud.isAirUnit) then
			constructorBuildDistDefs[i] = math.max(50, ud.buildDistance  - 10)
		end

		canMoveDefs[i] = true
		local stopDist = ud.xsize*8
		local loneStopDist = 16
		local turningDiameter = 2*(ud.speed*2195/(ud.turnRate * 2 * math.pi))
		if turningDiameter > 20 then
			turnDiameterSq[i] = turningDiameter*turningDiameter
		end
		if ud.turnRate > 150 then
			turnPeriods[i] = math.ceil(1100/ud.turnRate)
		else
			turnPeriods[i] = 8
		end
		if (ud.moveDef.maxSlope or 0) > 0.8 and ud.speed < 60 then
			-- Slow spiders need a lot of leeway when climing cliffs.
			stuckTravelOverride[i] = 5
			startMovingTime[i] = 12 -- May take longer to start moving
			-- Lower stopping distance for more precise placement on terrain
			loneStopDist = 4
		end
		if ud.customParams.unstick_leeway then
			startMovingTime[i] = tonumber(ud.customParams.unstick_leeway)
		end
		if ud.canFly then
			canFlyDefs[i] = true
			stopDist = ud.speed
			loneStopDist = ud.speed*0.66
			if ud.isHoveringAirUnit then
				stopDist = math.min(stopDist, 120)
				loneStopDist = math.min(loneStopDist, 80)
			end
			goalDist[i] = 8
		end
		if stopDist then
			stopDistSq[i] = stopDist*stopDist
		end
		loneStopDistSq[i] = (loneStopDist and loneStopDist*loneStopDist) or stopDistSq[i] or 256
		if stopDist and not goalDist[i] then
			goalDist[i] = loneStopDist
		end
		stoppingRadiusIncrease[i] = ud.xsize*260*(1 + math.max(0, (ud.xsize - 4)*0.15))
	end
end

-- Debug
--local oldSetMoveGoal = Spring.SetUnitMoveGoal
--function Spring.SetUnitMoveGoal(unitID, x, y, z, radius, speed, raw)
--	oldSetMoveGoal(unitID, x, y, z, radius, speed, raw)
--	Spring.MarkerAddPoint(x, y, z, ((raw and "r") or "") .. (radius or 0))
--end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Configuration

local moveRawCmdDesc = {
	id      = CMD_RAW_MOVE,
	type    = CMDTYPE.ICON_MAP,
	name    = 'Move',
	cursor  = 'Move', -- add with LuaUI?
	action  = 'rawmove',
	tooltip = 'Move: Move to a position. Click and drag to line move.',
}

local TEST_MOVE_SPACING = 16
local LAZY_SEARCH_DISTANCE = 450
local BLOCK_RELAX_DISTANCE = 250
local STUCK_TRAVEL = 25
local STUCK_MOVE_RANGE = 140
local GIVE_UP_STUCK_DIST_SQ = 250^2
local STOP_STOPPING_RADIUS = 10000000
local RAW_CHECK_SPACING = 500
local MAX_COMM_STOP_RADIUS = 400^2
local COMMON_STOP_RADIUS_ACTIVE_DIST_SQ = 120^2 -- Commands shorter than this do not activate common stop radius.

local CONSTRUCTOR_UPDATE_RATE = 30
local CONSTRUCTOR_TIMEOUT_RATE = 2

local STOPPING_HAX = not Spring.Utilities.IsCurrentVersionNewerThan(104, 271)

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Variables

local rawMoveUnit = {}
local commonStopRadius = {}
local oldCommandStoppingRadius = {}
local commandCount = {}
local oldCommandCount = {}
local fromFactoryReplaceSkip = {}
local engineMoveAppeared = {}
local fromFactoryID = {}

local constructors = {}
local constructorBuildDist = {}
local constructorByID = {}
local constructorCount = 0
local constructorsPerFrame = 0
local constructorIndex = 1
local alreadyResetConstructors = false

local checkEngineMove
local moveCommandReplacementUnits
local fastConstructorUpdate

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Utilities

local function IsPathFree(unitDefID, sX, sZ, gX, gZ, distance, testSpacing, distanceLimit, goalDistance, blockRelaxDistance)
	local vX = gX - sX
	local vZ = gZ - sZ
	-- distance had better be math.sqrt(vX*vX + vZ*vZ) or things will break
	if distance < testSpacing then
		return true
	end
	vX, vZ = vX/distance, vZ/distance
	local orginDistance = distance
	if goalDistance then
		distance = distance - goalDistance
	end

	if distanceLimit and (distance > distanceLimit) then
		if blockRelaxDistance then
			blockRelaxDistance = blockRelaxDistance - distance + distanceLimit
			if blockRelaxDistance < testSpacing then
				blockRelaxDistance = false
			end
		end
		distance = distanceLimit
	end

	local blockedDistance = false
	for test = 0, distance, testSpacing do
		if not Spring.TestMoveOrder(unitDefID, sX + test*vX, 0, sZ + test*vZ) then
			blockedDistance = test
			break
		end
	end
	
	
	if (not blockedDistance) or (not blockRelaxDistance) or (blockedDistance == 0) or ((distance - blockedDistance) > blockRelaxDistance) then
		return (not blockedDistance)
	end
	
	-- Don't take goalDistance into account when stopping early due to blockage.
	distance = orginDistance
	local relaxX, relaxZ
	for test = distance, blockedDistance - testSpacing, -testSpacing do
		if Spring.TestMoveOrder(unitDefID, sX + test*vX, 0, sZ + test*vZ) then
			if not relaxX then
				relaxX, relaxZ = sX + test*vX, sZ + test*vZ
			end
		elseif relaxX then
			return false, relaxX, relaxZ
		end
	end
	
	return true, relaxX, relaxZ
end

local function ResetUnitData(unitData)
	unitData.cx = nil
	unitData.cz = nil
	unitData.mx = nil
	unitData.mz = nil
	unitData.switchedFromRaw = nil
	unitData.nextTestTime = nil
	unitData.commandHandled = nil
	unitData.stuckCheckTimer = nil
	unitData.handlingWaitTime = nil
	unitData.nextRawCheckDistSq = nil
	unitData.doingRawMove = nil
	unitData.possiblyTurning = nil
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Raw Move Handling

local function StopRawMoveUnit(unitID, stopNonRaw)
	if not rawMoveUnit[unitID] then
		return
	end
	if stopNonRaw or not rawMoveUnit[unitID].switchedFromRaw then
		if STOPPING_HAX then
			local x, y, z = spGetUnitPosition(unitID)
			Spring.SetUnitMoveGoal(unitID, x, y, z, STOP_STOPPING_RADIUS)
		else
			Spring.ClearUnitGoal(unitID)
		end
	end
	rawMoveUnit[unitID] = nil
	--Spring.Echo("StopRawMoveUnit", math.random())
end

local function HandleRawMove(unitID, unitDefID, cmdParams)
	if spMoveCtrlGetTag(unitID) then
		--Spring.Echo("ret 10")
		return true, false
	end

	if #cmdParams < 3 then
		--Spring.Echo("ret 9")
		return true, true
	end

	local mx, my, mz = cmdParams[1], cmdParams[2], cmdParams[3]
	if mx < 0 or mx >= mapSizeX or mz < 0 or mz >= mapSizeZ then
		mx = math.max(0, math.min(mx, mapSizeX))
		mz = math.max(0, math.min(mz, mapSizeZ))
	end

	local goalDistOverride = cmdParams[4]
	local timerIncrement = cmdParams[5] or 1
	if not rawMoveUnit[unitID] then
		rawMoveUnit[unitID] = {}
	end
	local unitData = rawMoveUnit[unitID]
	if not (unitData.cx == mx and unitData.cz == mz) then
		ResetUnitData(unitData)
	end
	if unitData.handlingWaitTime then
		unitData.handlingWaitTime = unitData.handlingWaitTime - timerIncrement
		if unitData.handlingWaitTime <= 0 then
			unitData.handlingWaitTime = nil
		end
		--Spring.Echo("ret 8")
		return true, false
	end

	local x, y, z = spGetUnitPosition(unitID)
	local distSq = (x - (unitData.mx or mx))^2 + (z - (unitData.mz or mz))^2

	if not unitData.cx then
		unitData.cx, unitData.cz = mx, mz
		unitData.commandString = mx .. "_" .. mz
		commandCount[unitData.commandString] = (commandCount[unitData.commandString] or 0) + 1
		unitData.preventGoalClumping = (not goalDistOverride) and (distSq > COMMON_STOP_RADIUS_ACTIVE_DIST_SQ) and not Spring.Utilities.GetUnitRepeat(unitID)
	end
	if unitData.preventGoalClumping and unitData.commandString and not commonStopRadius[unitData.commandString] then
		commonStopRadius[unitData.commandString] = oldCommandStoppingRadius[unitData.commandString] or 0
	end
	if unitData.commandString and not commandCount[unitData.commandString] then
		commandCount[unitData.commandString] = oldCommandCount[unitData.commandString] or 1
	end

	local alone = (commandCount[unitData.commandString] <= 1)
	local myStopDistSq = (goalDistOverride and goalDistOverride*goalDistOverride) or (alone and loneStopDistSq[unitDefID]) or stopDistSq[unitDefID] or 256
	if unitData.preventGoalClumping then
		myStopDistSq = myStopDistSq + commonStopRadius[unitData.commandString]
	end

	if distSq < myStopDistSq then
		if unitData.preventGoalClumping then
			commonStopRadius[unitData.commandString] = (commonStopRadius[unitData.commandString] or 0) + stoppingRadiusIncrease[unitDefID]
			if commonStopRadius[unitData.commandString] > MAX_COMM_STOP_RADIUS then
				commonStopRadius[unitData.commandString] = MAX_COMM_STOP_RADIUS
			end
		end
		StopRawMoveUnit(unitID, true)
		--Spring.Echo("ret 7")
		return true, true
	end

	if canFlyDefs[unitDefID] then
		if unitData.commandHandled then
			--Spring.Echo("ret 6")
			return true, false
		end
		unitData.switchedFromRaw = true
		unitData.commandHandled = true
		Spring.SetUnitMoveGoal(unitID, mx, my, mz, goalDistOverride or goalDist[unitDefID] or 16, nil, false)
		--Spring.Echo("ret 5")
		return true, false
	end

	if not unitData.stuckCheckTimer then
		unitData.ux, unitData.uz = x, z
		unitData.stuckCheckTimer = (startMovingTime[unitDefID] or 8)
		if distSq > GIVE_UP_STUCK_DIST_SQ then
			unitData.stuckCheckTimer = unitData.stuckCheckTimer + math.floor(math.random()*8)
		end
	end
	unitData.stuckCheckTimer = unitData.stuckCheckTimer - timerIncrement

	if unitData.stuckCheckTimer <= 0 then
		local oldX, oldZ = unitData.ux, unitData.uz
		local travelled = math.abs(oldX - x) + math.abs(oldZ - z)
		unitData.ux, unitData.uz = x, z
		if travelled < (stuckTravelOverride[unitDefID] or STUCK_TRAVEL) then
			unitData.stuckCheckTimer = math.floor(math.random()*6) + 5
			if not GG.floatUnit[unitID] then
				if distSq < GIVE_UP_STUCK_DIST_SQ then
					StopRawMoveUnit(unitID, true)
					--Spring.Echo("ret 4")
					return true, true
				else
					local vx = math.random()*2*STUCK_MOVE_RANGE - STUCK_MOVE_RANGE
					local vz = math.random()*2*STUCK_MOVE_RANGE - STUCK_MOVE_RANGE
					Spring.SetUnitMoveGoal(unitID, x + vx, y, z + vz, 16, nil, false)
					unitData.commandHandled = nil
					unitData.switchedFromRaw = nil
					unitData.nextTestTime = nil
					unitData.doingRawMove = nil
					unitData.handlingWaitTime = math.floor(math.random()*4) + 2
					--Spring.Echo("ret 4")
					return true, false
				end
			end
		else
			unitData.stuckCheckTimer = 4 + math.min(6, math.floor(distSq/500))
			if distSq > GIVE_UP_STUCK_DIST_SQ then
				unitData.stuckCheckTimer = unitData.stuckCheckTimer + math.floor(math.random()*10)
			end
		end
	end

	if unitData and unitData.switchedFromRaw then
		if unitData.nextRawCheckDistSq and (unitData.nextRawCheckDistSq > distSq) then
			unitData.switchedFromRaw = nil
			unitData.nextTestTime = nil
		else
			--Spring.Echo("ret 2")
			return true, false
		end
	end

	unitData.nextTestTime = (unitData.nextTestTime or 0) - timerIncrement
	if unitData.nextTestTime <= 0 then
		local lazy = unitData.doingRawMove
		local freePath
		if (turnDiameterSq[unitDefID] or 0) > distSq then
			freePath = false
		else
			local distance = math.sqrt(distSq)
			local rx, rz
			freePath, rx, rz = IsPathFree(unitDefID, x, z, mx, mz, distance, TEST_MOVE_SPACING, lazy and LAZY_SEARCH_DISTANCE, goalDistOverride and (goalDistOverride - 20), BLOCK_RELAX_DISTANCE)
			if rx then
				mx, my, mz = rx, Spring.GetGroundHeight(rx, rz), rz
			end
			if (not freePath) then
				unitData.nextRawCheckDistSq = (distance - RAW_CHECK_SPACING)*(distance - RAW_CHECK_SPACING)
			end
		end
		if (not unitData.commandHandled) or unitData.doingRawMove ~= freePath then
			Spring.SetUnitMoveGoal(unitID, mx, my, mz, goalDist[unitDefID] or 16, nil, freePath)
			unitData.mx, unitData.mz = mx, mz
			unitData.nextTestTime = math.floor(math.random()*2) + turnPeriods[unitDefID]
			unitData.possiblyTurning = true
		elseif unitData.possiblyTurning then
			unitData.nextTestTime = math.floor(math.random()*2) + turnPeriods[unitDefID]
			unitData.possiblyTurning = false
		else
			unitData.nextTestTime = math.floor(math.random()*5) + 6
		end

		unitData.doingRawMove = freePath
		unitData.switchedFromRaw = not freePath
	end

	if not unitData.commandHandled then
		unitData.commandHandled = true
	end
	--Spring.Echo("ret 1")
	return true, false
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Command Handling

function gadget:CommandFallback(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions) -- Only calls for custom commands
	if not (cmdID == CMD_RAW_MOVE or cmdID == CMD_RAW_BUILD) then
		return false
	end
	local cmdUsed, cmdRemove = HandleRawMove(unitID, unitDefID, cmdParams)
	return cmdUsed, cmdRemove
end

local function CheckUnitQueues()
	for unitID,_ in pairs(unitQueuesToCheck) do
		if spGetUnitCurrentCommand(unitID) ~= CMD_RAW_MOVE then
			StopRawMoveUnit(unitID)
		end
		unitQueuesToCheck[unitID] = nil
	end
end

function gadget:UnitCmdDone(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions, cmdTag)
	if cmdID == CMD_STOP then
		-- Handling for shift clicking on commands to remove.
		StopRawMoveUnit(unitID)
	end
end

function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions)
	if cmdID == CMD_MOVE and not canFlyDefs[unitDefID] then
		moveCommandReplacementUnits = moveCommandReplacementUnits or {}
		moveCommandReplacementUnits[#moveCommandReplacementUnits + 1] = unitID
		engineMoveAppeared[unitID] = Spring.GetGameFrame()
	end

	if constructorBuildDistDefs[unitDefID] and not rawBuildUpdateIgnore[cmdID] then
		fastConstructorUpdate = fastConstructorUpdate or {}
		fastConstructorUpdate[#fastConstructorUpdate + 1] = unitID
		--Spring.Utilities.UnitEcho(unitID, cmdID)
	end

	if canMoveDefs[unitDefID] then
		if cmdID == CMD_STOP or ((not cmdOptions.shift) and (cmdID < 0 or stopCommand[cmdID])) then
			StopRawMoveUnit(unitID)
		elseif cmdID == CMD_INSERT and (cmdParams[1] == 0 or not cmdOptions.alt) then
			StopRawMoveUnit(unitID)
		elseif queueFrontCommand[cmdID] then
			unitQueueCheckRequired = true
			unitQueuesToCheck[unitID] = true
		end
	else
		if cmdID == CMD_INSERT then
			cmdID = cmdParams[2]
		end
		if cmdID == CMD_RAW_MOVE then
			return false
		end
	end
	return true
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Constructor Handling

local function GetConstructorCommandPos(cmdID, cp_1, cp_2, cp_3, cp_4, cp_5, cp_6, unitID)
	local _
	if cmdID == CMD_RAW_BUILD then
		cmdID, _, _, cp_1, cp_2, cp_3, cp_4, cp_5, cp_6 = spGetUnitCurrentCommand(unitID, 2)
	end
	if not cmdID then
		return false
	end

	if cmdID < 0 then
		return cp_1, cp_2, cp_3
	end

	if cmdID == CMD_REPAIR then
		-- (#cmd.params == 5 or #cmd.params == 1)
		if (cp_1 and not cp_2) or (cp_5 and not cp_6) then
			local targetUnitID = cp_1
			local unitDefID = Spring.GetUnitDefID(targetUnitID)
			if unitDefID and not canMoveDefs[unitDefID] then
				-- Don't try to chase moving units with raw move.
				local x, y, z = Spring.GetUnitPosition(targetUnitID)
				if x then
					return x, y, z
				end
			end
		end
	end

	if cmdID == CMD_RECLAIM then
		-- (#cmd.params == 5 or #cmd.params == 1)
		if (cp_1 and not cp_2) or (cp_5 and not cp_6) then
			local x, y, z = Spring.GetFeaturePosition(cp_1 - MAX_UNITS)
			if x then
				return x, y, z
			end
		end
	end
end

local function CheckConstructorBuild(unitID)
	local buildDist = constructorBuildDist[unitID]
	if not buildDist then
		return
	end
	
	local cmdID, _, cmdTag, cp_1, cp_2, cp_3, cp_4, cp_5, cp_6 = spGetUnitCurrentCommand(unitID)
	local cx, cy, cz = GetConstructorCommandPos(cmdID, cp_1, cp_2, cp_3, cp_4, cp_5, cp_6, unitID)

	if cmdID == CMD_RAW_BUILD and cp_3 then
		if (not cx) or math.abs(cx - cp_1) > 3 or math.abs(cz - cp_3) > 3 then
			spGiveOrderToUnit(unitID, CMD_REMOVE, cmdTag, 0)
			StopRawMoveUnit(unitID, true)
		end
		return
	end

	if cx then
		local x,_,z = Spring.GetUnitPosition(unitID)
		local buildDistSq = (buildDist + 30)^2
		local distSq = (cx - x)^2 + (cz - z)^2
		if distSq > buildDistSq then
			spGiveOrderToUnit(unitID, CMD_INSERT, {0, CMD_RAW_BUILD, 0, cx, cy, cz, buildDist, CONSTRUCTOR_TIMEOUT_RATE}, CMD_OPT_ALT)
		end
	end
end

local function AddConstructor(unitID, buildDist)
	if not constructorByID[unitID] then
		constructorCount = constructorCount + 1
		constructors[constructorCount] = unitID
		constructorByID[unitID] = constructorCount
	end
	constructorBuildDist[unitID] = buildDist
	constructorsPerFrame = math.ceil(constructorCount/CONSTRUCTOR_UPDATE_RATE)
end

local function ResetConstructors()
	if alreadyResetConstructors then
		Spring.Echo("LUA_ERRRUN", "ResetConstructors already reset")
		return
	end
	
	alreadyResetConstructors = true
	Spring.Echo("LUA_ERRRUN", "ResetConstructors", constructorCount, constructorsPerFrame, constructorIndex)
	Spring.Utilities.TableEcho(constructorBuildDist, "constructorBuildDist")
	Spring.Utilities.TableEcho(constructorByID, "constructorByID")
	
	constructors = {}
	constructorBuildDist = {}
	constructorByID = {}
	constructorCount = 0
	constructorsPerFrame = 0
	constructorIndex = 1
	
	for _, unitID in pairs(Spring.GetAllUnits()) do
		if constructorBuildDistDefs[unitDefID] then
			AddConstructor(unitID, constructorBuildDistDefs[unitDefID])
		end
	end
end

local function RemoveConstructor(unitID)
	if not constructorByID[unitID] then
		return
	end
	
	if not constructors[constructorCount] then
		ResetConstructors()
		return
	end
	
	local index = constructorByID[unitID]

	constructors[index] = constructors[constructorCount]
	constructorBuildDist[unitID] = nil
	constructorByID[constructors[constructorCount] ] = index
	constructorByID[unitID] = nil
	constructors[constructorCount] = nil
	constructorCount = constructorCount - 1

	constructorsPerFrame = math.ceil(constructorCount/CONSTRUCTOR_UPDATE_RATE)
end

local function UpdateConstructors(n)
	if n%CONSTRUCTOR_UPDATE_RATE == 0 then
		constructorIndex = 1
	end

	local fastUpdates
	if fastConstructorUpdate then
		fastUpdates = {}
		for i = 1, #fastConstructorUpdate do
			local unitID = fastConstructorUpdate[i]
			if not fastUpdates[unitID] then
				fastUpdates[unitID] = true
				CheckConstructorBuild(unitID)
			end
		end
		fastConstructorUpdate = nil
	end

	local count = 0
	while constructors[constructorIndex] and count < constructorsPerFrame do
		if not (fastUpdates and fastUpdates[unitID]) then
			CheckConstructorBuild(constructors[constructorIndex])
		end
		constructorIndex = constructorIndex + 1
		count = count + 1
	end
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Move replacement

local function ReplaceMoveCommand(unitID)
	local cmdID, _, cmdTag, cmdParam_1, cmdParam_2, cmdParam_3 = spGetUnitCurrentCommand(unitID)
	if cmdID == CMD_MOVE and cmdParam_3 then
		if fromFactoryReplaceSkip[unitID] then
			fromFactoryReplaceSkip[unitID] = nil
		else
			spGiveOrderToUnit(unitID, CMD_INSERT, {0, CMD_RAW_MOVE, 0, cmdParam_1, cmdParam_2, cmdParam_3}, CMD_OPT_ALT)
		end
		spGiveOrderToUnit(unitID, CMD_REMOVE, cmdTag, 0)
	end
end

local function UpdateMoveReplacement()
	if not moveCommandReplacementUnits then
		return
	end

	local fastUpdates = {}
	for i = 1, #moveCommandReplacementUnits do
		local unitID = moveCommandReplacementUnits[i]
		if not fastUpdates[unitID] then
			fastUpdates[unitID] = true
			ReplaceMoveCommand(unitID)
		end
	end
	moveCommandReplacementUnits = nil
end

local function DoFactoryWaypointManually(unitID)
	local cQueue = spGetCommandQueue(unitID, -1)
	local foundRightOpts = false
	for i = 1, #cQueue do
		if cQueue[i].id ~= CMD_MOVE then
			return
		end
		if cQueue[i].options.coded == 8 then
			foundRightOpts = true
		end
	end
	if not foundRightOpts then
		return
	end
	local facID = fromFactoryID[unitID]
	if not Spring.ValidUnitID(facID) then
		return
	end
	local factoryQueue = spGetCommandQueue(facID, -1)
	local orderArray = {}
	for i = 1, #factoryQueue do
		orderArray[i] = {
			factoryQueue[i].id,
			factoryQueue[i].params,
			factoryQueue[i].options.coded
		}
	end
	Spring.GiveOrderArrayToUnitArray({unitID}, orderArray)
end

local function UpdateEngineMoveCheck(frame)
	-- Maybe this could be done one frame earlier, but I've already written it this
	-- way and I don't want to unrewrite it if gadget:UnitFromFactory has recursion.
	-- See https://github.com/ZeroK-RTS/Zero-K/issues/4317 for a test case.
	if not checkEngineMove then
		return
	end

	for i = 1, #checkEngineMove do
		local unitID = checkEngineMove[i]
		if engineMoveAppeared[unitID] ~= frame - 1 then
			DoFactoryWaypointManually(unitID)
		end
		fromFactoryID[unitID] = nil
	end
	checkEngineMove = nil
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Gadget Interface

local function WaitWaitMoveUnit(unitID)
	local unitData = unitID and rawMoveUnit[unitID]
	if unitData then
		ResetUnitData(unitData)
	end
	Spring.GiveOrderToUnit(unitID, CMD.WAIT, 0, 0)
	Spring.GiveOrderToUnit(unitID, CMD.WAIT, 0, 0)
end

local function AddRawMoveUnit(unitID)
	rawMoveUnit[unitID] = true
end

local function RawMove_IsPathFree(unitDefID, sX, sZ, gX, gZ)
	local vX = gX - sX
	local vZ = gZ - sZ
	return IsPathFree(unitDefID, sX, sZ, gX, gZ, math.sqrt(vX*vX + vZ*vZ), TEST_MOVE_SPACING)
end

function gadget:UnitFromFactory(unitID, unitDefID, unitTeam, facID, facDefID)
	fromFactoryReplaceSkip[unitID] = true
	fromFactoryID[unitID] = facID
	checkEngineMove = checkEngineMove or {}
	checkEngineMove[#checkEngineMove + 1] = unitID
end

function gadget:Initialize()
	gadgetHandler:RegisterCMDID(CMD_RAW_MOVE)
	for _, unitID in pairs(Spring.GetAllUnits()) do
		gadget:UnitCreated(unitID, Spring.GetUnitDefID(unitID))
	end

	GG.AddRawMoveUnit = AddRawMoveUnit
	GG.StopRawMoveUnit = StopRawMoveUnit
	GG.RawMove_IsPathFree = RawMove_IsPathFree
	GG.WaitWaitMoveUnit = WaitWaitMoveUnit
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
	if (canMoveDefs[unitDefID]) then
		spInsertUnitCmdDesc(unitID, moveRawCmdDesc)
	end
	if constructorBuildDistDefs[unitDefID] and not constructorByID[unitID] then
		AddConstructor(unitID, constructorBuildDistDefs[unitDefID])
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	if unitID then
		rawMoveUnit[unitID] = nil
		if unitDefID and constructorBuildDistDefs[unitDefID] and constructorByID[unitID] then
			RemoveConstructor(unitID)
		end
	end
end

local needGlobalWaitWait = false
function gadget:GameFrame(n)
	if needGlobalWaitWait then
		for _, unitID in ipairs(Spring.GetAllUnits()) do
			WaitWaitMoveUnit(unitID)
		end
		needGlobalWaitWait = false
	end
	UpdateConstructors(n)
	UpdateMoveReplacement()
	UpdateEngineMoveCheck(n)
	if n%247 == 4 then
		oldCommandStoppingRadius = commonStopRadius
		commonStopRadius = {}

		oldCommandCount = commandCount
		commandCount = {}
		
		if alreadyResetConstructors then
			alreadyResetConstructors = false
		end
	end
	if unitQueueCheckRequired then
		CheckUnitQueues()
		unitQueueCheckRequired = false
	end
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
else --UNSYNCED--
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------


function gadget:DefaultCommand(targetType, targetID)
	if not targetID then
		return CMD_RAW_MOVE
	end
end

function gadget:Initialize()
	--Note: IMO we must *allow* LUAUI to draw this command. We already used to seeing skirm command, and it is informative to players.
	--Also, its informative to widget coder and allow player to decide when to manually micro units (like seeing unit stuck on cliff with jink command)
	gadgetHandler:RegisterCMDID(CMD_RAW_MOVE)
	Spring.SetCustomCommandDrawData(CMD_RAW_MOVE, "RawMove", {0.5, 1.0, 0.5, 0.7}) -- "" mean there's no MOVE cursor if the command is drawn.
	Spring.AssignMouseCursor("RawMove", "cursormove", true, true)
end

end
