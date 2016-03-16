
local scene = AZ.S.newScene()

scene.zombie = nil

-- botons
scene.playBtn = nil
scene.fbBtn = nil
scene.infoBtn = nil
scene.configBtn = nil


function scene.gotoScene(newScene)
	
	local options = {effect = SCENE_TRANSITION_EFFECT, time = SCENE_TRANSITION_TIME}
	
	if newScene == "stage.stage" then
		options.effect = "slideLeft"
	else
		options.effect = "slideDown"
	end
	AZ.S.gotoScene(newScene, options)
end

function scene.onTouch(event)
	
	if event.phase == "ended" and event.target.isWithinBounds then
		local id = event.target.id
		
		if id == scene.fbBtn.id then
			
			local function fbCallback(isLogged)
				if isLogged then
					scene.fbBtn.isActive = false
					scene.fbBtn.txt.text = AZ.utils.translate("CONNECTED")
				else
					print("\n\t\tNo hem pogut connectar a FB\n")
				end
			end
			
			AZ.fb:login(fbCallback)
			
		elseif id == scene.playBtn.id then
			scene.zombie.playAnim("play")
			scene.zombie.setAnimCallback(function() scene.gotoScene(id) end)
		else	
			scene.gotoScene(id)
		end
	end
end

function scene:createScene()
	
	AZ.achievementsManager:setup(AZ.userInfo.achievements)
	
	AZ.audio.playBSO(AZ.soundLibrary.menuLoop)
	
	local bg = display.newImage("assets/fondoliso.jpg")
	local scale = display.contentHeight/bg.height
	bg:scale(scale, scale)
	bg.x, bg.y = display.contentCenterX, display.contentCenterY
	scene.view:insert(bg)
	
	local _atlas = require "assets.Atlas.menuAtlas"
	local imgSheet = graphics.newImageSheet("assets/new_guiSheet/menu.png", _atlas:getSheet())
	_atlas = AZ.utils.unloadModule("assets.Atlas.menuAtlas")
	
	local landscape = display.newImage(imgSheet, 6)
	scale = ((display.contentWidth + bg.contentWidth) *0.5)/landscape.width
	landscape:scale(scale, scale)
	landscape.x, landscape.y = display.contentCenterX, display.contentHeight -(landscape.contentHeight *0.5)
	scene.view:insert(landscape)
	
	local logo = display.newImage(imgSheet, 5)
	logo:scale(SCALE_BIG, SCALE_BIG)
	logo.x, logo.y = display.contentCenterX, logo.contentHeight *0.75
	scene.view:insert(logo)
	
-- animal
	local zInfo = {}
	zInfo.sheetData = { width = 256, height = 256, numFrames = 8, contentWidth = 512, contentHeight = 1024 }
	zInfo.imageSheet = graphics.newImageSheet("assets/SpriteSheets/test_chihuahua.png", zInfo.sheetData)
	zInfo.sequenceData = { { name = "play",	sheet = zInfo.imageSheet,	start = 1,	count = 2,	time = 100,	loopDirection = "bounce", loopCount = 7 },
							{ name = "touch",	sheet = zInfo.imageSheet,	start = 3,	count = 6,	time = 350,	loopDirection = "bounce", loopCount = 1 } }
	
	scene.zombie = display.newSprite(zInfo.imageSheet, zInfo.sequenceData)
	scene.zombie.anchorY = 1
	scene.zombie:scale(scale, scale)
	scene.zombie.originalScale = scale
	scene.zombie.x = display.contentCenterX
	scene.view:insert(scene.zombie)
	
	scene.zombie.sound = { play = AZ.soundLibrary.chihuahuaMenuWarfSound, touch = AZ.soundLibrary.chihuahuaSound[2] }
	
	function scene.zombie.breath()
		
		local function callback()
			scene.zombie.transID = transition.to(scene.zombie, { time = 500, xScale = scene.zombie.originalScale, yScale = scene.zombie.originalScale *1.03, transition = easing.inOutQuad, onComplete = scene.zombie.breath })
		end
		
		scene.zombie.transID = transition.to(scene.zombie, { time = 500, xScale = scene.zombie.originalScale *1.03, yScale = scene.zombie.originalScale, transition = easing.inOutQuad, onComplete = callback })
	end
	scene.zombie.breath()
	
	function scene.zombie.playAnim(anim)
		transition.safePause(scene.zombie.transID)
		
		AZ.audio.playFX(scene.zombie.sound[anim], AZ.audio.AUDIO_VOLUME_OTHER_FX)
		scene.zombie:setSequence(anim)
		scene.zombie:play()
	end
	
	function scene.zombie.setAnimCallback(callback)
		scene.zombie.callback = callback
	end
	scene.zombie.setAnimCallback(function() transition.safeResume(scene.zombie.transID) end)
	
	function scene.zombie.animListener(event)
		if event.phase == "ended" then
			scene.zombie:pause()
			if scene.zombie.callback then scene.zombie.callback() end
		end
	end
	scene.zombie:addEventListener("sprite", scene.zombie.animListener)
	
	function scene.zombie.onTouch(event)
		if event.phase == "ended" and not scene.zombie.isPlaying then
			scene.zombie.playAnim("touch")
		end
	end
	scene.zombie:addEventListener("touch", scene.zombie.onTouch)
	
-- botons
	scale = scale *1.2
	
	local function createBtn(params)--(id, x, y, btnIndex, txtParams, touchSound, releaseSound)
		local btn = AZ.ui.newTouchButton({ id = params.id, x = params.x, y = params.y, touchSound = params.touchSound or AZ.soundLibrary.buttonSound, releaseSound = params.releaseSound, txtParams = params.txtParams, btnIndex = params.btnIndex,  imageSheet = imgSheet, onTouch = scene.onTouch })
		btn:setScale(scale, scale)
		scene.view:insert(btn)
		return btn
	end
	
	local padding = display.contentWidth *0.12
	local translate = AZ.utils.translate
	
	scene.playBtn =		createBtn({id = "stage.stage", 	x = display.contentCenterX, 			y = display.contentCenterY,	 						btnIndex = 4, txtParams = { text = translate("PLAY"), 	font = INTERSTATE_BOLD, fontSize = 50, color = AZ_DARK_RGB, y = -3 }, touchSound = AZ.soundLibrary.forwardBtnSound})
	scene.fbBtn = 		createBtn({id = "fb",				x = display.contentCenterX, 			y = scene.playBtn.y + scene.playBtn.contentHeight, 	btnIndex = 2, txtParams = { text = translate("CONNECT"), 	font = INTERSTATE_BOLD, fontSize = 23, color = AZ_DARK_RGB, x = 30, y = -5 }})
	scene.configBtn = 	createBtn({id = "options.options",	x = padding, 							y = display.contentHeight - padding, 					btnIndex = 1, touchSound = AZ.soundLibrary.forwardBtnSound})
	scene.infoBtn = 	createBtn({id = "credits.credits",	x = display.contentWidth - padding, 	y = display.contentHeight - padding, 					btnIndex = 3, touchSound = AZ.soundLibrary.forwardBtnSound})
	
	if AZ.userInfo.fbToken then
		scene.fbBtn.isActive = false
		scene.fbBtn.txt.text = translate("CONNECTED")
	end
	
	scene.zombie.y = scene.playBtn.y
	
	
	local versionCodeTxt = display.newText("v.".. (AZ.versionCode or "NONE"), display.contentCenterX, display.contentHeight *0.95, native.systemFontBold, 15 * scale)
	versionCodeTxt:setFillColor(1, 0, 0)
	scene.view:insert(versionCodeTxt)
end

function scene.onBackTouch()
	
	local function alertListener(event)
		if event.action == "clicked" and event.index == 2 then
			os.exit()
		end
	end
	
	native.showAlert("EXIT", "Are you sure you want to quit?", { "Cancel", "Yes" }, alertListener)
end

function scene:exitScene()
	scene.zombie.transID = transition.safeCancel(scene.zombie.transID)
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener("createScene", scene)
scene:addEventListener("exitScene", scene)

return scene