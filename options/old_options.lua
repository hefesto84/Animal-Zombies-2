
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
    display.remove(scene.btnSound)
    display.remove(scene.btnMusic)
    display.remove(scene.btnVibration)
    display.remove(scene.btnReset)
    display.remove(scene.btnlanguage)
    
    scene.createAll()
    scene.configure()
end

scene.onTouch = function(event)
    if event.phase == "release" or event.phase == "began" then
        if(event.id == "BackButton") then
            AZ.S.gotoScene("menu.menu", scene.options)
        
        elseif event.id == "Reset" then
            local loc, lan = scene.localization, scene.language
            native.showAlert(loc["reset_progress"][lan], loc["reset_progress_sure"][lan], { loc["cancel"][lan], loc["yes"][lan] }, scene.listenerReset)
        
        elseif event.id == "Language" then
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
        
        elseif event.id == "vibration" then
            AZ.utils.setVibration(event.state == 1)
            AZ.utils.vibrate()
            AZ.audio.playFX(AZ.soundLibrary.switchSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
            
            scene.genericInfo.vibration = event.state
            scene.isChange = true
            
        elseif event.id == "sound" then
            AZ.audio.setFX(event.state == 1)
            AZ.audio.playFX(AZ.soundLibrary.switchSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
            
            scene.genericInfo.sound = event.state
            scene.isChange = true
        
        elseif event.id == "music" then
            AZ.audio.setBSO(event.state == 1)
            AZ.audio.playFX(AZ.soundLibrary.switchSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
            
            scene.genericInfo.music = event.state
            scene.isChange = true
        
        end
    end
end

function scene.onBackTouch()
	AZ.S.gotoScene("menu.menu", scene.options)
end

scene.configure = function()
    scene.btnSound.configure(scene.genericInfo.sound == 1)
    scene.btnMusic.configure(scene.genericInfo.music == 1)
    scene.btnVibration.configure(scene.genericInfo.vibration == 1)
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
    
    scene.btnMusic	= AZ.gui.guiElementSwitch(scene.genericInfo, "music", "options/assets/menuOptionsPauseLoading.png", "boton options", "boton options-push", 
    {text = translate("music"), font=INTERSTATE_BOLD, size = myFontSize, onColor = AZ_DARK_RGB, offColor = AZ_BRIGHT_RGB, X = txtX, Y = txtY},
    {name = "musica on", X = 40, Y = 40}, {name = "musica off", X = 40, Y = 40},
    switchSound, display.contentWidth * 0.5, display.contentHeight * 0.25, scale, scale, display.centerReferencePoint, scene.onTouch)
    
    scene.btnSound	= AZ.gui.guiElementSwitch(scene.genericInfo, "sound", "options/assets/menuOptionsPauseLoading.png", "boton options", "boton options-push",
    {text = translate("sound"), font=INTERSTATE_BOLD, size = myFontSize, onColor = AZ_DARK_RGB, offColor = AZ_BRIGHT_RGB, X = txtX, Y = txtY},
    {name = "sonido on", X = 40, Y = 40}, {name = "sonido off", X = 40, Y = 40},
    switchSound, display.contentWidth * 0.5, display.contentHeight * 0.37, scale, scale, display.CenterLeftReferencePoint, scene.onTouch)
    
    scene.btnVibration  = AZ.gui.guiElementSwitch(scene.genericInfo, "vibration", "options/assets/menuOptionsPauseLoading.png", "boton options", "boton options-push",
    {text = translate("vibration"), font=INTERSTATE_BOLD, size = myFontSize, onColor = AZ_DARK_RGB, offColor = AZ_BRIGHT_RGB, X = txtX, Y = txtY},
    {name = "vibracion on", X = 40, Y = 40}, {name = "vibracion off", X = 40, Y = 40},
    switchSound, display.contentWidth * 0.5, display.contentHeight * 0.49, scale, scale, display.CenterLeftReferencePoint, scene.onTouch)
  
    scene.btnLanguage   = AZ.ui.newEnhancedButton{
        sound = AZ.soundLibrary.buttonSound,
        unpressed = 37, --reset",
        x = display.contentWidth * 0.5,
        y = display.contentHeight * 0.61,
        pressed = 36, --"reset-push",
        onEvent = scene.onTouch,
        id = "Language",
        text1 = {text= translate("language"), fontName = INTERSTATE_BOLD, fontSize = myFontSize, X = 0, Y = 27, color = AZ_DARK_RGB, altColor = AZ_BRIGHT_RGB}
    }
    --afegir coses al boto
    scene.btnLanguage:scale(scale, scale)
    
    
    scene.btnReset      = AZ.ui.newEnhancedButton{
        sound = AZ.soundLibrary.buttonSound,
        unpressed = 37, --reset",
        x = display.contentWidth * 0.5,
        y = display.contentHeight * 0.73,
        pressed = 36, --"reset-push",
        onEvent = scene.onTouch,
        id = "Reset",
        text1 = {text= translate("reset"), fontName = INTERSTATE_BOLD, fontSize = myFontSize, X = 0, Y = 27, color = AZ_DARK_RGB, altColor = AZ_BRIGHT_RGB}
    }
    --afegir coses al boto
    scene.btnReset:scale(scale, scale)
    
    local grpOptionsGUI = display.newGroup()
    
    grpOptionsGUI:insert(scene.btnSound)
    grpOptionsGUI:insert(scene.btnMusic)
    grpOptionsGUI:insert(scene.btnVibration)
    grpOptionsGUI:insert(scene.btnLanguage)
    grpOptionsGUI:insert(scene.btnReset)
    
    return grpOptionsGUI
end

scene.createMenuButtons = function()
    -- Menu button
    scene.btnBack = AZ.ui.newEnhancedButton{
        sound = AZ.soundLibrary.buttonSound, --"assets/audio/button.mp3",
        --sheet = "assets/gui1.png",
        unpressed = 95, --76, --"back",
        x = display.contentCenterX,
        y = display.contentHeight -(120*SCALE_DEFAULT),
        pressed = 98, --75, --"back-push",
        onEvent = scene.onTouch,
        id = "BackButton"
    }
    scene.btnBack:scale(SCALE_DEFAULT,SCALE_DEFAULT)
    
    return scene.btnBack
end

scene.createAll = function()
    scene.title = AZ.ui.createShadowText(AZ.utils.translate("OPTIONS"), display.contentCenterX, display.contentHeight * 0.08, 80 * SCALE_DEFAULT)
    
    scene.group:insert(scene.title)
    scene.group:insert(scene.createGUI())
end

function scene:createScene( event )
    scene.group = self.view   
    
    ----FlurryController:logEvent("in_options", {})
    
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
