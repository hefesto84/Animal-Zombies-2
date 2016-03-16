
require "tipsContainer"

local scene = AZ.S.newScene()
local params
local circleLoad = nil
local deltaTime = 0


local function getDeltaTime()
    local temp = system.getTimer() --Get current game time in ms
    local dt = (temp-deltaTime) *0.001
    deltaTime = temp --Store game time
    return dt
end

local function rotate()
    local rotation = LOADING_ROTATION_SPEED * getDeltaTime()
    circleLoad:rotate(rotation)
end

local function gotoGameplay()
    local options = 
    {
        effect = SCENE_TRANSITION_EFFECT,
        time = SCENE_TRANSITION_TIME,
        params = params
    }

    Runtime:removeEventListener("enterFrame", rotate)

    AZ.S.gotoScene("test_ingameScene", options)
    --AZ.S.gotoScene(INGAME_NAME, options)
end

function scene:createScene( event )
    local group = self.view
    
    deltaTime = 0
    
    audio.stop(1)
    
    local background = display.newImage("loading/assets/loading_bg.jpg")
    background:scale(display.contentHeight/background.height, display.contentHeight/background.height) 
    background.x, background.y = display.contentCenterX, display.contentCenterY
    group:insert(background)
    
    circleLoad = display.newImage("loading/assets/circle_load.png")
    circleLoad:scale(display.contentHeight/background.height, display.contentHeight/background.height)
    circleLoad.x, circleLoad.y = display.contentCenterX, display.contentCenterY
    group:insert(circleLoad)
    
--    local loadingTxt = display.newText(AZ.utils.translate("loading"), display.contentCenterX, display.contentHeight *0.25, INTERSTATE_BOLD, SMALL_FONT_SIZE * SCALE_DEFAULT)
--    loadingTxt:setFillColor(0, 0, 0, 0.4)
--    group:insert(loadingTxt)
    params = event.params
    
    timer.performWithDelay(LOADING_LIFETIME, gotoGameplay)
    
    Runtime:addEventListener("enterFrame", rotate)
    --timerID = timer.performWithDelay(LOADING_TIME/50, rotateCircleLoad,0)
end

scene:addEventListener( "createScene", scene )
return scene