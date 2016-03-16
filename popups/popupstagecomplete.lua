
local scene = AZ.S.newScene()

scene.Popup = {}
local _R = SCALE_BIG
local _W = display.contentWidth
local _H = display.contentHeight

scene.myImageSheet = nil
scene.params = nil
scene.Popup.background = nil
scene.Popup.btnClose = nil
scene.Popup.txtNoCoins = nil
scene.Popup.safeGroup = {}
scene.Popup.btnBuy = nil
local direction = nil
scene.itemToBuy = nil
scene.quantity = 500
scene.weaponPrice = nil

local function onTouch(event)
    
    local id = nil
    
    if event.target then
        id = event.target.id
    else
        id = event.id
    end
    
    if event.phase == "release" or event.phase == "ended" then
        if event.isBackKey or (id == "btnClose" and event.target.isWithinBounds) or id == "btnAccept" then
            AZ.userInfo.money = AZ.userInfo.money + scene.quantity
            AZ:saveData()
            AZ.S.hideOverlay("crossFade", 300)
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
    
    scene.Popup.background = display.newImage("popups/assets/popup_bg_nivel_completado.png")
    scene.Popup.background:scale(_R,_R)
    scene.Popup.background.x, scene.Popup.background.y = _W*0.5, _H*0.5+20*_R
	scene.Popup.background:addEventListener("touch", noTouch)
    scene.Popup:insert(scene.Popup.background)
    
	scene.btnClose = createBtn({id = "btnClose", x = _W*0.5+160*_R, y = _H*0.5-160*_R, btnIndex = sheetInfo:getFrameIndex("cerrar"), touchSound = AZ.soundLibrary.closePopupSound})
    
    scene.Popup.txtNoCoins = display.newText({text = AZ.utils.translate("pp_stage_complete"), x = _W*0.5, y = _H*0.5-130*_R, width = _W*0.7, font = BRUSH_SCRIPT, fontSize = 40*_R, align = "center"})
    scene.Popup.txtNoCoins:setFillColor(AZ.utils.getColor(FONT_BLACK_COLOR))
    
    -- Construim l'item a comprar
    scene.Popup.itemGroup = display.newGroup()
    scene.Popup.itemGroup.bg = createStar(40, false, false, sheetInfo)
	scene.Popup.itemGroup.bg.setPosition(_W*0.5, _H*0.5)
	scene.Popup.itemGroup.bg.bigLittleAnim()
	Runtime:addEventListener("enterFrame", scene.Popup.itemGroup.bg.doubleRotate)
    scene.Popup.itemGroup:insert(scene.Popup.itemGroup.bg)
    scene.Popup.itemGroup.img = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("sack"))
    scene.Popup.itemGroup.img:scale(_R, _R)
    scene.Popup.itemGroup.img.x, scene.Popup.itemGroup.img.y = _W*0.5, _H*0.5-10*_R
    scene.Popup.itemGroup:insert(scene.Popup.itemGroup.img)
    scene.Popup.itemGroup.txt = display.newText({text = "+"..scene.quantity, x = _W*0.5, y = _H*0.5+90*_R, font = INTERSTATE_BOLD, fontSize = 40*_R, align = "center"})
    scene.Popup.itemGroup.txt:setFillColor(AZ.utils.getColor(FONT_BLACK_COLOR))
    -- Marcador amb la quantitat de monedes que es guanyaran comprant l'item
    scene.Popup.itemGroup.circle = display.newGroup()
        local left = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("etiqueta_cantidad_bl_1"))
        left:scale(_R, _R)
        left.x, left.y = 0, 0
        scene.Popup.itemGroup.circle:insert(left)
        local middle = display.newImage("popups/assets/etiqueta_cantidad_bl_2.png")
        middle:scale(scene.Popup.itemGroup.txt.contentWidth/middle.contentWidth, _R)
        middle.x, middle.y =  left.contentWidth*0.5 + middle.contentWidth*0.5, 0
        scene.Popup.itemGroup.circle:insert(middle)
        local right = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("etiqueta_cantidad_bl_1"))
        right:scale(_R, _R)
        right:rotate(180)
        right.x, right.y = left.contentWidth + middle.contentWidth, 0
        scene.Popup.itemGroup.circle:insert(right)
    scene.Popup.itemGroup.circle.anchorChildren = true
    scene.Popup.itemGroup.circle.x, scene.Popup.itemGroup.circle.y = _W*0.5, _H*0.5+90*_R
    scene.Popup.itemGroup:insert(scene.Popup.itemGroup.circle)
    --
    scene.Popup.itemGroup:insert(scene.Popup.itemGroup.txt)
    
    scene.Popup.btnBuy = AZ.ui.newEnhancedButton2{
        sound = AZ.soundLibrary.buttonSound,
        myImageSheet = scene.myImageSheet,
        unpressedIndex = sheetInfo:getFrameIndex("boton_gris"),
        x = _W*0.5,
        y = _H*0.5+180*_R,
        pressedIndex = sheetInfo:getFrameIndex("boton_gris_press"),
        text1 = {text = AZ.utils.translate("pp_continue"), fontName = INTERSTATE_BOLD, fontSize = 50, X = 0, Y = 30, color = FONT_BLACK_COLOR},
        onEvent = onTouch,
        id = "btnAccept"
    }
    scene.Popup.btnBuy:scale(_R,_R)
    
    scene.Popup:insert(scene.Popup.btnBuy)
    scene.Popup:insert(scene.Popup.itemGroup)
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
	
	scene.Popup.starThree = createStar(80, false, false, sheetInfo)
	scene.Popup.starThree.setPosition(_W*0.5-10*_R, _H*0.5+85*_R)
	scene.Popup:insert(scene.Popup.starThree)
	scene.Popup.starThree.bigLittleAnim()
	Runtime:addEventListener("enterFrame", scene.Popup.starThree.doubleRotate)
    
end

--- Creem l'escene i guardem el paràmetres passats per utilitzar-los més endavant
function scene:createScene(event)
    scene.params = event.params
    scene:init()
    transition.from(scene.Popup, {time = 1000, alpha = 0, x = _W*0.5, y = _H*0.5, xScale = 0.000001, yScale = 0.000001, transition = easing.outElastic})
end

function scene:exitScene(event)
	Runtime:removeEventListener("enterFrame", scene.Popup.itemGroup.bg.doubleRotate)
	Runtime:removeEventListener("enterFrame", scene.Popup.starOne.doubleRotate)
	Runtime:removeEventListener("enterFrame", scene.Popup.starTwo.doubleRotate)
	Runtime:removeEventListener("enterFrame", scene.Popup.starThree.doubleRotate)
	transition.cancel(scene.Popup.itemGroup.bg.big)
	transition.cancel(scene.Popup.itemGroup.bg.little)
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