module(..., package.seeall)

-- requires
local _gameplay = nil

-- variables de nivell
local stage = 0
local level = 0
local killedZombies = 0
local disappearedZombies = 0
local maxZombiesInLevel = 0
local isPause = false
local isEndLevel = false
local killerZombie = nil

-- variables del jugador
local lifes = 0
local availableWeaponry = nil
local weaponScrollButtons = nil
local currentWeaponButton = nil

-- variables del combo
local comboTimer = nil
local comboCount = 0
local comboScore = 0
local initComboTime = 0
local highestCombo = 0

-- events
local touchEventname = ""

-- gràfics
local grp
local spriteSheet = nil
local upperGrad = nil
local lowerGrad = nil
local currentWeapon = nil
local weaponBubble = nil
local weaponQuantity = nil
local scoreTxt = nil
local pauseButton = nil
local lollipopImg = nil
local lollipopBubble = nil
local lollipopQuantity = nil
local weaponScroll = nil

-- efectes gràfics
local damageFrame = nil
local comboTable = nil
local scoreTable = nil

-- timers i transitions helper
local countDownTimerID = nil
local endGameTimerID = nil
local countDownTransID = nil
local waveTxtTransID = nil
local damageFrameTransID = nil
local updateScoreTransID = nil

local WeaponManager = require "weapons.WeaponManager"


function getKillerZombie()
    if killerZombie then
        return killerZombie.zType
    else
        return "none"
    end
end

function getComboScore()
    return comboScore
end

function getDeaths()
    return killedZombies
end

function getLifes()
    return lifes
end

function getDisappearedZombies()
    return disappearedZombies
end

function addMaxZombiesInLevel(amount)
    maxZombiesInLevel = maxZombiesInLevel + amount
end

function getWeaponManager()
    return WeaponManager
end

local function insertInGroup(element)
    if grp == nil then
        grp = display.newGroup()
    end
    
    grp:insert(element)
end

local function getAvailableWeaponry()
    if availableWeaponry == nil then
        availableWeaponry = {}
        for i = 1, WeaponManager:size() do
            local element = WeaponManager:getById(i)
            availableWeaponry[i] = {wName = element.name, wTypeNumber = i, wAmount = element.quantity}
        end
    end
    return availableWeaponry
end

local function hasMoved(event)
    return math.abs(event.x - event.xStart) > 5 or math.abs(event.y - event.yStart) > 5
end

local function startedPointInRect(p, r)
    return r.contentBounds.xMin < p.xStart and r.contentBounds.xMax > p.xStart and r.contentBounds.yMin < p.yStart and r.contentBounds.yMax > p.yStart
end

function isAlive()
    return lifes > 0
end

function enableDisableWeaponButtons(weapons, isEnabled)
    
    for i = 1, #weaponScrollButtons do
        local w = weaponScrollButtons[i]
        
        if weapons == "all" then
            w.isActive = isEnabled
            w.wasActive = isEnabled
            
            if isEnabled then
                w.alpha = 1
            else
                w.alpha = 0.7
            end
        else
            for j = 1, #weapons do
                local enabled = isEnabled
                
                if w.wName ~= weapons[j] then
                    enabled = not enabled
                end
                    
                w.isActive = enabled
                w.wasActive = enabled

                if enabled then
                    w.alpha = 1
                else
                    w.alpha = 0.7
                end
            end
        end
    end
end

function activateDeactivateButtons(pauseScrollActive, weaponButtonsActive, weaponButtonsAction)
    
    pauseButton.isActive = pauseScrollActive
    
    if weaponScroll then
        weaponScroll._view._isHorizontalScrollingDisabled = not pauseScrollActive
    end
    
    for i = 1, #weaponScrollButtons do
        if weaponButtonsAction == "save" then
            weaponScrollButtons[i].wasActive = weaponButtonsActive
            weaponScrollButtons[i].isActive = weaponButtonsActive
        elseif weaponButtonsAction == "previous" then
            weaponScrollButtons[i].isActive = weaponScrollButtons[i].wasActive
        else
            weaponScrollButtons[i].isActive = weaponButtonsActive
        end
    end
end

local function checkEndGame()
    if --[[isAlive() == false or]] #scoreTable ~= 0 then
        return
    end
    
    if isAlive() and disappearedZombies == maxZombiesInLevel and not isEndLevel then
        activateDeactivateButtons(false, false, "save")
        
        isEndLevel = true
        
        Runtime:dispatchEvent({ name = GAMEPLAY_END_IS_NEAR_EVNAME, success = true })
        endGameTimerID = timer.performWithDelay(1000, function() Runtime:dispatchEvent({ name = GAMEPLAY_END_GAME_EVNAME, success = true }) end)
    end
end

local function getWeaponByName(wName)
    
    for i = 1, #weaponScrollButtons do
        if weaponScrollButtons[i].wName == wName then
            return weaponScrollButtons[i]
        end
    end
    
    error("S'ha demanat l'arma ".. tostring(wName) .." pero no existeix o no esta disponible")
    return nil
end

function getWeaponPosition(wName)
	
	wName = wName or _gameplay.getWeaponControllerModule():getCurrentWeapon()
	
	local w = getWeaponByName(wName)
	
	if w then
		return w:localToContent( 0, 0 )
	else
		return nil
	end
	
end

function updateWeaponQuantity(wName, amount)
	
	wName = wName or _gameplay.getWeaponControllerModule():getCurrentWeapon()
	
	local newAmount = WeaponManager:updateWeaponAmount(wName, amount)
	
	local w = getWeaponByName(wName)
	w.changeQuantity(newAmount)
	
--	if w == currentWeaponButton then
--		weaponQuantity.text = newAmount
--	end
	
	return newAmount
end

function setCurrentWeaponQuantity(wName)
   
    if weaponBubble == nil then
        
        local superScale = SCALE_BIG *1.3
        
        weaponBubble = display.newImage(spriteSheet, 4)
        weaponBubble.x, weaponBubble.y = display.contentWidth *0.18, display.contentWidth *0.07
        weaponBubble:scale(superScale, superScale)
        insertInGroup(weaponBubble)
        
        weaponQuantity = display.newText("", 0, 0, INGAME_SCORE_FONT, 25 * SCALE_BIG)
        weaponQuantity:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
        weaponQuantity.x, weaponQuantity.y = weaponBubble.x, weaponBubble.y
        insertInGroup(weaponQuantity)
    end

    weaponQuantity.text = WeaponManager:getWeaponAmount(wName)
    
    weaponBubble:toFront()
    weaponQuantity:toFront()
end

function getWeaponQuantity(wName)
	return WeaponManager:getWeaponAmount(wName)
end

function setCurrentWeapon(wName)
	
    local w = getWeaponByName(wName)
    
    if currentWeaponButton ~= nil then
		if not (currentWeaponButton == w) then
			currentWeaponButton.selectWeapon(false)
		end
    end
    
    currentWeaponButton = w
    if currentWeaponButton ~= nil then
		currentWeaponButton.selectWeapon(true)
    end
    
--    if currentWeapon ~= nil then
--        display.remove(currentWeapon)
--    end
    
--    local position = display.contentWidth *0.1
    
--    --print("DSD: "..WEAPON_TYPES[w.wTypeNumber].spriteIndex.." | "..tonumber(WeaponManager:getByName(wName).id))
    
--    currentWeapon = display.newImage(spriteSheet, tonumber(WeaponManager:getByName(wName).id))
--    currentWeapon.x, currentWeapon.y = position, position
--    currentWeapon:scale(SCALE_BIG, SCALE_BIG)
--    insertInGroup(currentWeapon)
--    currentWeapon:toFront()
    
--    setCurrentWeaponQuantity(wName)
end

function caughtPowerup(wName, wAmount, isInTip)
    updateWeaponQuantity(wName, wAmount)
    
--    if not _gameplay.getWeaponControllerModule():isDirectWeapon(wName) then
--        setCurrentWeapon(wName)
--    end
end

function updateLollipopQuantity(amount)
    
    amount = amount or lollipopQuantity.quantity -1
    
    lollipopQuantity.text = amount
    lollipopQuantity.quantity = amount
    
    lollipopQuantity:toFront()
end

function heal(amount)
    amount = amount or 1
    lifes = lifes + amount
    
    if lifes > PLAYER_MAX_LIFES then
        lifes = PLAYER_MAX_LIFES
    end
    
    updateLollipopQuantity(lifes)
    _gameplay.updateLollipops(lifes)
end

function damage(amount, z)
    if AZ.isGodMode then
        return false
    end
    
    amount = amount or 1
    
    lifes = lifes - amount
    
    AZ.utils.vibrate()
    
    damageFrame.alpha = 0
    damageFrameTransID = transition.safeCancel(damageFrameTransID)
    damageFrameTransID = transition.from(damageFrame, { time = 500, alpha = 0.5 })
    
    if lifes < 1 then
        killerZombie = z
        
        lifes = 0
        
        isEndLevel = true
        
        Runtime:dispatchEvent({ name = GAMEPLAY_PAUSE_EVNAME, isPause = true, pauseType = "refillLollipops" })
        --Runtime:dispatchEvent({ name = GAMEPLAY_END_IS_NEAR_EVNAME, success = false })
        --endGameTimerID = timer.performWithDelay(1000, function() Runtime:dispatchEvent({ name = GAMEPLAY_END_GAME_EVNAME, success = false }) end)
    end
    
    updateLollipopQuantity(lifes)
    _gameplay.updateLollipops(lifes)
    
    return not isAlive()
end

function resumeGame()
    heal(PLAYER_MAX_LIFES)
    
	isEndLevel = false
	
    if killerZombie then
        killerZombie.dontHide = false
    end
end

----------------------------- GESTIÓ DE LAST WAVE ------------------------------
local function createWaveText(text, posY)
    local lastWaveText = display.newText(text, 0, 0, INTERSTATE_BOLD, LAST_WAVE_FONT_SIZE)
    
    lastWaveText.x, lastWaveText.y = 0, posY
    
    lastWaveText:setFillColor(AZ.utils.getColor(AZ_BRIGHT_RGB))
    
    lastWaveText.destroy = function()
        display.remove(lastWaveText)
        lastWaveText = nil
    end
    
    return lastWaveText
end

function prepareWave()
    local lastWaveSound = AZ.soundLibrary.lastWaveSound
    AZ.audio.playFX(lastWaveSound, AZ.audio.AUDIO_VOLUME_OTHER_FX)
    
    local posY = display.contentHeight * 0.07
    
    local lastWaveText1 = createWaveText(AZ.utils.translate("last"), -posY)
    local lastWaveText2 = createWaveText(AZ.utils.translate("wave"), posY)
    
    local waveGroup = display.newGroup()
    waveGroup:insert(lastWaveText1)
    waveGroup:insert(lastWaveText2)
    waveGroup.x, waveGroup.y = display.contentCenterX, display.contentCenterY
    
    waveGroup.destroyWaveText = function()
        lastWaveText1.destroy()
        lastWaveText2.destroy()
        
        _gameplay.createWave()
    end
    
    waveGroup.disappear = function()
        waveTxtTransID = transition.to(waveGroup, {time = 300, delay = audio.getDuration(lastWaveSound) - 151, alpha = 0, onComplete = function() waveTxtTransID = transition.safeCancel(waveTxtTransID) waveGroup.destroyWaveText() end })
    end
    
    local superBigScale = SCALE_BIG *3
    waveTxtTransID = transition.from(waveGroup, { time = audio.getDuration(lastWaveSound) - 550, delay = 100, alpha = 0, xScale = superBigScale, yScale = superBigScale, onComplete = waveGroup.disappear })
    
end

local function updateScore(addedScore)
    
    scoreTxt.score = scoreTxt.score + addedScore
    scoreTxt.text = scoreTxt.score
    scoreTxt.alpha = 1
    scoreTxt.xScale, scoreTxt.yScale = 1, 1
    
    updateScoreTransID = transition.safeCancel(updateScoreTransID)
    updateScoreTransID = transition.from(scoreTxt, { time = 250, xScale = 2, yScale = 2, alpha = 0, onComplete = checkEndGame })
end

local function createScoreText(score, posX, posY)
    
    if not isAlive() then
        return
    end
    
    local newScore = display.newText(score, 0, 0, INGAME_SPAWN_SCORE_FONT, INGAME_SPAWN_SCORE_SIZE)
    newScore.x, newScore.y = posX, posY
    newScore:setFillColor(AZ.utils.getColor(INGAME_SPAWN_SCORE_RGB))
    
    newScore.score = score
    
    newScore.move = function(transitionTime)
        newScore.transitionID = transition.to(newScore, { time = transitionTime, transition = easing.inOutExpo, x = scoreTxt.x, y = scoreTxt.y, onComplete = newScore.addScore })
    end
    
    newScore.destroyScore = function()
       if newScore ~= nil then
           
           if newScore.transitionID ~= nil then
               transition.safeCancel(newScore.transitionID)
               newScore.transitionID = nil
           end
           
           table.remove(scoreTable, 1)
           
           display.remove(newScore)
           newScore = nil
       end
    end
    
    newScore.addScore = function()
        updateScore(newScore.score)
        newScore.destroyScore()
    end
    
    local transitionTime = math.sqrt(((posX - display.contentCenterX) * (posX - display.contentCenterX)) + ((posY - 60) * (posY - 60)))
    transitionTime = transitionTime *1.5
    
    newScore.move(transitionTime)
    newScore.endTransitionTime = transitionTime + system.getTimer()
    
    scoreTable[#scoreTable +1] = newScore
    insertInGroup(newScore)
end

local function createComboEffect(x, y, isIngame)
	
	if isIngame then
		AZ.achievementsManager:combo(comboCount)
	end
	
	Runtime:dispatchEvent({ name = GAMEPLAY_COMBO_EVNAME, comboCount = comboCount })
	
    local myScale = SCALE_BIG * (comboCount * 0.05)
    if myScale > SCALE_BIG then
        myScale = SCALE_BIG
    end
    
    myScale = myScale + SCALE_BIG
    
    local comboEffect = display.newText("x".. comboCount, 0, 0, INTERSTATE_BOLD, BIG_FONT_SIZE + BIG_FONT_SIZE)
    comboEffect:setFillColor(AZ.utils.getColor(AZ_BRIGHT_RGB))
    comboEffect:scale(myScale, myScale)
    comboEffect.x, comboEffect.y = x, y
    comboEffect:rotate(math.random(-15, 15))
    comboEffect:toFront()
    
    comboEffect.destroyCombo = function()
        if comboEffect ~= nil then
            
            if comboEffect.transitionID ~= nil then
                transition.safeCancel(comboEffect.transitionID)
                comboEffect.transitionID = nil
            end
            
            comboEffect:removeSelf()
            comboEffect = nil
            
            table.remove(comboTable, 1)
        end
    end
    
    comboEffect.disappear = function()
        if comboEffect ~= nil then
            comboEffect.transitionID = transition.to(comboEffect, { time = 500, alpha = 0, onComplete = comboEffect.destroyCombo })
        end
    end
    
    comboEffect.transitionID = transition.from(comboEffect, { delay = 100, time = 200, xScale = 0.01, yScale = 0.01, onComplete = comboEffect.disappear })
    comboTable[#comboTable +1] = comboEffect
    insertInGroup(comboEffect)
end

local function finishCombo()
	
	Runtime:dispatchEvent({ name = GAMEPLAY_COMBO_EVNAME, comboCount = 0, finishCombo = true })
	
    AZ.audio.playFX(AZ.soundLibrary.comboSound, AZ.audio.AUDIO_VOLUME_OTHER_FX)
    
    if highestCombo < comboCount then
        highestCombo = comboCount
    end
    
    mComboTimer = nil
end

function addDisappearedZombies(killed, amount)
    amount = amount or 1
    disappearedZombies = disappearedZombies + amount
    
    if killed then
        killedZombies = killedZombies + amount
    end
    
    checkEndGame()
end

function addInstantCombo(score, zAmount, x, y)
    if --[[not isAlive() or]] zAmount < 1 then
        return
    end
    
    if comboCount == 0 or initComboTime < system.getTimer() then
        comboCount = 0
        initComboTime = system.getTimer() + INGAME_COMBO_TIME
    end
    
    killedZombies = killedZombies + zAmount
    comboCount = comboCount + zAmount
    local totalScore = 0
    
    local lapseTime = INGAME_COMBO_TIME - (INGAME_COMBO_TIME * ((comboCount -1) * 0.07))
    
    if comboCount > 1 then
        for i = comboCount - zAmount +1, comboCount do
            local addedScore = score * (i -1)
            comboScore = comboScore + addedScore
            totalScore = totalScore + addedScore + score
        end
        
        createComboEffect(x, y, true)
		
        comboTimer = timer.safeCancel(comboTimer)
        comboTimer = timer.performWithDelay(lapseTime, finishCombo)
    end
        
    createScoreText(math.max(totalScore, score), x, y)
        
    checkEndGame()
end

function tipInstantCombo(zAmount, x, y)
	if zAmount < 1 then
        return
    end
    
    if comboCount == 0 or initComboTime < system.getTimer() then
        comboCount = 0
        initComboTime = system.getTimer() + INGAME_COMBO_TIME
    end
    
    comboCount = comboCount + zAmount
    local totalScore = 0
    
    local lapseTime = INGAME_COMBO_TIME - (INGAME_COMBO_TIME * ((comboCount -1) * 0.07))
    
    if comboCount > 1 then
		
        createComboEffect(x, y, false)
            
        comboTimer = timer.safeCancel(comboTimer)
        comboTimer = timer.performWithDelay(lapseTime, finishCombo)
    end
end

function tipKill(x, y)
	
	if comboCount == 0 or initComboTime < system.getTimer() then
		Runtime:dispatchEvent({ name = GAMEPLAY_COMBO_EVNAME, comboCount = 0, finishCombo = true })
		comboCount = 0
		initComboTime = system.getTimer() + INGAME_COMBO_TIME
	end
	
	local lapseTime = INGAME_COMBO_TIME - (INGAME_COMBO_TIME * (comboCount * 0.07))
	
	comboCount = comboCount +1
	
	if comboCount > 1 then
		createComboEffect(x, y, false)
		
		comboTimer = timer.safeCancel(comboTimer)
		comboTimer = timer.performWithDelay(lapseTime, finishCombo)
	end
end

function addScore(score, x, y, breakCombo)
    --if not isAlive() then
    --    return
    --end
    
    disappearedZombies = disappearedZombies +1
    
    if not breakCombo and score > 0 then
        
        if comboCount == 0 or initComboTime < system.getTimer() then
            comboCount = 0
            initComboTime = system.getTimer() + INGAME_COMBO_TIME
        end
        
        local lapseTime = INGAME_COMBO_TIME - (INGAME_COMBO_TIME * (comboCount * 0.07))
        
        killedZombies = killedZombies +1
        comboCount = comboCount +1
        
        if comboCount > 1 then
            comboScore = comboScore + (score * (comboCount -1))
            score = score * comboCount
            
            createComboEffect(x, y, true)
            
            comboTimer = timer.safeCancel(comboTimer)
                
            comboTimer = timer.performWithDelay(lapseTime, finishCombo)
        end
        
        createScoreText(score, x, y)
    else
        comboCount = 0
    end
    
    checkEndGame()
end

local function onScrollViewTouch(event)
    if not event.limitReached and not startedPointInRect(event, weaponScroll) then
        Runtime:dispatchEvent({ name = touchEventname, phase = event.phase, id = 0, touchID = event.id, x = event.x, y = event.y })
    end
    
    return true
end

local function onScrollButtonTouch(event)
	
    if not startedPointInRect(event, event.target) then
		Runtime:dispatchEvent({ name = touchEventname, phase = event.phase, id = 0, touchID = event.id, x = event.x, y = event.y })
    
    elseif event.phase == "ended" and event.target.isActive then
		
		--Lisard: afegit el SHOVEL_NAME a la condicio perque no dispari el popup de comprar armes
        if WeaponManager:getWeaponAmount(event.target.wName) > 0 or event.target.wName == SHOVEL_NAME then
            event.target.selectWeapon(true)
        else
            Runtime:dispatchEvent({ name = GAMEPLAY_PAUSE_EVNAME, pauseType = "buyWeapons", isPause = true, wName = event.target.wName})
        end
        
    elseif hasMoved(event) and weaponScroll and event.phase == "moved" and not weaponScroll._view._isHorizontalScrollingDisabled then
		weaponScroll:takeFocus(event)
		
    end

    return true
end

local function pause(event)
    
    if isPause == event.isPause then
        return
    end
    
    isPause = event.isPause
    
    timer.safePauseResume(countDownTimerID, isPause)
    timer.safePauseResume(endGameTimerID, isPause)
    transition.safePauseResume(countDownTransID, isPause)
    transition.safePauseResume(waveTxtTransID, isPause)
    transition.safePauseResume(damageFrameTransID, isPause)
    transition.safePauseResume(updateScoreTransID, isPause)

    for i = 1, #scoreTable do
        transition.safePauseResume(scoreTable[i].transitionID, isPause)
    end
    
    for i = 1, #comboTable do
        transition.safePauseResume(comboTable[i].transitionID, isPause)
    end
end

local function onPauseTouch(event)
    
    if not startedPointInRect(event, pauseButton) then
        Runtime:dispatchEvent({ name = touchEventname, phase = event.phase, id = 0, touchID = event.id, x = event.x, y = event.y })

    elseif event.phase == "ended" and pauseButton.isActive then
        Runtime:dispatchEvent({ name = GAMEPLAY_PAUSE_EVNAME, isPause = true, pauseType = "pause" })
        
    end
    
    return true
end

function startCountDown(callback) 
   
    local myCountDown = AZ.soundLibrary.countDownSound
    local countDownNumber = nil
    local countDown = 3
    countDownTimerID = timer.safeCancel(countDownTimerID)
    local imgSheet = graphics.newImageSheet("assets/guiSheet/levelsIngameWinLose.png", AZ.atlas:getSheet())
    
    local function countDownFunction()
        if countDownNumber ~= nil then
            countDownNumber.destroy()
        end

        if countDown == 0 then
            AZ.audio.playFX(myCountDown[4], AZ.audio.AUDIO_VOLUME_OTHER_FX)

            countDownTimerID = timer.safeCancel(countDownTimerID)
            countDownTimerID = timer.performWithDelay(audio.getDuration(myCountDown[4]) *0.5, function() countDownTimerID = timer.safeCancel(countDownTimerID) callback() end)

            return
        end

        countDownNumber = display.newImage(imgSheet, AZ.atlas:getFrameIndex("cuentaatras-".. countDown))
        countDownNumber.x, countDownNumber.y = display.contentCenterX, display.contentCenterY
        countDownNumber:scale(SCALE_BIG, SCALE_BIG)
        countDownNumber.alpha = 1
        grp:insert(countDownNumber)

        countDownNumber.destroy = function()
            countDownTransID = transition.safeCancel(countDownTransID)
            
            display.remove(countDownNumber)
            countDownNumber = nil
        end

        local doubleScaleBig = SCALE_BIG + SCALE_BIG

        AZ.audio.playFX(myCountDown[countDown], AZ.audio.AUDIO_VOLUME_OTHER_FX)
        countDownTransID = transition.from(countDownNumber, { alpha = 0, time = INGAME_COUNTDOWN_TIME, xScale = doubleScaleBig, yScale = doubleScaleBig, transition = easing.outQuad, onComplete = countDownNumber.destroy })

        countDown = countDown -1
    end
    
    countDownTimerID = timer.performWithDelay(INGAME_COUNTDOWN_TIME, countDownFunction, 4)
end

function destroyUI()
    Runtime:removeEventListener(GAMEPLAY_PAUSE_EVNAME, pause)
    
    countDownTimerID = timer.safeCancel(countDownTimerID)
    endGameTimerID = timer.safeCancel(endGameTimerID)
    countDownTransID = transition.safeCancel(countDownTransID)
    waveTxtTransID = transition.safeCancel(waveTxtTransID)
    damageFrameTransID = transition.safeCancel(damageFrameTransID)
    updateScoreTransID = transition.safeCancel(updateScoreTransID)
    
    for i=1, #scoreTable do
        scoreTable[1].destroyScore()
    end
    
    for i=1, #comboTable do
        comboTable[1].destroyCombo()
    end
    
    if weaponScroll ~= nil then
        display.remove(weaponScroll)
    end
    
    display.remove(grp)
end

function initializeUI(currentStage, currentLevel, ss, requiredWeapons, initialShovels, maxZombies, gameplay)
    
    WeaponManager:init(initialShovels, requiredWeapons)
	
    Runtime:addEventListener(GAMEPLAY_PAUSE_EVNAME, pause)
    
----------------------------- SETEIG DE VARIABLES ------------------------------
    
    stage, level = currentStage, currentLevel
    
    _gameplay = gameplay
    
    lifes = PLAYER_MAX_LIFES
    
    isPause = false
    isEndLevel = false
    
    killerZombie = nil
    
    comboTimer = nil
    comboCount = 0
    comboScore = 0
    initComboTime = 0
    highestCombo = 0
    
    killedZombies = 0
    disappearedZombies = 0
    maxZombiesInLevel = maxZombies
    
    comboTable = {}
    scoreTable = {}
    
    touchEventname = _gameplay.getBoardTouchEventName()
    
    spriteSheet = ss
    
----------------------------- CREACIÓ DE GRÀFICS -------------------------------
    
-- frame de dany
    damageFrame = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth *1.2, display.contentHeight *1.2)
    damageFrame:setFillColor(1, 0, 0)
    damageFrame.alpha = 0
    insertInGroup(damageFrame)
    
-- gradients superior i inferior
    local function createGrad(posY, gradDirection)
        local sx, sy = display.contentWidth, display.contentHeight *0.2
        
        local gradRect = display.newRect(sx *0.5, posY + sy *0.5, sx, sy)
        local grad = { type = "gradient", color1 = {0, 0, 0, 0.9}, color2 = {0, 0, 0, 0}, direction = gradDirection }
        gradRect:setFillColor(grad)
        insertInGroup(gradRect)
        gradRect:toBack()
        return gradRect
    end
    
    upperGrad = createGrad(0, "down")
    lowerGrad = createGrad(display.contentHeight *0.8, "up")
    
-- score
    scoreTxt = display.newText("0", 0, 0, INGAME_SCORE_FONT, INGAME_SCORE_SIZE *1.2)
    scoreTxt.score = 0
    scoreTxt:setFillColor(AZ.utils.getColor(AZ_BRIGHT_RGB))
    scoreTxt.x, scoreTxt.y = display.contentCenterX, display.contentWidth *0.1
    insertInGroup(scoreTxt)
    
-- pauseButton
    local superScale = SCALE_BIG *1.3
    pauseButton = AZ.ui.newSuperButton{
        sound = AZ.soundLibrary.pauseSound,
        imageSheet = spriteSheet,
        unpressed = 9,
        pressedFilter = "filter.invertSaturate",
        x = display.contentWidth *0.68, y = display.contentWidth *0.1,
        onTouch = onPauseTouch,
        id = "Pause",
    }
    pauseButton:scale(SCALE_SMALL, SCALE_SMALL)
    pauseButton.isActive = true
    insertInGroup(pauseButton)
    
-- lollipopImg
    local pos = display.contentWidth *0.1
    lollipopImg = display.newImage(ss, 11)
    lollipopImg.x, lollipopImg.y = display.contentWidth - pos, pos
    lollipopImg:scale(SCALE_BIG, SCALE_BIG)
    insertInGroup(lollipopImg)
    
-- lollipopBubble
    lollipopBubble = display.newImage(spriteSheet, 4)
    lollipopBubble.x, lollipopBubble.y = display.contentWidth *0.82, display.contentWidth *0.07
    lollipopBubble:scale(superScale, superScale)
    insertInGroup(lollipopBubble)
 
-- lollipopQuantity
    superScale = SCALE_BIG *1.5
    lollipopQuantity = display.newText("", 0, 0, INGAME_SCORE_FONT, 25 * SCALE_BIG)
    lollipopQuantity:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
    lollipopQuantity.x, lollipopQuantity.y = lollipopBubble.x, lollipopBubble.y
    updateLollipopQuantity(PLAYER_MAX_LIFES)
    insertInGroup(lollipopQuantity)
    
-- scroll d'armes
    local padding = display.contentWidth *0.05
    local superScale = SCALE_BIG *1.35

    local wBtnCreated = 0
    weaponScrollButtons = {}
    local weaponry = getAvailableWeaponry()
    local wBtnGrp = display.newGroup()
    
    for i = 1, #weaponry do
        
        local weaponButtonGrp = display.newGroup()
        weaponButtonGrp.wName = weaponry[i].wName
        weaponButtonGrp.wTypeNumber = weaponry[i].wTypeNumber
        weaponButtonGrp.isActive = true
        weaponButtonGrp:addEventListener("touch", onScrollButtonTouch)
        
        local wWeapon = display.newImage(ss, tonumber(WeaponManager:getById(i).id))
		wWeapon.anchorY = 1
        wWeapon:scale(0.7, 0.7)
		wWeapon.y = wWeapon.contentHeight*0.4

        local wBubble = display.newImage(ss, 4)
        wBubble.x, wBubble.y = wWeapon.x, wWeapon.contentHeight *0.5
        
        local wQuantity = display.newText(weaponry[i].wAmount, 0, 0, INGAME_SCORE_FONT, 20)
		if weaponry[i].wAmount > 0 then
			wQuantity:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
			wBubble:setFillColor(1, 1, 1)
		else
			wQuantity:setFillColor(AZ.utils.getColor(AZ_BRIGHT_RGB))
			wBubble:setFillColor(AZ.utils.getColor({178, 34, 34}))
		end
        
        wQuantity.x, wQuantity.y = wBubble.x, wBubble.y
        
        
        weaponButtonGrp:insert(wWeapon)
        weaponButtonGrp:insert(wBubble)
        weaponButtonGrp:insert(wQuantity)
        
        weaponButtonGrp.selectWeapon = function(isSelected)
			
            if isSelected then
				
				AZ.audio.playFX(AZ.soundLibrary.changeWeaponSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
				
				wWeapon.transID = transition.to(wWeapon, {time = 300, xScale = 1, yScale = 1, transition = easing.outElastic})
                
                if not _gameplay.setNewWeapon(weaponButtonGrp.wName) then
					wWeapon.transID = transition.to(wWeapon, {time = 500, xScale = 0.7, yScale = 0.7, transition = easing.outElastic})
                end
            else
				wWeapon.transID = transition.to(wWeapon, {time = 500, xScale = 0.7, yScale = 0.7, transition = easing.outElastic})
            end
        end
        
        weaponButtonGrp.changeQuantity = function(amount)
			wQuantity.transID = transition.to(wQuantity, {time = 150, xScale = 2, yScale = 2, alpha = 0.6, onComplete = function() wQuantity.xScale, wQuantity.yScale, wQuantity.alpha = 1, 1, 1; wQuantity.transID = transition.safeCancel(wQuantity.transID) end})
            wQuantity.text = amount or tonumber(wQuantity.text) - 1
			if tonumber(wQuantity.text) > 0 then
				wQuantity:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
				wBubble:setFillColor(1, 1, 1)
			else
				wQuantity:setFillColor(AZ.utils.getColor(AZ_BRIGHT_RGB))
				wBubble:setFillColor(AZ.utils.getColor({178, 34, 34}))
			end
        end
        
        weaponButtonGrp:scale(superScale, superScale)
        wBtnGrp:insert(weaponButtonGrp)
        
        if wBtnCreated == 0 then
            weaponButtonGrp.x = weaponButtonGrp.width *0.5
        else
            weaponButtonGrp.x = wBtnGrp[wBtnCreated].contentBounds.xMax + weaponButtonGrp.width * 0.5 + padding
        end

        weaponScrollButtons[i] = weaponButtonGrp
        
        wBtnCreated = wBtnCreated +1
    end

    if wBtnGrp.width < display.contentWidth then
        wBtnGrp.x, wBtnGrp.y = display.contentCenterX - (wBtnGrp.width *0.5), display.contentHeight - wBtnGrp.height *0.6
        insertInGroup(wBtnGrp)
    else
        local _widget = require "widget"
        
        weaponScroll = _widget.newScrollView({
            --top = display.contentHeight - wBtnGrp.height *0.6,
            height = wBtnGrp.height *1.1,
            hideBackground = true, hideScrollBar = true,
            leftPadding = padding, rightPadding = padding,
            verticalScrollDisabled = true,
            listener = onScrollViewTouch
        })

        weaponScroll:setScrollWidth(wBtnGrp.width)
        weaponScroll.y = display.contentHeight - weaponScroll.height *0.5
        weaponScroll:insert(wBtnGrp)
        wBtnGrp.y = weaponScroll._view.height *0.5
        wBtnGrp:toFront()

        insertInGroup(weaponScroll)
        
        _widget = AZ:unloadModule("widget")
    end
    
    return grp
end