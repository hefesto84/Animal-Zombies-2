-- Objecte principal que es retorna
local gaviot = {}

-- Atributs de la classe
gaviot.isGaviotOn = false;
local board = nil;
local physics = nil;
local background = nil;
local targetsInfo = nil;
local numTargetsAlive = 0;
local timeFall = 0;
local bird = nil;
local cacas = {};
local timerToFinish = nil;

--SS
local _atlas        = nil;
local weaponsSS       = nil;
local nameCacaInSS  = "caca paloma";
local animInfo = nil;

-- Constants
local POS_BIRD_PERC             = 0.2

-- Valors precalculats
local delta_birdY = display.contentHeight * POS_BIRD_PERC;


-- FUNCIONS PRIVADES -----------------------------------------------------------
local function finishGaviot ()
    --Ha acabat tot el procés de atac aeri
    timerToFinish = nil;
    
    --Fem invisible l'ocell
    bird.isVisible = false;
    
    --Desbloquegem els zombies
    board.finishGaviot();
    
    --Indiquem que tot el procés ja ha acabat
    gaviot.isGaviotOn = false;
    
    --Enviem la notificació al GamePlay per a informar de que ha acabat el Gaviot
    Runtime:dispatchEvent({ name = GAMEPLAY_GAVIOT_FINISH_EVNAME });
end

local newHit = function()
    --Un nou projectil ha impactat contra el seu objectiu
    numTargetsAlive = numTargetsAlive - 1;
    if numTargetsAlive == 0 then
        --Tots els projectils han fet impacte
        --Settegem les variables de control
        timerToFinish = timer.performWithDelay(2000, finishGaviot);
    end
end

function shuffled(tab)
    local n, order, res = #tab, {}, {}

    for i=1,n do order[i] = { rnd = math.random(), idx = i } end
    table.sort(order, function(a,b) return a.rnd < b.rnd end)
    for i=1,n do res[i] = tab[order[i].idx] end
    return res
end

local filterTargets = function(maxTargets)
    --Volem filtrar i retornar una llista amb, com a màxim, maxTargets zombies que siguin objectius vàlids per a l'atac
    local shuffleZombieInfo = {};
    math.randomseed(os.time())
    shuffleZombieInfo = shuffled(targetsInfo);
    
    --Del vector re-ordenat, ens quedem amb els "numTargets" primers
    local selectedZombies = {};
    local i = 1;
    local currentZombieInfo = shuffleZombieInfo[i];
    local needMore = #selectedZombies < maxTargets;
    while needMore and currentZombieInfo do
        --Mentre necessitem més zombies per a retornar, i n'hi hagi disponibles, els afegim
        table.insert(selectedZombies, currentZombieInfo);
       
        --Actualitzem les variables de control
        i = i + 1;
        currentZombieInfo = shuffleZombieInfo[i];
        needMore = (table.getn(selectedZombies) < maxTargets);
    end
   
    return selectedZombies;
end
    
local shoot = function ()
    --Volem disparar
    --Obtenim els objectius
    cacas = {};
    local targetZombies = filterTargets(WEAP_GAVIOT_NUM_ATTACKS);
    local numZombies = #targetZombies;
    
    for i = 1, numZombies do
        --Per a cada un dels possibles objecius preparem un projectil
        local targetInfo = targetZombies[i];
        local targetZombie = targetInfo.zombie;
        local targetX = targetInfo.targetX;
        local targetY = targetInfo.targetY;
    
        --Creem la imatge i l'afegim al grup
        local newWidth, newHeight = board:getTileSize();
        local caca = display.newImage(weaponsSS, _atlas:getFrameIndex(nameCacaInSS));
        local scaleFactorPerImgW = newWidth / caca.contentWidth;
        local scaleFactorPerImgH = newHeight / caca.contentHeight;
        caca:scale(scaleFactorPerImgW, scaleFactorPerImgH);
        background.group:insert(caca);
        
        --Preparem les variables 
        caca.fallingTimer = nil;
        caca.fallingTrans = nil;

        caca.destroy = function()
            --El·liminem el projectil
            if caca.fallingTrans ~= nil then
                transition.cancel(caca.fallingTrans);
            end
            if caca.fallingTimer ~= nil then
                timer.cancel(caca.fallingTimer);
            end
        end

        caca.hit = function()
            --El projectil ha impactat
            --"Matem" l'objectiu
            local evParams = { name = OBJECT_TOUCH_EVNAME,
                                damage = WEAP_GAVIOT_DAMAGE_PER_BULLET,
                                how = "gaviot" };
            caca.target:dispatchEvent(evParams);

            --Aturem el comportament físic
            physics.deactivateFreeFall(caca);
            
            --El·liminem el projectil
            display.remove(caca);

            --Informem del nou impacte
            newHit();
        end
        
        caca.enterPause = function (isPause)
            --Volem adaptar el comportament del projecitil a l'estat de Pause actual
            if isPause then
                --Aturem timers i transicions
                if caca.fallingTrans ~= nil then transition.pause(caca.fallingTrans); end
                if caca.fallingTimer ~= nil then timer.pause(caca.fallingTimer); end
                if caca.scaleXTransition ~= nil then transition.pause(caca.scaleXTransition); end
                if caca.scaleXTransition ~= nil then transition.pause(caca.scaleYTransition); end
            
            else 
                --Reprenem timers i transicions
                if caca.fallingTrans ~= nil then transition.resume(caca.fallingTrans); end
                if caca.fallingTimer ~= nil then timer.resume(caca.fallingTimer); end
                if caca.scaleXTransition ~= nil then transition.resume(caca.scaleXTransition); end
                if caca.scaleXTransition ~= nil then transition.resume(caca.scaleYTransition); end
            end
        end

        --Preparem les propietats del projectil
        caca.target = targetZombie;
        caca.x = bird.x;
        caca.y = bird.y;

        --Calcul·lem els paràmetres físics de la caiguda Y
        local distFall = caca.y - targetY;
        local currentTimeFall = timeFall + (math.random() * 0.4 - 0.2);
        physics.activateFreeFall(caca, distFall, currentTimeFall);

        --Iniciem la transició linial per a X
        local timeMinAlignFactor = 0.3;
        local timeAlignX = currentTimeFall * (math.random(timeMinAlignFactor * 100, 100) / 100);
        caca.fallingTrans = transition.to(caca, {x=targetX, time=timeAlignX*1000, transition = easing.linear });

        --Iniciem les transicions d'escala per a simular la caiguda (posem l'encarament aleatori també)
        if math.random(2) == 1 then caca.xScale = -caca.xScale; end
        local idleXScale, idleYScale = caca.xScale, caca.yScale;
        local initialXScale, initialYScale = idleXScale*0.4, idleYScale*0.4;
        local finalXScale, finalYScale = idleXScale * 0.9, idleYScale * 1.5;
        
        caca.xScale, caca.yScale = initialXScale, initialYScale;
        local timeMinScaleFactor = 0.5;
        local timeScaleX = currentTimeFall * (math.random(timeMinScaleFactor * 100, 100) / 100);
        local timeScaleY = currentTimeFall * (math.random(timeMinScaleFactor * 100, 100) / 100);
        caca.scaleXTransition = transition.to(caca, {xScale = finalXScale, time=timeScaleX*1000, transition=easing.inCubic});
        caca.scaleYTransition = transition.to(caca, {yScale = finalYScale, time=timeScaleY*1000, transition=easing.inCubic});

        --Preparem el Timer que indiqui el final de la caiguda
        caca.fallingTimer = timer.performWithDelay(currentTimeFall*1000, caca.hit);

        --Afegim el projectil a la llista
        table.insert(cacas, caca);
    end

    --Informem de que s'ha produït el dispar
    --El flow de l'execució pot continuar fins que avisem de que el projectil ha impactat
    numTargetsAlive = numZombies;
    background.startDown();
    
    if numTargetsAlive == 0 then
        --No hi ha objectius vàlids
        --Iniciem el timer fins que el BG acabi de baixar
        timer.performWithDelay(timeFall*1000, finishGaviot);
    end
end

local function startGaviotFly (newTimeFall)
    --Hem arribat al punt més alt i volem que aparegui l'origen del projectil
    --Volem fer que l'ocell recorri la pantalla d'esquerra a dreta
    --Cal situar l'objecte a la posició més alta del background, fora de pla per l'esquerra
    local newWidth, newHeight = board:getTileSize();
    local scaleFactorPerImgW = newWidth / bird.contentWidth;
    local scaleFactorPerImgH = newHeight / bird.contentHeight;
    bird:scale(scaleFactorPerImgW, scaleFactorPerImgH);
    bird.x = -20;
    bird.y = -background.gaviotHeight + delta_birdY;
    bird.flyTrans = transition.to(bird, {time=WEAP_GAVIOT_BIRD_TIME_FLY, x=400, onComplete = function() bird:pause(); end });
    timeFall = newTimeFall;
    
    --Fem que l'ocell sigui visible
    bird.isVisible = true;
    bird:play();
    
    --Posem un timer per saber en quin moment l'ocell està en el punt central i "dispara"
    bird.shootTimer = timer.performWithDelay(WEAP_GAVIOT_BIRD_TIME_FLY/2, shoot);
end


-- FUNCIONS PÚBLIQUES ----------------------------------------------------------
function gaviot:startGaviot ()
    --Comença tot el procés de l'atac amb ocells
    gaviot.isGaviotOn = true;
    
    --Enviem la notificació al GamePlay per a informar de que ha iniciat el Gaviot
    Runtime:dispatchEvent({ name = GAMEPLAY_GAVIOT_START_EVNAME });
    
    --Fem la congel·lació dels zombies mentre duri l'atac
    --Obtenim també la llista d'objectius vàlids per a l'atac
    targetsInfo = board:startGaviot();
    
    --Iniciem el desplaçament del BG, indicant que es cridi a la funció d'inici del vol quan s'acabi l'ascens
    background.initGaviotAttack(startGaviotFly);
end

function gaviot:enterPause()
    --Entrem en mode Pause
    --Aturem tot el procés
    
    --Aturem el BG
    background.pauseGaviot(true);
    
    --Aturem els timers i transicions del mòdul
    bird.onPause(true);
    if timerToFinish ~= nil then timer.pause(timerToFinish); end
    for i = 1, #cacas, 1 do
        cacas[i].enterPause(true);
    end
end

function gaviot:exitPause()
    --Sortim del mode Pause
    --Reprenem el procés
    
    --Reprenem el BG
    background.pauseGaviot(false);
    
    --Reprenem els timers i transicions del mòdul
    bird.onPause(false);
    if timerToFinish ~= nil then timer.resume(timerToFinish); end
    for i = 1, #cacas, 1 do
        cacas[i].enterPause(false);
    end
end


-- INICIALITZACIÓ I DESTRUCCIÓ DEL MÒDUL ---------------------------------------
local function assertInitParams (params)
    --Comprovem que hem rebut tots els paràmetres
    local msg = "Tried to initialize the module without "
    AZ:assertParam(params, "Gaviot Init Error", msg .." params");
    AZ:assertParam(params.board, "Gaviot Init Error", msg .." board");
    AZ:assertParam(params.physics, "Gaviot Init Error", msg .." physics");
    AZ:assertParam(params.background, "Gaviot Init Error", msg .." background");
    AZ:assertParam(params.atlas, "Gaviot Init Error", msg .." atlas");
    AZ:assertParam(params.weaponsSS, "Gaviot Init Error", msg .." weaponsSS");
      
    return true;
end

function gaviot:init ( params )
    --Fem la comprovació de que tots els paràmetres són correctes
    assertInitParams(params);
    
    --Si hem arribat fins aquí és perquè tots els paràmetres són correctes
    board = params.board;
    physics = params.physics;
    background = params.background;
    _atlas = params.atlas;
    weaponsSS = params.weaponsSS;
    animInfo = AZ.animsLibrary.pigeonAnim();
    
    --Inicialitzem les propietats internes
    bird = display.newSprite(animInfo.imageSheet, animInfo.sequenceData)
    bird.isVisible = false;
    bird:pause();
    
    --Preparem les funcions privades
    bird.destroy = function()
        --Volem destruïr l'ocell
        bird.flyTrans = transition.safeCancel(bird.flyTrans);
        bird.shootTimer = timer.safeCancel(bird.shootTimer);
        
        --El·liminem tots els projectils que pugui tenir
        for i = 1, #cacas, 1 do
            cacas[i].destroy();
        end
    end
    
    bird.onPause = function(isPause)
        transition.safePauseResume(bird.flyTrans, isPause);
        timer.safePauseResume(bird.shootTimer, isPause);
        
        if isPause then
            bird:pause();
        else
            bird:play();
        end
    end
    
    --Insertem l'ocell en el grup de Background, per a fer que estigui sincronitzat
    background.group:insert(bird);
    
    return true;
end

-- Destruim el mòdul
function gaviot:destroy ()
    --El·liminem l'objecte gaviot
    if timerToFinish ~= nil then
        timer.cancel(timerToFinish);
    end
    
    --El·liminem el possible ocell que hi hagi
    bird.destroy();
    
    gaviot = nil
end

return gaviot;