
local scene = AZ.S.newScene()

scene.group = nil

scene.background    = nil
scene.title         = nil

scene.btnSound = ""
scene.btnMusic = ""
scene.btnVibration = ""
scene.btnLanguage = ""
scene.btnReset = ""

scene.btnBack = ""

scene.localization = ""
scene.language = ""

scene.genericInfo = {}

scene.displayContentWidth10     = display.contentWidth  * 0.1
scene.displayContentWidth6      = display.contentWidth  * 0.16
scene.displayContentWidth2      = display.contentWidth  * 0.5
scene.displayContentHeight4     = display.contentHeight * 0.25
scene.displayContentHeight12    = display.contentHeight * 0.08

scene.options                   = { effect = "crossFade", time = 250 }

scene.isChange = false

scene.listenerReset = function(event)
    if event.action == "clicked" and event.index == 2 then
        ----FlurryController:logEvent("in_options", { type = "reset" })
        
		AZ.Gamedonia:resetUser()
    end
end

scene.resetText = function()
    display.remove(scene.title)
	display.remove(scene.txtSound)
    display.remove(scene.btnSound)
	display.remove(scene.txtMusic)
    display.remove(scene.btnMusic)
	display.remove(scene.txtVibration)
    display.remove(scene.btnVibration)
    display.remove(scene.btnReset)
	display.remove(scene.txtLanguage)
    display.remove(scene.btnLanguage)
    
    scene.createAll()
    scene.configure()
end

local function getStateNumber(isActive)
	if isActive then
		return 1
	else
		return 0
	end
end

scene.onTouch = function(event)
    if event.phase == "release" or event.phase == "ended" then
        if(event.target.id == "BackButton") and event.target.isWithinBounds then
			scene.options.effect = "slideUp"
            AZ.S.gotoScene("menu.menu", scene.options)
        
        elseif event.target.id == "Reset" and event.target.isWithinBounds then
            local loc, lan = scene.localization, scene.language
            native.showAlert(loc["reset_progress"][lan], loc["reset_progress_sure"][lan], { loc["cancel"][lan], loc["yes"][lan] }, scene.listenerReset)
        
        elseif event.target.id == "Language" and event.target.isWithinBounds then
            local languageNumber = 0
            local currentLanguage = AZ.userInfo.language
            local gameLanguages = AZ.localization.languages

            for i=1, #gameLanguages do
                if gameLanguages[i] == currentLanguage then
                    languageNumber = i +1

                    if languageNumber > #gameLanguages then
                        languageNumber = 1
                    end
                        
                    break
                end
            end
                
            scene.language = gameLanguages[languageNumber]
            AZ.userInfo.language = scene.language
            scene.genericInfo.language = scene.language
            ----FlurryController:logEvent("in_options", { type = "language", language = scene.language })
            scene.resetText()
            scene.isChange = true
        
        elseif event.target.id == "vibration" and event.target.isWithinBounds then
            AZ.utils.setVibration(event.target.iconImg.isVisible)
            AZ.utils.vibrate()
            
			event.target.iconImg.isVisible = scene.genericInfo.vibration == 1
			
            scene.genericInfo.vibration = getStateNumber(not event.target.iconImg.isVisible)
            scene.isChange = true
            
        elseif event.target.id == "sound" and event.target.isWithinBounds then
            AZ.audio.setFX(event.target.iconImg.isVisible)
            
			event.target.iconImg.isVisible = scene.genericInfo.sound == 1
            
            scene.genericInfo.sound = getStateNumber(not event.target.iconImg.isVisible)
            scene.isChange = true
        
        elseif event.target.id == "music" and event.target.isWithinBounds then
            AZ.audio.setBSO(event.target.iconImg.isVisible)
            
			event.target.iconImg.isVisible = scene.genericInfo.music == 1
            
            scene.genericInfo.music = getStateNumber(not event.target.iconImg.isVisible)
            scene.isChange = true
        
        end
    end
end

function scene.onBackTouch()
	scene.options.effect = "slideUp"
	AZ.S.gotoScene("menu.menu", scene.options)
end

scene.configure = function()
	
	scene.btnSound.iconImg.isVisible = not (scene.genericInfo.sound == 1)
	scene.btnMusic.iconImg.isVisible = not (scene.genericInfo.music == 1)
	scene.btnVibration.iconImg.isVisible = not (scene.genericInfo.vibration == 1)
end

function scene.createTouchButton(params)
	local btn = AZ.ui.newTouchButton({ id = params.id, x = params.x, y = params.y, touchSound = params.touchSound or AZ.soundLibrary.buttonSound, releaseSound = params.releaseSound, txtParams = params.txtParams, btnIndex = params.btnIndex, iconIndex = params.iconIndex, imageSheet = scene.imageSheet, onTouch = scene.onTouch })
	btn:setScale(SCALE_BIG*1.2, SCALE_BIG*1.2)
	return btn
end

scene.createGUI = function()
    local switchSound = AZ.soundLibrary.switchSound
    
    local scale = (SCALE_DEFAULT + SCALE_BIG) *0.5
    
    --arxiu de configuracio, parametre de l'arxiu, nom fons imatge ON, nom fons imatge OFF, 
    --text ON {text, font, size, color, X, Y}, 
    --nom text OFF {text, font, size, color, X, Y}, 
    --nom icona ON {name, X, Y}, nom icona OFF {name, X, Y}, 
    --so, X, Y, escalaX, escalaY, referencePoint
    
    local translate = AZ.utils.translate
    
    local txtX, txtY = 100 * SCALE_DEFAULT, 45 * SCALE_DEFAULT
    local myFontSize = (SMALL_FONT_SIZE + NORMAL_FONT_SIZE) *0.5
	
	scene.txtMusic = display.newText({text = translate("music"), x = display.contentWidth*0.2, y = display.contentHeight*0.23, font = BRUSH_SCRIPT, fontSize = 40*SCALE_DEFAULT})
	scene.txtMusic:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
	scene.btnMusic = scene.createTouchButton({id = "music", x = display.contentWidth*0.2, y = display.contentHeight*0.3, btnIndex = 4, iconIndex = 5})
    
	scene.txtSound = display.newText({text = translate("sound"), x = display.contentWidth*0.5, y = display.contentHeight*0.23, font = BRUSH_SCRIPT, fontSize = 40*SCALE_DEFAULT})
	scene.txtSound:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
	scene.btnSound = scene.createTouchButton({id = "sound", x = display.contentWidth*0.5, y = display.contentHeight*0.3, btnIndex = 6, iconIndex = 5})
    
	scene.txtVibration = display.newText({text = translate("vibration"), x = display.contentWidth*0.8, y = display.contentHeight*0.23, font = BRUSH_SCRIPT, fontSize = 40*SCALE_DEFAULT})
	scene.txtVibration:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
	scene.btnVibration = scene.createTouchButton({id = "vibration", x = display.contentWidth*0.8, y = display.contentHeight*0.3, btnIndex = 7, iconIndex = 5})
	
	scene.txtLanguage = display.newText({text = translate("lang"), x = display.contentCenterX, y = display.contentHeight*0.46, font = BRUSH_SCRIPT, fontSize = 40*SCALE_DEFAULT})
	scene.txtLanguage:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
	scene.btnLanguage = scene.createTouchButton({id = "Language", x = display.contentCenterX, y = display.contentHeight*0.53, btnIndex = 1, txtParams = { text = string.upper(translate("language")), font = INTERSTATE_BOLD, fontSize = 25, color = AZ_DARK_RGB, x = 0, y = -4 }})
	
    scene.btnReset = scene.createTouchButton({id = "Reset", x = display.contentCenterX, y = display.contentHeight*0.68, btnIndex = 2, txtParams = { text = string.upper(translate("reset")), font = INTERSTATE_BOLD, fontSize = 25, color = AZ_DARK_RGB, x = 0, y = -4 }})
	
    local grpOptionsGUI = display.newGroup()
    
	grpOptionsGUI:insert(scene.txtMusic)
    grpOptionsGUI:insert(scene.btnMusic)
	grpOptionsGUI:insert(scene.txtSound)
    grpOptionsGUI:insert(scene.btnSound)
	grpOptionsGUI:insert(scene.txtVibration)
    grpOptionsGUI:insert(scene.btnVibration)
	grpOptionsGUI:insert(scene.txtLanguage)
    grpOptionsGUI:insert(scene.btnLanguage)
    grpOptionsGUI:insert(scene.btnReset)
    
    return grpOptionsGUI
end

scene.createMenuButtons = function()
    -- Menu button
	scene.btnBack = scene.createTouchButton({id = "BackButton", x = display.contentCenterX, y = display.contentHeight*0.9208, btnIndex = 3, touchSound = AZ.soundLibrary.backBtnSound})
	
    return scene.btnBack
end

scene.createAll = function()
    scene.title = AZ.ui.createShadowText(AZ.utils.translate("OPTIONS"), display.contentCenterX, display.contentHeight * 0.08, 90 * SCALE_BIG)
    
    scene.group:insert(scene.title)
    scene.group:insert(scene.createGUI())
end

function scene:createScene( event )
    scene.group = self.view   
    
    ----FlurryController:logEvent("in_options", {})
	
	scene.infoSheet = require "options.assets.options"
	scene.imageSheet = graphics.newImageSheet("options/assets/options.png", scene.infoSheet:getSheet())
    
    scene.isChange = false
    
    scene.genericInfo = AZ.userInfo --AZ.jsonIO:readFile(FILE_USER_INFO,false)
    
    scene.localization = AZ.localization
    scene.language = AZ.userInfo.language
    
    scene.background = display.newImage(WIN_PATH)
    scene.background:scale(display.contentHeight/scene.background.height, display.contentHeight/scene.background.height)  
    scene.background.x = display.contentCenterX
    scene.background.y = display.contentCenterY
    
    scene.group:insert(scene.background)
    scene.group:insert(scene.createMenuButtons())
    
    scene.createAll()
    scene.configure()
end 

function scene:exitScene( event )
    if scene.isChange then
        --[[FlurryController:logEvent("in_options", {
            music_enabled       = scene.genericInfo.music,
            sound_enabled       = scene.genericInfo.sound, 
            vibration_enabled   = scene.genericInfo.vibration, 
            language            = scene.genericInfo.language })]]
		AZ.saveData()
    end
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener( "createScene", scene )
scene:addEventListener( "exitScene", scene )

return scene 
