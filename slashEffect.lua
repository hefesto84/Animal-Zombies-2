module(..., package.seeall)
require "resolutions"

-- Slash line properties (line that shows up when you move finger across the screen)
local maxPoints = 3
local lineThickness = 20 * SCALE_BIG
local lineFadeTime = 150
local endPoints = {}

function destroy()
    while(#endPoints > 0) do
        table.remove(endPoints)
    end
end

function drawSlashLine(event)
    -- Play a slash sound
    --[[if(endPoints ~= nil and endPoints[1] ~= nil) then
        local distance = math.sqrt(math.pow(event.x - endPoints[1].x, 2) + math.pow(event.y - endPoints[1].y, 2))
	if(distance > minDistanceForSlashSound and slashSoundEnabled == true) then 
            playRandomSlashSound();  
            slashSoundEnabled = false
            timer.performWithDelay(minTimeBetweenSlashes, function(event) slashSoundEnabled = true end)
	end
    end]]

    -- Insert a new point into the front of the array
    table.insert(endPoints, 1, { x = event.x, y = event.y, line = nil }) 

    -- Remove any excessed points
    if #endPoints > maxPoints then 
        table.remove(endPoints)
    end

    for i=1, #endPoints -1 do
        local line = display.newLine(endPoints[i].x, endPoints[i].y, endPoints[i +1].x, endPoints[i+1].y)
        line:setColor(unpack(WEAP_RAKE_SLASH_COLOR))
        line.width = lineThickness
        
        line.destroy = function()
            line:removeSelf()
            line = nil
        end
        
	transition.to(line, { time = lineFadeTime, width = 0, alpha = 0, onComplete = line.destroy })
    end

    if event.phase == "ended" or event.phase == "cancelled" then		
        destroy()
    end
end