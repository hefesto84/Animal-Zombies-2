
local scene = AZ.S.newScene()

--scene.view = nil

-- requires
scene._gameplay = nil
scene._ui = nil

-- informació del nivell
scene.levelInfo = nil
scene.stage     = nil
scene.level     = nil

-- temps
scene.initGameTime = nil
scene.pauseTime    = nil

-- altres variables
scene.isInTip          = false
scene.isPause          = false
scene.pauseType		= nil
scene.endGameTimerID   = nil

local bso = nil


function scene.endLevel(event)
    
    local combos = scene._ui.getComboScore()
    local deaths = scene._ui.getDeaths()
    local lives = scene._ui.getLifes()
    local killerZombie = scene._ui.getKillerZombie()
    local killPercent = scene._gameplay.getKillPercent()
    
    local options = {
        effect = "slideDown",
        time = SCENE_TRANSITION_TIME,
        params = {  currentLevel = scene.level, currentStage = scene.stage,
                    gameLives = lives,          gameCombos = combos,
                    gameDeaths = deaths,        gameTime = system.getTimer() - scene.initGameTime,
                    gamePercent = killPercent,  killer = killerZombie
                 }
    }
    
	AZ.achievementsManager:levelPlayed(event.success)
	
	if event.success then
        AZ.S.gotoScene("win.test_win", options);
    else
        AZ.S.gotoScene("lose.lose", options);
    end
end

function scene.update()
    scene._gameplay.update()
end

function scene.refillLollipops(event)
    if event.isPause then
        -- cridem els lollipops
        AZ.S.showOverlay("popups.popupwolollipops", { effect = "fade", time = 400, isModal = true, params = { currentStage = scene.stage, currentLevel = scene.level } })
    else
        if event.success then
            -- seguim la partida
            scene._ui.resumeGame()
        else
            -- perdem
            Runtime:dispatchEvent({ name = GAMEPLAY_END_IS_NEAR_EVNAME, success = false })
            scene.endGameTimerID = timer.performWithDelay(1000, function() Runtime:dispatchEvent({ name = GAMEPLAY_END_GAME_EVNAME, success = false }) end)
        end
    end    
end

function scene.buyWeapons(event)
    if event.isPause then
        -- cridem el popup de compra d'armes
        AZ.S.showOverlay("popups.popuprefillweapon", { effect = "fade", time = 400, isModal = true, params = { weaponName = event.wName } })
    else
        if event.success then
            -- hem afegit armes
            Runtime:dispatchEvent({ name = GAMEPLAY_POWERUP_GET, powerUpName = event.weaponName, amount = event.weaponAmount })
        else
            -- no hem afegit armes, no fem res
        end
    end 
end

function scene.pauseGameplay(event)
    if event.isPause then
        -- cridem l'overlay de pausa
        AZ.S.showOverlay("pause.pause", { effect = "fade", time = 400, isModal = true, params = { currentStage = scene.stage, currentLevel = scene.level } })
    else
		-- no fem res
    end
end

function scene.pause(event)
    
	if scene.pauseType == event.pauseType and scene.isPause == event.isPause then
		return
	end
	
	if scene.pauseType == "refillLollipops" and event.pauseType ~= scene.pauseType then
		return
	end
	
    if scene.isPause ~= event.isPause then
        scene.isPause = event.isPause
        
		AZ.utils.activateDeactivateMultitouch(not scene.isPause)
		
        if scene.isPause then
            scene.pauseTime = system.getTimer()
            
            AZ.audio.fadeBSO(0.05)
        else
            scene.initGameTime = scene.initGameTime + (system.getTimer() - scene.pauseTime)
            scene.pauseTime = 0
            
            AZ.audio.fadeBSO(AZ.audio.AUDIO_VOLUME_BSO)
        end
    end
    
	scene.pauseType = event.pauseType
	
    if scene.pauseType == "pause" then
        scene.pauseGameplay(event)
    elseif scene.pauseType == "refillLollipops" then
        scene.refillLollipops(event)
    elseif scene.pauseType == "buyWeapons" then
        scene.buyWeapons(event)
    end
end

function scene.onBackTouch()
	Runtime:dispatchEvent({ name = GAMEPLAY_PAUSE_EVNAME, isPause = true, pauseType = "pause" })
end

scene.startGame = function()
    scene.initGameTime = system.getTimer()
    
    AZ.audio.playBSO(bso)
    
    scene._ui.activateDeactivateButtons(true, true, "save")
    
    Runtime:addEventListener("enterFrame", scene.update)
end

function scene:createScene(event)
    
-------------------------------- SETEIG INICIAL --------------------------------
	scene.level = event.params.level
    scene.stage = event.params.stage
    
	scene.pauseType = nil
	
	
-- modificacio del levelInfo per a incloure un per un els zombies, en mode normal i en last wave
    local _info = require("test_infoStage".. scene.stage)
    scene.stageInfo = _info.stageInfo
    bso = _info.stage_bso
    _info = AZ.utils.unloadModule("test_infoStage".. scene.stage)
    
    scene.levelInfo = AZ.gameInfo[scene.stage].gameplay.stages[1].levels[scene.level]
    
    scene.levelInfo.levelBalance.zombiesArray = {}
    scene.levelInfo.levelBalance.waveArray = {}
    
    for i = 1, #scene.levelInfo.levelBalance.zombies do
        
        local zType = scene.levelInfo.levelBalance.zombies[i]
        local zWave = math.round(zType.quantity * scene.levelInfo.levelBalance.wavePercent *0.01)
         
        for j = 1, zType.quantity do
            
            scene.levelInfo.levelBalance.zombiesArray[#scene.levelInfo.levelBalance.zombiesArray +1] = zType.type
            
            if j <= zWave then
                scene.levelInfo.levelBalance.waveArray[#scene.levelInfo.levelBalance.waveArray +1] = zType.type
            end
        end
    end
    
    scene.initGameTime = 0
    scene.pauseTime = 0

    scene.countDown = 3
    scene.countDownTimerID = nil
    scene.countDownNumber = nil 

    scene.isInTip = false
    scene.isPause = false
    scene.endGameTimerID = nil
    
    Runtime:addEventListener(GAMEPLAY_PAUSE_EVNAME, scene.pause)
    
----------------------------------- REQUIRES -----------------------------------
    scene._gameplay = require "test_gameplay"
    scene._ui = require "test_ingameUI"
    
    Runtime:addEventListener(GAMEPLAY_NO_LIFES_LEFT_EVNAME, scene.refillLollipops)
    Runtime:addEventListener(GAMEPLAY_END_GAME_EVNAME, scene.endLevel)
    
    local _atlas = require "assets.Atlas.gameplayAtlas"
    local spriteSheet = graphics.newImageSheet("assets/new_guiSheet/gameplay.png", _atlas:getSheet())
    _atlas = AZ:unloadModule("assets.Atlas.gameplayAtlas")
    
    scene.view.gameplay = scene._gameplay.initializeGameplay(scene, scene.levelInfo, scene.stageInfo, scene._ui, spriteSheet)
    scene.view.ui = scene._ui.initializeUI(scene.stage, scene.level, spriteSheet, scene.levelInfo.levelBalance.requiredWeapons, scene.levelInfo.levelBalance.shovelsAmount, #scene.levelInfo.levelBalance.zombiesArray + #scene.levelInfo.levelBalance.waveArray, scene._gameplay)
	scene.view:insert(scene.view.gameplay)
	scene.view:insert(scene.view.ui)
    
    -- ara canviem d'arma
    scene._gameplay.setNewWeapon(SHOVEL_NAME)
    
    -- després d'inicialitzar el gameplay, bloquejem els botons de les armes
    scene._ui.activateDeactivateButtons(true, false, "save")

end

scene.endTipCallback = function()
    scene.isInTip = false
	
	scene._ui.heal(7)
 
	if audio.isChannelPlaying(1) then
        audio.stop(1)
        --audio.dispose(loopHandle)
    end
	
    scene._tip = AZ.utils.unloadModule("test_tipController")
    scene._ui.startCountDown(scene.startGame)
    Runtime:removeEventListener(GAMEPLAY_FINISH_TIP_EVNAME, scene.endTipCallback)
end

function scene:enterScene(event)
    
	AZ.utils.activateDeactivateMultitouch(true)
	
    -- --FlurryController:logEvent("in_game", { stage = event.params.stage, level = event.params.level, game_state = "Playing" })

    if AZ.showTips and scene.levelInfo.levelBalance.ingameTip and scene.levelInfo.levelBalance.ingameTip ~= "none" then
        
        scene.isInTip = true
        
        Runtime:addEventListener(GAMEPLAY_FINISH_TIP_EVNAME, scene.endTipCallback)
		
		AZ.audio.playBSO(AZ.soundLibrary.tipLoop)
		
        scene._tip = require "test_tipController"
        
        scene.view.tip = scene._tip:initialize(AZ.tipsInfo, scene.levelInfo.levelBalance.ingameTip, scene._ui, scene._gameplay)
		scene.view:insert(scene.view.tip)
		scene.view.ui:toFront()
    else
        scene._ui.startCountDown(scene.startGame)
    end
end

function scene:exitScene(event)
	
    if scene.isInTip then
        Runtime:removeEventListener(GAMEPLAY_FINISH_TIP_EVNAME, scene.endTipCallback)
        scene._tip:destroyTip()
        scene._tip = AZ.utils.unloadModule("test_tipController")
    end
    
    Runtime:removeEventListener(GAMEPLAY_END_GAME_EVNAME, scene.endLevel)
    Runtime:removeEventListener("enterFrame", scene.update)
    Runtime:removeEventListener(GAMEPLAY_PAUSE_EVNAME, scene.pause)
end

function scene:destroyScene(event)
    scene._ui.destroyUI()
    
    Runtime:dispatchEvent({ name = ALL_DESTROY_EVNAME})
    
	AZ.utils.activateDeactivateMultitouch(false)
	
    scene._gameplay = AZ:unloadModule("test_gameplay")
    scene._ui = AZ:unloadModule("test_ingameUI")
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene
