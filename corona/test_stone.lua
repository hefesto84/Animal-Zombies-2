-- Objecte que retornem
local stone = {}

-- Propietats internes
local board = nil
local background = nil
local physics = nil
local ice = nil
local stones = {};
local dust = {};

--SS
local _atlas        = nil;
local weaponsSS       = nil;
local nameStoneInSS  = "piedra";
local animInfo = nil


-- FUNCIONS PÚBLIQUES ----------------------------------------------------------
function stone:place (index)
    --Escollim plantar una nova pedra 
    --Comprovem que la podem generar (que la cel·la estigui buida o amb un Zombie)
    local cellValid = true;
    local zombieInCell = nil;
    local touchEnabled = board:getTouchEnableInTile(index);
    if not board:isIndexValid(index) or not touchEnabled then
        cellValid = false;
    else 
        if stones[index] == nil then
            --No hi ha una pedra en aquesta posició
            zombieInCell = board:getObjectAtPosition (index);
            if zombieInCell ~= nil then
                cellValid = zombieInCell.objType == BOARD_OBJECT_TYPES.ZOMBIE and zombieInCell.isStoneValidTarget();
            end
        else
            --Ja hi ha una pedra en aquesta posició
            cellValid = false;
        end
    end
    
    if not cellValid then
        return false;
    end
    
    
    --Creem la pedra i l'escalem per tenir el tamany d'un tile
    local newWidth, newHeight = board:getTileSize();
    local newStone = display.newImage(weaponsSS, _atlas:getFrameIndex(nameStoneInSS));
    local scaleFactorPerImgW = newWidth / newStone.contentWidth;
    local scaleFactorPerImgH = newHeight / newStone.contentHeight;
    newStone:scale(scaleFactorPerImgW, scaleFactorPerImgH);
    newStone.objType = BOARD_OBJECT_TYPES.STONE;
    if math.random(0, 1) == 0 then
        newStone.xScale = -newStone.xScale;
    end
    
    background.group:insert(newStone);
    newStone:toFront();
    
    --Preparem els seus atributs
    newStone.currentLife = WEAP_STONE_DAMAGE;
    newStone.currentIndex = index;
    newStone.isPlacedInBoard = false;
    newStone.fallingTransition = nil;
    newStone.timerDestroy = nil;
    
    --Preparem les seves funcions
    newStone.destroy = function ()
        --Volem destruïr la pedra
        --Podria ser que les pedres s'hagin destruït pel Destroy del mòdul. En aquest cas, ja seran null
        if newStone == nil then return; end
        
        stones[newStone.currentIndex] = nil;
        Runtime:removeEventListener(GAMEPLAY_HOSE_NEWTILEREACHED_EVNAME, newStone.deletePendingStone);
        if newStone.timerDestroy ~= nil then
            timer.cancel(newStone.timerDestroy);
        end
        if newStone.fallingTransition ~= nil then
            transition.cancel(newStone.fallingTransition);
        end
        newStone = nil;
    end
    
    newStone.createDust = function (isInBoard)
        local breakEff = display.newSprite(animInfo.imageSheet, animInfo.sequenceData);
        background.group:insert(breakEff);
        if isInBoard then
            breakEff.x, breakEff.y = board:getTilePos(newStone.currentIndex);
        else
            breakEff.x, breakEff.y = newStone.x, newStone.y;
        end
        
        breakEff.xScale, breakEff.yScale = newStone.xScale, newStone.yScale;
        
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
                
                breakEff.transID = transition.to(breakEff, { time = animInfo.getAnimFramerate(breakEff.sequence), alpha = 0, onComplete = breakEff.destroy })
            end
        end
        breakEff:addEventListener("sprite", breakEff.animListener);
        breakEff:play();
        
        --Afegim l'efecte a l'array de pols
        table.insert(dust, breakEff);
    end
    
    newStone.finishTimeInBoard = function ()
        --Ha transcorregut el seu temps de vida
        --Afegim l'efecte de pols
        newStone.createDust(true);
        
        --La pedra surt del Board i desapareix
        board:delObjectsAtPosition (newStone.currentIndex);
    end
    
    newStone.deadOutsideBoard = function ()
        --La pedra ha mort sense haver pogut entrar al Board
        --Reactivem el TouchEnable, per si encara no havia acabat de caure
        board:setTouchEnableToPosition (newStone.currentIndex, true);
        
        --El·liminem la pedra
        newStone:removeSelf();
        newStone.destroy();
    end
    
    newStone.deletePendingStone = function (event)
        --Comprovem si la pedra encara no s'ha afegit al board i es troba en un dels Tiles ocupats per la manguera
        --Si és així, el·liminem la pedra
        local index = event.tileID;
        if not newStone.isPlacedInBoard and newStone.currentIndex == index then
            --La pedra encara està caient sobre la posició que volem el·liminar (està fora del Board)
            --Destruïm la pedra
            newStone.deadOutsideBoard();
        end
    end

    newStone.setStoneInBoard = function ()
        --Afegim la pedra al Board
        newStone.x = 0;
        newStone.y = 0;
        newStone:scale(1/scaleFactorPerImgW, 1/scaleFactorPerImgH);

        board:addObjectAtPosition (newStone, newStone.currentIndex);
        newStone.isPlacedInBoard = true;
    end
    
    newStone.finishZombieOut = function()
        --El zombie que ocupa la casella ha acabat de desaparèixer
        --La pedra segueix viva. Cal reemplaçar el zombie mort per la pedra
        newStone.x = 0;
        newStone.y = 0;
        newStone:scale(1/scaleFactorPerImgW, 1/scaleFactorPerImgH);
        board:replaceObjectForExternal (newStone, newStone.currentIndex);
        newStone.isPlacedInBoard = true;
    end
    
    newStone.finishFall = function()
        --Ha finalitzat l'animació d'entrada de la pedra
        --Comprovem el que cal fer en funció de l'estat de la cel·la
        newStone.fallingTransition = nil; 
        
        --Mirem que no hi hagi un gel en el Tile, que caldria el·liminar-lo
        ice:newTouchInTile (index)
        
        --Tractem el contingut del tile
        local damageToApply = 0;
        if zombieInCell ~= nil then
            --La posició es troba ocupada per un zombie
            local lifePendingZombie = zombieInCell.life;

            local isStoneResistant = zombieInCell.isWeaponResistant(STONE_NAME);
            if lifePendingZombie <= WEAP_STONE_DAMAGE and not isStoneResistant then
                damageToApply = lifePendingZombie;
            else
                damageToApply = WEAP_STONE_DAMAGE;
            end

            --Apliquem el dany al zombie i el reactivem
            --print("Fem mal: "..damageToApply);
            zombieInCell.damage(damageToApply, "stone")
            zombieInCell.setStoneTarget(false);
            
            --Apliquem el dany a la pedra
            newStone.currentLife = newStone.currentLife - damageToApply;
            if newStone.currentLife <= 0 then
                --La pedra s'ha trencat per l'impacte
                --Iniciem el trencament de la pedra
                newStone.createDust(false);
                
                --Treiem la pedra
                newStone.deadOutsideBoard();
                
            else
                --La pedra ha sobreviscut
                --Preparem el temps de vida que li queda
                newStone.timerDestroy = timer.performWithDelay(WEAP_STONE_LIFETIME_PER_ATTACK * newStone.currentLife, newStone.finishTimeInBoard);
            end
       
        else
            --La posició està lliure
            --Afegim la pedra al board sense haver rebut mal
            newStone.setStoneInBoard();
            
            --Preparem el temps de vida que li queda
            newStone.timerDestroy = timer.performWithDelay(WEAP_STONE_LIFETIME_PER_ATTACK * newStone.currentLife, newStone.finishTimeInBoard);
        end
        
        --Reactivem el Touch de la cel·la
        board:setTouchEnableToPosition (index, true);
    end
    
    newStone.enterPause = function (isPaused)
        --Volem adaptar el comportament de la pedra al nou estat de Pause de la partida
        
        timer.safePauseResume(newStone.timerDestroy, isPaused);
        transition.safePauseResume(newStone.fallingTransition, isPaused);
    end
    
    
    --Preparem al (possible) Zombie per a la caiguda de la pedra i desactivem el Touch del Tile
    board:setTouchEnableToPosition (index, false);
    if zombieInCell ~= nil then
        zombieInCell.setStoneTarget(true);
    end
    
    --Afegim la pedra a la llista, i esperem a que desaparegui
    stones[newStone.currentIndex] = newStone;
    
    --Afegim l'animació per acabar caient al centre del Tile que ens interessa
    local desiredX, desiredY = board:getTilePos(index);
    newStone.x = desiredX;
    newStone.y = desiredY - 50;
    newStone.fallingTransition = transition.to(newStone, {time = 500, y = desiredY, transition = easing.inExpo,  onComplete = newStone.finishFall });
    
    --Preparem el listener per si cal el·liminar la pedra per culpa d'una manguera
    Runtime:addEventListener(GAMEPLAY_HOSE_NEWTILEREACHED_EVNAME, newStone.deletePendingStone);
    newStone:addEventListener(OBJECT_DESTROY_EVNAME, newStone.destroy);

    return true
end

function stone:checkIfPending (index)
    --Volem saber si hi ha una pedra pendent de ficar-se en una posició concreta
    local found = false;
    for key, currentStone in pairs(stones) do
        --Comprovem si la pedra actual està pendent de caure a la posició indicada
        found = found or (currentStone.currentIndex == index and not currentStone.isPlacedInBoard and currentStone.currentLife > 0);
    end
    
    return found;
end

function stone:replaceWithStone (index)
    --Un Zombie ha mort per una pedra que encara segueix viva
    --Substituïm el Zombie per la pedra
    local currentStone = stones[index];
    currentStone.finishZombieOut();
end

function stone:cancelOutBoardStones()
    --Volem cancel·lar totes les pedres que encara no s'han afegit al board (estan caient o esperant a que acabi l'animació de mort del Zombie)
    for key, currentStone in pairs(stones) do
        --Comprovem si la pedra actual està pendent de caure a la posició indicada
        if not currentStone.isPlacedInBoard then
            --La pedra encara no s'ha afegit
            --La cancel·lem
            currentStone.deadOutsideBoard();
        end
    end
end

function stone:pauseTimerStones()
    --Volem aturar els Timers de mort de les pedres
    for key, currentStone in pairs(stones) do
        currentStone.enterPause(true);
    end
    
    for i = 1, #dust do
        dust[i].onPause(true);
    end
end

function stone:resumeTimerStones()
    --Volem reprendre els Timers de mort de les pedres
    for key, currentStone in pairs(stones) do
        currentStone.enterPause(false);
    end
    
    for i = 1, #dust do
        dust[i].onPause(false);
    end
end


-- GESTIÓ DE PAUSE -------------------------------------------------------------
function stone:enterPause()
    --Entrem en mode pause
    --Aturem totes les pedres actives (els seus timers i transicions)
    stone:pauseTimerStones();
end

function stone:exitPause()
    --Sortim del mode pause
    --Reprenem el comportament de les pedres actives (timers i transicions)
    stone:resumeTimerStones();
end




-- INICIALITZACIÓ I DESTRUCCIÓ -------------------------------------------------
function stone:destroy()
    --Se'ns demana destruïr el mòdul
    --Destruïm totes les pedres
    for key, currentStone in pairs(stones) do
        currentStone.destroy();
    end
    
    --Destruim tots els fums
    for i = 1, #dust do
        dust[1].destroy();
    end
    
    stone = nil
end

local function assertInitParams (params)
    --Comprovem que hem rebut tots els paràmetres necessaris
    local msg = "Tried to initialize the Stone module without ";
    AZ:assertParam(params, "Stone Init Error", msg .."params");
    AZ:assertParam(params.board, "Stone Init Error", msg .."'params.board'");
    AZ:assertParam(params.background, "Stone Init Error", msg .."'params.background'");
    AZ:assertParam(params.physics, "Stone Init Error", msg .."'params.physics'");
    AZ:assertParam(params.ice, "Stone Init Error", msg .."'params.ice'");
    AZ:assertParam(params.atlas, "Stone Init Error", msg .." atlas");
    AZ:assertParam(params.weaponsSS, "Stone Init Error", msg .." weaponsSS");
end

function stone:init(params)
    --Comprovem que s'hagi inicialitzat correctament
    assertInitParams(params);
    
    --Assignem els paràmetres
    board = params.board;
    background = params.background;
    physics = params.physics;
    ice = params.ice;
    _atlas = params.atlas;
    weaponsSS = params.weaponsSS;
    animInfo = AZ.animsLibrary.objectDestroyAnim();
end

return stone;



