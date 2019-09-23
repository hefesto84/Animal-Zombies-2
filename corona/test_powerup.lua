local powerUpModule = {}

powerUpModule.grp = nil
powerUpModule.sparkInfo = nil
powerUpModule.imageSheet = nil
powerUpModule.instance = nil


function powerUpModule:spawnPowerup(wName, amount, frameIndex, delay)
    
    local instance = display.newImage(powerUpModule.imageSheet, frameIndex)
    local superScale = SCALE_BIG *0.945
    instance:scale(superScale, superScale)
    instance.y = -(instance.contentHeight *1.2)
    if math.random(0, 1) == 0 then
        instance.x = display.contentWidth *0.3
    else
        instance.x = display.contentWidth *0.6
    end
    if math.random(0, 1) == 0 then
        instance.xScale = -instance.xScale
    end
    powerUpModule.grp:insert(instance)
    
    -- variables del powerup
    instance.wName = wName
    instance.movingLeft = true
    
    
    instance.destroy = function()
        
        if instance.sparkEffect then
            instance.sparkEffect.destroy()
        end
        
        instance.transID = transition.safeCancel(instance.transID)
        
        display.remove(instance)
        instance = nil
        powerUpModule.instance = nil
        
        Runtime:dispatchEvent({ name = GAMEPLAY_POWERUP_DESTROYED, powerUpName = wName })
    end
    
    instance.getIt = function()
		
		instance.transID = transition.safeCancel(instance.transID)
        
        -- avisem que hem agafat un powerup
        Runtime:dispatchEvent({ name = GAMEPLAY_POWERUP_GET, powerUpName = wName, amount = amount or 1 })
        
        instance.isVisible = false
        
        instance.sparkEffect = display.newSprite(powerUpModule.sparkInfo.imageSheet, powerUpModule.sparkInfo.sequenceData)
        instance.sparkEffect.x, instance.sparkEffect.y = instance.x, instance.y
        instance.sparkEffect.xScale, instance.sparkEffect.yScale = instance.xScale *1.5, instance.yScale *1.5
        instance.sparkEffect:play()
        powerUpModule.grp:insert(instance)
        
        if math.random(0, 1) == 0 then
            instance.sparkEffect.xScale = -instance.sparkEffect.xScale
        end
        instance.rotation = math.random(0, 360)
        
        instance.sparkEffect.destroy = function()
            instance.sparkEffect.transID = transition.safeCancel(instance.sparkEffect.transID)
            
            display.remove(instance.sparkEffect)
            instance.sparkEffect = nil
			
			instance.destroy()
        end
        
        instance.sparkEffect.onPause = function(isPause)
            transition.safePauseResume(instance.sparkEffect.transID, isPause)
        end
        
        instance.sparkEffect.animListener = function(event)
            if event.phase == "ended" then
                if instance.sparkEffect.ended then return end
                
                instance.sparkEffect.ended = true
                
                instance.sparkEffect.transID = transition.to(instance.sparkEffect, { time = powerUpModule.sparkInfo.getAnimFramerate(instance.sparkEffect.sequence), alpha = 0, onComplete = instance.sparkEffect.destroy })
            end
        end
        instance.sparkEffect:addEventListener("sprite", instance.sparkEffect.animListener)
    end
    
    instance.onPause = function(isPause)
        transition.safePauseResume(instance.transID, isPause)
        
        if instance.sparkEffect then
            instance.sparkEffect.onPause(isPause)
        end
    end
    
    instance.onTouch = function(event)
        if event.phase == "ended" then
            instance.getIt()
            instance:removeEventListener("touch", instance.onTouch)
        end
        
        return true
    end
    
    instance.lost = function()
        Runtime:dispatchEvent({ name = GAMEPLAY_POWERUP_LOST, powerUpName = wName })
        instance.destroy()
    end
    
    local rot = 1800
    if math.random(0, 1) == 0 then
        rot = -1800
    end
    
    instance.transID = transition.to(instance, { delay = delay, time = 5000, rotation = rot, y = display.contentHeight + instance.contentHeight, onComplete = instance.lost })

    instance:addEventListener("touch", instance.onTouch)
    
    powerUpModule.instance = instance
    return instance
end 

function powerUpModule:destroy()
    if powerUpModule.instance then
        powerUpModule.instance.destroy()
    end
    
    powerUpModule = nil
end

function powerUpModule:pause(isPause)
    if powerUpModule.instance then
        powerUpModule.instance.onPause(isPause)
    end 
end

function powerUpModule:canSpawnPowerUp()
    return powerUpModule.instance == nil
end

function powerUpModule:init(imageSheet)
    
    powerUpModule.grp = AZ.S.getScene(AZ.S.getCurrentSceneName()).view
    powerUpModule.imageSheet = imageSheet
    powerUpModule.sparkInfo = AZ.animsLibrary.powerUpSparkAnim()
    powerUpModule.instance = nil
    
end

return powerUpModule