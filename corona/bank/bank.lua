require "config"
local widget = require "widget"
local easing = require "easing"

local scene = AZ.S.newScene()
scene.Bank = {}

--- Variables i constants
local realWidth = 640
local realHeight = 960
local _R = SCALE_EXTRA_BIG
local _W = display.contentWidth
local _H = display.contentHeight
local _coins = AZ.userInfo.money
local _iconHeight = (150*_H)/realHeight
local _iconWidth = (131*_W)/realWidth
local params = nil
local direction = nil
local translate = nil

scene.bankBg = nil
scene.txtCoins = nil
scene.txtTitle = nil
scene.btnClose = nil
scene.txtItemName = nil
scene.txtItemDescription = nil
scene.btnBuy = nil
scene.txtBooster = nil
scene.txtPriceBooster = nil
scene.tm = nil
scene.jsonChanged = false
local booster = nil
local deltaTimeLeft = 0
local deltaTimeRight = 0
local itemTransID, shine1TransID, shine2TransID, timerID, shineTransID, shineTimerID = nil
local hasToWait = false --Variable per controlar la diferencia de temps entre les transicions de brillo del botons

-- Creem les variables que contindran les items a vendre
scene.scrollItems = nil
scene.items = {}
 
--- Taula que conté la informació de les diferents items
--scene.infoItems = AZ.personal.loadPersonalData(AZ.personal.bankInfo)

scene.infoItems = AZ.bankInfo.bankShop.bank

--- Funció per cancelar les transicions que puguin tenir les armes de l'scroll
local function cancelItemTransition()
	itemTransID = transition.safeCancel(itemTransID)
	shine1TransID = transition.safeCancel(shine1TransID)
	shine2TransID = transition.safeCancel(shine2TransID)
	timerID = timer.safeCancel(timerID)
end

local function cancelBtnShineTransition()
	shineTransID = transition.safeCancel(shineTransID)
	shineTimerID = timer.safeCancel(shineTimerID)
	
	scene.bars.alpha = 0
	scene.littleShine.alpha = 0
	scene.littleShine.xScale, scene.littleShine.yScale = 0.001, 0.001
	hasToWait = false
end

local function getDeltaTimeRight()
    local temp = system.getTimer() --Get current game time in ms
    local dt = (temp-deltaTimeRight) *0.001
    deltaTimeRight = temp --Store game time
    return dt
end

local function getDeltaTimeLeft()
    local temp = system.getTimer() --Get current game time in ms
    local dt = (temp-deltaTimeLeft) *0.001
    deltaTimeLeft = temp --Store game time
    return dt
end

local function rotateRight()
    local rotation = 50 * getDeltaTimeRight()
    for i = 1, #scene.items do
        if scene.items[i].isSelected == true then
            scene.items[i].shine1:rotate(rotation)
        end
    end
end

local function rotateLeft()
    local rotation = -25 * getDeltaTimeLeft()
    for i = 1, #scene.items do
        if scene.items[i].isSelected == true then
            scene.items[i].shine2:rotate(rotation)
        end
    end
end

local function barsShine()
	
	local function littleShine()
		local function endLittleShine()
			shineTransID = transition.safeCancel(shineTransID)
			shineTransID = transition.to(scene.littleShine, {time = 500, alpha = 0, xScale = 0.001, yScale = 0.001, rotation = -360, transition = easing.inSine, onComplete = shine})
		end
		if hasToWait then
			shineTransID = transition.safeCancel(shineTransID)
			shineTransID = transition.to(scene.littleShine, {time = 500, alpha = 0.8, xScale = 0.4*_R, yScale = 0.4*_R, rotation = 360, transition = easing.inSine, onComplete = endLittleShine})
		else
			shineTimerID = timer.safePerformWithDelay(shineTimerID, 250, shine)
		end
	end
	
	local function continueShine()
		shineTransID = transition.safeCancel(shineTransID)
		shineTransID = transition.to(scene.bars, {time = 250, alpha = 0.8, x = scene.btnBuy.contentWidth*0.5, y = scene.btnBuy.contentWidth*0.5, onComplete =  littleShine})
	end
	scene.bars.xScale, scene.bars.yScale = 1, 1
	scene.bars.alpha = 0.5
	scene.bars.x, scene.bars.y = 0, 0
	shineTransID = transition.safeCancel(shineTransID)
	shineTransID = transition.from(scene.bars, {time = 250, alpha = 0.2, x = -scene.btnBuy.contentWidth*0.5, y = -scene.btnBuy.contentWidth*0.5, onComplete = continueShine})
end

function shine()
	if hasToWait then
		shineTimerID = timer.safePerformWithDelay(shineTimerID, 5000, barsShine)
		hasToWait = false
	else
		barsShine()
		hasToWait = true
	end
end

--- Funció selectItem
local function selectItem(num)
    
	cancelItemTransition()
	cancelBtnShineTransition()
    for i=1, #scene.items do
        if scene.items[i].isSelected == true then
			Runtime:removeEventListener("enterFrame", rotateLeft)
			Runtime:removeEventListener("enterFrame", rotateRight)
			shine1TransID = transition.to(scene.items[i].shine1, {time = 150, delay = 25, alpha = 0, xScale = 0.0001*_R, yScale = 0.0001*_R, easing = easing.inOutQuad})
			shine2TransID = transition.to(scene.items[i].shine2, {time = 150, delay = 25, alpha = 0, xScale = 0.0001*_R, yScale = 0.0001*_R, easing = easing.inOutQuad})
            itemTransID = transition.to(scene.items[i].item, {time = 150, delay = 25, xScale = 0.7*_R, yScale = 0.7*_R, easing = easing.inOutQuad, onComplete = function() scene.items[i].isSelected = false end})
        end
    end
    
--    scene.items[num].isSelected = true
    itemTransID = transition.to(scene.items[num].item, {time = 300, delay = 200, xScale = _R, yScale = _R, easing = easing.inOutQuad, onStart = function() Runtime:addEventListener("enterFrame", rotateLeft); Runtime:addEventListener("enterFrame", rotateRight); scene.items[num].isSelected = true end})
	shine1TransID = transition.to(scene.items[num].shine1, {time = 300, delay = 200, alpha = 1, xScale = 1.6*_R, yScale = 1.6*_R, easing = easing.inOutQuad})
	shine2TransID = transition.to(scene.items[num].shine2, {time = 300, delay = 200, alpha = 1, xScale = 1.6*_R, yScale = 1.6*_R, easing = easing.inOutQuad})
--	timerID = timer.safePerformWithDelay(200, function() Runtime:addEventListener("enterFrame", rotateLeft); Runtime:addEventListener("enterFrame", rotateRight); scene.items[num].isSelected = true end)
	
    scene.txtItemName.text = translate(scene.items[num].info.itemName)
	if translate(scene.items[num].info.itemDescription) then
		scene.txtItemDescription.text = translate(scene.items[num].info.itemDescription)
	else
		scene.txtItemDescription.text = scene.items[num].info.itemDescription
	end
    scene.txtPriceBooster.text = scene.items[num].info.price
    scene.txtBooster.text = scene.items[num].info.quantity
	hasToWait = false
	shineTimerID = timer.safePerformWithDelay(shineTimerID, 500, barsShine)
end

local function startedPointInRect(p, r)
    return r.contentBounds.xMin < p.xStart and r.contentBounds.xMax > p.xStart and r.contentBounds.yMin < p.yStart and r.contentBounds.yMax > p.yStart
end

--- Funció que controla la selecció de l'Arma
-- Aquesta funció és la que controlarà el comportament que tindrà la pantalla quan es seleccioni una arma.
-- Aquesta rep l'event i juntament amb aquest el target, que és el botó en concret.
-- Gràcies al target podrem controlar si el botó està seleccionat o no i en el cas que no ho estigui, fer que ho estigui
-- i desseleccionar l'Arma que ho estigui anteriorment.
-- També ens permet donar el focus a l'ScrollView que conté el botó, de manera que encara que tinguem el dit sobre aquest,
-- al moure'l poguem fer scroll igualment.

local function clickOnItem(event)
    if event.phase == "moved" then
        local dx = math.abs( event.x - event.xStart )
        local dy = math.abs( event.y - event.yStart )
        
        if dx > 5 or dy > 5 then
            if startedPointInRect(event, event.target) then 
                scene.scrollItems:takeFocus( event )
            end
        end
    
    elseif event.phase == "ended" and startedPointInRect(event, event.target) then
        local target = event.target
		for i = 1, #scene.items do
			if target.info.storeID == scene.items[i].info.storeID then
				scene.scrollItems:scrollToPosition({x= (-scene.items[i].x)+_W*0.5, time=500})
				selectItem(i)
			end
		end
        
    end
 
    return true
end

local function coinFormat(c)
    local finalStr = ""
    local cStr = tostring(c)
    
    while #cStr > 2 do
        if finalStr == "" then
            finalStr = string.sub(cStr, #cStr-2, #cStr)
        else
            finalStr = string.sub(cStr, #cStr-2, #cStr) ..".".. finalStr
        end
        
        cStr = string.sub(cStr, 1, #cStr -3)
    end
    
    if #cStr > 0 and finalStr ~= "" then
        finalStr = cStr ..".".. finalStr
    elseif #cStr > 0 and finalStr == "" then
        finalStr = cStr
    end
    
    return finalStr
end

--- Funció buyItems
--Aquesta funció ens ha de permetre accedir a la botiga pertinent per poder
--fer la compra in-app
local function buyItems()
    
	local coinsToBuy
	local i = 0
	local found = false

	while found == false and i<#scene.items do
		i = i+1
		if scene.items[i].isSelected == true then
			found = true
			coinsToBuy = scene.items[i].info.quantity
		end
	end
	
	local function callback(success, receipt)
		if success then
			
			AZ.audio.playFX(AZ.soundLibrary.buyRealMoneySound, AZ.audio.AUDIO_VOLUME_OTHER_FX)
			
			print("Coins earned: ".. coinsToBuy)
			
			_coins = _coins + coinsToBuy
			AZ.userInfo.money = _coins
			scene.btnBank.txt.text = AZ.utils.coinFormat(_coins)
			scene.jsonChanged = true
		end
		
		AZ.loader:showHide(false, 100)
	end
	
	AZ.loader:showHide(true, 100)
	
	AZ.Gamedonia:buyProduct(scene.items[i].info.storeID, callback, true)
end

---Aquesta funció controla els events touch que es creen als diferents botons
local function onClick(event)
    
    local id = nil
    local phase = event.phase
    
    if event.target then
        id = event.target.id
    else
        id = event.id
    end
    if phase == "ended" or phase == "release" then
        --Tanca el banc i retorna a l'scene que l'ha cridat
        if event.isBackKey or (id == "btnClose" and event.target.isWithinBounds) then
            direction = "source"
            local options = {
                effect = "crossFade",
                time = 250,
                params = params
            }
            if params.isLollipop then
                options.isModal = true
                AZ.S.showOverlay("popups.popupwolollipops", options)
            elseif params.isRefillWeapon then
                options.isModal = true
                AZ.S.showOverlay("popups.popuprefillweapon", options)
            else
				direction = params.source[#params.source]
				options.params.source[#options.params.source] = nil
				AZ.S.gotoScene(direction, options)
            end
		elseif id == "btnShop" and event.target.isWithinBounds then
			direction = "shop"
			local options = {
				effect = "crossFade",
				time = 250,
				params = params
			}
			if options.params.source then
				if options.params.source[#options.params.source] == "shop.shop" then
					options.params.source[#options.params.source] = nil
				else
					options.params.source[#options.params.source+1] = "bank.bank"
				end
			else
				options.params.source = { "bank.bank" }
			end
			
			AZ.S.gotoScene("shop.shop", options)
			
		elseif id == "btnHearts" and event.target.isWithinBounds then
			local options = {
                effect = "crossFade",
                time = 1000,
                isModal = true
            }
            AZ.S.showOverlay("popups.popupwolives", options)
        --Cada cop que es toca el botó de comprar 
        elseif id == "btnBuy" then
            direction = "buy"
            buyItems()
        end
        
    end  
end

function scene.onBackTouch()
	onClick({ phase = "ended", isBackKey = true })
end

--- Funció per crear bitmaps escalats
-- Aquesta funció crea bitmaps escalats a la resolució que toca sense que existeixi
-- un sobreconsum de memoria
-- @param path Ruta de la imatge que carregem
-- @param x Coordenada X on col·locarem la imatge
-- @param y Coordenada Y on col·locarem la imatge 

local function bitmap(myImageSheet,index,x,y)
    local bmp = display.newImage(myImageSheet,index)
    bmp:scale(_R,_R)
    bmp.x = x
    bmp.y = y
    return bmp
end


--- Función para crear textos escalados
-- Esta función crea textos escalados a la resolución que toca sin que exista
-- un sobreconsumo de memoria
-- @param str String con el texto que mostraremos
-- @param color Array con los colores en RGBA, ej: {r = 100, g = 100, b = 100, a = 1}
-- @param font Fuente para el texto. Por defecto, native.systemFont
-- @param x Coordenada X donde colocaremos el texto
-- @param y Coordenada Y donde colocaremos el texto 
-- @param size Tamaño del texto que vamos a escribir

local function addText(name,str, color, font, x, y, size)
    local t = display.newText(str, 0, 0, font, size*_R)
    t:setFillColor(color.r, color.g, color.b, color.a)
    t.x = x
    t.y = y
    t.name = name
    scene.Bank:insert(t)
    return t
end

--- Funció onScrollEnded
-- És la funció encarregada de seleccionar els ítems quan l'scroll ha acabat
local function onScrollEnded(event)
    
    local x = scene.scrollItems:getContentPosition()
	
	for i = #scene.items, 1, -1 do
		if i ~= 1 then
			if x <= -((scene.items[i-1].x+((scene.items[i].x-scene.items[i-1].x)*0.5))-_W*0.5) then
				scene.scrollItems:scrollToPosition({x=(-scene.items[i].x)+_W*0.5, time=350})
				selectItem(i)
				return
			end
		else
			scene.scrollItems:scrollToPosition({x=(-scene.items[i].x)+_W*0.5, time=350})
			selectItem(i)
		end	
	end
end

--- Funció scrollListener
-- És el listener que controla el comportament de l'ScrollView, aquest hi ha de ser
-- perquè funcioni, però no cal que contingui res.

local function scrollListener( event )
    local x = scene.scrollItems:getContentPosition()
    
    local phase = event.phase
    
    if "began" == phase then
		scene.tm = timer.safeCancel(scene.tm)
		cancelItemTransition()
		cancelBtnShineTransition()
		for i=1, #scene.items do
            if scene.items[i].isSelected == true then
				Runtime:removeEventListener("enterFrame", rotateLeft)
				Runtime:removeEventListener("enterFrame", rotateRight)
				shine1TransID = transition.to(scene.items[i].shine1, {time = 150, delay = 0, alpha = 0, xScale = 0.0001*_R, yScale = 0.0001*_R, easing = easing.inOutQuad})
				shine2TransID = transition.to(scene.items[i].shine2, {time = 150, delay = 0, alpha = 0, xScale = 0.0001*_R, yScale = 0.0001*_R, easing = easing.inOutQuad})
               itemTransID = transition.to(scene.items[i].item, {time = 150, delay = 0, xScale = 0.7*_R, yScale = 0.7*_R, easing = easing.inOutQuad, onComplete = function() scene.items[i].isSelected = false end})
            end
        end
    elseif "moved" == phase then
        
    elseif "ended" == phase then
        scene.tm = timer.performWithDelay( 200, onScrollEnded )
    end
    
    return true
end

local function createBtn(params)--(id, x, y, btnIndex, txtParams)
	local btn = AZ.ui.newTouchButton({ id = params.id, x = params.x, y = params.y, touchSound = params.touchSound or AZ.soundLibrary.buttonSound, releaseSound = params.releaseSound, txtParams = params.txtParams, btnIndex = params.btnIndex,  imageSheet = scene.myImageSheet, onTouch = onClick })
	btn:setScale(SCALE_BIG*1.2, SCALE_BIG*1.2)
	scene.Bank:insert(btn)
	return btn
end

local function noTouch(event)
	return true
end

local function currentLifesListener(event)
	scene.btnHearts.txt.text = event.lifes
end

---Funció d'inicialització
-- Aquesta funció crea tots els elements del Banc
function scene.init(info)
    
    local sc_back = display.captureScreen(false)
    sc_back.x = display.contentCenterX
    sc_back.y = display.contentCenterY
    sc_back.alpha = 0.25
	sc_back.id = "btnClose"
	sc_back:addEventListener("touch", onClick)
	sc_back.isWithinBounds = true
    scene.view:insert(sc_back)
    
    local infoSheet = require "bank.sheet.bank"
    scene.myImageSheet = graphics.newImageSheet("bank/assets/bank.png", infoSheet:getSheet())
    local bx, by
    params = info
    translate = AZ.utils.translate
    -- Creamos los layers
    scene.Bank = scene.view
    
    -- Añadimos los popups y el botón de cerrar
    scene.bankBg = display.newImage("bank/assets/bank_bg.png")
    scene.bankBg:scale(_R,_R)
    scene.bankBg.x = _W/2
    scene.bankBg.y = _H/2+30*_R
	scene.bankBg:addEventListener("touch", noTouch)
    scene.Bank:insert(scene.bankBg)
	
	scene.btnClose = createBtn({id = "btnClose", x = _W*0.5+170*_R, y = _H*0.5-215*_R, btnIndex = infoSheet:getFrameIndex("cerrar"), touchSound = AZ.soundLibrary.closePopupSound})
    
    -- Preparem element monedes disponibles
	scene.btnHearts 		= createBtn({id = "btnHearts", x = _W*0.15, y = _H*0.07, btnIndex = infoSheet:getFrameIndex("corazon"), txtParams = { text = tostring(AZ.userInfo.lifesCurrent), font = INTERSTATE_BOLD, fontSize = 24, color = AZ_DARK_RGB, x = -32, y = -3 }, touchSound = AZ.soundLibrary.heartsAccessSound})
	scene.btnShop 			= createBtn({id = "btnShop", x = _W*0.85, y = _H*0.07, btnIndex = infoSheet:getFrameIndex("boton_shop")})
	if #AZ.userInfo.shopNewItems > 0 then
		scene.btnShop.newItemsMarker = display.newImage(scene.myImageSheet, infoSheet:getFrameIndex("alert_shop"), -30, -30)
		scene.btnShop:insert(scene.btnShop.newItemsMarker)
		scene.btnShop.newItemsLabel = display.newText({ text = tostring(#AZ.userInfo.shopNewItems), font = INTERSTATE_BOLD, fontSize = 20, x = -30, y = -31 })
		scene.btnShop.newItemsLabel:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
		scene.btnShop:insert(scene.btnShop.newItemsLabel)
	end
	scene.btnBank 			= createBtn({id = "btnClose", x = _W*0.5, y = _H*0.073, btnIndex = infoSheet:getFrameIndex("coin"), txtParams = { text = AZ.utils.coinFormat(AZ.userInfo.money), font = INTERSTATE_BOLD, fontSize = 22, color = AZ_DARK_RGB, x = -30, y = -5 }, touchSound = AZ.soundLibrary.closePopupSound})
    
    --Element nom del popup
    scene.txtTitle = addText("txtTitle", translate("bank"), {r =0 , g =0 , b =0 , a = 0.4 }, INTERSTATE_BOLD, _W/2, _H/2-170*_R, 30)
    
    --Element descripcció producte
    scene.txtItemName = addText("nomItem", "Nom Item", {r = 0, g = 0, b = 0, a = 0.7 }, INTERSTATE_BOLD, _W/2-180*_R, _H/2+45*_R, 35)
    scene.txtItemName.anchorX = 0
    scene.txtItemDescription = display.newText({text = "Aquest item fa tal cosa i tal altra", x = _W/2-180*_R, y = _H/2+65*_R, width = scene.bankBg.contentWidth*0.9, font = INTERSTATE_REGULAR, fontSize = 25*_R, align = "left"})
	scene.txtItemDescription:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
	scene.txtItemDescription.name = "descripcioItem"
    scene.txtItemDescription.anchorX = 0
    scene.txtItemDescription.anchorY = 0
	scene.Bank:insert(scene.txtItemDescription)
    
	--Boto de comprar monedes
	scene.btnBuyGrp = display.newGroup()
	
    by = _H/2+220*_R
    scene.btnBuy = AZ.ui.newEnhancedButton2(
    {
		sound = AZ.soundLibrary.buttonSound,
        id = "btnBuy",
        myImageSheet = scene.myImageSheet,
        unpressedIndex = infoSheet:getFrameIndex("boton"),
        pressedIndex = infoSheet:getFrameIndex("boton_press"),
        x = 0,
        y = 0,
        onEvent = onClick
    }
    )
    scene.btnBuy:scale(_R,_R)
	scene.btnBuyGrp:insert(scene.btnBuy)
	
	--Moneda del boto
	scene.btnBuyCoin = display.newImage(scene.myImageSheet, infoSheet:getFrameIndex("ic_moneda"), -scene.btnBuy.contentWidth*0.2, -25*_R)
	scene.btnBuyCoin:scale(_R*0.5,_R*0.5)
	scene.btnBuyGrp:insert(scene.btnBuyCoin)
	
	--Afegim l'efecte de brillantor al boto de comprar monedes
	scene.bars = display.newGroup()
	local bar1 = display.newRect(0, 0, scene.btnBuy.contentWidth, 4)
	local bar2 = display.newRect(0, 30, scene.btnBuy.contentWidth, 25)
	scene.bars:insert(bar1)
	scene.bars:insert(bar2)
	scene.bars.alpha = 0.5
	scene.bars.anchorChildren = true
	scene.bars.anchorX, scene.bars.anchorY = 0.5, 0.5
	scene.bars.x, scene.bars.y = 0, 0
	scene.bars:rotate(-45)
	scene.btnBuyGrp:insert(scene.bars)
	
	scene.btnBuyGrp:translate(_W*0.5, by)
	
	--Afegim la mascara per el boto de comprar monedes
	local btnMask = graphics.newMask("bank/assets/mascara_bot.png")
	scene.btnBuyGrp:setMask(btnMask)
	scene.btnBuyGrp.maskX, scene.btnBuyGrp.maskY = 0, 0
	scene.btnBuyGrp.maskScaleX, scene.btnBuyGrp.maskScaleY = _R, _R
	
    scene.Bank:insert(scene.btnBuyGrp)
	
	--Efecte d'ombra del boto de comprar monedes
	scene.btnBuyShadow = display.newImage(scene.myImageSheet, infoSheet:getFrameIndex("boton_sombra"))
	scene.btnBuyShadow:scale(_R, _R)
	scene.btnBuyShadow.x, scene.btnBuyShadow.y = scene.btnBuyGrp.x, scene.btnBuyGrp.y
	scene.Bank:insert(scene.btnBuyShadow)
	
	--Afegim l'estrelleta que es mostrara al final de l'animacio de brillantor metal·lica
	scene.littleShine = display.newImage(scene.myImageSheet, infoSheet:getFrameIndex("brillo_pq"))
	scene.littleShine:scale(_R, _R)
	scene.littleShine.alpha = 0
	scene.littleShine.xScale, scene.littleShine.yScale = 0.001, 0.001
	scene.Bank:insert(scene.littleShine)
	scene.littleShine.x, scene.littleShine.y = scene.btnBuyGrp.x+scene.btnBuy.contentWidth*0.45, scene.btnBuyGrp.y+scene.btnBuy.contentHeight*0.35
	
    scene.txtBooster = addText("txtBooster", "", {r = 0, g = 0, b = 0, a = 0.7 }, INTERSTATE_BOLD, _W/2, by-20*_R, 40)
    scene.txtPriceBooster = addText("txtPriceBooster", "", {r = 0, g = 0, b = 0, a = 0.7 }, INTERSTATE_REGULAR, _W/2, by + 30*_R, 30)
	
    --- Elements del selector d'items
    -- És l'ScrollView que contindrà l'array d'items    
    scene.scrollItems = widget.newScrollView
    {
        width = _W,
        height = _iconHeight*1.5,
        scrollWidth = (_W/5)*19 + _iconWidth,
        scrollHeight = _iconHeight,
        leftPadding = _iconWidth*1.5,
        rightPadding = _iconWidth*2.5,
        friction = 0.9,
        hideBackground = true,
        verticalScrollDisabled = true,
        hideScrollBar = true,
        listener = scrollListener,
        isBounceEnabled = true,
    }
    scene.Bank:insert(scene.scrollItems)
    scene.scrollItems.anchorX = 0
    scene.scrollItems.anchorY = 0
    scene.scrollItems.x = 0
    scene.scrollItems.y = _H/2-155*_R
    
	local numItem = 1
	
    for i=1,#scene.infoItems do
		
		if scene.infoItems[i].itemName ~= "facebook" and scene.infoItems[i].itemName ~= "twitter" and scene.infoItems[i].isValid then
			scene.items[numItem] = display.newGroup()
			scene.items[numItem].shine1 = bitmap(scene.myImageSheet, infoSheet:getFrameIndex("brillo1"), 0, 0)
			scene.items[numItem].shine1.alpha = 0
			scene.items[numItem].shine1.xScale, scene.items[i].shine1.yScale = 1.6*_R, 1.6*_R
			scene.items[numItem].shine2 = bitmap(scene.myImageSheet, infoSheet:getFrameIndex("brillo2"), 0, 0)
			scene.items[numItem].shine2.alpha = 0
			scene.items[numItem].shine2.xScale, scene.items[i].shine2.yScale = 1.6*_R, 1.6*_R
			scene.items[numItem].item = display.newImage(scene.myImageSheet, infoSheet:getFrameIndex(scene.infoItems[i].itemName), 0, 0)
			scene.items[numItem].item:scale(_R,_R)
			scene.items[numItem].isSelected = false
			scene.items[numItem].info = scene.infoItems[i]
			scene.items[numItem].item.xScale, scene.items[numItem].item.yScale = 0.8*_R, 0.8*_R
			scene.items[numItem]:addEventListener("touch", clickOnItem)
			scene.items[numItem]:insert(scene.items[i].shine1)
			scene.items[numItem]:insert(scene.items[i].shine2)
			scene.items[numItem]:insert(scene.items[i].item)
			scene.items[numItem].x = (_W/5)*(1+((2)*(numItem-1)))
			scene.items[numItem].y = _iconHeight*0.75
			scene.scrollItems:insert(scene.items[numItem])
			numItem = numItem + 1
		end
    end
    
    local mask = graphics.newMask("bank/assets/mascara.png")
    scene.scrollItems:setMask(mask)
    scene.scrollItems.maskScaleX = _R
    scene.scrollItems.maskScaleY = _R
    scene.scrollItems.maskX = 0
    scene.scrollItems.maskY = _H/2-135*_R
    scene.scrollItems.isHitTestMasked = false
    
    selectItem(1)
    scene.scrollItems:scrollToPosition({x=(-scene.items[1].x)+_W*0.5, time = 0})
end

function scene:createScene(event)
	
	AZ.audio.playBSO(AZ.soundLibrary.menuLoop)
	
    scene.init(event.params)
	Runtime:addEventListener(RECOVERED_LIFES_EVNAME, currentLifesListener)
end

function scene:exitScene(event)
	
	cancelItemTransition()
	cancelBtnShineTransition()

	for i = 1, #scene.items do
        Runtime:removeEventListener("enterFrame", rotateLeft)
        Runtime:removeEventListener("enterFrame", rotateRight)
    end
    
	if scene.jsonChanged then
        AZ:saveData()
		scene.jsonChanged = false
	end
	
	Runtime:removeEventListener(RECOVERED_LIFES_EVNAME, currentLifesListener)
end

function scene:overlayEnded(event)
	currentLifesListener({lifes = AZ.userInfo.lifesCurrent})
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener("createScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("overlayEnded", scene)

return scene

