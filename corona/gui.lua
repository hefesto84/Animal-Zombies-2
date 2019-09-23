module(..., package.seeall)


function guiElement(sheet, imageName, positionX, positionY, scaleX, scaleY, referencePoint)

	local element
	local sheetInfo = AZ.atlas
	local imageSheet = graphics.newImageSheet(sheet, sheetInfo:getSheet())

	element = display.newImage( imageSheet, sheetInfo:getFrameIndex(imageName))
        print("passa'm un anchor!")
	element.anchorX, element.anchorY = 0.5, 0.5 --:setReferencePoint(referencePoint)
	element.x = positionX
	element.y = positionY
	element:scale(scaleX, scaleY)

	sheetInfo = nil
	imageSheet = nil

	return element
end

local function guiElementSwitchHandler(self, event)

    local result = true

    if event.phase == "began" then
        
        local statusOn      = self[1]
        local statusOff     = self[2]        
        local pressed       = false
        local parameter     = self.parameter     
        local configuration = self.configuration

        local value = 0
        
        self.configure(not statusOn.isVisible)
        
        --[[if statusOn.isVisible == true then
            statusOn.isVisible = false
            statusOff.isVisible = true
        else
            statusOff.isVisible = false 
            statusOn.isVisible = true
	end]]
        
        if statusOn.isVisible then
            value = 1
	end
        
        --[[if parameter == "sound" then
            -- fx
            AZ.audio.setFX(value == 1)
        elseif parameter == "music" then
            -- bso
            AZ.audio.setBSO(value == 1)
        else
            -- vibration
            AZ.utils.setVibration(value == 1)
            AZ.utils.vibrate()
        end]]
        
        ----FlurryController:logEvent("in_options", { type = parameter, value = strValue })
        
        --AZ.audio.playFX(self.sound, AZ.audio.AUDIO_VOLUME_BUTTONS)
        
        --configuration[parameter] = value
	--AZ.personal.savePersonalData(configuration, AZ.personal.genericInfo)
        
        local buttonEvent = {}
        buttonEvent.id, buttonEvent.phase, buttonEvent.state = self._id, event.phase, value
        
        result = self._onEvent(buttonEvent)
    end
    
    return result
end

--[[old
function guiElementSwitch(configuration, parameter, sheet, imageNameON, imageNameOFF, sound, positionX, positionY, scaleX, scaleY, referencePoint)

	local sheetInfo = AZ.atlas
	local imageSheet = graphics.newImageSheet(sheet, sheetInfo:getSheet())
        
	local button
	local buttonOn
	local buttonOff

	button = display.newGroup()

	buttonOn  = display.newImage(imageSheet, sheetInfo:getFrameIndex(imageNameON))
	buttonOff = display.newImage(imageSheet, sheetInfo:getFrameIndex(imageNameOFF))
        
	sheetInfo = nil
	imageSheet = nil
        
        button.sound = sound

	buttonOn.x  = positionX
	buttonOn.y  = positionY
	buttonOn:scale(scaleX,scaleY)

	buttonOff.x = positionX
	buttonOff.y = positionY
	buttonOff:scale(scaleX,scaleY)

	buttonOn.isVisible = true
	buttonOff.isVisible = false

	button:insert(buttonOn)
	button:insert(buttonOff)

	button.touch = guiElementSwitchHandler
	button.configuration = configuration
	button.parameter = parameter

	button:addEventListener("touch" , button)


	return button
end
]]
--arxiu de configuracio, parametre de l'arxiu, imatge, nom fons imatge ON, nom fons imatge OFF, text ON {text, font, size, color, X, Y}, nom text OFF {text, font, size, color, X, Y}, icona ON {name, X, Y}, icona OFF {name, X, Y}, so, X, Y, escalaX, escalaY, referencePoint
function guiElementSwitch(configuration, parameter, sheet, imageNameON, imageNameOFF, buttonText, iconON, iconOFF, sound, positionX, positionY, scaleX, scaleY, referencePoint, onEvent)

	local sheetInfo = AZ.atlas
	local imageSheet = graphics.newImageSheet(sheet, sheetInfo:getSheet())
        
	local button = display.newGroup()
        local on = display.newGroup()
        local off = display.newGroup()
        
        local buttonOn  = display.newImage(imageSheet, sheetInfo:getFrameIndex(imageNameON))
        buttonOn.anchorX, buttonOn.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
        on:insert(buttonOn)

        local icon = display.newImage(imageSheet, sheetInfo:getFrameIndex(iconON.name))
        icon.x = on.x - buttonOn.width / 2.75
        icon.y = on.y
        icon.anchorX = 0.5
        icon.anchorY = 0.5
        on:insert(icon)
                
	local buttonOff = display.newImage(imageSheet, sheetInfo:getFrameIndex(imageNameOFF))
        buttonOff.anchorX, buttonOff.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
        off:insert(buttonOff)

        icon = display.newImage(imageSheet, sheetInfo:getFrameIndex(iconOFF.name))
        icon.x = on.x - buttonOff.width / 2.75
        icon.y = on.y
        icon.anchorX = 0.5
        icon.anchorY = 0.5
        off:insert(icon)
        
        local myText = display.newText(buttonText.text, 0, 0, buttonText.font, buttonText.size)
        myText.anchorX, myText.anchorY = 0, 0.5
        myText.onOffColor = { buttonText.onColor, buttonText.offColor }
        myText:scale(scaleX, scaleY)
        
        button.changeTextColor = function(isOn)
            if isOn == true then
                local onColor = myText.onOffColor[1]
                myText:setFillColor(AZ.utils.getColor(onColor))
            else
                local onColor = myText.onOffColor[2]
                myText:setFillColor(AZ.utils.getColor(onColor))
            end
        end
        
        button.changeText = function(newText)
            local txt = button[3]
            txt.text = newText
            txt.anchorX, txt.anchorY = 0, 0.5 --:setReferencePoint(display.CenterLeftReferencePoint)
            --txt.x, txt.y = buttonText.X, buttonText.Y
        end
        
        button.configure = function(isOn)
            button[1].isVisible = isOn
            button[2].isVisible = not isOn
            
            button.changeTextColor(isOn)
        end
        
	sheetInfo = nil
	imageSheet = nil
        
        button.sound = sound
        
	on:scale(scaleX,scaleY)
	off:scale(scaleX,scaleY)
        
	button:insert(on)
	button:insert(off)

        --button.anchorX, button.anchorY = 0, 0.5 --:setReferencePoint(display.CenterReferencePoint)
        
        button:insert(myText)
    
        myText.anchorX = 0.5
        myText.anchorY = 0.5
        button.x = positionX
        button.y = positionY
        
	button.touch = guiElementSwitchHandler
	button.configuration = configuration
	button.parameter = parameter

        button._id = parameter
        button._onEvent = onEvent

	button:addEventListener("touch" , button)


	return button
end

--[[

-- Funció deprecatejada
--

function createShadowText(text, posX, posY, size)
    local myShadow = display.newText(text, 5 * SCALE_DEFAULT, 5 * SCALE_DEFAULT, HAUNT_AOE, size)
    local myText = display.newText(text, 0, 0, HAUNT_AOE, size)
    
    myShadow:setFillColor(INGAME_SCORE_COLOR[1], INGAME_SCORE_COLOR[2], INGAME_SCORE_COLOR[3])
    myText:setFillColor(INGAME_COMBO_COLOR[1], INGAME_COMBO_COLOR[2], INGAME_COMBO_COLOR[3])
    
    local myGroup = display.newGroup()
    
    myGroup:insert(myShadow)
    myGroup:insert(myText)
    
    myGroup.width = myGroup.width * 1.8
    
    myGroup.anchorX, myGroup.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    myGroup.x, myGroup.y = posX, posY
    
    return myGroup
end
]]--
