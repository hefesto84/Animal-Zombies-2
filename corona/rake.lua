module(..., package.seeall)

local ingameUI

local get, lost = nil

rakeInstance = nil
isDisabled = false

function getStatistics()
    return get + lost, get, lost
end

function initialize(UI)
    isDisabled = false
    
    get, lost = 0, 0
    
    ingameUI = UI
end

function spawnRake(tipParams)
    
    local rakeAnim = AZ.animsLibrary.rakeAnim()
    rakeInstance = display.newSprite(rakeAnim.imageSheet1, rakeAnim.sequenceData)
    rakeInstance:setReferencePoint(display.CenterReferencePoint)
    rakeInstance:scale(ZOMBIE_SCALE, ZOMBIE_SCALE)
    rakeInstance:toFront()
    
    rakeInstance.pauseTransitionTime = 0
    rakeInstance.endTransitionTime = 0

    rakeInstance.isTip = tipParams ~= nil
    if rakeInstance.isTip then
        rakeInstance.getCallback = tipParams.endFunc
    end
    

    rakeInstance.disappear = function()
        if rakeInstance.transitionID ~= nil then
            transition.cancel(rakeInstance.transitionID)
        end
        
        display.remove(rakeInstance)
        rakeInstance = nil
    end
    
    rakeInstance.getIt = function()
        rakeInstance:removeEventListener("touch", rakeInstance)
        transition.cancel(rakeInstance.transitionID)
        
        AZ.audio.playFX(AZ.soundLibrary.rakeSound, AZ.audio.AUDIO_VOLUME_OTHER_FX)
        
        rakeInstance:setSequence("get")
        rakeInstance:play()
        rakeInstance:scale(ZOMBIE_EFF_SCALE, ZOMBIE_EFF_SCALE)
        
        if rakeInstance.isTip then
            rakeInstance.getCallback()
        else
            get = get +1
        end
        
        ingameUI.useRake(rakeInstance.isTip)
    end
    
    rakeInstance.onTouch = function(event)
        if event.phase == "ended" and rakeInstance.pauseTransitionTime == 0 and rakeInstance.sequence == "fall" and isDisabled == false then
            rakeInstance.getIt()
        end
        
        return true
    end
    
    rakeInstance.animListener = function(event)
        if event.phase == "ended" and rakeInstance.sequence == "get" then
            rakeInstance.disappear()
        end
    end
    
    rakeInstance.bottomReached = function()

        if rakeInstance.isTip then
            rakeInstance.setAndThrow()
            
            return
        end

        lost = lost +1

        rakeInstance.disappear()
    end
    
    rakeInstance.fallDown = function(fallTime)
        rakeInstance.endTransitionTime = system.getTimer() + fallTime
        rakeInstance.transitionID = transition.to(rakeInstance, { time = fallTime, y = display.contentHeight +50, onComplete = rakeInstance.bottomReached })
    end
    
    rakeInstance.setPause = function(isPause)
        if isPause == true then
            rakeInstance:pause()

            if rakeInstance.sequence ~= "get" then
                rakeInstance.pauseTransitionTime = rakeInstance.endTransitionTime - system.getTimer()
                transition.cancel(rakeInstance.transitionID)
            end
        else
            rakeInstance:play()

            if rakeInstance.sequence ~= "get" then
                rakeInstance.fallDown(rakeInstance.pauseTransitionTime)
                rakeInstance.pauseTransitionTime = 0
            end
        end
    end
    
    rakeInstance.setAndThrow = function()
        rakeInstance.y = -60
    
        if math.random(0, 1) == 0 then
            rakeInstance.x = RELATIVE_SCREEN_X3
        else
            rakeInstance.x = RELATIVE_SCREEN_X3 + RELATIVE_SCREEN_X3
        end
        rakeInstance.fallDown(6000)
    end
    
    
    rakeInstance:play()
    
    rakeInstance.setAndThrow()
    
    rakeInstance:addEventListener("touch", rakeInstance.onTouch)
    rakeInstance:addEventListener("sprite", rakeInstance.animListener)
    
    return rakeInstance
end