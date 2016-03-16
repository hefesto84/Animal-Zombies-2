module(..., package.seeall)

local _ingameUI
local _board
local _zombie
local _lollipop
local _rake

local myGroup

local levelInfo

local isLastWave = false

local maxZombiesInLevel = 0
local maxZombiesPerScreen = 0
local spawnProbability = 0
local spawnedZombies = 0
local isPause = false
local isDisabled = false

function getZombieStatistics()
    return _zombie.getStatistics()
end

function getPowerUpStatistics()
    local lollipopSpawned, lollipopGet, lollipopLost = _lollipop.getStatistics()
    local rakeSpawned, rakeGet, rakeLost = _rake.getStatistics()
    
    return lollipopSpawned, lollipopGet, lollipopLost, rakeSpawned, rakeGet, rakeLost
end

local function getRandomType()
    local randomType = math.random()
    local i = 1
	
    while i < #levelInfo.zombies +1 do
        if randomType <= levelInfo.zombies[i].probability then
            return AZ.zombiesLibrary.getZombie(levelInfo.zombies[i].type)
        end
        i = i +1
    end
end

local function createWave()
    activateDeactivatePause(true)
    
    al.Source(audio.getSourceFromChannel(1), al.PITCH, 1.3)
    
    maxZombiesInLevel = maxZombiesInLevel + levelInfo.waveZombies
    maxZombiesPerScreen = maxZombiesPerScreen +1
    spawnProbability = spawnProbability *1.3
    
    if maxZombiesPerScreen > 12 then
        maxZombiesPerScreen = 12
    end
end

local function spawnZombies()
    
    if _board.boardSize == maxZombiesPerScreen or spawnedZombies == maxZombiesInLevel then
        return
    end
    
    if math.random(1, 1000) <= spawnProbability then
        local newZombieType = getRandomType()
        local newAttacksTime = math.random(levelInfo.minTimePerAttack, levelInfo.maxTimePerAttack)
        local newAttacks = math.random(0, levelInfo.maxAttacksPerZombie)
        if newAttacks == 0 then
            newAttacksTime = newAttacksTime *0.75
        end
        
        myGroup:insert(_zombie.createzombie(newZombieType, newAttacks, newAttacksTime))

        spawnedZombies = spawnedZombies +1
   end
end

local function canSpawnPowerUp()
    return _lollipop.lollipopInstance == nil and _rake.rakeInstance == nil
end

local function spawnLollipops()
    if _ingameUI.getLives() == INGAME_MAX_LIFES or canSpawnPowerUp() == false then
        return
    end
    
    if math.random(1, 1000) <= levelInfo.lollipopSpawnProbability then
        local myLollipop = _lollipop.spawnLollipop()
        myGroup:insert(myLollipop)
        myLollipop:toFront()
    end
end

local function spawnRakes()
    if canSpawnPowerUp() == false or _ingameUI.isUsingRake == true then
        return
    end
    
    if math.random(1, 1000) <= levelInfo.rakeSpawnProbability then
        local myRake = _rake.spawnRake()
        myGroup:insert(myRake)
        myRake:toFront()
    end
end

function disableGameplay()
    -- si existeix una piruleta que cau, la deshabilitem
    if _lollipop.lollipopInstance ~= nil then
        _lollipop.isDisabled = true
    end
            
    -- si existeix un rastrell que cau, el deshabilitem
    if _rake.rakeInstance ~= nil then
        _rake.isDisabled = true
    end
            
    -- si hem perdut [i per tant, pot ser que encara hi hagi zombies visibles], deshabilitem els zombies
    if _ingameUI.isEndGame == false then
        _board.hideAll()
    end
end

local function createWaveText(text, posY)
    local lastWaveText = display.newText(
        text,
        0, 0,
        INTERSTATE_BOLD,
        LAST_WAVE_FONT_SIZE)
        
    lastWaveText:setReferencePoint(display.CenterReferencePoint)
    lastWaveText.x, lastWaveText.y = display.contentCenterX, posY
    
    lastWaveText:setTextColor(1, 1, 1)
    
    lastWaveText.destroy = function()
        display.remove(lastWaveText)
        lastWaveText = nil
    end
    
    return lastWaveText
end

local function prepareWave()
    local lastWaveSound = AZ.soundLibrary.lastWaveSound
    if AZ.audio.FX_ENABLED == true then
        local lastWaveChannel = audio.play(lastWaveSound)
        audio.setVolume(AZ.audio.AUDIO_VOLUME_OTHER_FX, { channel = lastWaveChannel })
    end
    
    local lastWaveText1 = createWaveText(AZ.utils.translate("last"), display.contentHeight * 0.43)
    local lastWaveText2 = createWaveText(AZ.utils.translate("wave"), display.contentHeight * 0.57)
    
    local waveGroup = display.newGroup()
    waveGroup:insert(lastWaveText1)
    waveGroup:insert(lastWaveText2)
    waveGroup:setReferencePoint(display.CenterReferencePoint)
    
    waveGroup.destroyWaveText = function()
        lastWaveText1.destroy()
        lastWaveText2.destroy()
        
        createWave()
    end
    
    waveGroup.disappear = function()
        transition.to(waveGroup, {time = 300, delay = audio.getDuration(lastWaveSound) - 151, alpha = 0, onComplete = waveGroup.destroyWaveText })
    end
    
    local superBigScale = SCALE_BIG + SCALE_BIG + SCALE_BIG
    transition.from(waveGroup, { time = audio.getDuration(lastWaveSound) - 550, delay = 100, alpha = 0, xScale = superBigScale, yScale = superBigScale, onComplete = waveGroup.disappear })
    
end

function update()
    -- si no estem en pausa, fem update
    if isPause == false then
        if _ingameUI.getDisappearedZombies() == levelInfo.maxZombiesInLevel and levelInfo.waveZombies ~= 0 and isLastWave == false then
            isLastWave = true
            activateDeactivatePause(false)
            timer.performWithDelay(1000, prepareWave)
        end
            
        spawnZombies()
        spawnLollipops()
        spawnRakes()
    end
end

function pause(pause)
    isPause = pause
    
    if _lollipop.lollipopInstance ~= nil then
        _lollipop.lollipopInstance.setPause(isPause)
    end
    
    if _rake.rakeInstance ~= nil then
        _rake.rakeInstance.setPause(isPause)
    end
    
    _board.pause(isPause)
end

function destroy()
    _board.deleteAll()
    
    if _lollipop.lollipopInstance ~= nil then
        _lollipop.lollipopInstance.bottomReached()
    end
    
    if _rake.rakeInstance ~= nil then
        _rake.rakeInstance.bottomReached()
    end
end

function init(currentLevelInfo, stage, level, ingameBackground, UI, board, zombie, lollipop, rake, slash)
    myGroup = display.newGroup()
    
    _ingameUI    = UI
    _board       = board
    _zombie      = zombie
    _lollipop    = lollipop
    _rake        = rake
    
    levelInfo = currentLevelInfo
    maxZombiesInLevel = levelInfo.maxZombiesInLevel
    maxZombiesPerScreen = levelInfo.maxZombiesPerScreen
    spawnProbability = levelInfo.zombieSpawnProbability
    
    spawnedZombies = 0
    isPause = false
    isDisabled = false
    
    isLastWave = false
    
    -- precarrega de zombies del nivell actual
    for i=1, #levelInfo.zombies do
        AZ.zombiesLibrary.getZombie(levelInfo.zombies[i].type)
    end
    
    -- precarrega d'efectes, lollipops i rakes
    local anims = AZ.animsLibrary
    
    anims.spawnAnim()
    anims.disappearAnim()
    anims.warningAnim()
    anims.biteAnim()
    anims.scratchAnim()
    anims.lollipopAnim()
    anims.rakeAnim()
    
    _zombie.initialize(ingameBackground, _board, _ingameUI, slash)
    _lollipop.initialize(_ingameUI)
    _rake.initialize(_ingameUI)
    
    return myGroup
end