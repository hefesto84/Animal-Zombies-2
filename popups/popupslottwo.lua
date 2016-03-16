
local scene = AZ.S.newScene()

scene.Popup = {}
scene.params = nil
scene.myImageSheet = nil
scene.price = nil

local _W = display.contentWidth
local _H = display.contentHeight
local _R = SCALE_BIG

local weaponBg = nil

local function onTouch(event)
    local id = nil 
    if event.target ~= nil then
        id = event.target.id
    else
        id = event.id
    end
    local phase = event.phase
    
    if phase == "ended" or phase == "release" then
        if event.isBackKey or (id == "btnClose" and event.target.isWithinBounds) then 
            AZ.S.hideOverlay()
        elseif id == "btnTwoPrize" then
            if (AZ.userInfo.money-scene.price) >= 0 then
                for i = 1, #AZ.userInfo.weapons do
					if AZ.userInfo.weapons[i].name == scene.params.prizeName then
						AZ.userInfo.weapons[i].boughtLevel = AZ.userInfo.weapons[i].boughtLevel + 1
						AZ.userInfo.weapons[i].quantity = scene.prizeAmount
						AZ.userInfo.money = AZ.userInfo.money - scene.price
					end
                end
				AZ:saveData()
--				AZ.S.hideOverlay()
				local options = {
                    time = 300,
                    effect = "crossFade",
                    params = scene.params
                }
				if options.params.source then
					options.params.source[#options.params.source+1] = "slotmachine.slotmachine"
				else
					options.params.source = {"slotmachine.slotmachine"}
				end
                AZ.S.gotoScene("shop.shop", options)
            else
                local options = {
                    effect = "crossFade",
                    time = 300,
                    params = scene.params,
                    isModal = true
                }
				options.params.isSlotPopup = true
				options.params.weaponName = scene.params.prizeName
				if options.params.source then
					options.params.source[#options.params.source+1] = "popups.popupslottwo"
				else
					options.params.source = "popups.popupslottwo"
				end
                direction = "buyCoins"
                AZ.S.showOverlay("popups.popupmoneygameplay", options)
            end
        end
    end
end

function scene.onBackTouch()
	onTouch({ phase = "ended", isBackKey = true })
end

--- És la funció encarregada de crear les imatges que es mostren per pantalla
local function bitmap(image,atlas,x,y)
   
   local bmp = nil
   if type(image) == "number" then
       bmp = display.newImage( scene.myImageSheet, image)
   else
       bmp = display.newImage( scene.myImageSheet, atlas:getFrameIndex(image))
   end
   
   if(bmp) then
       bmp.x,bmp.y = x, y
       bmp:scale(_R,_R)
       return bmp
   end
end

--- Función per crear texts escalats
-- Aquesta funció crea textos escalats a la resolució que toca sense que existeixi
-- un sobreconsum de memòria
local function addText(name,str, color, font, x, y, size)
    local t = display.newText(str, 0, 0, font, size*_R)
    t:setFillColor(color.r, color.g, color.b, color.a)
    t.x = x
    t.y = y
    t.name = name
    t.anchorX = 0.5
    t.anchorY = 0.5
    return t
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
--				transition.to(star.little, {time = 800, xScale = scene.R*0.5, yScale = scene.R*0.5, transition = easing.outQuad})
			end
			star.big.alpha = 1
			star.little.alpha = 1
			star.little.xScale, star.little.yScale = _R*1.8, _R*1.8
			transition.to(star.big, {time = 800, xScale = _R*0.5, yScale = _R*0.5, transition = easing.outQuad, onComplete = bigAnim})
--			transition.to(star.little, {time = 800, xScale = scene.R*1.8, yScale = scene.R*1.8, transition = easing.outQuad})
		end
	end
	
	function star.setPosition(x, y)
		star.big.x, star.big.y, star.little.x, star.little.y = x, y, x, y
	end
	
	return star
end

--- Funció showTwoPrize
-- És la funció encarregada de crear el contingut del popup quan s'aconsegueix
-- un premi de dues armes iguals
-- @param name És el nom del premi aconseguit
local function showTwoPrize(name, sheetInfo)
    scene.twoPrize = display.newGroup()
    local qtt = nil
    local price = nil
    
    local title = addText("titleTwoPrize", AZ.utils.translate("pp_slot_deal"), {r = 0.2, g = 0.2, b = 0.2, a = 0.9, }, BRUSH_SCRIPT, _W*0.5, _H*0.5-140*_R, 55)
    
    -- Etiqueta de descompte
    local discountBg = bitmap("etiqueta_descuento", sheetInfo, _W*0.5, _H*0.5-60*_R)
    local discountLbl = addText("discount", "-50%", {r = 0.2, g = 0.2, b = 0.2, a = 0.9, }, INTERSTATE_BOLD, _W*0.5, _H*0.5-60*_R, 40)
    
    --Elements de l'arma a comprar
	weaponBg = createStar(40, false, false, sheetInfo)
	weaponBg.setPosition(_W*0.5, _H*0.5+40*_R)
	weaponBg.bigLittleAnim()
	Runtime:addEventListener("enterFrame", weaponBg.doubleRotate)
    
    local weapon = bitmap(name, sheetInfo, _W*0.5, _H*0.5+40*_R)
    --weapon.xScale, weapon.yScale = scene.R*0.9, scene.R*0.9
    local weaponQttBg = bitmap("etiqueta_cantidad", sheetInfo, _W*0.5, _H*0.5+100*_R)
    for i=1,#AZ.shopInfo.shop.weapons do
        if AZ.shopInfo.shop.weapons[i].name == name.."_name" then
			for j = 1, #AZ.userInfo.weapons do
				if AZ.userInfo.weapons[j].name == name then
					qtt = AZ.shopInfo.shop.weapons[i].boosterData[AZ.userInfo.weapons[j].boughtLevel + 1].quantity
					price = AZ.shopInfo.shop.weapons[i].boosterData[AZ.userInfo.weapons[j].boughtLevel + 1].price
					scene.price = price/2
				end
			end
        end
    end
    local weaponQtt = addText("qtt", tostring(qtt), {r = 0.2, g = 0.2, b = 0.2, a = 0.9, }, INTERSTATE_BOLD, _W*0.5, _H*0.5+100*_R, 30)
    scene.prizeAmount = qtt
    
    -- Botó per comprar
    local btnTwoPrize = AZ.ui.newEnhancedButton2(
    {
	sound = AZ.soundLibrary.buttonSound,
        id = "btnTwoPrize",
        myImageSheet = scene.myImageSheet,
        unpressedIndex = sheetInfo:getFrameIndex("boton"),
        pressedIndex = sheetInfo:getFrameIndex("boton_press"),
        x = _W*0.5,
        y = _H*0.5+170*_R,
        onEvent = onTouch
    })
    btnTwoPrize:scale(_R, _R)
    local imgBigCoin = bitmap("coin_XL", sheetInfo, _W*0.5-30*_R, _H*0.5+155*_R)
    imgBigCoin.xScale, imgBigCoin.yScale = _R*0.5, _R*0.5
    local txtDiscountPrize = addText("discountPrice", scene.price, {r = 0.2, g = 0.2, b = 0.2, a = 0.9, }, INTERSTATE_BOLD, _W*0.5+30*_R, _H*0.5+155*_R, 50)
    local lblBefore = addText("before", AZ.utils.translate("pp_slot_deal_before"), {r = 0.2, g = 0.2, b = 0.2, a = 0.9, }, BRUSH_SCRIPT, _W*0.5-35*_R, _H*0.5+190*_R, 25)
    local imgLittleCoin = bitmap("coin_XL", sheetInfo, _W*0.5+15*_R, _H*0.5+190*_R)
    imgLittleCoin.xScale, imgLittleCoin.yScale = _R*0.3, _R*0.3
    local txtPrice = addText("price", price, {r = 0.2, g = 0.2, b = 0.2, a = 0.9, }, INTERSTATE_BOLD, _W*0.5+45*_R, _H*0.5+190*_R, 25)
    local lineStrike = bitmap("tachado", sheetInfo, _W*0.5+33*_R, _H*0.5+190*_R)
    
    scene.twoPrize:insert(title)
    scene.twoPrize:insert(btnTwoPrize)
    scene.twoPrize:insert(imgBigCoin)
    scene.twoPrize:insert(txtDiscountPrize)
    scene.twoPrize:insert(lblBefore)
    scene.twoPrize:insert(imgLittleCoin)
    scene.twoPrize:insert(txtPrice)
    scene.twoPrize:insert(lineStrike)
    scene.twoPrize:insert(weaponBg)
    scene.twoPrize:insert(weapon)
    scene.twoPrize:insert(weaponQttBg)
    scene.twoPrize:insert(weaponQtt)
    scene.twoPrize:insert(discountBg)
    scene.twoPrize:insert(discountLbl)
    
	
	scene.starOne = createStar(50, true, true, sheetInfo)
	scene.starOne.setPosition(_W*0.5-100*_R, _H*0.5+85*_R)
	scene.twoPrize:insert(scene.starOne)
	scene.starOne.bigLittleAnim()
	Runtime:addEventListener("enterFrame", scene.starOne.doubleRotate)
	
	scene.starTwo = createStar(50, true, false, sheetInfo)
	scene.starTwo.setPosition(_W*0.5+130*_R, _H*0.5+25*_R)
	scene.twoPrize:insert(scene.starTwo)
	scene.starTwo.bigLittleAnim()
	Runtime:addEventListener("enterFrame", scene.starTwo.doubleRotate)
	
	scene.starThree = createStar(80, false, false, sheetInfo)
	scene.starThree.setPosition(_W*0.5-10*_R, _H*0.5+85*_R)
	scene.twoPrize:insert(scene.starThree)
	scene.starThree.bigLittleAnim()
	Runtime:addEventListener("enterFrame", scene.starThree.doubleRotate)
    
    return scene.twoPrize
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
    
    scene.Popup.background = display.newImage("popups/assets/popup_bg.png")
    scene.Popup.background:scale(_R,_R)
    scene.Popup.background.x, scene.Popup.background.y = _W*0.5, _H*0.5+20*_R
	scene.Popup.background:addEventListener("touch", noTouch)
    scene.Popup:insert(scene.Popup.background)
    
	scene.btnClose = createBtn({id = "btnClose", x = _W*0.5+160*_R, y = _H*0.5-160*_R, btnIndex = sheetInfo:getFrameIndex("cerrar"), touchSound = AZ.soundLibrary.closePopupSound})
	
	scene.Popup:insert(showTwoPrize(scene.params.prizeName, sheetInfo))
    
end

function scene:createScene(event)
    scene.params = event.params
    scene:init()
	transition.from(scene.Popup, {time = 1000, alpha = 0, x = _W*0.5, y = _H*0.5, xScale = 0.000001, yScale = 0.000001, transition = easing.outElastic})
end

function scene:exitScene(event)
	Runtime:removeEventListener("enterFrame", weaponBg.doubleRotate)
	Runtime:removeEventListener("enterFrame", scene.starOne.doubleRotate)
	Runtime:removeEventListener("enterFrame", scene.starTwo.doubleRotate)
	Runtime:removeEventListener("enterFrame", scene.starThree.doubleRotate)
	transition.cancel(weaponBg.big)
	transition.cancel(weaponBg.little)
	transition.cancel(scene.starOne.big)
	transition.cancel(scene.starOne.little)
	transition.cancel(scene.starTwo.big)
	transition.cancel(scene.starTwo.little)
	transition.cancel(scene.starThree.big)
	transition.cancel(scene.starThree.little)
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener("createScene", scene)
scene:addEventListener("exitScene", scene)

return scene