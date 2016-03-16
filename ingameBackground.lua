module(..., package.seeall)

local _slash

local hasBeenTouched

function getTouched()
    return hasBeenTouched
end

function setTouched(touched)
    hasBeenTouched = touched
end

function createBackground(background_path, slash)
    
    _slash = slash
    
    local background = display.newImage(background_path)
    background:scale(display.contentHeight/background.height, display.contentHeight/background.height) 
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    
    hasBeenTouched = false
    
    background.touch = function(event)
        if AZ.isMultitouch ~= true then
            hasBeenTouched = true
            
            _slash.drawSlashLine(event)
        end
    end
    
    background:addEventListener("touch", background.touch)
    
    return background
end