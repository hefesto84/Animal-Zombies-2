-- ruta de l'imatge del nom de l'stage
upper_name          = "pet_cemetery_upper"
lower_name          = "pet_cemetery_lower"
frame_nameOrIndex   = 60 --"assets/frame_cementerio.jpg"
grave_nameOrIndex   = 61
background_path     = "assets/petCemeteryBackground.jpg"
stage_frame_index   = 62 --"petcemetery"
stage_bso           = AZ.soundLibrary.petCemeteryLoop
level_button_fx     = AZ.soundLibrary.stoneGraveSound

-- zombie array utilitzat per a un futur survival
zombieArray = {}

-- probabilitats d'spawneig de zombies per nivell
-- la suma és consecutiva: si el primer té un 0.3 i el segon té un 0.2, apareixeràn com que el primer té 0.3 i el segon la suma del propi i la probabilitat anterior: 0.5

local z = AZ.zombiesLibrary

-- level 1	-- en aquest nivell apareix: rabbit
local level_1_probability = {}
level_1_probability[1] = { probability = 1,     type = z.ZOMBIE_RABBIT_NAME,    maxAttacks = 1 } -- 100%

-- level 2	-- en aquest nivell apareix: mole
local level_2_probability = {}
level_2_probability[1] = { probability = 0.8,   type = z.ZOMBIE_RABBIT_NAME,    maxAttacks = 1 } -- 80%
level_2_probability[2] = { probability = 1,     type = z.ZOMBIE_MOLE_NAME,      maxAttacks = 0 } -- 20%

-- level 3	-- en aquest nivell apareix: dog
local level_3_probability = {}
level_3_probability[1] = { probability = 0.25,  type = z.ZOMBIE_RABBIT_NAME,    maxAttacks = 1 } -- 25%
level_3_probability[2] = { probability = 0.45,  type = z.ZOMBIE_MOLE_NAME,      maxAttacks = 1 } -- 20%
level_3_probability[3] = { probability = 1,     type = z.ZOMBIE_DOG_NAME,       maxAttacks = 1 } -- 55%

-- level 4	-- en aquest nivell apareix: parrot
local level_4_probability = {}
level_4_probability[1] = { probability = 0.2,   type = z.ZOMBIE_RABBIT_NAME,    maxAttacks = 1 } -- 20%
level_4_probability[2] = { probability = 0.4,   type = z.ZOMBIE_MOLE_NAME,      maxAttacks = 0 } -- 20%
level_4_probability[3] = { probability = 0.6,   type = z.ZOMBIE_DOG_NAME,       maxAttacks = 1 } -- 20%
level_4_probability[4] = { probability = 1,     type = z.ZOMBIE_PARROT_NAME,    maxAttacks = 1 } -- 40%

-- level 5	-- en aquest nivell apareix: pig
local level_5_probability = {}
level_5_probability[1] = { probability = 0.2,   type = z.ZOMBIE_RABBIT_NAME,    maxAttacks = 1 } -- 20%
level_5_probability[2] = { probability = 0.4,   type = z.ZOMBIE_MOLE_NAME,      maxAttacks = 0 } -- 20%
level_5_probability[3] = { probability = 0.6,   type = z.ZOMBIE_DOG_NAME,       maxAttacks = 1 } -- 20%
level_5_probability[4] = { probability = 0.8,   type = z.ZOMBIE_PARROT_NAME,    maxAttacks = 1 } -- 20%
level_5_probability[5] = { probability = 1,     type = z.ZOMBIE_PIG_NAME,       maxAttacks = 1 } -- 20%

-- level 6	-- en aquest nivell apareix: none
local level_6_probability = {}
level_6_probability[1] = { probability = 0.1,   type = z.ZOMBIE_RABBIT_NAME,    maxAttacks = 0 } -- 10%
level_6_probability[2] = { probability = 0.35,  type = z.ZOMBIE_MOLE_NAME,      maxAttacks = 1 } -- 25%
level_6_probability[3] = { probability = 0.45,  type = z.ZOMBIE_DOG_NAME,       maxAttacks = 1 } -- 10%
level_6_probability[4] = { probability = 0.55,  type = z.ZOMBIE_PARROT_NAME,    maxAttacks = 1 } -- 10%
level_6_probability[5] = { probability = 1,     type = z.ZOMBIE_PIG_NAME,       maxAttacks = 1 } -- 45%

-- level 7	-- en aquest nivell apareix: cat & fish
local level_7_probability = {}
level_7_probability[1] = { probability = 0.2,    type = z.ZOMBIE_MOLE_NAME,     maxAttacks = 0 } -- 20%
level_7_probability[2] = { probability = 0.3,    type = z.ZOMBIE_DOG_NAME,      maxAttacks = 1 } -- 10%
level_7_probability[3] = { probability = 0.4,    type = z.ZOMBIE_PARROT_NAME,   maxAttacks = 1 } -- 10%
level_7_probability[4] = { probability = 0.6,    type = z.ZOMBIE_PIG_NAME,      maxAttacks = 1 } -- 20%
level_7_probability[5] = { probability = 0.8,    type = z.ZOMBIE_CAT_NAME,      maxAttacks = 1 } -- 20%
level_7_probability[6] = { probability = 1,      type = z.ZOMBIE_FISH_NAME,     maxAttacks = 1 } -- 20%

-- level 8	-- en aquest nivell apareix: tortoise
local level_8_probability = {}
level_8_probability[1] = { probability = 0.15,  type = z.ZOMBIE_RABBIT_NAME,    maxAttacks = 1 } -- 15%
level_8_probability[2] = { probability = 0.35,  type = z.ZOMBIE_MOLE_NAME,      maxAttacks = 0 } -- 20%
level_8_probability[3] = { probability = 0.55,  type = z.ZOMBIE_PIG_NAME,       maxAttacks = 1 } -- 20%
level_8_probability[4] = { probability = 0.7,   type = z.ZOMBIE_CAT_NAME,       maxAttacks = 1 } -- 15%
level_8_probability[5] = { probability = 0.85,  type = z.ZOMBIE_FISH_NAME,      maxAttacks = 1 } -- 15%
level_8_probability[6] = { probability = 1,     type = z.ZOMBIE_TORTOISE_NAME,  maxAttacks = 1 } -- 15%

-- level 9	-- en aquest nivell apareix: none
local level_9_probability = {}
level_9_probability[1] = { probability = 0.08,  type = z.ZOMBIE_RABBIT_NAME,    maxAttacks = 1 } -- 8%
level_9_probability[2] = { probability = 0.23,  type = z.ZOMBIE_MOLE_NAME,      maxAttacks = 0 } -- 15%
level_9_probability[3] = { probability = 0.31,  type = z.ZOMBIE_DOG_NAME,       maxAttacks = 1 } -- 8%
level_9_probability[4] = { probability = 0.39,  type = z.ZOMBIE_PARROT_NAME,    maxAttacks = 1 } -- 8%
level_9_probability[5] = { probability = 0.54,  type = z.ZOMBIE_PIG_NAME,       maxAttacks = 1 } -- 15%
level_9_probability[6] = { probability = 0.62,  type = z.ZOMBIE_CAT_NAME,       maxAttacks = 1 } -- 8%
level_9_probability[7] = { probability = 0.7,   type = z.ZOMBIE_FISH_NAME,      maxAttacks = 1 } -- 8%
level_9_probability[8] = { probability = 1,     type = z.ZOMBIE_TORTOISE_NAME,  maxAttacks = 1 } -- 30%


-- storyboards
stage_storyboard = {}
stage_storyboard[1] = { storyboardImage = "story/assets/story09.jpg", storyboardText = "story_1_1" } -- lvl 0 win
stage_storyboard[2] = { storyboardImage = "story/assets/story01.jpg", storyboardText = "story_1_2" } -- lvl 1 rabbit
stage_storyboard[3] = { storyboardImage = "story/assets/story02.jpg", storyboardText = "story_1_3" } -- lvl 2 mole
stage_storyboard[4] = { storyboardImage = "story/assets/story04.jpg", storyboardText = "story_1_4" } -- lvl 3 dog
stage_storyboard[5] = { storyboardImage = "story/assets/story03.jpg", storyboardText = "story_1_5" } -- lvl 4 parrot
stage_storyboard[6] = { storyboardImage = "story/assets/story05.jpg", storyboardText = "story_1_6" } -- lvl 5 pig
stage_storyboard[7] = { storyboardImage = "story/assets/story06.jpg", storyboardText = "story_1_7" } -- lvl 7 cat&fish
stage_storyboard[8] = { storyboardImage = "story/assets/story07.jpg", storyboardText = "story_1_8" } -- lvl 8 tortoise
stage_storyboard[9] = { storyboardImage = "story/assets/story08.jpg", storyboardText = "story_1_9" } -- lvl 9 all

-- informació persistent dels nivells de l'stage 1
stage_level_info = {}
stage_level_info[1] = { zombies = level_1_probability,
                        lvlJson = "",
                        storyboard = stage_storyboard[2],
                        tip = 2,
                        ingameTip = nil,
                        emblem = 4,
                        zombieSpawnProbability = 900,
                        lollipopSpawnProbability = 5,
                        rakeSpawnProbability = 0,
                        maxZombiesPerScreen = 3,
                        maxZombiesInLevel = 20,
                        waveZombies = 0,
                        maxAttacksPerZombie = 1,
                        minTimePerAttack = 2000,
                        maxTimePerAttack = 3000,
                        medTime = 25000,
                        scoreBones = { 50, 180, 450 } }
stage_level_info[2] = { zombies = level_2_probability,
                        lvlJson = "",
                        storyboard = stage_storyboard[3],
                        tip = 3,
                        ingameTip = nil,
                        emblem = 5,
                        zombieSpawnProbability = 750,
                        lollipopSpawnProbability = 5,
                        rakeSpawnProbability = 0,
                        maxZombiesPerScreen = 4,
                        maxZombiesInLevel = 30,
                        waveZombies = 0,
                        maxAttacksPerZombie = 1,
                        minTimePerAttack = 1000,
                        maxTimePerAttack = 2000,
                        medTime = 55000,
                        scoreBones = { 50, 200, 500 } }
stage_level_info[3] = { zombies = level_3_probability,
                        lvlJson = "",
                        storyboard = stage_storyboard[4],
                        tip = 4,
                        ingameTip = nil,
                        emblem = 6,
                        zombieSpawnProbability = 600,
                        lollipopSpawnProbability = 10,
                        rakeSpawnProbability = 0,
                        maxZombiesPerScreen = 4,
                        maxZombiesInLevel = 40,
                        waveZombies = 0,
                        maxAttacksPerZombie = 1,
                        minTimePerAttack = 1000,
                        maxTimePerAttack = 2000,
                        medTime = 55000,
                        scoreBones = { 50, 300, 700 } }
stage_level_info[4] = { zombies = level_4_probability,
                        lvlJson = "",
                        storyboard = stage_storyboard[5],
                        tip = 0,
                        ingameTip = nil,
                        emblem = 7,
                        zombieSpawnProbability = 450,
                        lollipopSpawnProbability = 5,
                        rakeSpawnProbability = 0,
                        maxZombiesPerScreen = 5,
                        maxZombiesInLevel = 50,
                        waveZombies = 0,
                        maxAttacksPerZombie = 1, --2,
                        minTimePerAttack = 1000,
                        maxTimePerAttack = 2000,
                        medTime = 55000,
                        scoreBones = { 50, 350, 800 } }
stage_level_info[5] = { zombies = level_5_probability,
                        lvlJson = "",
                        storyboard = stage_storyboard[6],
                        tip = 5,
                        ingameTip = nil,
                        emblem = 8,
                        zombieSpawnProbability = 300,
                        lollipopSpawnProbability = 4,
                        rakeSpawnProbability = 0,
                        maxZombiesPerScreen = 5,
                        maxZombiesInLevel = 60,
                        waveZombies = 0,
                        maxAttacksPerZombie = 1, --2,
                        minTimePerAttack = 1000,
                        maxTimePerAttack = 1000,
                        medTime = 55000,
                        scoreBones = { 50, 500, 1000 } }
stage_level_info[6] = { zombies = level_6_probability,
                        lvlJson = "",
                        storyboard = nil,
                        tip = 11,
                        ingameTip = nil,
                        emblem = 9,
                        zombieSpawnProbability = 250,
                        lollipopSpawnProbability = 4,
                        rakeSpawnProbability = 0,
                        maxZombiesPerScreen = 6,
                        maxZombiesInLevel = 65,
                        waveZombies = 10,
                        maxAttacksPerZombie = 1, --2,
                        minTimePerAttack = 500,
                        maxTimePerAttack = 1000,
                        medTime = 55000,
                        scoreBones = { 50, 600, 1200 } }
stage_level_info[7] = { zombies = level_7_probability,
                        lvlJson = "",
                        storyboard = stage_storyboard[7],
                        tip = 0,
                        ingameTip = nil,
                        emblem = 10,
                        zombieSpawnProbability = 200,
                        lollipopSpawnProbability = 3,
                        rakeSpawnProbability = 0,
                        maxZombiesPerScreen = 7,
                        maxZombiesInLevel = 75,
                        waveZombies = 15,
                        maxAttacksPerZombie = 1, --3,
                        minTimePerAttack = 600,
                        maxTimePerAttack = 700,
                        medTime = 60000,
                        scoreBones = { 50, 700, 1500 } }
stage_level_info[8] = { zombies = level_8_probability,
                        lvlJson = "",
                        storyboard = stage_storyboard[8],
                        tip = 7,
                        ingameTip = nil,
                        emblem = 11,
                        zombieSpawnProbability = 150,
                        lollipopSpawnProbability = 3,
                        rakeSpawnProbability = 0,
                        maxZombiesPerScreen = 8,
                        maxZombiesInLevel = 85,
                        waveZombies = 20,
                        maxAttacksPerZombie = 1, --3,
                        minTimePerAttack = 500,
                        maxTimePerAttack = 500,
                        medTime = 60000,
                        scoreBones = { 50, 800, 1700 } }
stage_level_info[9] = { zombies = level_9_probability,
                        lvlJson = "",
                        storyboard = stage_storyboard[9],
                        tip = 0,
                        ingameTip = nil,
                        emblem = 12,
                        zombieSpawnProbability = 100,
                        lollipopSpawnProbability = 2,
                        rakeSpawnProbability = 0,
                        maxZombiesPerScreen = 9,
                        maxZombiesInLevel = 90,
                        waveZombies = 25,
                        maxAttacksPerZombie = 1, --3,
                        minTimePerAttack = 300,
                        maxTimePerAttack = 400,
                        medTime = 70000,
                        scoreBones = { 50, 800, 1900 } }