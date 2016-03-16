local prevTime = 0
local fpsTxt, luaTxt, texTxt

local monitorMem = function()
    local curTime = system.getTimer()
    
    function round(num)
        return math.floor(num * 100 + 0.5) *0.01
    end

    collectgarbage()
    local memUsage = round(collectgarbage("count") *0.0001)
    local texMem = round(system.getInfo("textureMemoryUsed") *0.000001)
    local fps = math.floor(1000/ (curTime - prevTime))
    
    if prevTime == 0 then
        tstTxt = display.newEmbossedText("Test Mode", 0, 0, display.nativeFont, 20)
        sysTxt = display.newEmbossedText("0", 0, 0, display.nativeFont, 15)
        luaTxt = display.newEmbossedText("0", 0, 0, display.nativeFont, 15)
        texTxt = display.newEmbossedText("0", 0, 0, display.nativeFont, 15)
        
        tstTxt:setReferencePoint(display.BottomLeftReferencePoint)
        tstTxt.x, tstTxt.y = 0, display.contentHeight -45
        
        tstTxt:setFillColor(255, 0, 255)
        sysTxt:setFillColor(255, 0, 255)
        luaTxt:setFillColor(255, 0, 255)
        texTxt:setFillColor(255, 0, 255)
    end
    
    local function updateTxt(myTxt, txt1, value, txt2, posY)
        myTxt.text = txt1 .. value .. txt2
        myTxt:setReferencePoint(display.BottomLeftReferencePoint)
        myTxt.x, myTxt.y = 0, posY
        myTxt:toFront()
    end
    
    tstTxt:toFront()
    updateTxt(sysTxt, "fps: ", fps, "", display.contentHeight -30)
    updateTxt(luaTxt, "lua: ", memUsage, " Mb", display.contentHeight -15)
    updateTxt(texTxt, "tex: ", texMem, " Mb", display.contentHeight)
    
    prevTime = curTime
end

Runtime:addEventListener( "enterFrame", monitorMem )