
local scene = AZ.S.newScene()

scene.Popup = {}
local _R = SCALE_BIG
local _W = display.contentWidth
local _H = display.contentHeight

scene.myImageSheet = nil
scene.Popup.background = nil
scene.Popup.btnClose = nil
scene.Popup.txtNoCoins = nil
scene.Popup.weaponGroup = {}
scene.Popup.btnRefill = nil
scene.gameplayPrice = nil
scene.refillQtt = nil

local function onTouch(event)
    
    local id = nil
    
    if event.target then
        id = event.target.id
    else
        id = event.id
    end
    
    if event.phase == "release" or event.phase == "ended" then
        
        if event.isBackKey or (id == "btnClose" and event.target.isWithinBounds) then
            local fadeTime = 400
            timer.performWithDelay(fadeTime, function() Runtime:dispatchEvent({ name = GAMEPLAY_PAUSE_EVNAME, isPause = false, pauseType = "buyWeapons", success = false }) end)
            
            AZ.S.hideOverlay("crossFade", fadeTime)
        elseif id == "btnRefill" then
            --- Ara està hardcodejat, més endevant s'haurà de programar la compra inapp de manera que vagi a l'Store pertinent
            -- fent servir el primer element del JSON del banc
            if AZ.userInfo.money - scene.gameplayPrice >= 0 then
                AZ.userInfo.money = AZ.userInfo.money - scene.gameplayPrice
                AZ:saveData()
                local fadeTime = 400
                timer.performWithDelay(fadeTime, function() Runtime:dispatchEvent({ name = GAMEPLAY_PAUSE_EVNAME, isPause = false, pauseType = "buyWeapons", success = true, weaponName = scene.params.weaponName, weaponAmount = scene.refillQtt }) end)

                AZ.S.hideOverlay("crossFade", fadeTime)
            else
                local options = {
                    effect = "crossFade",
                    time = 300,
                    params = scene.params,
                    isModal = true
                }
                options.params.isRefillWeapon = true
                AZ.S.showOverlay("popups.popupmoneygameplay", options)
            end
        end
        
        return true
    end
end

function scene.onBackTouch()
	onTouch({ phase = "ended", isBackKey = true })
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
	
	-- Creem el marcador de monedes
	scene.Popup.backgroundMarcador = display.newImage("popups/assets/contador.png")
    scene.Popup.backgroundMarcador:scale(_R,_R)
    scene.Popup.backgroundMarcador.x, scene.Popup.backgroundMarcador.y = _W*0.5, _H*0.5-225*_R
	scene.Popup.backgroundMarcador:addEventListener("touch", noTouch)
    scene.Popup:insert(scene.Popup.backgroundMarcador)
	
	scene.Popup.coinMarcador = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("coin_XL"))
	scene.Popup.coinMarcador:scale(_R*0.4, _R*0.4)
	scene.Popup.coinMarcador.x, scene.Popup.coinMarcador.y = _W*0.5, _H*0.5-235*_R
	scene.Popup:insert(scene.Popup.coinMarcador)
	
	scene.Popup.txtCoinsMarcador = display.newText(AZ.utils.coinFormat(AZ.userInfo.money), _W*0.5, _H*0.5-205*_R, INTERSTATE_BOLD, 25*_R)
	scene.Popup.txtCoinsMarcador:setFillColor(AZ.utils.getColor(AZ_BRIGHT_RGB))
	scene.Popup:insert(scene.Popup.txtCoinsMarcador)
    
    scene.Popup.background = display.newImage("popups/assets/popup_bg.png")
    scene.Popup.background:scale(_R,_R)
    scene.Popup.background.x, scene.Popup.background.y = _W*0.5, _H*0.5+20*_R
	scene.Popup.background:addEventListener("touch", noTouch)
    scene.Popup:insert(scene.Popup.background)
    
	scene.btnClose = createBtn({id = "btnClose", x = _W*0.5+160*_R, y = _H*0.5-160*_R, btnIndex = sheetInfo:getFrameIndex("cerrar")})
    
    scene.Popup.txtNoCoins = display.newText({text = AZ.utils.translate("pp_refill_item"), x = _W*0.5, y = _H*0.5-140*_R, font = BRUSH_SCRIPT, fontSize = 45*_R, align = "center"})
    scene.Popup.txtNoCoins:setFillColor(AZ.utils.getColor(FONT_BLACK_COLOR))
    scene.Popup:insert(scene.Popup.txtNoCoins)
    
    scene.Popup.weaponGroup = display.newGroup()
    scene.Popup.weaponGroup.bg = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("box"))
    scene.Popup.weaponGroup.bg:scale(_R, _R)
    scene.Popup.weaponGroup.bg.x, scene.Popup.weaponGroup.bg.y = _W*0.5, _H*0.5+35*_R
    scene.Popup.weaponGroup:insert(scene.Popup.weaponGroup.bg)
    scene.Popup.weaponGroup.circle = display.newGroup()
        scene.Popup.weaponGroup.circle.left = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("etiqueta_cantidad_bl_1"))
        scene.Popup.weaponGroup.circle.left.x, scene.Popup.weaponGroup.circle.left.y = 0, 0
        scene.Popup.weaponGroup.circle:insert(scene.Popup.weaponGroup.circle.left)
        scene.Popup.weaponGroup.circle.right = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("etiqueta_cantidad_bl_1"))
        scene.Popup.weaponGroup.circle.right:rotate(180)
        scene.Popup.weaponGroup.circle.right.x, scene.Popup.weaponGroup.circle.right.y = scene.Popup.weaponGroup.circle.left.contentWidth, 0
        scene.Popup.weaponGroup.circle:insert(scene.Popup.weaponGroup.circle.right)
    scene.Popup.weaponGroup.circle.anchorChildren = true
    scene.Popup.weaponGroup.circle:scale(_R, _R)
    scene.Popup.weaponGroup.circle.x, scene.Popup.weaponGroup.circle.y = _W*0.5, _H*0.5+90*_R
    scene.Popup.weaponGroup:insert(scene.Popup.weaponGroup.circle)
    scene.Popup.weaponGroup.img = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex(scene.params.weaponName))
    scene.Popup.weaponGroup.img:scale(_R*1.3, _R*1.3)
    scene.Popup.weaponGroup.img.x, scene.Popup.weaponGroup.img.y = _W*0.5, _H*0.5-25*_R
    scene.Popup.weaponGroup:insert(scene.Popup.weaponGroup.img)
    scene.Popup.weaponGroup.txt = display.newText({text = tostring(scene.refillQtt), x = _W*0.5, y = _H*0.5+90*_R, font = INTERSTATE_BOLD, fontSize = 40*_R, align = "center"})
    scene.Popup.weaponGroup.txt:setFillColor(AZ.utils.getColor(FONT_BLACK_COLOR))
    scene.Popup.weaponGroup:insert(scene.Popup.weaponGroup.txt)
    scene.Popup:insert(scene.Popup.weaponGroup)
    
    scene.Popup.btnRefill = AZ.ui.newEnhancedButton2{
        sound = AZ.soundLibrary.buttonSound,
        myImageSheet = scene.myImageSheet,
        unpressedIndex = sheetInfo:getFrameIndex("boton_blue"),
        x = _W*0.5,
        y = _H*0.5+180*_R,
        pressedIndex = sheetInfo:getFrameIndex("boton_blue_press"),
        text1 = {text = tostring(scene.gameplayPrice), fontName = INTERSTATE_BOLD, fontSize = 60, X = 30, Y = 40, color = FONT_BLACK_COLOR},
        onEvent = onTouch,
        id = "btnRefill"
    }
    scene.Popup.btnRefill:scale(_R,_R)
    scene.Popup:insert(scene.Popup.btnRefill)
    
    scene.Popup.imgCoin = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("coin_XL"))
    scene.Popup.imgCoin:scale(_R*0.6,_R*0.6)
    scene.Popup.imgCoin.x, scene.Popup.imgCoin.y = _W*0.5-60*_R, _H*0.5+180*_R
    scene.Popup:insert(scene.Popup.imgCoin)
    
end

--- Creem l'escene i guardem el paràmetres passats per utilitzar-los més endavant
function scene:createScene(event)
    scene.params = event.params
    for i = 1, #AZ.shopInfo.shop.weapons do
        if AZ.shopInfo.shop.weapons[i].name == scene.params.weaponName.."_name" then
            for j = 1, #AZ.userInfo.weapons do
                if AZ.userInfo.weapons[j].name == scene.params.weaponName then
                    if AZ.userInfo.weapons[j].boughtLevel == 0 then
                        scene.gameplayPrice = AZ.shopInfo.shop.weapons[i].boosterData[1].gameplayPrice
                        scene.refillQtt = AZ.shopInfo.shop.weapons[i].boosterData[1].quantity
                    else
                        scene.gameplayPrice = AZ.shopInfo.shop.weapons[i].boosterData[AZ.userInfo.weapons[j].boughtLevel].gameplayPrice
                        scene.refillQtt = AZ.userInfo.weapons[j].quantity
                    end
                end
            end
        end
    end
    scene:init()
    transition.from(scene.Popup, {time = 1000, alpha = 0, x = _W*0.5, y = _H*0.5, xScale = 0.000001, yScale = 0.000001, transition = easing.outElastic})
end

function scene:exitScene(event)
    Runtime:removeEventListener("enterFrame", rotateStar)
    transition.cancel(scene.Popup.weaponGroup.bg)
    scene.Popup.translucidBg.alpha = 0
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener( "createScene", scene )
scene:addEventListener("exitScene", scene)

return scene