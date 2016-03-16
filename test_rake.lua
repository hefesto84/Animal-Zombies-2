-- objecte que retornem
local rake = {}

-- variables
rake.touchID = nil
rake._board = nil
rake._ice = nil
rake.timerID = nil
rake.slashMaxPoints = 3
rake.slashThickness = 20 * SCALE_BIG
rake.slashFadeTime = 150
rake.slashPoints = {}


function rake:updatePosition(posX, posY)
    table.insert(rake.slashPoints, 1, { x = posX, y = posY }) 

    -- Remove any excessed points
    if #rake.slashPoints > rake.slashMaxPoints then 
        table.remove(rake.slashPoints)
        display.remove(rake.slashPoints)
    end

    if #rake.slashPoints > 1 then
        local line = display.newLine(rake.slashPoints[1].x, rake.slashPoints[1].y, rake.slashPoints[2].x, rake.slashPoints[2].y)
        line:setStrokeColor(AZ.utils.getColor(WEAP_RAKE_SLASH_COLOR))
        line.strokeWidth = rake.slashThickness
        
        line.destroy = function()
            display.remove(line)
            line = nil
        end
        
	transition.to(line, { time = rake.slashFadeTime, strokeWidth = line.strokeWidth *0.1, alpha = 0, onComplete = line.destroy })
    end
end

function rake:changeTarget(target, tileID)
    
    if target ~= nil then
        --Apliquem el dany
        target:dispatchEvent({ name = OBJECT_TOUCH_EVNAME, damage = 1, how = RAKE_NAME })
    end
    
    --Mirem si cal trencar el gel que hi hagi al Tile actual
    rake._ice:newTouchInTile(tileID);
end

function rake:removeSlash()
    while(#rake.slashPoints > 0) do
        table.remove(rake.slashPoints)
        display.remove(rake.slashPoints)
    end
end

function rake:destroy()
    rake:endRake()
    rake = nil
end

function rake:endRake()
	rake.timerID = timer.safeCancel(rake.timerID)
	
    --Cancel·lem el touch
    rake._board:cancelTouchEvent(rake.touchID);
    
    Runtime:removeEventListener(GAMEPLAY_WEAPON_CANCEL_EVNAME, rake.forceFinish)
    Runtime:removeEventListener(GAMEPLAY_PAUSE_EVNAME, rake.pause)
	
    AZ.utils.activateDeactivateMultitouch(true)
    rake:removeSlash()
end

function rake.forceFinish()
    if not rake then return end
    
    rake:endRake()
end

function rake.pause(event)
    if not rake then return end

    timer.safePauseResume(rake.timerID, event.isPause)
end

function rake:startRake(target, posX, posY, tileID, touchID)
	
    AZ.utils.activateDeactivateMultitouch(false)
    Runtime:addEventListener(GAMEPLAY_WEAPON_CANCEL_EVNAME, rake.forceFinish)
    Runtime:addEventListener(GAMEPLAY_PAUSE_EVNAME, rake.pause)

    local function finishRake()
        rake:endRake()
		Runtime:dispatchEvent({ name = GAMEPLAY_WEAPON_FINISH_EVNAME })
    end

	rake.timerID = timer.safeCancel(rake.timerID)
    rake.timerID = timer.performWithDelay(WEAP_RAKE_LIFETIME, finishRake)
    rake.slashPoints = {}
    rake.touchID = touchID;
    rake:changeTarget(target, tileID)
    rake:updatePosition(posX, posY)
end

function rake:init(board, ice)
    rake._board = board;
    rake._ice = ice;
end

return rake