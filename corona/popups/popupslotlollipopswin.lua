local scene = AZ.S.newScene()

local _R = SCALE_BIG
scene.lollipops = {}
local timerID = nil

local function rechargeLollipops()
    for i = 1, 7 do
        transition.to(
           scene.lollipops[i], 
           {
               time = 400, 
               delay = 200*(i-1), 
               alpha = 0.5, 
               xScale = 0.7, 
               yScale = 0.7, 
               x = display.contentWidth-40*_R,
               y = 40*_R, transition = easing.inOutExpo, 
               onStart = function()
                   if i == 1 then
                       transition.to(scene.lollipops[6], {time = 150, delay = 50, xScale = 1, yScale = 1})
                   elseif i == 2 then
                       transition.to(scene.lollipops[5], {time = 150, delay = 50, xScale = 1, yScale = 1})
                   elseif i == 3 then
                       transition.to(scene.lollipops[4], {time = 150, delay = 50, xScale = 1, yScale = 1})
                   elseif i == 5 then
                       transition.to(scene.lollipops[7], {time = 150, delay = 50, xScale = 1, yScale = 1})
                   end
               end,
               onComplete = function() 
                   transition.to(
                       scene.lollipops[i], 
                       {
                           time = 100, 
                           alpha = 0,
                           xScale = 0.001,
                           yScale = 0.001
                       }
                   ) 
               end
           }
        )
    end
    timerID = timer.performWithDelay(2000, function() AZ.S.hideOverlay(); Runtime:dispatchEvent({ name = GAMEPLAY_PAUSE_EVNAME, isPause = false, pauseType = "refillLollipops", success = true }) end)
end

function scene:createScene(event)
    local group = scene.view 
    
    for i = 1, 7 do
        scene.lollipops[i] = display.newImage("popups/assets/ic_slot_piruleta.png")
        if i == 1 or i == 6 then
            scene.lollipops[i].x, scene.lollipops[i].y = display.contentCenterX-(334*0.35)*_R, display.contentCenterY
        elseif i == 2 or i == 5 or i == 7 then
            scene.lollipops[i].x, scene.lollipops[i].y = display.contentCenterX, display.contentCenterY
        elseif i == 3 or i == 4 then
            scene.lollipops[i].x, scene.lollipops[i].y = display.contentCenterX+(334*0.35)*_R, display.contentCenterY
        end
        scene.lollipops[i]:scale(_R,_R)
        if i > 3 then
            scene.lollipops[i].xScale, scene.lollipops[i].yScale = 0.001, 0.001
        end
        group:insert(scene.lollipops[i])
    end
    
    rechargeLollipops()
    
end

function scene:exitScene(event)
    if timerID then
        timer.cancel(timerID)
    end
end

scene:addEventListener("createScene", scene)
scene:addEventListener("exitScene", scene)

return scene
