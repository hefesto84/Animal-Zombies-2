-- Objecte que retornem
local ice = {}

-- Propietats internes
local board = nil
local background = nil
local physics = nil
local stone = nil

--SS
local _atlas        = nil;
local weaponsSS     = nil;
local nameIceInSS   = "hielo";
local animInfo      = nil;

-- Variables de gestió
local ices = {};
local icesBreaking = {};


-- FUNCIONS PÚBLIQUES ----------------------------------------------------------
function ice:place (index)
    --Escollim plantar un nou gel 
    --Comprovem que la podem generar. Cal que el Tile:
    --  sigui vàlid, 
    --  tingui el TouchEnable activat,
    --  estigui buit o amb un Zombie
    --  no hi hagi un altre gel posat
    --  no hi hagi una pedra pendent d'afegir-se al board en aquella posició
    if not board:isIndexValid(index) then return false; end
        
    local touchEnabled = board:getTouchEnableInTile(index);
    if not touchEnabled then return false; end
    
    if ices[index] ~= nil then return false; end
    
    local objectInCell = board:getObjectAtPosition (index);
    if objectInCell ~= nil then
        --Hi ha un objecte a la posició
        if objectInCell.objType == BOARD_OBJECT_TYPES.ZOMBIE then
            --És un Zombie
            if not objectInCell.isIceValidTarget() then 
                --El Zombie no és vàlid
                return false;
            end

        else 
            --No és un Zombie. No es pot plantar
            return false;
        end
    end
    
    if stone:checkIfPending(index) then
        --Hi ha una pedra pendent d'afegir-se. El Tile no està disponible
        return false;
    end
    
    --El gel es pot plantar
    --Creem el gel i l'escalem per tenir el tamany d'un tile
    local newWidth, newHeight = board:getTileSize();
    local newIce = display.newImage(weaponsSS, _atlas:getFrameIndex(nameIceInSS));
    local scaleFactorPerImgW = newWidth / newIce.width;
    local scaleFactorPerImgH = newHeight / newIce.height;
    newIce:scale(scaleFactorPerImgW, scaleFactorPerImgH);
    newIce.objType = BOARD_OBJECT_TYPES.STONE;
    if math.random(0, 1) == 0 then
        newIce.xScale = -newIce.xScale;
    end
    
    background.group:insert(newIce);
    newIce:toFront();
    
    --Preparem els seus atributs
    newIce.currentIndex = index;
    newIce.currentTarget = nil;
    newIce.isAlive = true;
    newIce.timerDestroy = nil;
    newIce.transitionOutAlpha = nil;
    newIce.transitionOutSize = nil;
    
    --Definim les funcions del gel
    newIce.setPause = function (isPaused)
        --Aturem o reiniciem els timers en funció del valor rebut
        if isPaused then
            if newIce.timerDestroy ~= nil then timer.pause(newIce.timerDestroy); end
            if newIce.transitionOutAlpha ~= nil then transition.pause(newIce.transitionOutAlpha); end
            if newIce.transitionOutSize ~= nil then transition.pause(newIce.transitionOutSize); end
        else
            if newIce.timerDestroy ~= nil then timer.resume(newIce.timerDestroy); end
            if newIce.transitionOutAlpha ~= nil then transition.resume(newIce.transitionOutAlpha); end
            if newIce.transitionOutSize ~= nil then transition.resume(newIce.transitionOutSize); end
        end
    end
    
    newIce.setTarget = function (newTarget)
        --El gel rep un objectiu
        if newTarget.objType == BOARD_OBJECT_TYPES.ZOMBIE then
            --És un objectiu vàlid
            newIce.currentTarget = newTarget;
            newIce.currentTarget.setIceTarget(true);
            return true;
            
        else
            return false;
        end
    end
    
    newIce.destroy = function()
        --Volem destruïr el gel
        ices[newIce.currentIndex] = nil;
        if newIce.timerDestroy ~= nil then
            timer.cancel(newIce.timerDestroy);
        end
        newIce:removeSelf();
        newIce = nil;
    end
    
    newIce.finishMeltdown = function()
        --Ha acabat l'animació de fondre el gel
        if newIce.transitionOutSize ~= nil then transition.cancel(newIce.transitionOutSize); newIce.transitionOutSize = nil; end
        if newIce.transitionOutAlpha ~= nil then transition.cancel(newIce.transitionOutAlpha); newIce.transitionOutAlpha = nil; end
        
        --Descongel·lem el Zombie actual (si n'hi ha)
        if newIce.currentTarget ~= nil and newIce.currentTarget.life > 0 then
            newIce.currentTarget.setIceTarget(false);
        end
        
        --Destruïm el gel
        newIce.destroy();
    end
    
    newIce.startMeltdown = function()
        --Ha acabat el temps de vida del gel
        --Aturem el timer de vida
        newIce.isAlive = false;
        if newIce.timerDestroy ~= nil then timer.cancel(newIce.timerDestroy); end
        
        --Iniciem l'animació de fondre's
        local lowY = newIce.y + newIce.contentHeight*0.5;
        local wideXScale = newIce.xScale * 1.5;
        newIce.transitionOutAlpha = transition.to(newIce, {time = 1800, alpha = 0});
        newIce.transitionOutSize =  transition.to(newIce, {time = 2000, yScale = 0.01, xScale = wideXScale, y = lowY, onComplete = newIce.finishMeltdown});
    end
    
    newIce.forceMeltdown = function()
        --Es demana d'iniciar el procés de fondre el gel
        --Mirem en quin estat es troba el gel
        if newIce.isAlive then
            --El gel encara es troba actiu. El fonem
            newIce.startMeltdown();
        end
    end
    
    newIce.finishBreak = function()
        --S'ha acabat de trencar el gel
        --Descongel·lem el Zombie actual (si n'hi ha i no ha mort al trencar el gel)
        if newIce.currentTarget ~= nil and newIce.currentTarget.life > 0 then
            newIce.currentTarget.setIceTarget(false);
        end
        
        --Destruïm el gel
        newIce.destroy();
    end
    
    newIce.startBreak = function()
        --Gel rep un toc (del jugador o una explosió) i inicia el procés de trencar-se
        --Aturem el timer de vida
        newIce.isAlive = false;
        if newIce.timerDestroy ~= nil then timer.cancel(newIce.timerDestroy); end
        
        --Fem invisible el gel estàtic
        newIce.isVisible = false;
        
        --Creem l'efecte i el situem en la mateixa posició que el gel estàtic
        local breakEff = display.newSprite(animInfo.imageSheet, animInfo.sequenceData);
        background.group:insert(breakEff);
        breakEff.x, breakEff.y = newIce.x, newIce.y;
        breakEff.xScale, breakEff.yScale = newIce.xScale * 1.5, newIce.yScale * 1.5;
        
        breakEff.destroy = function(event)
  
            --Cancelem el transition
            transition.safeCancel(breakEff.transID)
            
            --Treiem l'efecte de l'array. Eliminem el primer perque sempre s'eliminen en ordre
            table.remove(icesBreaking, 1);
            
            display.remove(breakEff);
            breakEff = nil;
        end
        
        breakEff.finishAnim = function(event)
            --S'ha acabat el la seqüència d'animació de trencar-se
            --Prenem les accions sobre el contingut del board
            newIce.finishBreak();
            
            --Destruïm l'efecte
            breakEff.destroy(event);
        end
        
        breakEff.onPause = function(isPause)
            
            transition.safePauseResume(breakEff.transID, isPause)
            
            if isPause then
                breakEff:pause();
            else
                breakEff:play();
            end
            
        end
        
        breakEff.animListener = function(event)
            if event.phase == "ended" then
                
                if breakEff.ended then return; end
                breakEff.ended = true;
                breakEff.transID = transition.to(breakEff, { time = animInfo.getAnimFramerate(breakEff.sequence), alpha = 0, onComplete = breakEff.finishAnim })
            end
        end
        breakEff:addEventListener("sprite", breakEff.animListener);
        breakEff:play();
        
        --Afegim l'efecte a l'array de pols
        table.insert(icesBreaking, breakEff);
    end
    
    newIce.touch = function()
        --S'ha fet un touch sobre el Tile que conté el gel
        --Mirem en quin estat es troba el gel
        if newIce.isAlive then
            --El gel encara es troba actiu. El trenquem
            newIce.startBreak();
        end
    end
    
    --Situem el gel a la posició que hem escollit
    newIce.x, newIce.y = board:getTilePos(index);
    
    --Congel·lem el zombie (si n'hi ha)
    if objectInCell ~= nil then
        newIce.setTarget(objectInCell);
    end
    
    --Afegim el gel a la llista, i esperem a que desaparegui
    ices[newIce.currentIndex] = newIce;
    
    --Preparem el timer de vida
    newIce.timerDestroy = timer.performWithDelay(WEAP_ICECUBE_LIFETIME * 1000, newIce.startMeltdown);
    
    return true
end


-- FUNCIONS PÚBLIQUES ----------------------------------------------------------
function ice:getAnyIceAtPosition (index)
    --Consultem si hi ha actualment un gel a la posició indicada
    return ices[index] ~= nil;
end

function ice:newZombieAppeared (index)
    --Ha aparegut un nou zombie al Board
    --Cal mirar si hi havia un gel en aquella posició i, si hi era, congel·lar el zombie
    local currentIce = ices[index];
    if currentIce ~= nil then
        --Hi ha un gel
        --Congel·lem el zombie
        local currentZombie = board:getObjectAtPosition (index);
        currentIce.setTarget(currentZombie);
    end
end

function ice:newTouchInTile (index)
    --S'ha produït un Touch al Board, i cal trencar el possible gel "viu" que hi hagi
    --Cal mirar si hi ha un gel al Tile clickat i, si n'hi ha, aplicar les accions
    local currentIce = ices[index];
    if currentIce ~= nil then
        --Hi ha un gel
        currentIce.touch();
    end
end

function ice:newForceMeltdownInTile (index)
    --Es demana de fondre el gel viu que hi hagi a la posició indicada
    local currentIce = ices[index];
    if currentIce ~= nil then
        --Hi ha un gel
        currentIce.forceMeltdown();
    end
end

function ice:pauseTimerIces()
    --Volem aturar els timers i transicions dels gels
    for key, currentIce in pairs(ices) do
        currentIce.setPause(true);
    end
    
    --Fem el Pause/Resume dels efectes de fum
    for i = 1, #icesBreaking do
        icesBreaking[i].onPause(true);
    end
end

function ice:resumeTimerIces()
    --Volem reprendre els timers i transicions dels gels
    for key, currentIce in pairs(ices) do
        currentIce.setPause(false);
    end
    
    --Fem el Pause/Resume dels efectes de fum
    for i = 1, #icesBreaking do
        icesBreaking[i].onPause(false);
    end
end

function ice:enterPause()
    --Entrem en mode Pausa
    --Aturem els timers dels gels
    ice:pauseTimerIces()
end

function ice:exitPause()
    --Sortim del mode Pausa
    --Reprenem els timers del gels
    ice:resumeTimerIces();
end


-- INICIALITZACIÓ I DESTRUCCIÓ -------------------------------------------------
function ice:destroy()
    --Se'ns demana destruïr el mòdul
    --Destruïm tots els gels
    for key, currentIce in pairs(ices) do
        currentIce.destroy();
    end 
    
    --Destruim tots els efectes de trencat
    for i = 1, #icesBreaking do
        icesBreaking[1].destroy();
    end
    
    ice = nil
end

local function assertInitParams (params)
    --Comprovem que hem rebut tots els paràmetres necessaris
    local msg = "Tried to initialize the Ice module without ";
    AZ:assertParam(params, "Ice Init Error", msg .."params");
    AZ:assertParam(params.board, "Ice Init Error", msg .."'params.board'");
    AZ:assertParam(params.background, "Ice Init Error", msg .."'params.background'");
    AZ:assertParam(params.physics, "Ice Init Error", msg .."'params.physics'");
    AZ:assertParam(params.stone, "Ice Init Error", msg .."'params.stone'");
    AZ:assertParam(params.atlas, "Ice Init Error", msg .." atlas");
    AZ:assertParam(params.weaponsSS, "Ice Init Error", msg .." weaponsSS");
end

function ice:init(params)
    --Comprovem que s'hagi inicialitzat correctament
    assertInitParams(params);
    
    --Assignem els paràmetres
    board = params.board;
    background = params.background;
    physics = params.physics;
    stone = params.stone;
    _atlas = params.atlas;
    weaponsSS = params.weaponsSS;
    
    animInfo = AZ.animsLibrary.iceDestroyAnim();
end

return ice;





