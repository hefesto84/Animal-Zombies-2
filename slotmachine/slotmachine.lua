
local widget = require "widget"

local scene = AZ.S.newScene()

--######################################################################--
--#                                                                    #--
--#                      Declaració de variables                       #--
--#                                                                    #--
--######################################################################--

local RandomizerManager = require "slotmachine.module.RandomizerManager"
local direction = nil
scene.SlotMachine = display.newGroup()
scene.isLollipop = nil

scene.R = nil
scene.W = display.contentWidth
scene.H = display.contentHeight
scene.debug = true
scene.widget = require "widget" 
scene.blackbg = nil
scene.spinSheetData = {}
scene.spinSheet = nil
scene.spinData1 = { name="spin1", start=1, count=4, time = 150, loopCount = 10 }
scene.spinData2 = { name="spin2", frames={ 3, 4, 1, 2}, time=150, loopCount = 12 }
scene.spinData3 = { name="spin3", frames={ 4, 1, 3, 2}, time=150, loopCount = 14 }
scene.spin1 = nil
scene.spin2 = nil
scene.spin3 = nil
scene.slotColumnsContainer = nil
scene.slotColumnsCover = nil
scene.slotColumn = {}
scene.slotColumnIcons = {}
scene.TAG = " SlotMachine.lua] ==> "
scene.RESOURCES_PATH = "slotmachine/assets/"
scene.config = nil
scene.params = nil
scene.result = {}
scene.prizeName = nil
scene.prizeAmount = nil
scene.jackpot = AZ.userInfo.jackpot
scene.handle = nil
scene.noTouch = nil
scene.handleTimer = nil
scene.winLights = {}
scene.background = nil
scene.winLightsTransition = nil
local timerID = nil
local timerID2 = nil
local LOSE_LIGHTS_FILL = {0.6, 0.1, 0.1}
local NORMAL_LIGHTS_TO_RIGHT_FILL = {0.85, 0.65, 0.13}
local NORMAL_LIGHTS_TO_LEFT_FILL = {1, 1, 0.8}
local WIN_LIGHTS_FILL = {0.35, 1, 0.15}

-- Definición de los layers
scene.LAYER_BACKGROUND = 1
scene.LAYER_UI = 2
scene.LAYER_FX = 3
scene.LAYER_OB = 4
 
-- Definición de los grupos
scene.bg = nil
scene.ui = nil
scene.fx = nil
scene.ob = nil

-- Sprite atlas
scene.slotMachineAtlas = nil
scene.slotMachinePopupAtlas = nil
scene.slotMachineSheet = nil
scene.slotMachinePopupSheet = nil

-- Configuración de las monedas
scene._coins = 0
scene.COLOR_WHITE = {r = 255,     g = 255,    b = 255,    a = 255}
scene.COLOR_BLACK = {r = 0,       g = 0,      b = 0,      a = 0.7 }
scene.FONT = native.systemFont

-- Variables SlotMachine
scene.isPlaying = false

local timerId = nil

-- Funcions que necessiten ser creades amb antelació
local ressetLights, cancelLightsTransitions, setLightsGroupsAlpha, setLightsAlpha, setLightsTint, doColumnBounce, displaySlotColumns, isPrize, createWinLights, lightsAnimLose, lightsAnimWin

scene.iconName = {
   {["gaviot"] = "ic_slot_paloma", ["stinkBomb"] = "ic_slot_bomba", ["coin"] = "ic_slot_moneda", ["deathBox"] = "ic_slot_jaulamuerte", ["hose"] = "ic_slot_manguera", ["iceCube"] = "ic_slot_hielo", ["lifeBox"] = "ic_slot_jaulabuena", ["thunder"] = "ic_slot_rayo", ["lollipop"] = "ic_slot_piruleta", ["rake"] = "ic_slot_rastrillo", ["stone"] = "ic_slot_piedra", ["trap"] = "ic_slot_tramparat", ["earthquake"] = "ic_slot_terremoto" , ["grave"] = "ic_slot_lapida", ["skull"] = "ic_slot_calavera"},
   {["gaviot"] = "ic_slot_paloma_h", ["stinkBomb"] = "ic_slot_bomba_h", ["coin"] = "ic_slot_moneda_h", ["deathBox"] = "ic_slot_jaulamuerte_h", ["hose"] = "ic_slot_manguera_h", ["iceCube"] = "ic_slot_hielo_h", ["lifeBox"] = "ic_slot_jaulabuena_h", ["thunder"] = "ic_slot_rayo_h", ["lollipop"] = "ic_slot_piruleta_h", ["rake"] = "ic_slot_rastrillo_h", ["stone"] = "ic_slot_piedra_h", ["trap"] = "ic_slot_tramparat_h", ["earthquake"] = "ic_slot_terremoto_h"}
}

--- Funcions de debug
local function log(message)
   if(scene.debug) then
        --print("["..os.date( "%c" )..scene.TAG..message)
   end
end

local function dump()
    if(scene.debug) then
        local d = system.getInfo("textureMemoryUsed")/1024000
        local ts = system.getInfo("maxTextureSize")
        local dp = tonumber(string.format("%." .. (3 or 0) .. "f", (collectgarbage("count")/1024)))
        log("Memory Used: "..d.." MB | Max Texture Size: "..ts.." MB")  
        log("Memory allocated by LUA: "..dp.." MB")  
    end
end

---Funcio per activar o desactivar els diferents botons
local function activateDeactivateButtons(active)
	if not scene.isLollipop then
		scene.btnShop.isActive = active
		scene.btnExit.isActive = active
	end
    scene.btnPrizes.isActive = active
    scene.noTouch.isHitTestable = not active
end


--######################################################################--
--#                                                                    #--
--#            Creació dels layers i la gestió dels fills              #--
--#                                                                    #--
--######################################################################--

--- És la funció encarregada d'inicialitzar els layers de la màquina
local function setupLayers()
    scene.SlotMachine:insert(scene.bg)
    scene.SlotMachine:insert(scene.fx)
    scene.SlotMachine:insert(scene.ob)
    scene.SlotMachine:insert(scene.ui)
end

--- És la funció que permet inserir elements al layer corresponent
local function insertInGrp(object, layer)
    if layer == scene.LAYER_BACKGROUND then
        scene.bg:insert(object)
        return
    end
    if layer == scene.LAYER_FX then
        scene.fx:insert(object)
        return
    end
    if layer == scene.LAYER_UI then
        scene.ui:insert(object)
        return
    end
    if layer == scene.LAYER_OB then
        scene.ob:insert(object)
        return
    end
end

--- És la funció que premet eliminar elements gràfics de la pantalla
local function remove(object, layer)
    if layer == scene.LAYER_BACKGROUND then
        scene.bg:remove(object)
        return
    end
    if layer == scene.LAYER_FX then
        scene.fx:remove(object)
        return
    end
    if layer == scene.LAYER_UI then
        scene.ui:remove(object)
        return
    end 
    if layer == scene.LAYER_OB then
        scene.ob:remove(object)
        return
    end
end

--- És la funció encarregada d'inicialitzar els spriteSheets que es faran servir
local function setupSprites()
    scene.slotMachineAtlas = require "slotmachine.assets.sheet.Sprite2_slotmachine"
    scene.slotMachinePopupAtlas = require "slotmachine.assets.sheet.slotmachine3"
    scene.slotMachineSheet = graphics.newImageSheet( scene.RESOURCES_PATH.."Sprite2_slotmachine.png", scene.slotMachineAtlas:getSheet())
    scene.slotMachinePopupSheet = graphics.newImageSheet( scene.RESOURCES_PATH.."slotmachine3.png", scene.slotMachinePopupAtlas:getSheet())
    scene.spinSheetData = { width=89, height=205, numFrames=4, sheetContentWidth=256, sheetContentHeight=512 }
    scene.spinSheet = graphics.newImageSheet( "slotmachine/assets/slot_anim.png", scene.spinSheetData )
end

--- És la funció encarregada de mostrar les monedes que hi ha en cada moment
local function setCurrentCoins(coins)
	if coins ~= scene._coins then
		scene._coins = coins   
		log("Ponemos los coins"..scene._coins)
		for i=1, scene.ui.numChildren, 1 do
			if scene.ui[i].name == "txtCoins" then
				transition.to(
					scene.ui[i], 
					{
						time = 200, 
						alpha = 0, 
						transition = easing.inOutExpo, 
						iterations = 4,
						onRepeat = function() 
							transition.to(
								scene.ui[i],
								{
									time = 200,
									alpha = 1, 
									transition = easing.inOutExpo
								}
							)
							
							if scene.ui[i] then
								scene.ui[i].text = AZ.utils.coinFormat(scene._coins) 
							end
						end
					}
				)
			end
		end
		AZ.userInfo.money = scene._coins
	end
end

--######################################################################--
--#                                                                    #--
--#                      Gestió d'events touch                         #--
--#                                                                    #--
--######################################################################--

--- Funció que controla els events thouch 
local function onClick(event)

    local name = nil 
    if event.target ~= nil then
        name = event.target.id
    else
        name = event.id
    end
        
    local phase = event.phase
    
    if phase == "ended" or phase == "release" then
        if name == "btnShop" and event.target.isWithinBounds and event.target.isActive then
			direction = "shop"
			local options = {
				effect = "crossFade",
				time = 250,
				params = scene.params
			}
			if options.params.source then
				options.params.source[#options.params.source+1] = "slotmachine.slotmachine"
			else
				options.params.source = { "slotmachine.slotmachine" }
			end
			options.params.prizeName = nil
			AZ.S.gotoScene("shop.shop", options)
        elseif event.isBackKey or (name == "btnExit" and event.target.isWithinBounds and event.target.isActive) then
            direction = "source"
            if scene.isLollipop then
                local options = {
                    effect = "crossFade",
                    time = 300,
                    params = scene.params,
                    isModal = true
                }
                AZ.S.showOverlay("popups.popupwolollipops", options)
           else
                local options = {
                    effect = "slideRight",
                    time = 300,
                    params = scene.params
                }
               direction = scene.params.source[#scene.params.source]
				options.params.source[#options.params.source] = nil
				AZ.S.gotoScene(direction, options)
            end
        elseif name == "btnPrizes" then
			local options = {
				   effect = "crossFade",
				   time = 300,
				   params = scene.params,
				   isModal = true
			  }
			  options.params.config = scene.config
			  options.params.jackpot = scene.jackpot  
			  AZ.S.showOverlay("popups.popupslotprizelist",options)
        end
    end  
end

function scene.onBackTouch()
	if not scene.isPlaying then
		onClick({ phase = "ended", isBackKey = true })
	end
end

--######################################################################--
--#                                                                    #--
--#             Funcions de creació del elements gràfics               #--
--#                                                                    #--
--######################################################################--

--- És la funció encarregada de crear les imatges que es mostren per pantalla
local function bitmap(image,atlas,x,y)
   local sheet

   if atlas then
       if atlas == scene.slotMachineAtlas then
           sheet = scene.slotMachineSheet
       end
       if atlas == scene.slotMachinePopupAtlas then
           sheet = scene.slotMachinePopupSheet
       end
   else
      log("Error cargando atlas/sheets") 
      return
   end
   
   local bmp = nil
   if type(image) == "number" then
       bmp = display.newImage( sheet , image)
   else
       bmp = display.newImage( sheet , atlas:getFrameIndex(image))
   end
   
   if(bmp) then
       bmp.x,bmp.y = x,y
       bmp:scale(scene.R,scene.R)
       return bmp
   else
       log("Error cargando imagen: "..image)
       return
   end
end

local function background(path,atlas,x,y)
    return bitmap(path,atlas,x,y)
end

--- Funció encarregada de crear la palanca de la màquina
-- @param name És el nom de la palanca
-- @param atlas És l'spriteSheet on es troba la imatge
-- @param path É l'índex on hi ha la imatge
-- @params x, y Són les coordenades on ha d'anar la palanca
local function toggle(name,atlas,path,x,y)
    local t = display.newGroup()
    
    local function doNothing(event)
        return true
    end
    
    local function evPlay()
		scene:play()
    end
    
    local function handleListener( event )
        if event.phase == "began" then
            if scene.handleTimer then
                   timer.cancel(scene.handleTimer)
					scene.hendleTimer = nil
            end
			AZ.audio.playFX(AZ.soundLibrary.slotToggleDownSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
            return true
        end
        if event.phase == "ended" then
			AZ.audio.playFX(AZ.soundLibrary.slotToggleDownSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
            scene.handle:setValue(event.value)
            if scene.handle.value == 0 or scene.handle.value == 1 then
                if timerId then
                   timer.cancel(timerId)
					timerId = nil
                end
                timerId = timer.performWithDelay(1, function() scene.handle:setValue(math.min((scene.handle.value + 4), 100)) end, 25)
				 
                ressetLights()
				 
                if (scene._coins >= 10) then
                    evPlay()
					activateDeactivateButtons(false)
                else
                   local options = {
                       effect = "crossFade",
                       time = 300,
                       params = scene.params,
                       isModal = true
                   }
                   if options.params.source then
						options.params.source[#options.params.source+1] = "slotmachine.slotmachine"
					else
						options.params.source = { "slotmachine.slotmachine" }
					end
					 
                    if scene._coins == 0 then
                        direction = "bank"
                        AZ.S.showOverlay("popups.popupwomoney",options)
                    else
                        direction = "buyCoins"
                        AZ.S.showOverlay("popups.popupnemoney",options)
                    end
                end
            else
                timerId = timer.performWithDelay(1, function() scene.handle:setValue(math.min((scene.handle.value + 4), 100)) end, 25)
            end
                
            return true
        end
    end
   
    scene.handle = widget.newSlider({
        left = x-40*scene.R,
        top = y-20*scene.R,
        height = 150*scene.R,
        value = 100,
        id = "handle",
        orientation = "vertical",
        listener = handleListener,
        sheet = scene.slotMachineSheet,
        handleFrame = atlas:getFrameIndex(path),
        handleWidth = 80*scene.R,
        handleHeight = 83*scene.R,
        frameWidth = 0,
        frameHeight = 0
    })
    t:insert(scene.handle)
    
    scene.noTouch = display.newRect(0,0,80*scene.R,250*scene.R)
    scene.noTouch.x, scene.noTouch.y = x-6*scene.R, y+80*scene.R
    scene.noTouch.anchorX, scene.noTouch.anchorY = 0.5, 0.5
    scene.noTouch.alpha = 0
    scene.noTouch.isHitTestable = false
    scene.noTouch:addEventListener("touch", doNothing)
    t:insert(scene.noTouch)
    
    t.name = name
    return t
end

--- Funció per crear les icones de les armes
-- @param name Nom de la icona
-- @param atlas És l'spriteSheet on hi ha la icona
-- @param path És l'índex en el que es troba la icona
-- @params x, y Són les coordenades on se situarà la icona
local function icon(name,atlas,path,x,y,num)
    local ic = display.newGroup()
    local u = bitmap(path,atlas,x,y)
    u.x = x
    u.y = y
    if num ~= 2 then
        u.xScale, u.yScale = scene.R*0.75, scene.R*0.75
    end
        
    ic:insert(u)
    ic.name = name
    return ic
end

--- Función per crear texts escalats
-- Aquesta funció crea textos escalats a la resolució que toca sense que existeixi
-- un sobreconsum de memòria
-- @param name Nom del text
-- @param str String amb el text que mostrem
-- @param color Array amb els colors de la font
-- @param font Font per el text
-- @param x Coordenada X on colocarem el text
-- @param y Coordenada Y on colocarem el text 
-- @param size Tamany del text que volem mostrar
local function addText(name,str, color, font, x, y, size)
    local t = display.newText(str, 0, 0, font, size*scene.R)
    t:setFillColor(color.r, color.g, color.b, color.a)
    t.x = x
    t.y = y
    t.name = name
    t.anchorX = 0.5
    t.anchorY = 0.5
    return t
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

local function lollipopsWin()
	
	transition.to(scene.bg, {time = 400, alpha = 0})
	transition.to(scene.ui, {time = 400, alpha = 0})
	transition.to(scene.fx, {time = 400, alpha = 0})
	transition.to(scene.blackbg, {time = 400, alpha = 0})
	transition.to(scene.slotColumnsCover, {time = 400, alpha = 0})
	
	for i = 1, 3 do
		transition.to(scene.slotColumnIcons[i][1], {time = 400, alpha = 0})
		transition.to(scene.slotColumnIcons[i][3], {time = 400, alpha = 0})
	end
	
	local options = {
		effect = "crossFade",
		time = 300,
		params = scene.params,
		isModal = true
	}
	timer.performWithDelay(400, function() AZ.S.showOverlay("popups.popupslotlollipopswin", options) end)
end

--- Funció setPrize
-- És la funció encarregada de decidir com s'ha d'omplir el popup de premis
local function setPrize()
	
	local options = {
		effect = "crossFade",
		time = 300,
		params = scene.params,
		isModal = true
	}
    
    if (scene.result[1].name == scene.result[2].name and scene.result[1].name == scene.result[3].name) then
        scene.prizeName = scene.result[2].name
        if checkBoosterDisponibility(scene.prizeName) then
			lightsAnimWin()
			options.params.prizeName = scene.prizeName
			if scene.isLollipop then
				AZ.audio.playFX(AZ.soundLibrary.slotWinSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
				timer.performWithDelay(1000, function() activateDeactivateButtons(true); lollipopsWin() end)
			else
				if scene.result[1].name == "coin" then
					AZ.audio.playFX(AZ.soundLibrary.slotJackpodSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
				else
					AZ.audio.playFX(AZ.soundLibrary.slotWinSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
				end
				options.params.jackpot = scene.jackpot
				scene.prizeType = "threePrize"
				timer.performWithDelay(1000, function() activateDeactivateButtons(true); AZ.S.showOverlay("popups.popupslotthree", options) end)
			end
        else
			AZ.audio.playFX(AZ.soundLibrary.slotLoseSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
			lightsAnimLose()
			scene.prizeType = "noPrize"
			activateDeactivateButtons(true)
        end
    elseif ((scene.result[1].name == scene.result[2].name) or (scene.result[2].name == scene.result[3].name))then
        scene.prizeName = scene.result[2].name
        if checkBoosterDisponibility(scene.prizeName) then
			AZ.audio.playFX(AZ.soundLibrary.slotWinSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
			lightsAnimWin()
			scene.prizeType = "twoPrize"   
			options.params.prizeName = scene.prizeName
			timer.performWithDelay(1000, function() activateDeactivateButtons(true); AZ.S.showOverlay("popups.popupslottwo", options) end)
        else
			AZ.audio.playFX(AZ.soundLibrary.slotLoseSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
			lightsAnimLose()
			scene.prizeType = "noPrize"
			activateDeactivateButtons(true)
        end
    elseif (scene.result[1].name == scene.result[3].name) then
        scene.prizeName = scene.result[1].name
        if checkBoosterDisponibility(scene.prizeName) then
			AZ.audio.playFX(AZ.soundLibrary.slotWinSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
			lightsAnimWin()
			scene.prizeType = "twoPrize"
			options.params.prizeName = scene.prizeName
			timer.performWithDelay(1000, function() activateDeactivateButtons(true); AZ.S.showOverlay("popups.popupslottwo", options) end)
        else
			AZ.audio.playFX(AZ.soundLibrary.slotLoseSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
			lightsAnimLose()
			scene.prizeType = "noPrize"
			activateDeactivateButtons(true)
        end
    end
    
end

--######################################################################--
--#                                                                    #--
--#          Animació de les llums de la màquina per defecte           #--
--#                                                                    #--
--######################################################################--

function lightsAnimDefaultSecond()
	local function nextAnim13()
		local function hide()
			transition.to(scene.winLights, { time = 100, alpha = 0, onStart = function() transition.pause("showLightsBlock2") end, onComplete = function() transition.resume("showLightsBlock2") end })
		end
		--setLightsTint(NORMAL_LIGHTS_TO_RIGHT_FILL)
		scene.winLights.alpha = 0
		setLightsAlpha(1)
		transition.to(scene.winLights, { time = 100, alpha = 1, tag = "showLightsBlock2", iterations = 3, onRepeat = hide, onComplete = lightsAnimDefault })
	end
	local function nextAnim12()
		transition.to(scene.winLights.leftBottomBar1, { time = 150, alpha = 0, onComplete = nextAnim13 })
	end
	local function nextAnim11()
		transition.to(scene.winLights.leftBottomBar1, { time = 75, alpha = 1, onComplete = nextAnim12 })
		transition.to(scene.winLights.leftBottomBar2, { time = 150, alpha = 0 })
	end
	local function nextAnim10()
		transition.to(scene.winLights.leftBottomBar2, { time = 75, alpha = 1, onComplete = nextAnim11 })
		transition.to(scene.winLights.leftBottomBar3, { time = 150, alpha = 0 })
	end
	local function nextAnim9()
		transition.to(scene.winLights.leftBottomBar3, { time = 75, alpha = 1, onComplete = nextAnim10 })
		transition.to(scene.winLights.leftMid, { time = 150, alpha = 0 })
	end
	local function nextAnim8()
		transition.to(scene.winLights.leftMid, { time = 75, alpha = 1, onComplete = nextAnim9 })
		transition.to(scene.winLights.leftBottomWing, { time = 150, alpha = 0 })
	end
	local function nextAnim7()
		transition.to(scene.winLights.leftBottomWing, { time = 75, alpha = 1, onComplete = nextAnim8 })
		transition.to(scene.winLights.leftTopWing, { time = 150, alpha = 0 })
	end
	local function nextAnim6()
		transition.to(scene.winLights.leftTopWing, { time = 75, alpha = 1, onComplete = nextAnim7 })
		transition.to(scene.winLights.eyes, { time = 150, alpha = 0 })
	end
	local function nextAnim5()
		transition.to(scene.winLights.eyes, { time = 75, alpha = 1, onComplete = nextAnim6 })
		transition.to(scene.winLights.rightTopWing, { time = 150, alpha = 0 })
	end
	local function nextAnim4()
		transition.to(scene.winLights.rightTopWing, { time = 75, alpha = 1, onComplete = nextAnim5 })
		transition.to(scene.winLights.rightBottomWing, { time = 150, alpha = 0 })
	end
	local function nextAnim3()
		transition.to(scene.winLights.rightBottomWing, { time = 75, alpha = 1, onComplete = nextAnim4 })
		transition.to(scene.winLights.rightMid, { time = 150, alpha = 0 })
	end
	local function nextAnim2()
		transition.to(scene.winLights.rightMid, { time = 75, alpha = 1, onComplete = nextAnim3 })
		transition.to(scene.winLights.rightBottomBar3, { time = 150, alpha = 0 })
	end
	local function nextAnim1()
		transition.to(scene.winLights.rightBottomBar3, { time = 75, alpha = 1, onComplete = nextAnim2 })
		transition.to(scene.winLights.rightBottomBar2, { time = 150, alpha = 0 })
	end
	local function nextAnim()
		transition.to(scene.winLights.rightBottomBar2, { time = 75, alpha = 1, onComplete = nextAnim1 })
		transition.to(scene.winLights.rightBottomBar1, { time = 150, alpha = 0 })
	end
	setLightsTint(NORMAL_LIGHTS_TO_RIGHT_FILL)
	scene.winLights.alpha = 1
	setLightsAlpha(0)
	transition.to(scene.winLights.rightBottomBar1, { delay = 75, time = 75, alpha = 1, onComplete = nextAnim })
end

function lightsAnimDefault()
	local function nextAnim13()
		local function hide()
			transition.to(scene.winLights, { time = 100, alpha = 0, onStart = function() transition.pause("showLightsBlock") end, onComplete = function() transition.resume("showLightsBlock") end })
		end
		--setLightsTint(NORMAL_LIGHTS_TO_RIGHT_FILL)
		scene.winLights.alpha = 0
		setLightsAlpha(1)
		transition.to(scene.winLights, { time = 100, alpha = 1, tag = "showLightsBlock", iterations = 3, onRepeat = hide, onComplete = lightsAnimDefaultSecond })
	end
	local function nextAnim12()
		transition.to(scene.winLights.rightBottomBar1, { time = 150, alpha = 0, onComplete = nextAnim13 })
	end
	local function nextAnim11()
		transition.to(scene.winLights.rightBottomBar1, { time = 75, alpha = 1, onComplete = nextAnim12 })
		transition.to(scene.winLights.rightBottomBar2, { time = 150, alpha = 0 })
	end
	local function nextAnim10()
		transition.to(scene.winLights.rightBottomBar2, { time = 75, alpha = 1, onComplete = nextAnim11 })
		transition.to(scene.winLights.rightBottomBar3, { time = 150, alpha = 0 })
	end
	local function nextAnim9()
		transition.to(scene.winLights.rightBottomBar3, { time = 75, alpha = 1, onComplete = nextAnim10 })
		transition.to(scene.winLights.rightMid, { time = 150, alpha = 0 })
	end
	local function nextAnim8()
		transition.to(scene.winLights.rightMid, { time = 75, alpha = 1, onComplete = nextAnim9 })
		transition.to(scene.winLights.rightBottomWing, { time = 150, alpha = 0 })
	end
	local function nextAnim7()
		transition.to(scene.winLights.rightBottomWing, { time = 75, alpha = 1, onComplete = nextAnim8 })
		transition.to(scene.winLights.rightTopWing, { time = 150, alpha = 0 })
	end
	local function nextAnim6()
		transition.to(scene.winLights.rightTopWing, { time = 75, alpha = 1, onComplete = nextAnim7 })
		transition.to(scene.winLights.eyes, { time = 150, alpha = 0 })
	end
	local function nextAnim5()
		transition.to(scene.winLights.eyes, { time = 75, alpha = 1, onComplete = nextAnim6 })
		transition.to(scene.winLights.leftTopWing, { time = 150, alpha = 0 })
	end
	local function nextAnim4()
		transition.to(scene.winLights.leftTopWing, { time = 75, alpha = 1, onComplete = nextAnim5 })
		transition.to(scene.winLights.leftBottomWing, { time = 150, alpha = 0 })
	end
	local function nextAnim3()
		transition.to(scene.winLights.leftBottomWing, { time = 75, alpha = 1, onComplete = nextAnim4 })
		transition.to(scene.winLights.leftMid, { time = 150, alpha = 0 })
	end
	local function nextAnim2()
		transition.to(scene.winLights.leftMid, { time = 75, alpha = 1, onComplete = nextAnim3 })
		transition.to(scene.winLights.leftBottomBar3, { time = 150, alpha = 0 })
	end
	local function nextAnim1()
		transition.to(scene.winLights.leftBottomBar3, { time = 75, alpha = 1, onComplete = nextAnim2 })
		transition.to(scene.winLights.leftBottomBar2, { time = 150, alpha = 0 })
	end
	local function nextAnim()
		transition.to(scene.winLights.leftBottomBar2, { time = 75, alpha = 1, onComplete = nextAnim1 })
		transition.to(scene.winLights.leftBottomBar1, { time = 150, alpha = 0 })
	end
	setLightsTint(NORMAL_LIGHTS_TO_RIGHT_FILL)
	scene.winLights.alpha = 1
	setLightsAlpha(0)
	transition.to(scene.winLights.leftBottomBar1, { delay = 75, time = 75, alpha = 1, onComplete = nextAnim })
end

--######################################################################--
--#                                                                    #--
--#           Animació de les llums de la màquina al perdre            #--
--#                                                                    #--
--######################################################################--

local function eyesLightsAnimLose()
    local function hide()
        transition.to(scene.winLights.eyes, {time = 75, alpha = 1, onComplete = eyesLightsAnimLose})
    end
    transition.to(scene.winLights.eyes, {time = 75, alpha = 0, onComplete = hide})
end

local function wingsLightsAnimLose()
    local function wingsLightsHide()
        transition.to(scene.winLights.leftTopWing, {time = 125, delay = 50, alpha = 0, onComplete = wingsLightsAnimLose})
        transition.to(scene.winLights.leftBottomWing, {time = 100, alpha = 0})
        transition.to(scene.winLights.rightTopWing, {time = 125, delay = 50, alpha = 0})
        transition.to(scene.winLights.rightBottomWing, {time = 100, alpha = 0})
    end
    
    transition.to(scene.winLights.leftTopWing, {time = 125, delay = 50, alpha = 1, onComplete = wingsLightsHide})
    transition.to(scene.winLights.leftBottomWing, {time = 100, alpha = 1})
    transition.to(scene.winLights.rightTopWing, {time = 125, delay = 50, alpha = 1})
    transition.to(scene.winLights.rightBottomWing, {time = 100, alpha = 1})
end

local function topLightsAnimLose()
    eyesLightsAnimLose()
    wingsLightsAnimLose()
end

local function midLightsAnimLose()
    local function midLightsHide()
        transition.to(scene.winLights.leftMid, {time = 125, delay = 50, alpha = 0, onComplete = midLightsAnimLose})
        transition.to(scene.winLights.rightMid, {time = 125, delay = 50, alpha = 0})
    end
    transition.to(scene.winLights.leftMid, {time = 125, delay = 0, alpha = 1, onComplete = midLightsHide})
    transition.to(scene.winLights.rightMid, {time = 125, delay = 0, alpha = 1})
end

local function botLeftLightsAnimLose()
    
    local function botLeftLightsHide()
        local function doThird()
            transition.to(scene.winLights.leftBottomBar1, {time = 50, delay = 0, alpha = 0, onComplete = botLeftLightsAnimLose})
        end
        local function doSecond()
            transition.to(scene.winLights.leftBottomBar2, {time = 50, delay = 0, alpha = 0, onComplete = doThird})
        end
        transition.to(scene.winLights.leftBottomBar3, {time = 50, delay = 0, alpha = 0, onComplete = doSecond })
    end
    
    local function doThird()
        transition.to(scene.winLights.leftBottomBar1, {time = 50, delay = 0, alpha = 1, onComplete = botLeftLightsHide})
    end
    local function doSecond()
        transition.to(scene.winLights.leftBottomBar2, {time = 50, delay = 0, alpha = 1, onComplete = doThird})
    end
    transition.to(scene.winLights.leftBottomBar3, {time = 50, delay = 0, alpha = 1, onComplete = doSecond })
end

local function botRightLightsAnimLose()
    
    local function botRightLightsHide()
        local function doThird()
            transition.to(scene.winLights.rightBottomBar1, {time = 50, delay = 0, alpha = 0, onComplete = botRightLightsAnimLose})
        end
        local function doSecond()
            transition.to(scene.winLights.rightBottomBar2, {time = 50, delay = 0, alpha = 0, onComplete = doThird})
        end
        transition.to(scene.winLights.rightBottomBar3, {time = 50, delay = 0, alpha = 0, onComplete = doSecond })
    end
    
    local function doThird()
        transition.to(scene.winLights.rightBottomBar1, {time = 50, delay = 0, alpha = 1, onComplete = botRightLightsHide})
    end
    local function doSecond()
        transition.to(scene.winLights.rightBottomBar2, {time = 50, delay = 0, alpha = 1, onComplete = doThird})
    end
    transition.to(scene.winLights.rightBottomBar3, {time = 50, delay = 0, alpha = 1, onComplete = doSecond })
end

local function botLightsAnimLose()
    botLeftLightsAnimLose()
    botRightLightsAnimLose()
end

function lightsAnimLose()
    setLightsTint(LOSE_LIGHTS_FILL)
    topLightsAnimLose()
    timerID = timer.performWithDelay(500, midLightsAnimLose)
    botLightsAnimLose()
    scene.winLights.alpha = 1
end

--######################################################################--
--#                                                                    #--
--#           Animació de les llums de la màquina al guanyar           #--
--#                                                                    #--
--######################################################################--

local function eyesLightsAnimWin()
    local function hide()
        transition.to(scene.winLights.eyes, {time = 75, alpha = 1, onComplete = eyesLightsAnimWin})
    end
    transition.to(scene.winLights.eyes, {time = 75, alpha = 0, onComplete = hide})
end

local function wingsLightsAnimWin()
    local function wingsLightsHide()
        transition.to(scene.winLights.leftTopWing, {time = 125, alpha = 0, onComplete = wingsLightsAnimWin})
        transition.to(scene.winLights.leftBottomWing, {time = 75, delay = 50, alpha = 0})
        transition.to(scene.winLights.rightTopWing, {time = 125, alpha = 0})
        transition.to(scene.winLights.rightBottomWing, {time = 75, delay = 50, alpha = 0})
    end
    
    transition.to(scene.winLights.leftTopWing, {time = 125, alpha = 1, onComplete = wingsLightsHide})
    transition.to(scene.winLights.leftBottomWing, {time = 75, delay = 50, alpha = 1})
    transition.to(scene.winLights.rightTopWing, {time = 125, alpha = 1})
    transition.to(scene.winLights.rightBottomWing, {time = 75, delay = 50, alpha = 1})
end

local function topLightsAnimWin()
    eyesLightsAnimWin()
    wingsLightsAnimWin()
end

local function midLightsAnimWin()
    local function midLightsHide()
        transition.to(scene.winLights.leftMid, {time = 125, delay = 50, alpha = 0, onComplete = midLightsAnimWin})
        transition.to(scene.winLights.rightMid, {time = 125, delay = 50, alpha = 0})
    end
    transition.to(scene.winLights.leftMid, {time = 125, delay = 0, alpha = 1, onComplete = midLightsHide})
    transition.to(scene.winLights.rightMid, {time = 125, delay = 0, alpha = 1})
end

local function botLeftLightsAnimWin()
    
    local function botLeftLightsHide()
        local function doThird()
            transition.to(scene.winLights.leftBottomBar3, {time = 50, delay = 0, alpha = 0, onComplete = botLeftLightsAnimWin})
        end
        local function doSecond()
            transition.to(scene.winLights.leftBottomBar2, {time = 50, delay = 0, alpha = 0, onComplete = doThird})
        end
        transition.to(scene.winLights.leftBottomBar1, {time = 50, delay = 0, alpha = 0, onComplete = doSecond })
    end
    
    local function doThird()
        transition.to(scene.winLights.leftBottomBar3, {time = 50, delay = 0, alpha = 1, onComplete = botLeftLightsHide})
    end
    local function doSecond()
        transition.to(scene.winLights.leftBottomBar2, {time = 50, delay = 0, alpha = 1, onComplete = doThird})
    end
    transition.to(scene.winLights.leftBottomBar1, {time = 50, delay = 0, alpha = 1, onComplete = doSecond })
end

local function botRightLightsAnimWin()
    
    local function botRightLightsHide()
        local function doThird()
            transition.to(scene.winLights.rightBottomBar3, {time = 50, delay = 0, alpha = 0, onComplete = botRightLightsAnimWin})
        end
        local function doSecond()
            transition.to(scene.winLights.rightBottomBar2, {time = 50, delay = 0, alpha = 0, onComplete = doThird})
        end
        transition.to(scene.winLights.rightBottomBar1, {time = 50, delay = 0, alpha = 0, onComplete = doSecond })
    end
    
    local function doThird()
        transition.to(scene.winLights.rightBottomBar3, {time = 50, delay = 0, alpha = 1, onComplete = botRightLightsHide})
    end
    local function doSecond()
        transition.to(scene.winLights.rightBottomBar2, {time = 50, delay = 0, alpha = 1, onComplete = doThird})
    end
    transition.to(scene.winLights.rightBottomBar1, {time = 50, delay = 0, alpha = 1, onComplete = doSecond })
end

local function botLightsAnimWin()
    botLeftLightsAnimWin()
    botRightLightsAnimWin()
end

function lightsAnimWin()
    setLightsTint(WIN_LIGHTS_FILL)
    timerID = timer.performWithDelay(500, topLightsAnimWin)
    midLightsAnimWin()
    timerID2 = timer.performWithDelay(500, botLightsAnimWin)
    scene.winLights.alpha = 1
end

--######################################################################--
--#                                                                    #--
--#                    Configuracio de la maquina                      #--
--#                                                                    #--
--######################################################################--

---Funció scene.configure(coins)
-- És la funció que configura les armes disponibles per a la màquina
-- @param coins Són les monedes disponibles per gastar
function scene.configure(coins)
    if not coins then
       scene._coins = 0
    else
       scene._coins = coins
    end
    
    scene.isLollipop = scene.params.isLollipop
    
    if scene.isLollipop then
        scene.prob = AZ.slotInfo.probabilities.stage[scene.params.currentStage].level[scene.params.currentLevel].lollipop
        scene.weapons = AZ.slotInfo.probabilities.stage[scene.params.currentStage].level[scene.params.currentLevel].lollipop.weapons
        RandomizerManager:configure(scene.params.currentLevel,scene.params.currentStage, scene.prob)
    else
        scene.prob = AZ.slotInfo.probabilities.stage[scene.params.stage].level[scene.params.level].regular
        scene.weapons = AZ.slotInfo.probabilities.stage[scene.params.stage].level[scene.params.level].regular.weapons
        RandomizerManager:configure(scene.params.level,scene.params.stage, scene.prob)
    end
    scene.config = {}

    for i = 1, #scene.weapons do
        scene.config[i] = scene.weapons[i].name
    end
end 

--######################################################################--
--#                                                                    #--
--#                    Configuracio de les columnes                    #--
--#                                                                    #--
--######################################################################--

--- Funció que fa efecte de bounce a la columna de l'Slot quan es para després de la tirada
function doColumnBounce(n)
    local bounceBack, bounceDown
    function bounceBack()
        transition.to(scene.slotColumn[n], {time = 300, y = scene.slotColumnY})
    end
    function bounceDown()
        transition.to(scene.slotColumn[n], {time = 200, y = scene.slotColumnY + 30*scene.R, onComplete = bounceBack})
    end
    transition.from(scene.slotColumn[n], {time = 100, y = scene.slotColumnY - 30*scene.R, onComplete = bounceDown})
end

--- Funció que ompla i mostra els rodets de la màquina 334*205
function displaySlotColumns(n, firstTime)
    if n == 1 and firstTime then
        scene.result = {RandomizerManager:getResult(), RandomizerManager:getResult(), RandomizerManager:getResult()}
        while (isPrize(scene.result[2])) do
            scene.result[2] = RandomizerManager:getResult()
        end
    elseif n == 1 then
        scene.result = {RandomizerManager:getResult(), --[[{{name = "coin", prob = 0.2},{name = "coin", prob = 0.2}, {name = "coin", prob = 0.2}}]] RandomizerManager:getResult(), RandomizerManager:getResult()}
--        if scene.isLollipop then
--            scene.result[2] = {{name = "lollipop", prob = 0.2},{name = "lollipop", prob = 0.2},{name = "lollipop", prob = 0.2}}
--        end
    end
        scene.slotColumn[n] = display.newGroup()
		scene.slotColumnIcons[n] = {}
        for i = 1, 3 do
			scene.slotColumnIcons[n][i] = icon("icon010"..i, scene.slotMachinePopupAtlas, scene.iconName[1][scene.result[i][n].name], 0, 0+90*scene.R*(i-1), i)
            scene.slotColumn[n]:insert(scene.slotColumnIcons[n][i])--icon("icon010"..i, scene.slotMachinePopupAtlas, scene.iconName[1][scene.result[i][n].name], 0, 0+90*scene.R*(i-1), i))
        end
        scene.slotColumn[n].anchorChildren = true
        scene.slotColumn[n].anchorX, scene.slotColumn[n].anchorY = 0.5, 0.5
        scene.slotColumn[n].x, scene.slotColumn[n].y = scene.slotColumnX[n], scene.slotColumnY
        scene.slotColumnsContainer:insert(scene.slotColumn[n])
end

--######################################################################--
--#                                                                    #--
--#                    Configuracio de les llums                       #--
--#                                                                    #--
--######################################################################--

--- Funció per setejar l'alpha de cada llum
function setLightsAlpha(alpha)
    scene.winLights.leftTopWing.alpha = alpha
    scene.winLights.leftBottomWing.alpha = alpha
    scene.winLights.rightTopWing.alpha = alpha
    scene.winLights.rightBottomWing.alpha = alpha
    scene.winLights.eyes.alpha = alpha
    scene.winLights.leftMid.alpha = alpha
    scene.winLights.rightMid.alpha = alpha
    scene.winLights.leftBottomBar1.alpha = alpha
    scene.winLights.leftBottomBar2.alpha = alpha
    scene.winLights.leftBottomBar3.alpha = alpha
    scene.winLights.rightBottomBar1.alpha = alpha
    scene.winLights.rightBottomBar2.alpha = alpha
    scene.winLights.rightBottomBar3.alpha = alpha
end

function setLightsGroupsAlpha(alpha)
    scene.winLights.top.alpha = alpha
    scene.winLights.middle.alpha = alpha
    scene.winLights.bottom.alpha = alpha
end

--- Funcio per cancelar les transicions sobre les llums
function cancelLightsTransitions()
	if timerID then
		timer.cancel(timerID)
		timerID = nil
	end
	if timerID2 then
		timer.cancel(timerID2)
		timerID2 = nil
	end
    -- Top lights
    transition.cancel(scene.winLights.leftTopWing)
    transition.cancel(scene.winLights.leftBottomWing)
    transition.cancel(scene.winLights.rightTopWing)
    transition.cancel(scene.winLights.rightBottomWing)
    transition.cancel(scene.winLights.eyes)
    -- Middle lights
    transition.cancel(scene.winLights.leftMid)
    transition.cancel(scene.winLights.rightMid)
    -- Bottom lights
    transition.cancel(scene.winLights.leftBottomBar1)
    transition.cancel(scene.winLights.leftBottomBar2)
    transition.cancel(scene.winLights.leftBottomBar3)
    transition.cancel(scene.winLights.rightBottomBar1)
    transition.cancel(scene.winLights.rightBottomBar2)
    transition.cancel(scene.winLights.rightBottomBar3)
    -- Grups
    transition.cancel(scene.winLights.top)
    transition.cancel(scene.winLights.middle)
    transition.cancel(scene.winLights.bottom)
    -- Grup sencer
    transition.cancel(scene.winLights)
end

--- Funció per treure el tint de les llums de la màqina
function setLightsTint(c)
    -- Top lights
    scene.winLights.leftTopWing:setFillColor(c[1], c[2], c[3])
    scene.winLights.leftBottomWing:setFillColor(c[1], c[2], c[3])
    scene.winLights.rightTopWing:setFillColor(c[1], c[2], c[3])
    scene.winLights.rightBottomWing:setFillColor(c[1], c[2], c[3])
    scene.winLights.eyes:setFillColor(c[1], c[2], c[3])
    -- Middle lights
    scene.winLights.leftMid:setFillColor(c[1], c[2], c[3])
    scene.winLights.rightMid:setFillColor(c[1], c[2], c[3])
    -- Bottom lights
    scene.winLights.leftBottomBar1:setFillColor(c[1], c[2], c[3])
    scene.winLights.leftBottomBar2:setFillColor(c[1], c[2], c[3])
    scene.winLights.leftBottomBar3:setFillColor(c[1], c[2], c[3])
    scene.winLights.rightBottomBar1:setFillColor(c[1], c[2], c[3])
    scene.winLights.rightBottomBar2:setFillColor(c[1], c[2], c[3])
    scene.winLights.rightBottomBar3:setFillColor(c[1], c[2], c[3])
end

--- Funció de cració de les llums de la màquina
function createWinLights()
    
    scene.winLights = display.newGroup()
    
    -- Top lights
    scene.winLights.top = display.newGroup()
    scene.winLights.leftTopWing = display.newImage(scene.slotMachineSheet, scene.slotMachineAtlas:getFrameIndex("00_luceswin_alas_sup_izq"), scene.midW-110*scene.R, scene.midH-212*scene.R)
    scene.winLights.leftTopWing:scale(scene.R, scene.R)
    scene.winLights.leftBottomWing = display.newImage(scene.slotMachineSheet, scene.slotMachineAtlas:getFrameIndex("01_luceswin_alas_sup_izq"), scene.midW-127*scene.R, scene.midH-170*scene.R)
    scene.winLights.leftBottomWing:scale(scene.R, scene.R)
    scene.winLights.rightTopWing = display.newImage(scene.slotMachineSheet, scene.slotMachineAtlas:getFrameIndex("00_luceswin_alas_sup_der"), scene.midW+107*scene.R, scene.midH-212*scene.R)
    scene.winLights.rightTopWing:scale(scene.R, scene.R)
    scene.winLights.rightBottomWing = display.newImage(scene.slotMachineSheet, scene.slotMachineAtlas:getFrameIndex("01_luceswin_alas_sup_der"), scene.midW+127*scene.R, scene.midH-169*scene.R)
    scene.winLights.rightBottomWing:scale(scene.R, scene.R)
    scene.winLights.eyes = display.newImage(scene.slotMachineSheet, scene.slotMachineAtlas:getFrameIndex("02_luceswin_ojos"), scene.midW-1*scene.R, scene.midH-168*scene.R)
    scene.winLights.eyes:scale(scene.R, scene.R)
    scene.winLights.top:insert(scene.winLights.leftTopWing)
    scene.winLights.top:insert(scene.winLights.leftBottomWing)
    scene.winLights.top:insert(scene.winLights.rightTopWing)
    scene.winLights.top:insert(scene.winLights.rightBottomWing)
    scene.winLights.top:insert(scene.winLights.eyes)
    scene.winLights:insert(scene.winLights.top)
    
    -- Middle lights
    scene.winLights.middle = display.newGroup()
    scene.winLights.leftMid = display.newImage(scene.slotMachineSheet, scene.slotMachineAtlas:getFrameIndex("04_luceswin_centro_izq"), scene.midW-109*scene.R, scene.midH-22*scene.R)
    scene.winLights.leftMid:scale(scene.R, scene.R)
    scene.winLights.rightMid = display.newImage(scene.slotMachineSheet, scene.slotMachineAtlas:getFrameIndex("04_luceswin_centro_der"), scene.midW+107*scene.R, scene.midH-22*scene.R)
    scene.winLights.rightMid:scale(scene.R, scene.R)
    scene.winLights.middle:insert(scene.winLights.leftMid)
    scene.winLights.middle:insert(scene.winLights.rightMid)
    scene.winLights:insert(scene.winLights.middle)
    
    -- Bottom lights
    scene.winLights.bottom = display.newGroup()
    scene.winLights.leftBottomBar1 = display.newImage(scene.slotMachineSheet, scene.slotMachineAtlas:getFrameIndex("05_luceswin_inf_izq_01"), scene.midW-205*scene.R, scene.midH+200*scene.R)
    scene.winLights.leftBottomBar1:scale(scene.R, scene.R)
    scene.winLights.leftBottomBar2 = display.newImage(scene.slotMachineSheet, scene.slotMachineAtlas:getFrameIndex("05_luceswin_inf_izq_02"), scene.midW-180*scene.R, scene.midH+200*scene.R)
    scene.winLights.leftBottomBar2:scale(scene.R, scene.R)
    scene.winLights.leftBottomBar3 = display.newImage(scene.slotMachineSheet, scene.slotMachineAtlas:getFrameIndex("05_luceswin_inf_izq_03"), scene.midW-155*scene.R, scene.midH+200*scene.R)
    scene.winLights.leftBottomBar3:scale(scene.R, scene.R)
    scene.winLights.rightBottomBar1 = display.newImage(scene.slotMachineSheet, scene.slotMachineAtlas:getFrameIndex("05_luceswin_inf_der_01"), scene.midW+205*scene.R, scene.midH+200*scene.R)
    scene.winLights.rightBottomBar1:scale(scene.R, scene.R)
    scene.winLights.rightBottomBar2 = display.newImage(scene.slotMachineSheet, scene.slotMachineAtlas:getFrameIndex("05_luceswin_inf_der_02"), scene.midW+180*scene.R, scene.midH+200*scene.R)
    scene.winLights.rightBottomBar2:scale(scene.R, scene.R)
    scene.winLights.rightBottomBar3 = display.newImage(scene.slotMachineSheet, scene.slotMachineAtlas:getFrameIndex("05_luceswin_inf_der_03"), scene.midW+155*scene.R, scene.midH+200*scene.R)
    scene.winLights.rightBottomBar3:scale(scene.R, scene.R)
    scene.winLights.bottom:insert(scene.winLights.leftBottomBar1)
    scene.winLights.bottom:insert(scene.winLights.leftBottomBar2)
    scene.winLights.bottom:insert(scene.winLights.leftBottomBar3)
    scene.winLights.bottom:insert(scene.winLights.rightBottomBar1)
    scene.winLights.bottom:insert(scene.winLights.rightBottomBar2)
    scene.winLights.bottom:insert(scene.winLights.rightBottomBar3)
    scene.winLights:insert(scene.winLights.bottom)
    
    setLightsAlpha(0)
    
    insertInGrp(scene.winLights, scene.LAYER_BACKGROUND)
    
end

function ressetLights()
    cancelLightsTransitions()
    setLightsGroupsAlpha(1)
    setLightsAlpha(0)
    setLightsTint({1,1,1})
end

--######################################################################--
--#                                                                    #--
--#                       Procés d'una tirada                          #--
--#                                                                    #--
--######################################################################--

--- Funció roll()
-- És la funció encarregada de fer correr les rodes
local function roll()

    for i = 1, 3 do
        display.remove(scene.slotColumn[i])
        scene.slotColumn[i] = nil
    end
    
    local function spinListener( event )
       if event.phase == "ended" then
           if 1 == event.target.id then
               display.remove(scene.spin1)
				scene.spin1 = nil
           elseif 2 == event.target.id then
               display.remove(scene.spin2)
				scene.spin2 = nil
			elseif 3 == event.target.id then
               display.remove(scene.spin3)
				scene.spin3 = nil
			end
           displaySlotColumns(event.target.id)
           doColumnBounce(event.target.id)
			AZ.audio.playFX(AZ.soundLibrary.slotStopSound, AZ.audio.AUDIO_VOLUME_OTHER_FX)
       end
    end

    scene.spin1 = display.newSprite(scene.spinSheet, scene.spinData1)
    scene.spin1.id = 1
    scene.spin1.x = scene.slotColumnX[1]; scene.spin1.y = scene.slotColumnY
    scene.spin1:scale(scene.R, scene.R)
    scene.slotColumnsContainer:insert(scene.spin1)

    scene.spin2 = display.newSprite(scene.spinSheet, scene.spinData2)
    scene.spin2.id = 2
    scene.spin2.x = scene.slotColumnX[2]; scene.spin2.y = scene.slotColumnY
    scene.spin2:scale(scene.R, scene.R)
    scene.slotColumnsContainer:insert(scene.spin2)

    scene.spin3 = display.newSprite(scene.spinSheet, scene.spinData3)
    scene.spin3.id = 3
    scene.spin3.x = scene.slotColumnX[3]; scene.spin3.y = scene.slotColumnY
    scene.spin3:scale(scene.R, scene.R)
    scene.slotColumnsContainer:insert(scene.spin3)

    scene.spin1:addEventListener( "sprite", spinListener )
    scene.spin2:addEventListener( "sprite", spinListener )
    scene.spin3:addEventListener( "sprite", spinListener )
    scene.spin1:play(); scene.spin2:play(); scene.spin3:play()
	AZ.audio.playFX(AZ.soundLibrary.slotSpinSound, AZ.audio.AUDIO_VOLUME_OTHER_FX)
end

--- Funció que comprova que realment hi hagi premi
function isPrize(result)
    if (result[1].name == "skull" and result[2].name == "skull") or (result[1].name == "grave" and result[2].name == "grave") then
        return false
    elseif (result[2].name == "skull" and result[3].name == "skull") or (result[2].name == "grave" and result[3].name == "grave") then
        return false
    elseif (result[1].name == "skull" and result[3].name == "skull") or (result[1].name == "grave" and result[3].name == "grave") then
        return false
    else
        return true
    end
end


--- Funció checkPrize()
-- És la funció encarregada de comprovar si s'ha guanyat albun premi i en el 
-- cas que n'hi hagi disparar el popup que mostra el premi
local function checkPrize()
	local function noExtraLollipops()
		local options = {
           effect = "crossFade",
           time = 300,
           params = scene.params,
           isModal = true
       }
       options.params.slotPlayed = true
       AZ.S.showOverlay("popups.popupwolollipops",options)
	end
	
    scene.result = scene.result[2]
    scene.isPlaying = false
    if (scene.result[1].name == scene.result[2].name and scene.result[1].name == scene.result[3].name) or 
        ((scene.result[1].name == scene.result[2].name or scene.result[2].name == scene.result[3].name) and 
        (scene.result[2].name ~= "coin" and scene.result[2].name ~= "lollipop"))  or (scene.result[1].name == scene.result[3].name and 
        (scene.result[1].name ~= "coin" and scene.result[1].name ~= "lollipop")) then
        
        if isPrize(scene.result) then
			setPrize()
        elseif scene.isLollipop then
			AZ.audio.playFX(AZ.soundLibrary.slotLoseSound, AZ.audio.AUDIO_VOLUME_OTHER_FX)
			noExtraLollipops()
        else
			AZ.audio.playFX(AZ.soundLibrary.slotLoseSound, AZ.audio.AUDIO_VOLUME_OTHER_FX)
            lightsAnimLose()
			activateDeactivateButtons(true)
        end
        
    elseif scene.isLollipop then
		AZ.audio.playFX(AZ.soundLibrary.slotLoseSound, AZ.audio.AUDIO_VOLUME_OTHER_FX)
		noExtraLollipops()
    else
		AZ.audio.playFX(AZ.soundLibrary.slotLoseSound, AZ.audio.AUDIO_VOLUME_OTHER_FX)
        lightsAnimLose()
		activateDeactivateButtons(true)
    end
end

--- Funció scene:play()
-- És la funció encarregada de disparar el funcionament de la màquina
function scene:play()
    
	scene.isPlaying = true
	
    if scene.config == nil  then
       log("SlotMachine requiere la configuración de las probabilidades")
       return 
    end
   
    log("Empezamos la jugada") 

    if scene._coins < 0 then
        log("No podemos jugar, así que no lanzamos la jugada")
        return
    end
    
    roll()
	
	setCurrentCoins(scene._coins - 10)
    log("Hemos bajado el número de monedas")
    scene.jackpot = scene.jackpot+10
    
    timer.performWithDelay(2500, checkPrize)
    
end

local function setVariablesWithScale()
	scene.midW = scene.W/2
	scene.midH = scene.H/2
	scene.tleW = scene.midW-118*scene.R
	scene.treW = scene.midW+118*scene.R
	scene.sreW = scene.midW+200*scene.R
	scene.feW = scene.midW-150*scene.R
	scene.leW = scene.W - scene.feW
	scene.feH = scene.midH - 335*scene.R
	scene.leH = scene.midH + 300*scene.R
	scene.slotColumnX = {-(334*0.35)*scene.R, 0, (334*0.35)*scene.R}
	scene.slotColumnY = 0
	scene.oYToggle = scene.midH-100*scene.R
end

local function createBtn(params)--(group, id, x, y, btnIndex, txtParams)
	local btn = AZ.ui.newTouchButton({ id = params.id, x = params.x, y = params.y, touchSound = params.touchSound or AZ.soundLibrary.buttonSound, releaseSound = params.releaseSound, txtParams = params.txtParams, btnIndex = params.btnIndex,  imageSheet = scene.slotMachineSheet, onTouch = onClick })
	btn:setScale(SCALE_BIG*1.2, SCALE_BIG*1.2)
	insertInGrp(btn, params.group)
	return btn
end

local function setScale(bgW, bgH)
	if bgH*(display.contentWidth/bgW) > display.contentHeight then
		scene.R = display.contentHeight/bgH
	else
		scene.R = display.contentWidth/bgW
	end
end

--######################################################################--
--#                                                                    #--
--#                   Inicialització de la màquina                     #--
--#                                                                    #--
--######################################################################--

--- Funció scene.init(isDebugEnabled, params)
-- És la funció encarregada d'inicialitzar tota la màquina
-- @param isDebugEnabled Rep si estem en mode debug
-- @param params Rep els paràmetres passats per l'scene anterior
function scene:init(isDebugEnabled)
    
    scene.SlotMachine = scene.view
    scene.blackbg = display.newRect(0, 0, display.contentWidth+150, display.contentHeight)
    scene.blackbg:setFillColor(0,0,0)
    scene.blackbg.x, scene.blackbg.y = display.contentCenterX, display.contentCenterY
    scene.SlotMachine:insert(scene.blackbg)
    scene.bg = display.newGroup()
    scene.ui = display.newGroup()
    scene.fx = display.newGroup()
    scene.ob = display.newGroup()
    
    if isDebugEnabled == nil then
       scene.debug = false
    else
       scene.debug = isDebugEnabled 
    end
    
    setupSprites()
    setupLayers()
    
    scene.background = display.newImageRect("slotmachine/assets/slotmachine_fondo.png", 512, 768)
	setScale(scene.background.contentWidth, scene.background.contentHeight)
    scene.background.x, scene.background.y = display.contentCenterX, display.contentCenterY
	scene.background:scale(scene.R, scene.R)
    insertInGrp(scene.background, scene.LAYER_BACKGROUND)
    
	setVariablesWithScale()
	
    createWinLights()
    
    if not scene.params.isLollipop then
		
		scene.btnShop = createBtn({group = scene.LAYER_UI, id = "btnShop", x = display.contentWidth*0.5, y = display.contentHeight*0.9, btnIndex = scene.slotMachineAtlas:getFrameIndex("boton_shop")})
		if #AZ.userInfo.shopNewItems > 0 then
			scene.btnShop.newItemsMarker = display.newImage(scene.slotMachineSheet, scene.slotMachineAtlas:getFrameIndex("alert_shop"), -30, -30)
			scene.btnShop:insert(scene.btnShop.newItemsMarker)
			scene.btnShop.newItemsLabel = display.newText({ text = tostring(#AZ.userInfo.shopNewItems), font = INTERSTATE_BOLD, fontSize = 20, x = -30, y = -31 })
			scene.btnShop.newItemsLabel:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
			scene.btnShop:insert(scene.btnShop.newItemsLabel)
		end
		
		scene.btnExit = createBtn({group = scene.LAYER_UI, id = "btnExit",	x = display.contentWidth*0.2, y = display.contentHeight*0.9, btnIndex = scene.slotMachineAtlas:getFrameIndex("left"), touchSound = AZ.soundLibrary.backBtnSound})
		
    end
    
    scene.btnPrizes = AZ.ui.newEnhancedButton2(
    {
	sound = AZ.soundLibrary.buttonSound,
        id = "btnPrizes",
        myImageSheet = scene.slotMachineSheet,
        unpressedIndex = scene.slotMachineAtlas:getFrameIndex("botonprizes_unpush"),
        pressedIndex = scene.slotMachineAtlas:getFrameIndex("botonprizes_push"),
        x = scene.midW,
        y = scene.midH-280*scene.R,
        text1 = {text = AZ.utils.translate("prize_list"), fontName = INTERSTATE_BOLD, fontSize = 35, X = 0, Y = 20, color = {255,255,255,190}},
        onEvent = onClick
    })
    scene.btnPrizes:scale(scene.R*0.9, scene.R*0.9)
    insertInGrp(scene.btnPrizes,scene.LAYER_UI)
    
    scene.slotColumnsContainer = display.newContainer(334*scene.R,204*scene.R)
    scene.slotColumnsContainer.x, scene.slotColumnsContainer.y = scene.midW-0.5*scene.R, scene.midH-0.5*scene.R
    insertInGrp(scene.slotColumnsContainer, scene.LAYER_OB)
    scene.slotColumnsCover = bitmap(scene.slotMachineAtlas:getFrameIndex("slotmachine_anim_sombras"), scene.slotMachineAtlas, scene.midW-0.5*scene.R, scene.midH-1.25*scene.R)
    insertInGrp(scene.slotColumnsCover, scene.LAYER_OB)
    insertInGrp(addText("txtCoins",AZ.utils.coinFormat(AZ.userInfo.money),scene.COLOR_BLACK,INTERSTATE_BOLD,scene.midW,scene.feH,46),scene.LAYER_UI)
    scene.toggle = toggle("btnToggle",scene.slotMachineAtlas,"palanca",scene.sreW,scene.oYToggle)
    scene.noTouch.isHitTestable = false
    insertInGrp(scene.toggle,scene.LAYER_UI)
    
    scene.bg.y = scene.bg.y+15*scene.R
    scene.ui.y = scene.bg.y
    scene.fx.y = scene.bg.y+15*scene.R
    
    dump()
end

--######################################################################--
--#                                                                    #--
--#                  Creació i eliminació de l'escena                  #--
--#                                                                    #--
--######################################################################--

--- Funció scene:createScene(event)
-- És la funció encarregada de crear l'escena de la màquina
function scene:createScene(event)
	
	AZ.audio.playBSO(AZ.soundLibrary.slotMachineLoop)
	
    scene.params = event.params
    scene:init(true)
    scene.configure(AZ.userInfo.money)
    
    for i = 1, 3 do
        displaySlotColumns(i, true)
    end
    
    lightsAnimDefault()
end

--- Funció scene:exitScene(event)
-- És la funció encarregada de gestionar la sortida de l'escena
function scene:exitScene(event)
    
    ressetLights()
    
    if timerId then
        timer.cancel(timerId)
		timerId = nil
    end
	
	if not scene.isLollipop then
		AZ:saveData()
	end
end

function scene:overlayEnded(event)
	setCurrentCoins(AZ.userInfo.money)
	if scene.prizeType == "threePrize" then
		scene.jackpot = AZ.userInfo.jackpot
	end
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener("createScene",scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("overlayEnded", scene)

return scene
