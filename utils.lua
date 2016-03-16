module(..., package.seeall)

isMultitouch = true
platform = ""
isVibrationEnabled = true

-- filtre per a invertir botons
local kernel = {}
kernel.name = "invertSaturate"
kernel.language = "glsl"
kernel.category = "filter"
kernel.graph =
{
    nodes = {
        horizontal = { effect = "filter.invert", input1 = "paint1" },
        vertical = { effect = "filter.grayscale", input1 = "horizontal" }
    },
    output = "vertical",
}
graphics.defineEffect(kernel)


local function matchLanguage(lang)
	
	local locals = nil
	
	if AZ.localization then
		locals = AZ.localization.languages
	else
		local l = AZ.jsonIO:readFile("configFiles/localization.json", true)
		locals = l.languages
	end
		
	for i=1, #locals do
		if lang == locals[i] then
			return lang
		end
	end
    
    return "en"
end

function getInitLanguage()
    local locale, pos = nil, nil
    
    if system.getInfo( "platformName" ) ~= "Android" then
        locale = string.lower(system.getPreference( "ui", "language" ))
        pos = string.find(locale,"-",0)
    else
        locale = string.lower(system.getPreference( "locale", "language" ))
        pos = string.find(locale,"_",0)
    end
    
    if not pos then
        return matchLanguage(locale)
    else
        -- substring fins a la posicio pos
        return matchLanguage(string.sub(locale, pos))
    end
end

function translate(word)
	if AZ.localization[word] then
		return AZ.localization[word][AZ.userInfo.language]
	else
		return false
	end
end

--function getTranslation(word)
--    return AZ.translations.translations[word][AZ.userInfo.currentLanguage]
--end

function getColor(c)
    local nc = {}

    for i = 1, #c do
        nc[i] = c[i] /255
    end

    return unpack(nc)
end

function unloadModule(m)
    package.loaded[m] = nil
    _G[m] = nil
    return nil
end

local _print = print

function print(t, variableName)

    variableName = variableName or "table"

    _print("----------------------------------------------------------------------------------------------------------------------------------")
    
    local function pd(v, vName)
        if v == nil then
            _print(vName .." = nil")
            return
        end

        if type(v) ~= "table" then
            _print(vName .." = ".. tostring(v))
            return
        end

        local function getPrintableValue(_v)
            if type(_v) == "string" then
                _v = "\"".. _v .."\""
            end

            return tostring(_v)
        end

        if #v ~= 0 then
            for i = 1, #v do
                local vn = vName .."[".. i .."]"

                if type(v[i]) == "table" then
                    pd(v[i], vn)
                else
                    _print(vn .." = ".. getPrintableValue(v[i]))
                end
            end
        else
            local pairsNum = 0
            for key, value in pairs(v) do

                pairsNum = pairsNum +1

                local vn = vName ..".".. key

                if type(value) == "table" then
                    if string.find(key, "__") == nil and key ~= "_tableListeners" and string.find(vName, key) == nil then
                        pd(value, vn)
                    end
                else
                    _print(vn .." = ".. getPrintableValue(value))
                end
            end

            if pairsNum == 0 then
                _print(vName .." = {}")
            end
        end
    end
    
    pd(t, variableName)
    _print("----------------------------------------------------------------------------------------------------------------------------------")
end

local function substractColor(tc, fc)
    local nc = {}

    for i = 1, math.max(#tc, #fc) do
        nc[i] = (tc[i] or 0) - (fc[i] or 0)
    end

    return nc
end

local function addMultipliedColor(c1, c2, mFactor)
    local nc = {}

    for i = 1, math.max(#c1, #c2) do
        nc[i] = (c1[i] or 0) + ((c2[i] or 0) * mFactor)
    end

    return nc
end

function colorTransition(obj, colorFrom, colorTo, params)

    colorFrom = colorFrom or { 1, 1, 1 }
    colorTo = colorTo or { 0, 0, 0 }
	
    local diffColor = substractColor(colorTo, colorFrom)

    local proxy = { step = 0 }

    local mt = {
        __index = function(t, k)
            return t["step"]
        end,

        __newindex = function(t, k, v)
            if(obj.setFillColor) then
				local newColor = addMultipliedColor(colorFrom, diffColor, v)
				obj:setFillColor(unpack(newColor))
				obj.color = newColor
            end
            t["step"] = v
        end
    }

    params = params or {}
    params.time = params.time or 1000
    params.colorScale = 1

    setmetatable(proxy, mt)

    return transition.to(proxy, params)
end

function assertParam(param, errorName, errorMessage)
    assert(param ~= nil and param ~= "", errorName ..": ".. errorMessage)
end

function testConnection()
    if require("socket").connect("google.com", 80) == nil then
        return false
    end

    return true
end

function activateDeactivateMultitouch(active)
    isMultitouch = active

    if active then
        system.activate("multitouch")
    else
        system.deactivate("multitouch")
    end
end

function setVibration(isEnabled)
    isVibrationEnabled = isEnabled
end

function vibrate()
    if isVibrationEnabled == true then
        system.vibrate()
    end
end

function getAbsolutePosition(obj)
    --Obtenim les coordenades absolutes de l'objecte
    --Utilitzem un displayGroup nou que es troba en el punt mÃ©s extern
    local currentParent = display.getCurrentStage()
    return obj:localToContent(currentParent.x, currentParent.y)
end

function getPosInGrp (object, targetGroup)
    --Volem saber les coordenades de l'objecte en el grup indicat
    local absX, absY = getAbsolutePosition(object);
    return targetGroup:contentToLocal(absX, absY);
end

function changeGroup (object, newParent)
    --Fem un canvi de grup d'un objecte, perÃ² mantenint la seva posiciÃ³ actual en pantalla
    local newX, newY = getPosInGrp(object, newParent)
    newParent:insert(object)
    object.x, object.y = newX, newY
end

function isPointInRect(x, y, bounds)
	return bounds.xMin < x and bounds.xMax > x and bounds.yMin < y and bounds.yMax > y
end

function createSlide(objs, params)
	
	local spacing = display.contentCenterX
	
	local grp = display.newGroup()
	grp.y = params.y or display.contentCenterY
	grp.onComplete = params.onComplete
	
	grp.objs = {}
	for i = 1, #objs do
		grp:insert(objs[i])
		table.insert(grp.objs, objs[i])
		
		objs[i].x = spacing * i
		objs[i].originalScaleX, objs[i].originalScaleY = objs[i].xScale, objs[i].yScale
	end
		
	local currentObjNum = 0
	local prevX = 0
	local transArray = {}
	local minScale = 0.6
	local minAlpha = 0.6
	local minTransTime = 250
	
	local function cancelTrans()
		for i = 1, #transArray do
			transArray[i] = transition.safeCancel(transArray[i])
		end
		transArray = {}
	end
	
	local function getCenteredObj()
		local nearestObj, nearestX
		
		for i = 1, #grp.objs do
			local dist = math.abs(spacing - grp.objs[i].x)
			if (not nearestX and not nearestObj) or nearestX > dist then
				nearestX = dist
				nearestObj = i
			end
		end
		
		return nearestObj
	end
	
	local function slideObjs(goingTo, t)
		cancelTrans()
		
		currentObjNum = goingTo
		local objX = math.abs(spacing - grp.objs[currentObjNum].x)
		
		t = t or minTransTime *2
		
		for i = 1, #grp.objs do
			local iDist = i - currentObjNum
			
			local scaleMultiplier = minScale
			local newAlpha = minAlpha
			if i == currentObjNum then
				scaleMultiplier = 1
				grp.objs[i]:toFront()
				newAlpha = 1
			end
			
			local scaleX, scaleY = grp.objs[i].originalScaleX * scaleMultiplier, grp.objs[i].originalScaleY * scaleMultiplier
			local newX = spacing + (spacing * iDist)
			
			local id = transition.to(grp.objs[i], { time = t, alpha = newAlpha, x = newX, xScale = scaleX, yScale = scaleY, transition = easing.outExpo })
			table.insert(transArray, id)
		end
		
		if grp.onComplete then
			grp.timerID = timer.safePerformWithDelay(grp.timerID, t, function() grp.onComplete(grp.objs[currentObjNum]) end)
		end
	end
	
	local isDragging = false
	
	local function onTouch(event)
		
		if event.phase == "began" then
			display.getCurrentStage():setFocus(event.target)
			event.target.isFocus = true
			prevX = event.x
			isDragging = false
			
		elseif event.target.isFocus then
			if event.phase == "moved" then
				
				if not isDragging then
					cancelTrans()
					isDragging = true
					for i = 1, #grp.objs do
						local scaleX, scaleY = grp.objs[i].originalScaleX * minScale, grp.objs[i].originalScaleY * minScale
						local id = transition.to(grp.objs[i], { time = minTransTime, alpha = 1, xScale = scaleX, yScale = scaleY, transition = easing.outExpo })
						table.insert(transArray, id)
					end
				end
				
				local delta = event.x - prevX
				prevX = event.x
				
				for i = 1, #grp.objs do
					grp.objs[i].x = grp.objs[i].x + delta
				end
				
			elseif event.phase == "ended" or event.phase == "cancelled" then
				isDragging = false
				
				local dragDist = event.x - event.xStart
				
				local nearest = getCenteredObj()
				
				if nearest == currentObjNum then
					if dragDist < -20 and currentObjNum < #grp.objs then
						slideObjs(nearest +1)
					elseif dragDist > 20 and currentObjNum > 1 then
						slideObjs(nearest -1)
					else
						slideObjs(nearest)
					end
				else
					slideObjs(nearest)
				end
				
				display.getCurrentStage():setFocus(nil)
				event.target.isFocus = false
			end
		end
		return true
	end
	
	grp.bg = display.newRect(display.contentCenterX, 0, display.contentWidth, grp.contentHeight *1.2)
	grp.bg.alpha = 0
	grp.bg.isHitTestable = true
	grp:insert(grp.bg)
	grp.bg:toBack()
	grp.bg:addEventListener("touch", onTouch)
	
	function grp:jumpTo(num, t)
		slideObjs(num, t)
	end
	
	function grp:takeFocus(event)
		display.getCurrentStage():setFocus(grp.bg)
		grp.bg.isFocus = true
		prevX = event.x
		isDragging = false
	end
	
	function grp:getCurrentObjNum()
		return currentObjNum
	end
	
	function grp:getCurrentObj()
		return grp.objs[currentObjNum]
	end
	
	function grp:destroy()
		cancelTrans()
		
		grp.timerID = timer.safeCancel(grp.timerID)
		
		grp.bg:removeEventListener("touch", onTouch)
		
		grp = nil
	end
	
	return grp
end

------------------------------------ addons ------------------------------------

                                                                        -- timer
timer.safePerformWithDelay = function(timerID, delay, listener, iterations)
    if type(timerID) == "number" then
        iterations = listener
        listener = delay
        delay = timerID
    else
        timerID = timer.safeCancel(timerID)
    end
    return timer.performWithDelay(delay, listener, iterations)
end
                                                                  
timer.safeCancel = function(timerID)
    if timerID ~= nil then
        timer.cancel(timerID)
    end

    return nil
end

timer.safePause = function(timerID)
    if timerID ~= nil then
        return timer.pause(timerID)
    end
end

timer.safeResume = function(timerID)
    if timerID ~= nil then
        return timer.resume(timerID)
    end
end

timer.safePauseResume = function(timerID, isPause)
    if isPause then
        return timer.safePause(timerID)
    else
        return timer.safeResume(timerID)
    end
end

                                                                   -- transition
transition.safeCancel = function(transitionID)
    if transitionID ~= nil then
        transition.cancel(transitionID)
    end

    return nil
end

transition.safePause = function(transitionID)
    if transitionID ~= nil then
        transition.pause(transitionID)
    end
end

transition.safeResume = function(transitionID)
    if transitionID ~= nil then
        transition.resume(transitionID)
    end
end

transition.safePauseResume = function(transitionID, isPause)
    if isPause then
        transition.safePause(transitionID)
    else
        transition.safeResume(transitionID)
    end
end

                                                                        -- table
table.copyDictionary = function(d)

    local newDictionary = {}

    if d == nil then
        return nil
    end

    if #d ~= 0 then
        for i = 1, #d do
            if type(d[i]) == "table" then
                newDictionary[i] = table.copyDictionary(d[i])
            else
                newDictionary[i] = d[i]
            end
        end
    else
        for key, value in pairs(d) do

            if type(value) == "table" then
                newDictionary[key] = table.copyDictionary(value)
            else
                newDictionary[key] = value
            end
        end
    end

    return newDictionary
end

local minusChars = { "à", "á", "â", "ã", "ä", "å", "æ", "ç", "è", "é", "ê", "ë", "ì", "í", "î", "ï", "ð", "ñ", "ò", "ó", "ô", "õ", "ö", "÷", "ø", "ù", "ú", "û", "ü", "ý", "þ", "ÿ" }
local majusChars = { "À", "Á", "Â", "Ã", "Ä", "Å", "Æ", "Ç", "È", "É", "Ê", "Ë", "Ì", "Í", "Î", "Ï", "Ð", "Ñ", "Ò", "Ó", "Ô", "Õ", "Ö", "÷", "Ø", "Ù", "Ú", "Û", "Ü", "Ý", "Þ", "ß" }

local _lower = string.lower
local _upper = string.upper

function string.lower(s)
    s = _lower(s)
    
    for i = 1, #minusChars do
        s = string.gsub(s, majusChars[i], minusChars[i])
    end
    
    return s
end

function string.upper(s)
    s = _upper(s)
    
    for i = 1, #majusChars do
        s = string.gsub(s, minusChars[i], majusChars[i])
    end
    
    return s
end

function math.clamp(value, min, max)
	min, max = min or 0, max or 1
	
	if value < min then
		return min
	elseif value > max then
		return max
	end
		
	return value
end

---Funcio coinFormat
--Aquesta funció ens permetrà donar el format 12.325 a les monedes que tenim
function coinFormat(c)
    local finalStr = ""
    local cStr = tostring(c)
    
    while #cStr > 2 do
        if finalStr == "" then
            finalStr = string.sub(cStr, #cStr-2, #cStr)
        else
            finalStr = string.sub(cStr, #cStr-2, #cStr) ..".".. finalStr
        end
        
        cStr = string.sub(cStr, 1, #cStr -3)
    end
    
    if #cStr > 0 and finalStr ~= "" then
        finalStr = cStr ..".".. finalStr
    elseif #cStr > 0 and finalStr == "" then
        finalStr = cStr
    end
    
    return finalStr
end