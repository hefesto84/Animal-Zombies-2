
local scene = AZ.S.newScene()

scene.Popup = {}
scene.params = nil
scene.myImageSheet = nil

local _W = display.contentWidth
local _H = display.contentHeight
local _R = SCALE_BIG

local function onTouch(event)
    local id = nil 
    if event.target ~= nil then
        id = event.target.id
    else
        id = event.id
    end
    local phase = event.phase
    
    if phase == "ended" or phase == "release" then
        if event.isBackKey or (id == "btnClose" and event.target.isWithinBounds) or id == "btnThreePrize" then
            if scene.params.prizeName == "coin" then
                AZ.userInfo.money = AZ.userInfo.money + scene.prizeAmount
                AZ.userInfo.jackpot = 500
            else
               for i = 1, #AZ.userInfo.weapons do
                   if AZ.userInfo.weapons[i].name == scene.params.prizeName then
                      AZ.userInfo.weapons[i].boughtLevel = AZ.userInfo.weapons[i].boughtLevel + 1
                      AZ.userInfo.weapons[i].quantity = scene.prizeAmount
                   end
               end
            end
            AZ:saveData()
--            AZ.S.hideOverlay()
            if scene.params.prizeName == "coin" then
                AZ.S.hideOverlay()
            else
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

--- Funció showThreePrize
-- És la funció encarregada de crear el contingut del popup quan s'aconsegueix
-- un premi de tres armes igual
-- @param name És el nom del premi aconseguit
local function showThreePrize(name, sheetInfo)
    scene.threePrize = display.newGroup()
    
    local title = nil
    title = addText("titleThreePrize", AZ.utils.translate("pp_slot_win"), {r = 0.2, g = 0.2, b = 0.2, a = 0.9, }, BRUSH_SCRIPT, _W*0.5, _H*0.5-140*_R, 55)
    scene.threePrize:insert(title)
    
    local weaponBg = bitmap("box", sheetInfo, _W*0.5, _H*0.5+15*_R)
    scene.threePrize:insert(weaponBg)
    local weapon = bitmap(name, sheetInfo, _W*0.5, _H*0.5-20*_R)
    scene.threePrize:insert(weapon)
    local weaponQttBg = {}
    local weaponQtt = nil
    local qtt = nil
    if (name ~= "coin") then
        weaponQttBg = display.newGroup()
        weaponQttBg.left = bitmap("etiqueta_cantidad_bl_1", sheetInfo, 0, 0)
        weaponQttBg:insert(weaponQttBg.left)
        weaponQttBg.right = bitmap("etiqueta_cantidad_bl_1", sheetInfo, weaponQttBg.left.contentWidth, 0)
        weaponQttBg.right:rotate(180)
        weaponQttBg:insert(weaponQttBg.right)
        weaponQttBg.anchorChildren = true
        weaponQttBg.x, weaponQttBg.y = _W*0.5, _H*0.5+65*_R

        for i=1,#AZ.shopInfo.shop.weapons do
            if AZ.shopInfo.shop.weapons[i].name == name.."_name" then
                for j = 1, #AZ.userInfo.weapons do
                    if AZ.userInfo.weapons[j].name == name then
                        qtt = AZ.shopInfo.shop.weapons[i].boosterData[AZ.userInfo.weapons[j].boughtLevel + 1].quantity
                    end
                end
            end
        end
        weaponQtt = addText("qtt", tostring(qtt), {r = 0.2, g = 0.2, b = 0.2, a = 0.9, }, INTERSTATE_BOLD, _W*0.5, _H*0.5+65*_R, 40)
    elseif name == "coin" then
        qtt = scene.params.jackpot
        weaponQtt = addText("qtt", "+"..tostring(qtt), {r = 0.2, g = 0.2, b = 0.2, a = 0.9, }, INTERSTATE_BOLD, _W*0.5, _H*0.5+65*_R, 40)
            
        weaponQttBg = display.newGroup()
        weaponQttBg.left = bitmap("etiqueta_cantidad_bl_1", sheetInfo, 0, 0)
        weaponQttBg:insert(weaponQttBg.left)
        weaponQttBg.middle = display.newImage("popups/assets/etiqueta_cantidad_bl_2.png")
        local scaleX = weaponQtt.contentWidth/weaponQttBg.middle.contentWidth
        weaponQttBg.middle:scale(scaleX, _R)
        weaponQttBg.middle.x = (weaponQttBg.left.contentWidth/2) + (weaponQttBg.middle.contentWidth/2)
        weaponQttBg:insert(weaponQttBg.middle)
        weaponQttBg.right = bitmap("etiqueta_cantidad_bl_1", sheetInfo, weaponQttBg.left.contentWidth + weaponQttBg.middle.contentWidth, 0)
        weaponQttBg.right:rotate(180)
        weaponQttBg:insert(weaponQttBg.right)
        weaponQttBg.anchorChildren = true
        weaponQttBg.x, weaponQttBg.y = _W*0.5, _H*0.5+65*_R
    end
    scene.prizeAmount = qtt
    scene.threePrize:insert(weaponQttBg)
    scene.threePrize:insert(weaponQtt)
    
    local btnThreePrize = AZ.ui.newEnhancedButton2(
    {
        sound = AZ.soundLibrary.buttonSound,
        id = "btnThreePrize",
        myImageSheet = scene.myImageSheet,
        unpressedIndex = sheetInfo:getFrameIndex("boton_gris"),
        pressedIndex = sheetInfo:getFrameIndex("boton_gris_press"),
        x = _W*0.5,
        y = _H*0.5+180*_R,
        text1 = {text = AZ.utils.translate("pp_continue"), fontName = INTERSTATE_BOLD, fontSize = 50, X = 0, Y = 25, color = {0,0,0,190}},
        onEvent = onTouch
    })
    btnThreePrize:scale(_R, _R)
    scene.threePrize:insert(btnThreePrize)
   
    return scene.threePrize
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
    
    scene.Popup:insert(showThreePrize(scene.params.prizeName, sheetInfo))
end

function scene:createScene(event)
    scene.params = event.params
    scene:init()
	transition.from(scene.Popup, {time = 1000, alpha = 0, x = _W*0.5, y = _H*0.5, xScale = 0.000001, yScale = 0.000001, transition = easing.outElastic})
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener("createScene", scene)

return scene