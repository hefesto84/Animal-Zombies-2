module(..., package.seeall)

-- requires
local _ui = nil
local _board = nil
local _zombie = nil
local _physicsController = nil
local _wController = nil
local _bg = nil
local _prop = nil
local _powerup = nil

local levelInfo = nil -- informacio del nivell actual

-- Variables de control
local fallingLollipops = nil        -- estadistiques d'spawneig de piruletes
local fallingPowerups = nil         -- estadistiques d'spawneig d'armes
local spawnPowerupAtQuantity = -1   -- número de zombie en el qual spawnejarà un powerup
local zombiesArray = nil            -- zombies que sortiran en el nivell
local waveZombiesArray = nil        -- zombies que sortiran en el last wave
local spawnQuantity = 0             -- quantitat de zombies a spawnejar
local waveSpawnQuantity = 0         -- quantitat de zombies a spawnejar en mode last wave
local spawnedZombies = 0            -- zombies apareguts
local currentZombiesInScreen = 0    -- zombies actualment en pantalla
local zPatterns = nil               -- patrons que sortiràn en el nivell [per ara no s'utilitza]
local currentPattern = 0            -- número de patró actual
local spawnPatternAtQuantity = 0    -- número de zombie en el qual es dispararà un patró
local zQuantityBetweenPatterns = -1 -- número de zombies que han de sortir entre cada patró
local maxZombiesPerScreen = 0       -- quantitat màxima de zombies alhora [varia amb el last wave]
local spawnProbability = 0          -- probabilitat d'spawneig de zombies [varia amb el last wave]

local lifes = 0

local isDisabled = false        -- s'ha deshabilitat per final de partida?
local isPause = false           -- estem en pausa?
local isLastWave = false        -- s'ha fet el last wave?
local prepareWaveTimerID = nil  -- timer del last wave
local lollipopTimerID = nil     -- timer d'spawneig de lollipop

function getBoardTouchEventName()
    return _board:getTouchEventName()
end

function getBoardModule()
    return _board
end
    
function getZombieModule()
    return _zombie
end

function getWeaponControllerModule()
    return _wController
end

function getKillPercent()
    return _zombie.getKillPercent()
end

----------------------------- WEAPON GETTER/SETTER -----------------------------
function getCurrentWeapon()
    return _wController.currentWeapon
end

function setNewWeapon(wName)
    return _wController:changeWeapon(wName)
end

------------------------------- UPDATE DE VIDES --------------------------------
local function spawnLollipop()
    if _powerup:canSpawnPowerUp() then
        Runtime:dispatchEvent({ name = GAMEPLAY_SPAWN_POWERUP, powerUpName = "lollipop" })
        lollipopTimerID = timer.safeCancel(lollipopTimerID)
    end
end

function updateLollipops(l)
    if not fallingLollipops then return end
    
    lifes = l
    
    if fallingLollipops[lifes] then
        local t = timer.safePause(lollipopTimerID)
        
        if t and t ~= 0 and t < fallingLollipops[lifes] then
            timer.safeResume(lollipopTimerID)
            --print("resum de lollipop ".. t)
        else
            lollipopTimerID = timer.safeCancel(lollipopTimerID)
            lollipopTimerID = timer.performWithDelay(fallingLollipops[lifes], spawnLollipop, -1)
            --print("disparem lollipop ".. fallingLollipops[lifes])
        end
    else
        lollipopTimerID = timer.safeCancel(lollipopTimerID)
    end    
end

------------------------------- GESTIÓ DEL TOUCH -------------------------------
local touchEventListener = function(event)
    
    -- activem i desactivem els botons segons si deixem o comencem a apretar, respectivament
    if _board.numTouchesActive == 1 and event.params.phase == "began" then
        _ui.activateDeactivateButtons(false, false)
    elseif _board.numTouchesActive == 0 then
        if event.params.phase == "ended" or event.params.phase == "cancelled" then
            _ui.activateDeactivateButtons(true, true, "previous")
        end
    end
    
    --Cedim el control al WeaponController
    _wController:handleTouch(event.params)
end


------------------------------ GESTIÓ D'SPAWNEIG -------------------------------
local function findZombieStats(zName)
    for i = 1, #levelInfo.zombies do
        if levelInfo.zombies[i].type == zName then
            return levelInfo.zombies[i]
        end
    end
    --print("", "", "zombie ".. zName .." not found in this level")
    return nil
end

local function createZombie(z)
    
    if type(z) == "string" then
        local zInfo = AZ.zombiesLibrary.getZombie(z)
        local zStats = findZombieStats(z)
        
        local hits, timeToAttack = 2, 2000
        
        if zStats then
            hits = math.random(zStats.minAttacks, zStats.maxAttacks)
            timeToAttack = math.random(zStats.minAttackSpeed, zStats.maxAttackSpeed)
        end
        
        return _zombie.createzombie({ zombieInfo = zInfo, hits = hits, timeToAttack = timeToAttack }, nil)
    else
        local info, tInfo = z.getSpawnInfo()
        return _zombie.createzombie(info, tInfo)
    end
end

local function getRandomZombie()
    
    local p = math.random(1, #zombiesArray)
    local z = zombiesArray[p]
    table.remove(zombiesArray, p)
    
    return z
end

local function spawnZombie()
    math.randomseed(system.getTimer())
    
    local z = getRandomZombie()
    
    local zombie = createZombie(z)
    if _board:addObject(zombie) then
        spawnedZombies = spawnedZombies + 1
    else
        table.insert(zombiesArray, z.type)
        display.remove(zombie)
        zombie = nil
    end
end

--------------------- GESTIÓ DE CEL·LES BUIDES -----------------------
local function updateBoardTiles(event)
    currentZombiesInScreen = _board:getNumZombies()
end

----------------------------- GESTIÓ DE LAST WAVE ------------------------------
function createWave()
    
    prepareWaveTimerID = timer.safeCancel(prepareWaveTimerID)
    
    al.Source(audio.getSourceFromChannel(1), al.PITCH, 1.3)
    
    currentPattern = 0
    if zPatterns ~= nil and zPatterns.lastWave ~= nil and #zPatterns.lastWave > 0 then
        zQuantityBetweenPatterns = math.floor(waveSpawnQuantity / (#zPatterns.lastWave +1))
        --print("disparem un patró amb ".. zQuantityBetweenPatterns)
    else
        zQuantityBetweenPatterns = -1
    end    
    spawnPatternAtQuantity = spawnQuantity + zQuantityBetweenPatterns
    --print("spawnPatternAtQuantity ".. spawnPatternAtQuantity)
    
    zombiesArray = waveZombiesArray
    spawnQuantity = spawnQuantity + waveSpawnQuantity
    
    maxZombiesPerScreen = maxZombiesPerScreen +1
    spawnProbability = spawnProbability *1.3
end

-------------------------------- UPDATE I PAUSA --------------------------------
function update()
    if not isPause and not isDisabled and not _wController:isWeaponBlockingSpawn() then
        
        if not isLastWave and _ui.getDisappearedZombies() == spawnQuantity and waveSpawnQuantity > 0 then
            isLastWave = true
            
            prepareWaveTimerID = timer.performWithDelay(1000, _ui.prepareWave)
        end
        
        -- spawnegem un powerup si toca
        if spawnedZombies == spawnPowerupAtQuantity then
            if _powerup:canSpawnPowerUp() then
				Runtime:dispatchEvent({ name = GAMEPLAY_SPAWN_POWERUP, powerUpName = fallingPowerups[1].name, amount = fallingPowerups[1].amount or 1 })
            end
            
            spawnPowerupAtQuantity = -1
            
            table.remove(fallingPowerups, 1)
            if #fallingPowerups > 0 then
                spawnPowerupAtQuantity = math.floor(spawnQuantity * fallingPowerups[1].percent *0.01)
				--print("next powerup spawn at ".. spawnPowerupAtQuantity)
            end
        end
        
        -- spawnegem un patró si toca
        if AZ.spawnPatterns and spawnedZombies == spawnPatternAtQuantity and ((not isLastWave and currentPattern < #zPatterns.regular) or (isLastWave and currentPattern < #zPatterns.lastWave)) then
            
            currentPattern = currentPattern +1
            
            local success, zIndexes = _board:addPattern(currentPattern, isLastWave)
            
            -- si hem pogut disparar el patró, encara que no s'hagi spawnejat cap zombie,
            -- acabem incrementant la pròxima quantitat per a disparar un nou patró i actualitzem variables de gestió
            if success then
                --print("patró llençat, zombies de patró : ".. #zIndexes ..". spawnedZombies: ".. spawnedZombies ..", spawnQuantity: ".. spawnQuantity)
                local zPatternSpawned = #zIndexes
                spawnPatternAtQuantity = spawnPatternAtQuantity + zPatternSpawned + zQuantityBetweenPatterns
                
				spawnedZombies = spawnedZombies + zPatternSpawned
				spawnPowerupAtQuantity = spawnPowerupAtQuantity + zPatternSpawned
				spawnQuantity = spawnQuantity + zPatternSpawned
				_ui.addMaxZombiesInLevel(zPatternSpawned)
				--print("actualitzat, proper powerup amb: ".. spawnPowerupAtQuantity ..". spawnedZombies: ".. spawnedZombies)
				--print("actualitzat, proper patró amb: ".. spawnPatternAtQuantity ..". spawnedZombies: ".. spawnedZombies ..", spawnQuantity: ".. spawnQuantity)
            end
            
            return
        end
        
        if spawnedZombies >= spawnQuantity or maxZombiesPerScreen <= currentZombiesInScreen then
            return
        end
        
        if math.random(0, 1000) <= levelInfo.zombieSpawnProbability and #zombiesArray > 0 then
            spawnZombie()
        end
    end
end

local function pauseGameplay(event)
    isPause = event.isPause
    
    _powerup:pause(isPause)
    
    timer.safePauseResume(lollipopTimerID, isPause)
    timer.safePauseResume(prepareWaveTimerID, isPause)
end

------------------------------ GESTIÓ DE POWERUPS ------------------------------
local function powerupHandler(event)
    
    if event.name == GAMEPLAY_SPAWN_POWERUP then
        local weapon = nil
        
        if event.powerUpName then
            if event.powerUpName == "lollipop" then
                weapon = { name = "lollipop", id = 11 }
            else
                weapon = _ui.getWeaponManager():getByName(event.powerUpName)
            end
        end
        
        if not weapon then
            weapon = _ui.getWeaponManager():getRandomWeapon()
        end
        
        _powerup:spawnPowerup(weapon.name, event.amount or 1, weapon.id, event.delay)
        
    elseif event.name == GAMEPLAY_POWERUP_GET then
        if event.powerUpName == "lollipop" then
			AZ.audio.playFX(AZ.soundLibrary.lollipopSound[2], AZ.audio.AUDIO_VOLUME_OTHER_FX)
            _ui.heal()
        else
            --_ui.updateWeaponQuantity(event.powerUpName, event.amount or 1)
            _ui.caughtPowerup(event.powerUpName, event.amount or 1)
            --_ui.setCurrentWeapon(event.powerUpName)
        end
        
    elseif event.name == GAMEPLAY_POWERUP_LOST then
        if event.powerUpName == "lollipop" then
            updateLollipops(lifes)
        end
    end
end

------------------------------- GESTIÓ DEL MODUL -------------------------------
local function disableGameplay()
    isDisabled = true
end

local function destroyGameplay()
    
    prepareWaveTimerID = timer.safeCancel(prepareWaveTimerID)
    
    _bg:destroy();
    _physicsController.destroy();
    _wController:destroy();
    _board:destroy();
    _zombie.destroy();
    _powerup:destroy();
    
    AZ.utils.unloadModule("test_physicsModule")
    _board = AZ.utils.unloadModule("test_board")
    _zombie = AZ.utils.unloadModule("test_zombie")
    _wController = AZ.utils.unloadModule("test_weaponController")
    _bg = AZ.utils.unloadModule("test_background")
    _powerup = AZ.utils.unloadModule("test_powerup")
    
    Runtime:removeEventListener(GAMEPLAY_SPAWN_POWERUP, powerupHandler)
    Runtime:removeEventListener(GAMEPLAY_POWERUP_GET, powerupHandler)
    Runtime:removeEventListener(GAMEPLAY_POWERUP_LOST, powerupHandler)
    Runtime:removeEventListener(GENERIC_TOUCH_EVNAME, touchEventListener)
    Runtime:removeEventListener(BOARD_UPDATE_TILES_EVNAME, updateBoardTiles)
    Runtime:removeEventListener(GAMEPLAY_PAUSE_EVNAME, pauseGameplay)
    Runtime:removeEventListener(GAMEPLAY_END_IS_NEAR_EVNAME, disableGameplay)
    Runtime:removeEventListener(ALL_DESTROY_EVNAME, destroyGameplay)
end

function initializeGameplay(scene, currentLevelInfo, stageInfo, ui, spriteSheet)
    
    local grp = display.newGroup()
    
----------------------------- SETEIG DE VARIABLES ------------------------------
    
    _ui = ui
    _powerup = require "test_powerup"
    _board = require "test_board"
    _zombie = require "test_zombie"
    _wController = require "test_weaponController"
    
    _powerup:init(spriteSheet)
    
    levelInfo = table.copyDictionary(currentLevelInfo.levelBalance)
    
    zombiesArray = levelInfo.zombiesArray
    waveZombiesArray = levelInfo.waveArray
    spawnQuantity = #zombiesArray
    waveSpawnQuantity = #waveZombiesArray
    
    fallingLollipops = levelInfo.lollipops
    fallingPowerups = levelInfo.powerups
    spawnPowerupAtQuantity = -1
    if fallingPowerups then
        spawnPowerupAtQuantity = math.floor(spawnQuantity * fallingPowerups[1].percent *0.01)
        --print("spawn powerup at ".. spawnPowerupAtQuantity)
    end
    
    zPatterns = currentLevelInfo.boardData.patternsInfo
    currentPattern = 0
    zQuantityBetweenPatterns = -1
    if zPatterns ~= nil and zPatterns.regular ~= nil and #zPatterns.regular > 0 then
        zQuantityBetweenPatterns = math.floor(spawnQuantity / (#zPatterns.regular +1))
        --print("hi ha ".. #zPatterns.regular .." patrons regulars i ".. spawnQuantity .." zombies en el nivell. Disparem un patró cada ".. zQuantityBetweenPatterns)
    else
        --print("no hi ha patrons")
    end    
    spawnPatternAtQuantity = zQuantityBetweenPatterns
    
    maxZombiesPerScreen = levelInfo.maxZombiesPerScreen
    spawnProbability = levelInfo.zombieSpawnProbability
    spawnedZombies = 0

    isDisabled = false
    isPause = false
    isLastWave = false
    prepareWaveTimerID = nil
    
------------------------------ PREPAREM LISTENERS ------------------------------

    Runtime:addEventListener(GAMEPLAY_SPAWN_POWERUP, powerupHandler)
    Runtime:addEventListener(GAMEPLAY_POWERUP_GET, powerupHandler)
    Runtime:addEventListener(GAMEPLAY_POWERUP_LOST, powerupHandler)
    Runtime:addEventListener(GENERIC_TOUCH_EVNAME, touchEventListener)
    Runtime:addEventListener(BOARD_UPDATE_TILES_EVNAME, updateBoardTiles)
    Runtime:addEventListener(GAMEPLAY_PAUSE_EVNAME, pauseGameplay)
    Runtime:addEventListener(GAMEPLAY_END_IS_NEAR_EVNAME, disableGameplay)
    Runtime:addEventListener(ALL_DESTROY_EVNAME, destroyGameplay)
    
---------------------- PRECÀRREGA DE ZOMBIES I ANIMACIONS ----------------------
    
    -- precarrega d'efectes
    local anims = AZ.animsLibrary
    
    anims.spawnAnim()
    anims.disappearAnim()
    anims.warningAnim()
    anims.biteAnim()
    anims.scratchAnim()
    
    -- precarrega de zombies del nivell actual
    for i=1, #levelInfo.zombies do
        AZ.zombiesLibrary.getZombie(levelInfo.zombies[i].type)
    end
    
-------------------- INICIALITZACIÓ DEL BACKGROUND I PHYSICS -------------------

    require "test_physicsModule";
    _physicsController = initPhysics()

    local bgData = --[["assets/fondolargo_pruebas03_marcasref02.jpg";]]stageInfo.bgData;
    _bg = require "test_background"
    _bg:init({    onBGTouched = _board:getTouchEventName(), 
                                onDestroyBG = ALL_DESTROY_EVNAME, 
                                bgInfo = bgData,
                                physicsController = _physicsController});

--------------------------- INICIALITZACIÓ DEL ZOMBIE --------------------------
    
    _zombie.initialize(_board, _ui, _bg)
    

----------------------- INICIALITZACIÓ DEL GESTOR D'ARMES ----------------------
    
    _wController:init({ scene = scene, ingameUI = _ui, board = _board, physics = _physicsController, bg = _bg, ui = _ui })
    
----------------------- INICIALITZACIÓ DEL GESTOR DE PROP ----------------------

    _prop = require "test_prop"
    _prop:init({ board = _board, background = _bg });
    
--------------------------- INICIALITZACIÓ DEL BOARD ---------------------------
    
    local bParams = {   onErrorBoard = GENERIC_ERROR,
                        onDestroyBoard = "foo",
                        onInitializedBoard = "foo",
                        createObjFunc = createZombie,
                        touchEventFunc = GENERIC_TOUCH_EVNAME,
                        updateVacancyFunc = BOARD_UPDATE_TILES_EVNAME,
                        enterPauseEvent = GAMEPLAY_PAUSE_EVNAME,
                        exitPauseEvent = "foo",
                        onTileDragEvent = OBJECT_DRAG_EVNAME,
                        onDestroyTile = ALL_DESTROY_EVNAME,
                        updateObjectEvent = OBJECT_UPDATE_ID_EVNAME,
                        finishObjectEvent = OBJECT_DESTROY_EVNAME,
                        physicsControllerObject = _physicsController,
                        backgroundControllerObject = _bg,
                        wController = _wController,
                        propControllerObject = _prop}

    if _board:init(bParams) then
        _board:load(currentLevelInfo.boardData, stageInfo.propData)
    end
    
    AZ.utils.changeGroup(_bg.group, grp);
    AZ.utils.changeGroup(_physicsController.group, grp);
            
    return grp
    
end