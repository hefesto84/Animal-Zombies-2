
local scene = AZ.S.newScene()


-- grafics
scene.imageSheet = nil
scene.invisibleLayer = nil
scene.upperGrp = nil
scene.windowGrp = nil
scene.achievementsSheetGrp = nil
scene.bones = {}
scene.deathsTxt = nil
scene.scoreTxt = nil

-- botons
scene.replayBtn = nil
scene.shopBtn = nil
scene.levelsBtn = nil

-- variables
scene.levelInfo = nil
scene.stage = nil
scene.level = nil
scene.deaths = nil
scene.lives = nil
scene.combos = nil
scene.score = nil
scene.gamePercent = nil

local receivedParams = nil
local scale = 0
local translate = AZ.utils.translate
local unlockedNextLevel, unlockedNextStage = false, false


function scene:getTribones()
    
    local bonesPercent = AZ.gameInfo[scene.stage].gameplay.stages[1].levels[scene.level].levelBalance.bonesPercent
    
    local bones = 1
    for i = 1, #bonesPercent do
        if bonesPercent[i] <= scene.gamePercent then
            bones = bones +1
        end
    end
    return bones
end

function scene:writeInfo(combos, deaths, lives, myTime)
	
	local levelBalance = AZ.gameInfo[currentStage].gameplay.stages[1].levels[currentLevel].levelBalance
	local maximilianoWei = math.max
	
	-- calculem el temps
	local newTime = maximilianoWei(0, math.round((levelBalance.medTime - myTime) *0.002))
	--local newTime = levelBalance.medTime - myTime
	--newTime = math.round((newTime + newTime) *0.001)
	--newTime = math.max(newTime, 0)
	
	-- calculem la puntuacio
	scene.score = combos + (deaths * SCORE_DEATHS) + (lives * SCORE_LIFE) + newTime
	
	-- actualitzem puntuacio, tribones i temps
	scene.levelInfo.score = maximilianoWei(scene.levelInfo.score, scene.score)
	scene.levelInfo.tribones = maximilianoWei(scene.levelInfo.tribones, scene:getTribones())
	if scene.levelInfo.time > myTime or scene.levelInfo.time == -1 then
		scene.levelInfo.time = myTime
	end
	
	-- desbloquegem arma si toca
	local w = levelBalance.unlockedWeapon
	if w and w ~= "none" then
        
		local function unlockWeapon()
			for i=1, #AZ.userInfo.weapons do
				if AZ.userInfo.weapons[i].name == w then
					AZ.userInfo.weapons[i].isBlocked = false
					return
				end
			end
		end
		
		unlockWeapon()
	end
	
	-- desbloquegem nivell?
	unlockedNextLevel = scene.levelInfo.score == 0
	
	if scene.stage == AZ.userInfo.lastStageFinished +1 and STAGES_COUNT > AZ.userInfo.lastStageFinished +1 then
		
		local function countBones()
			local totalBones = 0
			local stgLvls = AZ.userInfo.progress.stages[scene.stage].levels
			
			for j = 1, #stgLvls do
				if stgLvls[j].tribones == 0 then
					return totalBones
				end
				totalBones = totalBones + stgLvls[j].tribones
			end
			return totalBones
		end
		
		if countBones() >= AZ.gameInfo[scene.stage +1].unlockStageWithBones then
			stageUnblockedNow = true
		end
	end
	
	AZ.userInfo.progress.stages[currentStage].levels[currentLevel] = levelInfo
	
	--AZ:saveData()
end

function scene.onTouch(event)
	if event.phase == "ended" then
		local target = event.target
		
		if AZ.utils.isPointInRect(event.x, event.y, target.contentBounds) and
		AZ.utils.isPointInRect(event.xStart, event.yStart, target.contentBounds) then
			
			local options = {
				effect = SCENE_TRANSITION_EFFECT, time = SCENE_TRANSITION_TIME,
				params = { stage = scene.stage, level = scene.level, changeStage = false, unblockedNow = scene.unlockedNextLevel, stageUnblockedNow = scene.unlockedNextStage }
			}
			
			if target._id == scene.replayBtn._id then
				AZ.S.gotoScene("loading.loading", options)
				
			elseif target._id == scene.shopBtn._id then
				options.params = receivedParams
				options.params.source = "win.test_win"
				AZ.S.gotoScene("shop.shop", options)
				
			elseif target._id == scene.levelsBtn._id then
				local story = AZ.gameInfo[scene.stage].gameplay.stages[1].levels[scene.level].finalStory
            
				if story then
					options.params.story = story
					options.params.storyType = "final"
					
					AZ.S.gotoScene("story.story", options)
				else
					AZ.S.gotoScene("levels.levels2", options)
				end
				
			elseif target._id == scene.levelsBtn._id then
				AZ.S.showOverlay("popups.popupwolives", { effect = "crossFade", time = SCENE_TRANSITION_TIME, isModal = true })
				
			end
		end
	end
end

function scene:createScene(event)
	
	receivedParams = event.params
	
	unlockedNextLevel, unlockedNextStage = false, false
	
	scene.stage, scene.level = event.params.currentStage, event.params.currentLevel
	
	scene.levelInfo = AZ.userInfo.progress.stages[scene.stage].levels[scene.level]
	
	local _info = require("test_infoStage".. scene.stage)
	
	local _sheetInfo = require "win.sheet.win_sheet"
    scene.imageSheet = graphics.newImageSheet("win/assets/win_sheet.png", _sheetInfo:getSheet())
	_sheetInfo = AZ.utils.unloadModule("win.sheet.win_sheet")
	
-- bg
	local bg = display.newImage("assets/fondoliso.jpg", display.contentCenterX, display.contentCenterY)
	scale = display.contentHeight / bg.contentHeight
	bg:scale(scale, scale)
	scene.view:insert(bg)
	
	scale = display.contentWidth / 512
	
-- grups
	local function createGrp()
		local grp = display.newGroup()
		grp.x = display.contentCenterX
		scene.view:insert(grp)
		return grp
	end
		
	scene.upperGrp = createGrp()
	scene.barGrp = createGrp()
	scene.achievementsSheetGrp = display.newGroup()
	
	
	
-- grafics	
	-- tribones bg
	local triboneBg = display.newImage(scene.imageSheet, 6)
	--triboneBg:scale(scale, scale)
	triboneBg.y = -50
	scene.upperGrp:insert(triboneBg)
	
	-- tribones
	scene.bones = {}
	for i = 1, 3 do
		local bone = display.newImage(scene.imageSheet, 7)
		bone.x, bone.y = 36.7 *(i -2), -42
		bone.isVisible = i <= scene.levelInfo.tribones
		scene.upperGrp:insert(bone)
		table.insert(scene.bones, bone)
	end
	
	-- stage name
	local stageStr = string.upper(translate(_info.upper_name) .." ".. translate(_info.lower_name))	
	local stageName = AZ.ui.createShadowText(stageStr, 0, 0, 45, display.contentWidth)
	stageName.y = -110 -(stageName.contentHeight *0.4)
	print(triboneBg.contentBounds.yMin)
	scene.upperGrp:insert(stageName)
	
	-- window upper
	local windowUpper = display.newImage(scene.imageSheet, 5)
	windowUpper.y = 12
	scene.upperGrp:insert(windowUpper)
	
	-- window bar
	local bar = display.newImage(scene.imageSheet, 4)
	bar.y = 69.5
	scene.barGrp:insert(bar)
	
	-- plate
	local ironSheet = display.newImage(scene.imageSheet, 12)
	scene.achievementsSheetGrp:insert(ironSheet)
	
	-- cor
	local heart = display.newImage(scene.imageSheet, 15)
	heart.x, heart.y = 169, 80
	scene.barGrp:insert(heart)
	
	-- afegeix cors
	local addHeart = display.newImage(scene.imageSheet, 24)
	addHeart.x, addHeart.y = 205, 90
	scene.barGrp:insert(addHeart)
	
	-- linies
	local function createLine(x)
		local l = display.newLine(x, 41, x, 116)
		l:setStrokeColor(0, 0, 0, 0.4)
		l.strokeWidth = 1
		scene.barGrp:insert(l)
	end
	createLine(-115)
	createLine(30)
	createLine(127)
	
-- textos
	-- nivell
	local lvlTxt = display.newText(string.upper(translate("level")) .. scene.level, 0, -88, INTERSTATE_BOLD, 23)
	lvlTxt:setFillColor(0, 0, 0, 0.6)
	scene.upperGrp:insert(lvlTxt)
	
	-- morts lbl
	local deathsLbl = display.newText(translate("deaths"), -170, 60, BRUSH_SCRIPT, 23)
	deathsLbl:setFillColor(0, 0, 0, 0.6)
	scene.barGrp:insert(deathsLbl)
	
	-- morts num
	scene.deathsTxt = display.newText(50, -170, 90, INTERSTATE_BOLD, 35)
	scene.deathsTxt:setFillColor(0, 0, 0, 0.6)
	scene.barGrp:insert(scene.deathsTxt)
	
	-- score lbl
	local scoreLbl = display.newText(translate("score"), -45, 60, BRUSH_SCRIPT, 23)
	scoreLbl:setFillColor(0, 0, 0, 0.6)
	scene.barGrp:insert(scoreLbl)
	
	-- score num
	scene.scoreTxt = display.newText(500, -45, 90, INTERSTATE_BOLD, 35)
	scene.scoreTxt:setFillColor(0, 0, 0, 0.6)
	scene.barGrp:insert(scene.scoreTxt)
	
	-- temps lbl
	local timeLbl = display.newText(translate("time"), 80, 60, BRUSH_SCRIPT, 23)
	timeLbl:setFillColor(0, 0, 0, 0.6)
	scene.barGrp:insert(timeLbl)
	
	-- temps num
	local timeTxt = display.newText("1:11", 80, 90, INTERSTATE_BOLD, 35)
	timeTxt:setFillColor(0, 0, 0, 0.6)
	scene.barGrp:insert(timeTxt)
	
	-- vides
	local lifeTxt = display.newText("8", 170, 78, INTERSTATE_BOLD, 25)
	lifeTxt:setFillColor(0, 0, 0, 0.6)
	scene.barGrp:insert(lifeTxt)
	
	-- achievements num
	local achievementsNum = display.newText("0/24", 0, 0, INTERSTATE_BOLD, 25)
	achievementsNum:setFillColor(0, 0, 0, 0.6)
	scene.achievementsSheetGrp:insert(achievementsNum)
	
-- botons
	local function createBtn(id, spriteIndex, x, y)
		local btn = AZ.ui.newSuperButton({
		id = id, sound = AZ.soundLibrary.buttonSound,
		onTouch = scene.onTouch, imageSheet = scene.imageSheet,
		unpressed = spriteIndex, pressedFilter = "filter.invertSaturate",
		x = x, y = y })
		btn:scale(scale, scale)
		scene.view:insert(btn)
		
		return btn
	end
	
	scene.replayBtn = createBtn("replay", 8, display.contentWidth *0.2, display.contentHeight *0.9)
	scene.shopBtn = createBtn("shop", 11, display.contentCenterX, display.contentHeight *0.97)
	scene.levelsBtn = createBtn("levels", 16, display.contentWidth *0.8, display.contentHeight *0.9)
	
	scene.achievementsSheetGrp.y = 8
	scene.barGrp:insert(scene.achievementsSheetGrp)
	
	scene.upperGrp:scale(scale, scale)
	scene.upperGrp.y = display.contentCenterY
	scene.barGrp:scale(scale, scale)
	scene.barGrp.y = display.contentCenterY
	
	scene.upperGrp.finalY = scene.upperGrp.contentHeight *0.95
	scene.barGrp.finalY = display.contentHeight *0.65
	
	
	if event.params.forceEnd then
		scene.upperGrp.y = scene.upperGrp.finalY
		scene.barGrp.y = scene.barGrp.finalY
		
	else
		scene.upperGrp.y = display.contentCenterY
		scene.barGrp.y = display.contentCenterY
		scene.achievementsSheetGrp.isVisible = false
		
	end
end

function scene:enterScene(event)
	
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)

return scene