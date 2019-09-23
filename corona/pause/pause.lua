
local scene = AZ.S.newScene()

-- botons
scene.resumeBtn = nil
scene.restartBtn = nil
scene.levelsBtn = nil
scene.menuBtn = nil

-- variables
scene.stage = 0
scene.level = 0

-- altres
scene.invisibleLayer = nil


function scene.activateDeactivateButtons(isActive)
	scene.invisibleLayer.isHitTestable = not isActive
end

function scene.onTouch(event)
	
	if event.phase == "ended" or event.phase == "release" then
		
		if event.id == scene.resumeBtn._id then
			timer.performWithDelay(SCENE_TRANSITION_TIME, function() Runtime:dispatchEvent({ name = GAMEPLAY_PAUSE_EVNAME, isPause = false, pauseType = "pause" }) end)
			AZ.S.hideOverlay("fade", SCENE_TRANSITION_TIME)
			
		else
			local options = {
				effect = SCENE_TRANSITION_EFFECT, time = SCENE_TRANSITION_TIME,
				params = { stage = scene.stage, level = scene.level }
			}
			
			if event.id == scene.restartBtn._id then
				AZ.S.gotoScene("loading.loading", options)
			
			elseif event.id == scene.levelsBtn._id then
				AZ.S.gotoScene("levels.levels2", options)
			
			elseif event.id == scene.menuBtn._id then
				AZ.S.gotoScene("menu.menu", options)
				
			end
		end
	end
end

function scene.onBackTouch()
	scene.onTouch({ phase = "ended", id = scene.resumeBtn._id })
end

function scene:createScene(event)
	
	scene.stage, scene.level = event.params.currentStage, event.params.currentLevel
	
	local translate = AZ.utils.translate
	
	local _info = require("test_infoStage".. scene.stage)
	
-- grafics
	local bg = display.newImage("assets/fondoliso.jpg")
	local scale = display.contentHeight / bg.contentHeight
	bg:scale(scale, scale) 
	bg.x, bg.y = display.contentCenterX, display.contentCenterY
	bg.alpha = 0.7
	--bg:setFillColor(0.3, 0.3, 0.3, 0.8)
	scene.view:insert(bg)
	
	local function createLine(y)
		local line = display.newLine(display.contentWidth *0.25, y, display.contentWidth *0.75, y)
		line:setStrokeColor(AZ.utils.getColor(AZ_DARK_RGB))
		scene.view:insert(line)
		
		return line
	end
	
	local upperLine = createLine(display.contentHeight *0.2314)
	local lowerLine = createLine(display.contentHeight *0.332)
	
-- textos
	local stageUpperTxt = AZ.ui.createShadowText(string.upper(translate(_info.upper_name)), display.contentCenterX, display.contentHeight * 0.0829, 65 * SCALE_BIG)
	local stageLowerTxt = AZ.ui.createShadowText(translate(_info.lower_name), display.contentCenterX, display.contentHeight *0.1552, 65 * SCALE_BIG)
	scene.view:insert(stageUpperTxt)
	scene.view:insert(stageLowerTxt)
	
	local lvlTxt = display.newText(translate("level") .. scene.level, display.contentCenterX, display.contentHeight *0.2822, INTERSTATE_BOLD, SCALE_BIG *30)
	lvlTxt:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
	scene.view:insert(lvlTxt)
	
	local maxScore = AZ.userInfo.progress.stages[scene.stage].levels[scene.level].score
	
	if maxScore > 0 then
		lvlTxt.y = display.contentHeight *0.2617
		
		local scoreTxt = display.newText(translate("max_score") ..": ".. maxScore, display.contentCenterX, display.contentHeight *0.3037, INTERSTATE_REGULAR, SCALE_BIG *25)
		scoreTxt:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
		scene.view:insert(scoreTxt)
	end
	
-- botons
	local function createBtn(txt, y)
		local btn = AZ.ui.newEnhancedButton({ sound = AZ.soundLibrary.buttonSound,
			id = txt,
			pressed = 36, unpressed = 37,
			x = display.contentCenterX, y = y,
			onEvent = scene.onTouch,
			text1 = { text= string.upper(translate(txt)), fontName = INTERSTATE_BOLD, fontSize = 40, X = 0, Y = 25, color = AZ_DARK_RGB, altColor = AZ_BRIGHT_RGB }
		})
		btn:scale(SCALE_BIG, SCALE_BIG)
		scene.view:insert(btn)
		
		return btn
	end
	
	scene.resumeBtn = createBtn("resume", display.contentHeight *0.4531)
	scene.restartBtn = createBtn("restart", display.contentHeight *0.5915)
	scene.levelsBtn = createBtn("levels", display.contentHeight *0.7279)
	scene.menuBtn = createBtn("menu", display.contentHeight *0.8663)
	
	
	scene.invisibleLayer = display.newRect(bg.x, bg.y, bg.contentWidth, bg.contentHeight)
	scene.invisibleLayer.alpha = 0
	scene.invisibleLayer:addEventListener("touch", function() return true end)
	scene.view:insert(scene.invisibleLayer)
	
	scene.activateDeactivateButtons(false)
end

function scene:enterScene(event)
	scene.activateDeactivateButtons(true)
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)

return scene