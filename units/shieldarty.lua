unitDef = {
  unitname               = [[shieldarty]],
  name                   = [[Racketeer]],
  description            = [[EMP Artillery]],
  acceleration           = 0.25,
  brakeRate              = 0.25,
  buildCostEnergy        = 350,
  buildCostMetal         = 350,
  buildPic               = [[SHIELDARTY.png]],
  buildTime              = 350,
  canAttack              = true,
  canGuard               = true,
  canMove                = true,
  canPatrol              = true,
  category               = [[LAND]],
  corpse                 = [[DEAD]],

  customParams           = {
    helptext       = [[The Racketeer launches long range EMP missiles that can stun key enemy defenses before assaulting them. Since its missiles do not track or even lead, it is only useful against enemy units that are standing still. Only one Racketeer is needed to keep a target stunned, so pick a different target for each Racketeer. It is excellent at depleting the energy of enemy shields.]],
  },

  explodeAs              = [[BIG_UNITEX]],
  footprintX             = 2,
  footprintZ             = 2,
  iconType               = [[walkerlrarty]],
  idleAutoHeal           = 5,
  idleTime               = 1800,
  leaveTracks            = true,
  maxDamage              = 950,
  maxSlope               = 36,
  maxVelocity            = 1.8,
  maxWaterDepth          = 22,
  minCloakDistance       = 75,
  modelCenterOffset      = [[0 0 0]],
  movementClass          = [[KBOT2]],
  moveState              = 0,
  noChaseCategory        = [[TERRAFORM FIXEDWING GUNSHIP]],
  objectName             = [[dominator.s3o]],
  script                 = [[shieldarty.lua]],
  seismicSignature       = 4,
  selfDestructAs         = [[BIG_UNITEX]],

  sfxtypes               = {

    explosiongenerators = {
      [[custom:STORMMUZZLE]],
      [[custom:STORMBACK]],
    },

  },

  sightDistance          = 325,
  trackOffset            = 0,
  trackStrength          = 8,
  trackStretch           = 1,
  trackType              = [[ComTrack]],
  trackWidth             = 22,
  turnRate               = 1800,
  upright                = true,

  weapons                = {

    {
      def                = [[EMP_ROCKET]],
      badTargetCategory  = [[SWIM LAND SHIP HOVER]],
      onlyTargetCategory = [[SWIM LAND SINK TURRET FLOAT SHIP HOVER]],
    },

  },

  weaponDefs             = {
    EMP_ROCKET = {
      name                    = [[EMP Cruise Missile]],
      areaOfEffect            = 96,
      cegTag                  = [[emptrail]],
      collideFriendly         = false,
      craterBoost             = 0,
      craterMult              = 0,

      damage                  = {
        default        = 1500,
        planes         = 1500,
      },

      edgeEffectiveness       = 0.4,
      explosionGenerator      = [[custom:YELLOW_LIGHTNINGPLOSION]],
      fireStarter             = 0,
      flighttime              = 10,
      impulseBoost            = 0,
      impulseFactor           = 0,
      interceptedByShieldType = 2,
      model                   = [[wep_merl.s3o]],
      noSelfDamage            = true,
      paralyzer               = true,
      paralyzeTime            = 8,
      range                   = 940,
      reloadtime              = 5,
      smokeTrail              = false,
      soundHit                = [[weapon/missile/vlaunch_emp_hit]],
      soundStart              = [[weapon/missile/missile_launch_high]],
      texture1                = [[null]], --flare
      tolerance               = 4000,
      weaponAcceleration      = 300,
      weaponTimer             = 1.6,
      weaponType              = [[StarburstLauncher]],
      weaponVelocity          = 7000,
    },
  },

  featureDefs            = {

    DEAD  = {
      description      = [[Wreckage - Racketeer]],
      blocking         = true,
      damage           = 950,
      energy           = 0,
      featureDead      = [[HEAP]],
      footprintX       = 2,
      footprintZ       = 2,
      metal            = 140,
      object           = [[dominator_dead.s3o]],
      reclaimable      = true,
      reclaimTime      = 140,
    },

    HEAP  = {
      description      = [[Debris - Racketeer]],
      blocking         = false,
      damage           = 950,
      energy           = 0,
      footprintX       = 2,
      footprintZ       = 2,
      metal            = 70,
      object           = [[debris2x2c.s3o]],
      reclaimable      = true,
      reclaimTime      = 70,
    },

  },

}

return lowerkeys({ shieldarty = unitDef })
