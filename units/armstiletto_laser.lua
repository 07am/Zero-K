unitDef = {
  unitname            = [[armstiletto_laser]],
  name                = [[Stiletto]],
  description         = [[EMP Lightning Bomber]],
  amphibious          = true,
  buildCostEnergy     = 700,
  buildCostMetal      = 700,
  buildPic            = [[armstiletto_laser.png]],
  buildTime           = 700,
  canAttack           = true,
  canDropFlare        = false,
  canFly              = true,
  canGuard            = true,
  canMove             = true,
  canPatrol           = true,
  canSubmerge         = false,
  category            = [[FIXEDWING]],
  collide             = false,
  collisionVolumeOffsets = [[0 0 0]],
  collisionVolumeScales  = [[50 20 60]],
  collisionVolumeTest    = 1,
  collisionVolumeType    = [[ellipsoid]],
  corpse              = [[DEAD]],
  cruiseAlt           = 180,

  customParams        = {
    description_bp = [[Bombardeiro de raios PEM invisível a radar]],
    description_de = [[EMP-Tarnkappenbomber]],
    description_fr = [[Bombardier EMP Furtif]],
    description_pl = [[Bombowiec EMP]],
    helptext       = [[Fast bomber armed with a lightning generator that paralyzes units in a wide area under it.]],
    helptext_bp    = [[Bombardeiro rápido a radar equipado com um gerador de raios ao invés de bombas que dispara raios de PEM contra o inimigo ao atacar.]],
    helptext_de    = [[Schneller Tarnkappenbomber, der mit einem Stossspannungsgenerator zum Paralysieren großflächiger Gebiete bewaffnet ist.]],
    helptext_fr    = [[Rapide, armé de canons EMP pouvant paralyser les unités dans une large bande.]],
    helptext_pl    = [[Szybki bombowiec, który jest w stanie sparaliżować jednostki w wyznaczonym obszarze.]],
    modelradius    = [[10]],
  },

  explodeAs           = [[GUNSHIPEX]],
  floater             = true,
  footprintX          = 3,
  footprintZ          = 3,
  iconType            = [[bomberriot]],
  idleAutoHeal        = 5,
  idleTime            = 1800,
  mass                = 238,
  maxAcc              = 0.5,
  maxDamage           = 1100,
  maxFuel             = 1000000,
  maxVelocity         = 9,
  minCloakDistance    = 75,
  noAutoFire          = false,
  noChaseCategory     = [[TERRAFORM FIXEDWING LAND SHIP SATELLITE SWIM GUNSHIP SUB HOVER]],
  objectName          = [[stiletto.s3o]],
  script              = [[armstiletto_laser.lua]],
  seismicSignature    = 0,
  selfDestructAs      = [[GUNSHIPEX]],
  side                = [[ARM]],
  sightDistance       = 660,
  stealth             = false,
  turnRadius          = 100,

  weapons             = {

    {
      def                = [[BOGUS_BOMB]],
      badTargetCategory  = [[SWIM LAND SHIP HOVER]],
      onlyTargetCategory = [[SWIM LAND SINK TURRET FLOAT SHIP HOVER GUNSHIP]],
    },


    {
      def                = [[ARMBOMBLIGHTNING]],
      mainDir            = [[0 -1 0]],
      maxAngleDif        = 0,
      onlyTargetCategory = [[NONE]],
    },

  },


  weaponDefs          = {

    ARMBOMBLIGHTNING = {
      name                    = [[BombLightning]],
      areaOfEffect            = 192,
      avoidFeature            = false,
      avoidFriendly           = false,
      beamTime                = 0.01,
	  burst					  = 80,
	  burstRate				  = 0.3,
      canattackground         = false,
      collideFriendly         = false,
      coreThickness           = 0.6,
      craterBoost             = 0,
      craterMult              = 0,

	  customParams        = {
	    disarmDamageMult = 1,
		disarmDamageOnly = 1,
		disarmTimer      = 13, -- seconds
	  
	  },
	  
      damage                  = {
        default        = 675,
        empresistant75 = 168.75,
        empresistant99 = 67.5,
        planes         = 675,
      },

      edgeEffectiveness       = 0.4,
      explosionGenerator      = [[custom:WHITE_LIGHTNING_BOMB]],
      fireStarter             = 90,
      impulseBoost            = 0,
      impulseFactor           = 0,
      intensity               = 12,
      interceptedByShieldType = 1,
      largeBeamLaser          = true,
      laserFlareSize          = 5,
      minIntensity            = 1,
      paralyzer               = true, -- for smart targeting, damage vs shields and lups shockwave
      range                   = 730,
      reloadtime              = 10,
      rgbColor                = [[1 1 1]],
      sprayAngle              = 6000,
      texture1                = [[lightning]],
      texture2                = [[flare]],
      texture3                = [[flare]],
      texture4                = [[smallflare]],
      thickness               = 10,
      tileLength              = 50,
      tolerance               = 32767,
      turret                  = true,
      weaponType              = [[BeamLaser]],
      weaponVelocity          = 2250,
    },


    BOGUS_BOMB       = {
      name                    = [[Fake Bomb]],
      avoidFeature            = false,
      avoidFriendly           = false,
      burst                   = 2,
      burstrate               = 1,
      collideFriendly         = false,

      damage                  = {
        default = 0,
      },

      explosionGenerator      = [[custom:NONE]],
      interceptedByShieldType = 1,
      manualBombSettings      = true,
      myGravity               = 0.8,
      noSelfDamage            = true,
      range                   = 500,
      reloadtime              = 10,
	  scale                   = [[0]],
      sprayangle              = 64000,
      weaponType              = [[AircraftBomb]],
    },

  },


  featureDefs         = {

    DEAD = {
      description      = [[Wreckage - Stiletto]],
      blocking         = true,
      category         = [[corpses]],
      damage           = 1130,
      energy           = 0,
      featureDead      = [[HEAP]],
      featurereclamate = [[SMUDGE01]],
      footprintX       = 2,
      footprintZ       = 2,
      height           = [[40]],
      hitdensity       = [[100]],
      metal            = 280,
      object           = [[Stiletto_dead.s3o]],
      reclaimable      = true,
      reclaimTime      = 280,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },


    HEAP = {
      description      = [[Debris - Stiletto]],
      blocking         = false,
      category         = [[heaps]],
      damage           = 1130,
      energy           = 0,
      featurereclamate = [[SMUDGE01]],
      footprintX       = 2,
      footprintZ       = 2,
      height           = [[4]],
      hitdensity       = [[100]],
      metal            = 140,
      object           = [[debris2x2c.s3o]],
      reclaimable      = true,
      reclaimTime      = 140,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },

  },

}

return lowerkeys({ armstiletto_laser = unitDef })
