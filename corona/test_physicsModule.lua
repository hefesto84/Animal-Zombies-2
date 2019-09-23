-- Objeto principal que se retorna
local physicsModule = {}
local _sqrt = math.sqrt;

-- Path que concatenamos con los recursos
physicsModule.path = "resources/"

-- Grupo principal del módulo
physicsModule.group = display.newGroup();

--Creem els grups d'elements que requereixen, a cada frame, un tractament de simulació de física
physicsModule.physicObjects = {};
physicsModule.parabolicObjects = {};
physicsModule.shakeObjects = {};
physicsModule.originalGrpParent = {};

--Añadimos todo el control del mundo físico
physicsModule.physics = require "physics"
physicsModule._W = display.contentWidth;
physicsModule._H = display.contentHeight;
physicsModule.physics.start();
physicsModule.physics.setGravity(0,0);
--physicsModule.physics.setDrawMode( "hybrid" )

-- Variables de gestió de pausa
local isPaused = false;

--Creem els elements físics permanents en pantalla
--Són els límits de la pantalla, però simulant una pantalla el doble d'alta, per a fer que els elements puguin
--marxar per la part de dalt
physicsModule.ground = display.newRect(0, 0, physicsModule._W, 10);
physicsModule.ground.collType = "wall"
physicsModule.ground.isVisible = false;
physicsModule.ground.anchorX = 0;
physicsModule.ground.anchorY = 0;
physicsModule.ground.x = 0
physicsModule.ground.y = physicsModule._H;
physicsModule.physics.addBody(physicsModule.ground, "static", {friction = 0, bounce = .1});
physicsModule.group:insert(physicsModule.ground);

physicsModule.roof = display.newRect(0, 0, physicsModule._W, 10);
physicsModule.roof.collType = "wall"
physicsModule.roof.isVisible = false;
physicsModule.roof.anchorX = 0;
physicsModule.roof.anchorY = 0;
physicsModule.roof.x = 0
physicsModule.roof.y = -physicsModule._H;
physicsModule.physics.addBody(physicsModule.roof, "static", {friction = 0, bounce = .1});
physicsModule.group:insert(physicsModule.roof);

physicsModule.wallLeft = display.newRect(0, 0, 10, 2*physicsModule._H);
physicsModule.wallLeft.collType = "wall"
physicsModule.wallLeft.isVisible = false;
physicsModule.wallLeft.anchorX = 0;
physicsModule.wallLeft.anchorY = 0;
physicsModule.wallLeft.x = -10
physicsModule.wallLeft.y = -physicsModule._H;
physicsModule.physics.addBody(physicsModule.wallLeft, "static", {friction = 0, bounce = .1});
physicsModule.group:insert(physicsModule.wallLeft);

physicsModule.wallRight = display.newRect(0, 0, 10, 2*physicsModule._H);
physicsModule.wallRight.collType = "wall"
physicsModule.wallRight.isVisible = false;
physicsModule.wallRight.anchorX = 0;
physicsModule.wallRight.anchorY = 0;
physicsModule.wallRight.x = physicsModule._W - 1;
physicsModule.wallRight.y = -physicsModule._H;
physicsModule.physics.addBody(physicsModule.wallRight, "static", {friction = 0, bounce = .1});
physicsModule.group:insert(physicsModule.wallRight);

--
-- Definición de los listeners principales
--

physicsModule.onCreate = {
    name = "onCreatePhysicsModule",
}

physicsModule.onDestroy = {
    name = "onDestroyPhysicsModule",
}

physicsModule.onInitialized = {
    name = "onInitializedPhysicsModule",
}

physicsModule.onError = {
    name = "onErrorPhysicsModule",
}

-- LISTENERS -------------------------------------------------------------------
local pausePlayBoard = function (event)
    --Actualitzem l'estat del Pause general
    isPaused = event.isPause;
    
    --Actualitzem el comportament del mòdul físic
    if isPaused then
        physicsModule.physics.pause();
    else
        physicsModule.physics.start();
        
        --En el moment en que sortim de la pausa, actualitzem el LastUpdateTimer dels objectes per a ignorar el temps en que ha estat pausat
        for object, _ in pairs(physicsModule.parabolicObjects) do
            object.PhysicsModuleLastUpdateTimer = system.getTimer();
        end
    end
end

physicsModule.update = function(self, event)
    --A cada frame cal que actualitzem l'estat dels elements que simulen física
    --Els elements que ho fan amb el motor de física integrat no ho necessiten 
    if not isPaused then
        for object, _ in pairs(physicsModule.parabolicObjects) do

            local deltaTime = (system.getTimer() - object.PhysicsModuleLastUpdateTimer) / 1000;
            object.PhysicsModuleTotalTimeElapsed = object.PhysicsModuleTotalTimeElapsed + deltaTime;
            object.PhysicsModuleLastUpdateTimer = system.getTimer();
            
            local initialPosY = object.PhysicsModuleInitialPosY;
            local initialVelY = object.PhysicsModuleInitialVelY;
            local accelerationY = object.PhysicsModuleAccelerationY;
            local timeElapsed = object.PhysicsModuleTotalTimeElapsed;

            local desiredY = physicsModule.getCurrentYParab(timeElapsed, initialPosY, initialVelY, accelerationY);
            local realY = desiredY + object.PhysicsModuleDeltaY;
            object.y = realY;
        end

        --Fem el tractament dels objectes de Shaking
        --Si encara els queden frames pendents, efectuem el sacceig
        for object, _ in pairs(physicsModule.shakeObjects) do
            local numFramesPending = object.PhysicsModuleShakeFramesPending;
            --Comprovem si encara hi ha frames pendents per a saccejar
            if numFramesPending > 0 then
                --Queden frames pendents
                local shake = math.random(numFramesPending);    
                object.x = object.PhysicsModuleShakeOriginalX + math.random( -shake, shake )
                object.y = object.PhysicsModuleShakeOriginalY + math.random( -shake, shake )

                --Decrementem el comptador
                object.PhysicsModuleShakeFramesPending = numFramesPending - 1;
            end

            --Comprovem si ja hem acabat el procés
            if object.PhysicsModuleShakeFramesPending <= 0 then
                --Hem acabat tot el procés
                --Situem l'objecte en el punt original
                object.x = object.PhysicsModuleShakeOriginalX;
                object.y = object.PhysicsModuleShakeOriginalY;

                --Cridem a la funció de retorn
                if object.PhysicsModuleShakeReturnFunc ~= nil then
                    object.PhysicsModuleShakeReturnFunc();
                end

                --Treiem l'objecte de la llista
                physicsModule.shakeObjects[object] = nil;
            end
        end
    end
end

-- Añadimos los listeners básicos al módulo
physicsModule.addEventListeners = function( params )
    Runtime:addEventListener("onCreatePhysicsModule",params.onCreatePhysicsModule)
    Runtime:addEventListener("onDestroyPhysicsModule",params.onDestroyPhysicsModule)
    Runtime:addEventListener("onInitializedPhysicsModule",params.onInitializedPhysicsModule)
    Runtime:addEventListener("onErrorPhysicsModule",params.onErrorPhysicsModule)
end


-- FUNCIONS PÚBLIQUES ----------------------------------------------------------
physicsModule.activateGravity = function()
    --Activem la gravetat 
    physicsModule.physics.setGravity(0,9.8);
end

physicsModule.deactivateGravity = function()
    --Desactivem la gravetat
    physicsModule.physics.setGravity(0,0);
end

physicsModule.makeObjectPhysic = function (object)
    --Volem afegir l'objecte al context físic
    --Comprovem que no hi sigui ja
    if physicsModule.physicObjects[object] == nil then
        --L'object encara no és físic
        --Assignem el nou parent Group
        local originalParentGroup = object.parent;
        physicsModule.originalGrpParent[object] = originalParentGroup;
        AZ.utils.changeGroup(object, physicsModule.group);
        
        --L'afegim al context físic
        local size = 35;
        
        --local currentShape = { -size,-size, size,-size, size,size, -size,size }
        --physicsModule.physics.addBody(object, {friction = 0, bounce = 0.7, shape = currentShape});
        physicsModule.physics.addBody(object, {friction = 0, bounce = .5, radius=size});
        
        --Afegim el Listener per a control·lar les col·lisions
        object:addEventListener("preCollision", physicsModule);

        --Afegim l'objecte a la llista d'objectes físics
        physicsModule.physicObjects[object] = true;
        
    else
        --L'objecte ja era físic
        print("L'objecte que volem tornar físic ja ho era");
    end
end

physicsModule.applyRndForce = function (object)
    --Apliquem una força aleatoria a l'objecte
    if physicsModule.physicObjects[object] ~= nil then
        --Calcul·lem la força aplicada
        local rndx = ((math.random() * 2) - 1) * 20; --  20 * aleatori entre -1 i 1
        --local rndy = ((math.random() * 0.5) + 0.5) * -20; --  -20 * aleatori entre 0.5 i 1
        --local rndy = ((math.random() * 2) - 1) * -20;     --  -20 * aleatori entre -1 i 1
        local rndy = (math.random() * 0.5) * -20;           --  -20 * aleatori entre 0 i 0.5

        --Calcul·lem la distància al centre de la imatge on aplicarem la força
        local rndcentx = math.random(-1, 1) * 5;
        local rndcenty = math.random(-1, 1) * 5;
        
        --Apliquem la força
        object:applyForce(rndx, rndy, object.x + rndcentx, object.y + rndcenty); 
    else
        --L'objecte no és físic
        print("L'objecte al que volem aplicar la força no és físic");
    end
end

physicsModule.preCollision = function (self, event)
    --Fem un control de les col·lisions
    --Si la col·lisió no es deu a un xoc amb els murs, la ignorem
    local collideObject = event.other
    if collideObject.collType ~= "wall" then
        event.contact.isEnabled = false
    end
end

physicsModule.undoObjectPhysic = function  (object)
    --Treiem l'objecte al context físic si ho era
    if physicsModule.physicObjects[object] ~= nil then
        --L'objecte és físic
        --Desactivem la física
        physicsModule.physics.removeBody(object);
        
        --Treiem l'objecte de la llista
        physicsModule.physicObjects[object] = nil;
        
        --Li tornem a assignar el seu parent original
        AZ.utils.changeGroup(object, physicsModule.originalGrpParent[object])
    end
end

physicsModule.activateParabolic = function (object, maxHeight, fullTime)
    --Volem donar a l'objecte "object" el comportament de simulació d'un tir parabòlic
    --Calcul·lem els paràmetres físics necessaris i els afegim com a atributs de l'objecte
    object.PhysicsModuleTimeInitial = system.getTimer();
    object.PhysicsModuleInitialPosY = object.y;
    object.PhysicsModuleAccelerationY = physicsModule.computeAcceleration(maxHeight, fullTime/2);
    object.PhysicsModuleInitialVelY = physicsModule.computeInitialVel(maxHeight, object.PhysicsModuleAccelerationY);
    object.PhysicsModuleDeltaY = 0;
    
    object.PhysicsModuleTotalTimeElapsed = 0;
    object.PhysicsModuleLastUpdateTimer = system.getTimer();
    
    --Afegim l'objecte a la llista
    physicsModule.parabolicObjects[object] = true;
end

physicsModule.activateFreeFall = function (object, maxHeight, fallTime)
    --Volem donar a l'objecte "object" el comportament de simulació de caiguda lliure
    --Calcul·lem els paràmetres físics necessaris i els afegim com a atributs de l'objecte
    object.PhysicsModuleTimeInitial = system.getTimer();
    object.PhysicsModuleInitialPosY = object.y;
    object.PhysicsModuleAccelerationY = physicsModule.computeAcceleration(maxHeight, fallTime);
    object.PhysicsModuleInitialVelY = 0;
    object.PhysicsModuleDeltaY = 0;
    
    object.PhysicsModuleTotalTimeElapsed = 0;
    object.PhysicsModuleLastUpdateTimer = system.getTimer();
    
    --Afegim l'objecte a la llista
    physicsModule.parabolicObjects[object] = true;
end

physicsModule.updateParabolicDeltaY = function (object, newDeltaY)
    --Actualitzem el valor que volem aplicar de DeltaY a l'objecte "object"
    if physicsModule.parabolicObjects[object] ~= nil then 
        --L'objecte és vàlid
        object.PhysicsModuleDeltaY = newDeltaY;
    else
        --L'objecte no és vàlid
        print("L'objecte al que volem settejar DeltaY no és vàlid");
    end
end

physicsModule.deactivateParabolic = function (object)
    --Volem treure el comportament de tir parabòlic de l'objecte "object"
    physicsModule.parabolicObjects[object] = nil;
end

physicsModule.deactivateFreeFall = function (object)
    --Volem treure el comportament de caiguda lliure (tir parabòlic) de l'objecte "object"
    physicsModule.parabolicObjects[object] = nil;
end

physicsModule.computeAcceleration = function (maxHeight, timeUp)
    --En funció de l'alçada a la que volem arribar i del temps disponible, retornem l'acceleració
    return -(2 * maxHeight) / (timeUp * timeUp);
end

physicsModule.computeInitialVel = function (maxHeight, acceleration)
    --En funció de l'alçada a la que volem arribar i l'acceleració del món, calcul·lem la velocitat
    return _sqrt(2 * -acceleration * maxHeight);
end

physicsModule.getCurrentYParab = function (timeElapsed, initialPosY, initialVelY, accelerationY)
    --En funció del temps transcorregut, calcul·lem la posició del Background
    local currentPos = initialPosY + (initialVelY * timeElapsed) + (0.5 * accelerationY * timeElapsed * timeElapsed);
    return currentPos;
end

physicsModule.getTimePerDistPixels = function (object, pixels)
    --Indicant la distancia que volem recórrer extra a la caiguda, retornem el temps que transcorrerà
    local t = 0;
    if physicsModule.parabolicObjects[object] ~= nil then
        --L'objecte està settejat per a moviment parabòlic
        local acceleration = object.PhysicsModuleAccelerationY;
        local initialVel = object.PhysicsModuleInitialVelY;
        
        local a = acceleration * 0.5;
        local b = initialVel;
        local c = -pixels;

        t = (-b + _sqrt((b*b) - 4 * a * c)) / (2 * a);
    else 
        --L'objecte no està preparat per a moviment parabòlic
        print("L'objecte actual no està preparat per obtindre el temps per pixels. No té comportament parabòlic");
    end
    
    return t;
end   

physicsModule.initShake = function (object, numFrames, returnFunc)
    --Volem simular un sacceig de l'objecte durant numFrames frames
    --Settegem els atributs necessaris
    object.PhysicsModuleShakeFramesPending = numFrames;
    object.PhysicsModuleShakeOriginalX = object.x;
    object.PhysicsModuleShakeOriginalY = object.y;
    object.PhysicsModuleShakeReturnFunc = returnFunc;
    
    --Afegim l'objecte a la llista corresponent
    physicsModule.shakeObjects[object] = true;
end

 
-- INIT I DESTROY --------------------------------------------------------------
physicsModule.destroy = function()
    -- Cancel·lem els events
    Runtime:removeEventListener("enterFrame", physicsModule.update);
    Runtime:removeEventListener(GAMEPLAY_PAUSE_EVNAME, pausePlayBoard);
    
    -- Borramos el contenido del grupo de physicsModule
    display.remove(physicsModule.group);
    
    -- Lanzamos un evento para confirmar la destrucción del objeto
    Runtime:dispatchEvent(physicsModule.onDestroy);
end
 
function initPhysics ( params )
    --Iniciem la captura l'events
    Runtime:addEventListener("enterFrame", physicsModule.update);
    Runtime:addEventListener(GAMEPLAY_PAUSE_EVNAME, pausePlayBoard);
        
    return physicsModule
end