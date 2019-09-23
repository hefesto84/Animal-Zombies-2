
local scene = AZ.S.newScene() 

local translate

local mCurrentStage
local mCurrentLevel
local background
local btnResume
local btnRestart
local btnLevels
local btnMenu
local imgTopScore
local lblTopScore
--local imgStage
local stageUpperTxt
local stageLowerTxt
local corteSuperior

local function changeIsActive( isActive )
    btnResume.isActive = isActive
    btnRestart.isActive = isActive
    btnLevels.isActive = isActive
    btnMenu.isActive = isActive
end

local onTouch = function(event)
    if event.phase == "release" then
        changeIsActive(false)
        
        --FlurryController:logEvent("in_game", { stage = mCurrentStage, level = mCurrentLevel, game_state = event.id })
        
        if event.id == "Resume" then
            --local ingame = AZ.S.getScene("test_ingameScene")
            local fadeTime = 400
            timer.performWithDelay(fadeTime, function() Runtime:dispatchEvent({ name = GAMEPLAY_PAUSE_EVNAME, isPause = false, pauseType = "pause" }) end)
            AZ.S.hideOverlay("fade", fadeTime)
        
        elseif event.id == "Restart" then
            local options = {
                effect = SCENE_TRANSITION_EFFECT,
                time = SCENE_TRANSITION_TIME,
                params = { stage = mCurrentStage, level = mCurrentLevel, resume = false }
            }
            AZ.S.gotoScene("loading.loading", options)
        
        elseif event.id == "Levels" then
            local options = {
                effect = SCENE_TRANSITION_EFFECT,
                time = SCENE_TRANSITION_TIME,
                params = { stage = mCurrentStage, level = mCurrentLevel, resume = false }
            }
            AZ.S.gotoScene("levels.levels2", options)
        
        elseif event.id == "Menu" then
            local options = {
                effect = SCENE_TRANSITION_EFFECT,
                time = SCENE_TRANSITION_TIME,
                params = { stage = mCurrentStage, level = mCurrentLevel, resume = false }
            }
            AZ.S.gotoScene("menu.menu", options)
        end
    end
end

local function createPauseButtons()

    local scale = (SCALE_BIG + SCALE_DEFAULT) *0.5
    local xPos = display.contentCenterX

    btnResume = AZ.ui.newEnhancedButton{
        sound = AZ.soundLibrary.buttonSound,
        unpressed = 37,
        x = xPos,
        y = display.contentHeight *0.35,
        pressed = 36,
        onEvent = onTouch,
        id = "Resume",
        text1 = {text= translate("resume"), fontName = INTERSTATE_BOLD, fontSize = NORMAL_FONT_SIZE, X = 0, Y = 30, color = AZ_DARK_RGB, altColor = AZ_BRIGHT_RGB}
    }
    btnResume:scale(scale, scale)
    
    -- restart button
    btnRestart = AZ.ui.newEnhancedButton{
        sound = AZ.soundLibrary.buttonSound,
        unpressed = 37,
        x = xPos,
        y = display.contentHeight *0.45,
        pressed = 36,
        onEvent = onTouch,
        id = "Restart",
        text1 = {text= translate("restart"), fontName = INTERSTATE_BOLD, fontSize = NORMAL_FONT_SIZE, X = 0, Y = 30, color = AZ_DARK_RGB, altColor = AZ_BRIGHT_RGB}
    }
    btnRestart:scale(scale, scale)
    
    -- Levels button
    btnLevels = AZ.ui.newEnhancedButton{
        sound = AZ.soundLibrary.buttonSound,
        unpressed = 37,
        x = xPos,
        y = display.contentHeight *0.55,
        pressed = 36,
        onEvent = onTouch,
        id = "Levels",
        text1 = {text= translate("levels"), fontName = INTERSTATE_BOLD, fontSize = NORMAL_FONT_SIZE, X = 0, Y = 30, color = AZ_DARK_RGB, altColor = AZ_BRIGHT_RGB}
    }
    btnLevels:scale(scale, scale)
    
    -- menu button
    btnMenu = AZ.ui.newEnhancedButton{
        sound = AZ.soundLibrary.buttonSound,
        unpressed = 37,
        x = xPos,
        y = display.contentHeight *0.65,
        pressed = 36,
        onEvent = onTouch,
        id = "Menu",
        text1 = {text= translate("menu"), fontName = INTERSTATE_BOLD, fontSize = NORMAL_FONT_SIZE, X = 0, Y = 30, color = AZ_DARK_RGB, altColor = AZ_BRIGHT_RGB}
    }
    btnMenu:scale(scale, scale)

    local grpLooseButtons = display.newGroup()

    grpLooseButtons:insert(btnLevels)
    grpLooseButtons:insert(btnMenu)
    grpLooseButtons:insert(btnRestart)
    grpLooseButtons:insert(btnResume)
    
    return grpLooseButtons
end

local function createPauseGUI()
    local grpPauseGUI = display.newGroup()
    
    local stageData = AZ.userInfo.progress.stages[mCurrentStage].levels
    local myImageSheet = graphics.newImageSheet("assets/guiSheet/stage".. mCurrentStage ..".png", AZ.atlas:getSheet())
    
    local _info = require("test_infoStage"..mCurrentStage)
    
    stageUpperTxt = AZ.ui.createShadowText(string.upper(AZ.utils.translate(_info.upper_name)), display.contentWidth * 0.5, display.contentHeight * 0.04, 45 * SCALE_BIG)
    stageLowerTxt = AZ.ui.createShadowText(AZ.utils.translate(_info.lower_name), display.contentWidth * 0.5, display.contentHeight * 0.1, 45 * SCALE_BIG)

    _info = AZ.utils.unloadModule("test_infoStage".. mCurrentStage)

    if stageData[mCurrentLevel] ~= nil and stageData[mCurrentLevel].score > 0 then
        
        lblTopScore = display.newText(
            translate("max_score") ..": ".. tostring(stageData[mCurrentLevel].score),
            0,
            0,
            INTERSTATE_BOLD,
            NORMAL_FONT_SIZE * SCALE_DEFAULT
        )
        lblTopScore.anchorX = 1
        lblTopScore.anchorY = 0.5
        --lblTopScore:setReferencePoint(display.CenterRightReferencePoint)
        lblTopScore.x = display.contentWidth * 0.95
        lblTopScore.y = display.contentHeight * 0.16
        lblTopScore:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
        grpPauseGUI:insert(lblTopScore)
    end
    
    local lblLevel = display.newText(
        translate("level") .." "..tostring(mCurrentLevel) , 
        display.contentWidth * 0.2,
        display.contentHeight * 0.2, 
        INTERSTATE_BOLD,
        NORMAL_FONT_SIZE * SCALE_DEFAULT
    )
    lblLevel.anchorX = 0
    lblLevel.anchorY = 0.5
    --lblLevel:setReferencePoint(display.CenterLeftReferencePoint)
    lblLevel.x = display.contentWidth * 0.05
    lblLevel.y = display.contentHeight * 0.16
    lblLevel:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
    
    AZ.utils.unloadModule("stage.info.infoStage"..mCurrentStage)
    
    --grpPauseGUI:insert(imgTopScore)
    --grpPauseGUI:insert(imgStage)
    grpPauseGUI:insert(stageUpperTxt)
    grpPauseGUI:insert(stageLowerTxt)
    grpPauseGUI:insert(lblLevel)

    return grpPauseGUI
    
end

function scene:createScene( event )
    
    local group = self.view
    
    translate = AZ.utils.translate
    
    mCurrentStage = event.params.currentStage
    mCurrentLevel = event.params.currentLevel
    
    background = display.newRect(0, 0, display.contentWidth, display.contentHeight)
    background:setFillColor(AZ.utils.getColor({ 130, 130, 113, 150 }))
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    
    local imgSheet = graphics.newImageSheet("assets/guiSheet/menuOptionsPauseLoading.png", AZ.atlas:getSheet())
    
    corteSuperior = display.newImage(imgSheet, 48)
    corteSuperior:scale(display.contentWidth/corteSuperior.width, display.contentWidth/corteSuperior.width) 
    corteSuperior.anchorX = 0
    corteSuperior.anchorY = 0
    --corteSuperior:setReferencePoint(display.TopLeftReferencePoint)
    corteSuperior.x = 0
    corteSuperior.y = 0
    
    group:insert(background)
    group:insert(corteSuperior)
    group:insert(createPauseButtons())
    group:insert(createPauseGUI())
    
    group:toFront()
end

scene:addEventListener( "createScene", scene )

return scene
