-- objecte que retornem
local stinkBomb = {}

-- requires
stinkBomb._board = nil
stinkBomb._bg = nil

-- variables
stinkBomb.bombsArray = {}
stinkBomb.animInfo = nil


function stinkBomb:throwBomb(tileID)
    
    local obj = stinkBomb._board:getObjectAtPosition(tileID)
    
    if obj ~= nil and obj.objType ~= BOARD_OBJECT_TYPES.ZOMBIE then
        return false
    end
    
    AZ:assertParam(stinkBomb._board, "StinkBomb ThrowBomb Error", "Tried to throw a stink bomb without being initialized")
    
    local success, nearTiles = stinkBomb._board:findIndexesAround(tileID, 3, WEAP_STINKBOMB_DISTANCE, 1)
    
    if not success then return false end
    
    table.insert(nearTiles[1], tileID)
    
    for i = 1, #nearTiles do
        for j = 1, #nearTiles[i] do
            local z = stinkBomb._board:getObjectAtPosition(nearTiles[i][j])

            if z ~= nil then

                if z.zType == AZ.zombiesLibrary.ZOMBIE_RAT_NAME then
                    Runtime:dispatchEvent({ name = GAMEPLAY_STINKBOMB_KILL_RATS_EVNAME })
                else
                    z:dispatchEvent({ name = OBJECT_TOUCH_EVNAME, damage = WEAP_STINKBOMB_DAMAGE, how = STINK_BOMB_NAME })
                end    
            end
        end
        
        --Enviem una notificació per a informar de tots els Tiles afectats
        --L'event espera una llista de ID, de manera que enviem una notificació per a cada llista de ID segons distància
        Runtime:dispatchEvent({ name = GAMEPLAY_EXPLOSION_EVNAME, indexs = nearTiles[i]});
    end
    
-- gràfic
    local explosion = display.newSprite(stinkBomb.animInfo.imageSheet, stinkBomb.animInfo.sequenceData)
    explosion.x, explosion.y = stinkBomb._board:getTilePos(tileID)
    explosion.rotation = math.random(0, 360)
    if explosion.rotation %2 == 0 then
        explosion.xScale = -explosion.xScale
    end
    
    local tileW, tileH = stinkBomb._board:getTileSize()
    local scale = ((tileW + tileH) *0.5) / ((explosion.width + explosion.height) *0.5)
    scale = scale *3.5
    explosion:scale(scale, scale)
    
    stinkBomb._bg.group:insert(explosion)
    
    explosion.destroy = function()
        
        explosion.fadeTransID = transition.safeCancel(explosion.fadeTransID)
        
        display.remove(explosion)
        explosion = nil
        
        table.remove(stinkBomb.bombsArray, 1)
    end
    
    explosion.onPause = function(isPause)
        transition.safePauseResume(explosion.fadeTransID, isPause)
        if isPause then
            explosion:pause()
        else
            explosion:play()
        end
    end
    
    explosion.animListener = function(event)
        if event.phase == "ended" then
            explosion.fadeTransID = transition.to(explosion, { time = stinkBomb.animInfo.getAnimFramerate(explosion.sequence), alpha = 0, onComplete = explosion.destroy })
        end
    end
    
    explosion:play()
    explosion:addEventListener("sprite", explosion.animListener)
    
    stinkBomb.bombsArray[#stinkBomb.bombsArray +1] = explosion
    
    return true
end

-- GESTIÓ DE PAUSA -------------------------------------------------------------
function stinkBomb:pause(isPause)
    for i = 1, #stinkBomb.bombsArray do
        stinkBomb.bombsArray[i].onPause(isPause)
    end
end

-- INIT I DESTROY --------------------------------------------------------------
function stinkBomb:init(board, bg)
    
    AZ:assertParam(board, "StinkBomb Init Error", "Tried to initialize the stink bomb module without 'params.board'")
    AZ:assertParam(bg, "StinkBomb Init Error", "Tried to initialize the stink bomb module without 'params.bg'")
    
    stinkBomb._board = board
    stinkBomb._bg = bg
    
    stinkBomb.bombsArray = {}
    stinkBomb.animInfo = AZ.animsLibrary.explosionCloudAnim()
end

function stinkBomb:destroy()
    for i = 1, #stinkBomb.bombsArray do
        stinkBomb.bombsArray[1].destroy()
    end
    
    stinkBomb = nil
end

return stinkBomb
