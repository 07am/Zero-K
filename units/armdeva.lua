unitDef = {
  unitname                      = [[armdeva]],
  name                          = [[Stardust]],
  description                   = [[Anti-Swarm Turret]],
  activateWhenBuilt             = true,
  bmcode                        = [[0]],
  buildCostEnergy               = 220,
  buildCostMetal                = 220,
  builder                       = false,
  buildingGroundDecalDecaySpeed = 30,
  buildingGroundDecalSizeX      = 5,
  buildingGroundDecalSizeY      = 5,
  buildingGroundDecalType       = [[armdeva_aoplane.dds]],
  buildPic                      = [[armdeva.png]],
  buildTime                     = 220,
  canAttack                     = true,
  canGuard                      = true,
  canstop                       = [[1]],
  category                      = [[FLOAT TURRET]],
  corpse                        = [[DEAD]],

  customParams                  = {
    description_de = [[Anti-Schwarm EMG]],
    description_fr = [[Mitrailleurs Anti-Nuée]],
    description_pl = [[Wieżyczka Wsparcia]],
    helptext       = [[The Stardust sports a powerful autocannon. While it has a short range and is thus even more vulnerable to skirmishers than the LLT, its high rate of fire and AoE allow it to quickly chew up swarms of lighter units.]],
    helptext_de    = [[Stardust ist ein Geschützturm mit einem lang perfektionierten und tödlichen energetischen Maschinengewehr. Zwar besitzt es nur eine kurze Reichweite, wodurch es sehr verletzbar gegenüber Skirmishern ist, dennoch machen es die hohe Feuerrate und die AoE zu einer guten Verteidigung gegen Schwärme und leichte Einheiten.]],
    helptext_fr    = [[Le Stardust est une tourelle mitrailleuse r haute energie. Son incroyable cadence de tir lui permettent d'arreter quasiment nimporte quelle nuée de Pilleur ou d'unités légcres, cependant sa portée est relativement limitée, et étant prcs du sol nimporte quel obstacle l'empeche de tirer.]],
    helptext_pl    = [[Wieżyczka Stardust posiada działko o bardzo dużej sile i wysokim obszarze działania, co pozwala jej niszczyć hordy lżejszych jednostek. Ma jednak niski zasięg, który pozwala ją atakować bez możliwości kontrataku.]],
  },

  defaultmissiontype            = [[GUARD_NOMOVE]],
  explodeAs                     = [[LARGE_BUILDINGEX]],
  floater                       = true,
  footprintX                    = 3,
  footprintZ                    = 3,
  iconType                      = [[defenseriot]],
  levelGround                   = false,
  mass                          = 192,
  maxDamage                     = 1500,
  maxSlope                      = 18,
  minCloakDistance              = 150,
  noAutoFire                    = false,
  noChaseCategory               = [[FIXEDWING LAND SHIP SATELLITE SWIM GUNSHIP SUB HOVER]],
  objectName                    = [[afury.s3o]],
  seismicSignature              = 4,
  selfDestructAs                = [[LARGE_BUILDINGEX]],

  sfxtypes                      = {

    explosiongenerators = {
      [[custom:WARMUZZLE]],
      [[custom:DEVA_SHELLS]],
    },

  },

  shootme                       = [[1]],
  side                          = [[ARM]],
  sightDistance                 = 451,
  TEDClass                      = [[FORT]],
  useBuildingGroundDecal        = true,
  workerTime                    = 0,
  yardMap                       = [[ooo ooo ooo]],

  weapons                       = {

    {
      def                = [[ARMDEVA_WEAPON]],
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },

  },


  weaponDefs                    = {

    ARMDEVA_WEAPON = {
      name                    = [[Pulse Autocannon]],
      accuracy                = 2300,
      alphaDecay              = 0.7,
      areaOfEffect            = 96,
      burnblow                = true,
      craterBoost             = 0.15,
      craterMult              = 0.3,

      damage                  = {
        default = 45,
        subs    = 2.25,
      },

      edgeEffectiveness       = 0.5,
      explosionGenerator      = [[custom:EMG_HIT_HE]],
      firestarter             = 70,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      intensity               = 0.7,
      interceptedByShieldType = 1,
      lineOfSight             = true,
      noSelfDamage            = true,
      range                   = 410,
      reloadtime              = 0.12,
      renderType              = 4,
      rgbColor                = [[1 0.95 0.4]],
      separation              = 1.5,
      soundHit                = [[weapon/cannon/emg_hit]],
      soundStart              = [[weapon/heavy_emg]],
      soundStartVolume        = 0.5,
      stages                  = 10,
      targetMoveError         = 0,
      turret                  = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 550,
    },

  },


  featureDefs                   = {

    DEAD  = {
      description      = [[Wreckage - Stardust]],
      blocking         = true,
      category         = [[arm_corpses]],
      damage           = 1500,
      featureDead      = [[DEAD2]],
      featurereclamate = [[smudge01]],
      footprintX       = 3,
      footprintZ       = 3,
      height           = 100,
      hitdensity       = 100,
      metal            = 88,
      object           = [[afury_dead.s3o]],
      reclaimable      = true,
      reclaimTime      = 88,
      seqnamereclamate = [[tree1reclamate]],
      world            = [[All Worlds]],
    },


    DEAD2 = {
      description      = [[Debris - Stardust]],
      blocking         = false,
      category         = [[heaps]],
      damage           = 1500,
      featureDead      = [[HEAP]],
      featurereclamate = [[smudge01]],
      footprintX       = 3,
      footprintZ       = 3,
      height           = 4,
      hitdensity       = 100,
      metal            = 88,
      object           = [[debris4x4b.s3o]],
      reclaimable      = true,
      reclaimTime      = 88,
      seqnamereclamate = [[tree1reclamate]],
      world            = [[All Worlds]],
    },


    HEAP  = {
      description      = [[Debris - Stardust]],
      blocking         = false,
      category         = [[heaps]],
      damage           = 1500,
      featurereclamate = [[smudge01]],
      footprintX       = 3,
      footprintZ       = 3,
      height           = 4,
      hitdensity       = 100,
      metal            = 44,
      object           = [[debris4x4b.s3o]],
      reclaimable      = true,
      reclaimTime      = 44,
      seqnamereclamate = [[tree1reclamate]],
      world            = [[All Worlds]],
    },

  },

}

return lowerkeys({ armdeva = unitDef })
