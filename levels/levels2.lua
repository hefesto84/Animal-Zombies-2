
local ui = require "ui"
local widget = require "widget"
local easing = require "easing"

local scene = AZ.S.newScene()

local mStage
local mLastLevelFinished
local mLastStageFinished
local stageInfo
local unblockedNow = false
local stageUnblockedNow = false

--Declaració de les variables
scene.scrollView = nil
scene.background = {}
scene.levelButton = {}
local levelTribones = {}
local _W = display.contentWidth
local _H = display.contentHeight
local levelButtonTransition = nil

--- Cal esborrar quan sigui en producció i tirar del application.content.ratio setejat al config.lua 

local _R = SCALE_BIG
local ESCALA = display.contentWidth/512
local BUTTON_X = {
    {213,392,247,98,226,358,294,147,127,265,390,177,98,301,381,207,162,328,326,187,175,264,106,236,370},
    {345,334,190,202,325,366,263,137,103,190,324,440,374,250,101,202,65,184,320,410,292,125,250,322,105},
    {215,161,100,230,378,377,355,297,215,117,68,206,360,403,254,115,242,368,239,122,286,429,296,165,266},
    {344,336,207,77,223,393,307,132,175,336,411,232,70,227,389,213,299,303,187,108,186,411,282,141,214}
}
local BUTTON_Y = {
    {2193,2090,2038,1988,1923,1838,1746,1777,1636,1538,1431,1382,1252,1203,1047,1016,923,880,770,720,579,489,437,336,257},
    {2315,2185,2110,1983,1900,1780,1696,1649,1532,1431,1386,1318,1230,1197,1133,979,934,854,777,639,568,510,442,344,336},
    {2314,2175,2026,1965,1914,1772,1635,1500,1408,1316,1207,1174,1159,1064,991,912,848,756,721,643,576,518,442,381,277},
    {2321,2177,2124,2040,1988,1890,1786,1715,1600,1560,1432,1319,1249,1199,1137,1067,963,830,770,659,559,493,459,416,307}
}

---Funció que afegeix els efectes als botons de recàrrega de vides, banc i nivells
local function buttonEffect(button)
    local function origin()
        transition.to(button, {time = 100, xScale = _R, yScale = _R, transition = easing.outExpo})
    end
    transition.to(button, {time = 100, xScale = _R*0.8, yScale = _R*0.8, transition = easing.outExpo, onComplete = origin})
end

---Funció que controla els events Touch sobre els diferents botons i que pot retornar el focus a l'escroll
local function onTouch( event )
    if event.phase == "began" then
        if event.target.id == "deacButLayer" then
			return true
        end
    elseif event.phase == "moved" then
        if event.target then
            if event.target.id ~= scene.btnHearts.id and event.target.id ~= scene.btnBank.id and event.target.id ~= scene.btnShop.id and event.target.id ~= scene.btnSlotMachine.id and event.target.id ~=  scene.btnBack.id then
                local dx = math.abs( event.x - event.xStart )
                local dy = math.abs( event.y - event.yStart )
                -- if finger drags button more than 5 pixels, pass focus to scrollView
                if dx > 5 or dy > 5 then
					event.target:forceEnded()
                    scene.scrollView:takeFocus( event )
                end
            end
        end
    elseif event.phase == "ended" and event.target.isActive then
        
        if event.target.id == scene.btnHearts.id and event.target.isWithinBounds then
            local options = {
                effect = "crossFade",
                time = 1000,
                isModal = true
            }
            AZ.S.showOverlay(scene.btnHearts.id, options)
        elseif event.target.id == scene.btnBank.id and event.target.isWithinBounds then
			local x, y = scene.scrollView:getContentPosition() 
            local options = {
                effect = "crossFade",
                time = 250,
                params = {
                    stage = mStage,
                    source = {"levels.levels2"},
					 scrollPosition = y
                }
            }
            AZ.S.gotoScene(scene.btnBank.id, options)
		elseif event.target.id == scene.btnShop.id and event.target.isWithinBounds then
			local x, y = scene.scrollView:getContentPosition() 
            local options = {
                effect = "crossFade",
                time = 250,
                params = {
                    stage = mStage,
                    source = {"levels.levels2"},
					 scrollPosition = y
                }
            }
            AZ.S.gotoScene(scene.btnShop.id, options)
		elseif event.target.id == scene.btnSlotMachine.id and event.target.isWithinBounds then
			local x, y = scene.scrollView:getContentPosition()
            local options = {
                effect = "slideLeft",
                time = 250,
                params = {
                    stage = mStage,
                    level = math.min(mLastLevelFinished+1, 25),
                    source = {"levels.levels2"},
                    isLollipop = false,
					 scrollPosition = y
                }
            }
            AZ.S.gotoScene(scene.btnSlotMachine.id, options)
		elseif event.target.id == scene.btnBack.id and event.target.isWithinBounds then
			local options = {
                effect = "slideRight",
                time = 250,
                params = {
                    stage = mStage,
                    --source = {"levels.levels2"}
                }
            }
            AZ.S.gotoScene(scene.btnBack.id,options)
		elseif event.target.id == "deacButLayer" then
			return true	
        elseif event.target.isWithinBounds --[[type(event.target.id) == "number"]] then
			
            local lvl = event.target.id
			
			if AZ.userInfo.lifesCurrent > 0 then
				
				local story = AZ.gameInfo[mStage].gameplay.stages[1].levels[lvl].initialStory

				if story then
					local options = 
					{
						effect = "slideLeft",
						time = 250,
						params = 
						{
							story = story,
							storyType = "initial",
							stage = mStage,
							level = lvl
						}
					}

					AZ.S.gotoScene("story.story", options)
				else
					local options = 
					{
						effect = "crossFade",
						time = 250,
						params = 
						{
							stage = mStage,
							level = lvl
						}
					}

					AZ.S.gotoScene("loading.loading", options)
				end
			else
				local options = {
					effect = "crossFade",
					time = 1000,
					isModal = true
				}
				AZ.S.showOverlay(scene.btnHearts.id, options)
			end
		else
			--AZ.utils.print(event, "touch event unhandled")
        end
    end
 
    return true
end

function scene.onBackTouch()
	AZ.S.gotoScene("stage.stage", { time = SCENE_TRANSITION_TIME, effect = SCENE_TRANSITION_EFFECT, params = { stage = mStage } })
end

---Funció que controla l'escroll
local function scrollListener( event )
    local phase = event.phase
    local direction = event.direction

    --return true
end

function createTribones(level,myImageSheet, infoSheet)
    local tb = display.newGroup()
    x = -19.5
    
    for i=1,levelTribones[level] or 0 do -- or 0 temporal
        local bone = display.newImage(myImageSheet, infoSheet:getFrameIndex("hueso"))
        bone.y = 31
        bone.x = x
        x = x+17
        tb:insert(bone)
    end
    
    return tb
    
end

---Funció que crea l'scroll que contindrà els botons de nivell
local function createScroll(myImageSheet, infoSheet)
    --Scroll que permetrà navegar fins a cada nivell
    scene.scrollView = widget.newScrollView
    {
        width = display.contentWidth,
        height = display.contentHeight,
        scrollWidth = display.contentWidth,
        scrollHeight = display.contentWidth*5,
        friction = 0.92,
        horizontalScrollDisabled = true,
        hideScrollBar = true,
        listener = scrollListener,
        isBounceEnabled = false,
    }
    
    --Inserim el fons a l'scroll
    for i = 1, 5 do
        scene.background[i] = display.newImage("assets/StagesGraphics/Stage"..mStage.."/SelectLevel/0"..i..".jpg")
        scene.background[i]:scale(ESCALA, ESCALA)
        scene.background[i].x = display.contentCenterX
        scene.background[i].y = 512/2*ESCALA+(display.contentWidth*(i-1))
        scene.scrollView:insert(scene.background[i])
    end
    
	local function createBtn(params)--(id, x, y, btnIndex, txtParams)
		local btn = AZ.ui.newTouchButton({ id = params.id, x = params.x, y = params.y, touchSound = params.touchSound or AZ.soundLibrary.buttonSound, releaseSound = params.touchSound, txtParams = params.txtParams, btnIndex = params.btnIndex,  imageSheet = myImageSheet, onTouch = onTouch })
		--btn:setScale(ESCALA, ESCALA)
		scene.scrollView:insert(btn)
		return btn
	end
	
    --Botons de nivell
    for i = 1, 25 do
        --En el cas que estiguin desbloquejats
        if i <= mLastLevelFinished +1 then
			scene.levelButton[i] = createBtn({id = i, x = BUTTON_X[mStage][i]*ESCALA, y = BUTTON_Y[mStage][i]*ESCALA, btnIndex = infoSheet:getFrameIndex("level_selector_clean"), txtParams = { text = tostring(i), font = INTERSTATE_BOLD, fontSize = 40, color = AZ_DARK_RGB, x = -2, y = -4 }, touchSound = AZ.soundLibrary.levelBtnPressSound, releaseSound = AZ.soundLibrary.levelBtnUnpressSound})
            if i <= mLastLevelFinished then
                scene.levelButton[i].tribonesBoard = display.newImage(myImageSheet, infoSheet:getFrameIndex("pergamino"))
                scene.levelButton[i]:insert(scene.levelButton[i].tribonesBoard)
                scene.levelButton[i].tribones = createTribones(i, myImageSheet, infoSheet)
                scene.levelButton[i]:insert(scene.levelButton[i].tribones)
            end
            if i == mLastLevelFinished + 1 then
                scene.levelButton[i].animLayer = display.newGroup()
                local button = display.newImage(myImageSheet, infoSheet:getFrameIndex("level_selector_clean"))
                scene.levelButton[i].animLayer:insert(button)
                local text = display.newText({text = tostring(i), x = 0, y = 0, font = INTERSTATE_BOLD, fontSize = 40, align = "center"})
                text:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
                text.x = -2
                text.y = -4
                scene.levelButton[i].animLayer:insert(text)
                scene.levelButton[i]:insert(scene.levelButton[i].animLayer)
                if unblockedNow == true then
                    scene.levelButton[i].blocked = display.newImage(myImageSheet, infoSheet:getFrameIndex("level_selector_block"))
                    scene.levelButton[i]:insert(scene.levelButton[i].blocked)
                end
            end
        else
            --En el cas que no estiguin desbloquejats
			scene.levelButton[i] = createBtn({id = i, x = BUTTON_X[mStage][i]*ESCALA, y = BUTTON_Y[mStage][i]*ESCALA, btnIndex = infoSheet:getFrameIndex("level_selector_block"), touchSound = AZ.soundLibrary.stageBlockedSound})
            scene.levelButton[i].isActive = false  
        end
		
		scene.levelButton[i]:setScale(ESCALA, ESCALA)
		
    end
     
     return scene.scrollView
end

---Funció per crear els marges degradats de la pantalla
local function createMargins()
    local marginGroup = display.newGroup()
    --Marges degradats superior i inferior
     local grad = { type = "gradient", color1 = { 0, 0, 0, 1 }, color2 = { 0, 0, 0, 0 }, direction = "down" }
     local grad2 = { type = "gradient", color1 = { 0, 0, 0, 1 }, color2 = { 0, 0, 0, 0 }, direction = "up" }
     scene.topMargin = display.newRect(0, 0, display.contentWidth, 200*_R)
     scene.topMargin.anchorX = 0
     scene.topMargin.anchorY = 0
     scene.topMargin:setFillColor(grad)
     scene.bottomMargin = display.newRect(0, display.contentHeight-200*_R, display.contentWidth, 200*_R)
     scene.bottomMargin.anchorX = 0
     scene.bottomMargin.anchorY = 0
     scene.bottomMargin:setFillColor(grad2)
     marginGroup:insert(scene.topMargin)
     marginGroup:insert(scene.bottomMargin)
     
     return marginGroup
end

local function currentLifesListener(event)
	scene.btnHearts.txt.text = event.lifes
end

---Funció crateButtons
--Aquesta funció és la que crea els botons que queden fora de l'scrollView.
--Rep per paràmetres la informació de l'sprite sheet.
local function createButtons(myImageSheet, infoSheet)
    
    local buttonsGroup = display.newGroup()
	
	local function createBtn(params)--(id, x, y, btnIndex, txtParams, touchSound, releaseSound)
		local btn = AZ.ui.newTouchButton({ id = params.id, x = params.x, y = params.y, touchSound = params.touchSound or AZ.soundLibrary.buttonSound, releaseSound = params.releaseSound, txtParams = params.txtParams, btnIndex = params.btnIndex,  imageSheet = myImageSheet, onTouch = onTouch })
		btn:setScale(_R*1.2, _R*1.2)
		buttonsGroup:insert(btn)
		return btn
	end
	
	local padding = display.contentWidth *0.12
	local translate = AZ.utils.translate
	
	scene.btnBank 			= createBtn({id = "bank.bank", x = _W*0.5, y = _H*0.073, btnIndex = infoSheet:getFrameIndex("monedas"), txtParams = { text = AZ.utils.coinFormat(AZ.userInfo.money), font = INTERSTATE_BOLD, fontSize = 22, color = AZ_DARK_RGB, x = -30, y = -5 }, touchSound = AZ.soundLibrary.bankAccessSound})
	scene.btnHearts 		= createBtn({id = "popups.popupwolives", x = _W*0.15, y = _H*0.07, btnIndex = infoSheet:getFrameIndex("corazon"), txtParams = { text = tostring(AZ.userInfo.lifesCurrent), font = INTERSTATE_BOLD, fontSize = 24, color = AZ_DARK_RGB, x = -32, y = -3 }, touchSound = AZ.soundLibrary.heartsAccessSound})
	scene.btnShop 			= createBtn({id = "shop.shop", x = _W*0.85, y = _H*0.07, btnIndex = infoSheet:getFrameIndex("boton_shop")})
	if #AZ.userInfo.shopNewItems > 0 then
		scene.btnShop.newItemsMarker = display.newImage(myImageSheet, infoSheet:getFrameIndex("alert_shop"), -30, -30)
		scene.btnShop:insert(scene.btnShop.newItemsMarker)
		scene.btnShop.newItemsLabel = display.newText({ text = tostring(#AZ.userInfo.shopNewItems), font = INTERSTATE_BOLD, fontSize = 20, x = -30, y = -31 })
		scene.btnShop.newItemsLabel:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
		scene.btnShop:insert(scene.btnShop.newItemsLabel)
	end
	scene.btnSlotMachine 	= createBtn({id = "slotmachine.slotmachine", x = _W*0.8, y = _H*0.908, btnIndex = infoSheet:getFrameIndex("boton_slotmachine"), touchSound = AZ.soundLibrary.forwardBtnSound})
	scene.btnSlotMachine.blocked = display.newGroup()
	scene.btnSlotMachine.blocked.x, scene.btnSlotMachine.blocked.y = 0, 0
	scene.btnSlotMachine:insert(scene.btnSlotMachine.blocked)
	scene.btnSlotMachine.unblocked = display.newGroup()
	scene.btnSlotMachine.unblocked.x, scene.btnSlotMachine.unblocked.y = 0, 0
	scene.btnSlotMachine:insert(scene.btnSlotMachine.unblocked)
	scene.btnBack 			= createBtn({id = "stage.stage",	x = _W*0.2, y = _H*0.9208, btnIndex = infoSheet:getFrameIndex("flecha"), touchSound = AZ.soundLibrary.backBtnSound})
     
    return buttonsGroup
end

--- Funció que dispara l'animació de pulsació del nivell desbloquejat
local function levelPulse()
	if mLastLevelFinished < 25 then
		scene.levelButton[math.min(mLastLevelFinished+1, 25)].animLayer.alpha = 1
		scene.levelButton[math.min(mLastLevelFinished+1, 25)].animLayer.xScale, scene.levelButton[math.min(mLastLevelFinished+1, 25)].animLayer.yScale = 1, 1
		levelButtonTransition = transition.to(scene.levelButton[math.min(mLastLevelFinished+1, 25)].animLayer, {time = 1000, delay = 100, alpha = 0, xScale = 1.5, yScale = 1.5, transition = easing.outExpo, onComplete = levelPulse})
	end
end

--- Funció que destrueix la imatge del botó bloquejat
local function destroyExtras()

    display.remove(scene.levelButton[math.min(mLastLevelFinished+1, 25)].blocked)
    scene.levelButton[math.min(mLastLevelFinished+1, 25)].blocked = nil
	
    levelPulse()
	scene.deactivateButtonsLayer.isHitTestable = false
--	if stageUnblockedNow then
--		AZ.S.showOverlay("popups.popupnewstage", {effect = "crossFade", time = 300, isModal = true })
--	end
end

--- Funció que fa la desaparició de la icona de nivell bloquejat
local function unblock()
    transition.to(scene.levelButton[math.min(mLastLevelFinished+1, 25)].blocked, {time = 1000, delay = 0, alpha = 0, xScale = 3,yScale = 3,transition = easing.outExpo, onComplete = destroyExtras})
end

---Funció que crea les quatre escenes de selector de nivell revent per paràmetre l'Stage
function scene:createScene(event)
    local group = scene.view
    
	scene.params = event.params
	
    mStage = event.params.stage
    if event.params.unblockedNow then
        unblockedNow = event.params.unblockedNow
    end
	if event.params.stageUnblockedNow then
		stageUnblockedNow = event.params.stageUnblockedNow
	end
    if event.params.level then
        scene.level = event.params.level
    end
	
    stageInfo = AZ.userInfo.progress.stages[mStage].levels
	
	AZ.audio.playBSO(AZ.soundLibrary.menuLoop)
    
    mLastStageFinished = AZ.userInfo.lastStageFinished
	
	local function getLastLevelFinished()
		local stg = AZ.userInfo.progress.stages[mStage]
		
		for i = 1, #stg.levels do
			if stg.levels[i].score == 0 then
				return i -1
			end
		end
		return #stg.levels
	end
	mLastLevelFinished = getLastLevelFinished()
    
    for i=1, #stageInfo do
       levelTribones[i] = stageInfo[i].tribones
    end
    
    --Carregem la informació de l'sprite on hi ha les imatges
    local infoSheet = require "levels.assets.sheet.level"
    local myImageSheet = graphics.newImageSheet("levels/assets/sheet/level.png", infoSheet:getSheet())
    
    ---Creem els components visuals de pantalla
    group:insert(createScroll(myImageSheet, infoSheet))
    group:insert(createMargins())
    group:insert(createButtons(myImageSheet, infoSheet))
	
	scene.deactivateButtonsLayer = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
	scene.deactivateButtonsLayer.alpha = 0
	scene.deactivateButtonsLayer.isEnabled = true
	scene.deactivateButtonsLayer.id = "deacButLayer"
	scene.deactivateButtonsLayer:addEventListener("touch", onTouch)
	scene.deactivateButtonsLayer.isHitTestable = true
	group:insert(scene.deactivateButtonsLayer)

    --- funció per comprovar si la posició a la que es vol anar entra dins dels límits de l'Scroll
    local function clampScroll(y)
        if y > (_W*5)-_H then
            return -((_W*5)-_H)
        elseif y < 0 then
            return 0
        end
        return -y
    end
     
    -- Funció que porta al nou nivell desbloquejat
    local function scrollLevel()
        scene.scrollView:scrollToPosition({ y = clampScroll((BUTTON_Y[mStage][math.min(mLastLevelFinished+1, 25)]*ESCALA)-(_H*0.5)), time = 1000, onComplete = unblock})
    end
     
    --Quan arribem al selector de nivell anem a l'inici
	if scene.params.scrollPosition then
		scene.scrollView:scrollToPosition({ y = clampScroll(-scene.params.scrollPosition), time = 0, onComplete = levelPulse})
		scene.deactivateButtonsLayer.isHitTestable = false
    elseif scene.level then
        scene.scrollView:scrollToPosition({ y = clampScroll((BUTTON_Y[mStage][scene.level]*ESCALA)-(_H*0.5)), time = 0})
        if unblockedNow == true then
            timer.performWithDelay(100, scrollLevel)
        else
            levelPulse()
			scene.deactivateButtonsLayer.isHitTestable = false
        end
    elseif mLastLevelFinished+1 == 1 then
        scene.scrollView:scrollToPosition({ y = clampScroll((BUTTON_Y[mStage][math.min(mLastLevelFinished+1, 25)]*ESCALA)-(_H*0.5)), time = 0, onComplete = levelPulse})
		scene.deactivateButtonsLayer.isHitTestable = false
	else 
		scene.scrollView:scrollToPosition({ y = clampScroll((BUTTON_Y[mStage][math.min(mLastLevelFinished+1, 25)]*ESCALA)-(_H*0.5)), time = 0, onComplete = levelPulse})
		scene.deactivateButtonsLayer.isHitTestable = false
    end
	
	Runtime:addEventListener(RECOVERED_LIFES_EVNAME, currentLifesListener)
end

function scene:exitScene(event)
    transition.cancel(levelButtonTransition)
    unblockedNow = false
	stageUnblockedNow = false
	scene.level = nil
	mStage = nil
	mLastLevelFinished = nil
	Runtime:removeEventListener(RECOVERED_LIFES_EVNAME, currentLifesListener)
end

function scene:overlayEnded(event)
	scene.btnBank.txt.text = AZ.utils.coinFormat(AZ.userInfo.money)
	currentLifesListener({lifes = AZ.userInfo.lifesCurrent})
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener("createScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("overlayEnded", scene)

return scene
