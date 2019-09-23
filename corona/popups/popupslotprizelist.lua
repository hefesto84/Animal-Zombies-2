
local scene = AZ.S.newScene()

scene.Popup = {}
scene.myImageSheet = nil
local _W = display.contentWidth
local _H = display.contentHeight
local _R = SCALE_BIG

scene.widget = require "widget"

scene.iconName = {
   {["gaviot"] = "ic_slot_paloma", ["stinkBomb"] = "ic_slot_bomba", ["coin"] = "ic_slot_moneda", ["deathBox"] = "ic_slot_jaulamuerte", ["hose"] = "ic_slot_manguera", ["iceCube"] = "ic_slot_hielo", ["lifeBox"] = "ic_slot_jaulabuena", ["thunder"] = "ic_slot_rayo", ["lollipop"] = "ic_slot_piruleta", ["rake"] = "ic_slot_rastrillo", ["stone"] = "ic_slot_piedra", ["trap"] = "ic_slot_tramparat", ["earthquake"] = "ic_slot_terremoto" , ["grave"] = "ic_slot_lapida", ["skull"] = "ic_slot_calavera"},
   {["gaviot"] = "ic_slot_paloma_h", ["stinkBomb"] = "ic_slot_bomba_h", ["coin"] = "ic_slot_moneda_h", ["deathBox"] = "ic_slot_jaulamuerte_h", ["hose"] = "ic_slot_manguera_h", ["iceCube"] = "ic_slot_hielo_h", ["lifeBox"] = "ic_slot_jaulabuena_h", ["thunder"] = "ic_slot_rayo_h", ["lollipop"] = "ic_slot_piruleta_h", ["rake"] = "ic_slot_rastrillo_h", ["stone"] = "ic_slot_piedra_h", ["trap"] = "ic_slot_tramparat_h", ["earthquake"] = "ic_slot_terremoto_h"}
}

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

---Funcio encarregada de gestionar els events Touch
local function onTouch(event)
    if event.phase == "ended" then
        if event.isBackKey or event.target.id == "btnClose" then
            if scene.params.isLollipop then
                local options = {
                    time = 300,
                    effect = "crossFade",
                    params = scene.params,
                    isModal = true
                }
                options.params.jackpot = nil
                options.params.config = nil
                AZ.S.showOverlay("slotmachine.slotmachine", options)
            else
                AZ.S.hideOverlay("crossFade", 300)
            end
        end
    end
end

function scene.onBackTouch()
	onTouch({ phase = "ended", isBackKey = true })
end

--- Funció checkBoosterDisponibility
-- És la funció que comprova que hi hagi el booster disponible
local function checkBoosterDisponibility(name)
    if name ~= "coin" and name ~= "lollipop" then
        for i = 1, #AZ.shopInfo.shop.weapons do
            if AZ.shopInfo.shop.weapons[i].name == name.."_name" then
                if (AZ.userInfo.weapons[i+1].boughtLevel > 2) then
                    return false
                end
            end
        end
    end
    return true
end

--- Funció addObjectEntry(atlas, path_lq, path_hq, iconName, x, y)
-- És la funció encarregada de crear el contingut de les entrades per els
-- diferents possibles premis
-- @param atlas És l'spriteSheet del qual s'han d'extreure el elements gràfics
-- @param path_lq És l'índex de les imatges amb baixa qualitat dels premis
-- @param paht_hq És l'índes de les imatges amb alta qualitat dels premis
-- @param iconName És el nom del premi
-- @params x, y Són les posicions base en les quals es basarà la posició de les imatges
local function addObjectEntry(atlas,path_lq,path_hq,iconName,x,y)
    local entry = {}
    entry = display.newGroup() 
    x = x*_R
    y = y*_R
    entry.lsBracket = bitmap("claudator2",atlas,x,y)
    entry.lsBracket.anchorX = 0
    entry.lsBracket.anchorY = 0
    
    entry.icLowQ    = bitmap(path_lq,atlas,entry.lsBracket.x+15*_R,y+5*_R)
    entry.icLowQ.xScale, entry.icLowQ.yScale = _R*0.75, _R*0.75
    entry.icLowQ.anchorX = 0
    entry.icLowQ.anchorY = 0
    
    entry.icLowQ2   = bitmap(path_lq, atlas, entry.icLowQ.x+60*_R, y+5*_R)
    entry.icLowQ2.xScale, entry.icLowQ2.yScale = _R*0.75, _R*0.75
    entry.icLowQ2.anchorX = 0
    entry.icLowQ2.anchorY = 0
    
    entry.icLowQ3   = bitmap(path_lq, atlas, entry.icLowQ2.x+60*_R, y+5*_R)
    entry.icLowQ3.xScale, entry.icLowQ3.yScale = _R*0.75, _R*0.75
    entry.icLowQ3.anchorX = 0
    entry.icLowQ3.anchorY = 0
    
    entry.rsBracket = bitmap("claudator1",atlas,entry.icLowQ3.x+60*_R,y)
    entry.rsBracket.anchorX = 0
    entry.rsBracket.anchorY = 0
    
    entry.icHighQ  = nil
    if iconName ~= "coin" then
        entry.icHighQ = bitmap(path_hq,atlas,entry.rsBracket.x+40*_R,y+5*_R)
        entry.icHighQ.anchorX = 0
        entry.icHighQ.anchorY = 0
    end
    
    --Es calcula quin és el booster que es pot desbloquejar per cada arma
    local qttPrize = nil
    if iconName == "lollipop" then
        qttPrize = 7
    elseif iconName == "coin" then
        qttPrize = scene.params.jackpot
    else
        for i=1,#AZ.shopInfo.shop.weapons do
            if AZ.shopInfo.shop.weapons[i].name == iconName.."_name" then
                qttPrize = AZ.shopInfo.shop.weapons[i].boosterData[AZ.userInfo.weapons[i+1].boughtLevel + 1].quantity
            end
        end
    end
    
    entry.qtt = nil
    if iconName == "coin" then
        entry.qtt = addText("quantitat", tostring(qttPrize), {r = 0.15, g = 0.15, b = 0.15, a = 0.5, }, INTERSTATE_REGULAR, entry.rsBracket.x+95*_R, y+28*_R, 50*_R)
    else
        entry.qtt = addText("quantitat", tostring(qttPrize), {r = 0.15, g = 0.15, b = 0.15, a = 0.5, }, INTERSTATE_REGULAR, entry.icHighQ.x+95*_R, y+28*_R, 60*_R)
    end
    entry.qtt.anchorX = 0.5
    entry.qtt.anchorY = 0.5
    
    entry:insert(entry.lsBracket)
    entry:insert(entry.rsBracket)
    if iconName ~= "coin" then
        entry:insert(entry.icHighQ)
    end
    entry:insert(entry.icLowQ)
    entry:insert(entry.icLowQ2)
    entry:insert(entry.icLowQ3)
    entry:insert(entry.qtt)
    
    return entry
end

--- Funció addScrollView()
-- És la funció encarregada de crear l'scrollView dels possibles premis
local function addScrollView(sheetInfo)
    
   scene.Popup.listScroll = scene.widget.newScrollView(
        {
            width = 355*_R,
            height = 293*_R,
            scrollWidth = 300*_R,
            scrollHeight = 1000*_R,
            horizontalScrollDisabled = true,
            isBounceEnabled = false,
            hideBackground = true
        }
    )
    
    scene.Popup.listScroll.anchorX = 0
    scene.Popup.listScroll.anchorY = 0
    scene.Popup.listScroll.x = _W*0.5-173*_R
    scene.Popup.listScroll.y = _H*0.5+7*_R
    
    local j = 0
    for i=1,#scene.params.config do
        local iconName = scene.params.config[i]
        if not (iconName == "grave" or iconName == "skull") and checkBoosterDisponibility(iconName) then
            scene.Popup.listScroll:insert(addObjectEntry(sheetInfo, scene.iconName[1][iconName], scene.iconName[2][iconName], iconName, 0, 70*j))
            j = j + 1
        end
    end
    
    return scene.Popup.listScroll
    
end

local function createBtn(params)--(id, x, y, btnIndex, txtParams)
	local btn = AZ.ui.newTouchButton({ id = params.id, x = params.x, y = params.y, touchSound = params.touchSound or AZ.soundLibrary.buttonSound, releaseSound = params.releaseSound, txtParams = params.txtParams, btnIndex = params.btnIndex,  imageSheet = scene.myImageSheet, onTouch = onTouch })
	btn:setScale(SCALE_BIG*1.2, SCALE_BIG*1.2)
	scene.Popup:insert(btn)
	return btn
end

local function noTouch(event)
	return true
end

function scene:init()
    scene.Popup = display.newGroup()
    
    local sheetInfo = require "popups.assets.slotmachine3"
    scene.myImageSheet = graphics.newImageSheet("popups/assets/slotmachine3.png",sheetInfo:getSheet())
    
    scene.Popup.translucidBg = display.newRect(0, 0, _W+200*_R, _H)
    scene.Popup.translucidBg.x, scene.Popup.translucidBg.y = _W*0.5, _H*0.5
    scene.Popup.translucidBg:setFillColor({0,0,0,0.5})
    scene.Popup.translucidBg.alpha = 0.5
	scene.Popup.translucidBg.id = "btnClose"
	scene.Popup.translucidBg:addEventListener("touch", onTouch)
    scene.view:insert(scene.Popup.translucidBg)
    
    scene.view:insert(scene.Popup)
    
    scene.Popup.background = display.newImage(scene.myImageSheet, sheetInfo:getFrameIndex("jackpot"))
    scene.Popup.background:scale(_R,_R)
    scene.Popup.background.x, scene.Popup.background.y = _W*0.5, _H*0.5
	scene.Popup.background:addEventListener("touch", noTouch)
    scene.Popup:insert(scene.Popup.background)
    
	scene.btnClose = createBtn({id = "btnClose", x = _W*0.5+185*_R, y = _H*0.5-300*_R, btnIndex = sheetInfo:getFrameIndex("cerrar"), touchSound = AZ.soundLibrary.closePopupSound})
    
    local g1 = bitmap("ic_slot_hueso", sheetInfo, 0, 0)
    local g2 = bitmap("ic_slot_hueso", sheetInfo, 0, 0)
    local g3 = bitmap("ic_slot_hueso", sheetInfo, 0, 0)

    local bones = display.newGroup()
    
    bones:insert(g1)
    bones:insert(g2)
    bones:insert(g3)
    
    bones:scale(_R, _R)
    bones.x = _W*0.5
    bones.y = _H*0.5-210*_R
    g1.x = g1.x - g1.contentWidth*1.2
    g3.x = g2.x + g2.contentWidth*1.2

    scene.Popup:insert(bones)
    
    scene.Popup:insert(addScrollView(sheetInfo))
    
end

function scene:createScene(event)
    scene.params = event.params
    scene:init()
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener("createScene", scene)

return scene