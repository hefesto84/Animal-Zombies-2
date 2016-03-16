-- Objeto principal que se retorna
local board = {}

-- Grupo principal del módulo
board.group = nil;

-- Control·ladors necessaris
local physics = nil;
local background = nil;
local wController = nil;
local propController = nil;

--Funció per a regenerar objectes guardats al JSON
local restoreObjectFunc = nil;

--Arrays amb els objectes que conté
local numTilesInBoard = 0
local numRows = 0;
local numColumns = 0;
local tileMap = nil;
local freeTilesMap = nil;
local tileSizeW, tileSizeH = 0, 0;

--Propietats de la Pausa
local pauseEventName = "";
local isPaused = false;

--Propietats de generació de Tiles
local finishObjectEventName = "";
local updateTileEvent = "";
local onDragEvent = "";
local CenterPercX = 0;
local CenterPercY = 0;
local TileSizePercFromWidth = 0;

--Constants
local kDENOMINATOR_IN_PROP_SPAWN_SEQ    = 100; --A cada cercle la probabilitat de fer spawn d'un prop és la del cercle anterior / pel valor

--Propietats del Touch
local touchInTileEventName = "touchInTile";
local genericTileEventName = "newEvent_TILE";
local touchDictInfo = {};
board.numTouchesActive = 0;

--Funció de duplicats
local duplicateFunc = nil;

--Matriu d'espais buits, per a la gestió de patrons
local freeTilesString = "";
local patternsAvailableInCurrentLevel = {};
local patternsInCurrentLevel_Regular = {};
local patternsInCurrentLevel_LastWave = {};
local patternsAvailableNow = {};

-- Definición de los listeners principales
local onError = {name = "onErrorBoard", message = ""};
local onDestroy = {name = "onDestroyBoard", message = "Board Destroyed Successfully"};
local onInitialized = {name = "onInitializedBoard", message = "Board Initialized Successfully"};
local onErrorGeneric = {name = "_onError", message = "", errorType = ""};
local onTouchEvent = {name = "onTouchEventToGameplay", params = {}, message = "New Touch Event Recieved"};
local onVacancyChanged = {name = "onVacancyChanged", patternsAvailable = {}};
local onDestroyTileEvent = ""

-- FUNCIONS DE GESTIÓ PAUSA-----------------------------------------------------
local pausePlayBoard = function(event)
    --L'usuari ha decidit pausar partida
    if not event.isPause then
        --El·liminem tots els events actius de Touch
        for _, touch in pairs(touchDictInfo) do
            local initialObj = board:getObjectAtPosition(touch.touchPath[1])
            --Comprovem que existeix un objecte al tile on ha començat el touch, que es un zombie i que se l'esta arrossegant
            if initialObj ~= nil and initialObj.objType == BOARD_OBJECT_TYPES.ZOMBIE and initialObj.isDragging then
                tileMap[touch.touchPath[1]].resetLayersPosition()
            end
        end

        touchDictInfo = {};
    end
    
    isPaused = event.isPause;
    
    --Treiem el Touch
    board:setTouchEnableToAll(not isPaused);
end


-- FUNCIONS DE CONSULTA DE LA CLASSE -------------------------------------------
function board:getTouchEventName()
    return touchInTileEventName;
end


-- GESTIÓ DE L'EVENT TOUCH -----------------------------------------------------
local function touchEventInTile (event)
    --Fem un control de Touch, per a fer un tractament de Touch que comença, que acaba, swipe, ....
    --Només fem gestió de Touch si no estem en pausa (a l'entrar en pausa s'el·liminen tots els events)
    if not isPaused then
        --Podem tractar el Touch
        --Obtenim la informació necessària de l'event de Touch al Tile
        local eventPhase = event.phase;
        local eventTouchID = event.touchID;
        local eventTileIndex = event.id;

        --Anirem omplint els paràmetres de l'event
        local newparamsEvent = {};
        local currentTouchInfo = touchDictInfo[eventTouchID];

        --print("touchEventInTile - Tile ".. event.params.id ..", phase ".. event.phase)
        if eventPhase == "began" then
            --Comencem un Touch del Tile. Comprovem que no hi hagi un event de Touch amb aquest ID (no hauria de passar mai)
            --Si passa, vol dir que ha començat un altre touch sobre el tile inicial d'un altre touch existent
            if currentTouchInfo == nil then
                --No tenim informació d'aquest event
                --Preparem la informació del nou Event
                local newPath = {};
                table.insert(newPath, eventTileIndex);
                local touchInfo = {touchBeganTime = system.getTimer(), touchPath = newPath, touchID = eventTouchID};

                --Afegim aquesta entrada utilitzant el ID del TouchEvent com a key
                touchDictInfo[eventTouchID] = touchInfo;
                board.numTouchesActive = board.numTouchesActive + 1;

                --Preparem els paràmetres de la notificació
                newparamsEvent = {phase = eventPhase, 
                                    id = eventTouchID,
                                    path = newPath,
                                    timeElapsed = 0,
                                    justChangeTile = true,
                                    x = event.x, 
                                    y = event.y};

            else
                --Ja hi ha informació anterior d'aquest event. No és possible
                print("ERROR: touchBegan "..tostring(eventTouchID).." already exists!");
                return;
            end

        elseif eventPhase == "moved" then
            --El touch s'ha mogut
            if currentTouchInfo ~= nil and currentTouchInfo.touchID == eventTouchID then
                --Tenim informació d'aquest event
                local currentEventPath = currentTouchInfo.touchPath; 
                local lastTileInPath = currentEventPath[#currentEventPath];
                local justChangeTile = false;
                if eventTileIndex ~= lastTileInPath then
                    --Afegim el nou tile al path
                    table.insert(currentEventPath, eventTileIndex);
                    justChangeTile = true;
                end

                --Preparem els paràmetres de la notificació
                newparamsEvent = {phase = eventPhase, 
                                    id = eventTouchID,
                                    path = currentEventPath,
                                    timeElapsed = system.getTimer() - currentTouchInfo.touchBeganTime,
                                    justChangeTile = justChangeTile,
                                    x = event.x, 
                                    y = event.y};
            else 
                --No hi ha informació anterior d'aquest event (o és un event posterior sobre el mateix tile)
                --Es pot deure a un event cancel·lat, o a un que s'ha iniciat en un Tile sense touchEnable
                return;
            end

        elseif eventPhase == "ended" then
            --El touch ha finalitzat
            if currentTouchInfo ~= nil  and currentTouchInfo.touchID == eventTouchID then
                --Preparem els paràmetres de la notificació
                newparamsEvent = {phase = eventPhase, 
                                    id = eventTouchID,
                                    path = currentTouchInfo.touchPath,
                                    timeElapsed = system.getTimer() - currentTouchInfo.touchBeganTime,
                                    justChangeTile = false,
                                    x = event.x, 
                                    y = event.y};

                --El·liminem l'entrada al diccionari
                touchDictInfo[eventTouchID] = nil;
                board.numTouchesActive = board.numTouchesActive - 1;
            else
                --No hi ha informació anterior d'aquest event
                --Es pot deure a un event cancel·lat, o a un que s'ha iniciat en un Tile sense touchEnable
                return;
            end

        else
            --Error
            print("Phase unknown");
        end 

        --Enviem la notificació del nou event de Touch
        --Preparem la informació que enviarem a la notificació al GamePlay
        onTouchEvent.params = newparamsEvent;
        Runtime:dispatchEvent(onTouchEvent);
    end
end

function board:cancelAllTouchEvents()
    --Volem cancel·lar tots els events de Touch que hi hagi actius sobre Tiles
    for key, info in pairs(touchDictInfo) do
        --Preparem la notificació pertinent 
        local newparamsEvent = {phase = "cancelled", 
                                id = 0,
                                path = info.touchPath,
                                timeElapsed = system.getTimer() - info.touchBeganTime,
                                justChangeTile = false,
                                x = 0, 
                                y = 0};
        touchDictInfo[key] = nil;
        board.numTouchesActive = board.numTouchesActive - 1;
        onTouchEvent.params = newparamsEvent;
        Runtime:dispatchEvent(onTouchEvent);
    end
end

local cancelTouchEventsFromTile = function (index)
    --Recorrem la llista d'events i cancel·lem tots els que comencin en un Tile concret
    for key, info in pairs(touchDictInfo) do
        if info.touchPath[1] == index then
            --L'event s'ha iniciat en el Tile que ens interessa
            --Aquest event ha de desaparèixer, enviant la notificació corresponent
            local newparamsEvent = {phase = "cancelled", 
                                id = 0,
                                path = info.touchPath,
                                timeElapsed = system.getTimer() - info.touchBeganTime,
                                justChangeTile = false,
                                x = 0, 
                                y = 0};
                                
            --El·liminem l'entrada al diccionari
            touchDictInfo[key] = nil;
            board.numTouchesActive = board.numTouchesActive - 1;
            onTouchEvent.params = newparamsEvent;
            Runtime:dispatchEvent(onTouchEvent);
        end
    end
end

function board:cancelTouchEventsInTile (index)
    --Volem cancel·lar tots els Touch que hi hagi actius sobre el Tile index
    cancelTouchEventsFromTile(index);
end

function board:cancelTouchEvent (touchID)
    --Volem cancel·lar un Touch concret
    local currentTouchInfo = touchDictInfo[touchID];
    if currentTouchInfo ~= nil then
        --Preparem els paràmetres de la notificació
        local newparamsEvent = {phase = "cancelled", 
                            id = 0,
                            path = currentTouchInfo.touchPath,
                            timeElapsed = system.getTimer() - currentTouchInfo.touchBeganTime,
                            justChangeTile = false,
                            x = 0, 
                            y = 0};

        --El·liminem l'entrada al diccionari
        touchDictInfo[touchID] = nil;
        board.numTouchesActive = board.numTouchesActive - 1;
        onTouchEvent.params = newparamsEvent;
        Runtime:dispatchEvent(onTouchEvent);
    end
end


-- GESTIÓ D'ESTAT ACTUAL DE PATRONS I STRING DE LLIURES ------------------------
local checkIfPatternAvailable = function (pattern)
    --Volem comprovar si el patró rebut per paràmetre encaixa amb l'estat actual del Board
    --Primer mirem si el patró encaixa amb el tamany del Board
    if #pattern ~= #freeTilesString then
        return false
    end
    
    --Anem comprovant totes les posicions
    local errorFound = false;
    local i = 1;
    while i <= #pattern and not errorFound do
        --Obtenim les dues posicions concretes
        local currentPatternPosition = pattern:sub(i, i);
        local currentBoardStatePosition = freeTilesString:sub(i, i);
        
        if currentPatternPosition == "1" and currentBoardStatePosition == "1" then
            --La posició actual del patró diu que és necessari, pero el Board està ocupat en aquesta posició
            --Aquest patró no es compleix
            errorFound = true;
        end
        
        --Incrementem el comptador
        i = i + 1;
    end
    
    return not errorFound;
end

local updatePatternMatches = function ()
    --La composició de cel·les lliures ha canviat en el Board
    --Volem comprovar quins patrons dels suportats es compleixen, i enviar la llista de patrons vàlids amb una notificació
    
    --Comprovem tots els patrons disponibles
    patternsAvailableNow = {};
    for i = 1, #patternsAvailableInCurrentLevel, 1 do
        --Obtenim el patró concret
        local currentPattern = patternsAvailableInCurrentLevel[i];
        if checkIfPatternAvailable(currentPattern.pattern) then
            --El patró es compleix
            --L'afegim a la llista
            table.insert(patternsAvailableNow, currentPattern);
        end
    end
    
    --Enviem l'event per informar al GamePlay dels nous patrons disponibles
    --print(freeTilesString, " i posicions lliures: ", table.concat(freeTilesMap, ", "));
    onVacancyChanged.patternsAvailable = patternsAvailableNow;
    Runtime:dispatchEvent(onVacancyChanged);
end

local setFreeTilesString = function()
    --Amb la informació actual del board preparem l'string que gestiona l'espai lliure
    local newFreeString = "";
    for i = 1, numTilesInBoard, 1 do
        --Accedim a cada Tile i comprovem si està buit o no
        local currentTile = tileMap[i];
        if currentTile.isOccupied then
            --La posició està ocupada
            newFreeString = newFreeString.."1";
        else
            --La posició està lliure
            newFreeString = newFreeString.."0";
        end
    end
    
    --Assignem el nou valor
    freeTilesString = newFreeString;
end

local setFreeTilesStringPosition = function (newPos, newValue)
    --Volem actualitzar una posició concreta de l'String de posicions lliures
    if newPos > 0 and newPos <= numTilesInBoard then
        --Preparem la informació
        local newString = "";
        local pre = freeTilesString:sub(1, newPos - 1);
        local post = freeTilesString:sub(newPos + 1, string.len(freeTilesString));
    
        --Re-construïm el nou string substituint l'element rebut
        if pre ~= nil then
            newString = newString..pre;
        end
        newString = newString..newValue;
        if post ~= nil then
            newString = newString..post;
        end
    
        --Guardem el nou valor
        freeTilesString = newString;
    end
end


-- FUNCIÓ DE CONSULTA D'INDEX --------------------------------------------------    
function board:isIndexValid (index)
    --Retornem si un índex pertany a l'interior del Board
    return index > 0 and index <= numTilesInBoard;
end

function board:getXCoord (index)
    --Retornem la columna a la que es troba un Tile
    if board:isIndexValid(index) then
        return tileMap[index].posInBoard.x;
    else
        return 0;
    end
end


-- FUNCIÓ DE CONSULTA DE TAMANY I POSICIÓ DEL TILE -----------------------------
function board:setTileScaleOriginal (index)
    --Recuperem l'escala original del Tile a la posició index
    currentTile = tileMap[index];
    currentTile.scaleToOriginal();
end

local scaleProp = function (index, scaleValue)
    --Escalem el prop de la posició index
    local currentTile = tileMap[index];
    local currentObject = board:getObjectAtPosition(index);

    if currentObject ~= nil and currentObject.objType == BOARD_OBJECT_TYPES.PROP then
        --El Tile conté un prop
        --Escalem el seu contingut si es de tipus Fence
        if currentObject.isFence then
            currentTile.scaleTile(scaleValue);
        end
    end
end

local scaleProps = function (scaleValue)
    --Escalem tots els Props que hi hagi al Board per a que sobresurtin del seu Tile
    for i = 1, numTilesInBoard, 1 do
        --Accedim al Tile concret
        scaleProp(i, scaleValue);
    end
end

function board:getTileSize ()
    --Retornem els Width i el Height dels Tiles
    return tileSizeW, tileSizeH;
end

function board:getTilePos (index)
    --Retornem la posició del Tile desitjat en el sistema de coordenades del Background (tota la pantalla)
    return AZ.utils.getPosInGrp(tileMap[index].tileGrp, background.group);
end

function board:alignPositionToGround(index)
    --Alieneem el Tile indicat per a treure-li qualsevol rotació que tingui
    if board:isIndexValid(index) then
        tileMap[index].tileGrp.rotation = 0;
    end
end


-- FUNCIONS GET D'OBJECTES------------------------------------------------------
function board:getObjectAtPosition (index)
    -- Retornem l'objecte que hi ha a la capa "main" del Tile indicat
    return board:getObjectAtPositionAtLayer(index, "main");
end

function board:getObjectAtPositionAtLayer (index, layer)
    --Retornem l'objecte que hi ha al layer "layer" del Tile indicat
    --Fem aquí el control de que l'índex estigui dins els límits vàlids
    if board:isIndexValid (index) then
        return tileMap[index].getObjectInLayer(layer);
    else
        return nil;
    end
end

function board:getNumZombies()
    --Retornem el número de Zombies que hi ha actualment al board
    local numZombies = 0;
    for i = 1, numTilesInBoard, 1 do
        local currentObject = tileMap[i].getObjectInLayer("main");
        if currentObject ~= nil and currentObject.objType == BOARD_OBJECT_TYPES.ZOMBIE then
            numZombies = numZombies + 1;
        end
    end
    
    return numZombies;
end

function board:getNumColumns()
    --Retornem el número de columnes
    return numColumns;
end


-- CONSULTES DEL TOUCH ENABLE DELS TILES ---------------------------------------
function board:getTouchEnableInTile (index)
    --Retornem l'estat de TouchEnable del tile index
    if board:isIndexValid (index) then
        return tileMap[index].isTouchEnabled;
    else
        return false;
    end
end


-- CONSULTES DEL VISIBLE DELS TILES --------------------------------------------
function board:setIsVisibleAtPosition(index, newIsVisible)
    --Volem settejar el isVisible d'un tile
    tileMap[index].tileGrp.isVisible = newIsVisible;
end


-- FUNCIONS DE GESTIÓ D'ESPAI LLIURE--------------------------------------------
function board:getAnyEmptyTile ()
    --Retornem l'index d'una posició buida de la llista de Tiles (si n'hi ha)
    --Tornem 0 en cas contrari
    local numFreeTiles = #freeTilesMap;
    if numFreeTiles > 0 then
        local randomIndex = math.random(numFreeTiles);
        return freeTilesMap[randomIndex];
    else
        return 0;
    end
end

local setPositionToFree = function (index)
    --Maquem que una posició passa a considerar-se "Disponible"
    --Actualitzem la taula de freeTilesMap afegint el l'index de la nova posició disponible
    table.insert(freeTilesMap, index);
    
    --Actualitzem l'string
    setFreeTilesStringPosition(index, "0");
end

local setPositionToOccupied = function (indexInFreeTilesMap, indexInTilesMap)
    --Marquem que una posició passa a considerar-se "Ocupada"
    --Actualitzem la taula de freeTilesMap treient l'element que conté l'index de la nova posició ocupada
    table.remove(freeTilesMap, indexInFreeTilesMap);
    
    --Actualitzem l'string
    setFreeTilesStringPosition(indexInTilesMap, "1");
end

local function removeIndexFromFree (index)
    --Volem treure l'índex especificat de la llista de posicions disponibles (si hi és)
    local found = false;
    local i = 1;
    while i <= numTilesInBoard and not found do
        --Mirem si l'hem trobat
        if freeTilesMap[i] == index then
            --L'hem trobat
            setPositionToOccupied(i, index);
            found = true;
        end    
        i = i + 1;
    end
end


-- FUNCIONS D'INSERCIÓ I ESBORRAT D'ELEMENTS------------------------------------
function board:addObject(newObject)
    --Volem afegir l'objecte rebut i posar-lo en una posició al·leatòria (si es pot)
    local randomFreeIndex = board:getAnyEmptyTile();
    if randomFreeIndex == 0 then
        --No queden tiles lliures 
        return false, randomFreeIndex;
    end
    
    --Afegim l'objecte rebut per paràmetre al Tile corresponent
    --Retornem si la operació ha tingut èxit, i l'índex on s'ha afegit
    local success = board:addObjectAtPosition(newObject, randomFreeIndex);
    return success, randomFreeIndex;
end

function board:addObjectAtPosition (newObject, newIndex)
    --Afegim l'objecte a la posició assignada
    --Volem assignar-lo com a objecte principal del Tile, i per a els layers addicionals es cridarà al "addObjectAtPositionAtLayer"
    --Si ja hi ha un objecte en aquesta posició, no es pot afegir
    if tileMap[newIndex].isOccupied then
        return false;
    else
        local success = board:addObjectAtPositionAtLayer (newObject, newIndex, "main");
        return success;
    end
end

local insertObjectInBoardAtPositionAtLayer = function (newObject, newIndex, newLayer)
    --Fem la inserció pròpiament dita de l'objecte al Board
    local targetTile = tileMap[newIndex];
    
    if targetTile.spawnObject({layer = newLayer, object = newObject}) then
        --Treiem la posició de la llista de posicions disponibles (per si encara hi era)
        --Aquest remove només es produeix si és el primer cop que afegim un objecte a aquest Tile
        removeIndexFromFree(newIndex);
        return true;
        
    else 
        return false;
    end
end

function board:addObjectAtPositionAtLayer (newObject, newIndex, newLayer)
    --Volem afegir l'objecte rebut a la posició i layer designats
    if insertObjectInBoardAtPositionAtLayer(newObject, newIndex, newLayer) then
        --L'objecte s'ha pogut insertar
        --Actualitzem els patrons vàlids (només cal fer-ho si s'ha modificat l'objecte principal)
        if newLayer == "main" then
            updatePatternMatches();
        end
            
        return true;
        
    else 
        return false;
    end
end

local deleteFullObjectInPosition = function (tileIndex)
    --Volem treure un objecte del Board (totes les capes), concretament el que està al Tile "tileIndex"
    if board:isIndexValid (tileIndex) then
        --És un índex vàlid
        --Informem al Tile del canvi d'estat
        local currentTile = tileMap[tileIndex];
        if currentTile.isOccupied then
            --Buidem el Tile
            currentTile.clearTile();
    
            --Afegim el Tile actual a la llista de Tiles disponibles
            setPositionToFree(tileIndex);
            
            return true;
        end
    end
    
    --El tile no estava en un estat adequat per esborrar el seu contingut
    return false;
end
    
function board:delObjectsAtPosition (tileIndex)
    --Volem treure un objecte del Board (totes les capes), concretament el que està al Tile "tileIndex"
    local success = deleteFullObjectInPosition(tileIndex);
    if success then
        updatePatternMatches();
    end
    return success;
end

function board:delObjectAtPositionAtLayer (tileIndex, layer)
    --Volem treure un objecte concret d'un Tile del board, concretament el layer "layer" del Tile "tileIndex"
    if board:isIndexValid (tileIndex) then
        --És un índex vàlid
        --El·liminem l'objecte concret del layer
        local currentTile = tileMap[tileIndex];
        if currentTile.isOccupied then
            local deleted, wasLast = currentTile.clearLayerTile(layer);
            if deleted and wasLast then
                --Hem aconseguit el·liminar l'últim layer del Tile
                --Afegim el Tile actual a la llista de Tiles disponibles
                setPositionToFree(tileIndex);
                updatePatternMatches();
                return true;
            end
        end
    end
    
    --El tile i el layer no estava en un estat adequat per esborrar el seu contingut
    return false;
end


-- FUNCIONS DE MANTENIMENT D'OBJECTES-------------------------------------------
function board:updateObjectAtPosition (tileIndex, newX, newY)
    --Volem actualitzar la posició d'un objecte a la pantalla, sense modificar la seva posició lògica dins el board
    if board:isIndexValid (tileIndex) then
        --És un índex vàlid
        --Demanem d'actualitzar la seva posició
        tileMap[tileIndex].drag(newX, newY);
    end
end

function board:resetObjectAtPosition (tileIndex)
    --Volem actualitzar la posició d'un objecte a la pantalla, sense modificar la seva posició lògica dins el board
    if board:isIndexValid (tileIndex) then
        --És un índex vàlid
        --Demanem de fer reset la seva posició
        tileMap[tileIndex].resetLayersPosition();
    end
end

function board:moveObjectToPosition (initialIndex, finalIndex)
    --Desplacem un objecte des de la posició inicial a la posició final
    if not(board:isIndexValid (initialIndex) and board:isIndexValid (finalIndex) and initialIndex ~= finalIndex) then 
        --Els index no són vàlids, o són el mateix
        --No fem res
        return false;
    end
    
    local initialTile = tileMap[initialIndex];
    local finalTile = tileMap[finalIndex];
    if initialTile.isOccupied == false or finalTile.isOccupied == true then
        --Les caselles no estan en un estat vàlid
        return false;
    end
    
    --Intercanviem les posicions
    initialTile.swapTile(finalTile, false);
    setPositionToFree(initialIndex);
    removeIndexFromFree(finalIndex);
    
    
    --Enviem la informació dels patrons vàlids
    updatePatternMatches();
    
    return true;
end

function board:swapObjects (firstIndex, secondIndex)
    --Intercanviem els objectes dels dos Tiles indicats
    if not(board:isIndexValid (firstIndex) and board:isIndexValid (secondIndex) and firstIndex ~= secondIndex) then 
        --Els index no són vàlids, o són el mateix
        --No fem res
        return false;
    end
    
    local firstTile = tileMap[firstIndex];
    local secondTile = tileMap[secondIndex];
    if firstTile.isOccupied == false or secondTile.isOccupied == false then
        --Les caselles no estan en un estat vàlid
        return false;
    end
    
    --Comprovem que no s'estigui fent Drag del Tile destí
    if not secondTile.canDrag then
        return false;
    end
    
    --Intercanviem els dos objectes
    firstTile.swapTile(secondTile, false);
    
    --Enviem la informació dels patrons vàlids
    updatePatternMatches();
    
    return true;
end

function board:replaceObject (initialIndex, finalIndex)
    --Volem "reemplaçar" el contingut del tile finalIndex amb l'objecte que hi ha al tile initialIndex
    if not(board:isIndexValid (initialIndex) and board:isIndexValid (finalIndex) and initialIndex ~= finalIndex) then 
        --Els index no són vàlids, o són el mateix
        --No fem res
        return false;
    end
    
    local firstTile = tileMap[initialIndex];
    local secondTile = tileMap[finalIndex];
    if firstTile.isOccupied == false or secondTile.isOccupied == false then
        --Les caselles no estan en un estat vàlid
        return false;
    end
    
    --Comprovem que no s'estigui fent Drag del Tile destí
    if not secondTile.canDrag then
        return false;
    end
    
    --Afegim l'objecte inicial a la posició final
    firstTile.swapTile(secondTile, false);
    
    --Esborrem l'objecte inicial
    deleteFullObjectInPosition(initialIndex);
    
    --Enviem la informació dels patrons vàlids
    updatePatternMatches();
    
    return true;
end

function board:replaceObjectForExternal (objectToInject, finalIndex)
    --Volem "reemplaçar" el contingut del tile finalIndex amb l'objecte rebut per paràmetre
    if not board:isIndexValid(finalIndex) then
        --L'índex no és vàlid
        --No fem res
        return false;
    end
    
    local finalTile = tileMap[finalIndex];
    if not finalTile.isOccupied then
        --La casella final no es troba en un estat vàlid
        return false;
    end
    
    --Comprovem que no s'estigui fent Drag del Tile destí
    if not finalTile.canDrag then
        return false;
    end
    
    --Esborrem l'objecte del Tile destí
    deleteFullObjectInPosition(finalIndex);
    
    --Afegim l'objecte rebut per paràmetre
    insertObjectInBoardAtPositionAtLayer (objectToInject, finalIndex, "main");
    
    --Enviem la informació dels patrons vàlids
    updatePatternMatches();
    
    return true;
end

function board:expandObjectToPosition (initialIndex, finalIndex)
    --Volem copiar l'objecte que hem arrossegat al nou Tile, fent que l'inicial torni al seu lloc
    if not(board:isIndexValid (initialIndex) and board:isIndexValid (finalIndex) and initialIndex ~= finalIndex) then 
        --Els index no són vàlids, o són el mateix
        --No fem res
        return false;
    end
    
    local firstTile = tileMap[initialIndex];
    local secondTile = tileMap[finalIndex];
    if firstTile.isOccupied == false or secondTile.isOccupied == true then
        --Les caselles no estan en un estat vàlid
        return false;
    end
    
    --Si no tenim una funció per a generar duplicats
    if duplicateFunc == nil then
        Runtime:dispatchEvent({ name = "_onError", errorType = "ExpandObject Error", message = "Tried to copy an object without 'duplicateObjectFunc' function. Set it in the 'board class' at initialization" })
        return false;
    end
    
    --Obtenim un duplicat de l'objecte del Tile original i l'afegim a la posició final'
    local newObject = duplicateFunc(firstTile.getObjectInLayer("main"));
    if newObject ~= nil then
        --Hem pogut crear el duplicat
        insertObjectInBoardAtPositionAtLayer (newObject, finalIndex, "main");
    
        --Tornem a deixar l'objecte inicial a la seva posició
        firstTile.resetLayersPosition();

        --Enviem la informació dels patrons vàlids
        updatePatternMatches();

        return true;
        
    else
        return false;
    end
    
end

-- FUNCIONS PER A GESTIÓ DE PATRONS---------------------------------------------
function board:addObjectsAtPositions (positions, objects)
    --Donada una llista de posicions i una llista d'objectes, insertem aquests al board
    local inserted = {};
    
    --Fem les comprovacions de control
    if #positions ~= #objects then
        --No tenim tantes posicions com objectes
        --És un error
        return positions;
    end
    
    --Anem intentant afegir tots els objectes a la posició que correspòn
    for i = 1, #positions, 1 do
        --Obtenim les dades necessàries
        local currentPosition = positions[i];
        local currentObject = objects[i];
        local currentTile = tileMap[currentPosition];
        
        --Comprovem si podem afegir l'objecte al Tile
        if currentTile.isOccupied == false then
            --El Tile està lliure
            --Afegim el nou objecte a la casella indicada (i)
            insertObjectInBoardAtPositionAtLayer(currentObject, currentPosition, "main");
            table.insert(inserted, currentPosition);
        end
    end
    
    -- Actualitzem els patrons vàlids
    updatePatternMatches();
    
    -- Retornem una llista amb els elements que s'han pogut insertar, per si cal tractar-los des de fora
    return inserted;
end

function board:addPattern (patternIndex, isLastWave)
    --Donat un patró, volem afegir elements al board seguint aquest patró
    --Finalment retornarem una llista amb els index on hi han aparegut zombies del patró
    local indexsToInject = {};
    local objectsToInject = {};
    local returnIndexs = {};

    --Comprovem que l'index sigui vàlid
    if patternIndex < 1 then return false; end
    if not isLastWave and patternIndex > #patternsInCurrentLevel_Regular then return false; end
    if isLastWave and patternIndex > #patternsInCurrentLevel_LastWave then return false; end
    
    --Obtenim la sintaxi del patró desitjat
    local patternDesiredSyntax;
    local patternDesiredZombies;
    
    if not isLastWave then
        patternDesiredSyntax = patternsInCurrentLevel_Regular[patternIndex].pattern;
        patternDesiredZombies = patternsInCurrentLevel_Regular[patternIndex].zombiesID;
    else 
        patternDesiredSyntax = patternsInCurrentLevel_LastWave[patternIndex].pattern;
        patternDesiredZombies = patternsInCurrentLevel_LastWave[patternIndex].zombiesID;
    end
    
    --Preparem una llista amb els index de les caselles on hi volem posar els objectes
    --Comprovant l'estat del Board sabrem si cal crear l'objecte o la posició ja es troba plena
    local currentZombieIndex = 1;
    for y = 1, #patternDesiredSyntax, 1 do
        --Si la casella es "1" volem afegir un objecte en aquesta posició
        if string.sub(patternDesiredSyntax, y, y) == "1" then
            --Voldrem afegir un Zombie a la posició y
            --Comprovem si es podrà afegir
            if not tileMap[y].isOccupied then
                --La posició es troba lliure
                --Creem el zombie que voldrem afegir i el posem a la llista
                local newZombie = restoreObjectFunc(patternDesiredZombies[currentZombieIndex]);
                table.insert(objectsToInject, newZombie);

                --Afegim l'index Y a la llista
                table.insert(indexsToInject, y);
            end

            --Tant si l'hem afegit com si no, incrementem el comptador de zombie 
            currentZombieIndex = currentZombieIndex + 1;
        end
    end

    --L'apliquem
    returnIndexs = board:addObjectsAtPositions(indexsToInject, objectsToInject);

    return true, returnIndexs;
end


-- FUNCIÓ PER APLICAR ACCIÓ A TOTS ELS ELEMENTS MAIN----------------------------
function board:sendEventToAllMain (eventToApply)
    --Volem aplicar una funció a tots els objectes que hi hagi emmagatzemats al board
    for i = 1, numTilesInBoard, 1 do
        --Accedim a l'objecte concret
        local currentObject = tileMap[i].getObjectInLayer("main");
        if currentObject ~= nil then
            --Hi ha un objecte en aquesta posició
            --Li apliquem la funció
            currentObject:dispatchEvent({name = eventToApply});
        end
    end
end


-- FUNCIÓ PER A TROBAR ELS INDEX DE LES CEL·LES ADJACENTS-----------------------
function board:findIndexesAround (tileOriginIndex, searchPattern, range, stateRequired)
    --A partir d'un patró de cerca i una distància màxima, retornem una llista de tots els Tiles que entren dins l'abast
    --Amb el paràmetre de "stateRequired" filtrem quin tipus de caselles ens interessen:
    -- 1 : Tots
    -- 2 : Només les buides
    -- 3 : Només les plenes
    
    if tileOriginIndex < 1 or tileOriginIndex > numTilesInBoard or range < 1 then
        --Error. L'index del tile no és vàlid
        return false, {};
    end
    
    --Preparem l'array de posicions a retornar
    local returnIndexes = {};
    for g = 1, range, 1 do
        returnIndexes[g] = {};
    end
    
    --Preparem les dades del Tile de origen
    local originPosX, originPosY = tileMap[tileOriginIndex].posInBoard.x, tileMap[tileOriginIndex].posInBoard.y;
    
    --Recorrem les posicions del board buscant les que ens interessen
    for i = 1, numTilesInBoard, 1 do
        if i ~= tileOriginIndex then
            local currentTile = tileMap[i];
            local currentPosX, currentPosY = currentTile.posInBoard.x, currentTile.posInBoard.y;
            local distX = math.abs(originPosX - currentPosX); 
            local distY = math.abs(originPosY - currentPosY);
            local distMax = math.max(distX, distY);
            local empty = not currentTile.isOccupied;
            
            --En funció del tipus de patró de cerca, actuem d'una manera o d'una altra
            if searchPattern == 1 then
                --Es tracta d'una cerca en forma de creu +
                --La distancia x o la distancia y han de ser 0, i entrar dins l'abast
                if (distX == 0 and distY <= range) or (distY == 0 and distX <= range) then
                    --La posició és vàlida
                    if stateRequired == 1 or (stateRequired == 2 and empty == true) or (stateRequired == 3 and empty == false) then
                        table.insert(returnIndexes[distMax], i);
                    end
                end
            elseif searchPattern == 2 then
                --Es tracta d'una cerca en forma de creu x
                --La distància X ha de coincidir amb la distància Y i entrar dins l'abast
                if distX == distY and distX <= range then
                    --La posició és vàlida
                    if stateRequired == 1 or (stateRequired == 2 and empty == true) or (stateRequired == 3 and empty == false) then
                        table.insert(returnIndexes[distMax], i);
                    end
                end
            elseif searchPattern == 3 then
                --Es tracta d'una cerca per superficie
                --La distància màxima ha d'entrar dins l'abast
                if distMax <= range then
                    --La posició és vàlida
                    if stateRequired == 1 or (stateRequired == 2 and empty == true) or (stateRequired == 3 and empty == false) then
                        table.insert(returnIndexes[distMax], i);
                    end
                end
            else
                --El patró de cerca no és vàlid
                print("ERROR. Pattern in findIndexesAround invalid [1-3]");
            end
        end
    end
    
    --Retornem el resultat
    return true, returnIndexes;
end


-- FUNCIONS PER AL TRACTAMENT DE TILES FÍSICS ----------------------------------
function board:startPhysicsTile (index)
    --Demanem al board que converteixi un Tile en un objecte físic
    local desiredTile = tileMap[index];
    physics.makeObjectPhysic(desiredTile.tileGrp);
    physics.applyRndForce(desiredTile.tileGrp);
end

function board:stopPhysicsTile (index)
    --Demanem al board que aturi el comportament físic del Tile
    local desiredTile = tileMap[index];
    physics.undoObjectPhysic(desiredTile.tileGrp);
end

function board:revertPhysicsTile (index)
    --Demanem al board que torni a posar el Tile en un estat previ a iniciar el comportament físic
    local desiredTile = tileMap[index];
    desiredTile.resetTilePosition(0);
end


-- GESTIÓ DE TOUCHENABLED ALS TILES --------------------------------------------
function board:setTouchEnableToPosition (index, newEnable)
    --Volem assignar un nou TouchEnable a una posició del board
    --Obtenim el Tile corresponent i li canviem el valor del TouchEnable
    local currentTile = tileMap[index];
    local oldEnable = currentTile.isTouchEnabled;
    currentTile.setTouchEnabled(newEnable);
    
    --Si canvia l'estat del Tile, el·liminem tots els Touch Events que puguin haver començat en aquest Tile
    if oldEnable ~= newEnable then
        --Cancel·lem els events
        cancelTouchEventsFromTile(index);
    end
end

function board:setTouchEnableToAll (newEnable)
    --Volem assignar un nou ToucnEnable a totes les posicions del board
    for i = 1, numTilesInBoard do
        board:setTouchEnableToPosition(i, newEnable);
    end
end


-- ARMES ESPECIALS DE AZ !!! ---------------------------------------------------
-- FUNCIONS DE TERRATRÈMOL -----------------------------------------------------
function board:getMaxYPos()
    --Obtenim la posició Y màxima dels zombies que hi ha en pantalla
    local maxY = -10000;
    
    for i = 1, numTilesInBoard, 1 do
        local currentTile = tileMap[i];
        local currentObject = currentTile.getObjectInLayer("main");
        if currentObject ~= nil and currentObject.objType == BOARD_OBJECT_TYPES.ZOMBIE then
            --El Tile té un Zombie al seu interior
            if currentObject.isLaunched and currentTile.tileGrp.y > maxY then
                maxY = currentTile.tileGrp.y;
            end
        end
        
    end
    
    return maxY;
end

function board:startEarthquake ()
    --Comença el procés de Terratrèmol
    --Fem els ajustos o modificacions necessàries al Board
    
    --Cancel·lem tots els events de Touch que hi pugui haver actius
    --Això també el·liminarà tots els events de Touch que hi pugui haver
    board:setTouchEnableToAll(false);
    
    --Congel·lem tots els Zombies
    for i = 1, numTilesInBoard, 1 do
        --Accedim al tile de la posició i a l'objecte del seu interior
        local currentTile = tileMap[i];
        local currentObject = currentTile.getObjectInLayer("main");
        
        if currentObject ~= nil and currentObject.objType == BOARD_OBJECT_TYPES.ZOMBIE then
            --Hi ha un zombie al seu interior
            currentObject.freezeZombie(true, true);
        end
    end
end

function board:startLaunch ()
    --Consultem els zombies actuals i els fem saltar
    --Retornem una llista amb els index dels Tiles propulsats, i un factor dels zombies llençats respecte el total
    local launchedTilesIndex = {};
    for i = 1, numTilesInBoard, 1 do
        --Accedim al tile de la posició i a l'objecte del seu interior
        local currentTile = tileMap[i];
        local currentObject = currentTile.getObjectInLayer("main");
        
        if currentObject ~= nil and currentObject.objType == BOARD_OBJECT_TYPES.ZOMBIE then
            --Hi ha un zombies al seu interior
            if currentObject.launchEarthquake() then
                --El Zombie es pot llençar i s'ha actualitzat en conseqüència
                --Convertim l'objecte en físic i li apliquem una força al·leatòria
                board:startPhysicsTile (i);
                
                --Tornem a posar detecció de Touch al Tile
                board:setTouchEnableToPosition (i, true);
                
                --Acumul·lem l'index del Zombie
                table.insert(launchedTilesIndex, i);
            end
        end
    end
    
    --Preparem les dades de retorn
    local factor = 0;
    if #launchedTilesIndex > 0 then
        factor = #launchedTilesIndex / numTilesInBoard; 
    end
    return launchedTilesIndex, factor;
end

function board:finishLaunch ()
    --S'ha acabat el procés de Launch
end

function board:finishEarthquake ()
    --Acaba completament tot el procés de Earthquake
    --Fem els ajustos o modificacions necessàries al Board
    
    --Restaurem la posició inicial dels Tiles
    for i = 1, numTilesInBoard, 1 do
        board:revertPhysicsTile(i);
    end
    
    --Descongel·lem tots els zombies
    for i = 1, numTilesInBoard, 1 do
        --Accedim al tile de la posició i a l'objecte del seu interior
        local currentTile = tileMap[i];
        local currentObject = currentTile.getObjectInLayer("main");
        
        if currentObject ~= nil and currentObject.objType == BOARD_OBJECT_TYPES.ZOMBIE then
            --Hi ha un zombie al seu interior
            --Si el zombie no es troba congel·lat per un gel, el reactivem
            if not currentObject.isIceTarget then
                currentObject.freezeZombie(false, false);
            end
        end
    end
    
    --El·liminem els events que Touch que hi pugui haver actius
    board:cancelAllTouchEvents();
    
    --Tornem a activar els events de Touch
    board:setTouchEnableToAll(true);
end


-- FUNCIONS DE GAVIOT ----------------------------------------------------------
function board:startGaviot ()
    --Preparem tots els zombies per al procés de atac aeri
    --Voldrem "congelar" a tots els zombies mentre dura el procés
    
    --Cancel·lem tots els events de Touch que hi pugui haver actius
    board:setTouchEnableToAll(false);
    
    --Congel·lem tots els Zombies, i preparem la llista dels objectius vàlids per a l'atac
    local validTargets = {};
    for i = 1, numTilesInBoard, 1 do
        --Accedim al tile de la posició i a l'objecte del seu interior
        local currentTile = tileMap[i];
        local currentObject = currentTile.getObjectInLayer("main");
        
        if currentObject ~= nil and currentObject.objType == BOARD_OBJECT_TYPES.ZOMBIE then
            --Hi ha un zombie al seu interior
            --Congel·lem els zombies mentre dura el procés
            currentObject.freezeZombie(true, true);
            
            --Preparem la informació de l'objectiu si és vàlid (està en un estat vàlid i no hi ha una pedra caient a la posició)
            if currentObject.isGaviotTarget() and not wController._stone:checkIfPending(i) then
                --És un objectiu vàlid
                --Preparem la informació que retornarem
                local XinPhy, YinPhy = AZ.utils.getPosInGrp(currentTile.tileGrp, background.group);
                local currentObjectInfo = {zombie = currentObject,
                                    targetX = XinPhy,
                                    targetY = YinPhy};
       
                table.insert(validTargets, currentObjectInfo);
            end
        end
    end
    
    return validTargets;
end

function board:finishGaviot ()
    --Descongel·lem tots els zombies
    for i = 1, numTilesInBoard, 1 do
        --Accedim al tile de la posició i a l'objecte del seu interior
        local currentTile = tileMap[i];
        local currentObject = currentTile.getObjectInLayer("main");
        
        if currentObject ~= nil and currentObject.objType == BOARD_OBJECT_TYPES.ZOMBIE then
            --Hi ha un zombie al seu interior
            --El reactivem si no hi ha un gel que l'atura
            if not currentObject.isIceTarget then
                currentObject.freezeZombie(false, false);
            end
        end
    end
    
    --El·liminem els events que Touch que hi pugui haver actius
    board:cancelAllTouchEvents();
    
    --Tornem a activar els events de Touch
    board:setTouchEnableToAll(true);
end


-- FUNCIONS DE HOSE ------------------------------------------------------------
function board:getFirstLowerTileFromXPos (xPos)
    --Donat un Touch en una coordenada X, volem saber a quin tile atacarà primer la manguera, començant
    --a comptar des de la part inferior
    local fileIndexXCenterPos, auxY = AZ.utils.getPosInGrp(tileMap[1].tileGrp, background.group)
    
    --Provem tots els Tiles d'una fila
    local i = 1;
    local selectedColumn = 0;
    local limit = fileIndexXCenterPos + 0.5*tileSizeW;
    while i <= numColumns and selectedColumn == 0 do
        --Provem si la posició que hem rebut està inclosa en el marge sel·leccionat
        if xPos <= limit then
            --Ja l'hem trobat
            selectedColumn = i;
        else
            --Encara no l'hem trobat
            i = i + 1;
            limit = limit + tileSizeW;
        end
    end
    
    if selectedColumn == 0 then
        --No l'hem trobat
        --Assumim que és la columna de més a la dreta
        selectedColumn = numColumns;
    end
    
    return numTilesInBoard - (numColumns - selectedColumn), selectedColumn;
end

function board:getTilesInColumn (selectedColumn)
    --Donada una columna, retornem tots els index dels tiles que la formen
    local tilesInColumn = {};
    if selectedColumn > 0 and selectedColumn <= numColumns then
        --És un índex de columna vàlid
        local currentIndex = selectedColumn;
        while currentIndex <= numTilesInBoard do
            --Afegim l'índex a la llista
            table.insert(tilesInColumn, currentIndex);
            
            --Calcul·lem el següent tile
            currentIndex = currentIndex + numColumns;
        end
    end
    
    return tilesInColumn;
end

local newPropHoseAtPosition = function (index, propHose)
    --Funció interna per a crear i afegir un HOSE_PROP en una posició del taulell
    --Creem l'element a injectar
    local currentTile = tileMap[index];
    if currentTile.isOccupied then 
        --El Tile conté un element
        --El volem substituir per el nou PROP_HOSE
        board:replaceObjectForExternal(propHose, index);
        
    else
        --El Tile està buit
        --Afegim l'element directament
        insertObjectInBoardAtPositionAtLayer(propHose, index, "main");
        
        -- Actualitzem els patrons vàlids
        updatePatternMatches();
    end
end


function board:insertPropHoseAtPosition (index, propHose)
    --Volem injectar un PROP_HOSE en una posició concreta
    if not board:isIndexValid(index) then
        return false;
    end
    
    --Afegim el Prop
    newPropHoseAtPosition(index, propHose);
end

function board:getUpTile(index)
    --Donat un index de Tile, volem saber l'índex del tile que té just sobre seu, si n'hi ha
    local upIndex = 0;
    if board:isIndexValid (index) then
        --L'índex és vàlid
       upIndex = index - numColumns;
       if upIndex < 1 then
           upIndex = 0;
       end
    end
    
    return upIndex;
end

function board:finishHose (tilesList)
    --Ha finalitzat l'acció de la manguera
    --Volem netejar tota la columna, en funció del contingut dels tiles
    for i = 1, #tilesList, 1 do
        --Obtenim el Tiles concret i li posem el Touch
        local currentTile = tileMap[tilesList[i]];
        board:setTouchEnableToPosition (tilesList[i], true);
        
        --Mirem l'objecte que té a l'interior i actuem de manera adequada
        local currentObject = currentTile.getObjectInLayer("main");
        if currentObject ~= nil and currentObject.objType == BOARD_OBJECT_TYPES.PROP_HOSE then
            --Es un Objecte PROP_HOSE ficat només per a tapar l'espai
            --El treiem
            deleteFullObjectInPosition(tilesList[i]);
        end
    end
    
    -- Actualitzem els patrons vàlids
    updatePatternMatches();
end



-- LOAD ------------------------------------------------------------------------
local function assertSingleParam (param, nameParam, errorType)
    --Fem la comprovació de que el paràmetre concret existeix
    --En cas contrari, ja enviem la notificació pertinent
    if param == nil or param == "" then
        --El valor no existeix
        --Enviem l'error
        onErrorGeneric.message = "Param named "..nameParam.." undefined";
        onErrorGeneric.errorType = errorType;
        Runtime:dispatchEvent(onErrorGeneric);
        return false;
    end
    
    return true;
end

local function assertLoadParams (data, singleError)
    --Volem comprovar que els paràmetres rebuts dels JSON de nivell són vàlids i es pot inicialitzar el board
    if data == nil then return false end;
    if not assertSingleParam(data.propertiesInfo, "propertiesInfo", singleError) then return false end;
    if not assertSingleParam(data.propsInfo, "propsInfo", singleError) then return false end;
    if not assertSingleParam(data.patternsInfo, "patternsInfo", singleError) then return false end;
    
    return true;
end

local function genericTileEvent (event)
    --Funció de gestió d'events produïts per tiles
    if event.params and event.params.id then
        print("genericTileEvent - Tile ".. event.params.id ..", phase ".. event.phase)
    end
end

local loadInitialObjects = function(objectsInfo)
    --Carreguem els objectes inicials d'una partida guardada anteriorment
    for i = 1, #objectsInfo, 1 do
        local currentObject = objectsInfo[i];
        
        --Per a cada objecte emmagatzemat al JSON, creem l'objecte i el fiquem al Tile corresponent
        --Fem comprovacions de control 
        local intKey = currentObject.tileID;
        if board:isIndexValid(intKey) then
            --L'índex del Tile és vàlid
            local targetTile = tileMap[intKey];
            if targetTile.isOccupied == false then
                --El tile està buit
                --Intentem crear l'objecte
                local restoredObject = restoreObjectFunc(currentObject.zombieName);
                if restoredObject ~= nil then
                    --Hem pogut re-crear l'objecte assignat a aquesta posició
                    --L'afegim al board
                    insertObjectInBoardAtPositionAtLayer(restoredObject, intKey, "main");

                else 
                    --No s'ha pogut re-crear l'objecte
                    --Error de definició de JSON
                    onError.message = "Initial object in Tile "..intKey.." could not be restored";
                    Runtime:dispatchEvent(onError);
                end

            else
                --El tile ja té un objecte a dins
                --Error de definició de JSON
                onError.message = "Tile "..intKey.." was already initialized";
                Runtime:dispatchEvent(onError);
            end
        else 
            --L'índex del Tile no és vàlid
            --Error de definició de JSON
            onError.message = "Index "..intKey.." invalid";
            Runtime:dispatchEvent(onError);
        end
    end
    
    --Un cop carregats, fem l'ajust de tamany per a que els PROPS que hi hagi sobresurtin del tile
    scaleProps();
end

local getProbabilitiesTable = function ()
    --A partir del diccionari amb la informació dels Tiles disponibles per omplir amb Props, retornem la taula de probabilitats
    local probTable = {};
    
    --Definim les funcions internes de la taula de probabilitats
    probTable.getDistFromProb = function(probValue)
        --Donat un valor, indiquem a quin nivell dins de allTilesInfo cal anar a buscar el Tile
        local found = false;
        local index = 1;
        local distFound = nil;
        while index <= #(probTable.data) and not found do
            --Obtenim la següent entrada de la taula
            local currentEntry = probTable.data[index];
            if probValue <= currentEntry.prob then
                --Ja l'hem trobat
                distFound = currentEntry.level;
                found = true;
            else
                --Encara no l'hem trobat
                index = index + 1;
            end
        end
        
        --Retornem la Key del cercle on cal omplir un Tile
        return distFound;
    end
    
    probTable.getRandomTile = function(allTilesInfo)
        --Obtenim un Tile d'entre tota la llista de Tiles possibles actualment
        local rndTileDist = probTable.getDistFromProb(math.random());
        local arrayDist = allTilesInfo[rndTileDist];
        local indexInDist = math.random(1, #arrayDist);
        local rndTileInfo = arrayDist[indexInDist];
        
        --Si no és null, el treiem de la llista de disponibles
        --Si la llista d'aquest nivell es queda buida, el·liminem el nivell i actualitzem les probabilitats
        if rndTileInfo ~= nil then
            --El treiem de la llista
            table.remove(allTilesInfo[rndTileDist], indexInDist);
            
            --Si la llista ha quedat buida ja no hi ha més Tiles en aquesta distància
            --Cal recalcul·lar les probabilitats
            if #allTilesInfo[rndTileDist] == 0 then
                --No en queden més
                allTilesInfo[rndTileDist] = nil;
                probTable.updateInfo(allTilesInfo);
            end
        end
        
        return rndTileInfo;
    end
    
    probTable.updateInfo = function(allTilesInfo)
        --Actualitzem les dades de probabilitats amb l'estat actual de la llista de Tiles
        --Obtenim el número de nivells que hi ha actualment amb Tiles
        probTable.data = {};
        local numLevels = 0;
        local mathIndex = 1;
        local mathProg = 0;
        for key, value in pairs(allTilesInfo) do
            if value ~= nil and #value > 0 then
                --Per a cada entrada de la llista de Tiles afegim una entrada a la taula de probabilitats
                local currentEntry = {level = key, prob = 0};
                table.insert(probTable.data, currentEntry);

                --Augmentem el número de nivells
                numLevels = numLevels + 1;
                
                --Actualitzem el càlcul que estem fent de la progressió matemàtica de probabilitats
                mathProg = mathProg + math.pow(kDENOMINATOR_IN_PROP_SPAWN_SEQ, mathIndex - 1);
                mathIndex = mathIndex + 1;
            end
        end
        
        --Ara que ja sabem el número de nivells, podem calcul·lar les probabilitats de cada nivell
        local initialProb = math.pow(kDENOMINATOR_IN_PROP_SPAWN_SEQ, numLevels - 1) / mathProg;
        local lastProb = 0;
        
        --Tornem a recòrrer la taula de probabilitats actualitzant el valor numèric
        for i = 1, #probTable.data, 1 do
            --Obtenim l'entrada concreta i assignem la seva probabilitat
            --Es calcula com l'acumulat de les probabilitats dels nivell anteriors més la meitat de la probabilitat del nivell anterior
            local currentEntry = probTable.data[i];
            local currentProb = lastProb + (initialProb / math.pow(kDENOMINATOR_IN_PROP_SPAWN_SEQ, i - 1));
            currentEntry.prob = currentProb;
            lastProb = currentProb;
        end
        
        --print("Hem actualitzat la taula de probabilitats i hi ha ", #probTable.data, " nivells")
    end
    
    return probTable;
end

local loadInitialProps = function(propsInfo, propsStageInfo)
    --Carreguem una distribució inicial de PROPS
    --Obtenim les dades de Props del nivell
    local propsOccupacy = propsInfo.propOccupacy;
    local prop1x1ProbMin = propsInfo.prop1x1ProbMin;
    local prop1x1ProbMax = propsInfo.prop1x1ProbMax;
    local reservedTiles = propsInfo.propReserved;
    
    --Preparem el diccionari de posicions reservades
    local reservedTilesDict = {};
    for i = 1, #reservedTiles, 1 do
        reservedTilesDict[reservedTiles[i]] = true;
    end
    
    --Preparem la probabilitat de carregar un PROP segons la distància als extrems
    --Accedim a cada Tile i en preparem la informació
    local allTilesInfo = {};
    local maxDistToEdge = 0;
    for i = 1, numTilesInBoard, 1 do
        --Mirem que no sigui un Tile reservat. Si no és, no ens interessa
        if reservedTilesDict[i] == nil then
            --Calcul·lem la distancia respecte els extrems. Mirem les 4 direccions i ens quedem amb la més curta
            local currentTile = tileMap[i];

            --Busquem si és Left / Right, i la distància
            local distToLeft = currentTile.posInBoard.x;
            local distToRight = numColumns - (currentTile.posInBoard.x - 1);
            local distToEdgeX = math.min(distToLeft, distToRight);
            local isLeft = distToEdgeX == distToLeft;
            local isCentralX = distToLeft == distToRight;

            --Busquem si és Up / Down, i la distància
            local distToUp = currentTile.posInBoard.y;
            local distToDown = numRows - (currentTile.posInBoard.y - 1);
            local distToEdgeY = math.min(distToUp, distToDown);
            local isUp = distToEdgeY == distToUp;
            local isCentralY = distToUp == distToDown;

            --Busquem en quina direcció hi ha menys distància, i control·lem el cas dels Tiles centrals
            local distToEdge = math.min(distToEdgeX, distToEdgeY);
            local nearestX = distToEdge == distToEdgeX;
            local isCentral = (nearestX and isCentralX) or (not nearestX and isCentralY); 
            local isCorner = not isCentral and (distToEdgeX == distToEdgeY);

            --Amb les dades anteriors, generem el tipus de Prop que carregaríem
            local kind = "prop1x1";
            if not isCentral then
                --No és un Tile de fila o columna central. Forma part d'un cercle
                local nameX = "l";
                if not isLeft then nameX = "r"; end
                local nameY = "u";
                if not isUp then nameY = "d"; end

                if isCorner then
                    --És una peça d'un borde
                    kind = nameX..nameY;
                else
                    --No és un borde
                    if nearestX then
                        kind = nameX;
                    else
                        kind = nameY;
                    end
                end
            end

            --Si tenim un nou valor de distància màxima, actualitzem el valor
            if kind ~= "prop1x1" and distToEdge > maxDistToEdge then
                maxDistToEdge = distToEdge;
            end

            --Preparem el diccionari amb la informació del Tile i l'afegim a la llista que correspon
            local currentTileInfo = {index = i,
                                    kind = kind,
                                    };
            if allTilesInfo[distToEdge] == nil then
                allTilesInfo[distToEdge] = {};
            end
            table.insert(allTilesInfo[distToEdge], currentTileInfo);   
        end
    end
    
    --Preparem la informació per a tractar amb les probabilitats per cercle
    local probabilitiesTable = getProbabilitiesTable();
    probabilitiesTable.updateInfo(allTilesInfo);
    
    --Anem omplint de props el Board fins que arribem a la ocupació desitjada
    local occupacyPerTile = 1 / numTilesInBoard;
    local currentOccupacy = 0;
    local tilesWithProps = math.min(math.floor(numTilesInBoard * propsOccupacy), numTilesInBoard - #reservedTiles); 
    prop1x1ProbMax = math.max(prop1x1ProbMin, prop1x1ProbMax);
    local tilesWith1x1 = math.random(math.floor(tilesWithProps * prop1x1ProbMin), math.floor(tilesWithProps * prop1x1ProbMax));
    local tilesWithWall = tilesWithProps - tilesWith1x1;
    
    --Preparem l'SpriteSheet
    local _atlas = propsStageInfo.spriteSheetAtlas
    local propsSS = graphics.newImageSheet(propsStageInfo.spriteSheetPath, _atlas.sheet);
        
    --Omplim els Props de murs
    while tilesWithWall > 0 do
        --Generem un númerò al·leatori per decidir a quin cercle posem un prop
        local randomTileInfo = probabilitiesTable.getRandomTile(allTilesInfo);
        if randomTileInfo ~= nil then
            --Omplim el Tile amb la informació del Prop que li correspòn
            --Permetem un % de possibilitats de que s'hi posi un prop1x1 enlloc del que li correspòn per cercles
            local currentIndex = randomTileInfo.index;
            local currentKind = randomTileInfo.kind;
            
            --Preparem la ruta de la imatge
            local propSS_index;
            local isFence;
            if currentKind == "prop1x1" then
                propSS_index = math.random(#_atlas.sheet.frames -8)
                isFence = false;
            else
                propSS_index = _atlas.frameIndex["prop_"..currentKind];
                isFence = true;
            end
            
            --Creem l'objecte, el settejem i el fiquem al Board
            local newProp = propController:create(propsSS, propSS_index, currentIndex);
            newProp.isFence = isFence;
            insertObjectInBoardAtPositionAtLayer(newProp, currentIndex, "main");
            
            --Actualitzem la ocupació actual
            tilesWithWall = tilesWithWall - 1;
            currentOccupacy = currentOccupacy + occupacyPerTile;
            
        else
            --No queden tiles disponibles
            break;
        end
    end
    
    --Omplim els Props de 1x1
    while tilesWith1x1 > 0 do
        --Escollim un tile aleatori d'entre tots els que queden
        --NO POT SER UNA POSICIÓ RESERVADA
        local currentIndex = board:getAnyEmptyTile();
        if reservedTilesDict[currentIndex] == nil then
            --Preparem la ruta de la imatge
            local propSS_index = math.random(#_atlas.sheet.frames -8)

            --Creem l'objecte, el settejem i el fiquem al Board
            local newProp = propController:create(propsSS, propSS_index, currentIndex);
            newProp.isFence = false;
            insertObjectInBoardAtPositionAtLayer(newProp, currentIndex, "main");

            --Actualitzem la ocupació actual
            tilesWith1x1 = tilesWith1x1 - 1;
            currentOccupacy = currentOccupacy + occupacyPerTile;
        end
    end
    
    --Un cop carregats, fem l'ajust de tamany per a que els PROPS sobresurtin del tile
    scaleProps(propsStageInfo.spriteFencesScale);
    
    --Tornem a posar tots els Tiles en el Z-index correcte
    for i = 1, #tileMap do
        tileMap[i].tileGrp:toFront();
    end
end

function board:load(boardData, propsStageInfo)
    --Hem pogut carregar correctament la informació del nivell
    --Fem la comprovació de que tenim tots els paràmetres necessaris
    local successAssertParams = assertLoadParams(boardData, "board loading error");
    if not successAssertParams then
        --Els paràmetres no són vàlids
        --No podem efectuar la càrrega del nivell
        return false;
    end

    --Inicialitzem les estructures
    tileMap = {};
    freeTilesMap = {};

    --Ara cal inicialitzar tots els atributs del board amb la informació obtinguda
    local propertiesInfo = boardData.propertiesInfo;
    numRows = propertiesInfo.H;
    numColumns = propertiesInfo.W;
    numTilesInBoard = numRows*numColumns;
    CenterPercX = propertiesInfo.centerPercX;
    CenterPercY = propertiesInfo.centerPercY;
    TileSizePercFromWidth = propertiesInfo.tileSizeFromTotalWidth;

    --Obtenim les dades necessàries per a fer la inicialització
    local screenWidth = display.contentWidth;
    local screenHeight = display.contentHeight;
    local boardCenterX = screenWidth * CenterPercX;
    local boardCenterY = screenHeight * CenterPercY;
    local boardTileSize = screenWidth * TileSizePercFromWidth;

    --Preparem la gestió d'events
    Runtime:addEventListener(touchInTileEventName, touchEventInTile);
    Runtime:addEventListener(genericTileEventName, genericTileEvent);

    --Carreguem i inicialitzem la classe Tile
    local tileModule = require "test_tile";
    local adjustment = 0;
    tileSizeW = boardTileSize + adjustment;
    tileSizeH = boardTileSize + adjustment;
    tileModule.initialize({onTileTouched = touchInTileEventName, 
                            onDestroySuccessTile = genericTileEventName, 
                            onDestroyTile = onDestroyTileEvent,
                            onPauseTile = pauseEventName,
                            onIdChange = updateTileEvent,
                            onDrag = onDragEvent,
                            onFinishObject = finishObjectEventName,
                            w = tileSizeW,
                            h = tileSizeH,     
                            parentGroup = board.group});

    --Creem els tiles individuals
    for y = 1, numRows, 1 do
        for i = 1, numColumns, 1 do
            --Creem el tile concret
            --Agafem l'origen del Tile en el centre
            local currentTileIndex = ((y - 1) * numColumns) + i;
            local newOriginX = (i - 1)*boardTileSize + boardTileSize*0.5;
            local newOriginY = (y - 1)*boardTileSize + boardTileSize*0.5;

            local newTile = tileModule.createTile({x = newOriginX,
                                                y = newOriginY,
                                                boardX = i,
                                                boardY = y,
                                                id = currentTileIndex});

            --Si el Tile s'ha pogut crear, fem la gestió de les dades i estructures internes
            if newTile ~= nil then
                --El Tile s'ha pogut crear satisfactoriament
                --Afegim el tile a les llistes de gestió interna, i a la llista de Tiles disponibles
                table.insert(tileMap, currentTileIndex, newTile);
                table.insert(freeTilesMap, currentTileIndex);
            end
        end
    end

     --Preparem el grup visual
    --Cal tenir en compte que el grup ja s'ha afegit al grup del BG a l'Init
    board.group.x, board.group.y = boardCenterX - board.group.width *0.5, boardCenterY - board.group.height *0.5;
    local newX, newY = AZ.utils.getPosInGrp(board.group, background.group)
    background.group:insert(board.group)
    board.group.x, board.group.y = newX, newY

    --Posem el grup visual de físiques per sobre el Board
    physics.group:toFront();
    
    --Fem la inicialització dels objectes Prop que conté
    loadInitialProps(boardData.propsInfo, propsStageInfo);

    --Inicialització de patrons
    --Preparem l'string d'espais buits i enviem la primera notificació amb els patrons disponibles
    local patternsInfo = boardData.patternsInfo;
    patternsInCurrentLevel_Regular = patternsInfo.regular;
    patternsInCurrentLevel_LastWave = patternsInfo.lastWave;
    --patternsAvailableInCurrentLevel = patternsInfo.regular;
    setFreeTilesString();
    updatePatternMatches();

    --Enviem una notificació per a avisar de que hem carregat un nivell amb nova informació
    Runtime:dispatchEvent({name = "newBoardLoaded", message = boardData});

    return true;  
end

function board:save()
    --Guardem el contingut del nivell actual en un fitxer json
    --TEST
    local newLevel = {};
    if jsonIO ~= nil then
        if jsonIO:writeFile("test2.json") then
            print("Write succeed!");
        end
    end
end

function board:destroy()
    
    -- Eliminem els tiles
    for i = 1, numTilesInBoard do
        tileMap[i].destroy()
    end
    
    -- Borramos el contenido del grupo de board
    display.remove(board.group)
    --background:destroy()
    
    -- Descarreguem el modul del tile
    package.loaded["test_tile"] = nil
    _G["test_tile"] = nil
    tileModule = nil
    
    -- Cancel·lem els listeners actius
    Runtime:removeEventListener(pauseEventName, pausePlayBoard);
    Runtime:removeEventListener(touchInTileEventName, touchEventInTile);
    Runtime:removeEventListener(genericTileEventName, genericTileEvent);
    
    -- Lanzamos un evento para confirmar la destrucción del objeto
    Runtime:dispatchEvent(onDestroy);
    
    board = nil
end


-- FUNCIONS PER AL INIT I DESTRUCCIÓ -------------------------------------------
local function assertInitParams (params)
    --Comprovem que hem rebut tots els paràmetres necessaris
    if params == nil then
        onErrorGeneric.message = "Params on Init undefined";
        onErrorGeneric.errorType = "Board Init Error";
        Runtime:dispatchEvent(onErrorGeneric);
        return false 
    end;
    if not assertSingleParam(params.onErrorBoard, "onErrorBoard", "Board Init Error") then return false end;
    if not assertSingleParam(params.onDestroyBoard, "onDestroyBoard", "Board Init Error") then return false end;
    if not assertSingleParam(params.onInitializedBoard, "onInitializedBoard", "Board Init Error") then return false end;
    --if not assertSingleParam(params.restoreFunc, "restoreFunc", "Board Init Error") then return false end;
    if not assertSingleParam(params.touchEventFunc, "touchEventFunc", "Board Init Error") then return false end;
    if not assertSingleParam(params.updateVacancyFunc, "updateVacancyFunc", "Board Init Error") then return false end;
    if not assertSingleParam(params.enterPauseEvent, "enterPauseEvent", "Board Init Error") then return false end;
    if not assertSingleParam(params.updateObjectEvent, "updateObjectEvent", "Board Init Error") then return false end;
    if not assertSingleParam(params.finishObjectEvent, "finishObjectEvent", "Board Init Error") then return false end;
    if not assertSingleParam(params.onDestroyTile, "onDestroyTile", "Board Init Error") then return false end;
        --if not assertSingleParam(params.physicsControllerObject, "physicsControllerObject", "Board Init Error") then return false end;
      
    return true;
end

function board:init ( params )
    --Fem la comprovació de que tots els paràmetres són correctes
    if assertInitParams(params, onErrorGeneric) then
        --Els paràmetres són correctes
        --Fem l'assignació
        onError.name = params.onErrorBoard;
        onDestroy.name = params.onDestroyBoard;
        onInitialized.name = params.onInitializedBoard;
        restoreObjectFunc = params.createObjFunc;--restoreFunc;
        onTouchEvent.name = params.touchEventFunc;
        onVacancyChanged.name = params.updateVacancyFunc;
        physics = params.physicsControllerObject;
        background = params.backgroundControllerObject;
        wController = params.wController;
        propController = params.propControllerObject;
        pauseEventName = params.enterPauseEvent
        onDestroyTileEvent = params.onDestroyTile
        
        --Afegim els listeners necessaris
        Runtime:addEventListener(pauseEventName, pausePlayBoard);
        
        --Inicialitzem el comptador de touches
        touchDictInfo = {};
        board.numTouchesActive = 0;
        
        --Inicialitzem els atributs
        tileMap = {};
        freeTilesMap = {};
        numTilesInBoard = 0;
        
        --Guardem el nom de l'event per a quan calgui actualitzar els objectes
        updateTileEvent = params.updateObjectEvent;
        onDragEvent = params.onTileDragEvent or "";
        finishObjectEventName = params.finishObjectEvent;
        
        --Inicialitzem el grup visual
        board.group = display.newGroup();
   
        --Inicialitzem una (possible) funció de duplicació d'objectes per al Tile
        duplicateFunc = params.createObjFunc;
        
        --S'ha pogut fer tota la inicialització
        Runtime:dispatchEvent(onInitialized)
        
        return true;
        
    else
        return false;
    end    
end

return board