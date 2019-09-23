-- Objecte que retornem
local hose = {}

-- Propietats internes
local currentHoses = {};
local board = nil;
local background = nil;
local ice = nil;

-- Constants
local timePerFade = 500;
local timePerTile = 250;
local timePerDamagePoint = 1000 * ( 1 / WEAP_HOSE_DAMAGE_PER_SECOND );

--SS
local _atlas        = nil;
local weaponsSS       = nil;
local namePistolInSS  = "manguera";
local animInfo        = nil;



-- FUNCIONS PUBLIQUES ----------------------------------------------------------
function hose:start (xPos)
    --Iniciem el comportament de la manguera 
    --Utilitzant la X de l'event trobem a quina columna cal atacar, i obtenim el seu centre
    local targetTileIndex, columnToKill = board:getFirstLowerTileFromXPos(xPos)
    
    --Comprovem si es pot crear
    if currentHoses[columnToKill] ~= nil then
        --Ja existeix una manguera per a la columna actual
        return false;
    end
    
    --Podem crear la manguera (escalada correctament)
    local pistol = display.newImage(weaponsSS, _atlas:getFrameIndex(namePistolInSS));
    pistol.isHoseOn = true;
    pistol.targetTileIndex = targetTileIndex;
    pistol.columnToKill = columnToKill;
    pistol.tilesToKill = {};
    pistol.tilesCovered = {};
    pistol.initHoseY = 0;
    pistol.damageTimer = nil;
    pistol.isAttacking = false;
    
    --Situem la manguera centrada en la part inferior de la pantalla
    local desiredX, desiredY = board:getTilePos(pistol.targetTileIndex);
    local tileW, tileH = board:getTileSize();
    local scaleFactorPerImgW = tileW / pistol.width;
    local scaleFactorPerImgH = tileH / pistol.height;
    pistol:scale(scaleFactorPerImgW, scaleFactorPerImgH);
    background.group:insert(pistol);
    pistol.initHoseY = desiredY + 0.5*tileH;
    pistol.x, pistol.y = desiredX, pistol.initHoseY + 0.5*pistol.contentHeight;
    
    --Fem els preparatius al board
    pistol.tilesToKill = board:getTilesInColumn (pistol.columnToKill);
    
    --Definim les funcions de cada manguera
    pistol.isIndexCovered = function (index)
        --Volem saber si la manguera està cobrint un Tile concret
        local found = false;
        local i = 1
        while i <= #pistol.tilesCovered and not found do
            found = pistol.tilesCovered[i] == index; 
            i = i + 1;
        end
        return found
    end
    
    pistol.destroy = function()
        --El·liminem l'objecte i settegem les variables de control
        --Runtime:removeEventListener(ALL_DESTROY_EVNAME, pistol.destroy);
        if pistol.lifeTimer ~= nil then timer.cancel(pistol.lifeTimer); end
        if pistol.fadeInTrans ~= nil then transition.cancel(pistol.fadeInTrans); end
        if pistol.fadeOutTrans ~= nil then transition.cancel(pistol.fadeOutTrans); end
        if pistol.fadeOutoWaterTrans ~= nil then transition.cancel(pistol.fadeOutoWaterTrans); end
        if pistol.upTransition ~= nil then transition.cancel(pistol.upTransition); end
        if pistol.damageTimer ~= nil then timer.cancel(pistol.damageTimer); end
        
        currentHoses[pistol.columnToKill] = nil;
        pistol.water:removeSelf();
        pistol.water = nil;
        pistol:removeSelf();
        pistol = nil;
    end
    
    pistol.finishDisappear = function()
        --Ha acabat tot el procés
        --Actualitzem l'estat de les posicions afectades
        board:finishHose(pistol.tilesToKill);

        --El·liminem la manguera
        pistol.destroy();
    end
    
    pistol.finishWater = function()
        --Acaba el temps d'atac
        --Fem que desaparegui l'aigua
        pistol.fadeOutoWaterTrans = transition.to (pistol.water, {time = timePerFade, alpha = 0});
        
        --Fem que desaparegui la manguera i, al acabar, que finalitzi el procés
        pistol.fadeOutTrans = transition.to (pistol, {time = timePerFade, alpha = 0, onComplete = pistol.finishDisappear});
    end
    
    pistol.tileCleared = function ()
        -- El contingut del tile ja ha sigut processat
        -- Aturem el timer de damage i considerem la posició com a coverta
        if pistol == nil then return; end
        
        pistol.isAttacking = false;
        if pistol.damageTimer ~= nil then
            timer.cancel(pistol.damageTimer);
            pistol.damageTimer = nil;
        end
        table.insert(pistol.tilesCovered, pistol.targetTileIndex);

        --Iniciem el camí cap al següent, si n'hi ha
        local nextTarget = board:getUpTile(pistol.targetTileIndex);
        if nextTarget ~= 0 then
            --Hi ha un Tile superior
            pistol.newTarget(nextTarget, timePerTile);
        end
        
    end
    
    pistol.newDamagePoint = function ()
        --El Zombie del Tile target actual rep un nou punt de mal
        --L'apliquem i gestionem si ja ha mort i podem seguir
        if pistol == nil then return end
        
        local currentObject = board:getObjectAtPosition (pistol.targetTileIndex);
        if currentObject ~= nil then
            --Hi ha un objecte a la casella
            if currentObject.objType == BOARD_OBJECT_TYPES.ZOMBIE and currentObject.isHoseValidTarget() then
                --És un Zombie. L'ataquem
                currentObject.damage(1, HOSE_NAME);
                
            else
                --El Zombie ja no és un objectiu vàlid (escapa o mor, i la notificació ENCARA no ha arribat)
                --Seguim pujant
                pistol.tileCleared();
            end
            
        else
            --No hi ha objecte al Tile actual
            --No és possible. L'única opció és que el zombie ha marxat, o desaparegut abans de morir
            board:insertPropHoseAtPosition (pistol.targetTileIndex, hose:createPropHose());
            pistol.tileCleared();
        end
    end
    
    pistol.tileReached = function ()
        -- El raig d'aigua ha arribat a un nou tile
        -- Treiem el TouchEnable del Tile
        board:setTouchEnableToPosition (pistol.targetTileIndex, false);
        
        --Ens assegurem que no hi ha una pedra pendent de caure que vagi cap a aquesta posició. Si és així, la treiem
        --Ho fem amb una notificació
        Runtime:dispatchEvent({ name = GAMEPLAY_HOSE_NEWTILEREACHED_EVNAME, tileID = pistol.targetTileIndex });
        
        --Desfem el possible gel que hi hagi
        ice:newForceMeltdownInTile(pistol.targetTileIndex);
        
        -- Mirem el contingut del Tile per saber el que cal fer
        local currentObject = board:getObjectAtPosition (pistol.targetTileIndex);
        if currentObject == nil then
            --No hi ha objecte
            --Afegim un PROP_HOSE i continuem l'ascens (el·liminant el possible gel que hi hagi)
            board:insertPropHoseAtPosition (pistol.targetTileIndex, hose:createPropHose());
            pistol.tileCleared();
        
        else
            --Hi ha un objecte al seu interior
            if currentObject.objType == BOARD_OBJECT_TYPES.ZOMBIE then
                --Es tracta d'un zombie. Mirem en quin estat es troba
                if not currentObject.isHoseValidTarget() then
                    --El Zombie no és vàlid
                    --No fem res i saltem al següent Tile (el PROP_HOSE s'afegirà automàticament quan acabi l'animació de mort)
                    pistol.tileCleared();
                    
                else
                    --El Zombie és vàlid
                    --Intentem fer-li mal
                    pistol.isAttacking = true;
                    pistol.damageTimer = timer.performWithDelay(timePerDamagePoint, pistol.newDamagePoint, 0);
                end
                
            elseif currentObject.objType == BOARD_OBJECT_TYPES.PROP or currentObject.objType == BOARD_OBJECT_TYPES.PROP_HOSE then
                --És un PROP
                --No fem res i saltem al següent Tile
                pistol.tileCleared();
        
            elseif currentObject.objType == BOARD_OBJECT_TYPES.TRAP then
                --És una Trap
                --La podem el·liminar i la substituïm per un PROP_HOSE, i desparem l'efecte de pols
                currentObject.createDust();
                board:insertPropHoseAtPosition(pistol.targetTileIndex, hose:createPropHose());
                pistol.tileCleared();
                
            elseif currentObject.objType == BOARD_OBJECT_TYPES.STONE then  
               --És una pedra
               --L'el·liminem i substituïm per un PROP_HOSE, i disparem l'efecte de pols
               currentObject.createDust(true);
               board:insertPropHoseAtPosition(pistol.targetTileIndex, hose:createPropHose());
               pistol.tileCleared();
            
            elseif currentObject.objType == BOARD_OBJECT_TYPES.CONTAINER then
                --És una caixa de vida o mort
                --Esperem a que desaparegui d'alguna manera
                pistol.isAttacking = true;
                
            end   
        end
    end
    
    pistol.newTarget = function (newTarget, newTime)
        -- El raig d'aigua ha finalitzat el seu objectiu i està llest per dirigir-se cap al següent
        pistol.targetTileIndex = newTarget;
        local desiredX, desiredY = board:getTilePos(pistol.targetTileIndex);
        local desiredHeight = pistol.initHoseY - desiredY;
        local desiredYScale = desiredHeight / pistol.water.height;
        
        pistol.upTransition = transition.to (pistol.water, { time = newTime, yScale = desiredYScale, onComplete = pistol.tileReached });
    end
    
    pistol.finishAppear = function()
        --La manguera ja ha aparegut
        --Creem la partícula d'aigua i la situem de manera que surti de la pistola
        pistol.water = display.newSprite(animInfo.imageSheet, animInfo.sequenceData)
        background.group:insert(pistol.water);
        
        pistol.water:play();
        pistol.water.scale(pistol.water, pistol.water.xScale, 0);
        pistol.water.alpha = 0.5;
        pistol.water.x, pistol.water.y = pistol.x, pistol.initHoseY;
        
        --Escalarem l'alçada de l'aigua, però volem que el punt inferior sempre sigui el mateix
        pistol.water.anchorY = 1;
        
        --Iniciem el procés d'allargar el raig cap al primer Tile objectiu
        pistol.newTarget(pistol.targetTileIndex, timePerTile / 2);
        
        --Preparem el Timer amb el temps de vida de la manguera
        pistol.lifeTimer = timer.performWithDelay(WEAP_HOSE_LIFETIME, pistol.finishWater);
    end
    
    pistol.enterPause = function (isPaused)
        --En funció de l'estat del Pause de la partida cal aturar o reprendre el comportament de la manguera
        if isPaused then
            --Aturem els timers i transicions
            if pistol.lifeTimer ~= nil then timer.pause(pistol.lifeTimer); end
            if pistol.fadeInTrans ~= nil then transition.pause(pistol.fadeInTrans); end
            if pistol.fadeOutTrans ~= nil then transition.pause(pistol.fadeOutTrans); end
            if pistol.fadeOutoWaterTrans ~= nil then transition.pause(pistol.fadeOutoWaterTrans); end
            if pistol.upTransition ~= nil then transition.pause(pistol.upTransition); end
            if pistol.damageTimer ~= nil then timer.pause(pistol.damageTimer); end
            if pistol.water ~= nil then pistol.water:pause(); end
        else
            --Reactivem els timers i transicions
            if pistol.lifeTimer ~= nil then timer.resume(pistol.lifeTimer); end
            if pistol.fadeInTrans ~= nil then transition.resume(pistol.fadeInTrans); end
            if pistol.fadeOutTrans ~= nil then transition.resume(pistol.fadeOutTrans); end
            if pistol.fadeOutoWaterTrans ~= nil then transition.resume(pistol.fadeOutoWaterTrans); end
            if pistol.upTransition ~= nil then transition.resume(pistol.upTransition); end
            if pistol.damageTimer ~= nil then timer.resume(pistol.damageTimer); end
            if pistol.water ~= nil then pistol.water:play(); end
        end
    end
    
    --Iniciem la transició de la manguera per a aparèixer (alpha)
    pistol.alpha = 0;
    pistol.fadeInTrans = transition.to (pistol, {time = timePerFade, alpha = 1, onComplete = pistol.finishAppear});
    
    --Actualitzem les variables
    currentHoses[pistol.columnToKill] = pistol;
    
    return true;
end

function hose:checkIfCovered (index)
    --Volem saber si alguna de les mangueres actuals està cobrint el Tile indicat
    local found = false;
    for key, currentHose in pairs(currentHoses) do
        found = found or currentHose.isIndexCovered(index);
    end
    
    return found;
end

function hose:newZombieInvalid (index)
   --Un zombie acaba de morir, i si una manguera l'estaba atacant, pot seguir pujant
   for i = 1, board:getNumColumns(), 1 do
       --Obtenim la manguera actual
       local currentHose = currentHoses[i];
       if currentHose ~= nil then
           --Hi ha una manguera en aquesta columna
           if currentHose.isAttacking and currentHose.targetTileIndex == index then
               --Estàvem atacant a l'objectiu que acaba de convertir-se en invàlid
               --Donem la casella per completada
               currentHose.tileCleared();
           end
       end
   end
end

function hose:replaceWithProp (index)
    --Volem substituir el contingut d'una casella per un PROP_HOSE que ocupi la posició a l'espera de que el treguin a l'acabar la manguera
    board:insertPropHoseAtPosition (index, hose:createPropHose());
end

function hose:finishAllHoses()
    --Volem aturar totes les mangueres que hi hagi actives
    for key, currentHose in pairs(currentHoses) do
        --Aturem la manguera automàticament, com si ja hagués arribat al final del temps de vida i ja hagués desaparegut
        currentHose.finishDisappear();
    end  
end

function hose:createPropHose()
    --Volem crear un Prop de Hose que serveixi per indicar que hi ha una manguera cobrint la posició del Board
    local newHoseProp = display.newRect (0,0,10,10);
    newHoseProp.objType = BOARD_OBJECT_TYPES.PROP_HOSE;
    newHoseProp.isVisible = false;
    
    newHoseProp.destroy = function ()
        --Volem destruïr la trampa
        newHoseProp:removeSelf();
        newHoseProp = nil;
    end
    
    --Fem que escolti l'event de mort
    newHoseProp:addEventListener(OBJECT_DESTROY_EVNAME, newHoseProp.destroy);
    
    return newHoseProp;
end


-- GESTIÓ DE PAUSA -------------------------------------------------------------
function hose:enterPause()
    --Entrem en mode Pause
    --Cal aturar el comportament de totes les mangueres
    for key, currentHose in pairs(currentHoses) do
        --Aturem la manguera
        currentHose.enterPause(true);
    end
end

function hose:exitPause()
    --Sortim del mode Pause
    --Reprenem el comportament de totes les mangueres
    for key, currentHose in pairs(currentHoses) do
        --Aturem la manguera
        currentHose.enterPause(false);
    end
end


-- INICIALITZACIÓ I DESTRUCCIÓ -------------------------------------------------
local function assertInitParams (params)
    --Comprovem que hem rebut tots els paràmetres necessaris
    local msg = "Tried to initialize the Hose module without ";
    AZ:assertParam(params, "Hose Init Error", msg .."params");
    AZ:assertParam(params.board, "Hose Init Error", msg .."'params.board'");
    AZ:assertParam(params.background, "Hose Init Error", msg .."'params.background'");
    AZ:assertParam(params.ice, "Hose Init Error", msg .."'params.ice'");
    AZ:assertParam(params.atlas, "Hose Init Error", msg .." atlas");
    AZ:assertParam(params.weaponsSS, "Hose Init Error", msg .." weaponsSS");
end

function hose:init(params)
    --Comprovem que s'hagi inicialitzat correctament
    assertInitParams(params);
    
    --Assignem els paràmetres
    board = params.board;
    background = params.background;
    ice = params.ice;
    _atlas = params.atlas;
    weaponsSS = params.weaponsSS;
    currentHoses = {};

    animInfo = AZ.animsLibrary.hoseWaterAnim();
end

function hose:destroy()
    --Se'ns demana destruïr el mòdul
    --Aturem totes les mangueres
    for key, currentHose in pairs(currentHoses) do
        currentHose.destroy();
    end  
    
    currentHoses = nil;
    hose = nil;
end

return hose