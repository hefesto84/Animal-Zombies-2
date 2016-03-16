module(..., package.seeall)

-- efectes
local boneInfo              = nil
local spawnInfo             = nil
local disappearInfo         = nil
local killInfo              = nil
local pigExplosionInfo      = nil
local explosionCloudInfo    = nil
local objectDestroyInfo     = nil
local iceDestroyInfo        = nil
local warningInfo           = nil
local biteInfo              = nil
local scratchInfo           = nil
local lifeDeathBoxInfo      = nil
local eatingPropInfo        = nil
local hoseWaterInfo         = nil
local pigeonInfo            = nil
local thunderInfo           = nil
local trapInfo              = nil
local powerUpSparkInfo      = nil

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
local scoutInfo     = nil
local uterInfo      = nil

local animsPath = "assets/SpriteSheets/new/"

local smallImageSheet = { width = 128,  height = 128,   numFrames = 8,  contentWidth = 256, contentHeight = 512 }
local bigImageSheet =   { width = 128,  height = 128,   numFrames = 16, contentWidth = 512, contentHeight = 512 }

-- funció per a seteig de temps d'animacions
local function setAnimTime(sprite, timePerFrame)
    timePerFrame = timePerFrame or 90
    
    local seq = sprite.sequenceData
    
    for i = 1, #seq do
        
        local _seq = seq[i]
        
        if _seq.time == nil then
            if _seq.count ~= nil then
                _seq.time = _seq.count * timePerFrame
            else
                _seq.time = #_seq.frames * timePerFrame
            end
            
            _seq.framerate = timePerFrame
        elseif _seq.framerate == nil then
            if _seq.count ~= nil then
                _seq.framerate = math.floor(_seq.time / _seq.count)
            else
                _seq.framerate = math.floor(_seq.time / #_seq.frames)
            end
        end
        
        seq[i] = _seq
    end
    
    sprite.getAnimFramerate = function(animName)
        for i = 1, #seq do
            if seq[i].name == animName then
                return seq[i].framerate
            end    
        end

        print("", "", sprite.name .." doesn't have an anim called ".. animName)
        return 0
    end
    
end

--------------------- EFECTES ---------------------
function getEffAnim(filename, isBig, params)
    local effect = {}
    
    local effName = string.gsub(filename, ".png", "")
    local loopDirection = params.loopDirection or "forward"
    local loopCount = params.loopCount or 1
    effect.sheetData = smallImageSheet
    if isBig then
        effect.sheetData = bigImageSheet
    end
    effect.name = effName .."Anim"
    effect.imageSheet = graphics.newImageSheet(animsPath .. filename, effect.sheetData)
    effect.is = effect.imageSheet
    effect.sequenceData = { { name = effName, sheet = effect.imageSheet, start = 1, count = effect.sheetData.numFrames, loopCount = loopCount, loopDirection = loopDirection } }
    setAnimTime(effect, params.framerate)
    
    return effect
end

function boneAnim()
    if boneInfo == nil then
        boneInfo = getEffAnim("boneDust.png", true, { framerate =  40 })
    end
   
    return boneInfo
end

function spawnAnim()
    if spawnInfo == nil then
        spawnInfo = {}
        spawnInfo.name = "appearEffectAnim"
        spawnInfo.sheetData = bigImageSheet
        spawnInfo.imageSheet = graphics.newImageSheet(animsPath .."appearEffect.png", spawnInfo.sheetData)
        spawnInfo.sequenceData = {  { name = "spawn1Effect",    sheet = spawnInfo.imageSheet,   start = 1,  count = 4,  loopCount = 1 },
                                    { name = "spawn2Effect",    sheet = spawnInfo.imageSheet,   start = 5,  count = 12, loopCount = 1 } }
        setAnimTime(spawnInfo, 70)
    end
    
    return spawnInfo
end

function disappearAnim()
    if disappearInfo == nil then
        disappearInfo = getEffAnim("disappearEffect.png", true, { loopCount = 1, framerate = 70 })
    end
    
    return disappearInfo
end

local function killAnim()
    if killInfo == nil then
        killInfo = {}
        killInfo.name = "killEffectAnim"
        killInfo.sheetData1 = bigImageSheet
        killInfo.sheetData2 = smallImageSheet
        killInfo.imageSheet1 = graphics.newImageSheet(animsPath .."killEffect1.png",    killInfo.sheetData1)
        killInfo.imageSheet2 = graphics.newImageSheet(animsPath .."killEffect2.png",    killInfo.sheetData1)
        killInfo.imageSheet3 = graphics.newImageSheet(animsPath .."airKillEffect.png",  killInfo.sheetData2)
        killInfo.sequenceData = {   { name = "kill1Effect",     sheet = killInfo.imageSheet1,   start = 1,  count = 16, loopCount = 1 },
                                    { name = "kill2Effect",     sheet = killInfo.imageSheet2,   start = 1,  count = 16, loopCount = 1 },
                                    { name = "airKillEffect",   sheet = killInfo.imageSheet3,   start = 1,  count = 8,  loopCount = 1 } }
        setAnimTime(killInfo, 50)
    end
    
    return killInfo.sequenceData
end

local function pigExplosionAnim()
    if pigExplosionInfo == nil then
        pigExplosionInfo = getEffAnim("pigExplosionEffect.png", true, { loopCount = 1 })
    end
    
    return pigExplosionInfo
end

function explosionCloudAnim()
    if explosionCloudInfo == nil then
        explosionCloudInfo = getEffAnim("explosionCloudEffect.png", true, { loopCount = 1, framerate = 70 })
    end
    
    return explosionCloudInfo
end

function objectDestroyAnim()
    if objectDestroyInfo == nil then
        objectDestroyInfo = getEffAnim("objectDestroyEffect.png", true, { framerate = 70 })
    end
    
    return objectDestroyInfo
end

function iceDestroyAnim()
    if iceDestroyInfo == nil then
        iceDestroyInfo = getEffAnim("iceDestroyEffect.png", true, { loopCount = 1, framerate = 70 })
    end
    
    return iceDestroyInfo
end

function warningAnim()
    if warningInfo == nil then
        warningInfo = {}
        warningInfo.name = "warningEffectAnim"
        warningInfo.sheetData = { width = 128, height = 128, numFrames = 2, contentWidth = 256, contentHeight = 128 }
        warningInfo.imageSheet = graphics.newImageSheet(animsPath .."warningEffect.png", warningInfo.sheetData)
        warningInfo.sequenceData = { name = "warningEffect", sheet = warningInfo.imageSheet, start = 1, count = 2, time = 400, loopCount = 5 }
    end
    
    return warningInfo
end

function biteAnim()
    if biteInfo == nil then
        biteInfo = getEffAnim("biteEffect.png", false, { loopCount = 1 })
        biteInfo.sound = AZ.soundLibrary.biteSound
    end
    
    return biteInfo
end

function scratchAnim()
    if scratchInfo == nil then
        scratchInfo = getEffAnim("scratchEffect.png", false, { loopCount = 1 })
        scratchInfo.sound = AZ.soundLibrary.scratchSound
    end
    
    return scratchInfo
end

function lifeDeathBoxAnim()
    if lifeDeathBoxInfo == nil then
        lifeDeathBoxInfo = {}
        lifeDeathBoxInfo.name = "lifeBoxEffectAnim"
        lifeDeathBoxInfo.sheetData1 = smallImageSheet
        lifeDeathBoxInfo.sheetData2 = bigImageSheet
        lifeDeathBoxInfo.imageSheet1 = graphics.newImageSheet(animsPath .."lifeBoxDisappearEffect.png",     lifeDeathBoxInfo.sheetData1)
        lifeDeathBoxInfo.imageSheet2 = graphics.newImageSheet(animsPath .."deathBoxExplosionEffect.png",    lifeDeathBoxInfo.sheetData2)
        lifeDeathBoxInfo.sequenceData = {   { name = "lifeBoxDisappearEffect",    sheet = lifeDeathBoxInfo.imageSheet1,   start = 1,  count = 8,  loopCount = 1 },
                                            { name = "deathBoxExplosionEffect",   sheet = lifeDeathBoxInfo.imageSheet2,   start = 1,  count = 16, loopCount = 1 },
                                            objectDestroyAnim().sequenceData[1] }
        setAnimTime(lifeDeathBoxInfo, 60)
    end
    
    return lifeDeathBoxInfo
end
    
function eatingPropAnim()
    if eatingPropInfo == nil then
        eatingPropInfo = getEffAnim("eatingPropEffect.png", true, { framerate = 50, loopCount = 0 })
    end
    
    return eatingPropInfo
end

function hoseWaterAnim()
    if hoseWaterInfo == nil then
        hoseWaterInfo = getEffAnim("hoseWaterEffect.png", false, { loopCount = 0, framerate = 30 })
    end
    
    return hoseWaterInfo
end

function pigeonAnim()
    if pigeonInfo == nil then
        pigeonInfo = getEffAnim("pigeonEffect.png", false, { framerate = 30, loopCount = 0, loopDirection = "bounce" })
    end
    
    return pigeonInfo
end

function thunderAnim()
    if thunderInfo == nil then
        thunderInfo = getEffAnim("thunderEffect.png", false, { framerate = 50, loopCount = 0 })
    end
    
    return thunderInfo
end

function trapAnim()
    if trapInfo == nil then
        trapInfo = {}
        trapInfo.name = "trapEffectAnim"
        trapInfo.sheetData = smallImageSheet
        trapInfo.imageSheet = graphics.newImageSheet(animsPath .."trapEffect.png", trapInfo.sheetData)
        trapInfo.sequenceData = {   { name = "plantedEffect",   sheet = trapInfo.imageSheet,    start = 1,  count = 1,  time = 1 },
                                    { name = "attackEffect",    sheet = trapInfo.imageSheet,    start = 2,  count = 7, loopCount = 1 } }
        setAnimTime(trapInfo)
    end
    
    return trapInfo
end

function powerUpSparkAnim()
    if powerUpSparkInfo == nil then
        powerUpSparkInfo = {}
        powerUpSparkInfo.name = "sparkEffectAnim"
        powerUpSparkInfo.sheetData = { width = 64, height = 64, numFrames = 16, contentWidth = 256, contentHeight = 256 }
        powerUpSparkInfo.imageSheet = graphics.newImageSheet(animsPath .."pickup.png",  powerUpSparkInfo.sheetData)
        powerUpSparkInfo.sequenceData = { { name = "sparkEffect", sheet = powerUpSparkInfo.imageSheet, start = 1, count = 16, loopCount = 1 } }

        setAnimTime(powerUpSparkInfo, 60)
    end
    
    return powerUpSparkInfo
end

--------------------- ZOMBIES ---------------------
local function getNormalZombie(filename, params)
    
    params = params or {}
    
    local loopDirection = params.loopDirection or "forward"
    local idleFrames = nil
    local idleStart = 1
    local idleCount = 8
    
    if params.frames ~= nil then
        idleFrames = params.frames
        idleStart = nil
        idleCount = nil
    end
    
    local zombieInfo = {}
    zombieInfo.name = string.gsub(filename, ".png", "Anim")
    zombieInfo.sheetData = smallImageSheet
    zombieInfo.imageSheet = graphics.newImageSheet(animsPath .. filename, zombieInfo.sheetData)
    local kill = killAnim()
    zombieInfo.sequenceData =   {   { name = "idle", sheet = zombieInfo.imageSheet, start = idleStart, count = idleCount, frames = idleFrames, loopDirection = loopDirection },
                                    kill[1], kill[2], kill[3] }
    setAnimTime(zombieInfo, params.framerate)
    return zombieInfo
end

local function getKindlyZombie(filename)
    
    local zombieInfo = {}
    zombieInfo.name = string.gsub(filename, ".png", "Anim")
    zombieInfo.sheetData = bigImageSheet
    zombieInfo.imageSheet = graphics.newImageSheet(animsPath .. filename, zombieInfo.sheetData)
    zombieInfo.sequenceData =   {   { name = "idle", sheet = zombieInfo.imageSheet, start = 1, count = 8 },
                                    { name = "kill", sheet = zombieInfo.imageSheet, start = 9, count = 8, loopCount = 1 } }
    setAnimTime(zombieInfo)
    return zombieInfo
end

function rabbitAnim()
    if rabbitInfo == nil then
        rabbitInfo = getNormalZombie("rabbit.png", { loopDirection = "bounce"} )
        rabbitInfo.attacks = { biteAnim(), scratchAnim() }
    end
    
    return rabbitInfo
end

function moleAnim()
    if moleInfo == nil then
        moleInfo = getKindlyZombie("mole.png")
    end
    
    return moleInfo
end

function dogAnim()
    if dogInfo == nil then
        dogInfo = getNormalZombie("dog.png")
        dogInfo.attacks = { biteAnim(), scratchAnim() }
    end
    
    return dogInfo
end

function parrotAnim()
    if parrotInfo == nil then
        parrotInfo = getNormalZombie("parrot.png", { frames = { 1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5, 6, 7, 8, 7, 6, 5, 6, 7, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1, 1 }, framerate = 50 })
        parrotInfo.attacks = { biteAnim() }
    end
    
    return parrotInfo
end

function pigAnim()
    if pigInfo == nil then
        pigInfo = {}
        pigInfo.name = "pigAnim"
        local mushroom = pigExplosionAnim()
        pigInfo.sheetData = bigImageSheet
        pigInfo.imageSheet = graphics.newImageSheet(animsPath .."pig.png", pigInfo.sheetData)
        local kill = killAnim()
        pigInfo.sequenceData =  {   { name = "idle",    sheet = pigInfo.imageSheet, start = 1, count = 3,   time = 350, loopDirection = "bounce" },
                                    { name = "swellUp", sheet = pigInfo.imageSheet, start = 1, count = 16,  loopCount = 1 },
                                    mushroom.sequenceData[1],
                                    kill[1], kill[2], kill[3] }
        setAnimTime(pigInfo)
        pigInfo.attacks = {}
    end
    
    return pigInfo
end

function catAnim()
    if catInfo == nil then
        catInfo = getNormalZombie("cat.png", { loopDirection = "bounce" })
        catInfo.attacks = { biteAnim(), scratchAnim() }
    end
    
    return catInfo
end

function fishAnim()
    if fishInfo == nil then
        fishInfo = getNormalZombie("fish.png", { framerate = 60, frames = { 1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5, 6, 7, 8, 7, 6, 5, 6, 7, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1 } })
        fishInfo.attacks = { biteAnim() }
    end
    
    return fishInfo
end

function tortoiseAnim()
    if tortoiseInfo == nil then
        tortoiseInfo = getNormalZombie("tortoise.png", { loopDirection = "bounce" })
        tortoiseInfo.attacks = { biteAnim() }
    end
    
    return tortoiseInfo
end

function queenAnim()
    if queenInfo == nil then
        queenInfo = getKindlyZombie("queen.png")
    end
    
    return queenInfo
end

function chihuahuaAnim()
    if chihuahuaInfo == nil then
        chihuahuaInfo = getNormalZombie("chihuahua.png", { loopDirection = "bounce", frames = { 1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5, 6, 7, 8 } })
        chihuahuaInfo.attacks = { biteAnim(), scratchAnim() }
    end
    
    return chihuahuaInfo
end

function duckAnim()
    if duckInfo == nil then
        duckInfo = getNormalZombie("duck.png", { framerate = 70, frames = { 1, 2, 3, 4, 5, 6, 7, 8, 7, 8, 7, 8, 7, 8, 7, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1 } })
        duckInfo.attacks = { biteAnim() }
    end
    
    return duckInfo
end

function turkeyAnim()
    if turkeyInfo == nil then
        turkeyInfo = getNormalZombie("turkey.png", { framerate = 50, frames = { 1, 2, 3, 2, 1, 2, 3, 2, 1, 2, 3, 4, 5, 6, 7, 8, 8 }, loopDirection = "bounce" })
        turkeyInfo.attacks = { biteAnim() }
    end
    
    return turkeyInfo
end

function cageAnim()
    if cageInfo == nil then
        cageInfo = getNormalZombie("cage.png", { loopDirection = "bounce" })
        cageInfo.attacks = { scratchAnim() }
    end
    
    return cageInfo
end

function ratAnim()
    if ratInfo == nil then
        ratInfo = getNormalZombie("rat.png", { frames = { 1, 1, 1, 2, 3, 4, 5, 6, 7, 8, 7, 8, 7, 6, 5 }, loopDirection = "bounce" })
        ratInfo.attacks = { biteAnim() }
    end
    
    return ratInfo
end

function possumAnim()
    if possumInfo == nil then
        possumInfo = {}
        possumInfo.name = "possumAnim"
        possumInfo.sheetData = bigImageSheet
        local kill = killAnim()
        possumInfo.imageSheet = graphics.newImageSheet(animsPath .."possum.png", possumInfo.sheetData)
        possumInfo.sequenceData = { { name = "idle",    sheet = possumInfo.imageSheet,  start = 9, count = 8, loopDirection = "bounce" },
                                    { name = "eat",     sheet = possumInfo.imageSheet,  frames = { 1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5, 4, 5, 6, 7, 8, 7, 6, 5, 4, 5, 6, 7, 8, 7, 6, 5, 4, 3, 2, 1 } },
                                    kill[1], kill[2], kill[3] }
        setAnimTime(possumInfo, 70)
        possumInfo.attacks = { biteAnim() }
    end
    
    return possumInfo
end

function bearAnim()
    if bearInfo == nil then
        bearInfo = getNormalZombie("bear.png", { loopDirection = "bounce" })
        bearInfo.attacks = { scratchAnim(), biteAnim() }
    end
    
    return bearInfo
end

function mooseAnim()
    if mooseInfo == nil then
        mooseInfo = getNormalZombie("moose.png", { framerate = 50, frames = { 1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5, 6, 7, 8, 7, 6, 5, 6, 7, 8, 7, 6, 5, 4, 3, 2, 1 } })
        mooseInfo.attacks = { biteAnim() }
    end
    
    return mooseInfo
end

function skunkAnim()
    if skunkInfo == nil then
        skunkInfo = {}
        skunkInfo.name = "skunkAnim"
        skunkInfo.sheetData = bigImageSheet
        skunkInfo.imageSheet = graphics.newImageSheet(animsPath .."skunk.png", skunkInfo.sheetData)
        local kill = killAnim()
        skunkInfo.sequenceData = {  { name = "idle",    sheet = skunkInfo.imageSheet,   start = 1,  count = 8,  loopDirection = "bounce" },
                                    { name = "fart",    sheet = skunkInfo.imageSheet,   frames = { 9, 10, 11, 12, 13, 14, 15, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16 }, loopCount = 1 },
                                    kill[1], kill[2], kill[3] }
        setAnimTime(skunkInfo, 60)
        skunkInfo.attacks = {}
    end
    
    return skunkInfo
end

function girlScoutAnim()
    if scoutInfo == nil then
        scoutInfo = {}
        scoutInfo.name = "scoutAnim"
        scoutInfo.sheetData = bigImageSheet
        scoutInfo.imageSheet = graphics.newImageSheet(animsPath .."girlScout.png", scoutInfo.sheetData)
        scoutInfo.sequenceData = {  { name = "idle",    sheet = scoutInfo.imageSheet,   frames = { 1, 1, 1, 1, 1, 2, 3, 4, 5, 6, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8 }, loopDirection = "bounce" },
                                    { name = "kill",    sheet = scoutInfo.imageSheet,   start = 9,  count = 8,  loopCount = 1 } }
        setAnimTime(scoutInfo, 40)
    end
    
    return scoutInfo
end

function uterAnim()
    if uterInfo == nil then
        uterInfo = getKindlyZombie("uter.png")
    end
    
    return uterInfo
end

function freeAnimMemory(anim)
    if anim ~= nil then
        --print("Let's free memory: ".. tostring(anim.name))
        display.remove(anim)
    end
    
    return nil
end

function cleanUp()
    boneInfo            = freeAnimMemory(boneInfo)
    spawnInfo           = freeAnimMemory(spawnInfo)
    disappearInfo       = freeAnimMemory(disappearInfo)
    killInfo            = freeAnimMemory(killInfo)
    pigExplosionInfo    = freeAnimMemory(pigExplosionInfo)
    explosionCloudInfo  = freeAnimMemory(explosionCloudInfo)
    objectDestroyInfo   = freeAnimMemory(objectDestroyInfo)
    iceDestroyInfo      = freeAnimMemory(iceDestroyInfo)
    warningInfo         = freeAnimMemory(warningInfo)
    biteInfo            = freeAnimMemory(biteInfo)
    scratchInfo         = freeAnimMemory(scratchInfo)
    lifeDeathBoxInfo    = freeAnimMemory(lifeDeathBoxInfo)
    eatingPropInfo      = freeAnimMemory(eatingPropInfo)
    hoseWaterInfo       = freeAnimMemory(hoseWaterInfo)
    pigeonInfo          = freeAnimMemory(pigeonInfo)
    thunderInfo         = freeAnimMemory(thunderInfo)
    trapInfo            = freeAnimMemory(trapInfo)
    powerUpSparkInfo    = freeAnimMemory(powerUpSparkInfo)
    rabbitInfo          = freeAnimMemory(rabbitInfo)
    moleInfo            = freeAnimMemory(moleInfo)
    dogInfo             = freeAnimMemory(dogInfo)
    parrotInfo          = freeAnimMemory(parrotInfo)
    pigInfo             = freeAnimMemory(pigInfo)
    catInfo             = freeAnimMemory(catInfo)
    fishInfo            = freeAnimMemory(fishInfo)
    tortoiseInfo        = freeAnimMemory(tortoiseInfo)
    queenInfo           = freeAnimMemory(queenInfo)
    chihuahuaInfo       = freeAnimMemory(chihuahuaInfo)
    duckInfo            = freeAnimMemory(duckInfo)
    turkeyInfo          = freeAnimMemory(turkeyInfo)
    cageInfo            = freeAnimMemory(cageInfo)
    ratInfo             = freeAnimMemory(ratInfo)
    possumInfo          = freeAnimMemory(possumInfo)
    bearInfo            = freeAnimMemory(bearInfo)
    mooseInfo           = freeAnimMemory(mooseInfo)
    skunkInfo           = freeAnimMemory(skunkInfo)
    scoutInfo           = freeAnimMemory(scoutInfo)
    uterInfo            = freeAnimMemory(uterInfo)
end