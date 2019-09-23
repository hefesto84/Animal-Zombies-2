
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
local deltaTime = 0

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

local function bgBigLittleAnim()
    local function bigAnim()
        transition.to(scene.Popup.safeGroup.bg, {time = 300, xScale = _R, yScale = _R, transition = easing.outQuad, onComplete = bgBigLittleAnim})
    end
    transition.to(scene.Popup.safeGroup.bg, {time = 300, xScale = _R*0.6, yScale = _R*0.6, transition = easing.outQuad, onComplete = bigAnim})
end

local function getDeltaTime()
    local temp = system.getTimer() --Get current game time in ms
    local dt = (temp-deltaTime) *0.001
    deltaTime = temp --Store game time
    return dt
end

local function rotateStar()
    local rotation = 50 * getDeltaTime()
    scene.Popup.safeGroup.bg:rotate(rotation)
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
    
	scene.btnClose = createBtn({id = "btnClose", x = _W*0.5+160*_R, y = _H*0.5-160*_R, btnIndex = sheetInfo:getFrameIndex("cerrar"), touchSound = AZ.soundLibrary.closePopupSound})
    
    scene.Popup.txtNoCoins = display.newText({text = "No coins!", x = _W*0.5, y = _H*0.5-140*_R, font = BRUSH_SCRIPT, fontSize = 45*_R, align = "center"})
    scene.Popup.txtNoCoins:setFillColor(AZ.utils.getColor(FONT_BLACK_COLOR))
    
    scene.Popup.safeGroup = display.newGroup()
    scene.Popup.safeGroup.bg = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("brillo"))
    scene.Popup.safeGroup.bg:scale(_R, _R)
    scene.Popup.safeGroup.bg.x, scene.Popup.safeGroup.bg.y = _W*0.5, _H*0.5+10*_R
    Runtime:addEventListener("enterFrame", rotateStar)
    bgBigLittleAnim()
    scene.Popup.safeGroup:insert(scene.Popup.safeGroup.bg)
    scene.Popup.safeGroup.img = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("safe_wo_coins"))
    scene.Popup.safeGroup.img:scale(_R, _R)
    scene.Popup.safeGroup.img.x, scene.Popup.safeGroup.img.y = _W*0.5, _H*0.5+10*_R
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
    
end

--- Creem l'escene i guardem el paràmetres passats per utilitzar-los més endavant
function scene:createScene(event)
    scene.params = event.params
    scene:init()
    transition.from(scene.Popup, {time = 1000, alpha = 0, x = _W*0.5, y = _H*0.5, xScale = 0.000001, yScale = 0.000001, transition = easing.outElastic})
end

function scene:exitScene(event)
    Runtime:removeEventListener("enterFrame", rotateStar)
    transition.cancel(scene.Popup.safeGroup.bg)
    scene.Popup.translucidBg.alpha = 0
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener( "createScene", scene )
scene:addEventListener("exitScene", scene)

return scene



