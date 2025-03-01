VFS.Include("LuaRules/Configs/customcmds.h.lua")

local configList = {
	{label = "Basic Commands"},
	{cmdID = CMD_AREA_MEX              , default = true, name = "Area Mex"},
	{cmdID = CMD.FIGHT                 , default = true, name = "Attack Move"},
	{cmdID = CMD_BUILD_PLATE           , default = true, name = "Build Plate"},
	{cmdID = CMD_EMBARK                , default = true, name = "Embark"},
	{cmdID = CMD.MANUALFIRE            , default = true, name = "Fire Special Weapon"},
	{cmdID = CMD.ATTACK                , default = true, name = "Force Fire"},
	{cmdID = CMD_JUMP                  , default = true, name = "Jump"},
	{cmdID = CMD.LOAD_UNITS            , default = true, name = "Load"},
	{cmdID = CMD_RAW_MOVE              , default = true, name = "Move"},
	{cmdID = CMD.STOP                  , default = true, name = "Stop"},
	{cmdID = CMD_STOP_PRODUCTION       , default = true, name = "Stop Production"},
	{cmdID = CMD.PATROL                , default = true, name = "Patrol"},
	{cmdID = CMD_RECALL_DRONES         , default = true, name = "Recall Drones"},
	{cmdID = CMD.RECLAIM               , default = true, name = "Reclaim"},
	{cmdID = CMD.REPAIR                , default = true, name = "Repair"},
	{cmdID = CMD_FIND_PAD              , default = true, name = "Resupply"},
	{cmdID = CMD.RESURRECT             , default = true, name = "Resurrect"},
	{cmdID = CMD.UNLOAD_UNITS          , default = true, name = "Unload"},
	
	{label = "Advanced Commands (hidden by default)"},
	{cmdID = CMD.AREA_ATTACK           , default = false, name = "Area Attack"},
	{cmdID = CMD_AREA_TERRA_MEX        , default = false, name = "Area Terra Mex"},
	{cmdID = CMD_UNIT_CANCEL_TARGET    , default = false, name = "Cancel Target"},
	{cmdID = CMD_DISEMBARK             , default = false, name = "Disembark"},
	{cmdID = CMD_EXCLUDE_PAD           , default = false, name = "Exclude Airpad"},
	{cmdID = CMD_AREA_GUARD            , default = false, name = "Guard"},
	{cmdID = CMD_UNIT_SET_TARGET_CIRCLE, default = false, name = "Set Target"},
	{cmdID = CMD.WAIT                  , default = false, name = "Wait"},
	
	{label = "Basic States"},
	{cmdID = CMD_WANT_ONOFF            , state = true, default = true, name = "Activation"},
	{cmdID = CMD.IDLEMODE              , state = true, default = true, name = "Air Idle State"},
	{cmdID = CMD_AP_FLY_STATE          , state = true, default = true, name = "Air Factory Idle State"},
	{cmdID = CMD_CLOAK_SHIELD          , state = true, default = true, name = "Area Cloaker"},
	{cmdID = CMD_PREVENT_BAIT          , state = true, default = true, name = "Avoid Bad Targets"},
	{cmdID = CMD_FACTORY_GUARD         , state = true, default = true, name = "Auto Assist"},
	{cmdID = CMD_WANT_CLOAK            , state = true, default = true, name = "Cloak"},
	{cmdID = CMD_PRIORITY              , state = true, default = true, name = "Construction Priority"},
	{cmdID = CMD_TOGGLE_DRONES         , state = true, default = true, name = "Drone Construction"},
	{cmdID = CMD_DONT_FIRE_AT_RADAR    , state = true, default = true, name = "Fire At Radar State"},
	{cmdID = CMD_FIRE_TOWARDS_ENEMY    , state = true, default = true, name = "Fire Towards Enemies"},
	{cmdID = CMD_UNIT_FLOAT_STATE      , state = true, default = true, name = "Float State"},
	{cmdID = CMD_AIR_STRAFE            , state = true, default = true, name = "Gunship Strafe"},
	{cmdID = CMD.FIRE_STATE            , state = true, default = true, name = "Hold Fire (Fire State)"},
	{cmdID = CMD.MOVE_STATE            , state = true, default = true, name = "Hold Position (Move State)"},
	{cmdID = CMD_PUSH_PULL             , state = true, default = true, name = "Impulse Mode"},
	{cmdID = CMD_MISC_PRIORITY         , state = true, default = true, name = "Misc Priority"},
	{cmdID = CMD_GOO_GATHER            , state = true, default = true, name = "Puppy Replication"},
	{cmdID = CMD.REPEAT                , state = true, default = true, name = "Repeat"},
	{cmdID = CMD_RETREAT               , state = true, default = true, name = "Retreat"},
	{cmdID = CMD_SELECTION_RANK        , state = true, default = true, name = "Selection Rank"},
	{cmdID = CMD.TRAJECTORY            , state = true, default = true, name = "Trajectory"},

	{label = "Advanced States (hidden by default)"},
	{cmdID = CMD_DISABLE_ATTACK        , state = true, default = false, name = "Allow Attack Commands"},
	--{cmdID = CMD_UNIT_BOMBER_DIVE_STATE, state = true, default = false, name = "Bomber Dive State"},
	{cmdID = CMD_AUTO_CALL_TRANSPORT   , state = true, default = false, name = "Call Transports"},
	{cmdID = CMD_FIRE_AT_SHIELD        , state = true, default = false, name = "Fire at Shields"},
	{cmdID = CMD_GLOBAL_BUILD          , state = true, default = false, name = "Global Build"},
	{cmdID = CMD_UNIT_KILL_SUBORDINATES, state = true, default = false, name = "Kill Captured"},
	{cmdID = CMD_PREVENT_OVERKILL      , state = true, default = false, name = "Overkill Prevention"},
	{cmdID = CMD_FORMATION_RANK        , state = true, default = false, name = "Formation Rank"},
	{cmdID = CMD_UNIT_AI               , state = true, default = false, name = "Unit AI"},
}

local defaultValues = {
	[CMD.SELFD] = true,
	[CMD.WAIT] = true,
	[CMD_DISEMBARK] = true,
	[CMD.AREA_ATTACK] = true,
	[CMD_AREA_TERRA_MEX] = true,
	[CMD_AREA_GUARD] = true,
	[CMD_UNIT_SET_TARGET_CIRCLE] = true,
	[CMD_UNIT_CANCEL_TARGET] = true,
	[CMD_EXCLUDE_PAD] = true,
	--[CMD_EMBARK] = true,
	--[CMD_STOP_PRODUCTION] = true,
	
	-- states
	--[CMD_RETREAT] = true,
	--[CMD_WANT_ONOFF] = true,
	--[CMD.REPEAT] = true,
	--[CMD_WANT_CLOAK] = true,
	--[CMD.TRAJECTORY] = true,
	--[CMD_UNIT_FLOAT_STATE] = true,
	--[CMD_PRIORITY] = true,
	--[CMD_MISC_PRIORITY] = true,
	--[CMD_FACTORY_GUARD] = true,
	--[CMD_TOGGLE_DRONES] = true,
	--[CMD_PUSH_PULL] = true,
	--[CMD.IDLEMODE] = true,
	--[CMD_AP_FLY_STATE] = true,
	[CMD_UNIT_AI] = true,
	--[CMD_CLOAK_SHIELD] = true,
	[CMD_AUTO_CALL_TRANSPORT] = true,
	[CMD_GLOBAL_BUILD] = true,
	--[CMD.MOVE_STATE] = true,
	--[CMD.FIRE_STATE] = true,
	--[CMD_UNIT_BOMBER_DIVE_STATE] = true,
	[CMD_UNIT_KILL_SUBORDINATES] = true,
	--[CMD_GOO_GATHER] = true,
	[CMD_DISABLE_ATTACK] = true,
	--[CMD_DONT_FIRE_AT_RADAR] = true,
	[CMD_PREVENT_OVERKILL] = true,
	--[CMD_AIR_STRAFE] = true,
	[CMD_SELECTION_RANK] = true,
	[CMD_FORMATION_RANK] = true,
	[CMD_FIRE_AT_SHIELD] = true,
	--[CMD_FIRE_TOWARDS_ENEMY] = true,
}

return configList, defaultValues
