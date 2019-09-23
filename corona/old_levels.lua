
local tribone = require "tribone"

local scene = AZ.S.newScene()

local mStage
local mLastLevelFinished
local mLastStageFinished
local background
local stageInfo

local btnLevel = {}
local levelTribones = {}

local function scoreString(stageInfo, isText)
    local sum = 0
    for i=1, 9 do
        sum = sum + stageInfo[i].tribones
    end
    
    if isText == true then
        return sum .."/27"
    end
    
    return sum
end

local onTouch = function(event)
    if event.phase == "release" then
        if event.id == "BackButton" then
            local options = {
                effect = SCENE_TRANSITION_EFFECT,
                time = SCENE_TRANSITION_TIME,
                params = { stage = mStage }
            }
            AZ.S.gotoScene(STAGE_NAME, options)
        else
            local levelSelected = tonumber(string.sub(event.id, 6, 6))
            
            local options = {
                effect = SCENE_TRANSITION_EFFECT,
                time = SCENE_TRANSITION_TIME,
                params = { stage = mStage, level = levelSelected }
            }

            AZ.audio.playFX(level_button_fx, AZ.audio.AUDIO_VOLUME_BUTTONS)
            
            --FlurryController:logEvent("in_level_selection", { stage = mStage, level_selected = levelSelected, stage_bones = scoreString(stageInfo, false) })

            AZ.S.gotoScene(STORY_NAME, options)
       end
   end
end

local function createLevelButtons()
	
        local myImageSheet = graphics.newImageSheet("assets/guiSheet/levelsIngameWinLose.png", AZ.atlas:getSheet())
        local contrarestarScala = 1/SCALE_DEFAULT
	local grpButtons = display.newGroup()
	
	-- recorrem un bucle de 9 per a crear les 9 làpides
	for i=1, 9 do
            -- posició XY de la làpida actual
            local posX = display.contentWidth * 0.17
            if i %3 == 2 then
                    posX = display.contentWidth * 0.5
            elseif i%3 == 0 then
                     posX = display.contentWidth -(display.contentWidth *0.17)
            end

            local posY = display.contentHeight * 0.33
            if i > 3 and i < 7 then
                    posY = display.contentHeight * 0.56
            elseif i > 6 then
                    posY = display.contentHeight * 0.79
            end

            -- no recomano que toquis aquest codi!! si alguna lapida no esta ben centrada, canvia el sourceX, sourceY, sourceWidth i sourceHeight
            -- no es que el codi estigui malament o sigui confus, es que ara esta centrat pero no sembla intuitiu el problema si es detecta que no esta ben centrat, al canviar els souce arreglem problema a problema en comptes de canviar el general per arreglar problemes concrets
            -- creem el botó de la làpida actual
            btnLevel[i] = AZ.ui.newEnhancedButton{
    		pressed = grave_nameOrIndex, --"lapidalevelstage".. mStage,
    		unpressed = grave_nameOrIndex, --"lapidalevelstage".. mStage,
    		x = posX,
    		y = posY,
    		onEvent = onTouch,
    		id = "Level".. i .."Button"
            }
            btnLevel[i].isActive = mStage <= mLastStageFinished or i <= mLastLevelFinished +1
            btnLevel[i]:scale(SCALE_DEFAULT,SCALE_DEFAULT)
            
            if (btnLevel[i].isActive) then
                -- si l'índex de la làpida es menor o igual a l'últim nivell acabat +1, creem el tribone
                local triBone = tribone.createTribone(0, btnLevel[i].height * 0.5, levelTribones[i])
                triBone:scale(contrarestarScala, contrarestarScala)
                btnLevel[i]:insert(triBone)
            else
                --sino posem un candau
                local candau = display.newImage(myImageSheet, 10)
                candau.x = 0
                candau.y = btnLevel[i].height * 0.3
                btnLevel[i]:insert(candau)
            end
            -- creem el numero de la lapida actual
            local txtLevel = display.newText(i, 0, -12 * SCALE_DEFAULT, INTERSTATE_BOLD, BIG_FONT_SIZE)
            txtLevel.x = 0
            txtLevel.y = btnLevel[i].height * -0.1
            txtLevel:setTextColor(FONT_BLACK_COLOR[1], FONT_BLACK_COLOR[2], FONT_BLACK_COLOR[3], FONT_BLACK_COLOR[4])
            btnLevel[i]:insert(txtLevel)
            grpButtons:insert(btnLevel[i])
	end

        grpButtons.y = grpButtons.y - display.contentHeight *0.08
        
	return grpButtons
end

local function createScore(stageInfo)
    
    local scoreGroup = display.newGroup()

    local lblScore1 = display.newText(
        AZ.translations.getTranslation("score"),
        RELATIVE_SCREEN_X2,
        display.contentHeight * 0.87,
        BRUSH_SCRIPT,
        NORMAL_FONT_SIZE * SCALE_DEFAULT
    )
    lblScore1.x, lblScore1.y = RELATIVE_SCREEN_X2, display.contentHeight * 0.87
    lblScore1:setTextColor(FONT_WHITE_COLOR[1], FONT_WHITE_COLOR[2], FONT_WHITE_COLOR[3], FONT_WHITE_COLOR[4])
    
    local lblScore2 = display.newText(
        scoreString(stageInfo, true),
        RELATIVE_SCREEN_X2,
        display.contentHeight * 0.85,
        INTERSTATE_BOLD,
        NORMAL_FONT_SIZE * SCALE_BIG
    )
    lblScore2.x, lblScore2.y = RELATIVE_SCREEN_X2, display.contentHeight * 0.92
    lblScore2:setTextColor(FONT_WHITE_COLOR[1], FONT_WHITE_COLOR[2], FONT_WHITE_COLOR[3], FONT_WHITE_COLOR[4])
    

    scoreGroup:insert(lblScore1)
    scoreGroup:insert(lblScore2)
    
    return scoreGroup
    
end

function scene:createScene( event ) 
	local group = self.view
        
        mStage = event.params.stage
        
        stageInfo = AZ.personal.loadPersonalData(AZ.personal.relativeLevels .. mStage ..".json")
        
        AZ.audio.playBSO(AZ.soundLibrary.menuLoop)
        
        local genericInfo = AZ.personal.loadPersonalData(AZ.personal.genericInfo)
	mLastLevelFinished = genericInfo.lastLevelFinished
        mLastStageFinished = genericInfo.lastStageFinished
        
        -- crec que es pot borrar
        if stageInfo == nil then
            stageInfo = AZ.personal.createTribonesData(mStage)
	end
        
	background = display.newImage(background_path)
        background:scale(display.contentHeight/background.height, display.contentHeight/background.height)  
        background.x = display.contentCenterX
        background.y = display.contentCenterY
        
        for i=1, #stageInfo do
            levelTribones[i] = stageInfo[i].tribones
        end    
	btnBack = AZ.ui.newEnhancedButton{
		sound = AZ.soundLibrary.buttonSound,
		--sheet = "assets/gui1.png",
		unpressed = 101,--"back",
		x = display.contentWidth * 0.17,
		y = display.contentHeight - (100 * SCALE_DEFAULT),
		pressed = 102, --"back-push",
		onEvent = onTouch,
		id = "BackButton"
	}
	btnBack:scale(SCALE_DEFAULT,SCALE_DEFAULT)
        
        local lvlUpperTxt = AZ.ui.createShadowText(AZ.translations.getTranslation("choose_level_upper"), display.contentWidth * 0.5, display.contentHeight * 0.06, 45 * SCALE_BIG)
        local lvlLowerTxt = AZ.ui.createShadowText(AZ.translations.getTranslation("choose_level_lower"), display.contentWidth * 0.5, display.contentHeight * 0.12, 45 * SCALE_BIG)
        
	group:insert(background)
        group:insert(btnBack)
	group:insert(createLevelButtons())
        group:insert(lvlUpperTxt)
        group:insert(lvlLowerTxt)
        group:insert(createScore(stageInfo))
end
 
--[[function scene:enterScene( event )
	local group = self.view
end

function scene:exitScene( event )
    
end

function scene:destroyScene( event )
        local group = self.view  
        
end
 
function scene:didExitScene( event )
        local group = self.view 
end]]

scene:addEventListener( "createScene", scene )
--scene:addEventListener( "enterScene", scene )
--scene:addEventListener( "exitScene", scene )
--scene:addEventListener( "destroyScene", scene)
--scene:addEventListener( "didExitScene", scene )

return scene