module(..., package.seeall)

require "config"
-----------------
-- Helper function for newButton utility function below
local function newButtonHandler( self, event )
    
    local result = true
    
    local default = self.default
    local over = self.over
    local text = self.defaultText
    
    -- General "onEvent" function overrides onPress and onRelease, if present
    local onTouch = self._onTouch
    local onEvent = self._onEvent
    
    local onPress = self._onPress
    local onRelease = self._onRelease
    
    local buttonEvent = {}
    if (self._id) then
        buttonEvent.id = self._id
    end
    
    local phase = event.phase
    if "began" == phase and self.isActive == true then
        if over then
            default.isVisible = false
            over.isVisible = true
        elseif self.pressedFilter then
            default.fill.effect = self.pressedFilter
            default.fill.effect.vertical.intensity = 0
        end
        
        if text ~= nil and text.pressedColor ~= nil then
            text:setFillColor(AZ.utils.getColor(text.pressedColor))
        end
        
        if onEvent then
            buttonEvent.phase = "press"
            result = onEvent( buttonEvent )
            --
            AZ.audio.playFX(self.sound, AZ.audio.AUDIO_VOLUME_BUTTONS)
            --
		elseif onTouch then
			AZ.audio.playFX(self.sound, AZ.audio.AUDIO_VOLUME_BUTTONS)
        elseif onPress then
            result = onPress( event )
        end
        
        -- Subsequent touch events will target button even if they are outside the stageBounds of button
        display.getCurrentStage():setFocus( self, event.id )
        self.isFocus = true
        
    elseif self.isFocus then
        local bounds = self.stageBounds
        local x,y = event.x,event.y
        local isWithinBounds = bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y
        
        if "moved" == phase then
            if over then
                -- The rollover image should only be visible while the finger is within button's stageBounds
                default.isVisible = not isWithinBounds
                over.isVisible = isWithinBounds
            end
            
            if self.pressedFilter then
                if isWithinBounds then
                    default.fill.effect = self.pressedFilter
                    default.fill.effect.vertical.intensity = 0
                else
                    default.fill.effect = nil
                end
            end
            
            if self.hasText ~= nil then
                if isWithinBounds then
                    text:setFillColor(AZ.utils.getColor(text.pressedColor))
                else
                    text:setFillColor(AZ.utils.getColor(text.unpressedColor))
                end
            end
            
        elseif "ended" == phase or "cancelled" == phase then
            if over then
                default.isVisible = true
                over.isVisible = false
            else
                default.fill.effect = nil
            end
            
            if text ~= nil and text.unpressedColor ~= nil then
                text:setFillColor(AZ.utils.getColor(text.unpressedColor))
            end
            
            if "ended" == phase then
                -- Only consider this a "click" if the user lifts their finger inside button's stageBounds
                if isWithinBounds then
                    if onEvent then
                        buttonEvent.phase = "release"
                        result = onEvent( buttonEvent )
                    elseif onRelease then
                        result = onRelease( event )
                    end
                end
            end
            
            -- Allow touch events to be sent normally to the objects they "hit"
            display.getCurrentStage():setFocus( self, nil )
            self.isFocus = false
        end
    end
    
    if onTouch then
        result = onTouch(event)
    end
    
    return result
end
--text {text="bla", fontName = "marieta", fontSize = 66, X = 0, Y = 0, color = {255,255,255,255}}
-- funcio que comproba que tingui parametres necessaris per crear text i retorna un display.text
function crearText(text)
    if text ~= nil and text.text ~= nil and  text.fontName ~= nil and text.fontSize ~= nil then
        if text.X == nil then
            text.X = 0
        end
        if text.Y == nil then
            text.Y = 0
        end
        if text.color == nil then
            text.color = { 1, 1, 1, 1}
        end
        local txt = display.newText( text.text, text.X, text.Y, text.fontName, text.fontSize )
        txt.anchorX, txt.anchorY = 0.5, 1 --:setReferencePoint(display.BottomCenterReferencePoint)
        txt.x = text.X
        txt.y = text.Y
        txt:setFillColor(AZ.utils.getColor(text.color))
        if text.color ~= nil then
            txt.unpressedColor = text.color
        else
            txt.unpressedColor = text.altColor
        end
        
        if text.altColor ~= nil then
            txt.pressedColor = text.altColor
        else
            txt.pressedColor = text.color
        end
        
        return txt
    end
    
    return nil
end

---------------
-- Button class modificat pel levels.lua

---------------
-- Button class

function newEnhancedButton2( params )
    local button = display.newGroup()
    
    --local sheetInfo = AZ.atlas

    if params.unpressedIndex then
        --local unpressedIndex, unpressedSheet = sheetInfo:getFrameIndexAndSpriteSheet(params.unpressed)
        local default = display.newImage(params.myImageSheet, params.unpressedIndex, params.x, params.y)
        
        button:insert(default, true)
        button.default = default
    end
    
    if params.pressedIndex then
        --local pressedIndex, pressedSheet = sheetInfo:getFrameIndexAndSpriteSheet(params.pressed)
        local over = display.newImage(params.myImageSheet, params.pressedIndex, params.x, params.y)
        over.isVisible = false
        button:insert(over, true)
        button.over = over
    end
    
    -- Public methods
    
    if ( params.onPress and ( type(params.onPress) == "function" ) ) then
        button._onPress = params.onPress
    end
    if ( params.onRelease and ( type(params.onRelease) == "function" ) ) then
        button._onRelease = params.onRelease
    end
    
    if (params.onEvent and ( type(params.onEvent) == "function" ) ) then
        button._onEvent = params.onEvent
    elseif params.onTouch and type(params.onTouch) == "function" then
        button._onTouch = params.onTouch
    end
    
    -- set button to active (meaning, can be pushed)
    button.isActive = true
    
    -- Set button as a table listener by setting a table method and adding the button as its own table listener for "touch" events
    button.touch = newButtonHandler
    
    button.sound = params.sound
    button:addEventListener("touch", button)
    
    if params.x then
        button.x = params.x
    end
    
    if params.y then
        button.y = params.y
    end
    
    if params.id then
        button._id = params.id
    end
    
    -- Modificació per a afegir text als botons
    local t1 = crearText(params.text1)
    if t1 ~= nil then
        button.hasText = true
        button:insert(t1, true)
        t1.y = params.text1.Y
        t1.x = params.text1.X
        
        button.defaultText = t1
        
        local t2 = crearText(params.text2)
        if t2 ~= nil then
            button:insert(t2, true)
            t2.y = params.text2.Y
            t2.x = params.text2.X
            
            button.overText = t2
        end
    end
    
    return button
end

---------------
-- Button class

function newEnhancedButton( params )
    local button = display.newGroup()
    
    local sheetInfo = AZ.atlas
    
    if params.unpressed then
        local default = nil
        if type(params.unpressed) == "string" then
            default = display.newImage(params.unpressed, params.x, params.y)
        else
            local unpressedIndex, unpressedSheet = sheetInfo:getFrameIndexAndSpriteSheet(params.unpressed)
            default = display.newImage(graphics.newImageSheet(unpressedSheet, sheetInfo:getSheet()), unpressedIndex, params.x, params.y)
        end
        
        button:insert(default, true)
        button.default = default
    else
        print("dafuq? estas creant un botó sense imatge??")
    end
    
    if params.pressed then
        local over = nil
        if type(params.pressed) == "string" then
            over = display.newImage(params.pressed, params.x, params.y)
        else
            local pressedIndex, pressedSheet = sheetInfo:getFrameIndexAndSpriteSheet(params.pressed)
            over = display.newImage(graphics.newImageSheet(pressedSheet, sheetInfo:getSheet()), pressedIndex, params.x, params.y)
        end
        
        over.isVisible = false
        button:insert(over, true)
        button.over = over
    else
        button.pressedFilter = params.pressedFilter
    end
    
    -- Public methods
    
    if ( params.onPress and ( type(params.onPress) == "function" ) ) then
        button._onPress = params.onPress
    end
    if ( params.onRelease and ( type(params.onRelease) == "function" ) ) then
        button._onRelease = params.onRelease
    end
    
    if (params.onEvent and ( type(params.onEvent) == "function" ) ) then
        button._onEvent = params.onEvent
    elseif params.onTouch and type(params.onTouch) == "function" then
        button._onTouch = params.onTouch
    end
    
    -- set button to active (meaning, can be pushed)
    button.isActive = true
    
    -- Set button as a table listener by setting a table method and adding the button as its own table listener for "touch" events
    button.touch = newButtonHandler
    
    button.sound = params.sound
    button:addEventListener("touch", button)
    
    
    if params.x then
        button.x = params.x
    end
    
    if params.y then
        button.y = params.y
    end
    
    if params.id then
        button._id = params.id
    end
    
    -- Modificacion para aï¿½adir texto a los botones
    local t1 = crearText(params.text1)
    if t1 ~= nil then
        button.hasText = true
        button:insert(t1, true)
        t1.y = params.text1.Y
        t1.x = params.text1.X
        
        button.defaultText = t1
        
        local t2 = crearText(params.text2)
        if t2 ~= nil then
            button:insert(t2, true)
            t2.y = params.text2.Y
            t2.x = params.text2.X
            
            button.overText = t2
        end
    end
    
    return button
end

---------------
-- Button class

function newButton( params )
    local button, defaultSrc , defaultX , defaultY , overSrc , overX , overY , size, font, textColor, offset
    
    
    if params.defaultSrc then
        button = display.newGroup()
        default = display.newImageRect ( params.defaultSrc , params.defaultX , params.defaultY )
        button:insert( default, true )
    end
    
    if params.overSrc then
        over = display.newImageRect ( params.overSrc , params.overX , params.overY )
        over.isVisible = false
        button:insert( over, true )
    end
    
    -- Public methods
    function button:setText( newText )
        
        local labelText = self.text
        if ( labelText ) then
            labelText:removeSelf()
            self.text = nil
        end
        
        local labelShadow = self.shadow
        if ( labelShadow ) then
            labelShadow:removeSelf()
            self.shadow = nil
        end
        
        local labelHighlight = self.highlight
        if ( labelHighlight ) then
            labelHighlight:removeSelf()
            self.highlight = nil
        end
        
        if ( params.size and type(params.size) == "number" ) then size=params.size else size=SMALL_FONT_SIZE end
        if ( params.font ) then font=params.font else font=native.systemFontBold end
        if ( params.textColor ) then textColor=params.textColor else textColor={ 1, 1, 1, 1 } end
        
        size = size * 2
        
        -- Optional vertical correction for fonts with unusual baselines (I'm looking at you, Zapfino)
        if ( params.offset and type(params.offset) == "number" ) then offset=params.offset else offset = 0 end
        
        if ( params.emboss ) then
            -- Make the label text look "embossed" (also adjusts effect for textColor brightness)
            local textBrightness = ( textColor[1] + textColor[2] + textColor[3] ) * 0.33
            
            labelHighlight = display.newText( newText, 0, 0, font, size )
            if ( textBrightness > 127) then
                labelHighlight:setFillColor( 1, 1, 1, 20/255 )
            else
                labelHighlight:setFillColor( 1, 1, 1, 140/255 )
            end
            button:insert( labelHighlight, true )
            labelHighlight.x = labelHighlight.x + 1.5; labelHighlight.y = labelHighlight.y + 1.5 + offset
            self.highlight = labelHighlight
            
            labelShadow = display.newText( newText, 0, 0, font, size )
            if ( textBrightness > 127) then
                labelShadow:setFillColor( 0, 0, 0, 0.5 )
            else
                labelShadow:setFillColor( 0, 0, 0, 20/255 )
            end
            button:insert( labelShadow, true )
            labelShadow.x = labelShadow.x - 1; labelShadow.y = labelShadow.y - 1 + offset
            self.shadow = labelShadow
            
            labelHighlight.xScale = .5; labelHighlight.yScale = .5
            labelShadow.xScale = .5; labelShadow.yScale = .5
        end
        
        labelText = display.newText( newText, 0, 0, font, size )
        labelText:setFillColor(AZ.utils.getColor(textColor))
        button:insert( labelText, true )
        labelText.y = labelText.y + offset
        self.text = labelText
        
        labelText.xScale = .5; labelText.yScale = .5
    end
    
    if params.text then
        button:setText( params.text )
    end
    
    if ( params.onPress and ( type(params.onPress) == "function" ) ) then
        button._onPress = params.onPress
    end
    if ( params.onRelease and ( type(params.onRelease) == "function" ) ) then
        button._onRelease = params.onRelease
    end
    
    if (params.onEvent and ( type(params.onEvent) == "function" ) ) then
        button._onEvent = params.onEvent
    end
    
    -- set button to active (meaning, can be pushed)
    button.isActive = true
    
    -- Set button as a table listener by setting a table method and adding the button as its own table listener for "touch" events
    button.touch = newButtonHandler
    button:addEventListener( "touch", button )
    
    if params.x then
        button.x = params.x
    end
    
    if params.y then
        button.y = params.y
    end
    
    if params.id then
        button._id = params.id
    end
    
    return button
end


--------------
-- Label class

function newLabel( params )
    local labelText
    local size, font, textColor, align
    local t = display.newGroup()
    
    if ( params.bounds ) then
        local bounds = params.bounds
        local left = bounds[1]
        local top = bounds[2]
        local width = bounds[3]
        local height = bounds[4]
        
        if ( params.size and type(params.size) == "number" ) then size=params.size else size=20 end
        if ( params.font ) then font=params.font else font=native.systemFontBold end
        if ( params.textColor ) then textColor=params.textColor else textColor={ 255, 255, 255, 255 } end
        if ( params.offset and type(params.offset) == "number" ) then offset=params.offset else offset = 0 end
        if ( params.align ) then align = params.align else align = "center" end
        
        if ( params.text ) then
            labelText = display.newText( params.text, 0, 0, font, size )
            labelText:setFillColor(AZ.utils.getColor(textColor))
            t:insert( labelText )
            -- TODO: handle no-initial-text case by creating a field with an empty string?
            
            if ( align == "left" ) then
                labelText.x = left + labelText.stageWidth * 0.5
            elseif ( align == "right" ) then
                labelText.x = (left + width) - labelText.stageWidth * 0.5
            else
                labelText.x = ((2 * left) + width) * 0.5
            end
        end
        
        labelText.y = top + labelText.stageHeight * 0.5
        
        -- Public methods
        function t:setText( newText )
            if ( newText ) then
                labelText.text = newText
                
                if ( "left" == align ) then
                    labelText.x = left + labelText.stageWidth * 0.5
                elseif ( "right" == align ) then
                    labelText.x = (left + width) - labelText.stageWidth * 0.5
                else
                    labelText.x = ((2 * left) + width) * 0.5
                end
            end
        end
        
        function t:setFillColor( r, g, b, a )
            local newR = 255
            local newG = 255
            local newB = 255
            local newA = 255
            
            if ( r and type(r) == "number" ) then newR = r end
            if ( g and type(g) == "number" ) then newG = g end
            if ( b and type(b) == "number" ) then newB = b end
            if ( a and type(a) == "number" ) then newA = a end
            
            labelText:setFillColor( r, g, b, a )
        end
    end
    
    -- Return instance (as display group)
    return t
    
end

local function textButtonHandler(self, event)
    
    local result = true
    
    local txt = self[2]
    local onEvent = self._onEvent
    local onPress = self._onPress
    
    local buttonEvent = {}
    if (self._id) then
        buttonEvent.id = self._id
    end
    
    local phase = event.phase
    buttonEvent.phase = event.phase
    
    if "began" == phase and self.isActive == true then
        
        txt.changeColor(true)
        
        if onEvent then
            result = onEvent( buttonEvent )
        elseif onPress then
            buttonEvent.phase = "press"
            result = onPress( buttonEvent )
        end
        
        AZ.audio.playFX(self.sound, AZ.audio.AUDIO_VOLUME_BUTTONS)
        
        -- Subsequent touch events will target button even if they are outside the stageBounds of button
        display.getCurrentStage():setFocus( self, event.id )
        self.isFocus = true
        
    elseif self.isFocus then
        local bounds = self.stageBounds
        local x,y = event.x,event.y
        local isWithinBounds = bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y
        
        if "moved" == phase then
            txt.changeColor(isWithinBounds)
            
            if onEvent then
                result = onEvent( buttonEvent )
            elseif onPress then
                buttonEvent.phase = "release"
                result = onPress( buttonEvent )
            end
            
        elseif "ended" == phase or "cancelled" == phase then
            txt.changeColor(false)
            
            if phase == "ended" and isWithinBounds then
                if onEvent then
                    result = onEvent( buttonEvent )
                elseif onPress then
                    buttonEvent.phase = "release"
                    result = onPress( buttonEvent )
                end
            end
            
            -- Allow touch events to be sent normally to the objects they "hit"
            display.getCurrentStage():setFocus( self, nil )
            self.isFocus = false
        end
    end
    
    return result
    
end

--params: txt, font, size, "referencePoint", x, y, unpressedColor, pressedColor, "onPress", "onEvent", sound, "id"
function newTextButton(params)
    local button = display.newGroup()
    
    local txtShadow = display.newText(params.txt, 5 * SCALE_BIG, 5 * SCALE_BIG, params.font, params.size)
    txtShadow:setFillColor(AZ.utils.getColor(params.pressedColor))
    txtShadow.col = params.pressedColor
    
    local txtBtn = display.newText(params.txt, 0, 0, params.font, params.size)
    txtBtn:setFillColor(AZ.utils.getColor(params.unpressedColor))
    txtBtn.col = params.unpressedColor
    
    txtBtn.changeColor = function(isPressed)
        
        if isPressed ~= txtBtn.isPressed then
            local txtColor, shaColor = txtBtn.col, txtShadow.col
            
            txtShadow:setFillColor(AZ.utils.getColor(txtColor))
            txtShadow.col = txtColor
            
            txtBtn:setFillColor(AZ.utils.getColor(shaColor))
            txtBtn.col = shaColor
            
            txtBtn.isPressed = isPressed
        end
    end
    
    button:insert(txtShadow)
    button:insert(txtBtn)
    button.anchorX, button.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    if button.referencePoint ~= nil then
        print("a ver moderfuquer, has intentat fotre un referencePoint en el text d'un botó, però s'ha d'afegir un anchorPoint")
        --button:setReferencePoint(params.referencePoint)
    end
    button.x, button.y = params.x, params.y
    
    -- Public methods
    
    if ( params.onPress and ( type(params.onPress) == "function" ) ) then
        button._onPress = params.onPress
    end
    if (params.onEvent and ( type(params.onEvent) == "function" ) ) then
        button._onEvent = params.onEvent
    end
    
    -- set button to active (meaning, can be pushed)
    button.isActive = true
    
    -- Set button as a table listener by setting a table method and adding the button as its own table listener for "touch" events
    button.touch = textButtonHandler
    
    button.sound = params.sound
    button:addEventListener("touch", button)
    
    if params.id then
        button._id = params.id
    end
    
    return button
end


--------------------------------------------------------------------------------

local function createText(params)
    
    if params and params.text and params.fontName and params.fontSize then
        
        local txt = display.newText(params.text, params.x or 0, params.y or 0, params.fontName, params.fontSize)
        txt.anchorX, txt.anchorY = 0.5, 1
        
        txt.color = params.color or { 1, 1, 1, 1 }
        txt.altColor = params.altColor or { 0, 0, 0, 1 }
        
        txt:setFillColor(AZ.utils.getColor(txt.color))
        
        return txt
    end
    
    return nil
end

function newSuperButton(params)
    
    local button = display.newGroup()
    button.x, button.y = params.x or 0, params.y or 0
    
    if params.unpressed then
        
        local default = display.newImage(params.imageSheet, params.unpressed, 0, 0)
        
        button:insert(default)
        button.default = default
    end
    
    if params.pressed then
        
        local over = display.newImage(params.imageSheet, params.pressed, 0, 0)
        over.isVisible = false
        
        button:insert(over)
        button.over = over
    else
        button.pressedFilter = params.pressedFilter
    end
    
    if params.onTouch and type(params.onTouch) == "function" then
        button._onTouch = params.onTouch
    end
    
    -- set button to active (meaning, can be pushed)
    button.isActive = true
    
    -- Set button as a table listener by setting a table method and adding the button as its own table listener for "touch" events
    button.touch = newButtonHandler
    
    button.sound = params.sound
    button:addEventListener("touch", button)
    
    
    if params.id then
        button._id = params.id
    end
    
    local txt = createText(params.txt)
    if txt then
        button:insert(txt)
    end
    
    return button
end

local function touchableBtnHandler(event)
	
	local target = event.target
	
	local function btnTrans(isTouched)
		if not target.isActive then return end
		
		target.colTransID = transition.safeCancel(target.colTransID)
		target.transID = transition.safeCancel(target.transID)
		
		if isTouched then
			if target.btnImg then target.colTransID = AZ.utils.colorTransition(target.btnImg, target.btnImg.color, { 0.8, 0.8, 0.8 }, { time = 100 }) end
			target.transID = transition.to(target, { time = 300, xScale = target.originalXScale *0.85, yScale = target.originalYScale *0.85, transition = easing.outElastic })
		else
			if target.btnImg then target.colTransID = AZ.utils.colorTransition(target.btnImg, target.btnImg.color, { 1, 1, 1 }, { time = 100 }) end
			target.transID = transition.to(target, { time = 500, xScale = target.originalXScale, yScale = target.originalYScale, transition = easing.outElastic })
		end
	end
	
	if event.phase == "began" then
		display.getCurrentStage():setFocus(target, event.id)
		target.isWithinBounds = true
		target.isFocused = true
		target.bounds = target.contentBounds
		
		if target.touchSound then AZ.audio.playFX(target.touchSound, AZ.audio.AUDIO_VOLUME_BUTTONS) end
		
		btnTrans(true)
		
		return target.callback(event)
		
	elseif target.isFocused then
		
		if event.phase == "moved" then
			
			if target.isWithinBounds ~= AZ.utils.isPointInRect(event.x, event.y, target.bounds) then
				target.isWithinBounds = not target.isWithinBounds
				
				btnTrans(target.isWithinBounds)
			end
		else
			--if target.isWithinBounds and target.touchSound then AZ.audio.playFX(target.touchSound, AZ.audio.AUDIO_VOLUME_BUTTONS) end
			if target.isWithinBounds and target.releaseSound then AZ.audio.playFX(target.releaseSound, AZ.audio.AUDIO_VOLUME_BUTTONS) end
			
			display.getCurrentStage():setFocus(nil, event.id)
			target.isFocused = false
			
			btnTrans(false)
		end
		
		if not event.isForceEnded then
			return target.callback(event)
		end
	end
end

function newTouchButton(params)
	
	local button = display.newGroup()
	button.x, button.y = params.x or 0, params.y or 0
	
	local function createBtnImg(imgIndex, layer, x, y)
		if imgIndex then
			local img = display.newImage(params.imageSheet, imgIndex)
			img.x, img.y = x or 0, y or 0
			button[layer] = img
			button:insert(img)
		end
	end
	createBtnImg(params.btnIndex, "btnImg")
	createBtnImg(params.iconIndex, "iconImg", params.iconX, params.iconY)
	
	if params.txtParams then
		params.txtParams.color = params.txtParams.color or { 1, 1, 1 }
		
		button.txt = display.newText(params.txtParams)
		button.txt:setFillColor(AZ.utils.getColor(params.txtParams.color))
		button.txt.anchorX, button.txt.anchorY = params.txtParams.anchorX or 0.5, params.txtParams.anchorY or 0.5
		button:insert(button.txt)
	end
	
	button.id = params.id or "touchButton default id"
	
	if params.onTouch and type(params.onTouch) == "function" then
		button.callback = params.onTouch
	else
		button.callback = function(event) print(event.target.id .." button has no callback function") end
	end
	
	button.isActive = true
	
	button.touchSound = params.touchSound
	button.releaseSound = params.releaseSound
	button:addEventListener("touch", touchableBtnHandler)
	
	function button:forceEnded()
		touchableBtnHandler({ target = button, phase = "ended", isForceEnded = true })
	end
	
	function button:setScale(xScale, yScale)
		button.originalXScale, button.originalYScale = xScale, yScale
		button:scale(xScale, yScale)
	end
	button:setScale(1, 1)
	
	return button
end

function createShadowText(text, posX, posY, size, w)
    local txtGrp = display.newGroup()
    
	w = w or 0
	
	txtGrp:insert(display.newText({ text = text, x = SCALE_DEFAULT *5, y = SCALE_DEFAULT *5, width = w, font = HAUNT_AOE, fontSize = size, align = "center" }))
    txtGrp:insert(display.newText({ text = text, width = w, font = HAUNT_AOE, fontSize = size, align = "center" }))
    
    txtGrp[1]:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
    txtGrp[2]:setFillColor(AZ.utils.getColor(INGAME_COMBO_RGB))
    
    local myContainer = display.newContainer(txtGrp.width,txtGrp.height)
    
    myContainer:insert(txtGrp)
    
    myContainer.anchorX = 0.5
    myContainer.anchorY = 0.5
    
    myContainer.x = posX
    myContainer.y = posY
    
    return myContainer
end
