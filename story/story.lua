
local scene = AZ.S.newScene()

scene.params = nil
scene.storyTxt = nil
scene.fullStoryTxt = ""
scene.timerID = nil

local background = nil

local function finishStory()
    local options = 
    {
        effect = SCENE_TRANSITION_EFFECT,
        time = SCENE_TRANSITION_TIME,
        params = scene.params
    }
    
    timer.safeCancel(scene.timerID)
    
    if scene.params.storyType == "initial" then
        AZ.S.gotoScene("loading.loading", options)
    elseif scene.params.storyType == "final" then
        
        if scene.params.level == 25 then
            options.params.changeStage = true
            AZ.S.gotoScene("stage.stage", options)
        else
            AZ.S.gotoScene("levels.levels2", options)
        end
    end    
end

local function onTouch (event)
    if event.phase == "ended" then
        --FlurryController:logEvent("in_story_tale", { stage = scene.stage, level = scene.level, end_story = "jump" })

        finishStory ()
    end
end

local function ended ()
    --FlurryController:logEvent("in_story_tale", { stage = scene.stage, level = scene.level, end_story = "wait" })
    
    finishStory ()
end

local function writeNextChar()
    
    scene.storyTxt.text = scene.storyTxt.text .. scene.fullStoryTxt:sub(#scene.storyTxt.text +1, #scene.storyTxt.text +1)
    if #scene.fullStoryTxt == #scene.storyTxt.text then
        timerID = timer.performWithDelay(STORY_LIFETIME, ended)
    end
    
end

function scene:createScene( event )
    
    local group = self.view
    
    scene.params = event.params
    scene.fullStoryTxt = AZ.utils.translate(event.params.story.storyText)
    
    AZ.audio.playBSO(AZ.soundLibrary.storyLoop)

-- background
    background = display.newImage(event.params.story.storyPath)
    background:scale(display.contentHeight/background.height, display.contentHeight/background.height)   
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    background:addEventListener("touch", onTouch)
    group:insert(background) 
    
-- gradient
    local gradRect = display.newRect( 0, 0, display.contentWidth *1.3, display.contentHeight * 0.6)
    local gradient = { type = "gradient", color1 = { 0, 0, 0, 0 }, color2 = { 0, 0, 0, 0.75 }, direction = "down" }
    gradRect:setFillColor( gradient )
    gradRect.x, gradRect.y = display.contentCenterX, display.contentHeight * 0.7
    group:insert(gradRect)
    
-- text
    local txtWidth = display.contentWidth * 0.9
    txtWidth = txtWidth + (4 - (txtWidth %4))

    scene.storyTxt = display.newText(scene.fullStoryTxt, 0, 0, txtWidth, 0, INTERSTATE_REGULAR, SMALL_FONT_SIZE * SCALE_DEFAULT )
    scene.storyTxt:setFillColor(AZ.utils.getColor(AZ_BRIGHT_RGB))
    scene.storyTxt.x, scene.storyTxt.y = display.contentCenterX, display.contentHeight * 0.97 - (scene.storyTxt.height *0.5)
    scene.storyTxt.text = ""
    group:insert(scene.storyTxt)
end

function scene:enterScene( event )    
    scene.timerID = timer.performWithDelay(TYPING_EFFECT_TIME, writeNextChar, #scene.fullStoryTxt)
end

function scene:exitScene( event )
    audio.fadeOut({ channel = 0, time = SCENE_TRANSITION_TIME })
end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )


return scene