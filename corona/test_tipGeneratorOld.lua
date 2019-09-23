module(..., package.seeall)

require "resolutions"
require "constants"

local tip = {}

tip._gameplay = nil
tip._board = nil
tip._zombies = nil

tip.tipTransID = nil
tip.handTransID = nil
tip.changingPosY = nil
tip.changingText = nil
tip.isWaitingAction = nil

tip.group = nil

tip.txtTipGroup = nil
tip.txtTextGroup = nil
tip.txtCooper = nil
tip.txtGradient = nil
tip.txtText = nil
tip.txtTap = nil
tip.txtTimer = nil

tip.hand = nil

tip.transitionTime = 250


tip.createGameplay = function()
    
    tip.gameplay = {}
    tip.gameplay.isListening = false
    tip.gameplay.endFunc = nil

    tip.gameplay.spawnZombie = function(params)
        
        local tipParams = { endFunc = params.endFunc, killEnabled = params.killEnabled }
        
        for i=1, #params.zombies do
            local current = params.zombies[i]
            
            local z = tip._zombies.createzombie({ zombieInfo = AZ.zombiesLibrary.getZombie(current.type), hits = 1, timeToAttack = current.timeToAttack or 0 }, tipParams)
            
            tip._board:addObjectAtPosition(z, current.boardID)
        end
    end
    
    tip.gameplay.attackZombie = function(params)
        for i=1, #params.zombies do
            local current = params.zombies[i]
            
            local z = tip._board:getObjectAtPosition(current.boardID)

            z.tipAttack(current.timeToAttack)

            z.setCallBack(params.endFunc, "attack")
        end    
    end
    
    tip.gameplay.enableZombieTouch = function(params)
        for i=1, #params.zombies do
            local current = params.zombies[i]
            
            local z = tip._board:getObjectAtPosition(current.boardID)

            z.enableDisableTouch(true)

            z.setCallBack(params.endFunc, "kill")
        end
    end
    
    tip.gameplay.powerupHandler = function(event)
        if event.name == GAMEPLAY_POWERUP_LOST then
            Runtime:dispatchEvent({ name = GAMEPLAY_SPAWN_POWERUP, powerUpName = event.powerUpName })
        else
            tip.gameplay.isListening = false
            
            Runtime:removeEventListener(GAMEPLAY_POWERUP_LOST, tip.gameplay.powerupHandler)
            Runtime:removeEventListener(GAMEPLAY_POWERUP_GET, tip.gameplay.powerupHandler)
            
            if tip.gameplay.endFunc then
                tip.gameplay.endFunc()
                tip.gameplay.endFunc = nil
            end
        end
    end
    
    tip.gameplay.spawnPowerUp = function(params)
        tip.gameplay.endFunc = params.endFunc
        
        Runtime:dispatchEvent({ name = GAMEPLAY_SPAWN_POWERUP, powerUpName = params.weaponName, delay = params.delay })
        
        tip.gameplay.isListening = true
        Runtime:addEventListener(GAMEPLAY_POWERUP_LOST, tip.gameplay.powerupHandler)
        Runtime:addEventListener(GAMEPLAY_POWERUP_GET, tip.gameplay.powerupHandler)
    end

    tip.gameplay.touchWeapon = function(params)
        tip._ui.enableDisableWeaponButtons({ params.weaponName }, true)
    end

    tip.gameplay.endWeapon = function(params)
        tip._ui.enableDisableWeaponButtons("all", true)
        tip._gameplay.setNewWeapon(SHOVEL_NAME)
    end
    
    tip.gameplay.actions = {    ["zombieSpawn"] = tip.gameplay.spawnZombie, ["zombieAttack"] = tip.gameplay.attackZombie,   ["zombieEnableKill"] = tip.gameplay.enableZombieTouch,
                                ["touchWeapon"] = tip.gameplay.touchWeapon, ["resetWeapon"] = tip.gameplay.endWeapon,       ["spawnPowerUp"] = tip.gameplay.spawnPowerUp }
end

tip.createHand = function()
    
    tip.hand = display.newImage("assets/mano.png")
    
    tip.hand:scale(SCALE_DEFAULT, SCALE_DEFAULT)
    tip.hand.alpha = 0
    
    -- APPEAR
    tip.hand.appear = function(callBack, params)
        local myTime, myDelay = 200, 0
        local myTransition = easing.linear
        
        if params ~= nil then
            if params.time ~= nil then
                myTime = params.time
            end
            if params.delay ~= nil then
                myDelay = params.delay
            end
            if params.anchorX and params.anchorY then
                tip.hand.anchorX, tip.hand.anchorY = params.anchorX, params.anchorY
            else
                tip.hand.anchorX, tip.hand.anchorY = 0.5, 1 --:setReferencePoint(display.BottomCenterReferencePoint)
            end
            if params.x ~= nil and params.y ~= nil then
                tip.hand.x, tip.hand.y = params.x, params.y
            end
            if params.boardID ~= nil then
                tip.hand.x, tip.hand.y = tip._board:getTilePos(params.boardID) --.getPos(params.xZombie, params.yZombie)
            end
            if params.rotation ~= nil then
                tip.hand.rotation = params.rotation
            end
            if params.easing ~= nil then
                myTransition = params.easing
            end
        end
        
        tip.hand:toFront()
        
        tip.handTransID = transition.to(tip.hand, { delay = myDelay, time = myTime, alpha = 1, easing = myTransition, onComplete = callBack })
    end
    
    -- DISAPPEAR
    tip.hand.disappear = function(callBack, params)
        local myTime, myDelay = 200, 0
        local myTransition = easing.linear
        
        if params ~= nil then
            if params.time ~= nil then
                myTime = params.time
            end
            if params.delay ~= nil then
                myDelay = params.delay
            end
            if params.easing ~= nil then
                myTransition = params.easing
            end
        end
        
        tip.handTransID = transition.to(tip.hand, { delay = myDelay, time = myTime, alpha = 0, easing = myTransition, onComplete = callBack })
    end
    
    -- MOVE
    tip.hand.move = function(callBack, params)
        local myTime, myDelay = 500, 200
        local myX, myY = params.x, params.y
        local myRot = params.rotation
        local myTransition = easing.linear
        
        if params ~= nil then
            if params.boardID ~= nil then
                myX, myY = tip._board:getTilePos(params.boardID) --.getPos(params.xZombie, params.yZombie)
            end
            if params.time ~= nil then
                myTime = params.time
            end
            if params.delay ~= nil then
                myDelay = params.delay
            end
            if params.easing ~= nil then
                myTransition = params.easing
            end
        end
        
        tip.hand:toFront()
        
        tip.handTransID = transition.to(tip.hand, { delay = myDelay, time = myTime, x = myX, y = myY, rotation = myRot, transition = myTransition, onComplete = callBack })
    end
    
    -- CLICK
    tip.hand.doClick = function(callBack)
        local scale = SCALE_DEFAULT *0.9
        tip.handTransID = transition.to(tip.hand, { time = 100, xScale = scale, yScale = scale, onComplete = callBack })
    end
    
    -- UNCLICK
    tip.hand.undoClick = function(callBack)
        local scale = SCALE_DEFAULT
        tip.handTransID = transition.to(tip.hand, { time = 250, xScale = scale, yScale = scale, onComplete = callBack })
    end
        
    tip.hand.doActions = function(actions, isLoop, endFunc)
        tip.hand.isLoop = isLoop
        tip.hand.toDo = actions
        tip.hand.currentAction = 1
        tip.hand.endFunc = endFunc
        
        tip.hand.act = function()
            if tip.hand.currentAction > #tip.hand.toDo then
                if tip.hand.isLoop then
                    tip.hand.currentAction = 1
                else
                    if tip.hand.endFunc ~= nil then
                        tip.hand.endFunc()
                    end
                    
                    return
                end
            end 
            
            local myAction = tip.hand.toDo[tip.hand.currentAction]
            tip.hand.actions[myAction.action](tip.hand.act, myAction.params)
            
            tip.hand.currentAction = tip.hand.currentAction +1   
        end
        
        tip.hand.act()
    end
    
    tip.hand.actions = { ["appear"] = tip.hand.appear, ["disappear"] = tip.hand.disappear, ["move"] = tip.hand.move, ["click"] = tip.hand.doClick, ["unclick"] = tip.hand.undoClick }
    
    tip.group:insert(tip.hand)
end

tip.createCooper = function()
    
    tip.txtCooper = display.newImage("assets/cooper.png", 0, 0)
    tip.txtCooper:scale(SCALE_DEFAULT, SCALE_DEFAULT)
    --tip.txtCooper:setReferencePoint(display.CenterReferencePoint)
    tip.txtCooper.x, tip.txtCooper.y = tip.txtCooper.contentWidth *0.6, 0
    
    tip.txtTipGroup:insert(tip.txtCooper)
end

tip.createText = function(myText)
    
    local txtWidth = display.contentWidth - (tip.txtCooper.contentWidth *1.3)
    txtWidth = txtWidth +(4 - (txtWidth %4))
    
    tip.txtText = display.newText(myText, 0, 0, txtWidth, 0, INTERSTATE_REGULAR, 30 *SCALE_DEFAULT)
    tip.txtText:setFillColor(AZ.utils.getColor(INGAME_COMBO_COLOR))
    tip.txtText.anchorX, tip.txtText.anchorY = 0, 0.5 --:setReferencePoint(display.CenterLeftReferencePoint)
    tip.txtText.x, tip.txtText.y = tip.txtCooper.x + (tip.txtCooper.contentWidth *0.6), 0
    
    tip.txtTextGroup:insert(tip.txtText)
end

tip.changeTipText = function(myText)
    
    -- creem el text a mostrar
    tip.createText(myText)
    
    -- calculem el tamany del degradat
    local size = math.max(tip.txtText.height *0.8, tip.txtCooper.contentHeight *0.7)
    local halfSize = size *0.5
    local gradSize = SCALE_DEFAULT *100
    local gradColor = {0, 0, 0, 0.9}
    
    -- creem els 3 rects del degradat
    local function createGrad(posY, gradDirection)
        local sx, sy = display.contentWidth, gradSize
        
        local gradRect = display.newRect(sx *0.5, posY + sy *0.5, sx, sy)
        local grad = { type = "gradient", color1 = gradColor, color2 = {0, 0, 0, 0}, direction = gradDirection }
        gradRect:setFillColor(grad)
        return gradRect
    end
    
    local middleGradRect = display.newRect(display.contentCenterX, 0, display.contentWidth, size)
    middleGradRect:setFillColor(unpack(gradColor))
    local upperGradRect = createGrad(-(gradSize + halfSize), "up")
    local lowerGradRect = createGrad(halfSize, "down")
    
    -- reiniciem el text
    tip.txtText.text = ""
    
    -- insertem els 3 rects en el mateix grup
    tip.txtGradient = display.newGroup()
    tip.txtGradient:insert(upperGradRect)
    tip.txtGradient:insert(lowerGradRect)
    tip.txtGradient:insert(middleGradRect)
    
    -- acabem insertant el grup del gradient en el grup del text del tip
    tip.txtTextGroup:insert(tip.txtGradient)
    
    if not tip.isWaitingAction then
        if tip.txtTap == nil then
            tip.txtTap = display.newText("tap to continue", 0, 0, INTERSTATE_REGULAR, SCALE_SMALL *30)
            tip.txtTap.x = display.contentCenterX
            
            tip.txtTextGroup:insert(tip.txtTap)
        end
        
        tip.txtTap.y = lowerGradRect.y
        tip.txtTap.alpha = 0
    end
end

tip.createTipText = function(myText, posY)
    tip.changeTipText(myText)
    
    tip.txtTipGroup:insert(tip.txtTextGroup)
    tip.group:insert(tip.txtTipGroup)
    
    if tip.hand ~= nil then
        tip.hand:toBack()
    end
    
    tip.txtGradient:toFront()
    tip.txtText:toFront()
    tip.txtCooper:toFront()
    
    if tip.txtTap ~= nil then
        tip.txtTap:toFront()
    end
    
    tip.txtTipGroup.y = posY
end

tip.endWriting = function()
    tip.txtTimer = timer.safeCancel(tip.txtTimer)
    
    if tip.txtTap ~= nil then
        tip.txtTap.alpha = 1
    end
end

tip.forceEndWriting = function()
    tip.txtText.text = tip.changingText
    
    tip.endWriting()
end

tip.isWritingChar = function()
    return tip.txtText.text ~= tip.changingText
end

tip.canForce = function()
    return tip.tipTransID == nil
end

tip.canSkipTip = function()
    return not tip.isWaitingAction
end

tip.writeNextChar = function()
    tip.txtText.text = tip.changingText:sub(1, #tip.txtText.text +1)
    
    if #tip.txtText.text == #tip.changingText then
        tip.endWriting()
    else
        tip.txtTimer = timer.performWithDelay(20, tip.writeNextChar)
    end
end

tip.cancelTransition = function()
    tip.tipTransID = transition.safeCancel(tip.tipTransID)
    
    tip.txtTimer = timer.performWithDelay(20, tip.writeNextChar)
    
    if tip.handActions ~= nil then
        tip.hand.doActions(tip.handActions.actions, tip.handActions.isLoop, tip.handActions.endFunc)
    end
    
    if tip.gameplayActions ~= nil then
        tip.gameplay.actions[tip.gameplayActions.action](tip.gameplayActions.params)
    end
end

tip.changeTipListener = function()
    tip.txtGradient:removeSelf()
    tip.txtText:removeSelf()
    
    tip.txtGradient = nil
    tip.txtText = nil
    
    if tip.txtTap ~= nil then
        tip.txtTap:removeSelf()
        tip.txtTap = nil
    end
    
    local currentY = tip.txtTipGroup.y
    
    tip.createTipText(tip.changingText, tip.changingPosY)
    
    if tip.changingPosY == currentY then
        tip.tipTransID = transition.to(tip.txtTextGroup, { time = tip.transitionTime, alpha = 1, onComplete = tip.cancelTransition })
    else
        tip.tipTransID = transition.to(tip.txtTipGroup, { time = tip.transitionTime, alpha = 1, onComplete = tip.cancelTransition })
    end
end

tip.changeTip = function(myText, posY, handActions, gameplayActions)
    tip.timerID = transition.safeCancel(tip.tipTransID)
    tip.txtTimer = timer.safeCancel(tip.txtTimer)
    tip.handTransID = transition.safeCancel(tip.handTransID)
    tip.hand.disappear(nil, { time = 250 })
    
    tip.changingText, tip.changingPosY = myText, posY
    tip.handActions = handActions
    tip.gameplayActions = gameplayActions
    
    tip.isWaitingAction = (handActions ~= nil and handActions.endFunc ~= nil) or (gameplayActions ~= nil and gameplayActions.endFunc ~= nil)
    
    if tip.changingPosY == tip.txtTipGroup.y then
        tip.tipTransID = transition.to(tip.txtTextGroup, { time = tip.transitionTime, alpha = 0, onComplete = tip.changeTipListener })
    else
        tip.tipTransID = transition.to(tip.txtTipGroup, { time = tip.transitionTime, alpha = 0, onComplete = tip.changeTipListener })
    end
end

tip.destroy = function()
    tip.txtTipGroup:removeEventListener("touch", tip.txtTipGroup.handler)
    
    if tip.gameplay.isListening then
        print("elimino")
        Runtime:removeEventListener(GAMEPLAY_POWERUP_LOST, tip.gameplay.powerupHandler)
        Runtime:removeEventListener(GAMEPLAY_POWERUP_GET, tip.gameplay.powerupHandler)
    end
    
    tip.txtTimer = timer.safeCancel(tip.txtTimer)
    tip.tipTransID = transition.safeCancel(tip.tipTransID)
    tip.handTransID = transition.safeCancel(tip.handTransID)

    tip = nil
    
    return nil
end

tip.pause = function(isPause)
    transition.safePauseResume(tip.handTransID, isPause)
    transition.safePauseResume(tip.tipTransID, isPause)
    timer.safePauseResume(tip.txtTimer, isPause)
end

function initializeTip(ui, gameplay, myText, posY, handActions, gameplayActions, eventHandler)
    
    if tip.txtCooper ~= nil then
        return
    end
    
    tip._ui = ui
    tip._gameplay = gameplay
    tip._board = gameplay.getBoardModule()
    tip._zombies = gameplay.getZombieModule()
    
    tip.group = display.newGroup()
    tip.txtTipGroup = display.newGroup()
    tip.txtTextGroup = display.newGroup()
    
    tip.txtTipGroup:addEventListener("touch", eventHandler)
    tip.txtTipGroup.handler = eventHandler
    
    tip.isWaitingAction = (handActions ~= nil and handActions.endFunc ~= nil) or (gameplayActions ~= nil and gameplayActions.endFunc ~= nil)
    tip.handActions = handActions
    tip.gameplayActions = gameplayActions
    
    tip.createCooper()
    tip.createTipText(myText, posY)
    tip.createHand()
    tip.createGameplay()
    
    tip.changingText = myText
    tip.tipTransID = transition.from(tip.txtTipGroup, { time = tip.transitionTime, alpha = 0, onComplete = tip.cancelTransition })
    
    return tip
end