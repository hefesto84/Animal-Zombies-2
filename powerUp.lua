module(..., package.seeall)

require "resolutions"

function createPowerUp(animInfo, onTouchFunction)
    local powerUp = display.newSprite(animInfo.imageSheet, animInfo.sequenceData)
    powerUp:setReferencePoint(display.CenterReferencePoint)
    powerUp:scale(ZOMBIE_SCALE, ZOMBIE_SCALE)
    powerUp:toFront()
    
    powerUp.pauseTransitionTime = 0
    powerUp.endTransitionTime = 0
    
    powerUp.disappear = function()
        if powerUp.transitionID ~= nil then
            transition.cancel(powerUp.transitionID)
        end
        
        powerUp:removeSelf()
        powerUp = nil
    end
    
    powerUp.pause = function(isPause)
        if isPause == true then
            powerUp:pause()

            if powerUp.sequence ~= "get" then
                powerUp.pauseTransitionTime = powerUp.endTransitionTime - system.getTimer()
                transition.cancel(powerUp.transitionID)
            end
        else
            powerUp:play()

            if powerUp.sequence ~= "get" then
                powerUp.fallDown(powerUp.pauseTransitionTime)
                powerUp.pauseTransitionTime = 0
            end
        end
    end
    
    powerUp.animListener = function(event)
        if event.phase == "ended" and powerUp.sequence == "get" then
            powerUp.disappear()
        end
    end
    
    powerUp.fallDown = function(fallTime)
        powerUp.endTransitionTime = system.getTimer() + fallTime
        powerUp.transitionID = transition.to(powerUp, { time = fallTime, y = display.contentHeight +50, onComplete = powerUp.disappear })
    end
    
    powerUp.onTouch = function(event)
        if event.phase == "ended" and powerUp.pauseTransitionTime == 0 and powerUp.sequence == "fall" and isDisabled == false then
            timer.performWithDelay(1, powerUp.touchFunction)
        end
        
        return true
    end
    
    if math.random(0, 1) == 0 then
        powerUp.x = RELATIVE_SCREEN_X3
    else
        powerUp.x = RELATIVE_SCREEN_X3 + RELATIVE_SCREEN_X3
    end
    powerUp.y = -60
    
    powerUp:play()
    
    powerUp.fallDown(6000)
    
    powerUp.touchFunction = onTouchFunction
    powerUp:addEventListener("touch", powerUp.onTouch)
    powerUp:addEventListener("sprite", powerUp.animListener)
    
    return powerUp
end