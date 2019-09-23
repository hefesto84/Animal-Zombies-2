

local scene = AZ.S.newScene()

-- grafics
scene.invisibleLayer = nil
scene.stageSlide = nil
scene.menuBtn = nil
scene.imageSheet = nil

scene.currentStage = 0
scene.lastStageBones = 0

local lockedStageFrameColor = { 0.6, 0.6, 0.6, 0.8 }


function scene.activateDeactivateButtons(activate)
	scene.invisibleLayer.isHitTestable = not activate
end

function scene:gotoSelectLevel(stage)
	scene.activateDeactivateButtons(false)
	
	local function endBrokenGlassTrans()		
		timer.performWithDelay(250, function() AZ.S.gotoScene("levels.levels2", { effect = "slideLeft", time = SCENE_TRANSITION_TIME, params = { stage = stage } }) end)
	end
	
	local brokenGlass = display.newImage(scene.imageSheet, 2)
	local stageGrp = scene.stageSlide:getCurrentObj().frameGrp
	stageGrp:insert(brokenGlass)
	local transTime = 50
	transition.from(brokenGlass, { time = transTime, alpha = 0 })
	transition.to(stageGrp, { time = transTime, rotation = math.random(-15, 15), onComplete = endBrokenGlassTrans })
end

function scene.onScrollEnded(stageBtn)
	
	local frame = stageBtn.frameGrp
		
	if frame.stageNum <= STAGES_COUNT and
		not frame.isActive and
		frame.stageNum == scene.currentStage +1 and
		scene.lastStageBones >= AZ.gameInfo[frame.stageNum].unlockStageWithBones then
		
		scene.activateDeactivateButtons(false)
		
		frame.isActive = true
		
		AZ.userInfo.lastStageFinished = AZ.userInfo.lastStageFinished +1
		AZ:saveData()
		
		AZ.audio.playFX(AZ.soundLibrary.stageUnblockSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
		
		
		local function destroyLock()
			display.remove(stageBtn.frameGrp.lock)
			stageBtn.frameGrp.lock = nil
			
			scene.activateDeactivateButtons(true)
		end
		
		local function disappearLock()
			transition.to(stageBtn.frameGrp.lock, { time = 1000, y = display.contentHeight *1.2, rotation = 30, transition = easing.inOutBack, onComplete = destroyLock })
			
			AZ.utils.colorTransition(frame.photo, lockedStageFrameColor, { 1, 1, 1, 1 }, { time = 500, transition = easing.inCubic })
			transition.to(stageBtn.upperName, { time = 750, alpha = 1, transition = easing.inCubic })
			transition.to(stageBtn.lowerName, { time = 1000, alpha = 1, transition = easing.inCubic })
		end
		
		local function rotateLock()
			transition.to(stageBtn.frameGrp.lock.upper, { time = 250, rotation = -30, transition = easing.outBounce, onComplete = disappearLock })
		end
		
		transition.to(stageBtn.frameGrp.lock.upper, { time = 250, y = -19, transition = easing.outCubic, onComplete = rotateLock })
	elseif frame.stageNum <= STAGES_COUNT and
		not frame.isActive then
		
		AZ.audio.playFX(AZ.soundLibrary.stageBlockedSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
		scene.activateDeactivateButtons(true)
		
	else
		scene.activateDeactivateButtons(true)
	end
end

function scene.onTouch(event)
	if event.phase == "ended" and not scene.invisibleLayer.isHitTestable then
		local target = event.target
		
		if event.isBackKey or (AZ.utils.isPointInRect(event.x, event.y, target.contentBounds) and AZ.utils.isPointInRect(event.xStart, event.yStart, target.contentBounds)) then
			
			scene.activateDeactivateButtons(false)
			
			if event.isBackKey or target._id == scene.menuBtn._id then
				AZ.S.gotoScene("menu.menu", { effect = "slideRight", time = SCENE_TRANSITION_TIME })
				
			end
		end
	end
end

function scene.onBackTouch()
	scene.onTouch({ phase = "ended", isBackKey = true })
end

function scene.onScrollBtnTouch(event)
	local target = event.target
	
	if event.phase == "moved" then
		if math.abs(event.x - event.xStart) > 5 or math.abs(event.y - event.yStart) > 5 then
			scene.activateDeactivateButtons(false)
			scene.stageSlide:takeFocus(event)
		end
		
	elseif event.phase ~= "began" then
		
		if target.stageNum == scene.stageSlide:getCurrentObjNum() then
			
			local photoBounds = target.photo.contentBounds
			
			if target.isActive and AZ.utils.isPointInRect(event.x, event.y, photoBounds) and AZ.utils.isPointInRect(event.xStart, event.yStart, photoBounds) then
				scene:gotoSelectLevel(target.stageNum)
				AZ.audio.playFX(AZ.soundLibrary.crashSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
			end
		else
			scene.activateDeactivateButtons(false)
			scene.stageSlide:jumpTo(target.stageNum)
		end
	end
	
	return true
end

local function getTotalBones()
	local totalBones = 0
	
	local stg = AZ.userInfo.progress.stages[scene.currentStage]
	
	if not stg then return totalBones end
	
	for i = 1, #stg.levels do
		if stg.levels[i].tribones == 0 then
			return totalBones
		end
		totalBones = totalBones + stg.levels[i].tribones
	end
	return totalBones
end

function scene:createScene(event)
	
	event.params = event.params or {}
	
	local currentStage = event.params.stage or 1
	scene.currentStage = AZ.userInfo.lastStageFinished +1
	scene.lastStageBones = getTotalBones()
	
	AZ.audio.playBSO(AZ.soundLibrary.menuLoop)
	
	local _atlas = require "assets.Atlas.stageCreditsAtlas"
	scene.imageSheet = graphics.newImageSheet("assets/new_guiSheet/stageCredits.png", _atlas:getSheet())
	_atlas = AZ.utils.unloadModule("stage.assets.stageAtlas")
	
-- grafics
	-- bg
	local bg = display.newImage("assets/fondoliso.jpg")
	local scale = display.contentHeight / bg.contentHeight
	bg:scale(scale, scale) 
	bg.x, bg.y = display.contentCenterX, display.contentCenterY
	scene.view:insert(bg)
	
	-- logo
	local logo = display.newImage(scene.imageSheet, 6)
	logo:scale(SCALE_BIG, SCALE_BIG)
	logo.x, logo.y = display.contentCenterX, logo.contentHeight *0.75
	scene.view:insert(logo)
	--[[local logo = display.newImage(scene.imageSheet, 6)
	logo:scale(SCALE_DEFAULT, SCALE_DEFAULT)
    logo.x, logo.y = display.contentCenterX, display.contentHeight *0.125
	scene.view:insert(logo)]]
	
-- botons
	-- menu
	scene.menuBtn = AZ.ui.newTouchButton({
		id = "menu", onTouch = scene.onTouch,
		x = display.contentCenterX, y = display.contentHeight *0.9208,
		touchSound = AZ.soundLibrary.backBtnSound, --releaseSound = AZ.soundLibrary.switchSound,
		btnIndex = 1, imageSheet = scene.imageSheet })
	--[[scene.menuBtn = AZ.ui.newSuperButton({
		id = "menu", sound = AZ.soundLibrary.buttonSound,
		onTouch = scene.onTouch, imageSheet = scene.imageSheet,
		unpressed = 1, pressedFilter = "filter.invertSaturate",
		x = display.contentCenterX, y = display.contentHeight *0.9 })]]
	scene.menuBtn:setScale(SCALE_BIG *1.2, SCALE_BIG *1.2)
	scene.view:insert(scene.menuBtn)
	
	-- stages
	local translate = AZ.utils.translate
	local stgBtnScale = (SCALE_DEFAULT + SCALE_SMALL) *0.5
	local stageBtns = {}
	
	for i = 1, STAGES_COUNT +1 do
		
		local stgFullGrp = display.newGroup()
		local stgGrp = display.newGroup()
		
		local frame = display.newImage(scene.imageSheet, 5)
		stgGrp:insert(frame)
		
		local upperTxt, lowerTxt
		local txtAlpha = 1
		
		if i <= STAGES_COUNT then
			local _info = require("test_infoStage".. i)
			
			upperTxt, lowerTxt = translate(_info.upper_name), translate(_info.lower_name)
			
			local photo = display.newImage(_info.frame_path)
			photo:scale(0.9, 0.9)
			photo.x, photo.y = -4, -8
			stgGrp:insert(photo)
			stgGrp.photo = photo
			
			_info = AZ.utils.unloadModule("test_infoStage".. i)
			
			if i > scene.currentStage then
				photo:setFillColor(unpack(lockedStageFrameColor))
				txtAlpha = 0.6
				
				local lock = display.newGroup()
				lock.x, lock.y = photo.x, photo.y
				
				lock.upper = display.newImage(scene.imageSheet, 4)
				lock.lower = display.newImage(scene.imageSheet, 3)
				
				lock.upper.x, lock.upper.y = -19, -12
				lock.lower.y = 17
				
				lock.upper.anchorX, lock.upper.anchorY = 0.1, 0.9
				
				lock:insert(lock.upper)
				lock:insert(lock.lower)
				
				lock:scale(2, 2)
				stgGrp:insert(lock)
				stgGrp.lock = lock
			end
		else
			upperTxt, lowerTxt = translate("new_stages"), translate("coming_soon")
			
			local photo = display.newImage(scene.imageSheet, 8)
			photo.x, photo.y = -3, -6
			stgGrp:insert(photo)
			stgGrp.photo = photo
		end
		
		local upperName = display.newText({ text = upperTxt, font = BRUSH_SCRIPT, fontSize = 60 })
		local lowerName = display.newText({ text = lowerTxt, font = INTERSTATE_BOLD, fontSize = 90 })
		upperName:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
		lowerName:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
		upperName.alpha = txtAlpha
		lowerName.alpha = txtAlpha
		upperName.y = 280
		lowerName.y = 360
		stgFullGrp:insert(upperName)
		stgFullGrp:insert(lowerName)
		stgFullGrp.upperName = upperName
		stgFullGrp.lowerName = lowerName
		
		stgFullGrp:insert(stgGrp)
		stgFullGrp.frameGrp = stgGrp
		
		stgFullGrp:scale(stgBtnScale, stgBtnScale)
		
		stageBtns[i] = stgFullGrp
	end
	
	-- slider
	scene.stageSlide = AZ.utils.createSlide(stageBtns, { y = display.contentHeight *0.47, onComplete = scene.onScrollEnded })
	scene.view:insert(scene.stageSlide)
	scene.stageSlide:jumpTo(currentStage, 0)
	
	-- afegim el touch als stages
	for i = 1, #stageBtns do
		stageBtns[i].frameGrp:addEventListener("touch", scene.onScrollBtnTouch)
		stageBtns[i].frameGrp.isActive = i <= scene.currentStage and i ~= #stageBtns
		stageBtns[i].frameGrp.stageNum = i
	end
	
	-- layer invisible
	scene.invisibleLayer = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
	scene.invisibleLayer.alpha = 0
	scene.view:insert(scene.invisibleLayer)
	scene.invisibleLayer:addEventListener("touch", function() return true end)
	
	scene.activateDeactivateButtons(false)
end

function scene:enterScene(event)
	
	event.params = event.params or {}
	
	local currentStage = event.params.stage or 1
	
	local rateUs = require("rateUs")
    
	if event.params.changeStage then
        scene.activateDeactivateButtons(false)

		scene.stageSlide:jumpTo(currentStage +1)
		
		local where = "win_stage"
		if scene.currentStage == STAGES_COUNT then
			where = "end_game"
		end
		
		rateUs.rateUs(true, where)
	else
		rateUs.rateUs(false, "reminded")
		scene.activateDeactivateButtons(true)
	end
    
	rateUs = AZ.utils.unloadModule("rateUs")
end

function scene:exitScene(event)
	scene.stageSlide:destroy()
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener("enterScene", scene)
scene:addEventListener("createScene", scene)
scene:addEventListener("exitScene", scene)

return scene