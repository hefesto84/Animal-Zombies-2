
local easing = require "easing"

local scene = AZ.S.newScene()

scene.Popup = {}
scene.COUNTDOWN_TIME = 10
scene.start_time = 0
local _R = SCALE_BIG
local _W = display.contentWidth
local _H = display.contentHeight

scene.myImageSheet = nil
scene.Popup.background = nil
scene.Popup.btnClose = nil
scene.Popup.txtComptador = nil
scene.Popup.btnSlotmachine = nil
scene.Popup.btnLollipops = nil

--- Funció per formatejar el text del comptador
-- Aquesta funció retorna el temps en segons i milisegons
-- amb el format adequat per el rellotge del compte enrere
local function returnTimeFormat(tTime)
    local seconds = math.floor(scene.COUNTDOWN_TIME - tTime / 1000)
    local miliseconds = math.floor (((scene.COUNTDOWN_TIME*1000 - tTime) / 10) % 100)
    if seconds < 10 then
        seconds = "0" .. seconds
    end
    if miliseconds < 10 then
        miliseconds = "0" .. miliseconds
    end
    return seconds,miliseconds
end

--- Funció update per decrementar el temps del rellotge
-- Aquesta funció decrementa el temps del rellotge amb 
-- el temps que ha passat 
local function update()
    local diffTime = system.getTimer() - scene.start_time
    if diffTime <= scene.COUNTDOWN_TIME * 1000 then
        -- Encara no s'ha acabat el compte enrere, seguim
        local ts, tms = returnTimeFormat(diffTime)
        scene.Popup.txtComptador.text = ts..":"..tms
    else
        -- S'ha acabat el compte enrere, posem elcomptador en vermell
        -- i parem l'update
        Runtime:removeEventListener("enterFrame", update)
        scene.Popup.txtComptador.text = "00:00"
        scene.Popup.txtComptador:setFillColor(1,0.2,0.2)
        
        local fadeTime = 400
        timer.performWithDelay(fadeTime, function() Runtime:dispatchEvent({ name = GAMEPLAY_PAUSE_EVNAME, isPause = false, pauseType = "refillLollipops", success = false }) end)

        AZ.S.hideOverlay("crossFade", fadeTime)
    end
end

--- Funció per preparar el compte enrere
-- Aquesta funció serveix per preparar el tems inicial del compte enrere
-- i registrar l'event update
local function prepareCountdown()
    if scene.params and scene.params.clickTime and scene.params.start_time then
        scene.start_time = scene.params.start_time + (system.getTimer() - scene.params.clickTime)
        local diffTime = system.getTimer() - scene.start_time
        if diffTime <= scene.COUNTDOWN_TIME * 1000 then
            -- Encara no s'ha acabat el compte enrere, seguim
            local ts, tms = returnTimeFormat(diffTime)
            scene.Popup.txtComptador.text = ts..":"..tms
        end
    else
        scene.start_time = system.getTimer()
        scene.Popup.txtComptador.text = "0"..scene.COUNTDOWN_TIME..":00"
    end
    Runtime:addEventListener("enterFrame", update)
end

--- Definició de l'event onClick
-- Aquest event s'executarà sempre que hi hagi una acció touch en un
-- dels elements del popup 
-- @param event conté la informació de l'event touch
local function onClick(event)
    
    local id = nil
    if event.target == nil then
        id = event.id
    else
        id = event.target.id
    end
    
    if event.phase == "ended" or event.phase == "release" then
        local options = {
            effect = SCENE_TRANSITION_EFFECT,
            time = SCENE_TRANSITION_TIME,
            params = scene.params,
            isModal = true
        }
        if event.isBackKey or (id == "btnClose" and event.target.isWithinBounds) then
            Runtime:removeEventListener("enterFrame", update)
            local fadeTime = 400
            timer.performWithDelay(fadeTime, function() Runtime:dispatchEvent({ name = GAMEPLAY_PAUSE_EVNAME, isPause = false, pauseType = "refillLollipops", success = false }) end)
            
            AZ.S.hideOverlay("crossFade", fadeTime)
        elseif id == "slotmachine" then
            Runtime:removeEventListener("enterFrame", update)
            options.params.isLollipop = true
            options.params.clickTime = system.getTimer()
            options.params.start_time = scene.start_time
            if AZ.userInfo.money >= 10 then
                AZ.S.showOverlay("slotmachine.slotmachine", options)
            else
                AZ.S.showOverlay("popups.popupmoneygameplay", options)
            end
        elseif id == "lollipops" then
			local diffTime = system.getTimer() - scene.start_time
			if diffTime <= scene.COUNTDOWN_TIME * 1000 then
			
				local function callback(success, transaction)
					if success then
						Runtime:removeEventListener("enterFrame", update)
						local fadeTime = 400
						timer.performWithDelay(fadeTime, function() Runtime:dispatchEvent({ name = GAMEPLAY_PAUSE_EVNAME, isPause = false, pauseType = "refillLollipops", success = true }) end)
						
						AZ.S.hideOverlay("crossFade", fadeTime)
					else
						prepareCountdown()
					end
					
					AZ.loader:showHide(false, 100)
				end
				
				AZ.loader:showHide(true, 100)
				Runtime:removeEventListener("enterFrame", update)
				if not scene.params then
					scene.params = {}
				end
				scene.params.clickTime = system.getTimer()
				scene.params.start_time = scene.start_time
			
			
				if system.getInfo("environment") == "simulator" then
					timer.performWithDelay(4000, function() callback(false, {}) end)
				else
					AZ.Gamedonia:buyProduct(AZ.userInfo.recoveryStatus.refillLollipopsStoreID, callback, true)
				end
			else
				return true
			end
        end
    end
end

function scene.onBackTouch()
	onClick({ phase = "ended", isBackKey = true })
end

--- Funció que retorna el delta time per la rotació dels objectes
local function getDeltaTime(deltaTime)
    local temp = system.getTimer() --Get current game time in ms
    local dt = (temp-deltaTime) *0.001
    deltaTime = temp --Store game time
    return dt, deltaTime
end

local function createStar(rotation, isRandom, isLeft, sheetInfo)
	local star = {}
	star = display.newGroup()
	local deltaTime = 0
	
	star.big = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("brillo"))
	star.big:scale(_R, _R)
	star.big.xScale, star.big.yScale = 0.001, 0.001
	star.big.alpha = 0
	star:insert(star.big)
	star.little = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("brillo_pq"))
	star.little:scale(_R, _R)
	star.little.xScale, star.little.yScale = 0.001, 0.001
	star.little.alpha = 0
	star:insert(star.little)
	
	function star.doubleRotate()
		local rotation1 = nil
		local rotation2 = nil
		rotation1, deltaTime = getDeltaTime(deltaTime)
		rotation1, rotation2 = rotation1*rotation, rotation1*-rotation
		star.big:rotate(rotation2)
		star.little:rotate(rotation1)
	end
	
	function star.bigLittleAnim()
		if isRandom then
			local scale = math.random(5, 7)*0.1
			local tm = math.random(400, 600)
			local function changePosition()
				local x, y, delay = nil
				if isLeft then
					delay = math.random(50, 100)
					if math.round(math.random()) == 0 then
						x = _W*0.5-(math.random(60, 150))*_R
						y = _H*0.5+(math.random(0, 20))*_R
					else
						x = _W*0.5-(math.random(60, 150))*_R
						y = _H*0.5-(math.random(0, 160))*_R
					end
				else
					delay = math.random(25, 75)
					if math.round(math.random()) == 0 then
						x = _W*0.5+(math.random(60, 150))*_R
						y = _H*0.5+(math.random(0, 20))*_R
					else
						x = _W*0.5+(math.random(60, 150))*_R
						y = _H*0.5-(math.random(0, 160))*_R
					end
				end
				transition.to(star.big, {delay = delay, time = 0, x = x, y = y, onComplete = star.bigLittleAnim})
				transition.to(star.little, {delay = delay, time = 0, x = x, y = y})
			end
			local function littleAnim()
				transition.to(star.big, {time = tm, xScale = 0.001, yScale = 0.001, alpha = 0, transition = easing.outQuad, onComplete = changePosition})
				transition.to(star.little, {time = tm, xScale = 0.001, yScale = 0.001, alpha = 0, transition = easing.outQuad})
			end
			transition.to(star.big, {time = tm, xScale = _R*(scale-0.4), yScale = _R*(scale-0.4), alpha = 1, transition = easing.outQuad, onComplete = littleAnim})
			transition.to(star.little, {time = tm, xScale = _R*scale, yScale = _R*scale, alpha = 1, transition = easing.outQuad})
		elseif rotation == 80 then
			local function littleAnim()
				transition.to(star.little, {time = 400, xScale = 0.001, yScale = 0.001, alpha = 0, transition = easing.outQuad, onComplete = star.bigLittleAnim})
				transition.to(star.big, {time = 400, xScale = 0.001, yScale = 0.001, alpha = 0, transition = easing.outQuad})
			end
			transition.to(star.little, {delay = 800, time = 400, xScale = _R*0.3, yScale = _R*0.3, alpha = 1, transition = easing.outQuad, onComplete = littleAnim})
			transition.to(star.big, {delay = 800, time = 400, xScale = _R*0.1, yScale = _R*0.1, alpha = 1, transition = easing.outQuad})
		elseif rotation == 40 and not isRandom then
			local function bigAnim()
				transition.to(star.big, {time = 800, xScale = _R, yScale = _R, transition = easing.outQuad, onComplete = star.bigLittleAnim})
			end
			star.big.alpha = 1
			star.little.alpha = 1
			star.little.xScale, star.little.yScale = _R*1.8, _R*1.8
			transition.to(star.big, {time = 800, xScale = _R*0.5, yScale = _R*0.5, transition = easing.outQuad, onComplete = bigAnim})
		end
	end
	
	function star.setPosition(x, y)
		star.big.x, star.big.y, star.little.x, star.little.y = x, y, x, y
	end
	
	return star
end

local function noTouch(event)
	return true
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
function scene.init()
    scene.Popup = display.newGroup()
    
    local sheetInfo = require "popups.assets.popups_sprite0"
    scene.myImageSheet = graphics.newImageSheet("popups/assets/popups_sprite0.png",sheetInfo:getSheet())
    
    scene.Popup.translucidBg = display.newRect(0, 0, _W+200*_R, _H)
    scene.Popup.translucidBg.x, scene.Popup.translucidBg.y = _W*0.5, _H*0.5
    scene.Popup.translucidBg:setFillColor({0,0,0,0.5})
    scene.Popup.translucidBg.alpha = 0.5
	scene.Popup.translucidBg.id = "btnClose"
	scene.Popup.translucidBg:addEventListener("touch", onClick)
	scene.Popup.translucidBg.isWithinBounds = true
    scene.view:insert(scene.Popup.translucidBg)
    
    scene.view:insert(scene.Popup)
    
	-- Creem el background del contador del popup
	scene.Popup.backgroundMarcador = display.newImage("popups/assets/contador.png")
    scene.Popup.backgroundMarcador:scale(_R,_R)
    scene.Popup.backgroundMarcador.x, scene.Popup.backgroundMarcador.y = _W*0.5, _H*0.5-265*_R
	scene.Popup.backgroundMarcador:addEventListener("touch", noTouch)
    scene.Popup:insert(scene.Popup.backgroundMarcador)
	
    -- Creem el background del popup
    scene.Popup.background = display.newImage("popups/assets/popup_refill_lollipops.png")
    scene.Popup.background:scale(_R,_R)
    scene.Popup.background.x, scene.Popup.background.y = _W*0.5, _H*0.5+35*_R
	scene.Popup.background:addEventListener("touch", noTouch)
    scene.Popup:insert(scene.Popup.background)
    
    -- Creem el botó de tancar, que ens portarà al lose
	scene.Popup.btnClose = createBtn({id = "btnClose", x = _W*0.5+165*_R, y = _H*0.5-200*_R, btnIndex = sheetInfo:getFrameIndex("cerrar"), touchSound = AZ.soundLibrary.closePopupSound})
    
    -- Preparem el label del compte enrere
    scene.Popup.txtComptador = display.newText(
        "05:00", 
        _W*0.5 - 50*_R, 
        _H*0.5 - 255*_R, 
        INTERSTATE_BOLD, 
        40 * _R
    )
    scene.Popup.txtComptador.anchorX = 0
    scene.Popup.txtComptador.align = "left"
    scene.Popup.txtComptador:setFillColor(AZ.utils.getColor(FONT_WHITE_COLOR))
    scene.Popup:insert(scene.Popup.txtComptador)
    
    -- Títol del popup
    scene.Popup.title = display.newText(AZ.utils.translate("pp_keep_playing"), _W*0.5, _H*0.5-200*_R, INTERSTATE_BOLD, 40)
    scene.Popup.title:scale(_R,_R)
    scene.Popup.title:setFillColor(AZ.utils.getColor(FONT_BLACK_COLOR))
    scene.Popup:insert(scene.Popup.title)
    
    -- Lollipops button
    scene.Popup.btnLollipops = AZ.ui.newEnhancedButton2{
        sound = AZ.soundLibrary.buttonSound,
        myImageSheet = scene.myImageSheet,
        unpressedIndex = sheetInfo:getFrameIndex("boton_blue"),
        pressedIndex = sheetInfo:getFrameIndex("boton_blue_press"),
        x = _W*0.5,
        y = _H*0.5+60*_R,
        onEvent = onClick,
        id = "lollipops"
    }
    scene.Popup.btnLollipops:scale(_R,_R)
    scene.Popup:insert(scene.Popup.btnLollipops)
    
    scene.Popup.btnLollipopsText = display.newText({text = AZ.utils.translate("pp_refill_lollipops"), x = _W*0.5-60*_R, y = _H*0.5+65*_R, width = 200*_R, height = 80*_R, font = INTERSTATE_BOLD, fontSize = 30*_R, align = "center"})
    scene.Popup.btnLollipopsText:setFillColor(AZ.utils.getColor(FONT_BLACK_COLOR))
    scene.Popup:insert(scene.Popup.btnLollipopsText)
    
    scene.Popup.btnLollipopsTextMoney = display.newText(AZ.userInfo.recoveryStatus.refillLollipopsPrice, _W*0.5+110*_R, _H*0.5+60*_R, INTERSTATE_BOLD, NORMAL_FONT_SIZE*_R)
    scene.Popup.btnLollipopsTextMoney:setFillColor(AZ.utils.getColor(FONT_BLACK_COLOR))
    scene.Popup:insert(scene.Popup.btnLollipopsTextMoney)
    
    scene.Popup.btnLollipopsBar = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("linea_separacion_boton"))
    scene.Popup.btnLollipopsBar:scale(_R, _R)
    scene.Popup.btnLollipopsBar.x, scene.Popup.btnLollipopsBar.y = _W*0.5+40*_R, _H*0.5+60*_R
    scene.Popup:insert(scene.Popup.btnLollipopsBar)
    
    -- Lollipops image
    scene.Popup.imgLolipop = display.newGroup()
    scene.Popup.lollipopBg = createStar(40, false, false, sheetInfo)
	scene.Popup.lollipopBg.setPosition(_W*0.5, _H*0.5-60*_R)
	scene.Popup.lollipopBg.bigLittleAnim()
	Runtime:addEventListener("enterFrame", scene.Popup.lollipopBg.doubleRotate)
    scene.Popup.imgLolipop:insert(scene.Popup.lollipopBg)
    scene.Popup.lollipopImg = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("lollipop_XL"))
    scene.Popup.lollipopImg:scale(_R, _R)
    scene.Popup.lollipopImg.x, scene.Popup.lollipopImg.y = _W*0.5, _H*0.5-60*_R
    scene.Popup.imgLolipop:insert(scene.Popup.lollipopImg)
    scene.Popup:insert(scene.Popup.imgLolipop)
    
    -- Slotmachine button
	scene.Popup.slotButtonGrp = display.newGroup()
    scene.Popup.btnSlotmachine = AZ.ui.newEnhancedButton2{
        sound = AZ.soundLibrary.buttonSound,
        myImageSheet = scene.myImageSheet,
        unpressedIndex = sheetInfo:getFrameIndex("boton"),
        pressedIndex = sheetInfo:getFrameIndex("boton_press"),
        x = _W*0.5,
        y = _H*0.5+250*_R,
        onEvent = onClick,
        id = "slotmachine"
    }
    scene.Popup.btnSlotmachine:scale(_R,_R)
    scene.Popup.slotButtonGrp:insert(scene.Popup.btnSlotmachine)
    
    scene.Popup.btnSlotmachineTextUpper = display.newText(AZ.utils.translate("pp_slot_refill_upper"), _W*0.5-60*_R, _H*0.5+230*_R, INTERSTATE_BOLD, 25*_R)
    scene.Popup.btnSlotmachineTextUpper:setFillColor(AZ.utils.getColor(FONT_BLACK_COLOR))
    scene.Popup.slotButtonGrp:insert(scene.Popup.btnSlotmachineTextUpper)
    
    scene.Popup.btnSlotmachineTextLower = display.newText(AZ.utils.translate("pp_slot_refill_lower"), _W*0.5-60*_R, _H*0.5+265*_R, INTERSTATE_BOLD, 30*_R)
    scene.Popup.btnSlotmachineTextLower:setFillColor(AZ.utils.getColor(FONT_BLACK_COLOR))
    scene.Popup.slotButtonGrp:insert(scene.Popup.btnSlotmachineTextLower)
    
    scene.Popup.btnSlotmachineTextMoney = display.newText("10", _W*0.5+75*_R, _H*0.5+250*_R, INTERSTATE_BOLD, NORMAL_FONT_SIZE*_R)
    scene.Popup.btnSlotmachineTextMoney:setFillColor(AZ.utils.getColor(FONT_BLACK_COLOR))
    scene.Popup.slotButtonGrp:insert(scene.Popup.btnSlotmachineTextMoney)
    
    scene.Popup.coin = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("coin_XL"))
    scene.Popup.coin:scale(_R*0.6,_R*0.6)
    scene.Popup.coin.x, scene.Popup.coin.y = _W*0.5+130*_R, _H*0.5+250*_R
    scene.Popup.slotButtonGrp:insert(scene.Popup.coin)
    
    scene.Popup.btnSlotmachineBar = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("linea_separacion_boton"))
    scene.Popup.btnSlotmachineBar:scale(_R, _R)
    scene.Popup.btnSlotmachineBar.x, scene.Popup.btnSlotmachineBar.y = _W*0.5+40*_R, _H*0.5+250*_R
    scene.Popup.slotButtonGrp:insert(scene.Popup.btnSlotmachineBar)
	
	scene.Popup:insert(scene.Popup.slotButtonGrp)
	
	if scene.params.slotPlayed then
		scene.Popup.btnSlotmachine.isActive = false
		scene.Popup.btnSlotmachineTextUpper.text = AZ.utils.translate("pp_slot_refill_already_upper")
		scene.Popup.btnSlotmachineTextLower.text = AZ.utils.translate("pp_slot_refill_already_lower")
		scene.Popup.slotButtonGrp.alpha = 0.75
	end
    
    scene.Popup.starOne = createStar(50, true, true, sheetInfo)
	scene.Popup.starOne.setPosition(_W*0.5-100*_R, _H*0.5-110*_R)
	scene.Popup:insert(scene.Popup.starOne)
	scene.Popup.starOne.bigLittleAnim()
	Runtime:addEventListener("enterFrame", scene.Popup.starOne.doubleRotate)
	
	scene.Popup.starTwo = createStar(50, true, false, sheetInfo)
	scene.Popup.starTwo.setPosition(_W*0.5+130*_R, _H*0.5-30*_R)
	scene.Popup:insert(scene.Popup.starTwo)
	scene.Popup.starTwo.bigLittleAnim()
	Runtime:addEventListener("enterFrame", scene.Popup.starTwo.doubleRotate)
	
	scene.Popup.starThree = createStar(80, false, false, sheetInfo)
	scene.Popup.starThree.setPosition(_W*0.5+35*_R, _H*0.5-140*_R)
	scene.Popup:insert(scene.Popup.starThree)
	scene.Popup.starThree.bigLittleAnim()
	Runtime:addEventListener("enterFrame", scene.Popup.starThree.doubleRotate)
    
    prepareCountdown()
    
end

--- Creem l'escene i guardem el paràmetres passats per utilitzar-los més endavant
function scene:createScene(event)
    scene.params = event.params or {}
    scene:init()
    transition.from(scene.Popup, {time = 1000, alpha = 0, x = _W*0.5, y = _H*0.5, xScale = 0.000001, yScale = 0.000001, transition = easing.outElastic})
end

function scene:exitScene(event)
    Runtime:removeEventListener("enterFrame", scene.Popup.lollipopBg.doubleRotate)
	Runtime:removeEventListener("enterFrame", scene.Popup.starOne.doubleRotate)
	Runtime:removeEventListener("enterFrame", scene.Popup.starTwo.doubleRotate)
	Runtime:removeEventListener("enterFrame", scene.Popup.starThree.doubleRotate)
	transition.cancel(scene.Popup.lollipopBg.big)
	transition.cancel(scene.Popup.lollipopBg.little)
	transition.cancel(scene.Popup.starOne.big)
	transition.cancel(scene.Popup.starOne.little)
	transition.cancel(scene.Popup.starTwo.big)
	transition.cancel(scene.Popup.starTwo.little)
	transition.cancel(scene.Popup.starThree.big)
	transition.cancel(scene.Popup.starThree.little)
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener( "createScene", scene )
scene:addEventListener("exitScene", scene)

return scene