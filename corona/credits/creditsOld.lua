
local scene = AZ.S.newScene()


function scene.onTouch(event)
    if event.phase == "release" then
        AZ.S.gotoScene("menu.menu", { effect = SCENE_TRANSITION_EFFECT, time = SCENE_TRANSITION_TIME })
    end
    
end

function scene:createScene()
    
    local developersNum = 8
    
    local bg = display.newImage("assets/fondoliso.jpg")
    bg:scale(display.contentHeight/bg.height, display.contentHeight/bg.height)  
    bg.x, bg.y = display.contentCenterX, display.contentCenterY
    scene.view:insert(bg)
    
    local staffTitle = AZ.ui.createShadowText("STAFF", display.contentCenterX, display.contentHeight * 0.0762, 80 * SCALE_DEFAULT)
    scene.view:insert(staffTitle)
    
    local menuBtn = AZ.ui.newEnhancedButton({ id = "menu", sound = AZ.soundLibrary.buttonSound, x = display.contentCenterX, y = display.contentHeight *0.9208, unpressed = 95, pressedFilter = "filter.invertSaturate", onEvent = scene.onTouch })
    menuBtn:scale(SCALE_DEFAULT, SCALE_DEFAULT)
    scene.view:insert(menuBtn)
    
    local yPos = staffTitle.contentBounds.yMax
    local yPadding = (menuBtn.contentBounds.yMin - yPos) / (developersNum +0.5)
    
    yPos = yPos +(yPadding *0.5)
    
    local function createDeveloper(upperTxt, lowerTxt)
        local devGrp = display.newGroup()
        
        local upper = display.newText(upperTxt, 0, 0, BRUSH_SCRIPT, 30 * SCALE_DEFAULT)
        upper:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
		upper.anchorY = 1
        --upper.y = -(upper.contentHeight *0.1)
        local lower = display.newText({ text = lowerTxt, width = display.contentWidth, font = INTERSTATE_REGULAR, fontSize = 30 * SCALE_DEFAULT, align = "center" })
        lower:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
		lower.anchorY = 0
        --lower.y = lower.contentHeight *0.1
        
        devGrp:insert(upper)
        devGrp:insert(lower)
        devGrp.x, devGrp.y = display.contentCenterX, yPos
        
        yPos = yPos + yPadding
        
        scene.view:insert(devGrp)
        
        return devGrp
    end
    
    local production = createDeveloper("Producer", "ROGER MONTSERRAT")
    local gameDesign = createDeveloper("Game Design", "DANIEL SANTEUGINI - ROGER MONTSERRAT")
    local art = createDeveloper("Lead Artist", "MAX CARRASCO")
    local graphic = createDeveloper("Graphic Design", "ALBERT ORIOL - SARA SALMERÓN")
    local anim = createDeveloper("2D Animation", "JOSÉ I. SALMERÓN")
    local programming = createDeveloper("Game Programmers", "GERARD CASTRO - LISARD CUNÍ\nJORDI FERRER - DANIEL SANTEUGINI")
    local music = createDeveloper("Music", "BERNAT SANCHEZ")
    local fx = createDeveloper("Sound FX", "IVAN AGUILAR")
end

scene:addEventListener("createScene", scene)

return scene


--[[scene.background    = nil
scene.btnMenu       = nil

scene.onTouch = function(event)
    if event.phase == "release" and event.id == "MenuButton" then
        local options = {
            effect = "crossFade",
            time = 250
        }
        
        AZ.S.gotoScene("menu.menu", options)
    end
end

scene.createMenuButtons = function()
    -- Menu button
    local btnMenu = AZ.ui.newEnhancedButton{
        sound = AZ.soundLibrary.buttonSound,
        unpressed = 95, --82, --"menu",
        x = display.contentWidth * 0.5,
        y = display.contentHeight -(120*SCALE_DEFAULT),
        pressed = 98, --80, --"menu-flecha-push",
        onEvent = scene.onTouch,
        id = "MenuButton"
    }

    local grpButtons = display.newGroup()
    btnMenu:scale(SCALE_DEFAULT,SCALE_DEFAULT)
    grpButtons:insert(btnMenu)
    return grpButtons
end

scene.createTextdata = function()
    local myImageSheet = graphics.newImageSheet("credits/assets/creditsStage.png", AZ.atlas:getSheet())
    
    local scale = (SCALE_BIG + SCALE_DEFAULT) *0.5
    
    local credits = display.newImage(myImageSheet, 2)
    credits:scale(scale, scale)
    credits.x = display.contentCenterX
    credits.y = display.contentCenterY
    
    local thousandGears = display.newImage(myImageSheet, 7)
    thousandGears:scale(scale, scale)
    thousandGears.x = display.contentCenterX
    thousandGears.y = display.contentCenterY - ((credits.height + thousandGears.height) *0.5 * scale) - (10 * SCALE_DEFAULT)
    
    local copyright = display.newImage(myImageSheet, 1)
    copyright:scale(SCALE_BIG, SCALE_BIG)
    copyright.x = display.contentWidth * 0.5
    copyright.y = display.contentHeight  - (SCALE_DEFAULT *40)
    
    local group = display.newGroup()
    group:insert(thousandGears)
    group:insert(credits)
    group:insert(copyright)
    
    return group
end

function scene:createScene( event )
	local group = self.view
        
        --FlurryController:logEvent("in_credits", { })
        
	scene.background = display.newImage(WIN_PATH)
        scene.background:scale(display.contentHeight/scene.background.height, display.contentHeight/scene.background.height) 
        scene.background.x = display.contentCenterX
        scene.background.y = display.contentCenterY
        
        group:insert(scene.background)
	group:insert(scene.createMenuButtons())
	group:insert(scene.createTextdata())
end

scene:addEventListener( "createScene", scene )

return scene]]