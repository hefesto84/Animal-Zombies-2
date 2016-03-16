module(..., package.seeall)

-- modul exclusiu per a les animacions
-- la durada d'una animació es calcula de la següent manera: nFrames * 75

-- efectes
local spawnInfo     = nil
local disappearInfo = nil
local killInfo      = nil
local mushroomInfo  = nil
local warningInfo   = nil
local biteInfo      = nil
local scratchInfo   = nil
local lollipopInfo  = nil
local rakeInfo      = nil
local boneInfo      = nil

-- zombies
local rabbitInfo    = nil
local moleInfo      = nil
local dogInfo       = nil
local parrotInfo    = nil
local pigInfo       = nil
local catInfo       = nil
local fishInfo      = nil
local tortoiseInfo  = nil
local queenInfo     = nil
local chihuahuaInfo = nil
local duckInfo      = nil
local turkeyInfo    = nil
local cageInfo      = nil
local ratInfo       = nil
local possumInfo    = nil
local bearInfo      = nil
local mooseInfo     = nil
local skunkInfo     = nil

local zombieImageSheet =    { width = 128,  height = 128,   numFrames = 32, contentWidth = 512,     contentHeight = 1024 }
local kindlyZombieSheet =   { width = 128,  height = 128,   numFrames = 64, contentWidth = 1024,    contentHeight = 1024 }
local attacksImageSheet =   { width = 128,  height = 128,   numFrames = 8,  contentWidth = 256,     contentHeight = 512 }

local hiddingFrames = { 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 }

--------------------- EFECTES ---------------------
function spawnAnim()
    if spawnInfo == nil then
        --print("Spawn doesn't exist. We create it")
        spawnInfo = {}
        spawnInfo.sheetData = zombieImageSheet
        spawnInfo.imageSheet = graphics.newImageSheet("assets/SpriteSheets/entrada.png", spawnInfo.sheetData)
        spawnInfo.sequenceData = {  { name = "spawn1",  sheet = spawnInfo.imageSheet,   start = 1,  count = 5,  time = 375,     loopCount = 1 },
                                    { name = "spawn2",  sheet = spawnInfo.imageSheet,   start = 6,  count = 26, time = 1950,    loopCount = 1 } }
    end
    
    return spawnInfo
end

function disappearAnim()
    if disappearInfo == nil then
        --print("Disappear doesn't exist. We create it")
        disappearInfo = {}
        disappearInfo.sheetData = zombieImageSheet
        disappearInfo.imageSheet = graphics.newImageSheet("assets/SpriteSheets/salir.png", disappearInfo.sheetData)
        disappearInfo.sequenceData = {  { name = "disappear1",  sheet = disappearInfo.imageSheet,   start = 1,  count = 12, time = 900,     loopCount = 1 },
                                        { name = "disappear2",  sheet = disappearInfo.imageSheet,   start = 13, count = 19, time = 1425,    loopCount = 1 } }
    end
    
    return disappearInfo
end

local function killAnim()
    if killInfo == nil then
        --print("Kill doesn't exist. We create it")
        killInfo = {}
        killInfo.sheetData = zombieImageSheet
        killInfo.imageSheet1 = graphics.newImageSheet("assets/SpriteSheets/muerte1.png", killInfo.sheetData)
        killInfo.imageSheet2 = graphics.newImageSheet("assets/SpriteSheets/muerte2.png", killInfo.sheetData)
        killInfo.sequenceData = {   { name = "kill1",   sheet = killInfo.imageSheet1,   start = 1,  count = 32, time = 1350,    loopCount = 1 },
                                    { name = "kill2",   sheet = killInfo.imageSheet2,   start = 1,  count = 32, time = 1350,    loopCount = 1 } }
    end
    
    return killInfo.sequenceData
end

local function mushroomAnim()
    if mushroomInfo == nil then
        --print("Mushroom doesn't exist. We create it")
        mushroomInfo = {}
        mushroomInfo.sheetData = zombieImageSheet
        mushroomInfo.imageSheet = graphics.newImageSheet("assets/SpriteSheets/seta.png", mushroomInfo.sheetData)
        mushroomInfo.sequenceData = { name = "mushroom",    sheet = mushroomInfo.imageSheet,    start = 1,  count = 32, time = 2400,    loopCount = 1 }
    end
    
    return mushroomInfo
end

function warningAnim()
    if warningInfo == nil then
        --print("Warning doesn't exist. We create it")
        warningInfo = {}
        warningInfo.sheetData = { width = 128, height = 128, numFrames = 2, contentWidth = 256, contentHeight = 128 }
        warningInfo.imageSheet = graphics.newImageSheet("assets/SpriteSheets/avisorojo.png", warningInfo.sheetData)
        warningInfo.sequenceData = { name = "warning", sheet = warningInfo.imageSheet, start = 1, count = 2, time = 400, loopCount = 5 }
    end
    
    return warningInfo
end

function biteAnim()
    if biteInfo == nil then
        --print("Bite doesn't exist. We create it")
        biteInfo = {}
        biteInfo.scale = SCALE_DEFAULT + SCALE_DEFAULT
        biteInfo.sheetData = attacksImageSheet
        biteInfo.sound = AZ.soundLibrary.biteSound
        biteInfo.imageSheet = graphics.newImageSheet("assets/SpriteSheets/bite.png", biteInfo.sheetData)
        biteInfo.sequenceData = { name = "bite",   sheet = biteInfo.imageSheet, start = 1,  count = 8,  time = 600, loopCount = 1 }
    end
    
    return biteInfo
end

function scratchAnim()
    if scratchInfo == nil then
        --print("Scratch doesn't exist. We create it")
        scratchInfo = {}
        scratchInfo.scale = SCALE_DEFAULT + SCALE_DEFAULT
        scratchInfo.sheetData = attacksImageSheet
        scratchInfo.sound = AZ.soundLibrary.scratchSound
        scratchInfo.imageSheet = graphics.newImageSheet("assets/SpriteSheets/scratch.png", scratchInfo.sheetData)
        scratchInfo.sequenceData = { name = "scratch",   sheet = scratchInfo.imageSheet, start = 1,  count = 8,  time = 600, loopCount = 1 }
    end
    
    return scratchInfo
end

local function defaultPowerUpAnim(powerUpImagePath, getImagePath)
    local powerUpInfo               = {}
    powerUpInfo.sheetData           = { width = 64, height = 64, numFrames = 16, contentWidth = 256, contentHeight = 256 }
    powerUpInfo.imageSheet1         = graphics.newImageSheet(powerUpImagePath,  powerUpInfo.sheetData)
    powerUpInfo.imageSheet2         = graphics.newImageSheet(getImagePath,      powerUpInfo.sheetData)
    powerUpInfo.sequenceData        = { { name = "fall",    sheet = powerUpInfo.imageSheet1,    start = 1,  count = 16, time = 1200 },
                                        { name = "get",     sheet = powerUpInfo.imageSheet2,    start = 1,  count = 16, time = 800, loopCount = 1 } }
    
    return powerUpInfo
end

function lollipopAnim()
    if lollipopInfo == nil then
        --print("Lollipop doesn't exist. We create it")
        lollipopInfo = defaultPowerUpAnim("assets/SpriteSheets/lollipop.png", "assets/SpriteSheets/pickup.png")
    end
    
    return lollipopInfo
end

function rakeAnim()
    if rakeInfo == nil then
        --print("Rake doesn't exist. We create it")
        rakeInfo = defaultPowerUpAnim("assets/SpriteSheets/rake.png", "assets/SpriteSheets/pickup.png")
    end
    
    return rakeInfo
end

function boneAnim()
    if boneInfo == nil then
        --print("Bone doesn't exist. We create it")
        boneInfo = {}
        boneInfo.sheetData      = { width = 128, height = 128, numFrames = 8, contentWidth = 256, contentHeight = 512 }
        boneInfo.imageSheet     = graphics.newImageSheet("assets/SpriteSheets/boneWinDust.png", boneInfo.sheetData)
        boneInfo.sequenceData   = { name = "bone spawn", sheet = boneInfo.imageSheet, start = 1, count = 8, time = 600, loopCount = 1 }
   end
   
   return boneInfo
end

--------------------- ZOMBIES ---------------------
local function defaultAnim(path)
    local zombieInfo = {}
    zombieInfo.sheetData = zombieImageSheet
    zombieInfo.imageSheet = graphics.newImageSheet(path, zombieInfo.sheetData)
    local kill = killAnim()
    zombieInfo.sequenceData =   {   { name = "spawn",   sheet = zombieInfo.imageSheet, start = 1,  count = 12,  time = 900,     loopCount = 1 },
                                    { name = "idle",    sheet = zombieInfo.imageSheet, start = 13, count = 20,  time = 1500 },
                                    { name = "hide",    sheet = zombieInfo.imageSheet, frames = hiddingFrames,  time = 900,     loopCount = 1 },
                                    kill[1], kill[2] }
    return zombieInfo
end

function rabbitAnim()
    if rabbitInfo == nil then
        --print("Rabbit doesn't exist. We create it")
        rabbitInfo = defaultAnim("assets/SpriteSheets/conejo.png")
        rabbitInfo.attacks = { biteAnim(), scratchAnim() }
    end
    
    return rabbitInfo
end

function moleAnim()
    if moleInfo == nil then
        --print("Mole doesn't exist. We create it")
        moleInfo = {}
        moleInfo.sheetData = kindlyZombieSheet
        moleInfo.imageSheet = graphics.newImageSheet("assets/SpriteSheets/topo.png", moleInfo.sheetData)
        moleInfo.sequenceData = {   { name = "spawn",   sheet = moleInfo.imageSheet,    start = 1,  count = 12,     time = 900,     loopCount = 1 },
                                    { name = "idle",    sheet = moleInfo.imageSheet,    start = 13, count = 20,     time = 1500 },
                                    { name = "hide",    sheet = moleInfo.imageSheet,    frames = hiddingFrames,     time = 900,     loopCount = 1 },
                                    { name = "kill",    sheet = moleInfo.imageSheet,    start = 34, count = 30,     time = 2250,    loopCount = 1 } }
        moleInfo.attacks = {}
    end
    
    return moleInfo
end

function dogAnim()
    if dogInfo == nil then
        --print("Dog doesn't exist. We create it")
        dogInfo = defaultAnim("assets/SpriteSheets/perro.png")
        dogInfo.attacks = { biteAnim(), scratchAnim() }
    end
    
    return dogInfo
end

function parrotAnim()
    if parrotInfo == nil then
        --print("Parrot doesn't exist. We create it")
        parrotInfo = defaultAnim("assets/SpriteSheets/loro.png")
        parrotInfo.attacks = { biteAnim() }
    end
    
    return parrotInfo
end

function pigAnim()
    if pigInfo == nil then
        --print("Pig doesn't exist. We create it")
        pigInfo = {}
        local mushroom = mushroomAnim()
        pigInfo.sheetData = zombieImageSheet
        pigInfo.imageSheet = graphics.newImageSheet("assets/SpriteSheets/cerdo.png", pigInfo.sheetData)
        local kill = killAnim()
        pigInfo.sequenceData =  {   { name = "spawn",       sheet = pigInfo.imageSheet, start = 1,  count = 12, time = 900,     loopCount = 1 },
                                    { name = "idle",        sheet = pigInfo.imageSheet, start = 13, count = 5,  time = 375 },
                                    { name = "hide",        sheet = pigInfo.imageSheet, frames = hiddingFrames, time = 900,     loopCount = 1 },
                                    { name = "explosion",   sheet = pigInfo.imageSheet, start = 19, count = 13, time = 650,     loopCount = 1 },
                                    mushroom.sequenceData,
                                    kill[1], kill[2] }
        pigInfo.attacks = {}
    end
    
    return pigInfo
end

function catAnim()
    if catInfo == nil then
        --print("Cat doesn't exist. We create it")
        catInfo = defaultAnim("assets/SpriteSheets/gato.png")
        catInfo.attacks = { biteAnim(), scratchAnim() }
    end
    
    return catInfo
end

function fishAnim()
    if fishInfo == nil then
        --print("Fish doesn't exist. We create it")
        fishInfo = defaultAnim("assets/SpriteSheets/pez.png")
        fishInfo.attacks = { biteAnim() }
    end
    
    return fishInfo
end

function tortoiseAnim()
    if tortoiseInfo == nil then
        --print("Tortoise doesn't exist. We create it")
        tortoiseInfo = defaultAnim("assets/SpriteSheets/tortuga.png")
        tortoiseInfo.attacks = { biteAnim() }
    end
    
    return tortoiseInfo
end

function queenAnim()
    if queenInfo == nil then
        --print("Queen doesn't exist. We create it")
        queenInfo = {}
        queenInfo.imageSheet = graphics.newImageSheet("assets/SpriteSheets/queen.png", kindlyZombieSheet)
        queenInfo.sequenceData = {  { name = "spawn",   sheet = queenInfo.imageSheet,   start = 1,  count = 12, time = 900,     loopCount = 1 },
                                    { name = "idle",    sheet = queenInfo.imageSheet,   start = 13, count = 20, time = 1500 },
                                    { name = "hide",    sheet = queenInfo.imageSheet,   frames = hiddingFrames, time = 900,     loopCount = 1 },
                                    { name = "kill",    sheet = queenInfo.imageSheet,   start = 34, count = 30, time = 2250,    loopCount = 1 } }
        queenInfo.attacks = {}
    end
    
    return queenInfo
end

function chihuahuaAnim()
    if chihuahuaInfo == nil then
        --print("Chihuahua doesn't exist. We create it")
        chihuahuaInfo = defaultAnim("assets/SpriteSheets/chihuahua.png")
        chihuahuaInfo.attacks = { biteAnim(), scratchAnim() }
    end
    
    return chihuahuaInfo
end

function duckAnim()
    if duckInfo == nil then
        --print("Duck doesn't exist. We create it")
        duckInfo = defaultAnim("assets/SpriteSheets/duck.png")
        duckInfo.attacks = { biteAnim() }
    end
    
    return duckInfo
end

function turkeyAnim()
    if turkeyInfo == nil then
        --print("Turkey doesn't exist. We create it")
        turkeyInfo = defaultAnim("assets/SpriteSheets/turkey.png")
        turkeyInfo.attacks = { biteAnim() }
    end
    
    return turkeyInfo
end

function cageAnim()
    if cageInfo == nil then
        --print("Cage doesn't exist. We create it")
        cageInfo = defaultAnim("assets/SpriteSheets/cage.png")
        cageInfo.attacks = { scratchAnim() }
    end
    
    return cageInfo
end

function ratAnim()
    if ratInfo == nil then
        --print("Rat doesn't exist. We create it")
        ratInfo = defaultAnim("assets/SpriteSheets/rat.png")
        ratInfo.attacks = { scratchAnim(), biteAnim() }
    end
    
    return ratInfo
end

function possumAnim()
    if possumInfo == nil then
        --print("Possum doesn't exist. We create it")
        possumInfo = defaultAnim("assets/SpriteSheets/rat.png")
        possumInfo.attacks = { scratchAnim(), biteAnim() }
    end
    
    return possumInfo
end

function bearAnim()
    if bearInfo == nil then
        --print("Bear doesn't exist. We create it")
        bearInfo = defaultAnim("assets/SpriteSheets/rat.png")
        bearInfo.attacks = { scratchAnim(), biteAnim() }
    end
    
    return bearInfo
end

function mooseAnim()
    if mooseInfo == nil then
        --print("Moose doesn't exist. We create it")
        mooseInfo = defaultAnim("assets/SpriteSheets/rat.png")
        mooseInfo.attacks = { scratchAnim(), biteAnim() }
    end
    
    return mooseInfo
end

function skunkAnim()
    if skunkInfo == nil then
        --print("Skunk doesn't exist. We create it")
        skunkInfo = defaultAnim("assets/SpriteSheets/rat.png")
        skunkInfo.attacks = { scratchAnim(), biteAnim() }
    end
    
    return skunkInfo
end

function freeAnimMemory(anim, animName)
    if anim ~= nil then
        --print("Let's free memory: ".. animName)
        display.remove(anim)
    end
    
    return nil
end

function cleanUp()
    spawnInfo       = freeAnimMemory(spawnInfo, "spawn info")
    disappearInfo   = freeAnimMemory(disappearInfo, "disappear info")
    killInfo        = freeAnimMemory(killInfo, "kill info")
    mushroomInfo    = freeAnimMemory(mushroomInfo, "mushroom info")
    warningInfo     = freeAnimMemory(warningInfo, "warning info")
    biteInfo        = freeAnimMemory(biteInfo, "bite info")
    scratchInfo     = freeAnimMemory(scratchInfo, "scratch info")
    lollipopInfo    = freeAnimMemory(lollipopInfo, "lollipop info")
    rakeInfo        = freeAnimMemory(rakeInfo, "rake info")
    boneInfo        = freeAnimMemory(boneInfo, "bone info")
    rabbitInfo      = freeAnimMemory(rabbitInfo, "rabbit info")
    moleInfo        = freeAnimMemory(moleInfo, "mole info")
    dogInfo         = freeAnimMemory(dogInfo, "dog info")
    parrotInfo      = freeAnimMemory(parrotInfo, "parrot info")
    pigInfo         = freeAnimMemory(pigInfo, "pigInfo info")
    catInfo         = freeAnimMemory(catInfo, "cat info")
    fishInfo        = freeAnimMemory(fishInfo, "fish info")
    tortoiseInfo    = freeAnimMemory(tortoiseInfo, "tortoise info")
    queenInfo       = freeAnimMemory(queenInfo, "queen info")
    chihuahuaInfo   = freeAnimMemory(chihuahuaInfo, "chihuahua info")
    duckInfo        = freeAnimMemory(duckInfo, "duck info")
    turkeyInfo      = freeAnimMemory(turkeyInfo, "turkey info")
    cageInfo        = freeAnimMemory(cageInfo, "cage info")
    ratInfo         = freeAnimMemory(ratInfo, "rat info")
    possumInfo      = freeAnimMemory(possumInfo, "possum info")
    bearInfo        = freeAnimMemory(bearInfo, "bear info")
    mooseInfo       = freeAnimMemory(mooseInfo, "moose info")
    skunkInfo       = freeAnimMemory(skunkInfo, "skunk info")
end