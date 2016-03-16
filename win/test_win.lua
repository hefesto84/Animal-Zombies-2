
--local facebook = require "facebook"
local tribone = require "test_tribone"
local easing = require "easing"
local widget = require "widget"

local scene = AZ.S.newScene()

local translate = nil

local group
--paràmetre que fem servir per escalar imatges i textos
local _R = SCALE_BIG
local _S = nil
--paràmetre que fem servir per escalar les posicions horitzontals de tots els elements
local _H = nil
local params = nil
local currentStage = nil
local currentLevel = nil
local currentDeaths = nil
local currentLives = nil
local currentCombos = nil
local currentTime = nil
local gameDeaths = nil
local gameLives = nil
local gameCombos = nil
local gamePercent = nil
local myTime = nil
local savedBones = nil
local mScore = nil
local maxScore = nil
local maxScoreShown = false
local achivementsContainer = nil
local grpWinGUI = nil
local marcador = nil
local lblMarcador = nil
local lblDeaths = nil
local lblScore = nil
local lblCombos = nil
local lblLives = nil
local btnLives = nil
local achivements = nil
local imgTribones = nil
local levelInfo = nil
local unblockedNow = false
local stageUnblockedNow = false
local lollipopsTable = { }
--control de timers
local timerID = nil
--actualitzar bones
local currentBones = nil
--
local lollipopsCount = 0
local lollipopInfo = nil

local myImageSheet = nil
local winLevelSheet = nil

-- botons, imatges i textos animats
local btnLevels = nil
local btnReplay = nil
local btnShop = nil
--local imgAchievement
local topGroup = nil
local bottomGroup = nil
local imgBoneGroup = { }
local triboneY = nil

local finishedAnim = false
local transID = nil
local finalTrans = nil



local function getTribones(score)
    
    local bonesPercent = AZ.gameInfo[currentStage].gameplay.stages[1].levels[currentLevel].levelBalance.bonesPercent
    
    local bones = 1
    for i = 1, #bonesPercent do
        if bonesPercent[i] <= gamePercent then
            bones = bones +1
        end
    end
    
	--print("amb percentatge ".. gamePercent ..": ".. bones .. " ossos")
    return bones
end



local function writeInfo(combos, deaths, lives, myTime)
    --require ("test_infoStage".. currentStage)
    --levelInfo           = stage_level_info[currentLevel]
    --local genericData   = AZ.userInfo--AZ.personal.loadPersonalData(AZ.personal.genericInfo)
    
    levelInfo = AZ.userInfo.progress.stages[currentStage].levels[currentLevel] --AZ.personal.loadPersonalData(AZ.personal.relativeLevels .. currentStage .. ".json")
    
    -- si el nivell actual era el que haviem de fer, actualitzem la informacio
    unblockedNow = levelInfo.score == 0
	
    savedBones = levelInfo.tribones
    currentBones = savedBones
    maxScore = levelInfo.score

    -- dibuix del tribone
    imgTribones = tribone.createTribone(
        myImageSheet,
        display.contentWidth * 0.5,
        triboneY+8*_S,
        savedBones,
        _S,
		7
    )
    topGroup:insert(imgTribones)
    --print("Combos: ".. combos ..", Deaths: ".. deaths .."x".. SCORE_DEATHS ..", Lives: ".. lives .."x".. SCORE_LIFE ..", Time: ".. levelInfo.levelBalance.medTime .."-".. myTime /1000)
    
    currentTime = AZ.gameInfo[currentStage].gameplay.stages[1].levels[currentLevel].levelBalance.medTime - myTime
    currentTime = math.round((currentTime + currentTime) *0.001)
    if currentTime < 0 then
        currentTime = 0
    end
    
    mScore = combos + (deaths * SCORE_DEATHS) + (lives * SCORE_LIFE) + currentTime
    --print("Total: ".. mScore)
    
    -- actualitzem puntuació si toca
    if levelInfo.score < mScore then
        levelInfo.score = mScore
    end
    -- actualitzem el temps si toca
    if levelInfo.time > myTime or levelInfo.time == -1 then
        levelInfo.time = myTime
    end
    -- actualitzem els ossos si toca
    local achievedBones = getTribones(mScore)
    if savedBones < achievedBones then
        levelInfo.tribones = achievedBones
    end
    
    -- desbloqueig d'arma presentada en el nivell
    local w = AZ.gameInfo[currentStage].gameplay.stages[1].levels[currentLevel].levelBalance.unlockedWeapon
    if w and w ~= "none" and unblockedNow then
        
        local function unlockWeapon()
            for i=1, #AZ.userInfo.weapons do
                if AZ.userInfo.weapons[i].name == w and AZ.userInfo.weapons[i].isBlocked then
					table.insert(AZ.userInfo.shopNewItems, w)
                    return
                end
            end
        end
        
        unlockWeapon()
    end
    
	-- si tenim prous ossos, desbloquegem el següent stage
	local function countBones()
		local totalBones = 0
		
		--local i = currentStage
		for i = 1, #AZ.userInfo.progress.stages do
			local _stage = AZ.userInfo.progress.stages[i]
			
			for j = 1, #_stage.levels do
				if _stage.levels[j].tribones == 0 then
					return totalBones
				end
				totalBones = totalBones + _stage.levels[j].tribones
			end
		end
		return totalBones
	end
	
	local totalBones = countBones()
	
	if totalBones >= (AZ.gameInfo[currentStage].unlockNextStageWithBones or 6) and currentStage == AZ.userInfo.lastStageFinished +1 then
		--AZ.userInfo.lastStageFinished = AZ.userInfo.lastStageFinished +1
		stageUnblockedNow = true
		AZ.achievementsManager:countStageFinished(currentStage)
	end
	
	local function countCurrentStageGoldenBones()
		local bones = 0
		
		for i = 1, #AZ.userInfo.progress.stages[currentStage].levels do
			bones = bones + AZ.userInfo.progress.stages[currentStage].levels[i].tribones
		end
		
		return bones
	end
	
	local goldenBones = countCurrentStageGoldenBones()
	
	if goldenBones == 75 then
		AZ.achievementsManager:unblockGoldenBone(currentStage)
	end
	
    AZ.userInfo.progress.stages[currentStage].levels[currentLevel] = levelInfo
    
    AZ:saveData()
    --AZ.personal.savePersonalData(stageData, AZ.personal.relativeLevels .. currentStage .. ".json")
    
end

local function getPlatform()
    if system.getInfo("platformName") == "iPhone OS" then
        return "iOS"
    end
    
    return "android"
end

local function startedPointInRect(p, r)
    return r.contentBounds.xMin < p.xStart and r.contentBounds.xMax > p.xStart and r.contentBounds.yMin < p.yStart and r.contentBounds.yMax > p.yStart
end

local onAchivementTouch = function(event)
    if event.phase == "moved" then
        local dx = math.abs( event.x - event.xStart )
        local dy = math.abs( event.y - event.yStart )
        
        if dx > 5 or dy > 5 then
            if startedPointInRect(event, event.target) then
                achivements:takeFocus( event )
            end
        end  
    
    elseif event.phase == "ended" and startedPointInRect(event, event.target) then
        if event.id == "gameServiceAchievements" then
            --FlurryController:logEvent("market_game_services", { clicked_in = "win level", which = "leaderboards" })
			 
            GameServicesController:show("leaderboards")
        end
    end
    
    return true
end

local onTouch = function(event)
    if event.phase == "ended" or event.phase == "release" then
        local options = {
            effect = SCENE_TRANSITION_EFFECT,
            time = SCENE_TRANSITION_TIME,
            params = { stage = currentStage, level = currentLevel, changeStage = false, unblockedNow = unblockedNow, stageUnblockedNow = stageUnblockedNow }
        }
		 
		event.target = event.target or {}
		
        if (event.target.id == "Replay" and event.target.isWithinBounds) then
            if timerID then
                timer.cancel(timerID)
            end
            
            --FlurryController:logEvent("in_win_level", { stage = currentStage, level = currentLevel, button = "replay" })
            
			if AZ.userInfo.lifesCurrent > 0 then
				AZ.S.gotoScene("loading.loading", options)
			else
				local options = {
					effect = "crossFade",
					time = 1000,
					isModal = true
				}
				AZ.S.showOverlay("popups.popupwolives", options)
			end
            
        elseif event.isBackKey or (event.target.id == "Levels" and event.target.isWithinBounds) then
            timerID = timer.safeCancel(timerID)
            
            --FlurryController:logEvent("in_win_level", { stage = currentStage, level = currentLevel, button = "levels" })
            
            local story = AZ.gameInfo[currentStage].gameplay.stages[1].levels[currentLevel].finalStory
            
			options.effect = "slideLeft"
				
            if story then
                options.params.story = story
                options.params.storyType = "final"
                
                AZ.S.gotoScene("story.story", options)
            else
                AZ.S.gotoScene("levels.levels2", options)
            end
            
        elseif event.target.id == "Shop" and event.target.isWithinBounds then
            if timerID then
                timer.cancel(timerID)
            end
            
            options.params = params
            options.params.source = {"win.test_win"}
            AZ.S.gotoScene("shop.shop", options)
            
        elseif event.target.id == "Lifes" and event.target.isWithinBounds then
            local options = {
                effect = "crossFade",
                time = 1000,
                isModal = true
            }
            AZ.S.showOverlay("popups.popupwolives", options)
            
--        elseif event.id == "gameServiceAchievements" then
--            --FlurryController:logEvent("market_game_services", { clicked_in = "win level", which = "leaderboards" })
--
--            GameServicesController:show("leaderboards")
        end
    end
end

function scene.onBackTouch()
	if finishedAnim then
		onTouch({ phase = "ended", isBackKey = true })
	end
end

function scene.createBtn(params)--(id, x, y, btnIndex, grp, scale, iconIndex, iconX, iconY, txtParams)
	local btn = AZ.ui.newTouchButton({ id = params.id, x = params.x, y = params.y, touchSound = params.touchSound or AZ.soundLibrary.buttonSound, releaseSound = params.releaseSound, btnIndex = params.btnIndex, iconIndex = params.iconIndex, iconX = params.iconX, iconY = params.iconY, txtParams = params.txtParams, imageSheet = myImageSheet, onTouch = onTouch })
	btn:setScale(params.scale, params.scale)
	if params.grp then
		params.grp:insert(btn)
	end
	return btn
end

local function createWinButtons()

	local grp = display.newGroup()
	local y = display.contentHeight -(SCALE_DEFAULT *100)
	local scale = _R *1.2
	
	btnLevels = scene.createBtn({id = "Levels", x = display.contentWidth *0.83, y = y, btnIndex = 15, grp = grp, scale = scale, touchSound = AZ.soundLibrary.forwardBtnSound})
	btnReplay = scene.createBtn({id = "Replay", x = display.contentWidth *0.17, y = y, btnIndex = 8, grp = grp, scale = scale, touchSound = AZ.soundLibrary.backBtnSound})
	btnShop = scene.createBtn({id = "Shop", x = display.contentCenterX, y = y, btnIndex = 10, grp = grp, scale = scale})
	if #AZ.userInfo.shopNewItems > 0 then
		btnShop.newItemsMarker = display.newImage(myImageSheet, 1, -30, -30)
		btnShop:insert(btnShop.newItemsMarker)
		btnShop.newItemsLabel = display.newText({ text = tostring(#AZ.userInfo.shopNewItems), font = INTERSTATE_BOLD, fontSize = 20, x = -30, y = -31 })
		btnShop.newItemsLabel:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
		btnShop:insert(btnShop.newItemsLabel)
	end
	
	btnShop.anchorY = 1
    
    return grp
end

local function getTime(t)
    local min, sec = 0

    min = math.floor( t/60 )
    sec = math.floor( t%60 )
    if sec < 10 then
        sec = "0"..sec
    end
    return (min..":"..sec)
end

local function addAchivement(y)
    local achivementGroup = display.newGroup()
    
    local imgAchivement = AZ.ui.newEnhancedButton2{
        sound = AZ.soundLibrary.buttonSound,
        myImageSheet = myImageSheet,
        unpressedIndex = 2,
        pressedIndex = 3,
        x = display.contentWidth*0.1,
        y = y,
        onEvent = onAchivementTouch,
        id = "achivement"
    }
    imgAchivement:scale(_S,_S)
    imgAchivement.anchorX, imgAchivement.anchorY = 0.5, 0.5
    
    local txtAchivementTitle = display.newText(
        "ACHIVEMENT NAME", 
        display.contentWidth*0.2, 
        y-30*_S, 
        display.contentWidth*0.6, 
        0, 
        INTERSTATE_BOLD, 
        18*_S
    )
    txtAchivementTitle.align = "left"
    txtAchivementTitle.anchorX, txtAchivementTitle.anchorY = 0, 0
    txtAchivementTitle:setFillColor(0, 0, 0, 0.6)
    
    local txtAchivement = display.newText(
        "Description of what has to be done to unlock the item", 
        display.contentWidth*0.2, 
        y-5*_S, 
        display.contentWidth*0.6, 
        0, 
        INTERSTATE_REGULAR, 
        18*_S
    )
    txtAchivement.align = "left"
    txtAchivement.anchorX, txtAchivement.anchorY = 0, 0
    txtAchivement:setFillColor(0, 0, 0, 0.6)
    
    local imgGameServiceAchivements = AZ.ui.newEnhancedButton2{
        sound = AZ.soundLibrary.buttonSound,
        myImageSheet = myImageSheet,
        unpressedIndex = 13,
        pressedIndex = 12,
        x = display.contentWidth*0.9,
        y = y,
        onEvent = onAchivementTouch,
        id = "gameServiceAchievements"
    }
    imgGameServiceAchivements:scale(_S,_S)
    imgGameServiceAchivements.anchorX, imgGameServiceAchivements.anchorY = 0.5, 0.5
    
    local separetaor = display.newLine(0, 0, display.contentWidth, 0)
    separetaor.x, separetaor.y = 0, y+40*_S
    separetaor.stroke = {0.2,0.2,0.2,0.4}
    separetaor.strokeWidth = 2*_S
    
    achivementGroup:insert(imgAchivement)
    achivementGroup:insert(txtAchivementTitle)
    achivementGroup:insert(txtAchivement)
    achivementGroup:insert(imgGameServiceAchivements)
    achivementGroup:insert(separetaor)
  
    return achivementGroup
end

local function createScrollAchivements(height)
    
    achivements = widget.newScrollView(
        {
            width = display.contentWidth,
            height = height,
            scrollWidth = display.contentWidth,
            scrollHeight = display.contentHeight*0.3,
            topPadding = -30*_S,
            bottomPadding = 50*_S,
            horizontalScrollDisabled = true,
            isBounceEnabled = false,
            backgroundColor = { 0.3, 0.3, 0.3, 0.2 }
        }
    )
    achivements.anchorX = 0.5
    achivements.anchorY = 0.5
    achivements.x = 0
    achivements.y = 0
    
    for i=1,24 do
        achivements:insert(addAchivement(0+(80*_S*i-1)))
    end
    
    achivementsContainer = display.newContainer(display.contentWidth, 1)
    achivementsContainer:insert(achivements)
    achivementsContainer.anchorX, achivementsContainer.anchorY = 0, 0
    achivementsContainer.x, achivementsContainer.y = 0, display.contentHeight*0.45-8.5*_S
    
    return achivementsContainer
    
end

local function currentLifesListener(event)
	btnLives.txt.text = event.lifes
end

local function createWinGUI(gameTime)
    --imatges
    local _info = require ("test_infoStage".. currentStage)
    
    grpWinGUI = display.newGroup()
    
    grpWinGUI:insert(createScrollAchivements(display.contentHeight*0.3))
    
    -- Elements del Marcador. Dins del bottomGroup
    local imgBottomBar = display.newImage(myImageSheet, 4)
    imgBottomBar:scale(_S, _S)
    imgBottomBar.x = display.contentWidth*0.5
    imgBottomBar.y = display.contentHeight*0.45 + imgBottomBar.contentHeight*0.50 - 6*_S
    imgBottomBar.anchorX, imgBottomBar.anchorY = 0.5, 0.5
    
    marcador = display.newImage(myImageSheet, 11)
    marcador:scale(_S,_S)
    marcador.x = display.contentWidth*0.5
    marcador.y = imgBottomBar.y - 62*_S
    marcador.anchorX, marcador.anchorY = 0.5, 0.5
    marcador.isVisible = false
    
    txtMarcador = display.newText(
        "0/24", 
        display.contentWidth*0.5, 
        imgBottomBar.y - 62*_S, 
        INTERSTATE_BOLD, 
        25*_S
    )
    txtMarcador.anchorX, txtMarcador.anchorY = 0.5, 0.5
    txtMarcador.align = "center"
    txtMarcador:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
    txtMarcador.isVisible = false
    
    
    local lblDeathsTitle = display.newText(
        translate("deaths"),
        display.contentWidth/2 - 145*_S,
        imgBottomBar.y - 10*_S,
        BRUSH_SCRIPT,
        SMALL_FONT_SIZE * SCALE_DEFAULT
    )
    lblDeathsTitle.anchorX, lblDeathsTitle.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    lblDeathsTitle:setFillColor(0, 0, 0, 0.6)
    
    lblDeaths = display.newText(
        currentDeaths,
        display.contentWidth/2 - 145*_S,
        imgBottomBar.y + 20*_S,
        INTERSTATE_BOLD,
        BIG_FONT_SIZE * SCALE_DEFAULT
    )
    lblDeaths.anchorX, lblDeaths.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    lblDeaths:setFillColor(0, 0, 0, 0.6)
    
    local deathsScoreBar = display.newLine(0, 0, 0, 75*_S)--.newImage(myImageSheet, 22)
    --deathsScoreBar:scale(_S, _S)
    deathsScoreBar.x = display.contentWidth/2 - 105*_S
    deathsScoreBar.y = imgBottomBar.y - 28*_S
    deathsScoreBar.anchorX, deathsScoreBar.anchorY = 0.5, 0.5
    deathsScoreBar.stroke = {0.2,0.2,0.2,0.2}
    deathsScoreBar.strokeWidth = 2*_S
    
    local lblScoreTitle = display.newText(
        translate("score"),
        display.contentWidth/2 - 55*_S,
        imgBottomBar.y - 10*_S,
        BRUSH_SCRIPT,
        SMALL_FONT_SIZE * SCALE_DEFAULT
    )
    lblScoreTitle.anchorX, lblScoreTitle.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    lblScoreTitle:setFillColor(0, 0, 0, 0.6)
    
    lblScore = display.newText(
        0,
        display.contentWidth/2 - 55*_S,
        imgBottomBar.y + 20*_S,
        INTERSTATE_BOLD,
        BIG_FONT_SIZE * SCALE_DEFAULT
    )
    lblScore.anchorX, lblScore.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    lblScore:setFillColor(0, 0, 0, 0.6)
    
    local scoreTimeBar = display.newLine(0, 0, 0, 75*_S)--.newImage(myImageSheet, 22)
    --scoreTimeBar:scale(_S, _S)
    scoreTimeBar.x = display.contentWidth/2 - 5*_S
    scoreTimeBar.y = imgBottomBar.y - 28*_S
    scoreTimeBar.anchorX, scoreTimeBar.anchorY = 0.5, 0.5
    scoreTimeBar.stroke = {0.2,0.2,0.2,0.2}
    scoreTimeBar.strokeWidth = 2*_S
    
    local lblTimeTitle = display.newText(
        translate("time"),
        display.contentWidth/2 + 45*_S,
        imgBottomBar.y - 10*_S,
        BRUSH_SCRIPT,
        SMALL_FONT_SIZE * SCALE_DEFAULT
    )
    lblTimeTitle.anchorX, lblTimeTitle.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    lblTimeTitle:setFillColor(0, 0, 0, 0.6)
    
    local t = gameTime *0.001
    local lblTime = display.newText(
        getTime(t),
        display.contentWidth/2 + 45*_S,
        imgBottomBar.y + 20*_S,
        INTERSTATE_BOLD,
        BIG_FONT_SIZE * SCALE_DEFAULT
    )
    lblTime.anchorX, lblTime.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    lblTime:setFillColor(0, 0, 0, 0.6)
    
    local timeLifesBar = display.newLine(0, 0, 0, 75*_S)--.newImage(myImageSheet, 22)
    --timeLifesBar:scale(_S, _S)
    timeLifesBar.x = display.contentWidth/2 + 90*_S
    timeLifesBar.y = imgBottomBar.y - 28*_S
    timeLifesBar.anchorX, timeLifesBar.anchorY = 0.5, 0.5
    timeLifesBar.stroke = {0.2,0.2,0.2,0.2}
    timeLifesBar.strokeWidth = 2*_S
	
	btnLives = scene.createBtn({
		id = "Lifes", 
		x = display.contentWidth/2+135*_S,
		y = imgBottomBar.y + 10*_S,
		btnIndex = 14,
		scale = _S,
		iconIndex = 23, 
		iconX = 40, 
		iconY = 15, 
		txtParams = {
			text = tostring(AZ.userInfo.lifesCurrent), 
			x = 0, 
			y = -3, 
			font = INTERSTATE_BOLD, 
			fontSize = 30,
			color = AZ_DARK_RGB
		},
		touchSound = AZ.soundLibrary.heartsAccessSound
	})
    
    -- Elements de la capçalera
    local imgTopBar = display.newImage(myImageSheet, 5)
    imgTopBar:scale(_S,_S)
    imgTopBar.x = display.contentWidth * 0.5
    imgTopBar.y = display.contentHeight*0.45 - imgTopBar.contentHeight*0.5
    imgTopBar.anchorX, imgTopBar.anchorY = 0.5, 0.5
    
    local imgFlag = display.newImage(myImageSheet, 6)
    imgFlag:scale(_S,_S)
    imgFlag.x = display.contentWidth * 0.5
    imgFlag.y = imgTopBar.y - imgFlag.contentHeight*0.60
    imgFlag.anchorX, imgFlag.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    
    triboneY = imgFlag.y
    
    local lblLevel = display.newText(
        translate("level") .. tostring(currentLevel) ,
        display.contentWidth * 0.5,
        display.contentHeight * 0.13,
        INTERSTATE_BOLD,
        NORMAL_FONT_SIZE * SCALE_DEFAULT
    )
    lblLevel.anchorX, lblLevel.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    lblLevel.x = display.contentWidth * 0.5
    lblLevel.y = imgFlag.y - imgFlag.contentHeight*0.50
    lblLevel:setFillColor(0, 0, 0, 0.6)
    
    local stageUpperTxt = AZ.ui.createShadowText(
        string.upper(translate(_info.upper_name).." "..translate(_info.lower_name)), 
        display.contentWidth*0.5, 
        lblLevel.y - 50*_S, 
        40 * _R
    )

    _info = AZ.utils.unloadModule("test_infoStage".. currentStage)
    
    bottomGroup = display.newGroup()
    bottomGroup:insert(imgBottomBar)
    bottomGroup:insert(marcador)
    bottomGroup:insert(txtMarcador)
    bottomGroup:insert(lblDeaths)
    bottomGroup:insert(lblDeathsTitle)
    bottomGroup:insert(deathsScoreBar)
    bottomGroup:insert(lblScore)
    bottomGroup:insert(lblScoreTitle)
    bottomGroup:insert(scoreTimeBar)
    bottomGroup:insert(lblTime)
    bottomGroup:insert(lblTimeTitle)
    bottomGroup:insert(timeLifesBar)
    bottomGroup:insert(btnLives)
    
    topGroup = display.newGroup()
    topGroup:insert(stageUpperTxt)--imgStage)
    --topGroup:insert(stageLowerTxt)
    topGroup:insert(lblLevel)
    topGroup:insert(imgFlag)
    topGroup:insert(imgTopBar)    
    
    grpWinGUI:insert(bottomGroup)
    grpWinGUI:insert(topGroup)

    return grpWinGUI

end


local function createTriboneSpawn(x, y, i)
	
	local boneSound = AZ.soundLibrary.boneSound
    AZ.audio.playFX(boneSound[i], AZ.audio.AUDIO_VOLUME_OTHER_FX)
    
    local dustInfo = AZ.animsLibrary.boneAnim()
	local dustAnim = display.newSprite(dustInfo.imageSheet, dustInfo.sequenceData)
	dustAnim:scale(SCALE_DEFAULT, SCALE_DEFAULT)
	dustAnim.x, dustAnim.y = x, y
	
	local destroyEffect = function()
        dustAnim.transID = transition.safeCancel(dustAnim.transID)
        display.remove(dustAnim)
        dustAnim = nil
    end
    
    local animListener = function(event)
       if event.phase == "ended" and dustAnim ~= nil then
           
		
           if dustAnim.isEnded then return end
           
           dustAnim.isEnded = true
           
           dustAnim.transID = transition.to(dustAnim, { time = dustInfo.getAnimFramerate(dustAnim.sequence), alpha = 0, onComplete = destroyEffect })
       end
    end
	
    
	dustAnim:play()
	dustAnim:addEventListener("sprite", animListener)
	
    return dustAnim
end

local function checkScore(score)
    local tribones = getTribones(score)
    
    AZ.audio.playFX(AZ.soundLibrary.addScoreSound, AZ.audio.AUDIO_VOLUME_BSO)
    
    if (currentBones < tribones) then
        currentBones = currentBones+1
        -- dibuix del tribone
        local imgBone = display.newImage(myImageSheet, 7)
        
        imgBone.boneIndex = currentBones
        imgBone.updateTribone = function()
            local fum = createTriboneSpawn(imgBone.x, imgBone.y, imgBone.boneIndex)
            fum.rotation = math.random(1, 360)
            group:insert( fum )
            imgBoneGroup:toFront()
            --local json = require("json")
            display.remove(imgTribones.bone1)                
            display.remove(imgTribones.bone2)
            display.remove(imgTribones.bone3)
        end
        local options = {time = 750, y = display.contentHeight * 0.60, xScale = 6 * _R, yScale = 6 * _R, alpha = 1, rotation = 300, transition = easing.outQuad, onComplete = imgBone.updateTribone}
        if currentBones == 1 then
            imgBone.x = display.contentWidth * 0.5 - 37 * _S
            options.x = display.contentWidth * 0.5 - 65 * _S
        elseif currentBones == 2 then
            imgBone.x = display.contentWidth * 0.5
            options.x = display.contentWidth * 0.5
        else
            imgBone.x = display.contentWidth * 0.5 + 37 * _S
            options.x = display.contentWidth * 0.5 + 65 * _S
        end
        imgBone.y = triboneY+8*_S
        imgBone:scale(_S, _S)
        transition.from(imgBone, options)
        imgBoneGroup:insert(imgBone)
        group:insert(imgBoneGroup)
    end
    
    if score == mScore then
        local winType = "congrats"
        
        if (score > maxScore) and (maxScoreShown == false) and maxScore > 0 then
            winType = "newRecord"
            
            --palpitar
            lblScore.palpitar = function()
                transition.from(lblScore, {time = 600, xScale = 1.5, yScale = 1.5, easing = easing.easeInOut, onComplete = lblScore.palpitar })            
            end
            transition.from(lblScore, {time = 1000, xScale = 1.5, yScale = 1.5, easing = easing.easeInElastic, onComplete = lblScore.palpitar })   
            maxScoreShown = true
        end
        
        --FlurryController:logEvent("in_win_level", { stage = currentStage, level = currentLevel, win_type = winType, bones = tribones, deaths = gameDeaths, score = mScore, time = myTime })
        
        launchFinalTransitions()
    end
end

function launchFinalTransitions()
    --transicio del panel superior
    topGroup:insert(imgTribones)
    topGroup:insert(imgBoneGroup)
    finalTrans = {}
    finalTrans[1] = transition.to( achivementsContainer, {time = 1000, delay = 1000, y = display.contentHeight*0.30-8.5*_S, height = display.contentHeight*0.3, easing = easing.inOutQuad, onComplete = function() end})
    finalTrans[2] = transition.to( bottomGroup, {time = 1000, delay = 1000, y = bottomGroup.y + display.contentHeight*0.15, transition = easing.inOutQuad, onComplete = function() bottomGroup:toFront(); marcador.isVisible = true; txtMarcador.isVisible = true end})
    finalTrans[3] = transition.to( topGroup, {time = 1000, delay = 1000, y = topGroup.y - display.contentHeight * 0.15, transition = easing.inOutQuad, onComplete = function() topGroup:toFront(); finishedAnim = true; scene.noTouchLayer.isHitTestable = false end })
	finalTrans[4] = transition.to( scene.winButtonsGroup, {time = 500, delay = 1500, alpha = 1, x = 0, transition = easing.outElastic})
	--scene.winButtonsGroup.isVisible = true
	if unblockedNow and currentLevel == 25 then
		finalTrans[4] = timer.performWithDelay(2200, function() AZ.S.showOverlay("popups.popupstagecomplete", {time = 300, effect = "crossFade", isModal = true}) end )
	end
	
end

function incrementTimeScore()
    local myScore = currentDeaths * SCORE_DEATHS + currentLives * SCORE_LIFE + currentCombos + currentTime
    checkScore(myScore, true)
    lblScore.text = myScore
    lblScore.xScale, lblScore.yScale = 1, 1
    transition.from(lblScore, { time = LIVES_TIME, xScale = 2, yScale = 2, transition = easing.easeInBack})--, onComplete = addBones})
end

function doTimeBonus()
    if (currentTime > 0) then
        if lblCombos == nil then
            lblCombos = display.newText(
                translate("bonus_time_score") ..": "..currentTime,
                0,
                display.contentHeight * 0.70,
                INTERSTATE_REGULAR,
                SMALL_FONT_SIZE * SCALE_DEFAULT
            )
            lblCombos:setFillColor(0, 0, 0, 0.6)
            lblCombos.anchorX, lblCombos.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
            lblCombos.x = lblScore
            lblCombos.alpha = 0
            group:insert(lblCombos)
        else
            lblCombos.text = translate("bonus_time_score") ..": "..currentTime
        end
        timerID = timer.performWithDelay( LIVES_TIME, function()
            transition.to(lblCombos, {time = LIVES_TIME, alpha = 1, transition = easing.inOutExpo, onComplete = function()
                --es mante el lbl sense sumarse res)
                timerID = timer.performWithDelay(LOLLIPOPCOMBO_TIME, function()
                    --despareix el lbl
                    transition.to(lblCombos, {time = LOLLIPOPCOMBO_TIME, alpha = 0, transition = easing.inExpo})
                    --suma la puntuacio
                    timerID = timer.performWithDelay(LOLLIPOPCOMBO_TIME, incrementTimeScore, 1)
                end, 1)
            end})
        end, 1)
    else
        --print("Current Combos: ".. currentCombos ..", current time: ".. currentTime)
        local myScore = currentDeaths * SCORE_DEATHS + currentLives * SCORE_LIFE + currentCombos + currentTime 
        --print("MyScore: ".. myScore ..", real score: ".. mScore)
        checkScore(myScore)
    end
end

function incrementCombosScore()
    currentCombos = gameCombos
    local myScore = currentDeaths * SCORE_DEATHS + currentLives * SCORE_LIFE + currentCombos
    checkScore(myScore)
    lblScore.text = myScore
    lblScore.xScale, lblScore.yScale = 1, 1
    transition.from(lblScore, { time = LIVES_TIME, xScale = 2, yScale = 2, transition = easing.easeInBack})
    
    doTimeBonus()
    
end

function incrementLivesScore()
    currentLives = currentLives + 1

    local score = currentDeaths * SCORE_DEATHS + currentLives * SCORE_LIFE
    checkScore(score)

    lblScore.text = score
    lblScore.xScale, lblScore.yScale = 1, 1
    transition.from(lblScore, { time = LIVES_TIME, xScale = 2, yScale = 2, transition = easing.easeInBack})

    if currentLives == gameLives then
        if gameCombos > 0 then
            --animacio dels combos
            lblCombos = display.newText(
                translate("bonus_combo_score") ..": ".. gameCombos,
                0,
                display.contentHeight * 0.65,
                INTERSTATE_REGULAR,
                SMALL_FONT_SIZE * SCALE_DEFAULT
            )
            lblCombos:setFillColor(0, 0, 0, 0.6)
            lblCombos.anchorX, lblCombos.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
            lblCombos.x = display.contentWidth * 0.5
            lblCombos.alpha = 0
            group:insert(lblCombos)
            --apareix el lblCombos
            transition.to(lblCombos, {time = LIVES_TIME, alpha = 1, transition = easing.inOutExpo, onComplete = function()
                --es mante el lbl sense sumarse res)
                timerID = timer.performWithDelay(LOLLIPOPCOMBO_TIME, function()
                    --despareix el lbl
                    transition.to(lblCombos, {time = LOLLIPOPCOMBO_TIME, alpha = 0, transition = easing.inExpo})
                    --suma la puntuacio
                    timerID = timer.performWithDelay(LOLLIPOPCOMBO_TIME, incrementCombosScore, 1)
                end, 1)
            end})
        else
            doTimeBonus()
        end
    end
end

local function lollipopsEffect()
    local x = lblScore.x
    local soundCount = 1
    for i = 1, gameLives do
        local imgLollipop = display.newImage(myImageSheet, 25, 0, display.contentHeight*0.70)
        imgLollipop:scale(SCALE_BIG, SCALE_BIG)
        imgLollipop.x = display.contentWidth + 100*SCALE_DEFAULT
        imgLollipop.alpha = 0
        imgLollipop.anim = function(i)
            local _delay = LOLLIPOPCOMBO_TIME - LOLLIPOPCOMBO_TIME * 0.8 * i
            --apareixer
            imgLollipop.transitionID = transition.to(imgLollipop, {delay = LOLLIPOPCOMBO_TIME*0.8 * i, time = LOLLIPOPCOMBO_TIME, alpha = 1, x = x - 30*_S + 15*_S*(i-1), onComplete = function()
                --moure cap a score
                local lollipopInfo = AZ.soundLibrary.lollipopSound
                imgLollipop.timerID = timer.performWithDelay( _delay + 100, function()
                    AZ.audio.playFX(lollipopInfo[soundCount], AZ.audio.AUDIO_VOLUME_OTHER_FX)
                    soundCount = soundCount + 1
                end, 1)
                imgLollipop.transitionID = transition.to(imgLollipop, {delay = _delay * i, time = LIVES_TIME * 3, alpha = 0, x = lblScore.x, y = lblScore.y, xScale = 0.01, yScale = 0.01, transition = easing.inExpo, onComplete = imgLollipop.disappear})
            end
            })
        end
        imgLollipop.anim(i)
        imgLollipop.disappear = function()
            incrementLivesScore()
            imgLollipop.immediateDestroy()
        end

        imgLollipop.immediateDestroy = function()
            if imgLollipop ~= nil then
                if imgLollipop.transitionID ~= nil then
                    transition.cancel(imgLollipop.transitionID)
                end

                if imgLollipop.timerID ~= nil then
                    timer.cancel(imgLollipop.timerID)
                end

                imgLollipop:removeSelf()
                imgLollipop = nil
            end
        end
        group:insert(imgLollipop)
        lollipopsTable[i] = imgLollipop
    end
end
            
function incrementDeathScore( )
    currentDeaths = currentDeaths + 1
    lblDeaths.text = currentDeaths
    local score = currentDeaths * SCORE_DEATHS
    checkScore(score)
    lblScore.text = score

    if currentDeaths == gameDeaths then
        lollipopsEffect()
    end
end

local function noTouch(event)
	return true
end

function scene:createScene( event )
	
	finishedAnim = false
	
    group = self.view
    
    translate = AZ.utils.translate
    
    imgBoneGroup = display.newGroup()
    
    maxScoreShown = false
    
    winLevelSheet = graphics.newImageSheet("assets/guiSheet/levelsIngameWinLose.png", AZ.atlas:getSheet())
    
    local _atlas = require "assets.Atlas.winAtlas"
    myImageSheet = graphics.newImageSheet("assets/new_guiSheet/win.png", _atlas:getSheet())
    _atlas = AZ.utils.unloadModule("assets.Atlas.winAtlas")
	
    local background = display.newImage("assets/fondoliso.jpg")
    _S = display.contentHeight/background.height
	background:scale(_S, _S) 
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    
	_S = display.contentHeight / 683

    params = event.params
    currentStage = event.params.currentStage
    currentLevel = event.params.currentLevel
    gameDeaths = event.params.gameDeaths
    gameLives = event.params.gameLives
    gameCombos = event.params.gameCombos
    gamePercent = event.params.gamePercent
    currentDeaths = 0
    currentLives = 0
    currentCombos = 0
    
    myTime = event.params.gameTime
    
	scene.noTouchLayer = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
	scene.noTouchLayer.alpha = 0
	scene.noTouchLayer:addEventListener("touch", noTouch)
	scene.noTouchLayer.isHitTestable = true
	
    group:insert(background)
    group:insert(createWinGUI(params.gameTime))
    writeInfo(params.gameCombos, params.gameDeaths, params.gameLives, params.gameTime)
	scene.winButtonsGroup = createWinButtons()
    group:insert(scene.winButtonsGroup)
	scene.winButtonsGroup.x = -display.contentWidth
	scene.winButtonsGroup.alpha = 0
	--scene.winButtonsGroup.isVisible = false
    group:insert(imgTribones)
	group:insert(scene.noTouchLayer)
	
	
	Runtime:addEventListener(RECOVERED_LIFES_EVNAME, currentLifesListener)
end
 
local function bonesPerCent(stageInfo)
    local sum = 0
    for i=1, 9 do
        sum = sum + stageInfo[i].tribones
    end
    return math.round(sum*100/27)
end

function scene:enterScene()
    
	finishedAnim = false
	
    if currentLevel == 25 then
        AZ.audio.playBSO(AZ.soundLibrary.ultimateWinLoop, AZ.audio.AUDIO_VOLUME_BSO)
    else
        audio.stop(1)
        if AZ.audio.BSO_ENABLED == true then
            al.Source(audio.getSourceFromChannel(1), al.PITCH, 1)
            audio.play(AZ.soundLibrary.winSound, { channel = 1 })
            audio.setVolume(AZ.audio.AUDIO_VOLUME_BSO, { channel = 1 })
        end
    end
    
--    local connection = AZ.utils.testConnection()
    
--	if params.isSecondTime then
--		local score = params.gameDeaths * SCORE_DEATHS + 
--		lblScore.text = score
--	else
		if gameDeaths > 0 then
			timerID =  timer.performWithDelay(DEATHS_TIME / gameDeaths, incrementDeathScore, gameDeaths)
		else
			--skip to next anim
			lollipopsEffect()
			--zombie activist achievement completed
			if connection == true then
				--local sendActivistAchievement = function()
					GameServicesController:sendAchievement(1,100)
					
				--    coroutine.yield()
				--end
				
				--local achivement = coroutine.create(sendActivistAchievement)
				--coroutine.resume(achievement)
			end
		end
--	end
    
--    -- enviar puntuacions i achievement
--    if connection == true then
--        --local sendOtherAchievements = function()
--            --GameServicesController:sendAllToScoreboard(currentStage)--puntuacions
--            --GameServicesController:sendAchievement(stage_level_info[currentLevel].emblem, 100)--achievement del nivell
--            --stageInfo = AZ.personal.loadPersonalData(AZ.personal.relativeLevels .. currentStage ..".json")--calcul del golden bone del stage
--            --GameServicesController:sendAchievement(golden_bone[currentStage],bonesPerCent(stageInfo))--achievement del golden bone del stage
            
--        --    coroutine.yield()
--        --end
        
--        --local achievements = coroutine.create(sendOtherAchievements)
--        --coroutine.resume(achievements)
--    end
end

function scene:exitScene(event)
	if finalTrans then
		for i = 1, #finalTrans do
			finalTrans[i] = transition.safeCancel(finalTrans[i])
		end
	end
	
	Runtime:removeEventListener(RECOVERED_LIFES_EVNAME, currentLifesListener)
end

function scene:destroyScene( event )
    local group = self.view
    for i=1, gameLives do
        if lollipopsTable[i] ~= nil then
            lollipopsTable[i].immediateDestroy()
        end
    end
end

function scene:overlayEnded(event)
	currentLifesListener({lifes = AZ.userInfo.lifesCurrent})
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )
scene:addEventListener( "overlayEnded", scene )

return scene



