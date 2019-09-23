
local scene = AZ.S.newScene()

scene.Popup = {}
local _R = SCALE_BIG
local _W = display.contentWidth
local _H = display.contentHeight

scene.myImageSheet = nil
scene.Popup.background = nil
scene.Popup.btnClose = nil
scene.Popup.txtNoCoins = nil
scene.Popup.safeGroup = {}
scene.Popup.btnBuy = nil
local direction = nil

local function onTouch(event)
    
    local id = nil
    
    if event.target then
        id = event.target.id
    else
        id = event.id
    end
    
    if event.phase == "release" or event.phase == "ended" then
        
		if event.isBackKey or (id == "btnClose" and event.target.isWithinBounds) then
            direction = "source"
            local options = {
                effect = "crossFade",
                time = 300,
                params = scene.params,
                isModal = true
            }
            AZ.S.hideOverlay("crossFade", 300)
        elseif id == "btnBank" then
            direction = "bank"
            local options = {
                effect = "crossFade",
                time = 300,
                params = scene.params
            }
            AZ.S.gotoScene("bank.bank", options)
        end
    end
end

function scene.onBackTouch()
	onTouch({ phase = "ended", isBackKey = true })
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
						y = _H*0.5+(math.random(0, 100))*_R
					else
						x = _W*0.5-(math.random(60, 150))*_R
						y = _H*0.5-(math.random(0, 100))*_R
					end
				else
					delay = math.random(25, 75)
					if math.round(math.random()) == 0 then
						x = _W*0.5+(math.random(60, 150))*_R
						y = _H*0.5+(math.random(0, 100))*_R
					else
						x = _W*0.5+(math.random(60, 150))*_R
						y = _H*0.5-(math.random(0, 100))*_R
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
	local btn = AZ.ui.newTouchButton({ id = params.id, x = params.x, y = params.y, touchSound = params.touchSound or AZ.soundLibrary.buttonSound, releaseSound = params.releaseSound, txtParams = params.txtParams, btnIndex = params.btnIndex,  imageSheet = scene.myImageSheet, onTouch = onTouch })
	btn:setScale(SCALE_BIG*1.2, SCALE_BIG*1.2)
	scene.Popup:insert(btn)
	return btn
end

function scene:init()
    scene.Popup = display.newGroup()
    
    local sheetInfo = require "popups.assets.popups_sprite0"
    scene.myImageSheet = graphics.newImageSheet("popups/assets/popups_sprite0.png",sheetInfo:getSheet())
    
    scene.Popup.translucidBg = display.newRect(0, 0, _W+200*_R, _H)
    scene.Popup.translucidBg.x, scene.Popup.translucidBg.y = _W*0.5, _H*0.5
    scene.Popup.translucidBg:setFillColor({0,0,0,0.5})
    scene.Popup.translucidBg.alpha = 0.5
	scene.Popup.translucidBg.id = "btnClose"
	scene.Popup.translucidBg:addEventListener("touch", onTouch)
	scene.Popup.translucidBg.isWithinBounds = true
    scene.view:insert(scene.Popup.translucidBg)
    
    scene.view:insert(scene.Popup)
    
    scene.Popup.background = display.newImage("popups/assets/popup_no_money_bg.png")
    scene.Popup.background:scale(_R,_R)
    scene.Popup.background.x, scene.Popup.background.y = _W*0.5, _H*0.5+20*_R
	scene.Popup.background:addEventListener("touch", noTouch)
    scene.Popup:insert(scene.Popup.background)
    
	scene.btnClose = createBtn({id = "btnClose", x = _W*0.5+160*_R, y = _H*0.5-160*_R, btnIndex = sheetInfo:getFrameIndex("cerrar")})
    
    scene.Popup.txtNoCoins = display.newText({text = AZ.utils.translate("pp_no_coins_enought"), x = _W*0.5, y = _H*0.5-140*_R, font = BRUSH_SCRIPT, fontSize = 45*_R, align = "center"})
    scene.Popup.txtNoCoins:setFillColor(AZ.utils.getColor(FONT_BLACK_COLOR))
    
    scene.Popup.safeGroup = display.newGroup()
    scene.Popup.safeGroup.bg = createStar(40, false, false, sheetInfo)
	scene.Popup.safeGroup.bg.setPosition(_W*0.5, _H*0.5)
	scene.Popup.safeGroup.bg.bigLittleAnim()
	Runtime:addEventListener("enterFrame", scene.Popup.safeGroup.bg.doubleRotate)
    scene.Popup.safeGroup:insert(scene.Popup.safeGroup.bg)
    scene.Popup.safeGroup.img = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("safe_w_coins"))
    scene.Popup.safeGroup.img:scale(_R, _R)
    scene.Popup.safeGroup.img.x, scene.Popup.safeGroup.img.y = _W*0.5, _H*0.5+30*_R
    scene.Popup.safeGroup:insert(scene.Popup.safeGroup.img)
    
    scene.Popup.btnBuy = AZ.ui.newEnhancedButton2{
        sound = AZ.soundLibrary.buttonSound,
        myImageSheet = scene.myImageSheet,
        unpressedIndex = sheetInfo:getFrameIndex("boton_dorado"),
        x = _W*0.5,
        y = _H*0.5+180*_R,
        pressedIndex = sheetInfo:getFrameIndex("boton_dorado_press"),
        text1 = {text = "BUY COINS", fontName = INTERSTATE_BOLD, fontSize = 40, X = 35, Y = 20, color = FONT_BLACK_COLOR},
        onEvent = onTouch,
        id = "btnBank"
    }
    scene.Popup.btnBuy:scale(_R,_R)
    scene.Popup:insert(scene.Popup.btnBuy)
    
    scene.Popup.imgCoin = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("coin_XL"))
    scene.Popup.imgCoin:scale(_R*0.7,_R*0.7)
    scene.Popup.imgCoin.x, scene.Popup.imgCoin.y = _W*0.5-100*_R, _H*0.5+180*_R
    scene.Popup:insert(scene.Popup.imgCoin)
    
    scene.Popup:insert(scene.Popup.safeGroup)
    scene.Popup:insert(scene.Popup.txtNoCoins)
    
    scene.Popup.starOne = createStar(50, true, true, sheetInfo)
	scene.Popup.starOne.setPosition(_W*0.5-100*_R, _H*0.5+85*_R)
	scene.Popup:insert(scene.Popup.starOne)
	scene.Popup.starOne.bigLittleAnim()
	Runtime:addEventListener("enterFrame", scene.Popup.starOne.doubleRotate)
	
	scene.Popup.starTwo = createStar(50, true, false, sheetInfo)
	scene.Popup.starTwo.setPosition(_W*0.5+130*_R, _H*0.5+25*_R)
	scene.Popup:insert(scene.Popup.starTwo)
	scene.Popup.starTwo.bigLittleAnim()
	Runtime:addEventListener("enterFrame", scene.Popup.starTwo.doubleRotate)
    
end

--- Creem l'escene i guardem el paràmetres passats per utilitzar-los més endavant
function scene:createScene(event)
    scene.params = event.params
    scene:init()
    transition.from(scene.Popup, {time = 1000, alpha = 0, x = _W*0.5, y = _H*0.5, xScale = 0.000001, yScale = 0.000001, transition = easing.outElastic})
end

function scene:exitScene(event)
	Runtime:removeEventListener("enterFrame", scene.Popup.safeGroup.bg.doubleRotate)
	Runtime:removeEventListener("enterFrame", scene.Popup.starOne.doubleRotate)
	Runtime:removeEventListener("enterFrame", scene.Popup.starTwo.doubleRotate)
	transition.cancel(scene.Popup.safeGroup.bg.big)
	transition.cancel(scene.Popup.safeGroup.bg.little)
	transition.cancel(scene.Popup.starOne.big)
	transition.cancel(scene.Popup.starOne.little)
	transition.cancel(scene.Popup.starTwo.big)
	transition.cancel(scene.Popup.starTwo.little)
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener( "createScene", scene )
scene:addEventListener("exitScene", scene)

return scene



