-- Objecte que retornem
local trap = {}

-- Propietats internes
local board = nil
local background = nil
local ice = nil
local animInfo = nil
local destroyInfo = nil
trap.numTrapsActive = 0;
trap.array = {};
trap.arrayTemp = {};
local dust = {};


-- FUNCIONS PRIVADES -----------------------------------------------------------
local canPlant = function (index)
    --Mirem si es pot plantar la trampa en la posició indicada
    if not board:isIndexValid(index) then
       --La posició no és vàlida per a plantar la trampa
       return false;
    end
            
    if board:getObjectAtPosition(index) ~= nil or ice:getAnyIceAtPosition(index) then
        --La cel·la ja està ocupada
        --No es pot aplicar
        return false;
    end
    
    return true;
end

-- FUNCIONS PÚBLIQUES ----------------------------------------------------------
function trap:plant (index)
    --Escollim plantar una nova trampa 
    if not canPlant(index) then
        --La trampa no es pot plantar ara mateix en la posició indicada
        return false;
    end
    
    --Creem la trampa
    local newTrap = display.newSprite(animInfo.imageSheet, animInfo.sequenceData);
    newTrap.x = 0;
    newTrap.y = 0;
    newTrap.currentLife = WEAP_TRAP_INITLIFE;
    newTrap.objType = BOARD_OBJECT_TYPES.TRAP;
    newTrap.currentIndex = index;
    
    newTrap.destroy = function ()
        if trap ~= nil then
            --Treiem la trampa de l'array
            for i = 1, #trap.array do
                if trap.array[i] == newTrap then
                    trap.array[i] = nil;
                end
            end

            --Volem destruïr la trampa
            Runtime:removeEventListener(ALL_DESTROY_EVNAME, newTrap.destroy);
            newTrap:removeSelf();
            newTrap = nil;

            --Decrementem el comptador de Traps actius
            trap.numTrapsActive = trap.numTrapsActive - 1;
        end
    end
    
    newTrap.createDust = function ()
        local breakEff = display.newSprite(destroyInfo.imageSheet, destroyInfo.sequenceData);
        background.group:insert(breakEff);
        breakEff.x, breakEff.y = board:getTilePos(newTrap.currentIndex);
        breakEff.xScale, breakEff.yScale = newTrap.xScale, newTrap.yScale;
        
        if math.random(0, 1) == 0 then
            breakEff.xScale = -breakEff.xScale;
        end
        
        breakEff.destroy = function(event)
            --Cancelem el transition
            transition.safeCancel(breakEff.transID)
            
            --Treiem l'efecte de l'array. Eliminem el primer perque sempre s'eliminen en ordre
            table.remove(dust, 1);
            
            display.remove(breakEff);
            breakEff = nil;
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
                breakEff.transID = transition.to(breakEff, { time = destroyInfo.getAnimFramerate(breakEff.sequence), alpha = 0, onComplete = breakEff.destroy })
            end
        end
        breakEff:addEventListener("sprite", breakEff.animListener);
        breakEff:play();
        
        --Afegim l'efecte a l'array de pols
        table.insert(dust, breakEff);
    end
    
    newTrap.dragObjectToIt = function (index)
        --Hem arrossegat un objecte a la trampa
        local currentZombie = board:getObjectAtPosition(index);
        if currentZombie == nil or currentZombie.objType ~= BOARD_OBJECT_TYPES.ZOMBIE then
            --L'objecte arrossegat no és un Zombie
            return false;
        end
        
        if currentZombie.isWeaponResistant(TRAP_NAME) then
            --El zombie és resistent a la trampa
            return false;
        end
        
        --Hem arrossegat un Zombie a la trampa
        --Apliquem el mal necessari per a matar el Zombie (o el mal que li queda disponible, si és inferior)
        local lifePendingZombie = currentZombie.life;
        local damageToApply = 0;
        if lifePendingZombie <= WEAP_TRAP_DAMAGE then
            damageToApply = lifePendingZombie;
        else 
            damageToApply = WEAP_TRAP_DAMAGE;
        end
        
        if currentZombie.damage(damageToApply, "trap") then
            --El Zombie ha mort
            --Restem vida a la trampa
            newTrap.currentLife = newTrap.currentLife - damageToApply;
            if newTrap.currentLife <= 0 then
                --La trampa ja no suporta més punts de mal i es trenca
                --Treiem la trampa del Board
                board:delObjectsAtPosition (newTrap.currentIndex);
           
            else
                --La trampa ha matat al Zombie, i encara li queden punts de mal
                --Iniciem l'animació de la trampa atacant
                newTrap:setSequence("attackEffect");
                newTrap:play();
            end

        else
            --El Zombie segueix viu
            --Fem que el Zombie passi a estar a la casella de la trampa
            board:replaceObject (index, newTrap.currentIndex);
        end 
        
        return true;
    end
    
    newTrap.onPause = function(isPause)
        transition.safePauseResume(newTrap.transID, isPause);
        
        --Si estem fent l'animació de tancar la trampa, pausem o resumim
        if newTrap.sequence == "attackEffect" then
            if isPause then
                newTrap:pause();
            else
                newTrap:play();
            end
        end
    end
    
    newTrap.endKill = function()
        --Acabem de fer l'animació de tancar la trampa, tornem a setejar l'sprite obert
        newTrap.ended = false;
        
        newTrap:setSequence("plantedEffect");
        newTrap:pause();
        
    end
    
    newTrap.animListener = function(event)
        if event.phase == "ended" and newTrap.sequence == "attackEffect" then
            if newTrap.ended then return end
            
            newTrap.ended = true
            
            newTrap.transID = transition.to(newTrap, { time = animInfo.getAnimFramerate("attackEffect"), onComplete = newTrap.endKill })
        end
    end
    
    --Mostrem el frame normal i afegim el listener a l'animació
    newTrap:setSequence("plantedEffect");
    newTrap:addEventListener("sprite", newTrap.animListener);
    
    --Fem que escolti l'event de mort
    newTrap:addEventListener(OBJECT_DESTROY_EVNAME, newTrap.destroy);
    Runtime:addEventListener(ALL_DESTROY_EVNAME, newTrap.destroy);
    
    --Afegim la trampa a la posició indicada
    if not board:addObjectAtPosition (newTrap, index) then
        --No s'ha pogut afegir
        newTrap.destroy();
        return false;
    end
    
    --Incrementem el comptador de Traps actius
    trap.numTrapsActive = trap.numTrapsActive + 1;
    
    --Afegim el Trap al nostre array
    trap.array[#trap.array +1] = newTrap
    
    return true
end

function trap:updateTempTouch (touchID, boardID, canShow, touchX, touchY)
    --Volem actualitzar l'estat de la (possible) trampa temporal que hi ha per culpa d'un Drag de l'arma
    --Accedim a la informació de la trampa temporal que hi pogués haver per al Touch actual
    
    local currentTempTrap = trap.arrayTemp[touchID];
    if currentTempTrap == nil then
        --No hi ha cap trampa temporal per al Touch actual
        currentTempTrap = display.newSprite(animInfo.imageSheet, animInfo.sequenceData);
        local newWidth, newHeight = board:getTileSize();
        local scaleFactorPerImgW = newWidth / currentTempTrap.width;
        local scaleFactorPerImgH = newHeight / currentTempTrap.height;
        currentTempTrap:scale(scaleFactorPerImgW, scaleFactorPerImgH);
        background.group:insert(currentTempTrap);
        currentTempTrap.x, currentTempTrap.y = 0, 0;
        currentTempTrap.boardID = 0;
        currentTempTrap.touchID = touchID;
        
        currentTempTrap.destroy = function()
            trap.arrayTemp[currentTempTrap.touchID] = nil;
            
            Runtime:removeEventListener("enterFrame", currentTempTrap.enterFrame);
            
            currentTempTrap:removeSelf();
            currentTempTrap = nil;
        end
        
        currentTempTrap.enterFrame = function()
            --Mirem en quin estat es troba la situació actual, per a saber si es pot posar la trampa o no
            --Actualitzem el seu aspecte
            if canPlant(currentTempTrap.boardID) then
                --Es pot plantar
                currentTempTrap:setFillColor(1, 1, 1, 0.3);
            else
                --No es pot plantar
                currentTempTrap:setFillColor(1, 0.5, 0.5, 0.7);
            end
        end
        
        currentTempTrap.moveToPosition = function (index, currentCanShow, newX, newY)
            if board:isIndexValid(index) then
                --La posició és vàlida
                currentTempTrap.isVisible = currentCanShow;
                
                --En funció de si es pot plantar o no, centrem la trampa o no
                if canPlant(index) then
                    currentTempTrap.x, currentTempTrap.y = board:getTilePos(index);
                else
                    currentTempTrap.x, currentTempTrap.y = newX, newY;
                end
                    
            else
                --La posició no és vàlida dins el board
                --currentTempTrap.isVisible = false;
                currentTempTrap.x, currentTempTrap.y = newX, newY;
            end 
            
            currentTempTrap.boardID = index;
        end
        
        Runtime:addEventListener("enterFrame", currentTempTrap.enterFrame);
        
        --Guardem la nova trampa
        trap.arrayTemp[touchID] = currentTempTrap;
    end
    
    --Situem la trampa a la posició desitjada
    currentTempTrap.moveToPosition(boardID, canShow, touchX, touchY);
    
end

function trap:finishTempTouch (touchID)
    --Ha finalitzat un event de Touch que creava una (possible) trampa~ temporal
    local currentTempTrap = trap.arrayTemp[touchID];
    if currentTempTrap ~= nil then
        currentTempTrap.destroy();
    end
end


-- INICIALITZACIÓ I DESTRUCCIÓ -------------------------------------------------
local function assertInitParams (params)
    --Comprovem que hem rebut tots els paràmetres necessaris
    local msg = "Tried to initialize the Hose module without ";
    AZ:assertParam(params, "Hose Init Error", msg .."params");
    AZ:assertParam(params.board, "Hose Init Error", msg .."'params.board'");
    AZ:assertParam(params.background, "Hose Init Error", msg .."'params.background");
    AZ:assertParam(params.ice, "Hose Init Error", msg .."'params.ice'");
end

function trap:init(params)
    --Comprovem que s'hagi inicialitzat correctament
    assertInitParams(params);
    
    --Assignem els paràmetres
    board = params.board;
    background = params.background;
    ice = params.ice;
    
    --Agafem la informació de l'animació
    animInfo = AZ.animsLibrary.trapAnim();
    destroyInfo = AZ.animsLibrary.objectDestroyAnim();
end

function trap:pause(isPause)
    --Fem el Pause/Resume de la trampa
    for i = 1, #trap.array do
        trap.array[i].onPause(isPause)
    end
    
    --Fem el Pause/Resume dels efectes de fum
    for i = 1, #dust do
        dust[i].onPause(isPause);
    end
end

function trap:destroy()
    --Se'ns demana destruïr el mòdul
    --Cada trampa individual s'el·limina capturant l'event 
    
    --Destruim tots els fums
    for i = 1, #dust do
        dust[1].destroy();
    end
    
    --Destruïm qualsevol trampa temporal que hagi pogut quedar penjada (cap, idealment)
    for key, currentTempTrap in pairs(trap.arrayTemp) do
        currentTempTrap.destroy();
    end
    
    trap = nil
end

return trap

