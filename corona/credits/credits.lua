
local scene = AZ.S.newScene()

scene.devs = {
	{ field = "Production", 		developers = "Roger Montserrat" },
	{ field = "Game Design", 		developers = "Roger Montserrat\nDaniel Santeugini" },
	{ field = "Lead Artist", 		developers = "Max Carrasco" },
	{ field = "Animation", 		developers = "José I. Salmerón" },
	{ field = "Graphic Design", 	developers = "Albert Oriol\nSara Salmerón" },
	{ field = "Lead Programming",	developers = "Daniel Santeugini" },
	{ field = "Programming",		developers = "Gerard Castro\nLisard Cuní\nJordi Ferrer" },
	{ field = "Music",				developers = "Bernat Sanchez" },
	{ field = "Sound FX", 			developers = "Ivan Aguilar" }
}

scene.scroll = nil


function scene.onTouch(event)
	if event.phase == "ended" then
		if not AZ.utils.isPointInRect(event.x, event.y, event.target.contentBounds) or not AZ.utils.isPointInRect(event.xStart, event.yStart, event.target.contentBounds) then
			return
		end
		
		AZ.S.gotoScene("menu.menu", { effect = "slideUp", time = SCENE_TRANSITION_TIME })
	end    
end

function scene.onBackTouch()
	AZ.S.gotoScene("menu.menu", { effect = "slideUp", time = SCENE_TRANSITION_TIME })
end

function scene:createScene()
	
	AZ.audio.playBSO(AZ.soundLibrary.creditsLoop)
	
	local _atlas = require "assets.Atlas.stageCreditsAtlas"
	local imageSheet = graphics.newImageSheet("assets/new_guiSheet/stageCredits.png", _atlas:getSheet())
	_atlas = AZ.utils.unloadModule("assets.Atlas.stageCreditsAtlas")
	
	local bg = display.newImage("assets/fondoliso.jpg")
	local scale = display.contentHeight/bg.height
	bg:scale(scale, scale)
	bg.x, bg.y = display.contentCenterX, display.contentCenterY
	scene.view:insert(bg)
	
	local logo = display.newImage(imageSheet, 7)
	logo:scale(SCALE_DEFAULT, SCALE_DEFAULT)
	logo.x, logo.y = display.contentCenterX, logo.contentHeight *0.7
	scene.view:insert(logo)
	
	local menuBtn = AZ.ui.newTouchButton({
		id = "menu", onTouch = scene.onTouch,
		x = display.contentCenterX, y = display.contentHeight *0.9208,
		touchSound = AZ.soundLibrary.backBtnSound, releaseSound = AZ.soundLibrary.switchSound,
		btnIndex = 1,  imageSheet = imageSheet })
	menuBtn:setScale(SCALE_BIG *1.2, SCALE_BIG *1.2)
	scene.view:insert(menuBtn)
	
	
	local fieldW = display.contentWidth *0.4
	local fieldX, devX = display.contentWidth *0.25, display.contentWidth *0.75
	local fieldFontSize, devFontSize = 30 * SCALE_DEFAULT, 34 * SCALE_DEFAULT
	
	local function createDevField(field, developers, y)
		local grp = display.newGroup()
		grp.y = y
		
		local fieldTxt = display.newText({ text = field, x = fieldX, width = fieldW, font = BRUSH_SCRIPT, fontSize = fieldFontSize, align = "right" })
		fieldTxt:setFillColor(AZ.utils.getColor(AZ_DARK_RGB), 0.6)
		fieldTxt.anchorY = 0
		grp:insert(fieldTxt)
		
		local devTxt = display.newText({ text = developers, x = devX, width = fieldW, font = INTERSTATE_BOLD, fontSize = devFontSize })
		devTxt:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
		devTxt.anchorY = 0
		grp:insert(devTxt)
		
		return grp
	end
	
	local posY = 0
	local offsetY = display.contentHeight *0.03
	local devGrp = display.newGroup()
	
	for i = 1, #scene.devs do
		local dev = createDevField(scene.devs[i].field, scene.devs[i].developers, posY)
		devGrp:insert(dev)
		
		posY = dev.contentBounds.yMax + offsetY
	end
	
	local function hola(event)
		
		if event.target and event.target._view then
			print("velocity", event.target._view._velocity)
			print("friction", event.target._view._friction)
		else
			AZ.utils.print(event)
		end
	end
	
	local _widget = require "widget"
	scene.scroll = _widget.newScrollView({
		height = (menuBtn.contentBounds.yMin - logo.contentBounds.yMax) *0.9,
		scrollHeight = devGrp.contentHeight,
		hideBackground = true, hideScrollBar = true,
		leftPadding = padding, rightPadding = padding,
		horizontalScrollDisabled = true,
		--listener = hola
	})
	_widget = AZ.utils.unloadModule("widget")
	
	scene.scroll.y = logo.contentBounds.yMax + ((menuBtn.contentBounds.yMin - logo.contentBounds.yMax) *0.5)
	scene.scroll:insert(devGrp)
	scene.view:insert(scene.scroll)
	
	local function autoScrollDown()
		timer.performWithDelay(SCENE_TRANSITION_TIME *0.5, function() scene.scroll:scrollToPosition({ y = 0, time = 1250 }) end)
	end
	
	scene.scroll:scrollToPosition({ y = -devGrp.contentHeight, time = 1, onComplete = autoScrollDown })
end

function scene:destroyScene()
	display.remove(scene.scroll)
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener("createScene", scene)
scene:addEventListener("destroyScene", scene)

return scene