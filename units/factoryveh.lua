return { factoryveh = {
  unitname                      = [[factoryveh]],
  name                          = [[Rover Assembly]],
  description                   = [[Produces Rovers]],
  buildCostMetal                = Shared.FACTORY_COST,
  buildDistance                 = Shared.FACTORY_PLATE_RANGE,
  builder                       = true,
  buildingGroundDecalDecaySpeed = 30,
  buildingGroundDecalSizeX      = 11,
  buildingGroundDecalSizeY      = 11,
  buildingGroundDecalType       = [[factoryveh_aoplane.dds]],

  buildoptions                  = {
    [[vehcon]],
    [[vehscout]],
    [[vehraid]],
    [[vehsupport]],
    [[vehriot]],
    [[vehassault]],
    [[vehcapture]],
    [[veharty]],
    [[vehheavyarty]],
    [[vehaa]],
  },

  buildPic                      = [[factoryveh.png]],
  canMove                       = true,
  canPatrol                     = true,
  category                      = [[SINK UNARMED]],
  collisionVolumeOffsets        = [[0 -8 -25]],
  collisionVolumeScales         = [[120 44 44]],
  collisionVolumeType           = [[ellipsoid]],
  selectionVolumeOffsets        = [[0 0 10]],
  selectionVolumeScales         = [[120 70 112]],
  selectionVolumeType           = [[box]],
  corpse                        = [[DEAD]],

  customParams                  = {
    ploppable = 1,
    sortName       = [[2]],
    default_spacing = 8,

    solid_factory  = 3,
    aimposoffset   = [[0 0 -35]],
    midposoffset   = [[0 0 -10]],
    modelradius    = [[70]],
    unstick_help   = 1,
    factorytab       = 1,
    shared_energy_gen = 1,
    parent_of_plate   = [[plateveh]],

    stats_show_death_explosion = 1,

    outline_x = 250,
    outline_y = 250,
    outline_yoff = 5,
  },

  energyUse                     = 0,
  explodeAs                     = [[LARGE_BUILDINGEX]],
  footprintX                    = 8,
  footprintZ                    = 8,
  iconType                      = [[facvehicle]],
  levelGround                   = false,
  maxDamage                     = 4000,
  maxSlope                      = 15,
  maxVelocity                   = 0,
  maxWaterDepth                 = 0,
  moveState                     = 1,
  noAutoFire                    = false,
  objectName                    = [[factoryveh.dae]],
  script                        = [[factoryveh.lua]],
  selfDestructAs                = [[LARGE_BUILDINGEX]],
  showNanoSpray                 = false,
  sightDistance                 = 273,
  useBuildingGroundDecal        = true,
  workerTime                    = Shared.FACTORY_BUILDPOWER,
  yardMap                       = "oooooooo oooooooo oooooooo yccccccy yccccccy yccccccy yccccccy yccccccy",

  featureDefs                   = {

    DEAD  = {
      blocking         = true,
      featureDead      = [[HEAP]],
      footprintX       = 8,
      footprintZ       = 8,
      object           = [[factoryveh_d.dae]],
      collisionVolumeOffsets = [[0 0 -20]],
      collisionVolumeScales  = [[110 35 75]],
      collisionVolumeType    = [[box]],
    },


    HEAP  = {
      blocking         = false,
      footprintX       = 7,
      footprintZ       = 7,
      object           = [[debris4x4c.s3o]],
    },

  },

} }
