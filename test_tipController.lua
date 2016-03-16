local tipController = {}

tipController._tipGen = nil

tipController.tipNum = 1        -- tip actual
tipController.endTrans = nil    -- transició final

tipController.tipArray = nil    -- array de tips

-- variables necessaries per a canvis de tip
tipController.numZombies = 0
tipController.deadZombies = 0

local destroyed = false
local endFadeTime = 250

local easingTypes = { ["linear"] = easing.linear,
    ["inSine"] = easing.inSine,         ["inQuad"] = easing.inQuad,         ["inCubic"] = easing.inCubic,       ["inQuart"] = easing.inQuart,       ["inQuint"] = easing.inQuint,       ["inExpo"] = easing.inExpo,         ["inCirc"] = easing.inCirc,         ["inBack"] = easing.inBack,         ["inElastic"] = easing.inElastic,       ["inBounce"] = easing.inBounce,
    ["outSine"] = easing.outSine,       ["outQuad"] = easing.outQuad,       ["outCubic"] = easing.outCubic,     ["outQuart"] = easing.outQuart,     ["outQuint"] = easing.outQuint,     ["outExpo"] = easing.outExpo,       ["outCirc"] = easing.outCirc,       ["outBack"] = easing.outBack,       ["outElastic"] = easing.outElastic,     ["outBounce"] = easing.outBounce,
    ["inOutSine"] = easing.inOutSine,   ["inOutQuad"] = easing.inOutQuad,   ["inOutCubic"] = easing.inOutCubic, ["inOutQuart"] = easing.inOutQuart, ["inOutQuint"] = easing.inOutQuint, ["inOutExpo"] = easing.inOutExpo,   ["inOutCirc"] = easing.inOutCirc,   ["inOutBack"] = easing.inOutBack,   ["inOutElastic"] = easing.inOutElastic, ["inOutBounce"] = easing.inOutBounce,
    ["outInSine"] = easing.outInSine,   ["outInQuad"] = easing.outInQuad,   ["outInCubic"] = easing.outInCubic, ["outInQuart"] = easing.outInQuart, ["outInQuint"] = easing.outInQuint, ["outInExpo"] = easing.outInExpo,   ["outInCirc"] = easing.outInCirc,   ["outInBack"] = easing.outInBack,   ["outInElastic"] = easing.outInElastic, ["outInBounce"] = easing.outInBounce
}

-- destrucció del tip
function tipController:destroyTip()
    
	if destroyed then return end
	
	destroyed = true
	
    Runtime:removeEventListener(GAMEPLAY_PAUSE_EVNAME, tipController.pause)
    
	-- fem un regal final si toca
	local finalGift = tipController.tipArray.finalGift
	if finalGift then
		tipController._tipGen:finalGift(finalGift.weaponName, finalGift.weaponQuantity)
	end
	
    tipController._tipGen._ui.enableDisableWeaponButtons("all", true)

    -- eliminem el tip i descarreguem el modul del generador
    tipController._tipGen:destroy()
    tipController._tipGen = AZ.utils.unloadModule("test_tipGenerator")

    -- enviem un event, que rebrà l'ingame i dispararà el gameplay
	Runtime:dispatchEvent({ name = GAMEPLAY_FINISH_TIP_EVNAME })
end

-- funció que reseteja variables de canvi específic de tip
function tipController:tipStepSetup(t)
    
    tipController.numZombies = 0
    tipController.deadZombies = 0
    
    if t.gameplayActions ~= nil and t.gameplayActions.params ~= nil then
        if t.gameplayActions.params.zombies ~= nil then
            tipController.numZombies = #t.gameplayActions.params.zombies
        end
    end
end

-- canvi de tip
function tipController:nextTip()
	
    tipController.tipNum = tipController.tipNum + 1
       
    -- si el tip actual es menor o igual a la quantitat de tips...
    if tipController.tipNum <= #tipController.tipArray.steps then
        local t = tipController.tipArray.steps[tipController.tipNum]
		
        -- ...el canviem
        tipController._tipGen:newTipStep(AZ.utils.translate(t.message), t.pos, t.handActions, t.gameplayActions)
        
        -- ...i actualitzem els zombies d'aquest pas del tip
        tipController:tipStepSetup(t)
        
    -- ...si no, i si la transició final encara no s'ha fet...
    elseif tipController.endTrans == nil then
        -- ...fem la transició, amb callback apuntant a la destrucció del tip
		tipController._tipGen:forceEnd(endFadeTime)
        tipController.endTrans = transition.to(tipController._tipGen.grp, { time = endFadeTime, alpha = 0, onComplete = function() tipController:destroyTip() end })
    end
end

function tipController:forceEnd()
	tipController._tipGen:forceEnd(endFadeTime)
	tipController.endTrans = transition.to(tipController._tipGen.grp, { time = endFadeTime, alpha = 0, onComplete = function() tipController:destroyTip() end })
end

-- funció que controla el touch al tip
function tipController:tipEventHandler(event)
    -- si hem aixecat el dit i podem forçar el tip...
    if event.phase == "ended" then
		
        -- ...i si encara estem escribint el tip...
        if tipController._tipGen:isWriting() then
			-- ...forcem que acabi d'escriure'l
			tipController._tipGen:endWriting(true)
            
        -- ...si ha acabat d'escriure i podem saltar de tip...
        elseif tipController._tipGen:canSkip() then
			print("touchFunc")
			-- ...anem al següent
			AZ.audio.playFX(AZ.soundLibrary.tipNextSound, AZ.audio.AUDIO_VOLUME_BUTTONS)
			tipController:nextTip()
        end
    end
    
    return true
end

function tipController:killZombiesToSkipTip()
    tipController.deadZombies = tipController.deadZombies + 1
    
    if tipController.deadZombies == tipController.numZombies then
		tipController:nextTip()
    end
end

function tipController:getEndFuncByString(f)
	
	if type(f) == "function" then
		return f
	end
	
    if f == "nextTip" then
        return function() tipController:nextTip() end
    elseif f == "voidFunc" then
        return function() end
    elseif f == "killZombieToSkipTip" then
        return function() tipController:killZombiesToSkipTip() end
    end
    
    print("WARNING", "", "No hi ha una funció de tip: ".. tostring(f))
    return nil
end

function tipController:getEasingByString(e)
    local easing = easingTypes[e]
    if not easing then
        easing = easingTypes["linear"]
        print("WARNING", "", "No hi ha un easing de tip: ".. tostring(e))
    end
    return easing
end

function tipController:tipSetup(tipsJson, tipName)
    
    local tipInfo = table.copyDictionary(tipsJson.types[tipName])
    
    local gameplayActions = table.copyDictionary(tipsJson.gameplayActions)
    local handActions = table.copyDictionary(tipsJson.handActions)
    
    for i = 1, #tipInfo.steps do
        
		local step = tipInfo.steps[i]
		
        local g = step.gameplayActions
        local h = step.handActions
        
        step.pos = math.floor(display.contentHeight * step.pos)
        
        if g and g ~= "none" then
            -- setegem les accions del gameplay
            if type(g) == "string" then
				local gStr = g
				g = gameplayActions[g]
				if not g then
					print("ERROR", "", "No hi ha un gameplayAction: ".. tostring(gStr))
				end
            end
                
            -- setegem endFunc si cal
            if g.params and g.params.zombies then
				local anyZombieFunc = false
				for i = 1, #g.params.zombies do
					if g.params.zombies[i].endFunc then
						g.params.zombies[i].endFunc = tipController:getEndFuncByString(g.params.zombies[i].endFunc)
						anyZombieFunc = true
					end
				end
				if anyZombieFunc then
					g.endFunc = g.endFunc or "voidFunc"
				end
			end
			
			if g.params ~= nil and g.params.endFunc ~= nil then
				g.params.endFunc = tipController:getEndFuncByString(g.params.endFunc)
                g.endFunc = tipController:getEndFuncByString("voidFunc")
            elseif g.endFunc ~= nil then
				 g.endFunc = tipController:getEndFuncByString(g.endFunc)
            end
        else
            -- no existeix accions de gameplay
            g = nil
        end

        if h and h ~= "none" then
            -- setegem les accions de la mà
            if type(h) == "string" then
				local hStr = h
                h = handActions[h]
				if not h then
					print("ERROR", "", "No hi ha un handAction: ".. tostring(hStr))
				end
            end
            
            for _i = 1, #h.actions do
                local actionParams = h.actions[_i].params
                
                if actionParams ~= nil then
                    -- setegem posició si cal
                    if actionParams.x ~= nil and actionParams.y ~= nil then
                        actionParams.x, actionParams.y = display.contentWidth * actionParams.x, display.contentHeight * actionParams.y
                    end
                    -- setegem easing si cal
                    if actionParams.easing ~= nil then
                        actionParams.easing = tipController:getEasingByString(actionParams.easing)
                    end
                    h.actions[_i].params = actionParams
                end
            end
            -- setegem endFunc si cal
            if h.endFunc ~= nil then
                h.endFunc = tipController:getEndFuncByString(h.endFunc)
            end
        else
            h = nil
        end
        
        step.gameplayActions = g
        step.handActions = h
    end
    
    return tipInfo
end

function tipController.pause(event)
    transition.safePauseResume(tipController.endTrans, event.isPause)
    tipController._tipGen:pause(event.isPause)
end

-- funció d'inicialització del tip
function tipController:initialize(tipsJson, tipName, ui, gameplay)
    
	destroyed = false
	
    local tipInfo = tipController:tipSetup(tipsJson, tipName)
    
    tipController._tipGen = require "test_tipGenerator"

    tipController.tipNum = 1
    tipController.endTrans = nil

    tipController.numZombies = 0
    tipController.deadZombies = 0

    tipController.tipArray = tipInfo
    
    local t = tipController.tipArray.steps[tipController.tipNum]
    local tipGrp = tipController._tipGen:init(ui, gameplay, AZ.utils.translate(t.message), t.pos, t.handActions, t.gameplayActions, function(event) return tipController:tipEventHandler(event) end, function() tipController:forceEnd() end)
    
    tipController:tipStepSetup(t)
    
    Runtime:addEventListener(GAMEPLAY_PAUSE_EVNAME, tipController.pause)
    
    return tipGrp
end

return tipController