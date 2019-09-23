require "config"
local widget = require "widget"
local easing = require "easing"

local scene = AZ.S.newScene()

scene.Shop = {}

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
local deltaTimeLeft = 0
local deltaTimeRight = 0

scene.txtTitle = nil
scene.btnClose = nil
scene.btnBank = {}
scene.txtWeaponName = nil
scene.txtWeaponDescription = nil
scene.btnBooster1 = {}
scene.btnBooster2 = {}
scene.btnBooster3 = {}
scene.txtBooster = nil
scene.jsonChanged = false
local xBooster = { _W/2-125*_R, _W/2, _W/2+125*_R }
scene.txtPriceBooster = nil
local xPriceBooster = { (_W/2-125*_R)+17*_R, (_W/2)+17*_R, (_W/2+125*_R)+17*_R }
local booster = nil
local weaponTransID, shine1TransID, shine2TransID, timerID, shineTransID, shineTimerID, breakTrans1, breakTrans2, breakTrans3, breakTransID, unlockTransID, unlockTimerID = nil
local hasToWait = false --Variable per controlar la diferencia de temps entre les transicions de brillo del botons

-- Creem les variables que contindran les armes a vendre
scene.scrollWeapons = nil
scene.weapons = nil

---Carreguem el json que conté la informació de les armes de la Shop
scene.infoWeapons = nil

--- Funció per cancelar les transicions que puguin tenir les armes de l'scroll
local function cancelWeaponTransition()
	weaponTransID = transition.safeCancel(weaponTransID)
	shine1TransID = transition.safeCancel(shine1TransID)
	shine2TransID = transition.safeCancel(shine2TransID)
	unlockTransID = transition.safeCancel(unlockTransID)
	unlockTimerID = timer.safeCancel(unlockTimerID)
end

local function cancelBtnShineTransition()
	
	shineTransID = transition.safeCancel(shineTransID)
	shineTimerID = timer.safeCancel(shineTimerID)
	
	scene.bars.alpha = 0
	scene.littleShine.alpha = 0
	scene.littleShine.xScale, scene.littleShine.yScale = 0.001, 0.001
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
    for i = 1, #scene.weapons do
        if scene.weapons[i].isSelected == true then
            scene.weapons[i].shine1:rotate(rotation)
        end
    end
end

local function rotateLeft()
    local rotation = -25 * getDeltaTimeLeft()
    for i = 1, #scene.weapons do
        if scene.weapons[i].isSelected == true then
            scene.weapons[i].shine2:rotate(rotation)
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
			shineTimerID = timer.safePerformWithDelay(shineTimerID, 500, shine)
		end
	end
	
	local function continueShine()
		shineTransID = transition.safeCancel(shineTransID)
		shineTransID = transition.to(scene.bars, {time = 150, alpha = 0.8, x = 64*_R, y = 73.5*_R, xScale = 0.01, yScale = 0.01, onComplete =  littleShine})
	end
	scene.bars.xScale, scene.bars.yScale = 1, 1
	scene.bars.alpha = 0.5
	scene.bars.x, scene.bars.y = 0, 0
	shineTransID = transition.safeCancel(shineTransID)
	shineTransID = transition.from(scene.bars, {time = 150, alpha = 0.2, x = -64*_R, y = -73.5*_R, xScale = 0.01, yScale = 0.01, onComplete = continueShine})
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

--Funcio per amagar tots els botons
local function hideAllBoosterBtns()
	scene.btnBooster1.blocked.isVisible = false
    scene.btnBooster1.unblocked.isVisible = false
    scene.btnBooster1.acquired.isVisible = false
    scene.btnBooster2.blocked.isVisible = false
    scene.btnBooster2.unblocked.isVisible = false
    scene.btnBooster2.acquired.isVisible = false
    scene.btnBooster3.blocked.isVisible = false
    scene.btnBooster3.unblocked.isVisible = false
    scene.btnBooster3.acquired.isVisible = false
	scene.btnBooster1Shadow.isVisible = false
	scene.btnBooster2Shadow.isVisible = false
	scene.btnBooster3Shadow.isVisible = false
	scene.btnBoosterBroken.isVisible = false
	scene.btnBoosterBroken.isHitTestable = false
end

--- Funció selectWeapon
--Aquesta funció ens permet fer visibles els botons correctes i amagar els que
--no s'han de veure. A més a més ens permet canviar la informació donada per pantalla
--per a cada arma. Això inclou la descripció, el nom i el preu i quantitat dels
--boosters.
local function selectWeapon(num)
    
    --Canviem la visibilitat de l'arma dins l'scrollView
	cancelWeaponTransition()
	cancelBtnShineTransition()
    for i=1, #scene.weapons do
        if scene.weapons[i].isSelected == true and not (i == num)  then
			if not scene.weapons[i].isBlocked then
				shine1TransID = transition.to(scene.weapons[i].shine1, {time = 150, delay = 25, alpha = 0, xScale = 0.0001*_R, yScale = 0.0001*_R, easing = easing.inOutQuad, onComplete = function() Runtime:removeEventListener("enterFrame", rotateLeft); Runtime:removeEventListener("enterFrame", rotateRight) end})
				shine2TransID = transition.to(scene.weapons[i].shine2, {time = 150, delay = 25, alpha = 0, xScale = 0.0001*_R, yScale = 0.0001*_R, easing = easing.inOutQuad})
			end
            weaponTransID = transition.to(scene.weapons[i].weapon, {time = 150, delay = 25, xScale = 0.7*_R, yScale = 0.7*_R, easing = easing.inOutQuad, onComplete = function() scene.weapons[i].isSelected = false end})
        end
    end
    
    --Ocultem tots els botons per després tinir més fàcil el mostrar-los
    hideAllBoosterBtns()
    
    --Seleccionem l'element a l'scrollView   
    weaponTransID = transition.to(scene.weapons[num].weapon, {time = 300, delay = 200, xScale = _R, yScale = _R, easing = easing.inOutQuad, onStart = function() scene.weapons[num].isSelected = true end})
	if not scene.weapons[num].isBlocked then
		shine1TransID = transition.to(scene.weapons[num].shine1, {time = 300, delay = 200, alpha = 1, xScale = 1.6*_R, yScale = 1.6*_R, easing = easing.inOutQuad, onStart = function() Runtime:addEventListener("enterFrame", rotateLeft); Runtime:addEventListener("enterFrame", rotateRight) end})
		shine2TransID = transition.to(scene.weapons[num].shine2, {time = 300, delay = 200, alpha = 1, xScale = 1.6*_R, yScale = 1.6*_R, easing = easing.inOutQuad})
	end
    scene.txtWeaponName.text = translate(AZ.shopInfo.shop.weapons[num].name)
    scene.txtWeaponDescription.text = translate(AZ.shopInfo.shop.weapons[num].description)
    --En el cas que sigui el booster de cors ho comprovem
    if scene.weapons[num].name == "extraLifes" then
        if AZ.userInfo.lifesMax == 5 then
            booster = 1
            scene.txtPriceBooster.text = AZ.shopInfo.shop.weapons[num].boosterData[1].price
            scene.txtPriceBooster.isVisible = true
            scene.txtPriceBooster.x = xPriceBooster[2]
            scene.txtBooster.text = "+"..AZ.shopInfo.shop.weapons[num].boosterData[1].quantity
            scene.txtBooster.isVisible = true
            scene.txtBooster.x = xBooster[2]
            scene.btnBooster2.unblocked.isVisible = true
			scene.btnBooster2:insert(scene.bars)
			scene.littleShine.x, scene.littleShine.y = scene.btnBooster2.x+45*_R, scene.btnBooster2.y+53*_R
			hasToWait = false
			shineTimerID = timer.safePerformWithDelay(shineTimerID, 500, barsShine)
        else
            scene.txtPriceBooster.isVisible = false
            scene.txtBooster.isVisible = false
            scene.btnBooster2.acquired.isVisible = true
        end
		scene.btnBooster2Shadow.isVisible = true
    else--sinó hem de comprovar si està desbloquejat o no i en el cas que ho estigui quins boosters s'han comprat i quins no
        if not scene.weapons[num].isBlocked then
			for i = 1, #AZ.userInfo.weapons do
				if AZ.userInfo.weapons[i].name == scene.weapons[num].name then
					if AZ.userInfo.weapons[i].boughtLevel < 3 then
						scene.txtPriceBooster.isVisible = true
						scene.txtBooster.isVisible = true
						scene.txtBooster.text = "+"..AZ.shopInfo.shop.weapons[num].boosterData[AZ.userInfo.weapons[i].boughtLevel + 1].quantity
						scene.txtPriceBooster.text = AZ.shopInfo.shop.weapons[num].boosterData[AZ.userInfo.weapons[i].boughtLevel + 1].price
						scene.txtPriceBooster.x = xPriceBooster[AZ.userInfo.weapons[i].boughtLevel + 1]
						scene.txtBooster.x = xBooster[AZ.userInfo.weapons[i].boughtLevel + 1]
						if AZ.userInfo.weapons[i].boughtLevel == 0 then
							scene.btnBooster1.unblocked.isVisible = true
							scene.btnBooster1:insert(scene.bars)
							scene.littleShine.x, scene.littleShine.y = scene.btnBooster1.x+45*_R, scene.btnBooster1.y+53*_R
							hasToWait = false
							shineTimerID = timer.safePerformWithDelay(shineTimerID, 500, barsShine)
							scene.btnBooster2.unblocked.isVisible = true
							scene.btnBoosterBroken.ressetBtn()
							scene.btnBoosterBroken.isVisible = true
							scene.btnBoosterBroken.x, scene.btnBoosterBroken.y = scene.btnBooster2.x, scene.btnBooster2.y
							scene.btnBoosterBroken.isHitTestable = true
							scene.btnBooster3.blocked.isVisible = true
						elseif AZ.userInfo.weapons[i].boughtLevel == 1 then
							scene.btnBooster1.acquired.isVisible = true
							scene.btnBooster2.unblocked.isVisible = true
							scene.btnBooster2:insert(scene.bars)
							scene.littleShine.x, scene.littleShine.y = scene.btnBooster2.x+45*_R, scene.btnBooster2.y+53*_R
							hasToWait = false
							shineTimerID = timer.safePerformWithDelay(shineTimerID, 500, barsShine)
							scene.btnBooster3.unblocked.isVisible = true
							scene.btnBoosterBroken.ressetBtn()
							scene.btnBoosterBroken.isVisible = true
							scene.btnBoosterBroken.x, scene.btnBoosterBroken.y = scene.btnBooster3.x, scene.btnBooster3.y
							scene.btnBoosterBroken.isHitTestable = true
						elseif AZ.userInfo.weapons[i].boughtLevel == 2 then
							scene.btnBooster1.acquired.isVisible = true
							scene.btnBooster2.acquired.isVisible = true
							scene.btnBooster3.unblocked.isVisible = true
							scene.btnBooster3:insert(scene.bars)
							scene.littleShine.x, scene.littleShine.y = scene.btnBooster3.x+45*_R, scene.btnBooster3.y+53*_R
							hasToWait = false
							shineTimerID = timer.safePerformWithDelay(shineTimerID, 500, barsShine)
						end
					else
						scene.txtPriceBooster.isVisible = false
						scene.txtBooster.isVisible = false
						scene.btnBooster1.acquired.isVisible = true
						scene.btnBooster2.acquired.isVisible = true
						scene.btnBooster3.acquired.isVisible = true                
					end
				end
			end
        else
            scene.txtPriceBooster.isVisible = false
            scene.txtBooster.isVisible = false
            scene.btnBooster1.blocked.isVisible = true
            scene.btnBooster2.blocked.isVisible = true
            scene.btnBooster3.blocked.isVisible = true
        end
		scene.btnBooster1Shadow.isVisible = true
		scene.btnBooster2Shadow.isVisible = true
		scene.btnBooster3Shadow.isVisible = true
    end
end

local function selectAndSimulatePurchase(num)
	
	--Canviem la visibilitat de l'arma dins l'scrollView
	cancelWeaponTransition()
	cancelBtnShineTransition()
    for i=1, #scene.weapons do
        if scene.weapons[i].isSelected == true then
			if not scene.weapons[i].isBlocked then
				shine1TransID = transition.to(scene.weapons[i].shine1, {time = 150, delay = 25, alpha = 0, xScale = 0.0001*_R, yScale = 0.0001*_R, easing = easing.inOutQuad, onComplete = function() Runtime:removeEventListener("enterFrame", rotateLeft); Runtime:removeEventListener("enterFrame", rotateRight) end})
				shine2TransID = transition.to(scene.weapons[i].shine2, {time = 150, delay = 25, alpha = 0, xScale = 0.0001*_R, yScale = 0.0001*_R, easing = easing.inOutQuad})
			end
            weaponTransID = transition.to(scene.weapons[i].weapon, {time = 150, delay = 25, xScale = 0.7*_R, yScale = 0.7*_R, easing = easing.inOutQuad, onComplete = function() scene.weapons[i].isSelected = false end})
        end
    end
	
	--Ocultem tots els botons per després tinir més fàcil el mostrar-los
	hideAllBoosterBtns()
	
	--Seleccionem l'element a l'scrollView
	timerID = timer.performWithDelay(80*num, function()
		weaponTransID = transition.to(scene.weapons[num].weapon, {time = 300, delay = 200, xScale = _R, yScale = _R, easing = easing.inOutQuad, onStart = function() Runtime:addEventListener("enterFrame", rotateLeft); Runtime:addEventListener("enterFrame", rotateRight); scene.weapons[num].isSelected = true end})
		shine1TransID = transition.to(scene.weapons[num].shine1, {time = 300, delay = 200, alpha = 1, xScale = 1.6*_R, yScale = 1.6*_R, easing = easing.inOutQuad})
		shine2TransID = transition.to(scene.weapons[num].shine2, {time = 300, delay = 200, alpha = 1, xScale = 1.6*_R, yScale = 1.6*_R, easing = easing.inOutQuad})
	end)
	scene.txtWeaponName.text = translate(AZ.shopInfo.shop.weapons[num].name)
	scene.txtWeaponDescription.text = translate(AZ.shopInfo.shop.weapons[num].description)
	
	for i = 1, #AZ.userInfo.weapons do
		if AZ.userInfo.weapons[i].name == scene.weapons[num].name then
			if AZ.userInfo.weapons[i].boughtLevel <= 3 then
				scene.txtPriceBooster.isVisible = true
				scene.txtBooster.isVisible = true
				scene.txtBooster.text = "+"..AZ.shopInfo.shop.weapons[num].boosterData[AZ.userInfo.weapons[i].boughtLevel].quantity
				scene.txtPriceBooster.text = AZ.shopInfo.shop.weapons[num].boosterData[AZ.userInfo.weapons[i].boughtLevel].price
				scene.txtPriceBooster.x = xPriceBooster[AZ.userInfo.weapons[i].boughtLevel]
				scene.txtBooster.x = xBooster[AZ.userInfo.weapons[i].boughtLevel]
				if AZ.userInfo.weapons[i].boughtLevel-1 == 0 then
					scene.btnBooster1.unblocked.isVisible = true
					scene.btnBooster1:insert(scene.bars)
					scene.littleShine.x, scene.littleShine.y = scene.btnBooster1.x+45*_R, scene.btnBooster1.y+53*_R
					hasToWait = false
					shineTimerID = timer.safePerformWithDelay(shineTimerID, 500, barsShine)
					scene.btnBooster2.unblocked.isVisible = true
					scene.btnBoosterBroken.ressetBtn()
					scene.btnBoosterBroken.isVisible = true
					scene.btnBoosterBroken.x, scene.btnBoosterBroken.y = scene.btnBooster2.x, scene.btnBooster2.y
					scene.btnBoosterBroken.isHitTestable = true
					scene.btnBooster3.blocked.isVisible = true
				elseif AZ.userInfo.weapons[i].boughtLevel-1 == 1 then
					scene.btnBooster1.acquired.isVisible = true
					scene.btnBooster2.unblocked.isVisible = true
					scene.btnBooster2:insert(scene.bars)
					scene.littleShine.x, scene.littleShine.y = scene.btnBooster2.x+45*_R, scene.btnBooster2.y+53*_R
					hasToWait = false
					shineTimerID = timer.safePerformWithDelay(shineTimerID, 500, barsShine)
					scene.btnBooster3.unblocked.isVisible = true
					scene.btnBoosterBroken.ressetBtn()
					scene.btnBoosterBroken.isVisible = true
					scene.btnBoosterBroken.x, scene.btnBoosterBroken.y = scene.btnBooster3.x, scene.btnBooster3.y
					scene.btnBoosterBroken.isHitTestable = true
				elseif AZ.userInfo.weapons[i].boughtLevel-1 == 2 then
					scene.btnBooster1.acquired.isVisible = true
					scene.btnBooster2.acquired.isVisible = true
					scene.btnBooster3.unblocked.isVisible = true
					scene.btnBooster3:insert(scene.bars)
					scene.littleShine.x, scene.littleShine.y = scene.btnBooster3.x+45*_R, scene.btnBooster3.y+53*_R
					hasToWait = false
					shineTimerID = timer.safePerformWithDelay(shineTimerID, 500, barsShine)
				end
			else
				scene.txtPriceBooster.isVisible = false
				scene.txtBooster.isVisible = false
				scene.btnBooster1.acquired.isVisible = true
				scene.btnBooster2.acquired.isVisible = true
				scene.btnBooster3.acquired.isVisible = true                
			end
			scene.btnBooster1Shadow.isVisible = true
			scene.btnBooster2Shadow.isVisible = true
			scene.btnBooster3Shadow.isVisible = true
		end
	end
	
	timerID = timer.performWithDelay(80*num, function()
		scene.btnBoosterBroken.breakBtn()
		cancelBtnShineTransition()
		for i = 1, #AZ.userInfo.weapons do
			if AZ.userInfo.weapons[i].name == scene.weapons[num].name then
				if AZ.userInfo.weapons[i].boughtLevel == 1 then
					scene.txtBooster.text = "+"..AZ.shopInfo.shop.weapons[num].boosterData[AZ.userInfo.weapons[i].boughtLevel + 1].quantity
					scene.txtPriceBooster.text = AZ.shopInfo.shop.weapons[num].boosterData[AZ.userInfo.weapons[i].boughtLevel + 1].price
					scene.txtPriceBooster.x = xPriceBooster[AZ.userInfo.weapons[i].boughtLevel + 1]
					scene.txtBooster.x = xBooster[AZ.userInfo.weapons[i].boughtLevel + 1]
					scene.btnBooster1.unblocked.isVisible = false
					scene.btnBooster1.acquired.isVisible = true
				elseif AZ.userInfo.weapons[i].boughtLevel == 2 then
					scene.txtBooster.text = "+"..AZ.shopInfo.shop.weapons[num].boosterData[AZ.userInfo.weapons[i].boughtLevel + 1].quantity
					scene.txtPriceBooster.text = AZ.shopInfo.shop.weapons[num].boosterData[AZ.userInfo.weapons[i].boughtLevel + 1].price
					scene.txtPriceBooster.x = xPriceBooster[AZ.userInfo.weapons[i].boughtLevel + 1]
					scene.txtBooster.x = xBooster[AZ.userInfo.weapons[i].boughtLevel + 1]
					scene.btnBooster2.unblocked.isVisible = false
					scene.btnBooster2.acquired.isVisible = true
				end
			end
		end
		unlockTimerID = timer.performWithDelay(1650, function() params.prizeName = nil; selectWeapon(num); scene.noTouchLayer.isHitTestable = false end)
	end )
--	timerID = timer.performWithDelay(150*num, function() params.prizeName = nil; selectWeapon(num); scene.noTouchLayer.isHitTestable = false end)
	
end

--Funcio que deixa definitivament una arma desbloquejada
local function setUnlocked(num)
	for i = 1, #AZ.userInfo.shopNewItems do
		if AZ.userInfo.shopNewItems[i] == scene.weapons[num].name then
			table.remove(AZ.userInfo.shopNewItems, i)
		end
	end
	for i = 1, #AZ.userInfo.weapons do
		if AZ.userInfo.weapons[i].name == scene.weapons[num].name then
			AZ.userInfo.weapons[i].isBlocked = false
			scene.weapons[num].isBlocked = false
			scene.jsonChanged = true
		end
	end
	
	if #AZ.userInfo.shopNewItems < 1 then
		display.remove(scene.btnShop.newItemsLabel)
		display.remove(scene.btnShop.newItemsMarker)
	else
		scene.btnShop.newItemsLabel.text = tostring(#AZ.userInfo.shopNewItems)
	end
	
	
	if params.prizeName then
		selectAndSimulatePurchase(num)
	else
		scene.noTouchLayer.isHitTestable = false
		selectWeapon(num)
	end
end

--Funcio de desbloqueix d'una arma
local function unlockWeapon(num)
	--Canviem la visibilitat de l'arma dins l'scrollView
	cancelWeaponTransition()
	cancelBtnShineTransition()
    for i=1, #scene.weapons do
        if scene.weapons[i].isSelected == true then
			if not scene.weapons[i].isBlocked then
				shine1TransID = transition.to(scene.weapons[i].shine1, {time = 150, delay = 25, alpha = 0, xScale = 0.0001*_R, yScale = 0.0001*_R, easing = easing.inOutQuad, onComplete = function() Runtime:removeEventListener("enterFrame", rotateLeft); Runtime:removeEventListener("enterFrame", rotateRight) end})
				shine2TransID = transition.to(scene.weapons[i].shine2, {time = 150, delay = 25, alpha = 0, xScale = 0.0001*_R, yScale = 0.0001*_R, easing = easing.inOutQuad})
			end
            weaponTransID = transition.to(scene.weapons[i].weapon, {time = 150, delay = 25, xScale = 0.7*_R, yScale = 0.7*_R, easing = easing.inOutQuad, onComplete = function() scene.weapons[i].isSelected = false end})
        end
    end
    
    --Ocultem tots els botons per després tinir més fàcil el mostrar-los
    hideAllBoosterBtns()
	scene.txtWeaponName.text = translate(AZ.shopInfo.shop.weapons[num].name)
    scene.txtWeaponDescription.text = translate(AZ.shopInfo.shop.weapons[num].description)
	scene.txtPriceBooster.isVisible = true
	scene.txtBooster.isVisible = true
	scene.txtBooster.text = "+"..AZ.shopInfo.shop.weapons[num].boosterData[1].quantity
	scene.txtPriceBooster.text = AZ.shopInfo.shop.weapons[num].boosterData[1].price
	scene.txtPriceBooster.x = xPriceBooster[1]
	scene.txtBooster.x = xBooster[1]
	
	weaponTransID = transition.to(scene.weapons[num].weapon, {time = 300, delay = 200, xScale = _R, yScale = _R, easing = easing.inOutQuad, onStart = function() scene.weapons[num].isSelected = true end })
	
	scene.btnBoosterBroken.ressetBtn()
	scene.btnBoosterBroken.isVisible = true
	scene.btnBoosterBroken.x, scene.btnBoosterBroken.y = scene.btnBooster1.x, scene.btnBooster1.y
	scene.btnBoosterBroken.isHitTestable = true
    scene.btnBooster1.unblocked.isVisible = true
    scene.btnBooster2.blocked.isVisible = true
    scene.btnBooster3.blocked.isVisible = true
	scene.btnBooster1Shadow.isVisible = true
	scene.btnBooster2Shadow.isVisible = true
	scene.btnBooster3Shadow.isVisible = true
	
	unlockTransID = AZ.utils.colorTransition(scene.weapons[num].weapon, {0.25, 0.25, 0.25}, {1, 1, 1}, {time = 1000})
	unlockTimerID = timer.performWithDelay(700, function() 
			scene.btnBoosterBroken.breakBtn()
			shine1TransID = transition.to(scene.weapons[num].shine1, {time = 300, alpha = 1, xScale = 1.6*_R, yScale = 1.6*_R, easing = easing.inOutQuad, onStart = function() Runtime:addEventListener("enterFrame", rotateLeft); Runtime:addEventListener("enterFrame", rotateRight) end})
			shine2TransID = transition.to(scene.weapons[num].shine2, {time = 300, alpha = 1, xScale = 1.6*_R, yScale = 1.6*_R, easing = easing.inOutQuad, onComplete = function() unlockTimerID = timer.performWithDelay(750, function() setUnlocked(num) end) end})
		end)
end

--Funcio que comprova que una arma s'ha de desbloquejar
local function checkUnlock(num)
	local unlock = false
	
	if #AZ.userInfo.shopNewItems > 0 then
		for i = 1, #AZ.userInfo.shopNewItems do
			if AZ.userInfo.shopNewItems[i] == scene.weapons[num].name then
				unlock = true
			end
		end
	end
	
	return unlock
end

local function scrollToWeapon(num, isFirstTime)
	
	local transTime = nil
	
	if isFirstTime then
		transTime = 200*(num-1)
		scene.scrollWeapons:scrollToPosition({x=(-scene.weapons[num].x)+_W*0.5, time = 200*(num-1)})
	else
		transTime = 350
		scene.scrollWeapons:scrollToPosition({x=(-scene.weapons[num].x)+_W*0.5, time = 350})
	end
    if scene.weapons[num].isSelected == false then
		if params.prizeName then
			if checkUnlock(num) then
				scene.noTouchLayer.isHitTestable = true
				timerID = timer.safePerformWithDelay(timerID, transTime, function() unlockWeapon(num) end)
			else
				timerID = timer.safePerformWithDelay(timerID, transTime, function() selectAndSimulatePurchase(num) end)
			end
		else
			if checkUnlock(num) then
				scene.noTouchLayer.isHitTestable = true
				timerID = timer.safePerformWithDelay(timerID, transTime, function() unlockWeapon(num) end)
			else
				selectWeapon(num)
			end
		end
    end
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

local function clickOnWeapon(event)
    if event.phase == "moved" then
        local dx = math.abs( event.x - event.xStart )
        local dy = math.abs( event.y - event.yStart )
        
        if dx > 5 or dy > 5 then
            if startedPointInRect(event, event.target) then
                scene.scrollWeapons:takeFocus( event )
            end
        end  
    
    elseif event.phase == "ended" and startedPointInRect(event, event.target) then
        local target = event.target
        scrollToWeapon(target.num, false)
    end
 
    return true
end

--- Funció buyWeapons
--Amb aquesta funció fem les comprovacions necessàries abans de comprar un booster
--i, en el cas que es compleixin, procedim amb la compra
local function buyWeapons()
    local weapon
    local price
    local quantity
    local i = 0
    local found = false
    local throwNoMoney = false
    local throwNeedMoney = false
    
    while found == false and i<#scene.weapons do
        i = i+1
        if scene.weapons[i].isSelected == true then
            found = true 
            weapon = i
            if scene.weapons[weapon].name == "extraLifes" then
                price = AZ.shopInfo.shop.weapons[i].boosterData[1].price
                quantity = AZ.shopInfo.shop.weapons[i].boosterData[1].quantity
            else
                price = AZ.shopInfo.shop.weapons[i].boosterData[AZ.userInfo.weapons[i+1].boughtLevel + 1].price
                quantity = AZ.shopInfo.shop.weapons[i].boosterData[AZ.userInfo.weapons[i+1].boughtLevel + 1].quantity
            end
        end
    end
	
	if scene.weapons[weapon].name == "extraLifes" then
		price = AZ.shopInfo.shop.weapons[weapon].boosterData[1].price
        quantity = AZ.shopInfo.shop.weapons[weapon].boosterData[1].quantity
    else
		for i = 1, #AZ.userInfo.weapons do
			if AZ.userInfo.weapons[i].name == scene.weapons[weapon].name then
				price = AZ.shopInfo.shop.weapons[weapon].boosterData[AZ.userInfo.weapons[i].boughtLevel + 1].price
				quantity = AZ.shopInfo.shop.weapons[weapon].boosterData[AZ.userInfo.weapons[i].boughtLevel + 1].quantity
			end
        end
    end
	
    if _coins >= price then
        --Posem la quantitat real de booster que hi ha disponible amb la compra
        if scene.weapons[weapon].name == "extraLifes" then
            AZ.userInfo.lifesMax = quantity
        else 
			for i = 1, #AZ.userInfo.weapons do
				if AZ.userInfo.weapons[i].name == scene.weapons[weapon].name then
					AZ.userInfo.weapons[i].quantity = quantity
					AZ.userInfo.weapons[i].boughtLevel = AZ.userInfo.weapons[i].boughtLevel + 1
				end
			end
        end
        
        if not AZ.isUnlimitedCoins then
           _coins = _coins - price
        else
           _coins = 99999 
        end
        
        -- Actualitzem les monedes
        AZ.userInfo.money = _coins
        scene.btnBank.txt.text = AZ.utils.coinFormat(_coins)
        -- Actualitzem userInfo
        scene.jsonChanged = true
		if scene.btnBoosterBroken.isVisible == true then
			scene.btnBoosterBroken.breakBtn()
			cancelBtnShineTransition()
			for i = 1, #AZ.userInfo.weapons do
				if AZ.userInfo.weapons[i].name == scene.weapons[weapon].name then
					if AZ.userInfo.weapons[i].boughtLevel == 1 then
						scene.txtBooster.text = "+"..AZ.shopInfo.shop.weapons[weapon].boosterData[AZ.userInfo.weapons[i].boughtLevel + 1].quantity
						scene.txtPriceBooster.text = AZ.shopInfo.shop.weapons[weapon].boosterData[AZ.userInfo.weapons[i].boughtLevel + 1].price
						scene.txtPriceBooster.x = xPriceBooster[AZ.userInfo.weapons[i].boughtLevel + 1]
						scene.txtBooster.x = xBooster[AZ.userInfo.weapons[i].boughtLevel + 1]
						scene.btnBooster1.unblocked.isVisible = false
						scene.btnBooster1.acquired.isVisible = true
					elseif AZ.userInfo.weapons[i].boughtLevel == 2 then
						scene.txtBooster.text = "+"..AZ.shopInfo.shop.weapons[weapon].boosterData[AZ.userInfo.weapons[i].boughtLevel + 1].quantity
						scene.txtPriceBooster.text = AZ.shopInfo.shop.weapons[weapon].boosterData[AZ.userInfo.weapons[i].boughtLevel + 1].price
						scene.txtPriceBooster.x = xPriceBooster[AZ.userInfo.weapons[i].boughtLevel + 1]
						scene.txtBooster.x = xBooster[AZ.userInfo.weapons[i].boughtLevel + 1]
						scene.btnBooster2.unblocked.isVisible = false
						scene.btnBooster2.acquired.isVisible = true
					end
				end
			end
			unlockTimerID = timer.performWithDelay(1650, function() selectWeapon(weapon) end)
		else
			selectWeapon(weapon)
		end
    else
        if _coins == 0 then
            throwNoMoney = true
        else
            throwNeedMoney = true
        end
    end
    
    if throwNoMoney == true then
        direction = "bank"
        local options = {
            effect = "crossFade",
            time = 300,
            params = params,
            isModal = true
        }
        if options.params.source then
			options.params.source[#options.params.source+1] = "shop.shop"
		else
			options.params.source = {"shop.shop"}
		end
        AZ.S.showOverlay("popups.popupwomoney",options)
    elseif throwNeedMoney == true then
        local options = {
            effect = "crossFade",
            time = 300,
            params = params,
            isModal = true
        }
		if options.params.source then
			options.params.source[#options.params.source+1] = "shop.shop"
		else
			options.params.source = {"shop.shop"}
		end
        AZ.S.showOverlay("popups.popupnemoney",options)
    end
end

---Funció que afegeix l'efecte al boto banc
local function buttonEffect(button)
    local function origin()
        transition.to(button, {time = 100, xScale = _R, yScale = _R, transition = easing.outExpo})
    end
    transition.to(button, {time = 100, xScale = _R*0.8, yScale = _R*0.8, transition = easing.outExpo, onComplete = origin})
end

---Funció onClick
--Controla els events touch sobre els botons que no estan a l'escrollView de les armes
local function onClick(event)
    
    local id = nil
    local phase = event.phase
    
    --Assignem la id que rebem per paràmetres
    if event.target then
        id = event.target.id
    else
        id = event.id
    end
    
    if phase == "ended" or phase == "release" then
		--Tanquem la botiga i tornem a l'scene anterior
        if event.isBackKey or (id == "btnClose" and event.target.isWithinBounds) then
            Runtime:removeEventListener("enterFrame", rotateLeft)
            Runtime:removeEventListener("enterFrame", rotateRight)
            local options = {
                effect = "crossFade",
                time = 300,
                params = params
            }
			direction = params.source[#params.source]
			options.params.source[#options.params.source] = nil
			AZ.S.gotoScene(direction, options)
        end
        --Accedim al Banc passant-li tant l'scene anterior a la botiga com la mateixa
        --botiga.
        if id == "btnBank" and event.target.isWithinBounds then
            Runtime:removeEventListener("enterFrame", rotateLeft)
            Runtime:removeEventListener("enterFrame", rotateRight)
            direction = "bank"
			local options = {
				effect = "crossFade",
				time = 250,
				params = params
			}
			if options.params.source then
				if options.params.source[#options.params.source] == "bank.bank" then
					options.params.source[#options.params.source] = nil
				else
					options.params.source[#options.params.source+1] = "shop.shop"
				end
			else
				options.params.source = { "shop.shop" }
			end
			
			AZ.S.gotoScene("bank.bank", options)
        end
		if id == "btnHearts" and event.target.isWithinBounds then
			local options = {
                effect = "crossFade",
                time = 1000,
                isModal = true
            }
            AZ.S.showOverlay("popups.popupwolives", options)
		end
        --En el cas que el botó sigui el de booster desbloquejat, el comprem
        if id == "unblocked" then
            buyWeapons()
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

local function addText(id,str, color, font, x, y, size)
    local t = display.newText(str, 0, 0, font, size*_R)
    t:setFillColor(color.r, color.g, color.b, color.a)
    t.x = x
    t.y = y
    t.id = id
    scene.Shop:insert(t)
    return t
end

local function onScrollEnded(event)
    
    local x = scene.scrollWeapons:getContentPosition()
	
	for i = #scene.weapons, 1, -1 do
		if i ~= 1 then
			if x <= -((scene.weapons[i-1].x+((scene.weapons[i].x-scene.weapons[i-1].x)*0.5))-_W*0.5) then
				scrollToWeapon(i, false)
				return
			end
		else
			scrollToWeapon(i, false)
		end
	end
end

--- Funció scrollListener
-- És el listener que controla el comportament de l'ScrollView, aquest hi ha de ser
-- perquè funcioni, però no cal que contingui res.

local function scrollListener( event )
   
    local phase = event.phase
    
    if "began" == phase then
        if timerID ~= nil then
            timer.cancel(timerID)
        end
		cancelWeaponTransition()
		cancelBtnShineTransition()
        --Canviem la visibilitat de l'arma dins l'scrollView
        for i=1, #scene.weapons do
            if scene.weapons[i].isSelected == true then
				if not scene.weapons[i].isBlocked then
					shine1TransID = transition.to(scene.weapons[i].shine1, {time = 175, delay = 0, alpha = 0, xScale = 0.0001*_R, yScale = 0.0001*_R, easing = easing.inOutQuad})
					shine2TransID = transition.to(scene.weapons[i].shine2, {time = 175, delay = 0, alpha = 0, xScale = 0.0001*_R, yScale = 0.0001*_R, easing = easing.inOutQuad})
				end
                weaponTransID = transition.to(scene.weapons[i].weapon, {time = 175, delay = 0, xScale = 0.7*_R, yScale = 0.7*_R, easing = easing.inOutQuad, onComplete = function() Runtime:removeEventListener("enterFrame", rotateLeft); Runtime:removeEventListener("enterFrame", rotateRight); scene.weapons[i].isSelected = false end})
            end
        end
    elseif "moved" == phase then
        
    elseif "ended" == phase then
        timerID = timer.performWithDelay( 200, onScrollEnded )
    end
    
    return true
end

local function noTouch(event)
	return true
end

local function createBtn(params)--(id, x, y, btnIndex, txtParams, touchSound, releaseSound)
	local btn = AZ.ui.newTouchButton({ id = params.id, x = params.x, y = params.y, touchSound = params.touchSound or AZ.soundLibrary.buttonSound, releaseSound = params.releaseSound, txtParams = params.txtParams, btnIndex = params.btnIndex,  imageSheet = scene.myImageSheet, onTouch = onClick })
	btn:setScale(SCALE_BIG*1.2, SCALE_BIG*1.2)
	scene.Shop:insert(btn)
	return btn
end

local function onBtnBrokenTouch(event)
	return true
end

--Funcio que ens serveix per crear el boto bloquejat que es trenca. Tambe conte els efectes de trencat
local function createBrokenButton(x, y, infoSheet)
	
	local grp = display.newGroup()
	
	grp.breakBtn = function()
		local x, y = grp.x, grp.y
		local function disapearTransition()
			breakTrans1 = transition.to(grp.img1, {time = 300, x = -3, y = 3, rotation = -2, transition = easing.outExpo, onComplete = function() breakTrans1 = transition.to(grp.img1, {time = 750, delay = 500, alpha = 0, x = -25, y = 30, rotation = 20, transition = easing.outExpo}) end })
			breakTrans2 = transition.to(grp.img2, {time = 300, x = -3, y = -3, rotation = -2, transition = easing.outExpo, onComplete = function() breakTrans2 = transition.to(grp.img2, {time = 750, delay = 500, alpha = 0, x = -20, y = -40, rotation = -40, transition = easing.outExpo}) end })
			breakTrans3 = transition.to(grp.img3, {time = 300, x = 3, y = -3, rotation = -2, transition = easing.outExpo, onComplete = function() breakTrans3 = transition.to(grp.img3, {time = 750, delay = 500, alpha = 0, x = 25, y = -20, rotation = -30, transition = easing.outExpo}) end })
		end
		math.randomseed(os.time())
		if math.random(1, 2) == 1 then
			breakTransID = transition.to(grp, {time = 100, x = x - math.random(2, 4)*_R, y = y + math.random(2, 4), iterations = 6, onComplete =  disapearTransition})
		else
			breakTransID = transition.to(grp, {time = 100, x = x + math.random(2, 4)*_R, y = y - math.random(2, 4), iterations = 6, onComplete =  disapearTransition})
		end
	end
	
	grp.ressetBtn = function()
		breakTrans1 = transition.safeCancel(breakTrans1)
		breakTrans2 = transition.safeCancel(breakTrans2)
		breakTrans3 = transition.safeCancel(breakTrans3)
		grp.img1.x, grp.img2.x, grp.img3.x = 0, 0, 0
		grp.img1.y, grp.img2.y, grp.img3.y = 0, 0, 0
		grp.img1.alpha, grp.img2.alpha, grp.img3.alpha = 1, 1, 1
		grp.img1.rotation, grp.img2.rotation, grp.img3.rotation = 0, 0, 0
	end
	
	grp.img1 = display.newImage(scene.myImageSheet, infoSheet:getFrameIndex("boton_block_roto_3"))
	grp:insert(grp.img1)
	grp.img2 = display.newImage(scene.myImageSheet, infoSheet:getFrameIndex("boton_block_roto_2"))
	grp:insert(grp.img2)
	grp.img3 = display.newImage(scene.myImageSheet, infoSheet:getFrameIndex("boton_block_roto_1"))
	grp:insert(grp.img3)
	
	grp.x, grp.y = x, y
	grp.id = "btnBroken"
	grp:scale(_R, _R)
	grp:addEventListener("touch", onBtnBrokenTouch)
	
	return grp
	
end

local function currentLifesListener(event)
	scene.btnHearts.txt.text = event.lifes
end

---Funció d'inicialització
-- Aquesta funció crea tots els elements de la Botiga
function scene.init(info)
    local sc_back = display.captureScreen(false)
    sc_back.x = display.contentCenterX
    sc_back.y = display.contentCenterY
    sc_back.alpha = 0.25
	sc_back.id = "btnClose"
	sc_back:addEventListener("touch", onClick)
	sc_back.isWithinBounds = true
    scene.view:insert(sc_back)
    
    local infoSheet = require "shop.assets.shop_sprite"
    scene.myImageSheet = graphics.newImageSheet("shop/assets/shop_sprite.png", infoSheet:getSheet())
    local bx, by

    scene.weapons = {}
    scene.btnBooster1 = {}
    scene.btnBooster2 = {}
    scene.btnBooster3 = {}
    params = info
    translate = AZ.utils.translate
    
    -- Creamos los layers
    scene.Shop = scene.view
    scene.Shop.size = 0
    
    -- Añadimos los popups y el botón de cerrar
    scene.shopBg = display.newImage("shop/assets/shop_bg.png")
    scene.shopBg:scale(_R,_R)
    scene.shopBg.x = _W/2
    scene.shopBg.y = _H/2+30*_R
	scene.shopBg:addEventListener("touch", noTouch)
    scene.Shop:insert(scene.shopBg)
	
	scene.btnClose = createBtn({id = "btnClose", x = _W*0.5+170*_R, y = _H*0.5-215*_R, btnIndex = infoSheet:getFrameIndex("cerrar"), touchSound = AZ.soundLibrary.closePopupSound})
    
    -- Preparem element monedes disponibles
	scene.btnHearts 		= createBtn({id = "btnHearts", x = _W*0.15, y = _H*0.07, btnIndex = infoSheet:getFrameIndex("corazon"), txtParams = { text = tostring(AZ.userInfo.lifesCurrent), font = INTERSTATE_BOLD, fontSize = 24, color = AZ_DARK_RGB, x = -32, y = -3 }, touchSound = AZ.soundLibrary.heartsAccessSound})
	scene.btnShop 			= createBtn({id = "btnClose", x = _W*0.85, y = _H*0.07, btnIndex = infoSheet:getFrameIndex("boton_shop"), touchSound = AZ.soundLibrary.closePopupSound})
	if #AZ.userInfo.shopNewItems > 0 then
		scene.btnShop.newItemsMarker = display.newImage(scene.myImageSheet, infoSheet:getFrameIndex("alert_shop"), -30, -30)
		scene.btnShop:insert(scene.btnShop.newItemsMarker)
		scene.btnShop.newItemsLabel = display.newText({ text = tostring(#AZ.userInfo.shopNewItems), font = INTERSTATE_BOLD, fontSize = 20, x = -30, y = -31 })
		scene.btnShop.newItemsLabel:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
		scene.btnShop:insert(scene.btnShop.newItemsLabel)
	end
	scene.btnBank 			= createBtn({id = "btnBank", x = _W*0.5, y = _H*0.073, btnIndex = infoSheet:getFrameIndex("coin"), txtParams = { text = AZ.utils.coinFormat(AZ.userInfo.money), font = INTERSTATE_BOLD, fontSize = 22, color = AZ_DARK_RGB, x = -30, y = -5 }, touchSound = AZ.soundLibrary.bankAccessSound})
    
    --Element nom del popup
    scene.txtTitle = addText("txtTitle", translate("shop"), {r =0 , g =0 , b =0 , a = 0.4 }, INTERSTATE_BOLD, _W/2, _H/2-190*_R, 30)
    
    --Element descripcció producte
    scene.txtWeaponName = addText("weaponName", "Nom Arma", {r = 0, g = 0, b = 0, a = 0.7 }, INTERSTATE_BOLD, _W/2-180*_R, _H/2+45*_R, 30)
    scene.txtWeaponName.anchorX = 0
	scene.txtWeaponDescription = display.newText({text = "Aquesta arma fa tal cosa i tal altra", x = _W/2-180*_R, y = _H/2+65*_R, width = scene.shopBg.contentWidth*0.9, font = INTERSTATE_REGULAR, fontSize = 17*_R, align = "left"})
	scene.txtWeaponDescription:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
	scene.txtWeaponDescription.name = "weaponDescription"
    scene.txtWeaponDescription.anchorX = 0
    scene.txtWeaponDescription.anchorY = 0
	scene.Shop:insert(scene.txtWeaponDescription)
    
    --Botons comprar unitats d'armes
    by = _H/2+220*_R
    bx = _W/2-125*_R
	scene.btnBooster1 = display.newGroup()
    scene.btnBooster1.blocked = AZ.ui.newEnhancedButton2(
    {
        sound = AZ.soundLibrary.buttonSound,
        id = "blocked",
        myImageSheet = scene.myImageSheet,
        unpressedIndex = infoSheet:getFrameIndex("boton_block"),
        pressedIndex = infoSheet:getFrameIndex("boton_block_press"),
        x = 0,
        y = 0,
        onEvent = onClick
    }
    )
    scene.btnBooster1.unblocked = AZ.ui.newEnhancedButton2(
    {
	sound = AZ.soundLibrary.buttonSound,
        id = "unblocked",
        myImageSheet = scene.myImageSheet,
        unpressedIndex = infoSheet:getFrameIndex("boton_small"),
        pressedIndex = infoSheet:getFrameIndex("boton_small_press"),
        x = 0,
        y = 0,
        onEvent = onClick
    }
    )
    scene.btnBooster1.acquired = AZ.ui.newEnhancedButton2(
    {
	sound = AZ.soundLibrary.buttonSound,
        id = "acquired",
        myImageSheet = scene.myImageSheet,
        unpressedIndex = infoSheet:getFrameIndex("boton_completed"),
        x = 0,
        y = 0,
        onEvent = onClick
    }
    )
    scene.btnBooster1.blocked.isVisible = false
    scene.btnBooster1.unblocked.isVisible = false
    scene.btnBooster1.acquired.isVisible = false
    scene.btnBooster1.blocked:scale(_R,_R)
    scene.btnBooster1.unblocked:scale(_R,_R)
    scene.btnBooster1.acquired:scale(_R,_R)
    scene.btnBooster1:insert(scene.btnBooster1.blocked)
    scene.btnBooster1:insert(scene.btnBooster1.unblocked)
    scene.btnBooster1:insert(scene.btnBooster1.acquired)
	
	scene.btnBooster1.anchorChildren = true
	scene.btnBooster1.anchorX = 0.5
	scene.btnBooster1.anchorY = 0.5
	scene.btnBooster1.x = bx
	scene.btnBooster1.y = by
	
	local btnBooster1Mask = graphics.newMask("shop/assets/bot_masc.png")
	scene.btnBooster1:setMask(btnBooster1Mask)
	scene.btnBooster1.maskScaleX = _R 
	scene.btnBooster1.maskScaleY = _R
	
	scene.btnBooster1Shadow = display.newImage(scene.myImageSheet, infoSheet:getFrameIndex("sombra"))
	scene.btnBooster1Shadow:scale(_R, _R)
	scene.btnBooster1Shadow.x, scene.btnBooster1Shadow.y = bx, by
	
	scene.Shop:insert(scene.btnBooster1)
	scene.Shop:insert(scene.btnBooster1Shadow)
    
    bx = _W/2
	scene.btnBooster2 = display.newGroup()
    scene.btnBooster2.blocked = AZ.ui.newEnhancedButton2(
    {
        sound = AZ.soundLibrary.buttonSound,
        id = "blocked",
        myImageSheet = scene.myImageSheet,
        unpressedIndex = infoSheet:getFrameIndex("boton_block"),
        pressedIndex = infoSheet:getFrameIndex("boton_block_press"),
        x = 0,
        y = 0,
        onEvent = onClick
    }
    )
    scene.btnBooster2.unblocked = AZ.ui.newEnhancedButton2(
    {
	sound = AZ.soundLibrary.buttonSound,
        id = "unblocked",
        myImageSheet = scene.myImageSheet,
        unpressedIndex = infoSheet:getFrameIndex("boton_small"),
        pressedIndex = infoSheet:getFrameIndex("boton_small_press"),
        x = 0,
        y = 0,
        onEvent = onClick
    }
    )
    scene.btnBooster2.acquired = AZ.ui.newEnhancedButton2(
    {
	sound = AZ.soundLibrary.buttonSound,
        id = "acquired",
        myImageSheet = scene.myImageSheet,
        unpressedIndex = infoSheet:getFrameIndex("boton_completed"),
        x = 0,
        y = 0,
        onEvent = onClick
    }
    )
    scene.btnBooster2.blocked.isVisible = false
    scene.btnBooster2.unblocked.isVisible = false
    scene.btnBooster2.acquired.isVisible = false
    scene.btnBooster2.blocked:scale(_R,_R)
    scene.btnBooster2.unblocked:scale(_R,_R)
    scene.btnBooster2.acquired:scale(_R,_R)
    scene.btnBooster2:insert(scene.btnBooster2.blocked)
    scene.btnBooster2:insert(scene.btnBooster2.unblocked)
    scene.btnBooster2:insert(scene.btnBooster2.acquired)
	
	scene.btnBooster2.anchorChildren = true
	scene.btnBooster2.anchorX = 0.5
	scene.btnBooster2.anchorY = 0.5
	scene.btnBooster2.x = bx
	scene.btnBooster2.y = by
	
	local btnBooster2Mask = graphics.newMask("shop/assets/bot_masc.png")
	scene.btnBooster2:setMask(btnBooster2Mask)
	scene.btnBooster2.maskScaleX = _R 
	scene.btnBooster2.maskScaleY = _R
	
	scene.btnBooster2Shadow = display.newImage(scene.myImageSheet, infoSheet:getFrameIndex("sombra"))
	scene.btnBooster2Shadow:scale(_R, _R)
	scene.btnBooster2Shadow.x, scene.btnBooster2Shadow.y = bx, by
	
	scene.Shop:insert(scene.btnBooster2)
	scene.Shop:insert(scene.btnBooster2Shadow)
    
    bx = _W/2+125*_R
	scene.btnBooster3 = display.newGroup()
    scene.btnBooster3.blocked = AZ.ui.newEnhancedButton2(
    {
		sound = AZ.soundLibrary.buttonSound,
        id = "blocked",
        myImageSheet = scene.myImageSheet,
        unpressedIndex = infoSheet:getFrameIndex("boton_block"),
        pressedIndex = infoSheet:getFrameIndex("boton_block_press"),
        x = 0,
        y = 0,
        onEvent = onClick
    }
    )
    scene.btnBooster3.unblocked = AZ.ui.newEnhancedButton2(
    {
		sound = AZ.soundLibrary.buttonSound,
        id = "unblocked",
        myImageSheet = scene.myImageSheet,
        unpressedIndex = infoSheet:getFrameIndex("boton_small"),
        pressedIndex = infoSheet:getFrameIndex("boton_small_press"),
        x = 0,
        y = 0,
        onEvent = onClick
    }
    )
    scene.btnBooster3.acquired = AZ.ui.newEnhancedButton2(
    {
		sound = AZ.soundLibrary.buttonSound,
        id = "acquired",
        myImageSheet = scene.myImageSheet,
        unpressedIndex = infoSheet:getFrameIndex("boton_completed"),
        x = 0,
        y = 0,
        onEvent = onClick
    }
    )
    scene.btnBooster3.blocked.isVisible = false
    scene.btnBooster3.unblocked.isVisible = false
    scene.btnBooster3.acquired.isVisible = false
    scene.btnBooster3.blocked:scale(_R,_R)
    scene.btnBooster3.unblocked:scale(_R,_R)
    scene.btnBooster3.acquired:scale(_R,_R)
    scene.btnBooster3:insert(scene.btnBooster3.blocked)
    scene.btnBooster3:insert(scene.btnBooster3.unblocked)
    scene.btnBooster3:insert(scene.btnBooster3.acquired)
	
	scene.btnBooster3.anchorChildren = true
	scene.btnBooster3.anchorX = 0.5
	scene.btnBooster3.anchorY = 0.5
	scene.btnBooster3.x = bx
	scene.btnBooster3.y = by
	
	local btnBooster3Mask = graphics.newMask("shop/assets/bot_masc.png")
	scene.btnBooster3:setMask(btnBooster3Mask)
	scene.btnBooster3.maskScaleX = _R 
	scene.btnBooster3.maskScaleY = _R
	
	scene.btnBooster3Shadow = display.newImage(scene.myImageSheet, infoSheet:getFrameIndex("sombra"))
	scene.btnBooster3Shadow:scale(_R, _R)
	scene.btnBooster3Shadow.x, scene.btnBooster3Shadow.y = bx, by
	
	scene.Shop:insert(scene.btnBooster3)
	scene.Shop:insert(scene.btnBooster3Shadow)
	
	--Afegim l'efecte de brillantor metal·lica al boto desbloquejat
	scene.bars = display.newGroup()
	local bar1 = display.newRect(0, 0, 195, 4)
	local bar2 = display.newRect(0, 30, 195, 25)
	scene.bars:insert(bar1)
	scene.bars:insert(bar2)
	scene.bars:scale(_R, _R)
	scene.bars.alpha = 0.5
	scene.bars.anchorChildren = true
	scene.bars.anchorX, scene.bars.anchorY = 0.5, 0.5
	scene.bars.x, scene.bars.y = 0, 0
	scene.bars:rotate(-45)
	scene.btnBooster1:insert(scene.bars)
	
	--Afegim l'estrelleta que es mostrara al final de l'animacio de brillantor metal·lica
	scene.littleShine = display.newImage(scene.myImageSheet, infoSheet:getFrameIndex("brillo_pq"))
	scene.littleShine:scale(_R, _R)
	scene.littleShine.alpha = 0
	scene.littleShine.xScale, scene.littleShine.yScale = 0.001, 0.001
	scene.Shop:insert(scene.littleShine)
	scene.littleShine.x, scene.littleShine.y = scene.btnBooster1.x+45*_R, scene.btnBooster1.y+53*_R
	
	--Etiquetes del boto de comprar boosters
    scene.txtBooster = addText("txtBooster", "+1", {r = 0, g = 0, b = 0, a = 0.7 }, INTERSTATE_BOLD, xBooster[1], by-25*_R, 40)
    scene.txtPriceBooster = addText("txtPriceBooster", "prova", {r = 0, g = 0, b = 0, a = 0.7 }, INTERSTATE_BOLD, xPriceBooster[1], by + 35*_R, 28)
	
	--Boto amb efecte de trencat
	scene.btnBoosterBroken = createBrokenButton(scene.btnBooster2.x, scene.btnBooster2.y, infoSheet)
	scene.Shop:insert(scene.btnBoosterBroken)
	scene.btnBoosterBroken.isVisible = false
	--timer.performWithDelay(2000, scene.btnBoosterBroken.breakBtn)
    
    --- Elements del selector d'armes
    -- És l'ScrollView que contindrà l'array d'armes
    scene.scrollWeapons = widget.newScrollView
    {
        width = _W,
        height = _iconHeight*1.5,
        scrollWidth = (_W/5)*19 + _iconWidth,
        scrollHeight = _iconHeight,
        leftPadding = _iconWidth*2,
        rightPadding = _iconWidth*2.5,
        friction = 0.9,
        hideBackground = true,
        verticalScrollDisabled = true,
        hideScrollBar = true,
        listener = scrollListener,
        isBounceEnabled = true,
    }
    scene.Shop:insert(scene.scrollWeapons)
    scene.scrollWeapons.anchorX = 0
    scene.scrollWeapons.anchorY = 0
    scene.scrollWeapons.x = 0
    scene.scrollWeapons.y = _H/2-150*_R
    
    for i=1, #AZ.shopInfo.shop.weapons do
        scene.weapons[i] = display.newGroup()
        scene.weapons[i].isSelected = false
        scene.weapons[i].num = i
		scene.weapons[i].name = string.sub(AZ.shopInfo.shop.weapons[i].name, 1, (string.find(AZ.shopInfo.shop.weapons[i].name, "_", 1)-1))
        scene.weapons[i].shine1 = bitmap(scene.myImageSheet, infoSheet:getFrameIndex("brillo1"), 0, 0)
        scene.weapons[i].shine1.alpha = 0
        scene.weapons[i].shine1.xScale, scene.weapons[i].shine1.yScale = 1.6*_R, 1.6*_R
        scene.weapons[i].shine2 = bitmap(scene.myImageSheet, infoSheet:getFrameIndex("brillo2"), 0, 0)
        scene.weapons[i].shine2.alpha = 0
        scene.weapons[i].shine2.xScale, scene.weapons[i].shine2.yScale = 1.6*_R, 1.6*_R
        scene.weapons[i].weapon = bitmap(scene.myImageSheet, infoSheet:getFrameIndex(scene.weapons[i].name), 0, 0)
        scene.weapons[i].weapon.xScale, scene.weapons[i].weapon.yScale = 0.7*_R, 0.7*_R
		scene.weapons[i].isBlocked = false
		for j = 1, #AZ.userInfo.weapons do
			if AZ.userInfo.weapons[j].name == scene.weapons[i].name then
				if AZ.userInfo.weapons[j].isBlocked == true then --(AZ.userInfo.weapons[math.min(i+1, #AZ.userInfo.weapons)].isBlocked == true and scene.weapons[i].name ~= "extraLifes") then
					scene.weapons[i].weapon:setFillColor(0.25,0.25,0.25)
					scene.weapons[i].isBlocked = true
				end
			end
		end
        scene.weapons[i]:insert(scene.weapons[i].shine1)
        scene.weapons[i]:insert(scene.weapons[i].shine2)
        scene.weapons[i]:insert(scene.weapons[i].weapon)
        scene.weapons[i].x = (_W/5)*(1+((1.85)*(i-1)))
        scene.weapons[i].y = _iconHeight*0.75
        scene.weapons[i]:addEventListener("touch", clickOnWeapon)
        
        scene.scrollWeapons:insert(scene.weapons[i])
    end
    
    local mask = graphics.newMask("shop/assets/mascara.png")
    scene.scrollWeapons:setMask(mask)
    scene.scrollWeapons.maskScaleX = _R
    scene.scrollWeapons.maskScaleY = 1.2*_R
    scene.scrollWeapons.maskX = 0
    scene.scrollWeapons.maskY = _H/2-135*_R
    scene.scrollWeapons.isHitTestMasked = false
	
	scene.noTouchLayer = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
	scene.noTouchLayer.alpha = 0
	scene.noTouchLayer:addEventListener("touch", noTouch)
	scene.noTouchLayer.isHitTestable = false
	scene.Shop:insert(scene.noTouchLayer)
	
	if params.prizeName then
		scene.noTouchLayer.isHitTestable = true
	end
	
--	if #AZ.userInfo.shopNewItems > 0 then
--		for i = 1, #scene.weapons do
--			if AZ.userInfo.shopNewItems[#AZ.userInfo.shopNewItems] == scene.weapons[i].name then
--				scrollToWeapon(i)
--				return true
--			end
--		end
--	else
--		scrollToWeapon(1)
--	end

	selectWeapon(1)
    scene.scrollWeapons:scrollToPosition({x=(-scene.weapons[1].x)+_W*0.5, time = 0})
end

--- Funcio que es crida al crear l'escena
function scene:createScene(event)
	
	AZ.audio.playBSO(AZ.soundLibrary.shopLoop)
	
	_coins = AZ.userInfo.money
    scene.init(event.params) 
	Runtime:addEventListener(RECOVERED_LIFES_EVNAME, currentLifesListener)
end

--- Funcio que es crida a l'entrar a l'escena
function scene:enterScene(event)
	if params.prizeName then
		for i = 1, #scene.weapons do
			if scene.weapons[i].name == params.prizeName then
				scrollToWeapon(i, true)
			end
		end
	else
		if #AZ.userInfo.shopNewItems > 0 then
			for i = 1, #scene.weapons do
				if AZ.userInfo.shopNewItems[#AZ.userInfo.shopNewItems] == scene.weapons[i].name then
					scrollToWeapon(i, true)
					return true
				end
			end
		else
			scrollToWeapon(1, true)
		end
	end
end

function scene:exitScene(event)
	-- Guardem el nou json generat
	if scene.jsonChanged then
		AZ:saveData()
	end
	
	timer.safeCancel(timerID)
	
	cancelWeaponTransition()
	
	cancelBtnShineTransition()
	
    for i = 1, #scene.weapons do
        Runtime:removeEventListener("enterFrame", rotateLeft)
        Runtime:removeEventListener("enterFrame", rotateRight)
    end
	
	Runtime:removeEventListener(RECOVERED_LIFES_EVNAME, currentLifesListener)
end

function scene:overlayEnded(event)
    _coins = AZ.userInfo.money
    scene.btnBank.txt.text = AZ.utils.coinFormat(_coins)
	currentLifesListener({lifes = AZ.userInfo.lifesCurrent})
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("overlayEnded", scene)

return scene
