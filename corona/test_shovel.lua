-- objecte que retornem
local shovel = {}

-- variables
local board
local ice
local stone

-- FUNCIONS PÚBLIQUES ----------------------------------------------------------
function shovel:updateObject (eventTouchPath, eventTouchCurrentX, eventTouchCurrentY, dragBlocked, touchID)
    --A cada event de Move de Touch mirem si podem desplaçar l'objecte
    --Preparem les dades necessàries
    local touchInitialTileID = eventTouchPath[1];
    local touchCurrentTileID = eventTouchPath[#eventTouchPath];
    local touchInitialObject = board:getObjectAtPosition(touchInitialTileID);
    local touchInitialEnabled = board:getTouchEnableInTile(touchInitialTileID);
    
    --Comprovem l'acció que cal realitzar
    if not dragBlocked then
        --En aquest moment podem realitzar drags
        if touchInitialObject ~= nil and touchInitialEnabled == true then
            --Hem desplaçat un tile amb objecte i amb Touch activat
            --Fem només actualització de posició si ja hem canviat de casella una vegada com a mínim
            local isZombieInitial = touchInitialObject.objType == BOARD_OBJECT_TYPES.ZOMBIE;
            if isZombieInitial and #eventTouchPath > 1 then
                --L'objecte de l'inici és un zombie, i l'estem portant a una posició diferent de la inicial
                if touchInitialObject.isDragValidTarget() then
                    --Podem fer Drag
                    --Actualitzem la seva posició
                    
                    --[[
                    local auxX, auxY = eventTouchCurrentX, eventTouchCurrentY;
                    if board:isIndexValid(touchCurrentTileID) then
                        auxX, auxY = board:getTilePos(touchCurrentTileID);
                    end
                    board:updateObjectAtPosition(touchInitialTileID, auxX, auxY)
                    ]]
                    board:updateObjectAtPosition(touchInitialTileID, eventTouchCurrentX, eventTouchCurrentY)
                    
                else
                    --No podem fer Drag
                    --Avisem al Board de que pot cancel·lar aquest Touch
                    board:cancelTouchEvent(touchID);
                end    
            end
        end
    else
        --No podem realitzar drags
        --Si ja ens hem desplaçat del tile, cancel·lem aquest Touch, doncs serà invàlid
        if #eventTouchPath > 1 then
            --Avisem al Board de que pot cancel·lar aquest Touch
            board:cancelTouchEvent(touchID);
        end
    end
end

function shovel:endTouch (eventTouchPath, eventTimeElapsed, dragBlocked)
    --S'ha acabat un event de Touch
    --En funció de l'estat actual, prenem una acció o una altra
    
    --Obtenim les dades necessàries
    local touchInitialTileID = eventTouchPath[1];
    local touchFinalTileID = eventTouchPath[#eventTouchPath];
    local touchInitialObject = board:getObjectAtPosition(touchInitialTileID);
    local touchFinalObject = board:getObjectAtPosition(touchFinalTileID);
    local touchInitialEnabled = board:getTouchEnableInTile(touchInitialTileID);
    local touchFinalEnabled = board:getTouchEnableInTile(touchFinalTileID);
    
    --Fem un tractament per casos
    if touchInitialEnabled == true then
        if touchInitialObject ~= nil then
            local isZombieInitial = touchInitialObject.objType == BOARD_OBJECT_TYPES.ZOMBIE;
            if isZombieInitial == true then
                --L'objecte inicial és un Zombie
                if touchFinalTileID == 0 then
                    --Hem acabat el Touch fora del Board
                    --Posem l'objecte inicial a la seva posició
                    board:resetObjectAtPosition(touchInitialTileID);
   
                elseif touchInitialTileID == touchFinalTileID then
                    --Hem arrossegat un objecte a sobre d'una altra posició del board
                    --No hem sortit del Tile, o hem tornat a la original
                    --No fem res especial. Resetejem l'objecte dins la posició del board, en cas de que ja ens haguem mogut
                    if #eventTouchPath > 1 then
                        --Hem desplaçat l'objecte a un tile adjacent i llavors hem tornat
                        --Resetejem l'objecte
                        board:resetObjectAtPosition(touchInitialTileID);
                    else 
                        --Hem fet tap a sobre d'un únic zombie
                        --Mirem si el temps de touch ha sigut inferior al mínim
                        if eventTimeElapsed <= INGAME_MAX_TIME_TO_KILL then
                            --Es considera un tap vàlid
                            --Enviem la notificació per a informar al zombie
                            touchInitialObject:dispatchEvent({name = OBJECT_TOUCH_EVNAME, how = "shovel" });
                        end
                    end

                else
                    --Hem arrossegat l'objecte a una nova posició
                    --Si el zombie i el Tile estan en un estat correcte, prenem l'acció pertinent
                    local zombieValid = not dragBlocked and touchInitialObject.isDragValidTarget();
                    local tileValid = touchFinalEnabled and not ice:getAnyIceAtPosition(touchFinalTileID) and not stone:checkIfPending (touchFinalTileID);
                    if zombieValid and tileValid then
                        --No estem bloquejats, i el Tile final accepta events de Touch
                        if touchFinalObject == nil then
                            --L'hem arrossegat a una posició buida
                            --Movem l'objecte a la nova posició
                            if not board:moveObjectToPosition (touchInitialTileID, touchFinalTileID) then
                                --Tornem a posar el Tile en la posició inicial
                                board:resetObjectAtPosition(touchInitialTileID); 
                            end
                    
                        else 
                            --L'hem arrossegat a una posició ocupada
                            --Mirem el tipus d'objecte que hi ha al Tile per saber si podem arrossegar-lo o no
                            if touchFinalObject.objType == BOARD_OBJECT_TYPES.TRAP then
                                --Hem arrossegat un Zombie cap a una trampa
                                if not touchFinalObject.dragObjectToIt(touchInitialTileID) then
                                    board:resetObjectAtPosition(touchInitialTileID)
                                end
                                
                            elseif touchFinalObject.objType == BOARD_OBJECT_TYPES.CONTAINER then
                                --Hem arrossegat un Zombie a una Caixa
                                if not touchFinalObject.dragZombie(touchInitialObject) then
                                    board:resetObjectAtPosition(touchInitialTileID)
                                end
                                
                            else 
                                --L'hem arrossegat a una posició ocupada per un objecte amb el que no interactuem
                                --Resetejem l'objecte
                                board:resetObjectAtPosition(touchInitialTileID);
                            end
                        end
                    else
                        --El Tile destí o la situació actual no permet desplaçaments
                        --Si estàvem movent un objecte, el retornem a la posició inicial
                        board:resetObjectAtPosition(touchInitialTileID);
                    end
                end
            end 
        end

    else
        -- El Tile origen no té el Touch Enable
        --Si estàvem movent un objecte, el retornem a la posició inicial
        if touchInitialObject ~= nil then
            board:resetObjectAtPosition(touchInitialTileID);
        end
    end
    
    --Cal també el cas de fer Touch en una posició buida on hi ha un gel, que s'ha de trencar
    if #eventTouchPath == 1 and eventTimeElapsed <= INGAME_MAX_TIME_TO_KILL and touchFinalEnabled then
        --Hem clickat en una posició vàlida
        ice:newTouchInTile(touchFinalTileID);
    end
	
	return true
end

function shovel:cancelTouch (eventTouchPath)
    --S'ha cancel·lat un event que es duia a terme mentre teníem el Shovel actiu
    local touchInitialTileID = eventTouchPath[1];
    local touchInitialObject = board:getObjectAtPosition(touchInitialTileID);
    
    if touchInitialObject ~= nil then
        board:resetObjectAtPosition(touchInitialTileID);
    end
end

function shovel:newZombieInvalid (tileID)
    --Un Zombie del Board acaba de tornar-se invàlid per a fer Drag
    --Cancel·lem tots els events de touch que pogués estar tenint
    board:cancelTouchEventsInTile (tileID);
end

local function assertInitParams (params)
    --Comprovem que hem rebut tots els paràmetres necessaris
    local msg = "Tried to initialize the Shovel module without ";
    AZ:assertParam(params, "Shovel Init Error", msg .."params");
    AZ:assertParam(params.board, "Shovel Init Error", msg .."'params.board'");
    AZ:assertParam(params.ice, "Shovel Init Error", msg .."'params.ice'");
    AZ:assertParam(params.stone, "Shovel Init Error", msg .."'params.stone'");
end

function shovel:destroy()
    --Se'ns demana destuir el mòdul
    shovel = nil;
end


function shovel:init ( params )
    --Fem la comprovació de que tots els paràmetres són correctes
    assertInitParams(params);
    
    --Si hem arribat fins aquí és perquè tots els paràmetres són correctes
    board = params.board;
    ice = params.ice;
    stone = params.stone;
end

return shovel



