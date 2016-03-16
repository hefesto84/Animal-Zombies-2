module(..., package.seeall)

local _slash

local group

local damageFrame
local scoreText
local lollipopsTable = {}
local scoreTable = {}
local comboTable = {}
local rakeImage

local mLife

local mComboTimer = ""
local mComboCount = 0
local mComboScore = 0
local mInitComboTime = 0
local mHighestCombo = 0

local mKilledZombies = 0
local mDisappearedZombies = 0
local mMaxZombiesInLevel = 0

local mCurrentStage, mCurrentLevel = nil

isEndGame = nil
isUsingRake = false

function getHighestCombo()
    return mHighestCombo
end

function getComboScore()
    return mComboScore
end

function getDisappearedZombies()
    return mDisappearedZombies
end

function getDeaths()
    return mKilledZombies
end

function getLives()
    return mLife
end

function isAlive()
    return mLife > 0
end

local function checkEndGame()
    if isAlive() == false or #scoreTable ~= 0 or isEndGame ~= nil then
        --print("isAlive: ".. tostring(isAlive()) .." == false or scoreTable: ".. #scoreTable .." ~= 0 or isEndGame: ".. tostring(isEndGame) .." ~= nil")
        return
    end
    
    --print("mDisappearedZombies, mMaxZombiesInLevel: ".. mDisappearedZombies .." == ".. mMaxZombiesInLevel)
    if mDisappearedZombies == mMaxZombiesInLevel  then
        isEndGame = true
    end
end

local function updateScore(addedScore)
    if scoreText.text == nil then
        return
    end
    
    --AZ.audio.playFX(AZ.soundLibrary.addScoreSound, AZ.audio.AUDIO_VOLUME_BSO)
    
    scoreText.text = tonumber(scoreText.text) + addedScore
    scoreText.alpha = 1
    scoreText.xScale, scoreText.yScale = 1, 1
    
    transition.from(scoreText, { time = 250, xScale = 2, yScale = 2, alpha = 0, onComplete = checkEndGame})
end

local function createLollipop(posX, posY)
    local myImageSheet = graphics.newImageSheet("assets/guiSheet/levelsIngameWinLose.png", AZ.atlas:getSheet())
    
    local lollipop = display.newImage(myImageSheet, 22, 0, 0)
    lollipop:setReferencePoint(display.CenterReferencePoint)
    lollipop.x, lollipop.y = posX, posY
    lollipop:scale(SCALE_DEFAULT, SCALE_DEFAULT)
    lollipop:rotate(10)
    
    lollipop.endTransitionTime = 0
    lollipop.pauseTransitionTime = 0
    lollipop.transitionID = nil
    lollipop.isFalling = false
    
    lollipop.move = function(transitionTime)
        lollipop.endTransitionTime = system.getTimer() + transitionTime
        
        lollipop.transitionID = transition.to(lollipop, { time = transitionTime, x = lollipopsTable[mLife -1].x + 46 * SCALE_DEFAULT, y = lollipopsTable[mLife -1].y })
    end
    
    lollipop.pause = function(isPause)
        if lollipop.isFalling == false then
            return
        end
        
        if isPause == true then
            lollipop.pauseTransitionTime = lollipop.endTransitionTime - system.getTimer()
            transition.cancel(lollipop.transitionID)
        else
            lollipop.move(lollipop.pauseTransitionTime)
            lollipop.pauseTransitionTime = 0
        end
    end
    
    lollipop.destroyLollipop = function()
        if lollipop ~= nil then
            
            if lollipop.transitionID ~= nil then
               transition.cancel(lollipop.transitionID)
               lollipop.transitionID = nil
            end
        
            lollipop:removeSelf()
            lollipop = nil
            
            table.remove(lollipopsTable, #lollipopsTable)
        end
    end
    
    return lollipop
end

local function updateLife()
    if mLife >= 0 and mLife +1 <= #lollipopsTable then
        local currentLollipop = lollipopsTable[mLife +1]
        
        if currentLollipop.transitionID ~= nil then
            transition.cancel(currentLollipop.transitionID)
            currentLollipop.transitionID = nil
        end
        
        currentLollipop.isFalling = false
        currentLollipop.transitionID = transition.to(currentLollipop, { time = 1000, xScale = 0.01, yScale = 0.01, alpha = 0, onComplete = currentLollipop.destroyLollipop })
    end
end

local function createScoreText(score, posX, posY)
    
    if isAlive() == false then
        return
    end
    
    local newScore = display.newText(score, 0, 0, INGAME_SPAWN_SCORE_FONT, INGAME_SPAWN_SCORE_SIZE)
    newScore:setReferencePoint(display.CenterReferencePoint)
    newScore.x, newScore.y = posX, posY
    newScore:setTextColor(INGAME_SPAWN_SCORE_COLOR[1], INGAME_SPAWN_SCORE_COLOR[2], INGAME_SPAWN_SCORE_COLOR[3])
    
    newScore.score = score
    
    newScore.endTransitionTime, newScore.pauseTransitionTime = 0, 0
    
    newScore.move = function(transitionTime)
        newScore.endTransitionTime = system.getTimer() + transitionTime
        newScore.transitionID = transition.to(newScore, { time = transitionTime, transition = easing.inOutExpo, x = scoreText.x, y = scoreText.y, onComplete = newScore.addScore })
    end
    
    newScore.pause = function(isPause)
        if newScore == nil then
            return
        end
        
        if isPause == true then
            newScore.pauseTransitionTime = newScore.endTransitionTime - system.getTimer()
            transition.cancel(newScore.transitionID)
        else
            newScore.move(newScore.pauseTransitionTime)
            newScore.pauseTransitionTime = 0
        end
    end
    
    newScore.destroyScore = function()
       if newScore ~= nil then
           
           if newScore.transitionID ~= nil then
               transition.cancel(newScore.transitionID)
               newScore.transitionID = nil
           end
           
           newScore:removeSelf()
           newScore = nil
           
           table.remove(scoreTable, 1)
       end
    end
    
    newScore.addScore = function()
        updateScore(newScore.score)
        
        if isAlive() then
            newScore.destroyScore()
        end
    end
    
    local transitionTime = math.sqrt(((posX - RELATIVE_SCREEN_X2) * (posX - RELATIVE_SCREEN_X2)) + ((posY - 60) * (posY - 60)))
    transitionTime = transitionTime *1.5
    
    newScore.move(transitionTime)
    newScore.endTransitionTime = transitionTime + system.getTimer()
    
    scoreTable[#scoreTable +1] = newScore
    group:insert(newScore)
end

local function createComboEffect(x, y)
    local myImageSheet = graphics.newImageSheet("assets/guiSheet/levelsIngameWinLose.png", AZ.atlas:getSheet())
    
    --local comboEffect = display.newImage(myImageSheet, AZ.atlas:getFrameIndex("x".. mComboCount))
    
    local myScale = SCALE_BIG * (mComboCount * 0.05)
    if myScale > SCALE_BIG then
        myScale = SCALE_BIG
    end
    
    myScale = myScale + SCALE_BIG
    
    local comboEffect = display.newText("x".. mComboCount, 0, 0, INTERSTATE_BOLD, BIG_FONT_SIZE + BIG_FONT_SIZE)
    comboEffect:setTextColor(INGAME_COMBO_COLOR[1], INGAME_COMBO_COLOR[2], INGAME_COMBO_COLOR[3])
    comboEffect:scale(myScale, myScale)
    comboEffect:setReferencePoint(display.CenterReferencePoint)
    comboEffect.x, comboEffect.y = x, y
    comboEffect:rotate(math.random(-15, 15))
    comboEffect:toFront()
    
    -- AZ.audio.playFX(AZ.soundLibrary.comboSound, AZ.audio.AUDIO_VOLUME_OTHER_FX)
    
    comboEffect.destroyCombo = function()
        if comboEffect ~= nil then
            
            if comboEffect.transitionID ~= nil then
                transition.cancel(comboEffect.transitionID)
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
    
    comboEffect.transitionID = transition.from(comboEffect, { delay = 200, time = 200, xScale = 0.01, yScale = 0.01, onComplete = comboEffect.disappear })
    comboTable[#comboTable +1] = comboEffect
    group:insert(comboEffect)
end

local function finishCombo()
    AZ.audio.playFX(AZ.soundLibrary.comboSound, AZ.audio.AUDIO_VOLUME_OTHER_FX)
    
    if mHighestCombo < mComboCount then
        mHighestCombo = mComboCount
    end
    
    mComboTimer = nil
end

function addScore(shouldBreakCombo, addedScore, x, y)
    if isAlive() == false then
        return
    end
    
    mDisappearedZombies = mDisappearedZombies +1
    
    if shouldBreakCombo == false and addedScore~= 0 then
        
        if mComboCount == 0 or mInitComboTime < system.getTimer() then
            mComboCount = 0
            mInitComboTime = system.getTimer() + INGAME_COMBO_TIME
        end
        
        local lapseTime = INGAME_COMBO_TIME - (INGAME_COMBO_TIME * (mComboCount * 0.07))
        
        mKilledZombies = mKilledZombies +1
        mComboCount = mComboCount +1
        mInitComboTime = system.getTimer() + lapseTime
        
        if mComboCount > 1 then
            mComboScore = mComboScore + ((addedScore * mComboCount) - addedScore)
            addedScore = addedScore * mComboCount
            
            createComboEffect(x, y)
            
            if mComboTimer ~= nil then
                timer.cancel(mComboTimer)
                mComboTimer = nil
            end
            mComboTimer = timer.performWithDelay(lapseTime, finishCombo)
        end
        
        createScoreText(addedScore, x, y)
        
    else
        mComboCount = 0
    end
    
    checkEndGame()
end 

function useRake(isTipRake)
    isUsingRake = true
    
    local myImageSheet = graphics.newImageSheet("assets/guiSheet/levelsIngameWinLose.png", AZ.atlas:getSheet())
    
    rakeImage = display.newImage(myImageSheet, 18)
    rakeImage:setReferencePoint(display.CenterReferencePoint)
    rakeImage:scale(SCALE_DEFAULT, SCALE_DEFAULT)
    rakeImage.x, rakeImage.y = 100 * SCALE_DEFAULT, 200 * SCALE_DEFAULT
    
    rakeImage.endFunc = nil
    
    group:insert(rakeImage)
    
    rakeImage.destroy = function()
        if rakeImage.timerID ~= nil then
            timer.cancel(rakeImage.timerID)
        end
        
        if rakeImage.transitionID ~= nil then
            transition.cancel(rakeImage.transitionID)
        end
        
        isUsingRake = false
        AZ.utils.activateDeactivateMultitouch(true)
        _slash.destroy()
        
        if rakeImage.endFunc ~= nil then
            rakeImage.endFunc()
        end
        
        rakeImage:removeSelf()
        rakeImage = nil
    end
    
    rakeImage.fadeOut = function()
        rakeImage.transitionID = transition.to(rakeImage, { time = 500, xScale = 0.001, yScale = 0.001, onComplete = rakeImage.destroy, transition = easing.inOutQuad })
    end
    
    AZ.utils.activateDeactivateMultitouch(false)
    
    if not isTipRake then
        rakeImage.timerID = timer.performWithDelay(INGAME_RAKE_TIME -500, rakeImage.fadeOut)
    end
end

function stopRake(myTime, endFunc)
    rakeImage.endFunc = endFunc
    rakeImage.timerID = timer.performWithDelay(myTime, rakeImage.fadeOut)
end

function heal(posX, posY)
    if mLife == 0 then
        return
    end
    
    mLife = mLife +1
    
    if mLife > INGAME_MAX_LIFES then
        mLife = INGAME_MAX_LIFES
        return
    end
    
    if isAlive() and lollipopsTable[mLife] ~= nil then
        lollipopsTable[mLife].destroyLollipop()
    end
    
    local lollipop = createLollipop(posX, posY)
    
    lollipopsTable[mLife] = lollipop
    group:insert(lollipop)
    
    lollipop.isFalling = true
    lollipop.move(100)
end

function damage()

    if AZ.isGodMode then
        return false
    end
    
    mLife = mLife -1
    
    AZ.utils.vibrate()
    
    damageFrame.alpha = 0
    transition.from(damageFrame, { time = 500, alpha = 0.5 })
    
    if mLife < 1 and isEndGame == nil then
        mLife = 0
        isEndGame = false
    end
    
    updateLife()
        
    return isAlive()
end

function pause(isPause)
    for i=1, #scoreTable do
        scoreTable[i].pause(isPause)
    end
    
    for i=1, #lollipopsTable do
        lollipopsTable[i].pause(isPause)
    end
    
    if rakeImage ~= nil and rakeImage.timerID ~= nil then
        if isPause == true then
            timer.pause(rakeImage.timerID)
        else
            timer.resume(rakeImage.timerID)
        end
    end
end

function destroy()
    
    for i=1, #scoreTable do
        scoreTable[1].destroyScore()
    end
    
    for i=1, #lollipopsTable do
        if lollipopsTable[1] ~= nil then
            if lollipopsTable[1].transitionID ~= nil then
                transition.cancel(lollipopsTable[1].transitionID)
                lollipopsTable[1].transitionID = nil
            end

            lollipopsTable[1]:removeSelf()
            lollipopsTable[1] = nil
            
            table.remove(lollipopsTable, 1)
        end
    end
    
    for i=1, #comboTable do
        comboTable[1].destroyCombo()
    end
    
    if damageFrame ~= nil then
        damageFrame:removeSelf()
        damageFrame = nil
    end
    
    if rakeImage ~= nil then
        rakeImage.destroy()
    end
end

function init(maxZombies, lollipopPanelPosX, currentStage, currentLevel, slash)
    group = display.newGroup()
    
    _slash = slash
    
    mCurrentStage = currentStage
    mCurrentLevel = currentLevel
    
    mLife = INGAME_MAX_LIFES

    mComboTimer = nil
    mComboCount = 0
    mComboScore = 0
    mInitComboTime = 0
    mHighestCombo = 0
    
    mKilledZombies = 0
    mDisappearedZombies = 0
    mMaxZombiesInLevel = maxZombies
    
    isEndGame = nil
    isUsingRake = false
    
    -- score
    scoreText = display.newText("0", 0, 0, INGAME_SCORE_FONT, INGAME_SCORE_SIZE)
    scoreText:setTextColor(INGAME_SCORE_COLOR[1], INGAME_SCORE_COLOR[2], INGAME_SCORE_COLOR[3])
    scoreText:setReferencePoint(display.CenterReferencePoint)
    scoreText.x = display.contentCenterX
    scoreText.y = 65 * SCALE_BIG
    scoreText:toBack()
    group:insert(scoreText)
    
    -- lollipops
    lollipopsTable = {}
    for i=1, 3 do
        local lollipop = createLollipop(lollipopPanelPosX + (46 * SCALE_DEFAULT * (i -2)), 93 * SCALE_DEFAULT)
        
        lollipopsTable[i] = lollipop
        group:insert(lollipop)
    end
    
    scoreTable = {}
    comboTable = {}
    
    damageFrame = display.newRect(0, 0, display.contentWidth *1.3, display.contentHeight)
    damageFrame:setFillColor(255, 0, 0)
    damageFrame:setReferencePoint(display.CenterReferencePoint)
    damageFrame.x, damageFrame.y = display.contentCenterX, display.contentCenterY
    damageFrame.alpha = 0
    
    group:insert(damageFrame)
    
    return group
end
