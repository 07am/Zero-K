unitDef = {
  unitname            = [[corch]],
  name                = [[Quill]],
  description         = [[Construction Hovercraft, Builds at 6 m/s]],
  acceleration        = 0.066,
  brakeRate           = 0.1,
  buildCostEnergy     = 150,
  buildCostMetal      = 150,
  buildDistance       = 140,
  builder             = true,

  buildoptions        = {
  },

  buildPic            = [[CORCH.png]],
  buildTime           = 150,
  canGuard            = true,
  canHover            = true,
  canMove             = true,
  canPatrol           = true,
  canreclamate        = [[1]],
  canstop             = [[1]],
  category            = [[UNARMED HOVER]],
  collisionVolumeOffsets = [[0 0 0]],
  collisionVolumeScales  = [[50 22 55]],
  collisionVolumeTest    = 1,
  collisionVolumeType    = [[ellipsoid]],  
  corpse              = [[DEAD]],

  customParams        = {
    description_fr = [[Hovercraft de Construction, Construit r 6 m/s]],
	description_de = [[Konstruktionsluftkissenboot, Baut mir 6 M/s]],
    helptext       = [[The Hovercon allows smooth expansion across both land and sea. It can also detect submarines that get too close.]],
    helptext_fr    = [[L'Hovercon est rapide et agile mais son blindage et ses nanoconstructeurs sont de mauvaise facture.]],
	helptext_de    = [[Der Hovercan erlaubt es dir leichtg�ngige Expansionen �ber Land und See. Dabei kann er sogar U-Boote entdecken, die ihm zu nahe kommen.]],
  },

  energyMake          = 0.15,
  energyUse           = 0,
  explodeAs           = [[BIG_UNITEX]],
  floater             = true,
  footprintX          = 3,
  footprintZ          = 3,
  iconType            = [[builder]],
  idleAutoHeal        = 5,
  idleTime            = 1800,
  mass                = 150,
  maxDamage           = 800,
  maxSlope            = 36,
  maxVelocity         = 2.8,
  metalMake           = 0.15,
  minCloakDistance    = 75,
  modelCenterOffset	  = [[0 5 2]],
  movementClass       = [[HOVER3]],
  noChaseCategory     = [[TERRAFORM SATELLITE FIXEDWING GUNSHIP HOVER SHIP SWIM SUB LAND FLOAT SINK TURRET]],
  objectName          = [[corch.s3o]],
  seismicSignature    = 4,
  selfDestructAs      = [[BIG_UNITEX]],

  sfxtypes            = {

    explosiongenerators = {
      [[custom:HOVERS_ON_GROUND]],
    },

  },

  showNanoSpray       = false,
  side                = [[CORE]],
  sightDistance       = 325,
  smoothAnim          = true,
  terraformSpeed      = 300,
  turninplace         = 0,
  turnRate            = 494,
  workerTime          = 6,

  featureDefs         = {

    DEAD  = {
      description      = [[Wreckage - Hovercon]],
      blocking         = false,
      category         = [[corpses]],
      damage           = 900,
      energy           = 0,
      featureDead      = [[DEAD2]],
      footprintX       = 3,
      footprintZ       = 3,
      height           = [[20]],
      hitdensity       = [[100]],
      metal            = 60,
      object           = [[corch_dead.s3o]],
      reclaimable      = true,
      reclaimTime      = 60,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },


    DEAD2 = {
      description      = [[Debris - Hovercon]],
      blocking         = false,
      category         = [[heaps]],
      damage           = 900,
      energy           = 0,
      featureDead      = [[HEAP]],
      footprintX       = 3,
      footprintZ       = 3,
      height           = [[4]],
      hitdensity       = [[100]],
      metal            = 60,
      object           = [[debris3x3c.s3o]],
      reclaimable      = true,
      reclaimTime      = 60,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },


    HEAP  = {
      description      = [[Debris - Hovercon]],
      blocking         = false,
      category         = [[heaps]],
      damage           = 900,
      energy           = 0,
      footprintX       = 3,
      footprintZ       = 3,
      height           = [[4]],
      hitdensity       = [[100]],
      metal            = 30,
      object           = [[debris3x3c.s3o]],
      reclaimable      = true,
      reclaimTime      = 30,
      seqnamereclamate = [[TREE1RECLAMATE]],
      world            = [[All Worlds]],
    },

  },

}

return lowerkeys({ corch = unitDef })
