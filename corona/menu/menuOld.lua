
require "constants"
require "emblemContainer"

local scene = AZ.S.newScene() 


scene.background   = nil
scene.lightning    = nil
scene.logo 			= nil
scene.paw          = nil

scene.btnPlay      = nil
scene.btnSurvival  = nil
scene.btnOptions   = nil
scene.btnCredits   = nil
scene.achievements = nil
scene.btnGameSrv 	= nil
scene.btnFacebook 	= nil
scene.btnTwitter	= nil


scene.onTouch = function(event)
    if event.phase == "ended" or event.phase == "release" then
        if event.id == "survival" then
            print("Pushed survival")
        elseif event.id == "gameServiceLeaderboard" then
            GameServicesController:show("achievements")
        elseif event.id == "gameServiceAchievements" then
            GameServicesController:show("leaderboards")
        elseif event.id == "btnFacebook" then
            print("TODO: Enlazar con Facebook")
        elseif event.id == "btnTwitter" then
            print("TODO: Enlazar con Twitter")
        else
            
            scene.paw.initTransID = transition.safeCancel(scene.paw.initTransID)
            scene.paw.transID = transition.safeCancel(scene.paw.transID)
            if scene.lightning ~= nil then
                scene.lightning.transID = transition.safeCancel(scene.lightning.transID)
            end
            
            local options = {
                effect = SCENE_TRANSITION_EFFECT,
                time = SCENE_TRANSITION_TIME,
                params = { stage = 1, source = "menu.menu" }
            }
            AZ.S.gotoScene(event.id, options)
        end
    end
    
    return true
end 

scene.createMenuButtons = function()
    
    local buttonsGroup = display.newGroup()
    local yPos = display.contentHeight *0.35
    
    scene.btnPlay = AZ.ui.newTextButton({
        txt = AZ.utils.translate("PLAY"),
        font = INTERSTATE_BOLD,
        size = 70,
        x = display.contentCenterX,
        y = yPos,
        unpressedColor = INGAME_COMBO_COLOR,
        pressedColor = INGAME_SCORE_COLOR,
        onEvent = scene.onTouch,
        id = "stage.stage"
    })
    
    yPos = yPos + (display.contentHeight *0.11)
    
	scene.btnSurvival = AZ.ui.newTextButton({
		txt = AZ.utils.translate("SURVIVAL"),
		font = INTERSTATE_BOLD,
		size = 70,
		x = display.contentCenterX,
		y = yPos,
		unpressedColor = INGAME_COMBO_COLOR,
		pressedColor = INGAME_SCORE_COLOR,
		onEvent = scene.onTouch,
		id = "survival"
	})
	
	if AZ.isSurvivalEnabled then
		yPos = yPos + (display.contentHeight *0.11)
	else
		scene.btnSurvival.isVisible = false
		buttonsGroup.y = display.contentHeight *0.07
    end
	
    scene.btnShop = AZ.ui.newTextButton({
        txt = AZ.utils.translate("SHOP"),
        font = INTERSTATE_BOLD,
        size = 70,
        x = display.contentCenterX,
        y = yPos,
        unpressedColor = INGAME_COMBO_COLOR,
        pressedColor = INGAME_SCORE_COLOR,
        onEvent = scene.onTouch,
        id = "shop.shop"
    })
    
    local scale = (SCALE_BIG + SCALE_DEFAULT) *0.5 --display.contentWidth/512
    
    scene.btnPlay:scale(scale,scale)
    buttonsGroup:insert(scene.btnPlay)
    scene.btnSurvival:scale(scale,scale)
    buttonsGroup:insert(scene.btnSurvival)
    scene.btnShop:scale(scale,scale)
    buttonsGroup:insert(scene.btnShop)
    return buttonsGroup
end

scene.setButtonsAlpha = function(alpha)
    scene.logo.alpha = alpha
    scene.btnPlay.alpha = alpha
    scene.btnSurvival.alpha = alpha
    scene.btnShop.alpha = alpha
    scene.btnOptions.alpha = alpha
    scene.btnCredits.alpha = alpha
    scene.btnGameSrv.alpha = alpha
    scene.achievements.alpha = alpha
    scene.btnFacebook.alpha = alpha
    scene.btnTwitter.alpha = alpha
end

scene.enableDisableButtons = function(enable)
    scene.logo.isActive = enable
    scene.btnPlay.isActive = enable
    scene.btnSurvival.isActive = enable
    scene.btnShop.isActive = enable
    
    scene.btnOptions.isActive = enable
    scene.btnCredits.isActive = enable
    
    scene.btnGameSrv.isActive = enable
    scene.achievements.isActive = enable
    
    scene.btnFacebook.isActive = enable
    scene.btnTwitter.isActive = enable
    
    scene.paw.isActive = enable
end

local setButtonsAlpha = function(alpha)
    scene.btnPlay.alpha = alpha
    scene.btnSurvival.alpha = alpha
    scene.btnShop.alpha = alpha
    
    scene.btnOptions.alpha = alpha
    scene.btnCredits.alpha = alpha
    
    scene.achievements.alpha = alpha
    scene.btnGameSrv.alpha = alpha
    
    scene.btnFacebook.alpha = alpha
    scene.btnTwitter.alpha = alpha
end

scene.finishInitialEffect = function()
    scene.lightning.transID = transition.safeCancel(scene.lightning.transID)
    scene.enableDisableButtons(true)
    AZ.audio.playBSO(AZ.soundLibrary.menuLoop)
end

scene.callLightning = function()
    local audioHandle = AZ.soundLibrary.lightningSound
    AZ.audio.playFX(audioHandle, AZ.audio.AUDIO_VOLUME_OTHER_FX)
    
    AZ.utils.vibrate()
    
    scene.lightning.transID = transition.from(scene.lightning, { time = audio.getDuration(audioHandle) * 0.2, alpha = 1, onComplete = scene.finishInitialEffect })
    
    setButtonsAlpha(1)

    local function pawInitTransEnd()
        scene.paw.initTransID = transition.safeCancel(scene.paw.initTransID)
        scene.paw.secondaryTransition()
    end

    scene.paw.initTransID = transition.to(scene.paw, {time = 500, x = scene.paw.originalX, y = scene.paw.originalY, easing = easing.inExpo, onComplete = pawInitTransEnd })
end

scene.createInitialEffect = function()
    local audioHandle = AZ.soundLibrary.welcomeSound
    local welcomeChannel = audio.play(audioHandle, { onComplete = scene.callLightning })
    audio.setVolume(AZ.audio.AUDIO_VOLUME_OTHER_FX, { channel = welcomeChannel })
end


scene.createPaw = function()

    local myImageSheet = graphics.newImageSheet("menu/assets/menuOptionsPauseLoading.png", AZ.atlas:getSheet())
    
    scene.paw = display.newImage(myImageSheet, 43)
    scene.paw.x = display.contentCenterX-- *1.15
    scene.paw:scale(SCALE_DEFAULT *1.5, SCALE_DEFAULT *1.5)
    scene.paw.originalX, scene.paw.originalY = scene.paw.x, display.contentHeight -(scene.paw.contentHeight *0.4)
    scene.paw.isActive = true
    scene.paw.contador = 0
    scene.paw.rotation = -15
    
    scene.paw.secondaryTransition = function()
        scene.paw.contador = scene.paw.contador + 1
        
        scene.paw.transID = transition.safeCancel(scene.paw.transID)
        
        if (scene.paw.contador < 20) then
            local newScale = 10 * SCALE_DEFAULT
            
            scene.paw.transID = transition.to(scene.paw, { time = 20, x = scene.paw.originalX + math.random(-newScale, newScale), y = scene.paw.originalY + math.random(-newScale, newScale), onComplete = scene.paw.secondaryTransition })
        else
            scene.paw.transID = transition.to(scene.paw, { time = 20, x = scene.paw.originalX, y = scene.paw.originalY, onComplete = function() scene.paw.transID = transition.safeCancel(scene.paw.transID) end })
            scene.paw.contador = 0
            scene.paw.isActive = true
       end
    end
    
    function scene.paw.onTouch(event)
        if event.phase == "began" and scene.paw.isActive then
            scene.paw.transID = transition.safeCancel(scene.paw.transID)
            scene.paw.isActive = false
            scene.paw.secondaryTransition()
            AZ.utils.vibrate()
        end
    end
    
    scene.paw:addEventListener("touch", scene.paw.onTouch)

    return scene.paw
end

scene.addButtons = function(group)
    local atlas = require "menu.assets.sheets.icons"
    local sheet = graphics.newImageSheet("menu/assets/sprites/icons.png",atlas:getSheet())
    local grp = display.newGroup()
    
    local function createButton(id, unpressed, pressed)
        local btn = AZ.ui.newEnhancedButton2({ id = id, myImageSheet = sheet, unpressedIndex = unpressed, pressedIndex = pressed, x = 0, y = 0, onEvent = scene.onTouch })
        btn:scale(SCALE_BIG, SCALE_BIG)
        grp:insert(btn)
        return btn
    end
    
    scene.btnOptions = createButton("options.options", 4, 3)
    scene.btnCredits = createButton("credits.credits", 12, 11)
    scene.achievements = createButton("gameServiceAchievements", 6, 5)
    scene.btnGameSrv = createButton("gameServiceLeaderboard", 8, 7)
    scene.btnFacebook = createButton("btnFacebook", 1, 1)
	scene.btnTwitter = createButton("btnTwitter", 2, 2)
    
	scene.achievements.isVisible = false
    scene.btnGameSrv.isVisible = false
    scene.btnFacebook.isVisible = false
	scene.btnTwitter.isVisible = false
	
	
    local space = display.contentWidth *0.05
    
    scene.btnOptions.x, scene.btnOptions.y      	= scene.btnOptions.contentWidth *0.5 + space, display.contentHeight - (space + scene.btnOptions.contentHeight *0.5)
    scene.btnCredits.x, scene.btnCredits.y      	= scene.btnOptions.contentBounds.xMax + space + (scene.btnCredits.contentWidth *0.5), scene.btnOptions.y
    scene.achievements.x, scene.achievements.y	= display.contentWidth - (space + scene.achievements.contentWidth *0.5), scene.btnOptions.y
    scene.btnGameSrv.x, scene.btnGameSrv.y      	= scene.achievements.contentBounds.xMin - (space + scene.btnGameSrv.contentWidth *0.5), scene.btnOptions.y
    scene.btnFacebook.x, scene.btnFacebook.y		= scene.footer.contentBounds.xMin + (scene.footer.contentWidth *0.2187), scene.footer.contentBounds.yMin + (scene.footer.contentHeight *0.5378)
    scene.btnTwitter.x, scene.btnTwitter.y      	= scene.footer.contentBounds.xMin + (scene.footer.contentWidth *0.1972), scene.footer.contentBounds.yMin + (scene.footer.contentHeight *0.6772)
    
    scene.btnFacebook:scale(0.9, 0.9)
    scene.btnTwitter:scale(0.9, 0.9)
    
    atlas = AZ.utils.unloadModule("menu.assets.sheets.icons")
    sheet = nil
    
    return grp
end

scene.addBackground = function()
	local bg = display.newImage("assets/fondoliso.jpg")
    bg:scale(display.contentHeight/bg.height, display.contentHeight/bg.height)  
    bg.x, bg.y = display.contentCenterX, display.contentCenterY
    return bg
end

scene.addFooter = function()
    scene.footer = display.newImage("menu/assets/sprites/footer.png")
    scene.footer.anchorX = 0.5
    scene.footer.anchorY = 1
    scene.footer.x = display.contentCenterX
    scene.footer.y = display.contentHeight
    local scale = (display.contentWidth *1.1)/scene.footer.contentWidth
    scene.footer:scale(scale,scale)
    return scene.footer
end

scene.addLogo = function()
    local scale = SCALE_DEFAULT --display.contentWidth/768
    scene.logo = display.newImage("menu/assets/sprites/logo.png")
    scene.logo.x, scene.logo.y = display.contentCenterX, display.contentHeight *0.125
    scene.logo:scale(scale,scale)
	
	local function foo2(success, receipt)
		print("success?", success)
		AZ.utils.print(receipt, "receipt")
	end
	
	local function foo1(event)
		if event.phase == "ended" then
			AZ.Gamedonia:buyProduct(event.target.id, foo2, true)
		end
	end
	
	local function createSq(x, col, id)
		local sq = display.newRect(x, display.contentHeight *0.2, display.contentHeight *0.1, display.contentHeight *0.1)
		sq:setFillColor(unpack(col))
		sq.id = id
		sq:addEventListener("touch", foo1)
		
	end
	--[[
	createSq(display.contentWidth *0.2, { 1, 0, 0 }, "bank_00_coins")
	createSq(display.contentWidth *0.4, { 0, 1, 0 }, {"bank_00_coins"})
	createSq(display.contentWidth *0.6, { 0, 0, 1 }, "com.thousandgears.animalzombies2.bank_00_coins")
	createSq(display.contentWidth *0.8, { 1, 1, 1 }, {"com.thousandgears.animalzombies2.bank_00_coins"})
	]]
    return scene.logo
end

function scene:createScene( event )

    local group = self.view
    
    group:insert(scene.addBackground())
    group:insert(scene.addFooter())
    group:insert(scene.addLogo())
    group:insert(scene.createPaw())
    group:insert(scene.createMenuButtons())
    group:insert(scene.addButtons())

	local sq = display.newRect(0, 0, 10, 10)
	sq.x, sq.y = 5, 5
	sq:setFillColor(1, 0, 0)
	scene.view:insert(sq)

    if event.params ~= nil and event.params.firstTime ~= nil and AZ.audio.FX_ENABLED == true then
        scene.lightning = display.newRect(0, 0, display.contentWidth *1.3, display.contentHeight)
        scene.lightning.x, scene.lightning.y = display.contentCenterX, display.contentCenterY
        scene.lightning.alpha = 0
        group:insert(scene.lightning)

        setButtonsAlpha(0)
        scene.enableDisableButtons(false)
        
        scene.paw.y = display.contentHeight + scene.paw.contentHeight
        
        scene.createInitialEffect()
    else
        scene.paw.y = scene.paw.originalY
        AZ.audio.playBSO(AZ.soundLibrary.menuLoop)
    end
end

local function alertListener(event)
	AZ.utils.print(event)
	if event.action == "clicked" and event.index == 2 then
		os.exit()
	end
end

function scene.onBackTouch()
	
	native.showAlert("EXIT", "Are you sure you want to quit?", { "NO", "YES" }, alertListener)
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener( "createScene", scene )
 
return scene
