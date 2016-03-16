module(..., package.seeall)

local ingameUI

local get, lost = nil

lollipopInstance = nil
isDisabled = false

function getStatistics()
    return get + lost, get, lost
end

function initialize(UI)
    isDisabled = false
    
    get, lost = 0, 0
    
    ingameUI = UI
end

function spawnLollipop(tipParams)
    
    local lollipopAnim = AZ.animsLibrary.lollipopAnim()
    lollipopInstance = display.newSprite(lollipopAnim.imageSheet1, lollipopAnim.sequenceData)
    lollipopInstance:setReferencePoint(display.CenterReferencePoint)
    lollipopInstance:scale(ZOMBIE_SCALE, ZOMBIE_SCALE)
    lollipopInstance:toFront()
    
    lollipopInstance.pauseTransitionTime = 0
    lollipopInstance.endTransitionTime = 0
    
    lollipopInstance.isTip = tipParams ~= nil
    if lollipopInstance.isTip then
        lollipopInstance.getCallback = tipParams.endFunc
    end
    
    
    lollipopInstance.disappear = function()
        if lollipopInstance.transitionID ~= nil then
            transition.cancel(lollipopInstance.transitionID)
        end
        
        display.remove(lollipopInstance)
        lollipopInstance = nil
    end

    lollipopInstance.getIt = function()
        lollipopInstance:removeEventListener("touch", lollipopInstance)
        transition.cancel(lollipopInstance.transitionID)
        
        AZ.audio.playFX(AZ.soundLibrary.lollipopSound[2], AZ.audio.AUDIO_VOLUME_OTHER_FX)
        
        lollipopInstance:setSequence("get")
        lollipopInstance:play()
        lollipopInstance:scale(ZOMBIE_EFF_SCALE, ZOMBIE_EFF_SCALE)

        if lollipopInstance.isTip then
            lollipopInstance.getCallback()            
        else
            get = get +1
        end

        ingameUI.heal(lollipopInstance.x, lollipopInstance.y)
    end
    
    lollipopInstance.onTouch = function(event)
        if event.phase == "began" and lollipopInstance.pauseTransitionTime == 0 and lollipopInstance.sequence == "fall" and isDisabled == false then
            lollipopInstance.getIt()
        end
    end
    
    lollipopInstance.animListener = function(event)
        if event.phase == "ended" and lollipopInstance.sequence == "get" then
            lollipopInstance.disappear()
        end
    end
    
    lollipopInstance.bottomReached = function()

        if lollipopInstance.isTip then
            lollipopInstance.setAndThrow()
            
            return
        end

        lost = lost +1
        
        lollipopInstance.disappear()
    end
    
    lollipopInstance.fallDown = function(fallTime)
        lollipopInstance.endTransitionTime = system.getTimer() + fallTime
        lollipopInstance.transitionID = transition.to(lollipopInstance, { time = fallTime, y = display.contentHeight +50, onComplete = lollipopInstance.bottomReached })
    end
    
    lollipopInstance.setPause = function(isPause)
        if isPause == true then
            lollipopInstance:pause()

            if lollipopInstance.sequence ~= "get" then
                lollipopInstance.pauseTransitionTime = lollipopInstance.endTransitionTime - system.getTimer()
                transition.cancel(lollipopInstance.transitionID)
            end
        else
            lollipopInstance:play()

            if lollipopInstance.sequence ~= "get" then
                lollipopInstance.fallDown(lollipopInstance.pauseTransitionTime)
                lollipopInstance.pauseTransitionTime = 0
            end
        end
    end
    
    lollipopInstance.setAndThrow = function()
        lollipopInstance.y = -60
    
        if math.random(0, 1) == 0 then
            lollipopInstance.x = RELATIVE_SCREEN_X3
        else
            lollipopInstance.x = RELATIVE_SCREEN_X3 + RELATIVE_SCREEN_X3
        end
        lollipopInstance.fallDown(6000)
    end
    
    
    lollipopInstance:play()
    
    lollipopInstance.setAndThrow()
    
    lollipopInstance:addEventListener("touch", lollipopInstance.onTouch)
    lollipopInstance:addEventListener("sprite", lollipopInstance.animListener)
    
    return lollipopInstance
end