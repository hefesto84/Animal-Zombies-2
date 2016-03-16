-- objecte que retornem
local wController = {}

-- requires d'armes
wController._shovel = nil
wController._rake = nil
wController._stone = nil
wController._trap = nil
wController._iceCube = nil
wController._earthquake = nil
wController._hose = nil
wController._thunder = nil
wController._stinkBomb = nil
wController._gaviot = nil
wController._container = nil

-- altres requires necessaris
wController._ui = nil
wController._board = nil
wController._scene = nil

-- Informació dels SS
local _atlas    = nil;
local weaponsSS = nil;

-- variables
wController.currentWeapon = nil


-- FUNCIONS DE CONSULTA --------------------------------------------------------
function wController:getCurrentWeapon()
	return wController.currentWeapon
end

local function isUsingWeapon(w)
    return w == wController.currentWeapon
end

function wController:isWeaponBlockingSpawn()
    --Retornem si actualment hi ha una arma que estigui bloquejant el sistema d'spawneig
    return wController._earthquake.isEarthquakeOn or wController._gaviot.isGaviotOn;
end

local function resetWeapon()
    wController:changeWeapon(SHOVEL_NAME)
end

function wController:isDirectWeapon(wName)
    return wName == GAVIOT_NAME or wName == EARTHQUAKE_NAME
end

function wController:changeWeapon(weaponName)
    
    local isDirectWeapon = nil
    
    -- assignem una arma nova si no l'estem utilitzant ja
    if wController.currentWeapon ~= weaponName then
        -- cancel·lem tots els events de Touch que hi pogués haver actius
        wController._board:cancelAllTouchEvents()
        
        -- Comprovem si es tracta d'una arma d'activació directa
        isDirectWeapon = wController:isDirectWeapon(weaponName)
        
        if isDirectWeapon then
            --Disparem l'arma directament (si es pot)
            local wProp1Active = wController._earthquake.isEarthquakeOn or wController._gaviot.isGaviotOn;
            local weaponConditionsOK = not wProp1Active;
            if weaponConditionsOK then
                if weaponName == GAVIOT_NAME then
                    wController._gaviot:startGaviot();
                    wController._ui.enableDisableWeaponButtons("all", false)
                elseif weaponName == EARTHQUAKE_NAME then 
                    wController._earthquake:startEarthquake();
                    wController._ui.enableDisableWeaponButtons({ STONE_NAME, TRAP_NAME, ICE_CUBE_NAME, EARTHQUAKE_NAME, HOSE_NAME, STINK_BOMB_NAME, GAVIOT_NAME, LIFE_BOX_NAME, DEATH_BOX_NAME }, false)
                end
                
                wController._ui.updateWeaponQuantity(weaponName)
                
                if weaponName == EARTHQUAKE_NAME then
                    resetWeapon()
                end
            end
            
        else 
            --Cancelem qualsevol possible arma previa
            Runtime:dispatchEvent({ name = GAMEPLAY_WEAPON_CANCEL_EVNAME })

            --Assignem la nova arma escollida
            wController.currentWeapon = weaponName;
            wController._ui.setCurrentWeapon(wController.currentWeapon)
        end
        
        -- enviem un event conforme hem canviat o seleccionat l'arma
        Runtime:dispatchEvent({ name = GAMEPLAY_WEAPON_CHANGED_EVNAME, newWeapon = weaponName })
    end
    
    return not isDirectWeapon or false
end

function wController:isInTip()
	return wController._scene.isInTip
end

-- GESTIÓ DE TOUCH -------------------------------------------------------------
function wController:handleBeganPhase(event)
    --Comença un event de Touch
    --En funció de l'arma sel·leccionada prenem unes accions o unes altres
    
    --Obtenim la informació de l'event
    local touchID = event.id;
    local touchX = event.x
    local touchY = event.y
    local touchTileID = event.path[1]
    local touchObject = wController._board:getObjectAtPosition(touchTileID);
    
    --Preparem variables de control
    local wProp1Active = wController._earthquake.isEarthquakeOn or wController._gaviot.isGaviotOn;
    
	if isUsingWeapon(SHOVEL_NAME) then
		-- si no tenim municio de pala, cancelem touch
		if wController._ui.getWeaponQuantity(SHOVEL_NAME) < 1 then
			wController._board:cancelTouchEvent(touchID)
		end
		
    elseif isUsingWeapon(RAKE_NAME) then
        -- comencem a utilitzar el rastrell
        wController._rake:startRake(touchObject, touchX, touchY, touchTileID, touchID);
    
    elseif isUsingWeapon(THUNDER_NAME) then
        -- comencem a utilitzarl el raig
        wController._thunder:startThunder(touchObject, touchX, touchY) 
        
    elseif isUsingWeapon(TRAP_NAME) then
        --Comencem a utilitzar la trampa
        --Si estem dins el Board voldrem mostrar la imatge de la trampa indicant on anirà a parar
        wController._trap:updateTempTouch(touchID, touchTileID, not wProp1Active, touchX, touchY);
    end
end

function wController:handleMovedPhase(event)
    
    --Obtenim la informació de l'event
    local touchID = event.id;
    local touchPath = event.path
    local elapsedTime = event.timeElapse
    local touchX = event.x
    local touchY = event.y
    local firstTileID = touchPath[1]
    local lastTileID = touchPath[#touchPath]
    local initialObject = wController._board:getObjectAtPosition(firstTileID)
    local finalObject = wController._board:getObjectAtPosition(lastTileID)
    
    --Preparem variables de control
    local wProp1Active = wController._earthquake.isEarthquakeOn or wController._gaviot.isGaviotOn;
    
    if isUsingWeapon(SHOVEL_NAME) then
        --Tenim la pala seleccionada. Tractem el cas de desplaçar
        --Només es pot fer en cas de que existeixi una arma plantada que permeti arrossegar-hi Zombies (i no es pot fer si hi ha un terratrèmol o un gaviot actius)
        local anyDragWeaponActive = wController._trap.numTrapsActive > 0 or #wController._container.array > 0;
        local dragBloqued = not anyDragWeaponActive or wProp1Active;
        wController._shovel:updateObject(touchPath, touchX, touchY, dragBloqued, touchID);
    
    elseif isUsingWeapon(RAKE_NAME) then
        if event.justChangeTile then
            wController._rake:changeTarget(finalObject, lastTileID)
        end
        wController._rake:updatePosition(touchX, touchY)
		
    elseif isUsingWeapon(THUNDER_NAME) then
        -- si hem canviat de tile, avisem al raig que canvii de target
        if event.justChangeTile then
            wController._thunder:changeTarget(finalObject, true)
        end
        wController._thunder:updatePosition(touchX, touchY)
        
    elseif isUsingWeapon(TRAP_NAME) then
        --Fem els ajustos necessaris per al cas de moure una trampa temporal
        wController._trap:updateTempTouch(touchID, lastTileID, not wProp1Active, touchX, touchY);
    end
end

function wController:handleEndedPhase(event)
    
    --Obtenim la informació de l'event
    local touchID = event.id;
    local touchPath = event.path
    local elapsedTime = event.timeElapsed
    local touchX = event.x
    local touchY = event.y
    local firstTileID = touchPath[1]
    local lastTileID = touchPath[#touchPath]
    local initialObject = wController._board:getObjectAtPosition(firstTileID)
    local finalObject = wController._board:getObjectAtPosition(lastTileID)
    local wName = ""
    
    --Preparem variables de control
    local wProp1Active = wController._earthquake.isEarthquakeOn or wController._gaviot.isGaviotOn;
    local timeElapsedValid = elapsedTime <= INGAME_MAX_TIME_TO_KILL;
    local notMoved = #touchPath == 1;
    
    if isUsingWeapon(SHOVEL_NAME) then
        -- Calcul·lem l'acció que cal prendre
        local anyDragWeaponActive = wController._trap.numTrapsActive > 0 or #wController._container.array > 0;
        local dragBloqued = not anyDragWeaponActive or wProp1Active;
        
		if wController._shovel:endTouch(touchPath, elapsedTime, dragBloqued) then
			wController:weaponEnd()
        end
		
    elseif isUsingWeapon(RAKE_NAME) then
        -- eliminem l'slash
        wController._rake:endRake();
        
        wController:weaponEnd()
		
    elseif isUsingWeapon(THUNDER_NAME) then
        -- canviem de target a nil
        wController._thunder:changeTarget(nil, false)
        --wName = THUNDER_NAME
        
        wController:weaponEnd()
   
    elseif isUsingWeapon(HOSE_NAME) then
        -- Volem iniciar la manguera
        local weaponConditionsOK = not wProp1Active and 
                                    timeElapsedValid and 
                                    notMoved;
        if weaponConditionsOK then
            if wController._hose:start(touchX) then
                --resetWeapon();
				wController:weaponEnd()
            end
        end
        
     elseif isUsingWeapon(STONE_NAME) then
        -- Volem plantar una pedra o posar-la sobre un Zombie
        local weaponConditionsOK = not wProp1Active and 
                                    timeElapsedValid and 
                                    notMoved;
        if weaponConditionsOK then
            local destTileIndex = touchPath[#touchPath];
            if wController._stone:place(destTileIndex) then
                --resetWeapon();
				wController:weaponEnd()
            end
        end
        
    elseif isUsingWeapon(TRAP_NAME) then
        -- Cancel·lem la trampa temporal
        wController._trap:finishTempTouch(touchID)
        
        -- Volem plantar una trampa
        local weaponConditionsOK = not wProp1Active;
        if weaponConditionsOK then
            local destTileIndex = touchPath[#touchPath];
            if wController._trap:plant(destTileIndex) then
                --resetWeapon();
				wController:weaponEnd()
            end
        end
        
    elseif isUsingWeapon(ICE_CUBE_NAME) then
        --Volem plantar un gel
        local weaponConditionsOK = not wProp1Active and 
                                timeElapsedValid and 
                                notMoved;
        if weaponConditionsOK then
            local destTileIndex = touchPath[#touchPath];
            if wController._iceCube:place(destTileIndex) then
                --resetWeapon();
				wController:weaponEnd()
            end
        end
        
    elseif isUsingWeapon(STINK_BOMB_NAME) then
        --Llencem la bomba fètida
        local weaponConditionsOK = not wProp1Active ;
        if weaponConditionsOK then
            if wController._stinkBomb:throwBomb(lastTileID) then
                --resetWeapon()
				wController:weaponEnd()
            end
        end
        
    elseif isUsingWeapon(LIFE_BOX_NAME) then
        local weaponConditionsOK = not wProp1Active and 
                                timeElapsedValid and 
                                notMoved;
        if weaponConditionsOK then
            if wController._container:addContainer(wController._container.types.LIFE, lastTileID, wController:isInTip()) then
                --resetWeapon()
				if wController:weaponEnd() then
					resetWeapon()
				end
            end
        end
        
    elseif isUsingWeapon(DEATH_BOX_NAME) then
        local weaponConditionsOK = not wProp1Active and 
                                timeElapsedValid and 
                                notMoved;
        if weaponConditionsOK then
            if wController._container:addContainer(wController._container.types.DEATH, lastTileID, wController:isInTip()) then 
                --resetWeapon()
				if wController:weaponEnd() then
					resetWeapon()
				end
			end
        end
    end
    
    --WeaponManager:update(wName)
end

function wController:handleCancelledPhase(event)
    --S'ha cancel·lat un event de Touch
    --En funció de l'arma actual decidim com cal operar
    --En cas de cancel·lació, en principi només afecta als Touch de Shovel...
    local touchPath = event.path
    local touchID = event.id
    
    if isUsingWeapon(SHOVEL_NAME) then
        -- Calcul·lem l'acció que cal prendre
        wController._shovel:cancelTouch(touchPath);
        
    elseif isUsingWeapon(THUNDER_NAME) then
        --Donem el raig per finalitzat
        wController._thunder:endThunder();
        
    elseif isUsingWeapon(TRAP_NAME) then
        -- Cancel·lem la trampa temporal
        wController._trap:finishTempTouch(touchID)
	else
		-- ay! gordito
		wController:handleEndedPhase(event)
    end
end

function wController:weaponEnd(isForced)
	if not wController._scene.isInTip or isForced then
		
		-- restem una arma
		AZ.achievementsManager:weaponUsed(wController.currentWeapon)
		
		if wController._ui.updateWeaponQuantity(wController.currentWeapon) == 0 then
			resetWeapon()
			return false
		end 
		return true
	end
end

local function weaponEnd()
    wController:weaponEnd()
end

function wController:handleTouch(event)
	--En funció de la fase de l'event, deleguem la gestió a la funció concreta
    if event.phase == "began" then
        wController:handleBeganPhase(event)
    elseif event.phase == "moved" then
        wController:handleMovedPhase(event)
    elseif event.phase == "ended" then
        wController:handleEndedPhase(event)
    elseif event.phase == "cancelled" then
        wController:handleCancelledPhase(event)
    else
        print("phase ".. event.phase .." unknown")
    end
end


-- LISTENERS -------------------------------------------------------------------
local newZombieAppeared = function (event)
    --Un Zombie ha aparegut al Board
    --Cal comprovar si ha aparegut en una posició on hi havia un Gel esperant
    wController._iceCube:newZombieAppeared(event.boardID);
end

local newZombieEscaping = function (event)
    --Un Zombie comença a escapar
    --Si estàvem fent un Drag del Zombie, aquest Touch s'ha de cancel·lar
    wController._shovel:newZombieInvalid(event.boardID);
    
    --Si era l'objectiu d'una manguera, ja pot seguir pujant
    --La gestió de substituïr el Zombie per un PROP_HOSE ja es farà quan acabi l'animació
    wController._hose:newZombieInvalid(event.boardID);
    
end

local newZombieEscaped = function (event)
    --Un Zombie ha acabat l'animació d'escape
    local zombieIndex = event.boardID;
    
    --En funció de l'estat del zombie i de les armes implicades, prenem unes accions determinades
    if wController._hose:checkIfCovered(zombieIndex) then
        --El zombie ha mort en una columna on hi ha una manguera activa (pot haver sigut ella o una arma anterior a l'activació de la manguera)
        --Situem un PROP de manguera (PROP_HOSE) ocupant el tile
        wController._hose:replaceWithProp(zombieIndex);
    
    else
        --Treiem el Zombie del Board
        wController._board:delObjectsAtPosition(zombieIndex);
    end
end

local newZombieDying = function (event)
    --Un Zombie acaba de morir i comença l'animació de mort
    local zombieIndex = event.boardID;
    
    --Si estàvem fent un Drag del Zombie, aquest Touch s'ha de cancel·lar
    local currentZombie = wController._board:getObjectAtPosition(zombieIndex);
    if false --[[currentZombie.isTargetDrag]] then -----------------------------
        wController._shovel:newZombieInvalid(event.boardID);
    end
    
    --Avisem de que tenim un nou Zombie invàlid. Si era l'objectiu d'una manguera, ja pot seguir pujant
    --La gestió de substituïr el Zombie per un PROP_HOSE ja es farà quan acabi l'animació
    wController._hose:newZombieInvalid(zombieIndex);
    
    --Informem de que un Zombie ha mort, per a gestionar si encarra dura el terratrèmol
    wController._earthquake:newZombieDead(zombieIndex);
end

local newZombieDead = function (event)
    --Un zombie ha acabat l'animació de mort
    local zombieIndex = event.boardID;
    
    --En funció de l'estat del zombie i de les armes implicades, prenem unes accions determinades
    if wController._hose:checkIfCovered(zombieIndex) then
        --El zombie ha mort en una columna on hi ha una manguera activa (pot haver sigut ella o una arma anterior a l'activació de la manguera)
        --Situem un PROP de manguera (PROP_HOSE) ocupant el tile
        wController._hose:replaceWithProp(zombieIndex);

    elseif wController._stone:checkIfPending(zombieIndex) then
        --Avisem per a que es substitueixi el zombie per la pedra que va aquesta posició
        wController._stone:replaceWithStone(zombieIndex);

    else
        --Treiem el Zombie del board
        wController._board:delObjectsAtPosition(zombieIndex);
    end 
end

local newZombieDamaged = function (event)
    --Un zombie acaba de rebre dany
    local zombieIndex = event.boardID;
    
    --Comprovem si cal tractar el gel que pugui tenir 
    wController._iceCube:newTouchInTile(zombieIndex);
end

local newExplosion = function (event)
    --Hi ha hagut una explosió al Board
    local indexs = event.indexs;
    
    --Ice
    --Volem el·liminar tots els Gels que hi pugui haver a la zona afectada
    for i = 1, #indexs, 1 do
        wController._iceCube:newTouchInTile(indexs[i]);
    end
end

local newBoxExploding = function (event)
    --Una caixa (vida o mort) comença a explotar
    local boxIndex = event.boardID;
    
    --Hose
    --Volem notificar que si era un objectiu de manguera, aquesta ja pot seguir pujant
    wController._hose:newZombieInvalid(boxIndex);
end

local newBoxExploded = function (event)
    --Una caixa ja ha acabat d'explotar
    local boxIndex = event.boardID;
    
    if wController._hose:checkIfCovered(boxIndex) then
        --Situem un PROP de manguera (PROP_HOSE) ocupant el tile
        wController._hose:replaceWithProp(boxIndex);

    else
        --Treiem la caixa del board
        wController._board:delObjectsAtPosition(boxIndex);
		print("treiem la caixa del board")
    end
end

local newPropErased = function (event)
    --Un prop acaba d'ésser menjat
    local propIndex = event.boardID;
    
    if wController._hose:checkIfCovered(propIndex) then
        --Situem un PROP de manguera (PROP_HOSE) ocupant el tile
        wController._hose:replaceWithProp(propIndex);

    else
        --Treiem el prop del board
        wController._board:delObjectsAtPosition(propIndex);
    end
end

local newEarthquake = function (event)
    --Comença un nou terratrèmol
    --Cal que els mòduls de les armes facin l'adaptació al nou estat
    
    --Stone
    --Cancel·lem les pedres que estiguin caient o estiguin fora el board, i aturem el timer de mort de les altres
    wController._stone:cancelOutBoardStones();
    wController._stone:pauseTimerStones();
    
    --Trap
    --No cal fer res
    
    --Gel
    --Aturem els timers de vida del gel
    wController._iceCube:pauseTimerIces();

    --Hose
    --Aturem el procés de la manguera
    wController._hose:finishAllHoses();

end

local finishEarthquake = function (event)
    --Acaba un terratrèmol
    --Cal que els mòduls de les armes facin l'adaptació al nou estat
    
    --Stone
    --Reactivem els timers de les pedres que s'han congel·lat
    wController._stone:resumeTimerStones();
    
    --Gel
    --Reactivem els timers dels gels que s'han aturat
    wController._iceCube:resumeTimerIces();
    
    --Tornem a activar les armes
    wController._ui.enableDisableWeaponButtons("all", true)
end

local newGaviot = function (event)
    --Comença un nou gaviot
    --Cal que els mòduls de les armes facin l'adaptació al nou estat
    
    --Stone
    --Pausem les pedres
    wController._stone:pauseTimerStones();
    
    --Trap
    --No cal fer res
    
    --Gel
    --Aturem els timers de vida del gel
    wController._iceCube:pauseTimerIces();

    --Hose
    --Aturem el procés de la manguera
    wController._hose:finishAllHoses();
end

local finishGaviot = function (event)
    --Acaba un gaviot
    --Cal que els mòduls de les armes facin l'adaptació al nou estat
    
    --Reactivem els timers de les pedres que s'han congel·lat
    wController._stone:resumeTimerStones();
    
    --Gel
    --Reactivem els timers dels gels que s'han aturat
    wController._iceCube:resumeTimerIces();
    
    --Tornem a activar les armes
    wController._ui.enableDisableWeaponButtons("all", true)
end


-- GESTIÓ DE PAUSA -------------------------------------------------------------
local pausePlayBoard = function (event)
    --Es notifica que hi ha un canvi en l'estat de Pause
    --Cal gestionar totes les armes
    if event.isPause then
        --Entrem en Pausa
        --Shovel (RES)
        
        --Stone
        --Aturem timers i transicions
        wController._stone:enterPause();
        
        --Ice
        --Aturem els timers de vida del gel
        wController._iceCube:enterPause();
        
        --Rake (RES)
        
        --Earthquake
        --Aturem el procés
        wController._earthquake:enterPause();
        
        --Hose
        --Aturem l'acció de la manguera
        wController._hose:enterPause();
        
        --Thunder (RES)
        
        --Gaviot
        --Aturem el procés
        wController._gaviot:enterPause();
        
    else 
        --Sortim de Pausa
        --Shovel (RES)
        --No cal fer res
        
        --Stone
        --Reactivem els timers i transicions
        wController._stone:exitPause();
        
        --Ice
        --Reactivem els timers de les pedres que s'han congel·lat
        wController._iceCube:exitPause();
        
        --Rake (RES)
        
        --Earthquake
        --Aturem el procés
        wController._earthquake:exitPause();
        
        --Hose
        --Reactivem l'acció de la manguera
        wController._hose:exitPause();
        
        --Thunder (RES)
        
        --Gaviot
        --Reactivem el procés
        wController._gaviot:exitPause();
    end
    
    --Trap
    wController._trap:pause(event.isPause)
    
    --Estinc Bonv
    wController._stinkBomb:pause(event.isPause)
end



-- CREACIÓ I DESTRUCCIÓ --------------------------------------------------------
function wController:destroy()
    
    --Treiem els listeners
    Runtime:removeEventListener(GAMEPLAY_PAUSE_EVNAME, pausePlayBoard);
    
    Runtime:removeEventListener(GAMEPLAY_WEAPON_FINISH_EVNAME, weaponEnd)
    Runtime:removeEventListener(OBJECT_JUST_KILLED_EVNAME, newZombieDying)
    Runtime:removeEventListener(OBJECT_FINISH_DEAD_ANIM_EVNAME, newZombieDead);
    Runtime:removeEventListener(OBJECT_JUST_ESCAPING_ANIM_EVNAME, newZombieEscaping);
    Runtime:removeEventListener(OBJECT_FINISH_ESCAPE_ANIM_EVNAME, newZombieEscaped);
    Runtime:removeEventListener(GAMEPLAY_EARTHQUAKE_START_EARTHQUAKE_EVNAME, newEarthquake);
    Runtime:removeEventListener(GAMEPLAY_EARTHQUAKE_FINISH_EARTHQUAKE_EVNAME, finishEarthquake)
    Runtime:removeEventListener(GAMEPLAY_GAVIOT_START_EVNAME, newGaviot);
    Runtime:removeEventListener(GAMEPLAY_GAVIOT_FINISH_EVNAME, finishGaviot);
    Runtime:removeEventListener(OBJECT_FINISH_SPAWN_ANIM_EVNAME, newZombieAppeared);
    Runtime:removeEventListener(OBJECT_DAMAGED_EVNAME, newZombieDamaged);
    Runtime:removeEventListener(GAMEPLAY_EXPLOSION_EVNAME, newExplosion);
    Runtime:removeEventListener(GAMEPLAY_CONTAINER_EXPLODING_EVNAME, newBoxExploding);
    Runtime:removeEventListener(GAMEPLAY_CONTAINER_EXPLODED_EVNAME, newBoxExploded);
    Runtime:removeEventListener(OBJECT_PROP_JUST_ERASED, newPropErased);
    
    --Forcem la destrucció dels mòduls
    wController._shovel:destroy();
    wController._stone:destroy();
    wController._iceCube:destroy();
    wController._rake:destroy();
    wController._trap:destroy();
    wController._earthquake:destroy();
    wController._gaviot:destroy();
    wController._hose:destroy();
    wController._thunder:destroy();
    wController._stinkBomb:destroy();
    wController._container:destroy()
    
    --Descarreguem els mòduls
    wController._shovel = AZ:unloadModule("test_shovel")
    wController._stone = AZ:unloadModule("test_stone")
    wController._earthquake = AZ:unloadModule("test_earthquakeModule")
    wController._hose = AZ:unloadModule("test_hose");
    wController._trap = AZ:unloadModule("test_trap");
    wController._rake = AZ:unloadModule("test_rake")
    wController._thunder = AZ:unloadModule("test_thunder");
    wController._stinkBomb = AZ:unloadModule("test_stinkBomb")
    wController._iceCube = AZ:unloadModule("test_ice")
    wController._gaviot = AZ:unloadModule("test_gaviot")
    wController._container = AZ:unloadModule("test_deathLifeContainer")
    
    wController = nil
end

local function assertParams(params)
    local msg = "Tried to initialize weapon controller without "
    AZ:assertParam(params.ingameUI, "Weapon Controller Init Error", msg .."'params.ingameUI'")
    AZ:assertParam(params.board,    "Weapon Controller Init Error", msg .."'params.board'")
    AZ:assertParam(params.physics,  "Weapon Controller Init Error", msg .."'params.physics'")
    AZ:assertParam(params.bg,       "Weapon Controller Init Error", msg .."'params.bg'")
    AZ:assertParam(params.ui,       "Weapon Controller Init Error", msg .."'params.ui'")
end

function wController:init(params)
    assertParams(params)
    
    wController._ui = params.ingameUI
    wController._board = params.board
    wController._scene = params.scene
	
    --Fem els requires dels mòduls de les armes
    wController._shovel = require "test_shovel"
    wController._stone = require "test_stone"
    wController._iceCube = require "test_ice"
    wController._rake = require "test_rake"
    wController._trap = require "test_trap";
    wController._earthquake = require "test_earthquakeModule"
    wController._hose = require "test_hose"
    wController._thunder = require "test_thunder"
    wController._stinkBomb = require "test_stinkBomb"
    wController._gaviot = require "test_gaviot"
    wController._container = require "test_deathLifeContainer"
    
    --Preparem les dades SpriteSheets
    _atlas    	= require("assets.Atlas.armaOnAtlas");
    weaponsSS 	= graphics.newImageSheet("assets/new_guiSheet/armaOn.png", _atlas:getSheet());
    
    --Inicialitzem els control·ladors que ho necessitin
    wController._shovel:init ({ board = wController._board, ice = wController._iceCube, stone = wController._stone });
    wController._stone:init({ board = params.board, background = params.bg, physics = params.physics, ice = wController._iceCube, atlas = _atlas, weaponsSS = weaponsSS });
    wController._iceCube:init({ board = params.board, background = params.bg, physics = params.physics, stone = wController._stone, atlas = _atlas, weaponsSS = weaponsSS });
    wController._rake:init(params.board, wController._iceCube);
    wController._trap:init({ board = params.board, background = params.bg, ice = wController._iceCube });
    wController._earthquake:init({ board = params.board, physics = params.physics, background = params.bg, killZombieEvent = GAMEPLAY_EARTQUAKE_FINISH_LAUNCH_EVNAME })
    wController._hose:init({ board = params.board, background = params.bg, stone = wController._stone, ice = wController._iceCube, atlas = _atlas, weaponsSS = weaponsSS });
    wController._thunder:init({ bg = params.bg, board = params.board })
    wController._stinkBomb:init(params.board, params.bg)
    wController._gaviot:init({ board = params.board, physics = params.physics, background = params.bg, atlas = _atlas, weaponsSS = weaponsSS });
    wController._container:init({ board = params.board, ui = params.ui , ice = wController._iceCube, stone = wController._stone, weaponsSS = weaponsSS })
    
    --Afegim els listeners que impliquen interactuar amb les armes
    Runtime:addEventListener(GAMEPLAY_WEAPON_FINISH_EVNAME, weaponEnd)
    Runtime:addEventListener(OBJECT_JUST_KILLED_EVNAME, newZombieDying)
    Runtime:addEventListener(OBJECT_FINISH_DEAD_ANIM_EVNAME, newZombieDead);
    Runtime:addEventListener(OBJECT_JUST_ESCAPING_ANIM_EVNAME, newZombieEscaping);
    Runtime:addEventListener(OBJECT_FINISH_ESCAPE_ANIM_EVNAME, newZombieEscaped);
    Runtime:addEventListener(GAMEPLAY_EARTHQUAKE_START_EARTHQUAKE_EVNAME, newEarthquake);
    Runtime:addEventListener(GAMEPLAY_EARTHQUAKE_FINISH_EARTHQUAKE_EVNAME, finishEarthquake)
    Runtime:addEventListener(GAMEPLAY_GAVIOT_START_EVNAME, newGaviot);
    Runtime:addEventListener(GAMEPLAY_GAVIOT_FINISH_EVNAME, finishGaviot);
    Runtime:addEventListener(OBJECT_FINISH_SPAWN_ANIM_EVNAME, newZombieAppeared);
    Runtime:addEventListener(OBJECT_DAMAGED_EVNAME, newZombieDamaged);
    Runtime:addEventListener(GAMEPLAY_EXPLOSION_EVNAME, newExplosion);
    Runtime:addEventListener(GAMEPLAY_CONTAINER_EXPLODING_EVNAME, newBoxExploding);
    Runtime:addEventListener(GAMEPLAY_CONTAINER_EXPLODED_EVNAME, newBoxExploded);
    Runtime:addEventListener(OBJECT_PROP_JUST_ERASED, newPropErased);
    
    --Afegim els listeners de gestió de GamePlay
    Runtime:addEventListener(GAMEPLAY_PAUSE_EVNAME, pausePlayBoard);
end

return wController