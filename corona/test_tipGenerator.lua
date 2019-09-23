
local tip = {}

tip._ui = nil
tip._gameplay = nil
tip._board = nil
tip._zombies = nil

tip.grp = nil
tip.tipGrp = nil

-- variables de touch
tip.touchFunc = nil
tip.touchEnabled = false

tip.isWaitingAction = false

-- gràfics
tip.touchableLayer = nil
tip.box = nil
tip.cooper = nil
tip.txt = nil
tip.arrow = nil
tip.hand = nil

tip.spawnedObjsAt = {}

local boxMargin, doubleMargin



local function createGameplay()
	tip.gameplay = {}
    tip.gameplay.runtimeListeners = {}
	tip.gameplay.givenWeapons = {}
	
-- gameplay functions
	local function addRuntimeListener(evName, func)
		if tip.gameplay.runtimeListeners[evName] ~= func then
			Runtime:addEventListener(evName, func)
		end
		tip.gameplay.runtimeListeners[evName] = func
	end
	
	tip.gameplay.removeListeners = function()
		for evName, func in pairs(tip.gameplay.runtimeListeners) do
			Runtime:removeEventListener(evName, func)
		end
		
		tip.gameplay.runtimeListeners = {}
	end
	
	tip.gameplay.substractGivenWeapons = function()
		for wName, amount in pairs(tip.gameplay.givenWeapons) do
			tip._ui.updateWeaponQuantity(wName, -amount)
		end
		
		tip.gameplay.givenWeapons = {}
	end
	
	-- ZOMBIE HANDLER, rep un event llançat per el zombie per parametres
	tip.gameplay.zombieHandler = function(event)
		if event.action == "spawn" then
			print("El zombie ha aperegut")
		elseif event.action == "kill" then
--			event.endFunc()
			tip:executeEndFunc(event.endFunc, event.endDelay)
		elseif event.action == "attack" then
--			event.endFunc()
			tip:executeEndFunc(event.endFunc, event.endDelay)
		elseif event.action == "exit" then
--			event.endFunc()
			tip:executeEndFunc(event.endFunc, event.endDelay)
		end
	end
	
	-- SPAWN ZOMBIE
    tip.gameplay.spawnZombie = function(params)
        
        local tipParams = { endFunc = params.endFunc, killEnabled = params.killEnabled, wKiller = params.killerWeapon, endDelay = params.endDelay }
        
        for i=1, #params.zombies do
            local current = params.zombies[i]
			
			tipParams.wKiller = current.killerWeapon or params.killerWeapon
            
            local z = tip._zombies.createzombie({ zombieInfo = AZ.zombiesLibrary.getZombie(current.type), hits = 1, timeToAttack = current.timeToAttack or 0 }, tipParams)
           
            if tip._board:addObjectAtPosition(z, current.boardID) then
				table.insert(tip.spawnedObjsAt, current.boardID)
			else
				print("WARNING\tEl zombie ".. current.type .." en el tile ".. current.boardID .." no s'ha pogut insertar en el board")
				display.remove(z)
			end
        end
		
		tip._board:setTouchEnableToAll(true)
		
		addRuntimeListener(ZOMBIE_TIP_CALLBACK_EVNAME, tip.gameplay.zombieHandler)
		
    end
    
	-- EXIT ZOMBIE
	tip.gameplay.exitZombie = function(params)
        for i=1, #params.zombies do
			local current = params.zombies[i]
			
			local z = tip._board:getObjectAtPosition(current.boardID)
			
			z.tipHide(current.timeToHide)
			
			if params.endFunc or current.endFunc then
				z.setCallBack(params.endFunc or current.endFunc, "exit", params.endDelay or current.endDelay)
			end
        end
		
		addRuntimeListener(ZOMBIE_TIP_CALLBACK_EVNAME, tip.gameplay.zombieHandler)
    end
	
	-- ATTACK ZOMBIE
    tip.gameplay.attackZombie = function(params)
        for i=1, #params.zombies do
			local current = params.zombies[i]
			
			local z = tip._board:getObjectAtPosition(current.boardID)
			
			z.tipAttack(current.timeToAttack)
			
			if params.endFunc or current.endFunc then
				z.setCallBack(params.endFunc or current.endFunc, "attack", params.endDelay or current.endDelay)
			end
        end
		addRuntimeListener(ZOMBIE_TIP_CALLBACK_EVNAME, tip.gameplay.zombieHandler)
    end
    
	-- ENABLE ZOMBIE TOUCH
    tip.gameplay.enableZombieTouch = function(params)
        for i=1, #params.zombies do
            local current = params.zombies[i]
           
            local z = tip._board:getObjectAtPosition(current.boardID)
			
			z.enableDisableTouch(true)
			if params.killerWeapon or current.killerWeapon then
				z.setWeaponKiller(current.killerWeapon or params.killerWeapon)
			end
			
            if params.endFunc or current.endFunc then
				z.setCallBack(params.endFunc or current.endFunc, "kill", params.endDelay or current.endDelay)
			end
        end
		tip._board:setTouchEnableToAll(true)
		addRuntimeListener(ZOMBIE_TIP_CALLBACK_EVNAME, tip.gameplay.zombieHandler)
    end
	
	-- COMBO
	tip.gameplay.comboListener = function(params)
		
		local respawnTimerID = nil
		
		local function createZombies()
			local zParams = { killEnabled = true, zombies = params.zombies, endDelay = params.endDelay }
			tip.gameplay.spawnZombie(zParams)
		end
		
		local function comboListener(event)
			if event.finishCombo then
				respawnTimerID = timer.safeCancel(respawnTimerID)
				respawnTimerID = timer.performWithDelay(900, createZombies)
			elseif event.comboCount == params.comboCount then
				
				respawnTimerID = timer.safeCancel(respawnTimerID)
				
				tip.gameplay.removeListeners()
				
--				if params.endFunc then
--					params.endFunc()
--				end
				tip:executeEndFunc(params.endFunc, params.endDelay)
			end
		end
		
		createZombies()
		
		tip._board:setTouchEnableToAll(true)
		
		addRuntimeListener(GAMEPLAY_COMBO_EVNAME, comboListener)
	end
	
	-- SPAWN POWERUP
    tip.gameplay.spawnPowerUp = function(params)
		
		local function powerupHandler(event)
			if event.name == GAMEPLAY_POWERUP_LOST then
				Runtime:dispatchEvent({ name = GAMEPLAY_SPAWN_POWERUP, powerUpName = event.powerUpName })
			else
				
				if params.weaponName ~= "lollipop" then
					tip.gameplay.givenWeapons[params.weaponName] = (tip.gameplay.givenWeapons[params.weaponName] or 0) +1
					if not tip._gameplay.getWeaponControllerModule():isDirectWeapon(params.weaponName) then
						tip._ui.setCurrentWeapon(params.weaponName)
					end
				end
				
				tip.gameplay.removeListeners()
				
--				if params.endFunc then
--					params.endFunc()
--				end
				tip:executeEndFunc(params.endFunc, params.endDelay)
			end
		end
		
		Runtime:dispatchEvent({ name = GAMEPLAY_SPAWN_POWERUP, powerUpName = params.weaponName, endDelay = params.endDelay })
		
		addRuntimeListener(GAMEPLAY_POWERUP_LOST, powerupHandler)
		addRuntimeListener(GAMEPLAY_POWERUP_GET, powerupHandler)
    end
	
	-- FINISH BOARD WEAPON
	tip.gameplay.finishBoardWeapon = function(params)
		
		Runtime:dispatchEvent({ name = GAMEPLAY_WEAPON_END_IN_TIP_EVNAME })
	end
	
	-- TOUCH IN TILE
	tip.gameplay.touchInTile = function(params)
		
		tip.gameplay.touchInTileHandler = function(event)
			if event.params.phase == "ended" and event.params.path[#event.params.path] == params.boardID then
				
				tip.gameplay.removeListeners()
				tip._board:setTouchEnableToAll(false)
				
--				params.endFunc()
				tip:executeEndFunc(params.endFunc, params.endDelay)
			end
		end
		
		addRuntimeListener(GENERIC_TOUCH_EVNAME, tip.gameplay.touchInTileHandler)
		
		tip._board:setTouchEnableToAll(false)
		tip._board:setTouchEnableToPosition(params.boardID, true)
	end
	
	-- BOARD WEAPONS LISTENER
	tip.gameplay.listenBoardWeapon = function(params)
		
		local receivedEvents = 0
		params.count = params.count or 1
		
		local function boardListener(event)
			
			if event.wName == params.weaponName then
				
				receivedEvents = receivedEvents +1
				
				if receivedEvents == params.count then
				
					tip.gameplay.removeListeners()
					
--					if params.endFunc then
--						params.endFunc()
--					end
					tip:executeEndFunc(params.endFunc, params.endDelay)
				end
			end
		end
		
		tip._board:setTouchEnableToAll(true)
		
		addRuntimeListener(GAMEPLAY_PLANTED_WEAPON_INTERACTED_EVNAME, boardListener)
	end
	
	-- ENABLE TOUCH IN WEAPON BUTTON
    tip.gameplay.touchWeapon = function(params)
        tip._ui.enableDisableWeaponButtons({ params.weaponName }, true)
		
		local function weaponTouched(event)
			if event.newWeapon == params.weaponName then
				
				tip.gameplay.removeListeners()
				
--				if params.endFunc then
--					params.endFunc()
--				end
				tip:executeEndFunc(params.endFunc, params.endDelay)
			end
		end
		
		addRuntimeListener(GAMEPLAY_WEAPON_CHANGED_EVNAME, weaponTouched)
    end
	
	-- ENABLES TIP TO KNOW WHEN A WEAPON IS REFILLED
	tip.gameplay.unlockAndRefillWeapon = function(params)
        tip._ui.enableDisableWeaponButtons({ params.weaponName }, true)
		
		local function weaponRefill(event)
			if event.success then
				tip.gameplay.removeListeners()
				tip:executeEndFunc(params.endFunc, params.endDelay)
			end
		end
		
		addRuntimeListener(GAMEPLAY_PAUSE_EVNAME, weaponRefill)
	end
	
    tip.gameplay.actions = {	["zombieSpawn"] = tip.gameplay.spawnZombie,	["zombieAttack"] = tip.gameplay.attackZombie,
								["zombieExit"] = tip.gameplay.exitZombie,		["zombieEnableKill"] = tip.gameplay.enableZombieTouch,
								["touchWeapon"] = tip.gameplay.touchWeapon,	["listenBoardWeapon"] = tip.gameplay.listenBoardWeapon,
								["spawnPowerUp"] = tip.gameplay.spawnPowerUp,	["listenCombos"] = tip.gameplay.comboListener,
								["touchInTile"] = tip.gameplay.touchInTile,	["finishBoardWeapon"] = tip.gameplay.finishBoardWeapon,
								["unlockWeaponAndListenToWeaponRefill"] = tip.gameplay.unlockAndRefillWeapon,
								["resetWeapon"] = function() print("'resetWeapon' no existeix") end }
end

local function createHand()
	tip.hand = display.newImage("assets/mano.png")
	tip.hand:scale(SCALE_DEFAULT, SCALE_DEFAULT)
    tip.hand.alpha = 0
	tip.grp:insert(tip.hand)
	
-- hand actions
	-- APPEAR
    tip.hand.appear = function(callBack, params)
        
		params = params or {}
		params.time = params.time or 200
		
		tip.hand.anchorX, tip.hand.anchorY = params.anchorX or 0.5, params.anchorY or 1
		tip.hand.rotation = params.rotation or tip.hand.rotation
		
		local newX, newY = 0, 0
		local newXPos, newYPos = false, false
		
		--- D'aquesta manera es pot assenyalar l'arma que correspon ---
		if params.weapon then
			newXPos, newYPos = true, true
			newX, newY = tip._ui.getWeaponPosition(params.weapon)
			newY = newY-tip.hand.contentHeight*0.6
		end
		---------------------------------------------------------------
		if params.boardID then
			newXPos, newYPos = true, true
			newX, newY = tip._board:getTilePos(params.boardID)
		end
		if params.x then
			newXPos = true
			newX = newX + params.x
		end
		if params.y then
			newYPos = true
			newY = newY + params.y
		end
        
		if newXPos then
			tip.hand.x = newX
		end
		if newYPos then
			tip.hand.y = newY
		end
		
        tip.hand.transID = transition.to(tip.hand, { delay = params.delay, time = params.time, alpha = 1, easing = params.easing, onComplete = callBack})
    end
    
    -- DISAPPEAR
    tip.hand.disappear = function(callBack, params)
		
		params = params or {}
		params.time = params.time or 200
		
        tip.hand.transID = transition.to(tip.hand, { delay = params.delay, time = params.time, alpha = 0, easing = params.easing, onComplete = callBack })
    end
    
    -- MOVE
    tip.hand.move = function(callBack, params)
		
		params = params or {}
		params.time = params.time or 500
		params.delay = params.delay or 200
		
		local newX, newY = 0, 0
		local newXPos, newYPos = false, false
		
		if params.boardID then
			newXPos, newYPos = true, true
			newX, newY = tip._board:getTilePos(params.boardID)
		end
		if params.x then
			newXPos = true
			newX = newX + params.x
		end
		if params.y then
			newYPos = true
			newY = newY + params.y
		end
        
		if not newXPos then
			newX = nil
		end
		if not newYPos then
			newY = nil
		end
		
        tip.hand.transID = transition.to(tip.hand, { delay = params.delay, time = params.time, x = newX, y = newY, rotation = params.rotation, transition = params.easing, onComplete = callBack })
    end
    
    -- CLICK
    tip.hand.doClick = function(callBack)
        local scale = SCALE_DEFAULT *0.9
        tip.hand.transID = transition.to(tip.hand, { time = 100, xScale = scale, yScale = scale, onComplete = callBack })
    end
    
    -- UNCLICK
    tip.hand.undoClick = function(callBack)
        local scale = SCALE_DEFAULT
        tip.hand.transID = transition.to(tip.hand, { time = 250, xScale = scale, yScale = scale, onComplete = callBack })
    end
        
    tip.hand.doActions = function(actions, isLoop, endFunc, endDelay)
        tip.hand.isLoop = isLoop
        tip.hand.toDo = actions
        tip.hand.currentAction = 1
        
        tip.hand.act = function()
			
			if not tip then return end
			
            if tip.hand.currentAction > #tip.hand.toDo then
                if tip.hand.isLoop then
                    tip.hand.currentAction = 1
                else
--					if endFunc then
--						endFunc()
--					end
					tip:executeEndFunc(endFunc, endDelay)
					
					return
                end
            end 
            
            local myAction = tip.hand.toDo[tip.hand.currentAction]
			
			tip.hand.transID = transition.safeCancel(tip.hand.transID)
            tip.hand.actions[myAction.action](tip.hand.act, myAction.params)
            
            tip.hand.currentAction = tip.hand.currentAction +1   
        end
        
        tip.hand.act()
    end
    
    tip.hand.actions = { ["appear"] = tip.hand.appear, ["disappear"] = tip.hand.disappear, ["move"] = tip.hand.move, ["click"] = tip.hand.doClick, ["unclick"] = tip.hand.undoClick }
	
end

--Funcio que gestiona l'endFunction i l'executa amb delay o no
function tip:executeEndFunc(endFunc, endDelay)
	if endFunc then
		if endDelay then
			tip.endFuncTimerID = timer.safePerformWithDelay(tip.endFuncTimerID, endDelay, function() endFunc() end)
		else
			endFunc()
		end
	end
end

function tip:finalGift(wName, wAmount)
	tip._ui.updateWeaponQuantity(wName, wAmount)
	tip._ui.enableDisableWeaponButtons("all", true)
	tip._gameplay.setNewWeapon(SHOVEL_NAME)
end

local function cancelTransTimers()
    tip.box.transID = transition.safeCancel(tip.box.transID)
    tip.arrow.alphaTransID = transition.safeCancel(tip.arrow.alphaTransID)
	tip.txt.timerID = timer.safeCancel(tip.txt.timerID)
end

function tip:isWriting()
    return #tip.txt.text ~= #tip.txt.newTxt
end

function tip:canSkip()
    return not tip.isWaitingAction
end

function tip:endWriting(isForced)
    cancelTransTimers()
    
    tip.txt.text = tip.txt.newTxt
    
    tip.box.resize(0)
    
    if isForced then
        tip.arrow.showOrHide(true, 0)
    else
        tip.arrow.showOrHide(true)
    end
end

local function startTip(newText)
	tip.txt.typewrite(newText)
    tip.box.resize()
    tip.touchEnabled = true
	
	if tip.handActions then
		tip.hand.doActions(tip.handActions.actions, tip.handActions.isLoop, tip.handActions.endFunc, tip.handActions.endDelay)
    end
    
    if tip.gameplayActions then
		--AZ.utils.print(tip.gameplayActions.params, tip.gameplayActions.action)
        tip.gameplay.actions[tip.gameplayActions.action](tip.gameplayActions.params)
    end
end

local function relocateAndShowNewTip(posY, newText)
    tip.tipGrp.y = posY
    tip.txt.text = ""
    tip.box.path.height = tip.box.originalHeight
    tip.tipGrp.transID = transition.to(tip.tipGrp, { time = 250, alpha = 1, onComplete = function() startTip(newText) end })
end

function tip:newTipStep(txt, posY, handActions, gpActions)
    cancelTransTimers()
	tip.endFuncTimerID = timer.safeCancel(tip.endFuncTimerID)
	
	tip.hand.transID = transition.safeCancel(tip.hand.transID)
	tip.hand.disappear(nil, { time = 250 })
    tip.arrow.showOrHide(false, 0)
    
	tip.handActions = handActions
	tip.gameplayActions = gpActions
    tip.isWaitingAction = (handActions and handActions.endFunc ~= nil) or (gpActions and gpActions.endFunc ~= nil)
    
    if tip.tipGrp.y == posY then
        startTip(txt)
    else
        tip.tipGrp.transID = transition.to(tip.tipGrp, { time = 250, alpha = 0, onComplete = function() relocateAndShowNewTip(posY, txt) end })
    end
end

function tip:destroy()
	cancelTransTimers()
	tip.hand.transID = transition.safeCancel(tip.hand.transID)
	tip.endFuncTimerID = timer.safeCancel(tip.endFuncTimerID)
	
	tip.touchEnabled = false
	tip.arrow.moveTransID = transition.safeCancel(tip.arrow.moveTransID)
	
	tip.gameplay.removeListeners()
	tip.gameplay.substractGivenWeapons()
	
    tip = nil
    
    return nil
end

function tip:pause(isPause)
	transition.safePauseResume(tip.box.transID, isPause)
	transition.safePauseResume(tip.arrow.moveTransID, isPause)
	transition.safePauseResume(tip.arrow.alphaTransID, isPause)
	transition.safePauseResume(tip.hand.transID, isPause)
	timer.safePauseResume(tip.txt.timerID, isPause)
	timer.safePauseResume(tip.endFuncTimerID, isPause)
end

function tip:forceEnd(t)
	t = t or 250
	
	-- ens recorrem l'array de zombies spawnejats i els eliminem
	for i = 1, #tip.spawnedObjsAt do
		local obj = tip._board:getObjectAtPosition(tip.spawnedObjsAt[i])
		
		if obj then
			transition.to(obj, { time = t, alpha = 0, onComplete = function() tip._board:delObjectsAtPosition(tip.spawnedObjsAt[i]) end })
		end
	end
	
	-- per si de cas, eliminem possibles armes plantades en el board durant el tip
	tip.gameplay.finishBoardWeapon()
end

local function startedAndEndedInRect(bounds, event)
	return AZ.utils.isPointInRect(event.xStart, event.yStart, bounds) and AZ.utils.isPointInRect(event.x, event.y, bounds)
end

function tip:init(uiModule, gameplayModule, txt, posY, handActions, gpActions, touchFunc, forceEndFunc)
	
	tip.touchFunc = touchFunc
	
	tip.spawnedObjsAt = {}
	
	tip.endFuncTimerID = nil
	tip.touchFuncTimerID = nil
	
-- requires
    tip._ui = uiModule
    tip._gameplay = gameplayModule
    tip._board = tip._gameplay.getBoardModule()
    tip._zombies = tip._gameplay.getZombieModule()
    
-- gràfics
    local boxW = display.contentWidth *0.9

    tip.grp = display.newGroup()
    tip.tipGrp = display.newGroup()
    tip.tipGrp.alpha = 0
    tip.tipGrp.anchorX, tip.tipGrp.anchorY = 0, 0
    tip.tipGrp.x = (display.contentWidth - boxW) *0.5
    
	-- touchable layer
	tip.touchEnabled = false
    local function onLayerTouch(event)
        if event.phase == "ended" and tip and tip.touchEnabled and not tip.isWaitingAction then
			tip._board:cancelTouchEvent(event.id)
			return tip.touchFunc(event)
		end
		
		return not tip.isWaitingAction
	end
	
	tip.touchableLayer = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth *1.2, display.contentHeight *1.2)
	tip.touchableLayer.alpha = 0
	tip.touchableLayer.isHitTestable = true
	tip.touchableLayer:addEventListener("touch", onLayerTouch)
	tip.grp:insert(tip.touchableLayer)
	
	tip.grp:insert(tip.tipGrp)
	
    -- cooper
    tip.cooper = display.newImage("assets/cooper.png")
    tip.cooper:scale(SCALE_BIG, SCALE_BIG)
    
    boxMargin = tip.cooper.contentWidth *0.1
    doubleMargin = boxMargin + boxMargin
    
    tip.cooper.x, tip.cooper.y = (tip.cooper.contentWidth *0.5) + boxMargin, tip.cooper.contentHeight *0.5
    tip.tipGrp:insert(tip.cooper)
    
    -- caixa
    tip.box = display.newRoundedRect(0, 0, boxW, tip.cooper.contentHeight + boxMargin, display.contentWidth *0.03)
    tip.box.originalHeight = tip.box.contentHeight
    tip.box.anchorX, tip.box.anchorY = 0, 0
    tip.box:setFillColor(0, 0, 0, 0.8)
    tip.tipGrp:insert(tip.box)
    tip.box:toBack()
	
	-- x
	tip.boxCross = display.newGroup()
	local cross = display.newImage("assets/tipCross.png")
	cross:scale(SCALE_DEFAULT, SCALE_DEFAULT)
	tip.boxCross:insert(cross)
	
	tip.forceEndFunc = forceEndFunc
	local function onCrossTouch(event)
		if event.phase == "ended" and tip and tip.touchEnabled then
			tip._board:cancelTouchEvent(event.id)
			if startedAndEndedInRect(tip.boxCross.contentBounds, event) then
				tip.forceEndFunc()
			end
		end
		return true
	end
	
	local crossLayer = display.newRect(0, 0, cross.contentWidth *3, cross.contentHeight *3)
	crossLayer.alpha = 0
	crossLayer.isHitTestable = true
	crossLayer:addEventListener("touch", onCrossTouch)
	tip.boxCross:insert(crossLayer)
	
    tip.boxCross.x, tip.boxCross.y = tip.box.path.width -(cross.contentWidth), cross.contentHeight
	tip.tipGrp:insert(tip.boxCross)
	
    function tip.box.resize(t)
        
        local boxHeight = tip.box.originalHeight

        if tip.isWaitingAction then
            boxHeight = math.max(tip.txt.newH + doubleMargin + doubleMargin, boxHeight)
        else
            boxHeight = math.max(tip.txt.newH + boxMargin + doubleMargin + doubleMargin + tip.arrow.contentHeight, boxHeight)
        end

        if not t then
            local hDiff = math.abs(boxHeight - tip.box.height)
            t = hDiff *5
        end

        tip.box.transID = transition.safeCancel(tip.box.transID)
        tip.box.transID = transition.to(tip.box, { time = t, height = boxHeight, transition = easing.outCubic })
    end
    
    -- text
    local txtX = tip.cooper.contentWidth + doubleMargin
    local txtW = boxW - (txtX + doubleMargin)
    tip.txt = display.newText("", txtX, doubleMargin, txtW, 0, INTERSTATE_LIGHT, 28 *SCALE_DEFAULT)
	tip.txt:setFillColor(AZ.utils.getColor(INGAME_COMBO_COLOR))
	tip.txt.anchorX, tip.txt.anchorY = 0, 0
    tip.tipGrp:insert(tip.txt)
    
    function tip.txt.typewrite(text)
        
        local function writeChar()
            tip.txt.text = tip.txt.newTxt:sub(1, #tip.txt.text +1)
            
            if #tip.txt.text == #tip.txt.newTxt then
                tip:endWriting(false)
            end
        end
        
        tip.txt.text = text
        tip.txt.newH = tip.txt.contentHeight
        tip.txt.newTxt = text
        tip.txt.text = ""
    
        tip.txt.timerID = timer.safePerformWithDelay(tip.txt.timerID, 20, writeChar, #text)
    end
    
    -- fletxa
    tip.arrow = display.newImage("assets/flecha.png")
    tip.arrow:scale(SCALE_BIG, SCALE_BIG)
    tip.arrow.x = txtX +(txtW *0.5)
    tip.arrow.alpha = 0
    tip.arrow.newAlpha = 0
    tip.tipGrp:insert(tip.arrow)
    
    local movingSpace = display.contentWidth *0.0125
    local lPos, rPos = tip.arrow.x - movingSpace, tip.arrow.x + movingSpace
    function tip.arrow.move()
		if not tip then return end
		
        local nx = rPos
        if tip.arrow.x == rPos then
            nx = lPos
        end
        
        tip.arrow.moveTransID = transition.to(tip.arrow, { time = 500, x = nx, transition = easing.inOutCubic, onComplete = tip.arrow.move })
    end
    tip.arrow.move()
    
    function tip.arrow.showOrHide(shouldShow, time)
        if shouldShow == (tip.arrow.newAlpha == 1) or tip.isWaitingAction then
			return false, 0
        end
        tip.arrow.newAlpha = math.abs(tip.arrow.newAlpha -1)
        
        local function setArrowY()
            tip.arrow.y = tip.box.contentHeight - doubleMargin -(tip.arrow.contentHeight *0.5)
        end
        
        time = time or 250
        
        tip.arrow.alphaTransID = transition.safeCancel(tip.arrow.alphaTransID)
        tip.arrow.alphaTransID = transition.to(tip.arrow, { delay = 0, time = time, onStart = setArrowY, alpha = tip.arrow.newAlpha })
        
        return true, time
	end
	
	
	createGameplay()
	createHand()
	
	tip.handActions = handActions
	tip.gameplayActions = gpActions
	tip.isWaitingAction = (handActions and handActions.endFunc ~= nil) or (gpActions and gpActions.endFunc ~= nil)
	
	
	
    relocateAndShowNewTip(posY, txt)
    
    return tip.grp
end

return tip