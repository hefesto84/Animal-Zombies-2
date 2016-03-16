
require("mobdebug").start()


local isAndroid = system.getInfo("platformName") == "Android"
local background = nil

if isAndroid then
    background = display.newImage("androidSplash.jpg")
    background:scale(display.contentHeight/background.height, display.contentHeight/background.height) 
    background.x, background.y = display.contentCenterX, display.contentCenterY
end

require "controller.animalzombies.AZController"
AZ:initialize()
--AZ.S.purgeOnSceneChange = true
AZ.S.removeOnSceneChange = true

local function onSystem(event)
    if event.type == "applicationSuspend" or event.type == "applicationExit" then
        Runtime:dispatchEvent({ name = GAMEPLAY_PAUSE_EVNAME, isPause = true, pauseType = "pause" })
        system.setIdleTimer(true)
        ----FlurryController.forceSend()
    elseif event.type == "applicationResume" then
        system.setIdleTimer(false)
    end
end
Runtime:addEventListener("system", onSystem)

local function onAndroidBackTouch(event)
	if event.keyName == "back" and event.phase == "up" then
		if AZ.S.isInScene then
			local scene = AZ.S.getCurrentSceneOrOverlay()
			scene:dispatchEvent({ name = ANDROID_BACK_BUTTON_TOUCH_EVNAME })
		end
		
		return true
	end
end
Runtime:addEventListener("key", onAndroidBackTouch)

local function endSplash()

    AZ.S.gotoScene("thousandgears.thousandgears", { time = SCENE_TRANSITION_TIME, effect = SCENE_TRANSITION_EFFECT })
    
    if isAndroid then
        display.remove(background)
    end
end

if isAndroid then
    timer.performWithDelay(1000, endSplash)
else
    endSplash()
end
