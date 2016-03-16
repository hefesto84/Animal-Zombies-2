-- objecte que retornem
local thunder = {}

-- requires
thunder._bg = nil
thunder._board = nil

-- variables
thunder.animInfo = nil
thunder.target = nil
thunder.attackTimerID = nil
thunder.finalTimerID = nil
thunder.sprite = nil


function thunder:damage()
    
    if thunder.target ~= nil then
        if thunder.target.takeDamage({ damage = 1, how = THUNDER_NAME }) then
            thunder.target = nil
        end
    end
end

function thunder:changeTarget(target, isTouching)
    if target ~= nil and target.objType == BOARD_OBJECT_TYPES.ZOMBIE then
        thunder.target = target
    else
        thunder.target = nil
    end
    thunder.sprite.isVisible = isTouching
end

function thunder:updatePosition(x, y)
    thunder.sprite.x, thunder.sprite.y = x, y
end

function thunder:destroy()
    thunder:endThunder()
    thunder = nil
end

function thunder:endThunder()
    
    Runtime:removeEventListener(GAMEPLAY_WEAPON_CANCEL_EVNAME, thunder.forceFinish)
    Runtime:removeEventListener(GAMEPLAY_PAUSE_EVNAME, thunder.pause)
    thunder.target = nil
    
    thunder.attackTimerID = timer.safeCancel(thunder.attackTimerID)
    thunder.finalTimerID = timer.safeCancel(thunder.finalTimerID)
    
    display.remove(thunder.sprite)
end

function thunder.pause(event)
    timer.safePauseResume(thunder.attackTimerID, event.isPause)
    timer.safePauseResume(thunder.finalTimerID, event.isPause)
    
    if thunder.sprite then
        if event.isPause then
            thunder.sprite:pause()
        else
            thunder.sprite:play()
        end
    end
end

function thunder.forceFinish()
    thunder:endThunder()
end

function thunder:startThunder(target, x, y)
    if thunder.finalTimerID == nil then
		
        Runtime:addEventListener(GAMEPLAY_WEAPON_CANCEL_EVNAME, thunder.forceFinish)
        Runtime:addEventListener(GAMEPLAY_PAUSE_EVNAME, thunder.pause)
        
        local function attack()
            thunder:damage()
        end

        local function endThunder()
            thunder:endThunder()
            Runtime:dispatchEvent({ name = GAMEPLAY_WEAPON_FINISH_EVNAME })
        end

        thunder.attackTimerID = timer.performWithDelay(1000 /WEAP_THUNDER_DAMAGE_PER_SECOND, attack, 0)
        thunder.finalTimerID = timer.performWithDelay(WEAP_THUNDER_LIFETIME, endThunder)
    end
    
    thunder.sprite = display.newSprite(thunder.animInfo.imageSheet, thunder.animInfo.sequenceData)
    local tileW, tileH = thunder._board:getTileSize()
    local scale = ((tileW + tileH) *0.5) / ((thunder.sprite.width + thunder.sprite.height) *0.5)
    scale = scale + scale
    thunder.sprite:scale(scale, scale)
    
    thunder.sprite.anchorY = 0.8125
    
    thunder._bg.group:insert(thunder.sprite)
    
    thunder.sprite:play()
        
    thunder:updatePosition(x, y)
    
    thunder:changeTarget(target, true)
end

function thunder:init(params)
    thunder._bg = params.bg
    thunder._board = params.board
    
    thunder.animInfo = AZ.animsLibrary.thunderAnim()
end

return thunder