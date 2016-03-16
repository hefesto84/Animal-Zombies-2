
local easing = require "easing"

local scene = AZ.S.newScene()

scene.Popup = {}
scene.start_time = 0
local _R = SCALE_EXTRA_BIG
local _S = SCALE_DEFAULT
local _W = display.contentWidth
local _H = display.contentHeight
scene.anyWaiting = nil
scene.lifesCurrent = AZ.userInfo.lifesCurrent
scene.lifesToWin = nil
scene.lifesMax = AZ.userInfo.lifesMax
scene.secondsToEarn = nil
scene.heartsAnim = true
scene.hearts = {}
scene.heartsTimers = {}

local onClick = nil

scene.myImageSheet = nil
scene.Popup.background = nil
scene.Popup.btnClose = nil
scene.Popup.txtComptador = nil
scene.Popup.imgFacebook = nil
scene.Popup.txtFacebook = nil
scene.Popup.btnFacebook = nil
scene.Popup.imgLives = nil
scene.Popup.txtLives = nil
scene.Popup.btnLives = nil
scene.Popup.heartsGroup = nil


--- Funció encarregada de setejar les variables de la recàrrega de vides
local function setVariables()
    scene.lifesCurrent = AZ.userInfo.lifesCurrent
    scene.lifesMax = AZ.userInfo.lifesMax
    scene.anyWaiting, scene.lifesToWin, scene.secondsToEarn = AZ.recoveryController:getCurrentRecoveryStatus()
end

--- Funció que fa el fadeIn en la animació dels cors
function scene.fadeIn(heart)
    transition.to(heart, {time = 1000, alpha = 1, onComplete = scene.fadeOut})
end
--- Funció que fa el fadeOut en la animació dels cors
function scene.fadeOut(heart)
    transition.to(heart, { time=1000, alpha = 0, onComplete = scene.fadeIn })
end

--- Funció que prepara el display dels cors disponibles i els que es poden guanyar
function scene.prepareHearts()
    scene.Popup.heartsGroup = display.newGroup()
    
    for i = 1, scene.lifesMax do
        scene.hearts[i] = display.newGroup()
        if i <= scene.lifesCurrent then
            scene.hearts[i].life = display.newImage(scene.myImageSheet, 13)
        elseif i <= scene.lifesCurrent+scene.lifesToWin then
            scene.hearts[i].lifeBg = display.newImage(scene.myImageSheet, 11)
            scene.hearts[i].life = display.newImage(scene.myImageSheet, 13)
            scene.hearts[i].life.alpha = 1
            transition.to(scene.hearts[i].life, {time = 1000, alpha = 0, onComplete = scene.fadeIn})
        else
            scene.hearts[i].life = display.newImage(scene.myImageSheet, 10)
        end
        if scene.hearts[i].lifeBg ~= nil then
            scene.hearts[i]:insert(scene.hearts[i].lifeBg)
        end
		scene.hearts[i]:insert(scene.hearts[i].life)
		scene.hearts[i]:scale(_R,_R)
		scene.hearts[i].x = ((scene.Popup.btnLives.contentWidth*0.95)/scene.lifesMax)*i-1
        scene.Popup.heartsGroup:insert(scene.hearts[i])
        
    end
    
    scene.Popup.heartsGroup.anchorChildren = true
    scene.Popup.heartsGroup.anchorX = 0.5
    scene.Popup.heartsGroup.x = _W*0.5
    scene.Popup.heartsGroup.y = _H*0.5-25*_R
    
    return scene.Popup.heartsGroup
end

function scene.ressetHearts()
    for i = 1, scene.lifesMax do
        if scene.hearts[i].lifeBg ~= nil then
            display.remove(scene.hearts[i].lifeBg)
            scene.hearts[i].lifeBg = nil
            transition.cancel(scene.hearts[i].life)
        end
        display.remove(scene.hearts[i].life)
        scene.hearts[i].life = nil
    end
    
    scene.Popup:insert(scene.prepareHearts())
    
end

--- Preparem els botons per quan les vides actuals són inferiors a les vides màximes
function scene.prepareButtonsLifesToWin()
    
    local btnGroup = display.newGroup()
    
    -- Lives button
    scene.Popup.btnLives = AZ.ui.newEnhancedButton2{
        sound = AZ.soundLibrary.buttonSound,
        myImageSheet = scene.myImageSheet,
        unpressedIndex = 1,
        pressedIndex = 3,
        x = _W*0.5,
        y = _H*0.5+60*_R,
        onEvent = onClick,
        id = "btnLives"
    }
    scene.Popup.btnLives.isActive = true
    scene.Popup.btnLives:scale(_R,_R)
    btnGroup:insert(scene.Popup.btnLives)
    
    scene.Popup.btnLivesTextTop = display.newText({text = AZ.utils.translate("pp_btn_lifes_upper"), x = _W*0.5-60*_R, y = _H*0.5+45*_R, width = scene.Popup.btnLives.contentWidth*0.60, font = INTERSTATE_BOLD, fontSize = 30*_R, align = "center"})
    scene.Popup.btnLivesTextTop:setFillColor(AZ.utils.getColor(AZ_BLACK_RGB))
    btnGroup:insert(scene.Popup.btnLivesTextTop)
    scene.Popup.btnLivesTextBottom = display.newText({text = AZ.utils.translate("pp_btn_lifes_lower"), x = _W*0.5-60*_R, y = _H*0.5+75*_R, width = scene.Popup.btnLives.contentWidth*0.60, font = INTERSTATE_BOLD, fontSize = 30*_R, align = "center"})
    scene.Popup.btnLivesTextBottom:setFillColor(AZ.utils.getColor(AZ_BLACK_RGB))
    btnGroup:insert(scene.Popup.btnLivesTextBottom)
    scene.Popup.btnLivesText = display.newText(AZ.userInfo.recoveryStatus.refillHeartsPrice, _W*0.5+110*_R, _H*0.5+60*_R, INTERSTATE_BOLD, 45*_R)
    scene.Popup.btnLivesText:setFillColor(AZ.utils.getColor(AZ_BLACK_RGB))
    btnGroup:insert(scene.Popup.btnLivesText)
    
    -- Facebook button
    scene.Popup.btnFacebook = AZ.ui.newEnhancedButton2{
        sound = AZ.soundLibrary.buttonSound,
        myImageSheet = scene.myImageSheet,
        unpressedIndex = 5,
        pressedIndex = 7,
        x = _W*0.5,
        y = _H*0.5+200*_R,
        onEvent = onClick,
        id = "btnFacebook"
    }
    scene.Popup.btnFacebook.isActive = true
    scene.Popup.btnFacebook:scale(_R,_R)
    btnGroup:insert(scene.Popup.btnFacebook)
    
    scene.Popup.btnFacebookText = display.newText(AZ.utils.translate("pp_btn_lifes_fb"), _W*0.5-10*_R, _H*0.5+200*_R, INTERSTATE_BOLD, 30*_R)
    scene.Popup.btnFacebookText:setFillColor(AZ.utils.getColor(AZ_BLACK_RGB))
    btnGroup:insert(scene.Popup.btnFacebookText)
    scene.Popup.btnFacebookTextQtt = display.newText("+1", _W*0.5+125*_R, _H*0.5+200*_R, INTERSTATE_BOLD, 30*_R)
    scene.Popup.btnFacebookTextQtt:setFillColor(AZ.utils.getColor(AZ_BLACK_RGB))
    btnGroup:insert(scene.Popup.btnFacebookTextQtt)
    
    return btnGroup
end

--- Preparem els botons quan les vides actuals són iguals a les vides màximes
function scene.prepareButtonsLifesMax()
    
    local btnGroup = display.newGroup()
    
    -- Lives button
    scene.Popup.btnLives = AZ.ui.newEnhancedButton2{
        sound = AZ.soundLibrary.buttonSound,
        myImageSheet = scene.myImageSheet,
        unpressedIndex = 2,
        pressedIndex = 4,
        x = _W*0.5,
        y = _H*0.5+60*_R,
        onEvent = onClick,
        id = "btnLives"
    }
    scene.Popup.btnLives.isActive = false
    scene.Popup.btnLives:scale(_R,_R)
    btnGroup:insert(scene.Popup.btnLives)
    
    scene.Popup.btnLivesTextTop = display.newText({text = "RECÀRREGA", x = _W*0.5-60*_R, y = _H*0.5+45*_R, width = scene.Popup.btnLives.contentWidth*0.60, font = INTERSTATE_BOLD, fontSize = 30*_R, align = "center"})
    scene.Popup.btnLivesTextTop:setFillColor(AZ.utils.getColor(AZ_BLACK_RGB))
    scene.Popup.btnLivesTextTop.alpha = 0.5
    btnGroup:insert(scene.Popup.btnLivesTextTop)
    scene.Popup.btnLivesTextBottom = display.newText({text = "COMPLETA", x = _W*0.5-60*_R, y = _H*0.5+75*_R, width = scene.Popup.btnLives.contentWidth*0.60, font = INTERSTATE_BOLD, fontSize = 30*_R, align = "center"})
    scene.Popup.btnLivesTextBottom:setFillColor(AZ.utils.getColor(AZ_BLACK_RGB))
    scene.Popup.btnLivesTextBottom.alpha = 0.5
    btnGroup:insert(scene.Popup.btnLivesTextBottom)
    scene.Popup.btnLivesText = display.newText("1.50€", _W*0.5+110*_R, _H*0.5+60*_R, INTERSTATE_BOLD, 45*_R)
    scene.Popup.btnLivesText:setFillColor(AZ.utils.getColor(AZ_BLACK_RGB))
    scene.Popup.btnLivesText.alpha = 0.5
    btnGroup:insert(scene.Popup.btnLivesText)
    
    -- Facebook button
    scene.Popup.btnFacebook = AZ.ui.newEnhancedButton2{
        sound = AZ.soundLibrary.buttonSound,
        myImageSheet = scene.myImageSheet,
        unpressedIndex = 6,
        pressedIndex = 8,
        x = _W*0.5,
        y = _H*0.5+200*_R,
        onEvent = onClick,
        id = "btnFacebook"
    }
    scene.Popup.btnFacebook.isActive = false
    scene.Popup.btnFacebook:scale(_R,_R)
    btnGroup:insert(scene.Popup.btnFacebook)
    
    scene.Popup.btnFacebookText = display.newText("COMPARTEIX", _W*0.5+10*_R, _H*0.5+200*_R, INTERSTATE_BOLD, 30*_R)
    scene.Popup.btnFacebookText:setFillColor(AZ.utils.getColor(AZ_BLACK_RGB))
    scene.Popup.btnFacebookText.alpha = 0.5
    btnGroup:insert(scene.Popup.btnFacebookText)
    
    return btnGroup
end

--- Funció per esborrar de pantalla els botons de comprar vides i de compartir al facebook
function scene.removeButtons()
    display.remove(scene.Popup.btnFacebook)
    scene.Popup.btnFacebook = nil
    display.remove(scene.Popup.btnFacebookText)
    scene.Popup.btnFacebookText = nil
    if scene.Popup.btnFacebookTextQtt ~= nil then
        display.remove(scene.Popup.btnFacebookTextQtt)
        scene.Popup.btnFacebookTextQtt = nil
    end
    display.remove(scene.Popup.btnLives)
    scene.Popup.btnLives = nil
    display.remove(scene.Popup.btnLivesText)
    scene.Popup.btnLivesText = nil
    display.remove(scene.Popup.btnLivesTextTop)
    scene.Popup.btnLivesTextTop = nil
    display.remove(scene.Popup.btnLivesTextBottom)
    scene.Popup.btnLivesTextBottom = nil
end

--- Funció per formatejar el text del comptador
-- Aquesta funció retorna el temps en segons i milisegons
-- amb el format adequat per el rellotge del compte enrere
local function returnTimeFormat(tTime)
    local minutes = math.floor((scene.secondsToEarn - tTime) / 60)
    local seconds = math.floor ((scene.secondsToEarn - tTime) % 60)
    if minutes < 10 then
		minutes = "0"..tostring(minutes)
    end
    if seconds < 10 then
        seconds = "0"..tostring(seconds)
    end
    return minutes,seconds
end

--- Funció update per decrementar el temps del rellotge
-- Aquesta funció decrementa el temps del rellotge amb 
-- el temps que ha passat 
function scene.update()
    local diffTime = os.time(os.date( '*t' )) - scene.start_time
    if diffTime <= scene.secondsToEarn then
        -- Encara no s'ha acabat el compte enrere, seguim
        local minutes, seconds = returnTimeFormat(diffTime)
        scene.Popup.txtMinuts.text = minutes
        scene.Popup.txtSegons.text = seconds
        scene.Popup.txtMinuts.alpha = 1
        scene.Popup.txtComptador.alpha = 1
        scene.Popup.txtSegons.alpha = 1
    else
        -- S'ha acabat el compte enrere, posem elcomptador en vermell
        -- i parem l'update
        Runtime:removeEventListener("enterFrame", scene.update)
        scene.Popup.txtMinuts.text = "00"
        scene.Popup.txtSegons.text = "00"
        scene.Popup.txtMinuts.alpha = 0.5
        scene.Popup.txtComptador.alpha = 0.5
        scene.Popup.txtSegons.alpha = 0.5
        setVariables()
        scene.prepareCountdown(false)
        scene.ressetHearts()
    end
end

--- Funció per preparar el compte enrere
-- Aquesta funció serveix per preparar el tems inicial del compte enrere
-- i registrar l'event update
function scene.prepareCountdown(isFirstTime)
    if scene.anyWaiting then
        scene.Popup.txtMinuts.alpha = 1
        scene.Popup.txtComptador.alpha = 1
        scene.Popup.txtSegons.alpha = 1
        scene.start_time = os.time(os.date( '*t' ))
		local minutes, seconds = returnTimeFormat(0)
        scene.Popup.txtMinuts.text = minutes--math.floor(scene.secondsToEarn / 60)
        scene.Popup.txtSegons.text = seconds--math.floor(scene.secondsToEarn % 60)
        if not isFirstTime then
            Runtime:addEventListener("enterFrame", scene.update)
        end
	else
        scene.Popup.txtMinuts.text = "00"
        scene.Popup.txtSegons.text = "00"
        scene.Popup.txtMinuts.alpha = 0.5
        scene.Popup.txtComptador.alpha = 0.5
        scene.Popup.txtSegons.alpha = 0.5
    end
end


--- Definició de l'event onClick
-- Aquest event s'executarà sempre que hi hagi una acció touch en un
-- dels elements del popup 
-- @param event conté la informació de l'event touch
function onClick(event)
    
    local id = nil
    if event.target == nil then
        id = event.id
    else
        id = event.target.id
    end
    
    if event.phase == "ended" or event.phase == "release" then
        if event.isBackKey or (id == "btnClose" and event.target.isWithinBounds) then
            Runtime:removeEventListener("enterFrame", scene.update)
            AZ.S.hideOverlay("crossFade", 500)
        elseif id == "btnFacebook" then
			local function fbCallback(posted)
				
				if posted then
					AZ.audio.playFX(AZ.soundLibrary.shareForLifeSound, AZ.audio.AUDIO_VOLUME_OTHER_FX)
					Runtime:removeEventListener("enterFrame", scene.update)
					scene.lifesCurrent = math.min((scene.lifesCurrent + 1), scene.lifesMax)
					AZ.userInfo.lifesCurrent = scene.lifesCurrent
					AZ:saveData()
					if scene.lifesCurrent == scene.lifesMax then
						scene.removeButtons()
						scene.Popup:insert(scene.prepareButtonsLifesMax())
					end
					setVariables()
					scene.ressetHearts()
					scene.prepareCountdown(false)
				end
			end
			
			fbCallback(true)
			--AZ.fb:postMessage(fbCallback)
			
        elseif id == "btnLives" then
            
            local function callback(success, transaction)
                if success then
                   Runtime:removeEventListener("enterFrame", scene.update)
                   scene.lifesCurrent =  scene.lifesMax
                   AZ.userInfo.lifesCurrent = scene.lifesCurrent
                   AZ:saveData()
                   if scene.lifesCurrent == scene.lifesMax then
                       scene.removeButtons()
                       scene.Popup:insert(scene.prepareButtonsLifesMax())
                   end
                   setVariables()
                   scene.ressetHearts()
					scene.prepareCountdown(false)
					AZ.audio.playFX(AZ.soundsLibrary.payFullLifesSound, AZ.audio.AUDIO_VOLUME_OTHER_FX)
                end
                
				AZ.loader:showHide(false, 100)
            end
            
			AZ.loader:showHide(true, 100)
			
            AZ.Gamedonia:buyProduct({ AZ.userInfo.recoveryStatus.refillHeartsStoreID }, callback, true)
        end
    end
end

function scene.onBackTouch()
	onClick({ phase = "ended", isBackKey = true })
end

function scene.onBgTouch(event)
	if event.phase == "ended" then
		
		if not AZ.utils.isPointInRect(event.x, event.y, scene.Popup.background.contentBounds) and
			not AZ.utils.isPointInRect(event.xStart, event.yStart, scene.Popup.background.contentBounds) then
			scene.onBackTouch()
		end
	end
end

local function createBtn(params)--(id, x, y, btnIndex, txtParams)
	local btn = AZ.ui.newTouchButton({ id = params.id, x = params.x, y = params.y, touchSound = params.touchSound or AZ.soundLibrary.buttonSound, releaseSound = params.releaseSound, txtParams = params.txtParams, btnIndex = params.btnIndex,  imageSheet = scene.myImageSheet, onTouch = onClick })
	btn:setScale(SCALE_BIG*1.2, SCALE_BIG*1.2)
	scene.Popup:insert(btn)
	return btn
end

--- Definició de la funció init
-- Aquesta funció carrega tots el elements gràfics del popup i els insereix a
-- el view de l'escena
function scene:init()
    scene.Popup = display.newGroup()
        
    setVariables()
    
    local sheetInfo = require "popups.assets.popups-life"
    scene.myImageSheet = graphics.newImageSheet("popups/assets/popups-life.png",sheetInfo:getSheet())
    
    scene.Popup.translucidBg = display.newRect(0, 0, _W+200*_R, _H)
    scene.Popup.translucidBg.x, scene.Popup.translucidBg.y = _W*0.5, _H*0.5
    scene.Popup.translucidBg:setFillColor({0,0,0,0.5})
    scene.Popup.translucidBg.alpha = 0.5
    scene.Popup.translucidBg:addEventListener("touch", scene.onBgTouch)
	scene.view:insert(scene.Popup.translucidBg)
    
    scene.view:insert(scene.Popup)
    
    -- Creem el background del popup
    scene.Popup.background = display.newImage("popups/assets/popup_life_empty.png")--, 512, 683)
	scene.Popup.background:scale(_R, _R)
	scene.Popup.background.x, scene.Popup.background.y = _W*0.5, _H*0.5
	scene.Popup:insert(scene.Popup.background)
	
    -- Creem el botó de tancar
	scene.btnClose = createBtn({id = "btnClose", x = _W*0.5 + 165*_R, y = _H*0.5 - 240*_R, btnIndex = sheetInfo:getFrameIndex("cerrar"), touchSound = AZ.soundLibrary.closePopupSound})
    
    -- Títol del popup
    scene.Popup.txtPopupTitle = display.newText(
        AZ.utils.translate("pp_next_recharge"),
        _W*0.5,
        _H*0.5 - 190*_R,
        INTERSTATE_BOLD,
        35*_R
    )
    scene.Popup.txtPopupTitle:setFillColor(AZ.utils.getColor(AZ_BLACK_RGB))
    scene.Popup:insert(scene.Popup.txtPopupTitle)
    
    -- Preparem el label del compte enrere
    scene.Popup.txtMinuts = display.newText({
        text = "00",
        x = _W*0.5-75*_R,
        y = _H*0.5-130*_R,
        font = INTERSTATE_BOLD,
        fontSize = 60*_R,
        align = "center"
    })
    scene.Popup.txtMinuts:setFillColor(AZ.utils.getColor(AZ_BLACK_RGB))
    scene.Popup.txtMinuts.anchorX = 0
    scene.Popup:insert(scene.Popup.txtMinuts)
    
    scene.Popup.txtComptador = display.newText({
        text = ":", 
        x = _W*0.5, 
        y = _H*0.5 - 130*_R, 
        font = INTERSTATE_BOLD, 
        fontSize = 60 * _R,
        align = "center"
    })
    scene.Popup.txtComptador:setFillColor(AZ.utils.getColor(AZ_BLACK_RGB))
    scene.Popup:insert(scene.Popup.txtComptador)
    
    scene.Popup.txtSegons = display.newText({
        text = "00",
        x = _W*0.5+10*_R,
        y = _H*0.5-130*_R,
        font = INTERSTATE_BOLD,
        fontSize = 60*_R,
        align = "center"
    })
    scene.Popup.txtSegons:setFillColor(AZ.utils.getColor(AZ_BLACK_RGB))
    scene.Popup.txtSegons.anchorX = 0
    scene.Popup:insert(scene.Popup.txtSegons)
    
    if not scene.anyWaiting then
        scene.Popup.txtMinuts.alpha = 1
        scene.Popup.txtComptador.alpha = 1
        scene.Popup.txtSegons.alpha = 1
    end
    
    -- Inserim els botons de comprar vides i compartir al Facebook
	if scene.lifesCurrent ~= scene.lifesMax and not scene.anyWaiting then
		scene.Popup:insert(scene.prepareButtonsLifesToWin())
    elseif not scene.anyWaiting then
        scene.Popup:insert(scene.prepareButtonsLifesMax())
	else
        scene.Popup:insert(scene.prepareButtonsLifesToWin())
    end
	
    -- Inserim el marcador de cors
    scene.Popup:insert(scene.prepareHearts())
    
end

--- Creem l'escene i guardem el paràmetres passats per utilitzar-los més endavant
function scene:createScene(event)
    scene:init()
    scene.params = event.params
    transition.from(scene.Popup, {time = 1000, alpha = 0, x = _W*0.5, y = _H*0.5, xScale = 0.001, yScale = 0.001, transition = easing.outElastic})
    scene.prepareCountdown(true)
end

function scene:enterScene(event)
    Runtime:addEventListener("enterFrame", scene.update)
end

function scene:exitScene(event)
    Runtime:removeEventListener("enterFrame", scene.update)
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener( "createScene", scene )
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)

return scene