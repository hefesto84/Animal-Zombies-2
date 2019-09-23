module(..., package.seeall)

local _board
local _ingameUI

local touchEventName, setBoardIdEventName, setDrag, killWhenEarthquakeEventName, finishEarthquakeEventName, stinkBombEventName, pauseEventName, disableEventName, killEventName, destroyEventName

local justKilledEventName, finishDeadAnimEventName, justEscapingEventName, finishEscapeAnimEventName, finishAppearAnimEventName, justDamagedEventName, justExplosionEventName

local killedZombies, killedKindly, escapedZombies, zombieAttacks, killerZombie

local fullBodySS = nil
local numRatPlaguesAvailable = RAT_NUM_PLAGUES

function getStatistics()
    return killedZombies, killedKindly, escapedZombies, zombieAttacks, killerZombie
end

-- events inclou touchEvent, changeBoardIdEvent, destroyZombieEvent,
-- killWhenEarthquakeEvent, finishEarthquakeEvent, stinkBombEvent, pauseEvent,
-- disableEvent i killEvent
function initialize(gameplayBoard, UI)
    
------------------- COMPROVEM QUE TENIM TOTS ELS PARÀMETRES --------------------
    local msg = "Tried to initialize the zombie module without "
    AZ:assertParam(gameplayBoard,   "Init Zombie Error",    msg .."gameplayBoard")
    AZ:assertParam(UI,              "Init Zombie Error",    msg .."UI")
--------------------------------------------------------------------------------

    killedZombies, killedKindly, escapedZombies, zombieAttacks = 0, 0, 0, 0
    killerZombie = "none"
    
    _board       = gameplayBoard
    _ingameUI    = UI
    
    touchEventName =                OBJECT_TOUCH_EVNAME
    setBoardIdEventName =           OBJECT_UPDATE_ID_EVNAME
    setDrag =                       OBJECT_DRAG_EVNAME
    destroyEventName =              OBJECT_DESTROY_EVNAME
    killWhenEarthquakeEventName =   GAMEPLAY_EARTHQUAKE_KILL_IN_AIR_EVNAME
    finishEarthquakeEventName =     GAMEPLAY_EARTQUAKE_FINISH_LAUNCH_EVNAME
    stinkBombEventName =            GAMEPLAY_STINKBOMB_KILL_RATS_EVNAME
    pauseEventName =                GAMEPLAY_PAUSE_EVNAME
    disableEventName =              GAMEPLAY_END_IS_NEAR_EVNAME
    killEventName =                 OBJECT_KILLED_BY_STONE_EVNAME
    --killedByStoneEventName =        OBJECT_KILL_EVNAME
    --killedByHoseEventName =         OBJECT_KILL_EVNAME
    
    justKilledEventName =       OBJECT_JUST_KILLED_EVNAME
    finishDeadAnimEventName =   OBJECT_FINISH_DEAD_ANIM_EVNAME
    justEscapingEventName =     OBJECT_JUST_ESCAPING_ANIM_EVNAME
    finishEscapeAnimEventName = OBJECT_FINISH_ESCAPE_ANIM_EVNAME
    finishAppearAnimEventName = OBJECT_FINISH_SPAWN_ANIM_EVNAME
    justDamagedEventName =      OBJECT_DAMAGED_EVNAME
    justExplosionEventName =    GAMEPLAY_EXPLOSION_EVNAME
    
    local _atlas = require "test_atlas"
    fullBodySS = graphics.newImageSheet("assets/SpriteSheets/zombiesFull.png", _atlas:getSheet())
    _atlas = AZ.utils.unloadModule("test_atlas")
end

-- params inclou zombieInfo, hits i timeToAttack
-- tipParams inclou endFunc (i killEnabled)
function createzombie(params, tipParams)
    
    local function randomFlip(sprite)
        if math.random(2) == 1 then
            sprite.xScale = -sprite.xScale
            sprite.isFlipped = not sprite.isFlipped
        end
    end
    
    local function isKillAnim(anim)
        return string.find(anim, "kill") ~= nil
    end
    
    local zombieAnim = table.copyDictionary(params.zombieInfo.anim)
    
    local randomAnimSpeed = math.random(90, 110) *0.01
    for i = 1, #zombieAnim.sequenceData do
        if string.find(zombieAnim.sequenceData[i].name, "kill") == nil and zombieAnim.sequenceData[i].name ~= "mushroom" then
            zombieAnim.sequenceData[i].time = zombieAnim.sequenceData[i].time * randomAnimSpeed
        end    
    end
    
    local zombie = display.newSprite(zombieAnim.imageSheet, zombieAnim.sequenceData)
    zombie.isVisible = false

    -- Creem variables
    zombie.objType              = BOARD_OBJECT_TYPES.ZOMBIE
    zombie.boardID              = nil
    zombie.zType                = params.zombieInfo.type
    zombie.life                 = params.zombieInfo.lifes
    zombie.behaviour            = params.zombieInfo.behaviour
    zombie.fullSizeIndex        = params.zombieInfo.fullSizeIndex
    zombie.wResistant           = params.zombieInfo.wResistant
    zombie.sound                = params.zombieInfo.sound
    zombie.isKillEnabled        = true
    zombie.isTipZombie          = tipParams ~= nil
    zombie.isLogicFreezed       = false
    zombie.isAnimFreezed        = false
    zombie.attackTime           = params.timeToAttack
    zombie.isFlipped            = false
    zombie.damagedTimer         = nil
    zombie.disappearTransID     = nil
    zombie.isLaunched           = false
    zombie.isHoseTarget         = false
    zombie.isIceTarget          = false
    zombie.isDragging           = false
    zombie.fullBodyImg          = nil
    zombie.isRatFromPlague      = false
    zombie.possumTargetID       = 0
    zombie.eatTimer             = nil
    
    
    if zombie.behaviour == AZ.zombiesLibrary.ZOMBIE_BEHAVIOUR_KINDLY then
        zombie.hits = 0
    else
        zombie.hits = params.hits
    end
    
    if zombie.zType == AZ.zombiesLibrary.ZOMBIE_PIG_NAME then
        zombie.attackTime = 1
    end
    
    zombie.setFlip = function (isFlipped)
        --Assignem una orientació en X per al Zombie
        if (zombie.isFlipped and not isFlipped) or (not zombie.isFlipped and isFlipped) then
            --El Zombie es troba invertit respecte el que volem
            zombie.xScale = -zombie.xScale
            zombie.fullBodyImg.xScale = zombie.xScale
        end
        zombie.isFlipped = isFlipped
    end
    
    zombie.isZombieVisible = function()
        return zombie.isVisible or zombie.fullBodyImg.isVisible
    end
    
    zombie.setFullBodyState = function (isFBVisible)
        --Assignem si volem que es visualitzi el cos sencer del Zombie o la animació standart
        zombie.isVisible = not isFBVisible
        zombie.fullBodyImg.isVisible = isFBVisible
    end
    
    zombie.isWeaponResistant = function(wName)
        for i = 1, #zombie.wResistant do
            if zombie.wResistant[i] == wName then
                --print("l'arma ".. wName .." no afecta al ".. zombie.zType)
                return true
            end
        end
        --print("l'arma ".. wName .." si afecta al ".. zombie.zType)
        return false
    end
    
    zombie.isEscaping = function()
        return zombie.sequence == "hide"
    end
    
    zombie.damageFadeOut = function()
        zombie:setFillColor(1, 1, 1)
        zombie.fullBodyImg:setFillColor(1, 1, 1)
        
        zombie.damagedTimer = timer.safeCancel(zombie.damagedTimer)
    end
    
    zombie.getSpawnInfo = function()
        local tParams = nil
        if zombie.isTipZombie then
            tParams = { endFunc = zombie.tipCallBack, killEnabled = zombie.isKillEnabled }
        end
        
        return { zombieInfo  = params.zombieInfo, hits = zombie.hits, timeToAttack = zombie.attackTime }, tParams
    end
    
    zombie.showDamage = function(hasBeenDamaged)
        if hasBeenDamaged == true then
            zombie.damagedTimer = timer.safeCancel(zombie.damagedTimer)
            zombie.damagedTimer = timer.performWithDelay(150, zombie.damageFadeOut)
        end
        
        if zombie.damagedTimer ~= nil then
            zombie:setFillColor(AZ.utils.getColor({ 255, INGAME_SPAWN_SCORE_COLOR[2], INGAME_SPAWN_SCORE_COLOR[3] }))
            zombie.fullBodyImg:setFillColor(AZ.utils.getColor({ 255, INGAME_SPAWN_SCORE_COLOR[2], INGAME_SPAWN_SCORE_COLOR[3] }))
        end
    end
    
    zombie.disableZombie = function()
        zombie.isKillEnabled = false
        zombie.exitZombie()
    end
    
    zombie.finishZombie = function()
        
        zombie.timerID = timer.safeCancel(zombie.timerID)
        zombie.disappearTransID = transition.safeCancel(zombie.disappearTransID)
        
        Runtime:removeEventListener(pauseEventName, zombie.pauseByEvent)
        Runtime:removeEventListener(disableEventName, zombie.disableZombie)
        Runtime:removeEventListener(stinkBombEventName, zombie.killByStinkBomb)
        
        zombie = nil
    end
    
    zombie.spawnScore = function(score, breakCombo)
        
        local view = display.getCurrentStage()
        local nx, ny = zombie:localToContent(view.x, view.y)
        _ingameUI.addScore(score, nx, ny, breakCombo)
    end
    
    zombie.isTipCallBack = function(action)
        if zombie.tipCallBack ~= nil and zombie.callAtAction == action then
            zombie.tipCallBack(zombie)
            
            return true
        end
        
        return false
    end
	
    zombie.exitZombie = function()
        if zombie.sequence == "hide" or zombie.sequence == "mushroom" or isKillAnim(zombie.sequence) == true or zombie.dontHide ~= nil then
            return
        end
        
        zombie.timerID = timer.safeCancel(zombie.timerID)
        
        local disappearAnim = AZ.animsLibrary.disappearAnim()
        zombie.exitAnim = display.newSprite(disappearAnim.imageSheet, disappearAnim.sequenceData)
        zombie.exitAnim:scale(2, 2) --ZOMBIE_EFF_SCALE, ZOMBIE_EFF_SCALE)
        randomFlip(zombie.exitAnim)

        -- enviem notificació de que el zombie comença a escapar
        -- comentario patrocinado por Gordiflu Productions sl
        Runtime:dispatchEvent({ name = justEscapingEventName, boardID = zombie.boardID })

        zombie.exitAnim.destroyEffect = function()
            _board:delObjectAtPositionAtLayer(zombie.boardID, "exitEff")
            zombie.exitAnim = nil
        end

        zombie.exitAnim.disappearZombie = function()
            zombie.isVisible = false
            zombie.exitAnim:setSequence("disappear2")
            zombie.exitAnim:play()
            
            escapedZombies = escapedZombies +1
        end

        zombie.exitAnim.animListener = function(event)
            if event.phase == "ended" and zombie ~= nil and zombie.exitAnim ~= nil then
                if zombie.exitAnim.sequence == "disappear1" then
                    zombie.exitAnim.disappearZombie()
                else
                    zombie.exitAnim.destroyEffect()
                    
                    if zombie.life > 0 then
                        
                        if zombie.isTipCallBack("exit") == false then
                            zombie.spawnScore(0, zombie.behaviour ~= AZ.zombiesLibrary.ZOMBIE_BEHAVIOUR_KINDLY)
                        end
                        
                        --Enviem un event de que el Zombie ha acabat de marxar
                        Runtime:dispatchEvent({ name = finishEscapeAnimEventName, boardID = zombie.boardID })
                    end
                end
            end
        end
        
        AZ.audio.playFX(AZ.soundLibrary.disappearSound, AZ.audio.AUDIO_VOLUME_ZOMBIE_FX)
        
        _board:addObjectAtPositionAtLayer(zombie.exitAnim, zombie.boardID, "exitEff")
          
        zombie:setSequence("hide")
        zombie.showDamage(false)
        zombie:play()
        zombie.exitAnim:setSequence("disappear1")
        zombie.exitAnim:play()
        zombie.exitAnim:addEventListener("sprite", zombie.exitAnim.animListener)
    end
	
    zombie.killZombie = function(how)
    
        if isKillAnim(zombie.sequence) or zombie.sequence == "mushroom" then
            return
        end
        
        --Actualitzem l'estat
        zombie.freezeZombie(false, false)
        zombie.timerID = timer.safeCancel(zombie.timerID)
        zombie.possumCancelEat()
        --zombie.isVisible = true
        zombie.isLaunched = false
        zombie.setFullBodyState(false)
        
        --Enviem la notificació de que el Zombie acaba de morir
        Runtime:dispatchEvent({ name = justKilledEventName, boardID = zombie.boardID })

        local function destroyAnim(anim)
            if anim ~= nil then
                anim.destroyEffect()
            end
        end
        destroyAnim(zombie.spawnAnim)
        destroyAnim(zombie.warningAnim)
        destroyAnim(zombie.attackAnim)
        destroyAnim(zombie.exitAnim)
        
        AZ.audio.playFX(zombie.sound[math.random(#zombie.sound)], AZ.audio.AUDIO_VOLUME_ZOMBIES)
        zombie.killedBy = how
        
        if zombie.behaviour == AZ.zombiesLibrary.ZOMBIE_BEHAVIOUR_KINDLY then
            killedKindly = killedKindly +1
            
            if how == "trap" then
                zombie.setFullBodyState(true)
                zombie.disappearTransID = transition.to(zombie.fullBodyImg, { time = 200, alpha = 0, onComplete = function() Runtime:dispatchEvent({ name = finishDeadAnimEventName, boardID = zombie.boardID }) end })
            else
                zombie:setSequence("kill")
            end
            
            if _ingameUI.damage(1, zombie.zType) then
                killerZombie = zombie.zType
                zombie.dontHide = true
            end
            
            if zombie.isTipCallBack("kill") == false then
                zombie.spawnScore(0, true)
            end
        else
            killedZombies = killedZombies +1
            
            zombie:setSequence("kill".. tostring(math.random(1, 2)))
            
            AZ.audio.playFX(AZ.soundLibrary.bloodSound[math.random(#AZ.soundLibrary.bloodSound)], AZ.audio.AUDIO_VOLUME_OTHER_FX)
            zombie:scale(1.5, 1.5) --ZOMBIE_DEATH_SCALE, ZOMBIE_DEATH_SCALE)
            randomFlip(zombie)
            
            if zombie.isTipCallBack("kill") == false then
                zombie.spawnScore(SCORE_DEATHS, false)
            end
        end
        
        zombie:play()
    end
    
    zombie.damage = function(amount, how)
        if amount < 1 then
            return false
        end
        
        local isDraggableSaved = zombie.isDragging and (how == EXPLOSION_PIG_NAME or how == EXPLOSION_SKUNK_NAME or how == STINK_BOMB_NAME)
        local isResistant = zombie.isWeaponResistant(how)
        
        local canBeDamaged = isKillAnim(zombie.sequence) == false and 
                            zombie.sequence ~= "mushroom" and 
                            zombie.isZombieVisible() and 
                            zombie.life > 0 and 
                            zombie.isKillEnabled and 
                            not isDraggableSaved and
                            not isResistant
        
        if canBeDamaged then
            zombie.life = zombie.life - amount
            
            --Notifiquem que el zombie acaba de rebre dany
            Runtime:dispatchEvent({ name = justDamagedEventName, boardID = zombie.boardID })
            
            if zombie.life < 1 then
                zombie.killZombie(how)
                return true
            else
                zombie.showDamage(true)
                AZ.audio.playFX(AZ.soundLibrary.hitSound, AZ.audio.AUDIO_VOLUME_ZOMBIES)
                return false
            end
        end
        
        return true
    end
    
    zombie.takeDamage = function(params)
        
         local dmg = params.damage or 1
         if dmg == -1 then
            dmg = zombie.life
         end
                
         return zombie.damage(dmg, params.how or "shovel")
    end
    
    zombie.explode = function()
        
        zombie.life = 0
        
        zombie:setSequence("mushroom")
        zombie:play()
        zombie:scale(1.5, 1.5)
        --zombie:scale(ZOMBIE_EFF_SCALE + SCALE_BIG, ZOMBIE_EFF_SCALE + SCALE_BIG)
        randomFlip(zombie)
        if zombie.isFlipped == true then
            zombie.x, zombie.y = zombie.x + (10 * ZOMBIE_SCALE), zombie.y - (20 * ZOMBIE_SCALE)
        else
            zombie.x, zombie.y = zombie.x - (10 * ZOMBIE_SCALE), zombie.y - (20 * ZOMBIE_SCALE)
        end
        
        AZ.audio.playFX(AZ.soundLibrary.mushroomSound, AZ.audio.AUDIO_VOLUME_ZOMBIE_FX)
        
        --Enviem una notificació a tots els zombies del voltant per a fer-lo mal
        local zArray = _board:findIndexesAround(zombie.boardID, 3, 1, 3)
        for i = 1, #zArray[1] do
            _board:getObjectAtPosition(zArray[1][i]):dispatchEvent({ name = touchEventName, damage = 3, how = EXPLOSION_PIG_NAME })
        end
        
        --Enviem una notificació per a informar de tots els Tiles afectats
        zArray = _board:findIndexesAround(zombie.boardID, 3, 1, 1)
        Runtime:dispatchEvent({ name = justExplosionEventName, indexs = zArray[1]})
    end
	
    zombie.attack = function()
        local attackInfo = zombieAnim.attacks[math.random(#zombieAnim.attacks)]
        zombie.attackAnim = display.newSprite(attackInfo.imageSheet, attackInfo.sequenceData)
        zombie.attackAnim:scale(2, 2)--ZOMBIE_EFF_SCALE, ZOMBIE_EFF_SCALE)
        randomFlip(zombie.attackAnim)
            
        zombie.attackAnim.destroyEffect = function()
            _board:delObjectAtPositionAtLayer(zombie.boardID, "attackEff")
            zombie.attackAnim = nil
            
            zombie.isTipCallBack("attack")
        end
                
        zombie.attackAnim.animListener = function(event)
            if event.phase == "ended" and zombie ~= nil and zombie.attackAnim ~= nil then
                zombie.prepareToAttack()
                zombie.attackAnim.destroyEffect()
            end
        end
            
        AZ.audio.playFX(attackInfo.sound, AZ.audio.AUDIO_VOLUME_ZOMBIE_FX)
        
        _board:addObjectAtPositionAtLayer(zombie.attackAnim, zombie.boardID, "attackEff")
        
        zombie.attackAnim:play()
        zombie.attackAnim:addEventListener("sprite", zombie.attackAnim.animListener)
            
        zombie.hits = zombie.hits -1
        
        zombieAttacks = zombieAttacks +1
        
        if _ingameUI.damage(1, zombie.zType) then
            killerZombie = zombie.zType
            
            zombie.dontHide = true
        end
    end
    
    zombie.attackSkunk = function()
        --La mofeta explota
        
        --Mostrem l'efecte gràfic
        --FALTA FER-------------------------------

        --Calcul·lem els Tiles afectat i mirem si al seu interior hi ha un objecte per enviar-li la notificació de dany
        local damagedTiles = _board:findIndexesAround (zombie.boardID, 3, 2, 3)
        for dist = 1, 2, 1 do
            local tilesAtDist = damagedTiles[dist]               
            for i = 1, #tilesAtDist, 1 do
                local currentIndex = tilesAtDist[i]
                local currentObject = _board:getObjectAtPosition(currentIndex)
                currentObject:dispatchEvent({ name = touchEventName, damage = 3, how = EXPLOSION_SKUNK_NAME })
            end
        end
        
        --Enviem una notificació per a informar de tots els Tiles afectats
        damagedTiles = _board:findIndexesAround(zombie.boardID, 3, 2, 1)
        Runtime:dispatchEvent({ name = justExplosionEventName, indexs = damagedTiles[1]})
        Runtime:dispatchEvent({ name = justExplosionEventName, indexs = damagedTiles[2]})

        --Decrementem el número d'atacs del zombie
        zombie.hits = zombie.hits - 1
        zombie.prepareToAttack()
    end
    
    zombie.ratExpand = function()
        --La rata intenta expandir-se
        --Retorna si s'ha pogut expandir o no
        if zombie.isRatFromPlague or numRatPlaguesAvailable > 0 then
            --La rata té permís per multiplicar-se
            --Si no es pot (totes les caselles ocupades), ataca
            local freeAround = _board:findIndexesAround(zombie.boardID, 3, 1, 2)[1]
            local numNewRats = #freeAround

            if numNewRats > 0 then
                --Hi ha lloc per a spawnejar noves rates
                --Creem les rates i les afegim
                local newRats = {}
                for i = 1, numNewRats, 1 do
                    local newRat = createzombie(zombie.getSpawnInfo())
                    newRat.isRatFromPlague = true
                    table.insert(newRats, newRat)
                end
                local ammountAdded = #board:addObjectsAtPositions(freeAround, newRats)

                --Actualitzem el número de zombies del nivell
                _ingameUI.addMaxZombiesInLevel(ammountAdded)

                --Decrementem el número d'atacs del zombie
                zombie.hits = zombie.hits - 1
                zombie.prepareToAttack()

                --Si era una rata inicial, decrementem el comptador de rates disponibles
                --Indiquem que és una rata de plaga, per a que pugui expandir-se sempre a partir d'ara i no canvïi el comptador de plagues disponibles
                if not zombie.isRatFromPlague then
                    numRatPlaguesAvailable = numRatPlaguesAvailable - 1
                    zombie.isRatFromPlague = true
                end

                return true

            else
                --No hi ha lloc disponible
                return false
            end

        else
            --És una rata inicial, i no queden plagues disponibles
            return false
        end
    end
    
    zombie.possumCancelEat = function ()
        --La zarigüeya atura la menjada de prop (si estava succeïnt)
        if zombie.eatTimer ~= nil then
            --Aturem el timer
            timer.cancel(zombie.eatTimer)
            zombie.eatTimer = nil

            --Aturem l'animació de la zarigüeya
            --FALTA FER----------------------------------------

            --Aturem l'animació del Prop
            local currentProp = _board:getObjectAtPosition(zombie.possumTargetID)
            currentProp.cancelEaten()

            --Preparem un nou atac de la zarigüeya. El que hem cancel·lat no compta
            zombie.prepareToAttack()
        end
    end
    
    zombie.possumFinishEat = function ()
        --La zarigüeya ha acabat de menjar-se un Prop
        timer.cancel(zombie.eatTimer)
        zombie.eatTimer = nil
        
        --Actualitzem l'estat del prop
        local currentProp = _board:getObjectAtPosition(zombie.possumTargetID)
        currentProp.finishEaten(zombie.possumTargetID)
        
        --Ens assegurem de que l'escala del Tile és la original
        _board:setTileScaleOriginal(zombie.possumTargetID);
        
        --Decrementem el número d'atacs del zombie
        zombie.hits = zombie.hits - 1
        zombie.prepareToAttack()
    end
    
    zombie.possumEat = function ()
        --La zarigüeya intenta menjar PROPs del seu voltant
        --Obtenim tots els Tiles del seu voltant, i els filtrem quedant-nos amb els que tenen PROPS
        local propsNear = {}
        local tilesFullNear = _board:findIndexesAround(zombie.boardID, 3, 1, 3)[1]
        for i = 1, #tilesFullNear, 1 do
            local currentIndex = tilesFullNear[i]
            local currentObject = _board:getObjectAtPosition(currentIndex)
            if currentObject ~= nil and currentObject.objType == BOARD_OBJECT_TYPES.PROP and currentObject.canBeEaten then
                --El Tile conté un PROP menjable
                --L'afegim
                table.insert(propsNear, currentIndex)
            end
        end
        
        --Si hi ha Tiles amb PROPs, n'escollim un per a fer de target
        if #propsNear > 0 then
            --Hi ha PROPs
            --Obtenim un dels elements de forma random
            local rndIndex = propsNear[math.random(1, #propsNear)]
            local currentProp = _board:getObjectAtPosition(rndIndex)
            
            --Iniciem el procés de menjar de la Zarigüeya
            zombie.possumTargetID = rndIndex
            
            --Alineem la Zarigüeya amb el Tile que vol menjar
            local isFlipped = false
            local XProp = _board:getXCoord(rndIndex)
            local XZombie = _board:getXCoord(zombie.boardID)
            if XProp == XZombie then
                --El Prop està a la mateixa alçada. Posem una orientació random
                if math.random(2) == 1 then isFlipped = true end 
            else
                --Volem encarar el Zombie
                --La zarigüeya NO FLIPPED està mirant a l'esquerra
                if XProp > XZombie then isFlipped = true end
            end
            zombie.setFlip(isFlipped)
            
            --Iniciem el procés de menjar del Prop
            currentProp.startEaten()
            zombie.eatTimer = timer.performWithDelay(POSSUM_TIME_EAT, zombie.possumFinishEat)
            
            return true
        else
            
            return false
        end
    end
    
    zombie.displayWarning = function()
        
        if zombie == nil then
            print("zombie es nil!")
            return
        end
        
        zombie.timerID = timer.safeCancel(zombie.timerID)
        
        if zombie.zType == AZ.zombiesLibrary.ZOMBIE_PIG_NAME then
            --El porc ha d'explotar
            zombie:setSequence("explosion")
            zombie:play()
            
        elseif zombie.hits ~= 0 and _ingameUI.isAlive() then
            --El zombie té una interacció pendent
            if zombie.zType == AZ.zombiesLibrary.ZOMBIE_SKUNK_NAME then
                --La mofeta allibera una explosió que fa mal al voltant
                zombie.attackSkunk()                
                return
                
            elseif zombie.zType == AZ.zombiesLibrary.ZOMBIE_POSSUM_NAME then
                --La zarigüeya intenta menjar-se els PROPS del seu voltant (si n'hi ha sinó ataca)
                if zombie.possumEat() then
                    return
                end
        
            elseif zombie.zType == AZ.zombiesLibrary.ZOMBIE_RAT_NAME then
                --La rata ha d'intentar spawnejar altres rates al seu voltant (si encara hi ha plagues disponibles)
                if zombie.ratExpand() then
                    return
                end
                
            else
                --No té un comportament especial
                --Permetem que es produeixi l'atac
            end
            
            --Efectuem un atac
            local warningInfo = AZ.animsLibrary.warningAnim()
            zombie.warningAnim = display.newSprite(warningInfo.imageSheet, warningInfo.sequenceData)
            zombie.warningAnim.rotation = 20
            
            zombie.warningAnim.destroyEffect = function()
                _board:delObjectAtPositionAtLayer(zombie.boardID, "warningEff")
                zombie.warningAnim = nil
            end
                
            zombie.warningAnim.animListener = function(event)
                if event.phase == "ended" and zombie ~= nil and zombie.warningAnim ~= nil then
                    zombie.warningAnim.destroyEffect()
                    zombie.attack()
                end
            end
            
            _board:addObjectAtPositionAtLayer(zombie.warningAnim, zombie.boardID, "warningEff")
            
            zombie.warningAnim:play()
            zombie.warningAnim:addEventListener("sprite", zombie.warningAnim.animListener)
            
        else
            --El zombie escapa
            zombie.exitZombie()
	end
    end
    
    zombie.prepareToAttack = function()
        if zombie.isTipZombie == false and not zombie.isLogicFreezed then
            
            zombie.timerID = timer.performWithDelay(zombie.attackTime, zombie.displayWarning)
        end
    end

    zombie.pauseResumeLogic = function(isPause, saveState)
        
        if zombie.life > 0 and zombie.timerID == nil and zombie.sequence ~= "spawn" then
            if zombie.isTipZombie then
                zombie.tipAttack(zombie.attackTime)
            else
                zombie.prepareToAttack()
            end
        end
        
        timer.safePauseResume(zombie.timerID, isPause)
        
        if zombie.eatTimer ~= nil then
            timer.safePauseResume(zombie.eatTimer, isPause)
            _board:getObjectAtPosition(zombie.possumTargetID).pauseResumeEat(isPause)
        end
        
        if saveState then
            zombie.isLogicFreezed = isPause
        end
    end
    
    zombie.pausePlayAnim = function(isPause, saveState)
        
        local handleAnim = nil
            
        if isPause then
            handleAnim = function(anim)
                if anim ~= nil then
                    anim:pause()
                end
            end
        else
            handleAnim = function(anim)
                if anim ~= nil then
                    anim:play()
                end
            end
        end
            
        handleAnim(zombie)
        handleAnim(zombie.spawnAnim)
        handleAnim(zombie.warningAnim)
        handleAnim(zombie.attackAnim)
        handleAnim(zombie.exitAnim)
        
        if saveState then
            zombie.isAnimFreezed = isPause
        end
        
    end
    
    zombie.pauseZombie = function(isPause)
        zombie.pauseResumeLogic(isPause or zombie.isLogicFreezed, false)
        zombie.pausePlayAnim(isPause or zombie.isAnimFreezed, false)
        
        timer.safePauseResume(zombie.timerID, isPause)
        transition.safePauseResume(zombie.disappearTransID, isPause)
    end
    
    zombie.pauseByEvent = function(event)
        zombie.pauseZombie(event.isPause)
    end
    
    zombie.freezeZombie = function(isPauseLogic, isPauseAnim)
        zombie.pauseResumeLogic(isPauseLogic, true)
        zombie.pausePlayAnim(isPauseAnim, true)
    end
    
    zombie.spawn = function()
        local spawnAnim = AZ.animsLibrary.spawnAnim()
        zombie.spawnAnim = display.newSprite(spawnAnim.imageSheet, spawnAnim.sequenceData)
        --zombie.spawnAnim.x, zombie.spawnAnim.y = zombie.x, zombie.y
        zombie.spawnAnim:scale(2, 2) --ZOMBIE_EFF_SCALE + SCALE_SMALL, ZOMBIE_EFF_SCALE + SCALE_SMALL)
        randomFlip(zombie.spawnAnim)

        zombie.spawnAnim.destroyEffect = function()
            _board:delObjectAtPositionAtLayer(zombie.boardID, "spawnEff")
            zombie.spawnAnim = nil
        end

        zombie.spawnAnim.spawnZombie = function()
            zombie.isVisible = true
            zombie:setSequence("spawn")
            zombie:play()
            
            zombie.spawnAnim:setSequence("spawn2")
            zombie.spawnAnim:play()
        end

        zombie.spawnAnim.animListener = function(event)
            if event.phase == "ended" and zombie ~= nil and zombie.spawnAnim ~= nil then
                if zombie.spawnAnim.sequence == "spawn1" then
                    zombie.spawnAnim.spawnZombie()
                    
                else
                    zombie.spawnAnim.destroyEffect()
                end
            end
        end
        
        AZ.audio.playFX(AZ.soundLibrary.spawnSound, AZ.audio.AUDIO_VOLUME_ZOMBIE_FX)
        
        _board:addObjectAtPositionAtLayer(zombie.spawnAnim, zombie.boardID, "spawnEff")
        
        zombie.spawnAnim:setSequence("spawn1")
        zombie.spawnAnim:play()
        zombie.spawnAnim:addEventListener("sprite", zombie.spawnAnim.animListener)
        
        --Afegim la imatge de cos sencer, i apliquem el mateix factor d'escala que el Zombie enterrat
        randomFlip(zombie)
        zombie.fullBodyImg = display.newImage(fullBodySS, zombie.fullSizeIndex)
        zombie.fullBodyImg.isVisible = false
        _board:addObjectAtPositionAtLayer(zombie.fullBodyImg, zombie.boardID, "fullBody")
        zombie.fullBodyImg.xScale, zombie.fullBodyImg.yScale = zombie.xScale, zombie.yScale
    end

    zombie.animListener = function(event)
        if event.phase == "ended" then
            if zombie.sequence == "spawn" then
                zombie:setSequence("idle")
                zombie.showDamage(false)
                zombie:play()
                zombie.isTipCallBack("spawn")
                
                zombie.prepareToAttack()
                
                --Enviem un event de que el Zombie ha aparegut al Board
                Runtime:dispatchEvent({ name = finishAppearAnimEventName, boardID = zombie.boardID })
                
            elseif zombie.sequence == "explosion" then
                zombie.explode()
            elseif zombie.sequence == "mushroom" or isKillAnim(zombie.sequence) == true then
                if zombie.sequence == "mushroom" then
                    if zombie.isTipCallBack("mushroom") == false then
                        zombie.spawnScore(0, false)
                    end
                end
                
                --Enviem una notificació per a informar de que el Zombie ha acabat l'animació i ha desaparegut
                Runtime:dispatchEvent({ name = finishDeadAnimEventName, boardID = zombie.boardID })
            end
        end
    end
    
    zombie.isGaviotTarget = function()
        if zombie.behaviour ~= AZ.zombiesLibrary.ZOMBIE_BEHAVIOUR_KINDLY and zombie.life > 0 and zombie.isZombieVisible() then --zombie.isVisible then
            local function destroyAnim(anim)
                if anim ~= nil then
                    anim.destroyEffect()
                end
            end
            destroyAnim(zombie.warningAnim)
            destroyAnim(zombie.attackAnim)
            
            return true
        end
        
        return false
    end
    
    zombie.launchEarthquake = function()
        if zombie.behaviour ~= AZ.zombiesLibrary.ZOMBIE_BEHAVIOUR_KINDLY and zombie.life > 0 and zombie.isZombieVisible() and not zombie.isIceTarget then
            zombie.isLaunched = true
            
            local function destroyAnim(anim)
                if anim ~= nil then
                    anim.destroyEffect()
                end
            end
            
            destroyAnim(zombie.spawnAnim)
            destroyAnim(zombie.exitAnim)
            destroyAnim(zombie.warningAnim)
            destroyAnim(zombie.attackAnim)
            
            --Assignem l'aspecte visual desitjat
            zombie.setFullBodyState(true)
        end
        
        return zombie.isLaunched
    end
    
    zombie.setStoneTarget = function(isTarget)
        if isTarget then
            local function destroyAnim(anim)
                if anim ~= nil then
                    anim.destroyEffect()
                end
            end
            destroyAnim(zombie.warningAnim)
            destroyAnim(zombie.attackAnim)
        end
        
        zombie.freezeZombie(isTarget, isTarget)
    end
    
    zombie.setHoseTarget = function(isTarget)
        if isTarget then
            local function destroyAnim(anim)
                if anim ~= nil then
                    anim.destroyEffect()
                end
            end
            destroyAnim(zombie.warningAnim)
            destroyAnim(zombie.attackAnim)
        end
        
        zombie.freezeZombie(isTarget, false)
        zombie.isHoseTarget = isTarget
    end
    
    zombie.setIceTarget = function(isTarget)
        if isTarget then
            local function destroyAnim(anim)
                if anim ~= nil then
                    anim.destroyEffect()
                end
            end
            destroyAnim(zombie.spawnAnim)
            destroyAnim(zombie.warningAnim)
            destroyAnim(zombie.attackAnim)
        end
        
        zombie.freezeZombie(isTarget, isTarget)
        zombie.isIceTarget = isTarget
    end
    
    zombie.setDragTarget = function(event)--isTarget)
        if not zombie.isDragValidTarget() then
            return
        end
        
        local isTarget = event.isDrag
        
        if isTarget then
            local function destroyAnim(anim)
                if anim ~= nil then
                    anim.destroyEffect()
                end
            end
            destroyAnim(zombie.spawnAnim)
            destroyAnim(zombie.warningAnim)
            destroyAnim(zombie.attackAnim)
            
            --Si era una zarigüeya menjant un prop, aturem el procés
            zombie.possumCancelEat()
        end
        
        zombie.freezeZombie(isTarget, isTarget)
        zombie.isDragging = isTarget
        
        --Assignem l'aspecte visual desitjat
        zombie.setFullBodyState(isTarget)
    end
    
    zombie.isStoneValidTarget = function()
        return zombie.life > 0 and zombie.isVisible
    end
    
    zombie.isHoseValidTarget = function()
        local isTarget = zombie.life > 0 and not zombie.isEscaping()
        return isTarget
    end
    
    zombie.isIceValidTarget = function()
        local isTarget = zombie.life > 0 and not zombie.isEscaping() and zombie.sequence ~= "spawn"
        return isTarget
    end
    
    zombie.isDragValidTarget = function()
        local draggableZombie = zombie.zType ~= AZ.zombiesLibrary.ZOMBIE_BEAR_NAME and zombie.zType ~= AZ.zombiesLibrary.ZOMBIE_MOOSE_NAME
        return zombie.life > 0 and not zombie.isEscaping() and zombie.isZombieVisible() and not zombie.isIceTarget and draggableZombie
    end
    
    zombie.setBoardID = function(event)
        
        local prevID = zombie.boardID
        zombie.boardID = event.id
        
        if prevID == nil then
            zombie.spawn()
        end
    end
    
    zombie.killByEvent = function(event)
        zombie.killZombie(event.how)
    end
    
    zombie.killByStinkBomb = function()
        if zombie.zType == AZ.zombiesLibrary.ZOMBIE_RAT_NAME then
            zombie.killZombie(STINK_BOMB_NAME)
        end
    end
    
    zombie.killIfLaunched = function()
        if zombie.isLaunched then
            zombie.killZombie(EARTHQUAKE_NAME)
        end
    end
    
    -- tip functions
    zombie.enableDisableTouch = function(isEnabled)
        zombie.isKillEnabled = isEnabled
    end
    
    zombie.tipAttack = function(delay)
        delay = delay or zombie.attackTime
        zombie.timerID = timer.performWithDelay(delay, zombie.displayWarning)
    end
    
    zombie.tipHide = function(delay)
        delay = delay or zombie.attackTime
        zombie.timerID = timer.performWithDelay(delay, zombie.exitZombie)
    end
    
    zombie.setCallBack = function(callBack, callAtAction)
        zombie.tipCallBack = callBack
        zombie.callAtAction = callAtAction
    end
    
    
    local touchEnabled = true
    
    if zombie.isTipZombie then
        zombie.tipCallBack = tipParams.endFunc
        
        if tipParams.killEnabled ~= nil then
            touchEnabled = tipParams.killEnabled
            zombie.setCallBack(tipParams.endFunc, "kill")
        else
            zombie.setCallBack(tipParams.endFunc, "spawn")
        end    
    end
    
    zombie.enableDisableTouch(touchEnabled)
    
    -- Creem listener del touch i sprite
    zombie:addEventListener("sprite", zombie.animListener)
    zombie:addEventListener(touchEventName, zombie.takeDamage)
    zombie:addEventListener(setBoardIdEventName, zombie.setBoardID)
    zombie:addEventListener(setDrag, zombie.setDragTarget)
    zombie:addEventListener(destroyEventName, zombie.finishZombie)
    zombie:addEventListener(finishEarthquakeEventName, zombie.killIfLaunched)
    zombie:addEventListener(killEventName, zombie.killByEvent)
    Runtime:addEventListener(pauseEventName, zombie.pauseByEvent)
    Runtime:addEventListener(stinkBombEventName, zombie.killByStinkBomb)
    Runtime:addEventListener(disableEventName, zombie.disableZombie)
    
    return zombie
end