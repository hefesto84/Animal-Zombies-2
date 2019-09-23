-- Objete principal que es retorna
local earthquake = {}

-- Atributs de la classe
local board = nil;
local physics = nil;
local background = nil;

-- Variables de gestió
earthquake.isEarthquakeOn = false;
local isLaunchOn = false;
local isPaused = false;
local launchedZombies = {};
local launchedZombiesPendingToKill = 0;
local initialLaunchGroupY = 0;
local prelauchTimer = nil
local launchTimer  = nil
local gravityTimer = nil
local finishTimer = nil

-- Constants
local LERP_TIME_VALUE           = 0.4;
local POS_LOWER_ZOMBIE_PERC     = 0.75;
local PRELAUNCH_TIME_VALUE      = 200;
local RETURN_TIME_VALUE         = 3000;
local SHAKE_FRAMES              = 30;
local GRAVITY_PERC              = 0.7;

-- Valors precalculats
local maxYInScreen = display.contentHeight * POS_LOWER_ZOMBIE_PERC;

-- Events als que cridar
local killZombieEventName = "";


-- FUNCIONS PRIVADES -----------------------------------------------------------
local finishEarthquake = function (event)
    --Considerem que tots els Tiles han tornat a la posició correcta
    --Donem per finalitzat el procés de Earthquake
    if finishTimer ~= nil then finishTimer = nil; end
    
    --Actualitzem l'estat del mòdul
    earthquake.isEarthquakeOn = false;
    
    --Enviem la notificació al GamePlay per a informar de que ha acabat el Earthquake
    Runtime:dispatchEvent({ name = GAMEPLAY_EARTHQUAKE_FINISH_EARTHQUAKE_EVNAME });
end

local finishReturn = function (event)
    --El moviment de rebot ha finalitzat i tornem a estar centrats
    --Recuperem tots els Tiles i els posem a la posició original
    board:finishEarthquake();
    
    --Reiniciem la posició del grup físic
    physics.group.y = initialLaunchGroupY;
    
    --Passat un temps per al retorn dels Tiles, donem per finalitzat el procés
    finishTimer = timer.performWithDelay(100, finishEarthquake);
end

local finishLaunch = function (event)
    --Matem a tots els Zombies que han sigut llençats i que encara puguin quedar vius
    --Indiquem que ha acabat el Launch
    isLaunchOn = false;
    
    --Cancel·lem els timers i demanem de matar a tots els zombies que puguin quedar
    if launchTimer ~= nil then 
        timer.cancel(launchTimer);
        launchTimer = nil;
    end
    if gravityTimer ~= nil then
        timer.cancel(gravityTimer);
        gravityTimer = nil
    end
    board:sendEventToAllMain(killZombieEventName);
    
    --Desactivem la gravetat, per si estava activada
    physics.deactivateGravity();
    
    --Iniciem la transició cap a l'origen
    background.returnDespl(RETURN_TIME_VALUE, finishReturn);
end

local activateGravity = function()
    --Activem la gravetat del sistema de físiques per acumular tots els objectes en la meitat inferior de l'espai físic
    physics.activateGravity();
end

local startLaunch = function (event)
    --Iniciem el llençament físic dels Zombies
    --Demanem al Board quins zombies es poden llençar i els impulsem
    local zombiesLaunchedFactor;
    launchedZombies, zombiesLaunchedFactor = board:startLaunch();
    launchedZombiesPendingToKill = #launchedZombies;
    
    --Control·lem si hi ha zombies llençats
    if launchedZombiesPendingToKill > 0 then
        --Hem llençat zombies
        isLaunchOn = true;
        
        --Guardem la posició inicial del grup físic
        initialLaunchGroupY = physics.group.y;
        
        --Iniciem el moviement del BG
        --Posem un timer per a indicar que ha acabat el Launch
        local fullTimeNeeded = background.initDespl(1)--zombiesLaunchedFactor);
        launchTimer = timer.performWithDelay(fullTimeNeeded, finishLaunch);
        gravityTimer = timer.performWithDelay(fullTimeNeeded * GRAVITY_PERC, activateGravity)
        
    else
        --No hi havia zombies que llençar
        finishReturn();
    end 
end

local finishShake = function (event)
    --Ha acabat el procés de Shake
    --Passat un temps, iniciem el procés de Launch
    prelauchTimer = timer.performWithDelay(PRELAUNCH_TIME_VALUE, startLaunch);
end


-- FUNCIONS PÚBLIQUES ----------------------------------------------------------
function earthquake:startEarthquake ()
    --Se'ns demana de començar el terratrèmol
    --Si estem en un estat vàlid, iniciem el procés
    if earthquake.isEarthquakeOn == false then
        --Estem en un estat vàlid
        earthquake.isEarthquakeOn = true;
        prelauchTimer = nil;
        launchTimer  = nil;
        gravityTimer = nil;
        finishTimer = nil;
        
        --Enviem la notificació de que comença el terratrèmol, per a preparar la resta de mòduls
        Runtime:dispatchEvent({ name = GAMEPLAY_EARTHQUAKE_START_EARTHQUAKE_EVNAME });
        
        --Iniciem el terratrèmol al Board 
        board:startEarthquake();
        
        --Fem que tremoli el joc
        AZ.utils.vibrate();
    
        --Iniciem el Shake físic
        physics.initShake(background.group, SHAKE_FRAMES, finishShake);
        
        return true;
    else 
        return false;
    end
end

function earthquake:enterPause()
    --Entrem en mode Pause
    isPaused = true;
    
    --Aturem els timers
    if prelauchTimer ~= nil then timer.pause(prelauchTimer); end
    if launchTimer ~= nil then timer.pause(launchTimer); end
    if gravityTimer ~= nil then timer.pause(gravityTimer); end
    if finishTimer ~= nil then timer.pause(finishTimer); end
    
    --Aturem el BG
    background.pauseEarthquake(true);
end

function earthquake:exitPause()
    --Sortim del mode Pause
    isPaused = false;
    
    --Reactivem els timers
    if prelauchTimer ~= nil then timer.resume(prelauchTimer); end
    if launchTimer ~= nil then timer.resume(launchTimer); end
    if gravityTimer ~= nil then timer.resume(gravityTimer); end
    if finishTimer ~= nil then timer.resume(finishTimer); end
    
    --Reactivem el BG
    background.pauseEarthquake(false);
end


-- CAPTURA DE ENTERFRAME -------------------------------------------------------
local updateLaunchZombiesView = function (event)
    --A cada frame volem actualitzar la posició del grup de zombies llençats
    if isLaunchOn and not isPaused then
        --Calcul·lem l'alçada del zombie més baix
        local maxYZombie = board:getMaxYPos();

        --Volem desplaçar el grup sencer de zombies per a garantir que es pugui visualitzar perfectament el zombie más baix 
        local newY = maxYInScreen - maxYZombie;
        local currentY = physics.group.y;

        --Iniciem la transició
        local lerpYValue = (1 - LERP_TIME_VALUE)*currentY + LERP_TIME_VALUE*newY;
        physics.group.y = lerpYValue;
    end
    
    --Actualitzem el BG en funció de l'estat actual
    --Assumint que el grup de launch (physics.group) comença a alçada 0, la seva
    --coordenada Y indica quin DeltaY cal desplaçar el BG
    background.update(isLaunchOn and not isPaused, physics.group.y);
    
    return true;
end


-- CAPTURA DE LAUNCHED ZOMBIE KILLED -------------------------------------------
function earthquake:newZombieDead (indexTile)
    --Ha mort un animal que estava llençat
    --Apliquem tots els canvis necessaris en el zombie
    board:stopPhysicsTile(indexTile);
        
    --Control·lem si tots els zombies de Launch estan morts
    if isLaunchOn == true then
        --Ha mort un animal propulsat
        launchedZombiesPendingToKill = math.max(0, launchedZombiesPendingToKill - 1);
        if launchedZombiesPendingToKill == 0 then
            --Acaba de morir l'últim zombie
            --Acaba tot el procés
            finishLaunch();
        end
    else
        --El zombie ha mort com a conseqüència del final del Launch
        --No cal fer res especial
    end
end


-- INICIALITZACIÓ I DESTRUCCIÓ -------------------------------------------------
local function assertInitParams (params)
    --Comprovem que hem rebut tots els paràmetres necessaris
    local msg = "Tried to initialize the Earthquake module without ";
    AZ:assertParam(params, "Earthquake Init Error", msg .."params");
    AZ:assertParam(params.board, "Earthquake Init Error", msg .."'params.board'");
    AZ:assertParam(params.background, "Earthquake Init Error", msg .."'params.background'");
    AZ:assertParam(params.killZombieEvent, "Earthquake Init Error", msg .."'params.killZombieEvent'");
end

function earthquake:init ( params )
    --Fem la comprovació de que tots els paràmetres són correctes
    assertInitParams(params);
    
    --Si hem arribat fins aquí és perquè tots els paràmetres són correctes
    board = params.board;
    physics = params.physics;
    background = params.background;
    killZombieEventName = params.killZombieEvent;
    
    --Preparem la captura d'events
    Runtime:addEventListener("enterFrame", updateLaunchZombiesView);
end

-- Destruïm el módulo
function earthquake:destroy ()
    --Se'ns demana destruïr el mòdul
    if launchTimer ~= nil then
        timer.cancel(launchTimer);
        launchTimer = nil;
    end
    if gravityTimer ~= nil then
        timer.cancel(gravityTimer);
        gravityTimer = nil
    end
    
    Runtime:removeEventListener("enterFrame", updateLaunchZombiesView);
    
    earthquake = nil;
end

-- Retornem l'objecte principal
return earthquake;