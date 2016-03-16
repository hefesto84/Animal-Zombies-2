
local scene = AZ.S.newScene()

scene._tip = nil
scene._board = nil
scene._background = nil
scene._zombies = nil
scene._lollipop = nil
scene._rake = nil
scene._ui = nil
scene._gameplay = nil
scene._slash = nil

scene.myImageSheet = nil

scene.levelInfo = nil

scene.mCurrentStage = nil
scene.mCurrentLevel = nil

scene.mInitGameTime = nil
scene.mPauseTime    = nil

scene.isPause       = false
scene.endGameTimer  = nil

scene.pauseBut = nil

scene.countDown         = 3
scene.countDownTimerID  = nil
scene.countDownNumber   = nil

local function activateDeactivatePause(active)
    scene.pauseBut.isActive = active
end

scene.endLevel = function()
    local combos = scene._ui.getComboScore()
    local deaths = scene._ui.getDeaths()
    local lives = scene._ui.getLives()
    
    local options = {
        effect = "slideDown",
        time = SCENE_TRANSITION_TIME,
        params = { currentLevel = scene.mCurrentLevel, currentStage = scene.mCurrentStage, gameLives = lives, gameCombos = combos, gameDeaths = deaths, gameTime = system.getTimer() - scene.mInitGameTime }
    }
    
    if scene._ui.isEndGame == true then
        AZ.S.gotoScene(WIN_NAME, options);
    else
        AZ.S.gotoScene(LOSE_NAME, options);
    end
end

scene.changePause = function()
    
    if scene.isPause == false then
        
        AZ.audio.fadeBSO(0.05)
        
        scene.mPauseTime = system.getTimer()
        scene.isPause = true
        
        local options = {
            effect = "fade",
            time = 400,
            params = { currentStage = scene.mCurrentStage, currentLevel = scene.mCurrentLevel },
            isModal = true
        }
        
        --FlurryController:logEvent("in_game", { stage = scene.mCurrentStage, level = scene.mCurrentLevel, game_state = "Paused" })

        AZ.S.showOverlay("pause", options)
    else
        AZ.audio.fadeBSO(AZ.audio.AUDIO_VOLUME_BSO)

        scene.mInitGameTime = scene.mInitGameTime + (system.getTimer() - scene.mPauseTime)
        scene.mPauseTime = 0
        scene.isPause = false
    end
    
    scene._ui.pause(scene.isPause)
    scene._gameplay.pause(scene.isPause)
end

scene.update = function()
    if scene._ui.isEndGame ~= nil and scene.endGameTimer == nil then
        scene._gameplay.disableGameplay()
        scene.endGameTimer = timer.performWithDelay(1500, scene.endLevel)
    elseif scene._ui.isAlive() == true then
        scene._gameplay.update()
    end
end

scene.onTouch = function(event)
    if event.phase == "release" and event.id == "Pause Button" and scene.isPause == false and scene._ui.isEndGame == nil then
        scene.changePause()
    end
end

scene.onSystemEvent = function(event)
    if event.type == "applicationSuspend" and scene.isPause == false and scene.pauseBut.isActive == true then
        scene.changePause()
    end
end

function scene:createScene( event )
    local group = self.view
    
    --FlurryController:logEvent("in_game", { stage = event.params.stage, level = event.params.level, game_state = "Playing" })
    
    scene._board = require "board"
    scene._background = require "ingameBackground"
    scene._zombies = require "zombie"
    scene._lollipop = require "lollipop"
    scene._rake = require "rake"
    scene._ui = require "ingameUI"
    scene._gameplay = require "gameplayController"
    scene._slash = require "slashEffect"
    
    scene.myImageSheet = graphics.newImageSheet("assets/guiSheet/levelsIngameWinLose.png", AZ.atlas:getSheet())
    
    scene.endGameTimer = nil
    
    scene.mCurrentLevel = event.params.level
    scene.mCurrentStage = event.params.stage
              
    require("infoStage" .. scene.mCurrentStage)
    scene.levelInfo = stage_level_info[scene.mCurrentLevel]
    AZ:unloadModule("infoStage".. scene.mCurrentStage)
    
    -- background
    local background = scene._background.createBackground(background_path, scene._slash)
    
    -- score panel
    local scorePanel = display.newImage(scene.myImageSheet, 20)
    scorePanel:setReferencePoint(display.TopCenterReferencePoint)
    scorePanel.x = RELATIVE_SCREEN_X2 - 5 * SCALE_BIG
    scorePanel.y = 15 * SCALE_BIG
    scorePanel:scale(SCALE_BIG, SCALE_BIG)
    
    -- lollipop panel
    local lollipopPanel = display.newImage(scene.myImageSheet, 21)
    lollipopPanel:setReferencePoint(display.TopCenterReferencePoint)
    lollipopPanel.x = display.contentWidth - RELATIVE_SCREEN_X6
    lollipopPanel.y = 15 * SCALE_BIG
    lollipopPanel:scale(SCALE_BIG *0.85, SCALE_BIG *0.85)
    
    -- pause button
    scene.pauseBut = AZ.ui.newEnhancedButton{
        sound = AZ.soundLibrary.buttonSound,
        pressed = 8, --"botonpausa-push",
        unpressed = 9, --"botonpausa",
        x = 30 * SCALE_DEFAULT,
        y = 80 * SCALE_DEFAULT,
        onEvent = scene.onTouch,
        id = "Pause Button"
    }
    scene.pauseBut.x = (50 + scene.pauseBut.contentWidth * 0.5) * SCALE_DEFAULT
    scene.pauseBut:scale(SCALE_DEFAULT,SCALE_DEFAULT)
    activateDeactivatePause(false)
    
    group:insert(background)
    group:insert(scorePanel)
    group:insert(lollipopPanel)
    group:insert(scene.pauseBut)
    group:insert(scene._gameplay.init(scene.levelInfo, scene.mCurrentStage , scene.mCurrentLevel, scene._background, scene._ui, scene._board, scene._zombies, scene._lollipop, scene._rake, scene._slash))
    group:insert(scene._ui.init(scene.levelInfo.maxZombiesInLevel + scene.levelInfo.waveZombies, lollipopPanel.x - (10 * SCALE_BIG), scene.mCurrentStage , scene.mCurrentLevel, scene._slash))
end

scene.startGame = function()
    scene.mInitGameTime = system.getTimer()
    activateDeactivatePause(true)
    
    AZ.audio.playBSO(stage_bso)
        
    Runtime:addEventListener("system", scene.onSystemEvent)
    Runtime:addEventListener("enterFrame", scene.update)
end

scene.countdownFunction = function()
    
    if scene.countDownNumber ~= nil then
        scene.countDownNumber.destroy()
    end
    
    local myCountDown = AZ.soundLibrary.countDownSound
    
    if scene.countDown == 0 then
        timer.cancel(scene.countDownTimerID)
        scene.countDownTimerID = nil
        
        AZ.audio.playFX(myCountDown[4], AZ.audio.AUDIO_VOLUME_OTHER_FX)
        
        timer.performWithDelay(audio.getDuration(myCountDown[4]) *0.5, scene.startGame)
        
        return
    end
    
    scene.countDownNumber = display.newImage(scene.myImageSheet, AZ.atlas:getFrameIndex("cuentaatras-".. scene.countDown))
    scene.countDownNumber:setReferencePoint(display.CenterReferencePoint)
    scene.countDownNumber.x, scene.countDownNumber.y = RELATIVE_SCREEN_X2, RELATIVE_SCREEN_Y2
    scene.countDownNumber:scale(SCALE_BIG, SCALE_BIG)
    scene.countDownNumber.alpha = 1
    
    scene.countDownNumber.destroy = function()
        if scene.countDownNumber.transitionID ~= nil then
            transition.cancel(scene.countDownNumber.transitionID)
        end
        
        scene.countDownNumber:removeSelf()
        scene.countDownNumber = nil
    end
    
    local doubleScaleBig = SCALE_BIG + SCALE_BIG
    
    AZ.audio.playFX(myCountDown[scene.countDown], AZ.audio.AUDIO_VOLUME_OTHER_FX)
    scene.countDownNumber.transitionID = transition.from(scene.countDownNumber, { alpha = 0, time = INGAME_COUNTDOWN_TIME, xScale = doubleScaleBig, yScale = doubleScaleBig, transition = easing.outQuad, onComplete = scene.countDownNumber.destroy })
    
    scene.countDown = scene.countDown -1
end

local function endTipCallback()
    scene.countDownTimerID = timer.performWithDelay(INGAME_COUNTDOWN_TIME, scene.countdownFunction, scene.countDown +1)
    Runtime:removeEventListener("tipCallback", endTipCallback)
end

function scene:enterScene( event )
    local group = self.view
    
    scene.isPause = false
    scene.mPauseTime = 0
    scene.countDown = 3
    
    scene._board.init()
    
    if scene.levelInfo.ingameTip ~= nil then
        scene._tip = require(scene.levelInfo.ingameTip)
        
        Runtime:addEventListener("tipCallback", endTipCallback)

        scene._tip.initialize(scene._board, scene._zombies, scene._lollipop, scene._rake, scene._ui)
    else
        scene.countDownTimerID = timer.performWithDelay(INGAME_COUNTDOWN_TIME, scene.countdownFunction, scene.countDown +1)
    end
end


function scene:exitScene( event )
    local lollipopSpawned, lollipopGet, lollipopLost, rakeSpawned, rakeGet, rakeLost = scene._gameplay.getPowerUpStatistics()
    local killedZombies, killedKindly, escapedZombies, zombieAttacks, killerZombie = scene._gameplay.getZombieStatistics()
    
    --[[
    	FlurryController:logEvent("in_game", {
        stage               = scene.mCurrentStage,
        level               = scene.mCurrentLevel,
        level_finished      = tostring(not scene.isPause),
        killed_zombies      = killedZombies,
        killed_kindly       = killedKindly,
        escaped_zombies     = escapedZombies,
        total_zombies       = scene.levelInfo.maxZombiesInLevel + scene.levelInfo.waveZombies,
        zombies_attacks     = zombieAttacks,
        lollipop_spawned    = lollipopSpawned,
        lollipop_get        = lollipopGet,
        lollipop_lost       = lollipopLost,
        rake_spawned        = rakeSpawned,
        rake_get            = rakeGet,
        rake_lost           = rakeLost,
        max_combo           = scene._ui.getHighestCombo(),
        killed_by           = killerZombie })
    ]]
    Runtime:removeEventListener("system", scene.onSystemEvent)
    Runtime:removeEventListener("enterFrame", scene.update)
    
    audio.fadeOut({ channel = 0, time = SCENE_TRANSITION_TIME })
    audio.stopWithDelay(SCENE_TRANSITION_TIME)
    AZ.zombiesLibrary.cleanUp()
end

function scene:destroyScene( event )
    local group = self.view
    
    if scene.isPause == true then
        AZ.S.hideOverlay()
    end
    
    scene._gameplay.destroy()
    scene._ui.destroy()
    
    scene._ui = AZ:unloadModule("ingameUI")
    scene._gameplay = AZ:unloadModule("gameplayController")
    scene._background = AZ:unloadModule("ingameBackground")
    scene._tip = AZ:unloadModule("test_tip_v1")
    scene._board = AZ:unloadModule("board")
    scene._zombies = AZ:unloadModule("zombie")
    scene._lollipop = AZ:unloadModule("lollipop")
    scene._rake = AZ:unloadModule("rake")
    scene._ui = AZ:unloadModule("ingameUI")
    scene._slash = AZ:unloadModule("slashEffect")

end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )
--scene:addEventListener( "overlayEnded", scene )

return scene