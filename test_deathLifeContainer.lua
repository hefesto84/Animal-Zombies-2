-- objecte que retornem
local container = {}

-- requires
container._board = nil
container._ice = nil
container._stone = nil
container._ui = nil

-- variables
container.array = {}
container.types = { LIFE = LIFE_BOX_NAME, DEATH = DEATH_BOX_NAME }
container.imageSheet = nil
container.animInfo = nil


function container.endGame(event)
    if event.success then
        container:finishAllContainers()
    end
end

function container:destroy()
    
    Runtime:removeEventListener(GAMEPLAY_END_IS_NEAR_EVNAME, container.endGame)
    
    for i = 1, #container.array do
        if container.array[i] ~= nil then
            container.array[i].destroy()
        end
    end
    
    container = nil
end

function container:finishAllContainers()
    for i = 1, #container.array do
        if container.array[i] ~= nil then
            container.array[i].finishContainer()
        end
    end
end

function container:addContainer(containerType, boardID, isInTip)
    
    if not container._board:isIndexValid(boardID) or not container._board:getTouchEnableInTile(boardID) then
        return false;
    end
    
    local currentObject = container._board:getObjectAtPosition(boardID);
    if currentObject ~= nil then
        return false;
    end
    
    if container._ice:getAnyIceAtPosition(boardID) or container._stone:checkIfPending (boardID) then
        return false;
    end
    
    
    local newContainer = display.newGroup()
    newContainer.objType = BOARD_OBJECT_TYPES.CONTAINER
    newContainer.boardID = boardID
    newContainer.containerType = containerType
    newContainer.canDrag = true
    newContainer.timerID = nil
    newContainer.transitionID = nil
    newContainer.count = 0
    newContainer.lastZombieIn = ""
	
    local contImg = nil
    
    if containerType == container.types.DEATH then
        contImg = display.newImage(container.imageSheet, 3)
    else
        contImg = display.newImage(container.imageSheet, 2)
    end
    
    local contBubble = display.newImage(container.imageSheet, 4)
    contBubble.x, contBubble.y = contImg.contentBounds.xMax - (contBubble.width *0.5), contImg.contentBounds.yMax - (contBubble.height *0.5)
    contBubble:scale(1.5, 1.5)
    
    local contNum = display.newText(newContainer.count, 0, 0, INGAME_SCORE_FONT, 25)
    contNum:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
    contNum.x, contNum.y = contBubble.x, contBubble.y
    
    newContainer:insert(contImg)
    newContainer:insert(contBubble)
    newContainer:insert(contNum)
    
    
	newContainer.forceFinish = function()
		newContainer.finishContainer()
	end
	
    newContainer.destroy = function()
        
        Runtime:dispatchEvent({ name = GAMEPLAY_CONTAINER_EXPLODED_EVNAME, boardID = newContainer.boardID })
        
        Runtime:removeEventListener(GAMEPLAY_PAUSE_EVNAME, newContainer.onPause)
        if isInTip then
			Runtime:removeEventListener(GAMEPLAY_WEAPON_END_IN_TIP_EVNAME, newContainer.forceFinish)
		end
		
        newContainer.timerID = timer.safeCancel(newContainer.timerID)
        
        container._board:delObjectsAtPosition(newContainer.boardID)
        
        for i = 1, #container.array do
            if container.array[i] == newContainer then
                table.remove(container.array, i)
            end
        end
        
        newContainer = nil
    end
    
    newContainer.addScore = function()
        local view = display.getCurrentStage()
        local nx, ny = newContainer:localToContent(view.x, view.y)
        
		if isInTip then
			container._ui.tipInstantCombo(newContainer.count, nx, ny)
		else
			container._ui.addInstantCombo(SCORE_DEATHS, newContainer.count, nx, ny)
		end
    end
    
    newContainer.disappearContainer = function(shouldExplode)
        
        if not newContainer.isVisible then return end
        
        -- ja no podem amagar més zombies i ocultem la caixa
        newContainer.canDrag = false
        newContainer.isVisible = false
        
        -- llencem notificació conforme la caixa desapareix
        Runtime:dispatchEvent({ name = GAMEPLAY_CONTAINER_EXPLODING_EVNAME, boardID = newContainer.boardID })
        
        local animName = ""
        
        if shouldExplode then
            
            AZ.utils.vibrate()
            
            if newContainer.containerType == container.types.LIFE then
                container._ui.damage(newContainer.count)

                animName = "objectDestroyEffect"
            else
                newContainer.addScore()

                animName = "deathBoxExplosionEffect"
            end
        else
            newContainer.addScore()
            
            animName = "lifeBoxDisappearEffect"
        end
        
        newContainer.effect = display.newSprite(container.animInfo.imageSheet1, container.animInfo.sequenceData)
        newContainer.effect:scale(2, 2)
        
        if not shouldExplode then
            newContainer.effect:scale(1.2, 1.2)
        end
        
        newContainer.effect.animListener = function(event)
            if event.phase == "ended" then
                if newContainer.effect.isEnded then return end
                
                newContainer.effect.isEnded = true
                
                newContainer.transitionID = transition.to(newContainer.effect, { time = container.animInfo.getAnimFramerate(animName), alpha = 0, onComplete = newContainer.destroy })
                
            end
        end
        newContainer.effect:addEventListener("sprite", newContainer.effect.animListener)
        
        newContainer.effect:setSequence(animName)
        newContainer.effect:play()
        
        container._board:addObjectAtPositionAtLayer(newContainer.effect, boardID, "effect")
    end
    
    
    newContainer.onPause = function(event)
        if newContainer.timerID == nil then
            return
        end
        
        timer.safePauseResume(newContainer.timerID, event.isPause)
        transition.safePauseResume(newContainer.transitionID, event.isPause)
        
        if newContainer.effect ~= nil then
            if event.isPause then
                newContainer.effect:pause()
            else
                newContainer.effect:play()
            end
        end
    end
    
    newContainer.updateCount = function(amount)
        amount = amount or 1
        
        newContainer.count = newContainer.count + amount
        container._ui.addDisappearedZombies(newContainer.containerType == container.types.DEATH)
        
        contNum.text = newContainer.count
    end
    
    newContainer.explode = function()
        newContainer.disappearContainer(true)
    end
    
	newContainer.explodeByEvent = function(params)
		newContainer.lastZombieIn = params.who
		newContainer.explode()
	end
	
    newContainer.finishContainer = function()
        newContainer.disappearContainer(newContainer.containerType == container.types.DEATH)
    end
    
    newContainer.dragZombie = function(z)
        if z.isWeaponResistant(newContainer.containerType) then
            return false
        end
        
        if newContainer.canDrag then
            
			 if z.zType == AZ.zombiesLibrary.ZOMBIE_PIG_NAME then
                -- si introduim un porc en la caixa, l'afegim i explota directament
				z.takeDamage({ life = -1, how = newContainer.containerType })
                newContainer.updateCount(0)
                newContainer.explode()
                
            elseif z.behaviour == AZ.zombiesLibrary.ZOMBIE_BEHAVIOUR_KINDLY and newContainer.containerType == container.types.DEATH then
                
                if newContainer.count < 1 then
                    return false
                end
               
                -- hem posat un kindly en una caixa de mort: treiem una vida
				z.takeDamage({ life = -1, how = newContainer.containerType })
                --container._ui.damage()
                newContainer.updateCount(0)
                
            elseif z.behaviour ~= AZ.zombiesLibrary.ZOMBIE_BEHAVIOUR_KINDLY and newContainer.containerType == container.types.LIFE then
                
                if newContainer.count < 1 then
                    return false
                end
                
                -- hem posat un zombie en una caixa de vida: treiem tantes vides com hi hagués al contador
                container._ui.damage(newContainer.count, z.zType)
                
                newContainer.updateCount(-newContainer.count)
            else
                -- hem afegit un zombie adient a la caixa, sumem el contador
                newContainer.updateCount()
            end
			
			newContainer.lastZombieIn = z.zType
			
			timer.performWithDelay(0, function() Runtime:dispatchEvent({ name = GAMEPLAY_PLANTED_WEAPON_INTERACTED_EVNAME, zombie = z.zType, wName = newContainer.containerType }) end)
			
			transition.to(z.fullBodyImg, { time = 100, alpha = 0, onComplete = function() container._board:delObjectsAtPosition(z.boardID) end })
        end
        
        return newContainer.canDrag
    end
    
    -- afegim el listener per a pausar el contenidor
    Runtime:addEventListener(GAMEPLAY_PAUSE_EVNAME, newContainer.onPause)
    newContainer:addEventListener(OBJECT_TOUCH_EVNAME, newContainer.explodeByEvent)
    
    -- afegim un timer de vida
    newContainer.timerID = timer.performWithDelay(WEAP_CONTAINER_LIFETIME, newContainer.finishContainer)
	
	if isInTip then
		timer.safePause(newContainer.timerID)
		Runtime:addEventListener(GAMEPLAY_WEAPON_END_IN_TIP_EVNAME, newContainer.forceFinish)
	end
	
    -- afegim el contenidor el en board
    container._board:addObjectAtPosition(newContainer, boardID)
    
    -- afegim el contenidor al nostre array
    container.array[#container.array +1] = newContainer
    
    return true;
end

function container:init(params)
    container._board = params.board
    container._ui = params.ui
    container._ice = params.ice
    container._stone = params.stone
    container.imageSheet = params.weaponsSS
    
    Runtime:addEventListener(GAMEPLAY_END_IS_NEAR_EVNAME, container.endGame)
    
    container.animInfo = AZ.animsLibrary.lifeDeathBoxAnim()
end

return container