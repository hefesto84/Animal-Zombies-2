-- ruta de l'imatge del nom de l'stage
upper_name          = "county_fair_upper"
lower_name          = "county_fair_lower"
frame_nameOrIndex   = 73 --"assets/frame_feria.jpg"
grave_nameOrIndex   = 74
background_path     = "assets/countyFairBackground.jpg"
stage_frame_index   = 72 --"countyfair"
stage_bso           = AZ.soundLibrary.countyFairLoop
level_button_fx     = AZ.soundLibrary.woodGraveSound

-- zombie array utilitzat per a un futur survival
zombieArray = {}

-- probabilitats d'spawneig de zombies per nivell
-- la suma és consecutiva: si el primer té un 0.3 i el segon té un 0.2, apareixeràn com que el primer té 0.3 i el segon la suma del propi i la probabilitat anterior: 0.5

local z = AZ.zombiesLibrary

-- level 1	-- en aquest nivell apareix: queen
local level_1_probability = {}
level_1_probability[1] = { probability = 0.2,   type = z.ZOMBIE_RABBIT_NAME,    maxAttacks = 1 } -- 20%
level_1_probability[2] = { probability = 0.5,   type = z.ZOMBIE_PARROT_NAME,    maxAttacks = 1 } -- 30%
level_1_probability[3] = { probability = 0.8,   type = z.ZOMBIE_CAT_NAME,       maxAttacks = 1 } -- 30%
level_1_probability[4] = { probability = 1,     type = z.ZOMBIE_QUEEN_NAME,     maxAttacks = 0 } -- 20%

-- level 2	-- en aquest nivell apareix: none
local level_2_probability = {}
level_2_probability[1] = { probability = 0.2,   type = z.ZOMBIE_PARROT_NAME,    maxAttacks = 1 } -- 20%
level_2_probability[2] = { probability = 0.4,   type = z.ZOMBIE_CAT_NAME,       maxAttacks = 1 } -- 20%
level_2_probability[3] = { probability = 0.6,   type = z.ZOMBIE_DOG_NAME,       maxAttacks = 1 } -- 20%
level_2_probability[4] = { probability = 0.8,   type = z.ZOMBIE_FISH_NAME,      maxAttacks = 1 } -- 20%
level_2_probability[5] = { probability = 1,     type = z.ZOMBIE_PIG_NAME,       maxAttacks = 1 } -- 20%

-- level 3	-- en aquest nivell apareix: chihuahua
local level_3_probability = {}
level_3_probability[1] = { probability = 0.2,   type = z.ZOMBIE_DOG_NAME,       maxAttacks = 1 } -- 20%
level_3_probability[2] = { probability = 0.4,   type = z.ZOMBIE_CAT_NAME,       maxAttacks = 1 } -- 20%
level_3_probability[3] = { probability = 0.5,   type = z.ZOMBIE_QUEEN_NAME,     maxAttacks = 0 } -- 10%
level_3_probability[4] = { probability = 1,     type = z.ZOMBIE_CHIHUAHUA_NAME, maxAttacks = 1 } -- 50%

-- level 4	-- en aquest nivell apareix: duck
local level_4_probability = {}
level_4_probability[1] = { probability = 0.2,   type = z.ZOMBIE_RABBIT_NAME,    maxAttacks = 1 } -- 20%
level_4_probability[2] = { probability = 0.3,   type = z.ZOMBIE_QUEEN_NAME,     maxAttacks = 0 } -- 10%
level_4_probability[3] = { probability = 0.6,   type = z.ZOMBIE_CHIHUAHUA_NAME, maxAttacks = 1 } -- 30%
level_4_probability[4] = { probability = 1,     type = z.ZOMBIE_DUCK_NAME,      maxAttacks = 1 } -- 40%

-- level 5	-- en aquest nivell apareix: none
local level_5_probability = {}
level_5_probability[1] = { probability = 0.1,   type = z.ZOMBIE_TORTOISE_NAME,  maxAttacks = 1 } -- 10%
level_5_probability[2] = { probability = 0.2,   type = z.ZOMBIE_QUEEN_NAME,     maxAttacks = 0 } -- 10%
level_5_probability[3] = { probability = 0.5,   type = z.ZOMBIE_CHIHUAHUA_NAME, maxAttacks = 1 } -- 30%
level_5_probability[4] = { probability = 0.8,   type = z.ZOMBIE_DUCK_NAME,      maxAttacks = 1 } -- 30%
level_5_probability[5] = { probability = 1,     type = z.ZOMBIE_PIG_NAME,       maxAttacks = 1 } -- 15%

-- level 6	-- en aquest nivell apareix: turkey
local level_6_probability = {}
level_6_probability[1] = { probability = 0.1,   type = z.ZOMBIE_QUEEN_NAME,     maxAttacks = 0 } -- 10%
level_6_probability[2] = { probability = 0.3,   type = z.ZOMBIE_CHIHUAHUA_NAME, maxAttacks = 1 } -- 20%
level_6_probability[3] = { probability = 0.5,   type = z.ZOMBIE_DUCK_NAME,      maxAttacks = 1 } -- 20%
level_6_probability[4] = { probability = 1,     type = z.ZOMBIE_TURKEY_NAME,    maxAttacks = 1 } -- 50%

-- level 7	-- en aquest nivell apareix: none
local level_7_probability = {}
level_7_probability[1] = { probability = 0.1,    type = z.ZOMBIE_QUEEN_NAME,    maxAttacks = 0 } -- 10%
level_7_probability[2] = { probability = 0.35,   type = z.ZOMBIE_CHIHUAHUA_NAME,maxAttacks = 1 } -- 25%
level_7_probability[3] = { probability = 0.6,    type = z.ZOMBIE_DUCK_NAME,     maxAttacks = 1 } -- 25%
level_7_probability[4] = { probability = 0.85,   type = z.ZOMBIE_TURKEY_NAME,   maxAttacks = 1 } -- 25%
level_7_probability[5] = { probability = 1,      type = z.ZOMBIE_PIG_NAME,      maxAttacks = 1 } -- 15%

-- level 8	-- en aquest nivell apareix: cage
local level_8_probability = {}
level_8_probability[1] = { probability = 0.15,  type = z.ZOMBIE_QUEEN_NAME,     maxAttacks = 0 } -- 15%
level_8_probability[2] = { probability = 0.41,  type = z.ZOMBIE_CHIHUAHUA_NAME, maxAttacks = 1 } -- 26%
level_8_probability[3] = { probability = 0.67,  type = z.ZOMBIE_DUCK_NAME,      maxAttacks = 1 } -- 26%
level_8_probability[4] = { probability = 0.93,  type = z.ZOMBIE_TURKEY_NAME,    maxAttacks = 1 } -- 26%
level_8_probability[5] = { probability = 1,     type = z.ZOMBIE_CAGE_NAME,      maxAttacks = 1 } -- 7%

-- level 9	-- en aquest nivell apareix: none
local level_9_probability = {}
level_9_probability[1] = { probability = 0.1,   type = z.ZOMBIE_QUEEN_NAME,     maxAttacks = 0 } -- 10%
level_9_probability[2] = { probability = 0.25,  type = z.ZOMBIE_CHIHUAHUA_NAME, maxAttacks = 1 } -- 15%
level_9_probability[3] = { probability = 0.4,   type = z.ZOMBIE_DUCK_NAME,      maxAttacks = 1 } -- 15%
level_9_probability[4] = { probability = 0.55,  type = z.ZOMBIE_TURKEY_NAME,    maxAttacks = 1 } -- 15%
level_9_probability[5] = { probability = 0.65,  type = z.ZOMBIE_CAGE_NAME,      maxAttacks = 1 } -- 10%
level_9_probability[6] = { probability = 0.8,   type = z.ZOMBIE_PIG_NAME,       maxAttacks = 1 } -- 15%
level_9_probability[7] = { probability = 0.9,   type = z.ZOMBIE_MOLE_NAME,      maxAttacks = 0 } -- 10%
level_9_probability[8] = { probability = 1,     type = z.ZOMBIE_TORTOISE_NAME,  maxAttacks = 1 } -- 10%


-- storyboards
stage_storyboard = {}
stage_storyboard[1] = { storyboardImage = "story/assets/story2_07.jpg", storyboardText = "story_2_1" } -- lvl 0 win
stage_storyboard[2] = { storyboardImage = "story/assets/story2_01.jpg", storyboardText = "story_2_2" } -- lvl 1 queen
stage_storyboard[3] = { storyboardImage = "story/assets/story2_08.jpg", storyboardText = "story_2_4" } -- lvl 3 chihuahua
stage_storyboard[5] = { storyboardImage = "story/assets/story2_03.jpg", storyboardText = "story_2_5" } -- lvl 4 duck
stage_storyboard[6] = { storyboardImage = "story/assets/story2_04.jpg", storyboardText = "story_2_6" } -- lvl 6 turkey
stage_storyboard[7] = { storyboardImage = "story/assets/story2_05.jpg", storyboardText = "story_2_7" } -- lvl 8 cage
stage_storyboard[8] = { storyboardImage = "story/assets/story2_06.jpg", storyboardText = "story_2_8" } -- lvl 9 all

-- informació persistent dels nivells de l'stage 2
stage_level_info = {}
stage_level_info[1] = { zombies = level_1_probability,
                        lvlJson = "",
                        storyboard = stage_storyboard[2],
                        tip = 8,
                        ingameTip = nil,
                        emblem = 13,
                        zombieSpawnProbability = 800,
                        lollipopSpawnProbability = 10,
                        rakeSpawnProbability = 0,
                        maxZombiesPerScreen = 3,
                        maxZombiesInLevel = 40,
                        waveZombies = 0,
                        maxAttacksPerZombie = 1,
                        minTimePerAttack = 1000,
                        maxTimePerAttack = 2000,
                        medTime = 50000,
                        scoreBones = { 50, 300, 650 } }
stage_level_info[2] = { zombies = level_2_probability,
                        lvlJson = "",
                        storyboard = stage_storyboard[3],
                        tip = 10,
                        ingameTip = nil,
                        emblem = 14,
                        zombieSpawnProbability = 700,
                        lollipopSpawnProbability = 3,
                        rakeSpawnProbability = 50,
                        maxZombiesPerScreen = 4,
                        maxZombiesInLevel = 50,
                        waveZombies = 0,
                        maxAttacksPerZombie = 1,
                        minTimePerAttack = 1000,
                        maxTimePerAttack = 2000,
                        medTime = 40000,
                        scoreBones = { 50, 500, 1300 } }
stage_level_info[3] = { zombies = level_3_probability,
                        lvlJson = "",
                        storyboard = stage_storyboard[4],
                        tip = 0,
                        ingameTip = nil,
                        emblem = 15,
                        zombieSpawnProbability = 600,
                        lollipopSpawnProbability = 3,
                        rakeSpawnProbability = 10,
                        maxZombiesPerScreen = 5,
                        maxZombiesInLevel = 60,
                        waveZombies = 0,
                        maxAttacksPerZombie = 1, --2,
                        minTimePerAttack = 1000,
                        maxTimePerAttack = 1000,
                        medTime = 50000,
                        scoreBones = { 50, 700, 1450 } }
stage_level_info[4] = { zombies = level_4_probability,
                        lvlJson = "",
                        storyboard = stage_storyboard[5],
                        tip = 0,
                        ingameTip = nil,
                        emblem = 16,
                        zombieSpawnProbability = 500,
                        lollipopSpawnProbability = 2,
                        rakeSpawnProbability = 10,
                        maxZombiesPerScreen = 7,
                        maxZombiesInLevel = 80,
                        waveZombies = 0,
                        maxAttacksPerZombie = 1, --2,
                        minTimePerAttack = 600,
                        maxTimePerAttack = 700,
                        medTime = 50000,
                        scoreBones = { 50, 800, 2000 } }
stage_level_info[5] = { zombies = level_5_probability,
                        lvlJson = "",
                        storyboard = nil,
                        tip = 0,
                        ingameTip = nil,
                        emblem = 17,
                        zombieSpawnProbability = 400,
                        lollipopSpawnProbability = 2,
                        rakeSpawnProbability = 5,
                        maxZombiesPerScreen = 8,
                        maxZombiesInLevel = 90,
                        waveZombies = 0,
                        maxAttacksPerZombie = 1, --2,
                        minTimePerAttack = 500,
                        maxTimePerAttack = 500,
                        medTime = 50000,
                        scoreBones = { 50, 750, 1850 } }
stage_level_info[6] = { zombies = level_6_probability,
                        lvlJson = "",
                        storyboard = stage_storyboard[6],
                        tip = 0,
                        ingameTip = nil,
                        emblem = 18,
                        zombieSpawnProbability = 300,
                        lollipopSpawnProbability = 2,
                        rakeSpawnProbability = 5,
                        maxZombiesPerScreen = 9,
                        maxZombiesInLevel = 90,
                        waveZombies = 20,
                        maxAttacksPerZombie = 1, --2,
                        minTimePerAttack = 300,
                        maxTimePerAttack = 400,
                        medTime = 60000,
                        scoreBones = { 50, 950, 2400 } }
stage_level_info[7] = { zombies = level_7_probability,
                        lvlJson = "",
                        storyboard = nil,
                        tip = 0,
                        ingameTip = nil,
                        emblem = 19,
                        zombieSpawnProbability = 200,
                        lollipopSpawnProbability = 2,
                        rakeSpawnProbability = 5,
                        maxZombiesPerScreen = 10,
                        maxZombiesInLevel = 95,
                        waveZombies = 30,
                        maxAttacksPerZombie = 1, --3,
                        minTimePerAttack = 300,
                        maxTimePerAttack = 400,
                        medTime = 55000,
                        scoreBones = { 50, 1000, 2600 } }
stage_level_info[8] = { zombies = level_8_probability,
                        lvlJson = "",
                        storyboard = stage_storyboard[7],
                        tip = 9,
                        ingameTip = nil,
                        emblem = 20,
                        zombieSpawnProbability = 150,
                        lollipopSpawnProbability = 2,
                        rakeSpawnProbability = 1,
                        maxZombiesPerScreen = 11,
                        maxZombiesInLevel = 110,
                        waveZombies = 30,
                        maxAttacksPerZombie = 1, --3,
                        minTimePerAttack = 300,
                        maxTimePerAttack = 400,
                        medTime = 60000,
                        scoreBones = { 50, 1000, 2450 } }
stage_level_info[9] = { zombies = level_9_probability,
                        lvlJson = "",
                        storyboard = stage_storyboard[8],
                        tip = 0,
                        ingameTip = nil,
                        emblem = 21,
                        zombieSpawnProbability = 100,
                        lollipopSpawnProbability = 2,
                        rakeSpawnProbability = 1,
                        maxZombiesPerScreen = 12,
                        maxZombiesInLevel = 120,
                        waveZombies = 40,
                        maxAttacksPerZombie = 1, --3,
                        minTimePerAttack = 300,
                        maxTimePerAttack = 300,
                        medTime = 85000,
                        scoreBones = { 50, 950, 2250 } }
