
local scene = AZ.S.newScene()
scene.currentStage = nil

scene.timerID = nil

scene.strFinal = nil
scene.lblStory = nil

scene.background = nil
scene.imgStory = nil

scene.finishStory = function()
    local options = 
    {
        effect = SCENE_TRANSITION_EFFECT,
        time = SCENE_TRANSITION_TIME,
        params = { stage = scene.currentStage, changeStage = true }
    }
    AZ.S.gotoScene(STAGE_NAME, options);
end

scene.tap = function(event)
    scene.finishStory()
end

scene.writeNextChar = function()
    --print(lblStory.text)
    local myTxt = scene.lblStory
    local finalTxt = scene.strFinal
    
    myTxt.text = myTxt.text .. finalTxt:sub(#myTxt.text+1, #myTxt.text+1)
    
    if #finalTxt == #myTxt.text then
        scene.timerID = timer.performWithDelay(STORY_TIME, scene.finishStory)
    end
    
end

function scene:createScene( event )
    local group = self.view
    scene.currentStage = event.params.stage
    
    require("stage.info.infoStage".. scene.currentStage)
    
    scene.background = display.newImage(stage_storyboard[1].storyboardImage)
    scene.background:scale(display.contentHeight/scene.background.height, display.contentHeight/scene.background.height)   
    scene.background.x = display.contentCenterX
    scene.background.y = display.contentCenterY
    scene.background:addEventListener("tap", scene.tap)
    
    scene.imgStory = display.newRect(
        0,
        display.contentHeight * 0.6,
        display.contentWidth,
        display.contentHeight * 0.4)
    local gradient = graphics.newGradient({0, 0, 0, 0}, {0, 0, 0, 200})
    scene.imgStory:setFillColor( gradient )
    group:insert(scene.background) 
    group:insert(scene.imgStory)
end

--[[function scene:destroyScene( event )
    
    
    
end]]

function scene:enterScene( event )    
    local group = self.view
    --si aquest nivell ha de mostrar una historia    
    require("stage.info.infoStage".. scene.currentStage)
    
    scene.strFinal = AZ.utils.translate(stage_storyboard[1].storyboardText)
    scene.lblStory = display.newText(--[[Embossed]]
        scene.strFinal,
        display.contentWidth * 0.05,
        display.contentHeight * 0.97,
        display.contentWidth * 0.9,
        0,
        INTERSTATE_REGULAR,
        SMALL_FONT_SIZE * SCALE_DEFAULT
    )
    scene.lblStory:setTextColor(1, 1, 1)
    scene.lblStory:toFront()
    scene.lblStory.y = display.contentHeight * 0.97 - scene.lblStory.height/2
    scene.lblStory.text = ""
    group:insert(scene.lblStory)
    scene.timerID = timer.performWithDelay(STORY_CHAR_TIME, scene.writeNextChar, #scene.strFinal)
end

function scene:destroyScene( event )
    
    if scene.timerID ~= nil then
        timer.cancel(scene.timerID)
    end
    
end

--[[function scene:enterScene( event )
        local group = self.view
end


function scene:exitScene( event )
	local group = self.view  

function scene:didExitScene( event )

    
end

end]]


scene:addEventListener( "touch", scene )
scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
--scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene)
--scene:addEventListener( "didExitScene", scene )


return scene