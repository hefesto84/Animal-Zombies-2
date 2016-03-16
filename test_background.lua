-- Objecte principal que es retorna
local background = {}

-- Atributs de la classe
background.group = nil;
local physicsController = nil

--Variables de control
local imagesBG = nil;
local earthquakeHeight = 0; 
local pixelsInRebound = 0;
background.gaviotHeight = 0;

--Constants
local BG_LAUNCHGROUP_FACTORRELATION         = 0.5
local MAX_JUMP_TIME                         = 5;
local MAX_GAVIOT_TIME_UP                    = 2
local MAX_GAVIOT_TIME_DOWN                  = 3;




-- GESTIÓ DE TOUCH -------------------------------------------------------------
background.onTouch = function(event)
    background.onBGTouch.phase = event.phase
    background.onBGTouch.touchID = event.id
    background.onBGTouch.x, background.onBGTouch.y = event.x, event.y

    Runtime:dispatchEvent(background.onBGTouch)

    return true
end


-- GESTIÓ DE LA SIMULACIÓ DE FÍSIQUES PER A EARTHQUAKE -------------------------
background.initDespl = function(zombieFactor)
    --Iniciem un desplaçament per a simular la pujada i baixada dels zombies
    --Settejem tots els paràmetres estàtics necessaris
    background.initialY = background.group.y;
    background.transitionReturn = nil;

    --Settejem tots els paràmetres dinàmics necessaris utilitzant les dades rebudes
    local jumpHeight = background.computeLaunchHeight(zombieFactor);
    local jumpTime = background.computeLaunchTime(zombieFactor);
    physicsController.activateParabolic (background.group, jumpHeight, jumpTime);

    local extraTime = physicsController.getTimePerDistPixels(background.group, pixelsInRebound);
    return (jumpTime + extraTime) * 1000;
end

background.computeLaunchHeight = function (zombieFactor)
    --En funció de la quantitat de zombies que hi ha en el llençament, calcul·lem l'alçada
    --Està ponderat dins uns límits
    local halfJump = earthquakeHeight / 2;
    return halfJump * (1 + zombieFactor);
end

background.computeLaunchTime = function (zombieFactor)
    --En funció de la quantitat de zombies que hi ha en el llençament, calcul·lem el temps disponible
    --Està ponderat dins uns límits
    local halfTime = MAX_JUMP_TIME / 2;
    return halfTime * (1 + zombieFactor);
end

background.returnDespl = function(timeToReturn, finishFunction)
    --Aturem el comportament físic i retornem a la posició inicial
    physicsController.deactivateParabolic(background.group);
    background.transitionReturn = transition.to( background.group, { time=timeToReturn, y=background.initialY, transition=easing.inOutExpo, onComplete=finishFunction} );
end

background.update = function (isLaunching, currentZGroupDeltaY)
    --Cal actualitzar el background en funció del temps transcorregut i del desplaçament de "càmera" fet per ajustar el grup de Zombies
    --Només ho fem si estem en mode Launching
    if isLaunching == true then
        --Li passem el nou valor de desplaçament de càmera al mòdul de física
        --Apart del valor de caiguda lliure que tingui, aplicarà un petit ajust per adaptar-se a la càmera enfocant el zombie més baix
        physicsController.updateParabolicDeltaY(background.group, currentZGroupDeltaY*BG_LAUNCHGROUP_FACTORRELATION);
    end
end

background.pauseEarthquake = function (isPause)
    --Volem adaptar el comportament del BG en funció de l'estat de Pause per al procés de Gaviot
    if isPause then
        --Aturem timers i transicions
        if background.transitionReturn ~= nil then transition.pause(background.transitionReturn); end
        
    else 
        --Reprenem els timers i transicions
        if background.transitionReturn ~= nil then transition.resume(background.transitionReturn); end
    end
end


-- GESTIÓ DE LA SIMULACIÓ DE FÍSIQUES PER A GAVIOT -----------------------------
background.initGaviotAttack = function (startGaviotFly)
    --Iniciem les transicions del BG
    background.initialY = background.group.y;
    background.startGaviotFly = startGaviotFly;
    background.transitionGaviotUp = nil;
    background.timerGaviotDown = nil;

    local targetY = background.initialY + background.gaviotHeight;
    background.transitionGaviotUp = transition.to (background.group, {time=MAX_GAVIOT_TIME_UP*1000, y=targetY, transition=easing.linear, onComplete=background.finishUp});
end

background.finishUp = function()
    --El BG ha acabat de pujar
    --Informem de la situació al GamePlay. Passem com a parámetre el temps que tardarà el descens, per a sincronitzar elements
    background.startGaviotFly(MAX_GAVIOT_TIME_DOWN);
end

background.startDown = function()
    --Iniciem el descens
    local jumpHeight = background.gaviotHeight;
    local jumpTime = MAX_GAVIOT_TIME_DOWN;
    physicsController.activateFreeFall (background.group, jumpHeight, jumpTime);

    --Comencem el timer que indica el final de la caiguda
    local timeToFinish = MAX_GAVIOT_TIME_DOWN * 1000;
    background.timerGaviotDown = timer.performWithDelay(timeToFinish, background.finishDown);
end

background.finishDown = function()
    --Hem acabat el descens
    physicsController.deactivateFreeFall(background.group);

    --Per a garantir que està en posició correcta, posem el BG en la posició inicial
    background.group.y = background.initialY;
end

background.pauseGaviot = function (isPause)
    --Volem adaptar el comportament del BG en funció de l'estat de Pause per al procés de Gaviot
    if isPause then
        --Aturem timers i transicions
        if background.transitionGaviotUp ~= nil then transition.pause(background.transitionGaviotUp); end
        if background.timerGaviotDown ~= nil then timer.pause(background.timerGaviotDown); end
        
    else 
        --Reprenem els timers i transicions
        if background.transitionGaviotUp ~= nil then transition.resume(background.transitionGaviotUp); end
        if background.timerGaviotDown ~= nil then timer.resume(background.timerGaviotDown); end
    end
end
    

-- GESTIO DE GRUPS -------------------------------------------------------------
background.insertGroup = function(groupToAdd)
    background.group:insert(groupToAdd);   
end
    

-- INICIALITZACIÓ I DESTRUCCIÓ DEL MÒDUL ---------------------------------------
local function assertInitParams (params)
    --Comprovem que hem rebut tots els paràmetres
    local msg = "Tried to initialize the module without "
    AZ:assertParam(params, "Module Init Error", msg .." params");
    AZ:assertParam(params.onBGTouched, "Module Init Error", msg .." onBGTouched");
    AZ:assertParam(params.onDestroyBG, "Module Init Error", msg .." onDestroyBG");
    AZ:assertParam(params.bgInfo, "Module Init Error", msg .." bgInfo");
    
    return true;
end

local function setupEvents(bg, params)
    -- event que enviem al apretar el background
    bg.onBGTouch = { name = params.onBGTouched, id = 0, x = 0, y = 0, phase = "", touchID = nil, isTouchEnabled = false }
    
    -- event que cridaràn per a eliminar el background
    bg.onBGDestroy = params.onDestroyBG 
    
    -- event que enviem quan s'ha destruit el background satisfactoriament
    if params.onDestroySuccessBG ~= nil then
        bg.onBGDestroySuccess = { name = params.onDestroySuccessBG }
    end
    
    if params.physicsController ~= nil then
        physicsController = params.physicsController;
    end
    
end

function background:destroy()
    --Se'ns demana de destruïr el mòdul
    --Cancel·lem tots els timers i transicions que hi pugui haver
    if background == nil then return; end
    
    if background.transitionReturn ~= nil then
        transition.cancel(background.transitionReturn);
    end
    if background.transitionGaviotUp ~= nil then
        transition.cancel(background.transitionGaviotUp);
    end
    if background.timerGaviotDown ~= nil then
       timer.cancel(background.timerGaviotDown);
    end
    
    --El·liminem el grup del BG
    display.remove(background.group)

    imagesBG = nil;
    background = nil;
end

function background:init ( params )
    --Inicialitzem el mòdul amb els paràmetres necessàris
    --Fem la comprovació de que tots els paràmetres són correctes
    assertInitParams(params);
    
    --Si hem arribat fins aquí és perquè tots els paràmetres són correctes
    --Preparem els atributs
    background.group = display.newGroup();
    background.physicsController = physicsController;
    
    --Carreguem les imatges de BG
    imagesBG = display.newGroup();
    local propHeight = 0;
    local bgInfo = params.bgInfo;
    local numImgDown = #bgInfo.downImages;
    local numImgUp = #bgInfo.upImages;
    
    for i = 1, numImgDown, 1 do
        --Carreguem cadascuna de les imatges i l'apilem l'anterior
        local currentImgBG = display.newImage(bgInfo.downImages[i], true);
        local scaleFactorPerImg = display.contentWidth / currentImgBG.width;
        currentImgBG:scale(scaleFactorPerImg, scaleFactorPerImg);
        propHeight = display.contentHeight / currentImgBG.contentHeight;
        currentImgBG.anchorX, currentImgBG.anchorY = 0.5, 1
        currentImgBG.x = display.contentCenterX;
        currentImgBG.y = display.contentHeight + (i * currentImgBG.contentHeight);
        
        --Afegim la imatge al grup
        imagesBG:insert(currentImgBG);
    end
    
    for i = 1, numImgUp, 1 do
        --Carreguem cadascuna de les imatges i l'apilem l'anterior
        local currentImgBG = display.newImage(bgInfo.upImages[i], true);
        local scaleFactorPerImg = display.contentWidth / currentImgBG.width;
        currentImgBG:scale(scaleFactorPerImg, scaleFactorPerImg);
        propHeight = display.contentHeight / currentImgBG.contentHeight;
        currentImgBG.anchorX, currentImgBG.anchorY = 0.5, 1
        currentImgBG.x = display.contentCenterX;
        currentImgBG.y = display.contentHeight - ((i - 1) * currentImgBG.contentHeight);
        
        --Afegim el listener a cada imatge
        currentImgBG:addEventListener("touch", background.onTouch)
        
        --Afegim la imatge al grup
        imagesBG:insert(currentImgBG);
    end
    
    --Inicialitzem el grup Background
    --Desplacem el grup sencer per intentar que quedi tota la part del Terra visible
    --iphone4 : propHeight = 1.5 ----> 25px
    --iphone5 : propHeight = 1.775 --> 75px
    --Amb aquests dos punts establim la fòrmula matemàtica
    local desplToCenter = - (25 + (propHeight - 1.5)*(50 / 0.275));
    imagesBG.y = imagesBG.y + desplToCenter;
    
    --Calcul·lem les distàncies de desplaçament per al Terratrèmol i el Gaviot amb els tamanys de BG calcul·lats
    local heightPerImg = imagesBG[1].contentHeight;
    earthquakeHeight = (heightPerImg * numImgUp) - (display.contentHeight * 2) - desplToCenter
    pixelsInRebound = (heightPerImg * numImgDown) - (display.contentHeight * 0.5) + desplToCenter;
    background.gaviotHeight = (heightPerImg * numImgUp) - display.contentHeight - desplToCenter
    
    --Ultimem el grup
    background.initialY = background.group.y;
    background.group:insert(imagesBG);
 
    --Preparem els listeners i notificacions
    setupEvents(background, params);
    
    return true;
end

-- Retornem l'objecte principal
return background;