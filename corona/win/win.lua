
local facebook = require("facebook")
local tribone = require "tribone"
local easing = require "easing"

local scene = AZ.S.newScene()

local translate

local group
local currentStage
local currentLevel
local currentDeaths
local currentLives
local currentCombos
local currentTime
local gameDeaths
local gameLives
local gameCombos
local myTime
local savedBones
local mScore
local maxScore
local maxScoreShown = false
local lblDeaths
local lblScore
local lblCombos
local imgTribones
local levelInfo
local lollipopsTable = { }
--control de timers
local timerID
--actualitzar bones
local maxZombies
local currentBones
--
local lollipopsCount = 0
local lollipopInfo

local winLevelSheet = nil

-- botons, imatges i textos animats
local btnFB
local btnLevels
local btnReplay
local btnNext
local shine
local imgAchievement
local topGroup
local imgBoneGroup = { }
local lblNewRecord
local btnGameServiceAchievements
local btnGameServiceLeaderboard

local finishedAnim = false


function facebookListener(event)
    if ( "session" == event.type ) then
        if ( "login" == event.phase ) then
            facebook.request("me")
        end
    elseif ( "request" == event.type ) then
        require ("stage.info.infoStage"..currentStage)
        local response = {}
        response = AZ.json.decode(tostring(event.response))
        local attachment = {
            name = "Animal Zombies",
            link = "http://www.codiwans.com/animalzombies/AnimalZombiesRedirectToStores.html",
            caption = AZ.translations.getTranslation("fb_caption"), --"Play Animal Zombies in your smartphone!",
            description = AZ.translations.getFacebookDescription(tostring(response.first_name), emblem_container[stage_level_info[currentLevel].emblem].fbName, mScore, currentStage, currentLevel),
            --description = tostring(response.first_name).." earned the achievement "..emblem_container[stage_level_info[currentLevel].emblem].fbName.." scoring ".. mScore .." playing Animal Zombies in level "..currentStage.."-"..currentLevel.."!",
            picture = emblem_container[stage_level_info[currentLevel].emblem].URL
        }
        package.loaded["stage.info.infoStage"..currentStage] = nil
        facebook.showDialog( "feed", attachment )
        --facebook.request( "me/feed", "POST", attachment )
    elseif ( "dialog" == event.type) then
        facebook.logout()
        native.setKeyboardFocus( nil )
    end
end

local function getTribones(score)
    if score >= levelInfo.scoreBones[1] then
        if score >= levelInfo.scoreBones[2] then
            if score >= levelInfo.scoreBones[3] then
                return 3
            end
            return 2
        end
        return 1
    end
    return 0
end

local function writeStatistics(score, time)
    local statistics = AZ.personal.loadPersonalData(AZ.personal.statistics .. currentStage .. ".json")
    
    if statistics == nil then
        statistics = AZ.personal.resetStatistics(currentStage)
    end
    
    statistics[currentLevel].played = statistics[currentLevel].played +1
    
    -- minim i maxim [score]
    if statistics[currentLevel].minScore > score or statistics[currentLevel].minScore == 0 then
        statistics[currentLevel].minScore = score
    end
    if statistics[currentLevel].maxScore < score then
        statistics[currentLevel].maxScore = score
    end
    
    -- minim i maxim [time]
    if statistics[currentLevel].minTime > time or statistics[currentLevel].minTime == 0 then
        statistics[currentLevel].minTime = time
    end
    if statistics[currentLevel].maxTime < time then
        statistics[currentLevel].maxTime = time
    end
    
    -- total i mitja [score]
    statistics[currentLevel].totalScore = statistics[currentLevel].totalScore + score
    statistics[currentLevel].medScore = statistics[currentLevel].totalScore / statistics[currentLevel].played
    
    -- total i mitja [time]
    statistics[currentLevel].totalTime = statistics[currentLevel].totalTime + time
    statistics[currentLevel].medTime = statistics[currentLevel].totalTime / statistics[currentLevel].played
    
    AZ.personal.savePersonalData(statistics, AZ.personal.statistics .. currentStage .. ".json")
end

local function writeInfo(combos, deaths, lives, myTime)
    require ("stage.info.infoStage".. currentStage)
    levelInfo           = stage_level_info[currentLevel]
    local genericData   = AZ.userInfo--AZ.personal.loadPersonalData(AZ.personal.genericInfo)
    local stageData     = AZ.userInfo.progress.stages[currentStage].levels--AZ.personal.loadPersonalData(AZ.personal.relativeLevels .. currentStage .. ".json")
    
    -- si el nivell actual era el que haviem de fer, actualitzem la informacio generica [lastStage, lastLevel i tips]
    if genericData.lastLevelFinished +1 == currentLevel then
        -- actualitzem nivell [i stage si escau]
        genericData.lastLevelFinished = genericData.lastLevelFinished +1
        if currentLevel == 9 then
            genericData.lastStageFinished = genericData.lastStageFinished +1
            genericData.lastLevelFinished = 0
        end

      
        -- guardem les dades generiques
        AZ.personal.savePersonalData(genericData, AZ.personal.genericInfo)
    end
    savedBones = stageData[currentLevel].tribones
    currentBones = savedBones
    maxScore = stageData[currentLevel].score

    -- dibuix del tribone
    imgTribones = tribone.createTribone(
        display.contentWidth * 0.5,
        display.contentHeight * 0.41 + (10*SCALE_DEFAULT),
        savedBones
    )
    topGroup:insert(imgTribones)
    --print("Combos: ".. combos ..", Deaths: ".. deaths .."x".. SCORE_DEATHS ..", Lives: ".. lives .."x".. SCORE_LIFE ..", Time: ".. levelInfo.medTime .."-".. myTime /1000)
    
    currentTime = levelInfo.medTime - myTime
    currentTime = math.round((currentTime + currentTime) *0.001)
    if currentTime < 0 then
        currentTime = 0
    end
    
    mScore = combos + (deaths * SCORE_DEATHS) + (lives * SCORE_LIFE) + currentTime
    --writeStatistics(mScore, math.floor(myTime * 0.001))
    --print("Total: ".. mScore)

    maxZombies = levelInfo.maxZombiesInLevel
    
    -- actualitzem puntuació slevelInfoi toca
    if stageData[currentLevel].score < mScore then
        stageData[currentLevel].score = mScore
    end
    -- actualitzem el temps si toca
    if stageData[currentLevel].time > myTime or stageData[currentLevel].time == -1 then
        stageData[currentLevel].time = myTime
    end
    -- actualitzem els ossos si toca
    local achievedBones = getTribones(mScore)
    if savedBones < achievedBones then
        stageData[currentLevel].tribones = achievedBones
    end

    AZ.personal.savePersonalData(stageData, AZ.personal.relativeLevels .. currentStage .. ".json")
    
end

local function getPlatform()
    if system.getInfo("platformName") == "iPhone OS" then
        return "iOS"
    end
    
    return "android"
end

local onTouch = function(event)
    if event.phase == "ended" or event.phase == "release" then
        local options = {
            effect = SCENE_TRANSITION_EFFECT,
            time = SCENE_TRANSITION_TIME,
            params = { stage = currentStage, level = currentLevel, changeStage = false }
        }

		if not finishedAnim then
			return
		end
		

        if event.isBackKey or event.id == "Next" then
            Runtime:removeEventListener("enterFrame", rotate)
            if timerID then
                timer.cancel(timerID)
            end
            
            --FlurryController:logEvent("in_win_level", { stage = currentStage, level = currentLevel, button = "next" })

            --si ja estem al nivell màxim
            if (currentLevel == 9) then --cambiar per variable constant (length d'array de nivells o int)
                --historia final
                AZ.S.gotoScene(FINAL_STORY_NAME, options)
            else --sino seguim historia normal
                --options.params.level = options.params.level + 1
                AZ.S.gotoScene("levels.levels2",options)
            end
        elseif (event.id == "Replay") then
            Runtime:removeEventListener("enterFrame", rotate)
            if timerID then
                timer.cancel(timerID)
            end
           
            --FlurryController:logEvent("in_win_level", { stage = currentStage, level = currentLevel, button = "replay" })
            
            AZ.S.gotoScene("loading.loading", options)
            
        elseif event.id == "Levels" then
            Runtime:removeEventListener("enterFrame", rotate)
            if timerID then
                timer.cancel(timerID)
            end
            
            --FlurryController:logEvent("in_win_level", { stage = currentStage, level = currentLevel, button = "levels" })
            
            AZ.S.gotoScene("levels.levels2", options)
        elseif event.id == "FB" then
            --local share = function()
                if AZ.utils.testConnection() == true then
                    --FlurryController:logEvent("in_win_level", { stage = currentStage, level = currentLevel, button = "share FB" })

                    facebook.login( FACEBOOK_APP_ID, facebookListener, { "publish_stream" } )
                else
                    local options = {
                        buttonLabels = {
                            FACEBOOK_NO_NET_BTN
                        }
                   }
                   native.showAlert(FACEBOOK_NO_NET_TITLE, FACEBOOK_NO_NET_MSG, options)    
                end
                
            --    coroutine.yield()
            --end
            
            --local shareFB = coroutine.create(share)
            --coroutine.resume(shareFB)
                
        elseif event.id == "gameServiceLeaderboard" then
            --FlurryController:logEvent("market_game_services", { clicked_in = "win level", which = "achievements" })

            GameServicesController:show("achievements")
        elseif event.id == "gameServiceAchievements" then
            --FlurryController:logEvent("market_game_services", { clicked_in = "win level", which = "leaderboards" })

            GameServicesController:show("leaderboards")
        end
    end
end

function scene.onBackTouch()
	onTouch({ phase = "ended", isBackKey = true })
end

local function createWinButtons()

    -- Levels button
    btnLevels = AZ.ui.newEnhancedButton{
        sound = AZ.soundLibrary.buttonSound,
        unpressed = 96, --82, --"menu",
        x = display.contentWidth * 0.17,
        y = display.contentHeight - (100*SCALE_DEFAULT),
        pressed = 97, --82, --"menu-flecha-push",
        onEvent = onTouch,
        id = "Levels"
    }
    btnLevels:scale(SCALE_DEFAULT,SCALE_DEFAULT)
    btnLevels.active = false
    btnLevels.alpha = 0
    
    -- Replay button
    btnReplay = AZ.ui.newEnhancedButton{
        sound = AZ.soundLibrary.buttonSound,
        unpressed = 103, --86, --"replay",
        x = RELATIVE_SCREEN_X2,
        y = display.contentHeight - (100*SCALE_DEFAULT),
        pressed = 104, --85, --"replay-push",
        onEvent = onTouch,
        id = "Replay"
    }
    btnReplay:scale(SCALE_DEFAULT,SCALE_DEFAULT)
    btnReplay.active = false
    btnReplay.alpha = 0
    
    -- Next button
    btnNext = AZ.ui.newEnhancedButton{
        sound = AZ.soundLibrary.buttonSound,
        unpressed = 105, --84, --"next",
        x = display.contentWidth * 0.83,
        y = display.contentHeight - (100*SCALE_DEFAULT),
        pressed = 106, --83, --"next-push",
        onEvent = onTouch,
        id = "Next"
    }
    btnNext.alpha = 0
    btnNext.active = false
    btnNext:scale(SCALE_DEFAULT,SCALE_DEFAULT)
    
    -- FaceBook button
    btnFB = AZ.ui.newEnhancedButton{
        sound = AZ.soundLibrary.buttonSound,
        unpressed = 78, --"shareonfb",
        x = display.contentWidth * 0.73,
        y = display.contentHeight * 0.48,
        pressed = 77, --"shareonfb-push",
        text1 = {text = translate("share"), X = -5, Y = 3, fontName = INTERSTATE_BOLD, fontSize = NORMAL_FONT_SIZE *0.9, color = FONT_WHITE_COLOR },
        text2 = {text = translate("on_fb"), X = -5, Y = 33, fontName = INTERSTATE_BOLD, fontSize = SMALL_FONT_SIZE, color = FONT_WHITE_COLOR },
        onEvent = onTouch,
        id = "FB"
    }
    btnFB.alpha = 0
    btnFB:scale(2*SCALE_DEFAULT,2*SCALE_DEFAULT)
    btnFB.rotation = -40
    btnFB.active = false
    
    if system.getInfo("platformName") == "Android" then
        
        btnGameServiceAchievements = AZ.ui.newEnhancedButton{
            sound = AZ.soundLibrary.buttonSound,
            unpressed = 90,--"gameServiceBlanco", 
            x = display.contentWidth *0.62,
            y = display.contentHeight * 0.58,
            pressed = 89,--"gameServiceNegro",
            onEvent = onTouch,
            id = "gameServiceAchievements"
        }
    else
            
        btnGameServiceAchievements = AZ.ui.newEnhancedButton{
            sound = AZ.soundLibrary.buttonSound,
            unpressed = 92,--"gameServiceBlanco", 
            x = display.contentWidth *0.62,
            y = display.contentHeight * 0.58,
            pressed = 91,--"gameServiceNegro",
            onEvent = onTouch,
            id = "gameServiceAchievements"
        }
        
    end
    btnGameServiceAchievements.alpha = 0
    btnGameServiceAchievements:scale(2*SCALE_DEFAULT,2*SCALE_DEFAULT)
    btnGameServiceAchievements.rotation = -40
    btnGameServiceAchievements.active = false
    btnGameServiceLeaderboard = AZ.ui.newEnhancedButton{
        sound = AZ.soundLibrary.buttonSound,
        unpressed = 88,--"gameServiceBlanco", 
        x = display.contentWidth *0.8,
        y = display.contentHeight * 0.58,
        pressed = 87,--"gameServiceNegro",
        onEvent = onTouch,
        id = "gameServiceLeaderboard"
    }
    btnGameServiceLeaderboard.alpha = 0
    btnGameServiceLeaderboard:scale(2*SCALE_DEFAULT,2*SCALE_DEFAULT)
    btnGameServiceLeaderboard.rotation = -40
    btnGameServiceLeaderboard.active = false
    
    local grpWinButtons = display.newGroup()

    grpWinButtons:insert(btnLevels)
    grpWinButtons:insert(btnReplay)
    grpWinButtons:insert(btnNext)
    grpWinButtons:insert(btnFB)
    grpWinButtons:insert(btnGameServiceAchievements)
    grpWinButtons:insert(btnGameServiceLeaderboard)

    return grpWinButtons
end

local function getTime(t)
    local min, sec = 0

    min = math.floor( t/60 )
    sec = math.floor( t%60 )
    if sec < 10 then
        sec = "0"..sec
    end
    return (min..":"..sec)
end

local function createWinGUI(gameTime)
    --imatges
    require ("stage.info.infoStage".. currentStage)
    
    local sheetInfo = AZ.atlas
    local myImageSheet = graphics.newImageSheet("assets/guiSheet/stage".. currentStage ..".png", sheetInfo:getSheet())
    
    local stageUpperTxt = AZ.ui.createShadowText(string.upper(AZ.utils.translate(upper_name)), display.contentCenterX, display.contentHeight * 0.24, 45 * SCALE_BIG)
    local stageLowerTxt = AZ.ui.createShadowText(AZ.utils.translate(lower_name), display.contentCenterX, display.contentHeight * 0.30, 45 * SCALE_BIG)
    
    imgFlag = display.newImage(winLevelSheet, 19)
    imgFlag.x = display.contentWidth * 0.5
    imgFlag.y = display.contentHeight * 0.41
    imgFlag:scale(SCALE_DEFAULT,SCALE_DEFAULT)
    imgFlag.anchorX, imgFlag.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
        
    local achievementIndex = AZ.atlas:getFrameIndexAndSpriteSheet(emblem_container[stage_level_info[currentLevel].emblem].frameIndex)
    imgAchievement = display.newImage(myImageSheet, achievementIndex)
    imgAchievement.x = display.contentWidth * 0.33 - 5 * SCALE_DEFAULT
    imgAchievement.y = display.contentHeight * 0.52
    imgAchievement:scale(SCALE_BIG + SCALE_BIG, SCALE_BIG + SCALE_BIG)
    imgAchievement.alpha = 0
    imgAchievement.anchorX, imgAchievement.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    
    -- textos
    lblLevel = display.newText(
        translate("level") .. tostring(currentLevel) ,
        display.contentWidth * 0.5,
        display.contentHeight * 0.13,
        INTERSTATE_BOLD,
        NORMAL_FONT_SIZE * SCALE_DEFAULT
    )
    lblLevel.anchorX, lblLevel.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    lblLevel.x = display.contentWidth * 0.5
    lblLevel.y = display.contentHeight * 0.35
    lblLevel:setTextColor(FONT_BLACK_COLOR[1], FONT_BLACK_COLOR[2], FONT_BLACK_COLOR[3], FONT_BLACK_COLOR[4])
    
    lblNewRecord = display.newText(
        translate("congrats"),
        display.contentWidth * 0.95,
        display.contentHeight * 0.33,
        BRUSH_SCRIPT,
        BIG_FONT_SIZE * SCALE_BIG * 0.9
    )
    lblNewRecord.anchorX, lblNewRecord.anchorY = 0.5, 1 --:setReferencePoint(display.BottomCenterReferencePoint)
    lblNewRecord.x = display.contentWidth * 1.5
    lblNewRecord.y = display.contentHeight * 0.35
    lblNewRecord:setTextColor(FONT_BLACK_COLOR[1], FONT_BLACK_COLOR[2], FONT_BLACK_COLOR[3], FONT_BLACK_COLOR[4])
    
    local lblDeathsTitle = display.newText(
        translate("deaths"),
        display.contentWidth * 0.5,
        display.contentHeight * 0.72,
        BRUSH_SCRIPT,
        NORMAL_FONT_SIZE * SCALE_DEFAULT
    )
    lblDeathsTitle.anchorX, lblDeathsTitle.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    lblDeathsTitle.x = display.contentWidth * 0.15
    lblDeathsTitle:setTextColor(FONT_BLACK_COLOR[1], FONT_BLACK_COLOR[2], FONT_BLACK_COLOR[3], FONT_BLACK_COLOR[4])
    
    lblDeaths = display.newText(
        currentDeaths,
        display.contentWidth * 0.25,
        display.contentHeight * 0.77,
        INTERSTATE_BOLD,
        BIG_FONT_SIZE * SCALE_DEFAULT
    )
    lblDeaths.anchorX, lblDeaths.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    lblDeaths.x = display.contentWidth * 0.15
    lblDeaths:setTextColor(FONT_BLACK_COLOR[1], FONT_BLACK_COLOR[2], FONT_BLACK_COLOR[3], FONT_BLACK_COLOR[4])
    
    local lblScoreTitle = display.newText(
        translate("score"),
        display.contentWidth * 0.5,
        display.contentHeight * 0.72,
        BRUSH_SCRIPT,
        NORMAL_FONT_SIZE * SCALE_DEFAULT
    )
    lblScoreTitle.anchorX, lblScoreTitle.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    lblScoreTitle.x = display.contentWidth * 0.5
    lblScoreTitle:setTextColor(FONT_BLACK_COLOR[1], FONT_BLACK_COLOR[2], FONT_BLACK_COLOR[3], FONT_BLACK_COLOR[4])
    
    lblScore = display.newText(
        0,
        display.contentWidth * 0.5,
        display.contentHeight * 0.77,
        INTERSTATE_BOLD,
        BIG_FONT_SIZE * SCALE_DEFAULT
    )
    lblScore.anchorX, lblScore.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    lblScore.x = display.contentWidth * 0.5
    lblScore:setTextColor(FONT_BLACK_COLOR[1], FONT_BLACK_COLOR[2], FONT_BLACK_COLOR[3], FONT_BLACK_COLOR[4])
    
    local lblTimeTitle = display.newText(
        translate("time"),
        display.contentWidth * 0.75,
        display.contentHeight * 0.72,
        BRUSH_SCRIPT,
        NORMAL_FONT_SIZE * SCALE_DEFAULT
    )
    lblTimeTitle.anchorX, lblTimeTitle.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    lblTimeTitle.x = display.contentWidth * 0.85
    lblTimeTitle:setTextColor(FONT_BLACK_COLOR[1], FONT_BLACK_COLOR[2], FONT_BLACK_COLOR[3], FONT_BLACK_COLOR[4])
    
    local t = gameTime *0.001
    local lblTime = display.newText(
        getTime(t),
        display.contentWidth * 0.75,
        display.contentHeight * 0.77,
        INTERSTATE_BOLD,
        BIG_FONT_SIZE * SCALE_DEFAULT
    )
    lblTime.anchorX, lblTime.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
    lblTime.x = display.contentWidth * 0.85
    lblTime:setTextColor(FONT_BLACK_COLOR[1], FONT_BLACK_COLOR[2], FONT_BLACK_COLOR[3], FONT_BLACK_COLOR[4])

    package.loaded["stage.info.infoStage".. currentStage] = nil
    
    local grpWinGUI = display.newGroup()

    topGroup = display.newGroup()
    topGroup:insert(stageUpperTxt)--imgStage)
    topGroup:insert(stageLowerTxt)
    topGroup:insert(imgFlag)
    topGroup:insert(lblLevel)
    
    grpWinGUI:insert(topGroup)
    grpWinGUI:insert(imgAchievement)
    --grpWinGUI:insert(imgDeathsScoreTime)
    --grpWinGUI:insert(imgCongratulations)
    grpWinGUI:insert(lblNewRecord)
    grpWinGUI:insert(lblDeaths)
    grpWinGUI:insert(lblDeathsTitle)
    grpWinGUI:insert(lblScore)
    grpWinGUI:insert(lblScoreTitle)
    grpWinGUI:insert(lblTime)
    grpWinGUI:insert(lblTimeTitle)

    return grpWinGUI

end

function createTriboneSpawn(x, y, i)
    local boneInfo = AZ.animsLibrary.boneAnim()
    local boneSound = AZ.soundLibrary.boneSound
    local boneSpawnInstance = display.newSprite(boneInfo.imageSheet, boneInfo.sequenceData)
    boneSpawnInstance:scale(SCALE_DEFAULT, SCALE_DEFAULT)
    boneSpawnInstance:toFront()

    AZ.audio.playFX(boneSound[i], AZ.audio.AUDIO_VOLUME_OTHER_FX)

    boneSpawnInstance:setSequence("bone spawn")
    boneSpawnInstance:play()


    boneSpawnInstance.x = x
    boneSpawnInstance.y = y

    boneSpawnInstance:scale(SCALE_DEFAULT*2,SCALE_DEFAULT*2)
    boneSpawnInstance.destroy = function(event)
        if event.phase == "ended" and boneSpawnInstance ~= nil then
            group:remove(boneSpawnInstance)            
            boneSpawnInstance = nil
        end
    end

    boneSpawnInstance:addEventListener("sprite", boneSpawnInstance.destroy)

    return boneSpawnInstance
end

local function checkScore(score)
    local tribones = getTribones(score)
    
    AZ.audio.playFX(AZ.soundLibrary.addScoreSound, AZ.audio.AUDIO_VOLUME_BSO)
    
    if (currentBones < tribones) then
        currentBones = currentBones+1
        -- dibuix del tribone
        local imgBone = display.newImage(winLevelSheet, 16)
        
        imgBone.boneIndex = currentBones
        imgBone.updateTribone = function()
            local fum = tribone.createTriboneSpawn(imgBone.x, imgBone.y, imgBone.boneIndex)
            fum.rotation = math.random(1, 360)
            group:insert( fum )
            imgBoneGroup:toFront()
            --local json = require("json")
            display.remove(imgTribones.bone1)                
            display.remove(imgTribones.bone2)
            display.remove(imgTribones.bone3)
        end
        local options = {time = 750, y = display.contentHeight * 0.60, xScale = 6 * SCALE_DEFAULT, yScale = 6 * SCALE_DEFAULT, alpha = 1, rotation = 300, transition = easing.outQuad, onComplete = imgBone.updateTribone}
        if currentBones == 1 then
            imgBone.x = display.contentWidth * 0.5 - 36 * SCALE_DEFAULT - 1
            options.x = display.contentWidth * 0.5 - 72 * SCALE_DEFAULT - 1
        elseif currentBones == 2 then
            imgBone.x = display.contentWidth * 0.5 - 1
            options.x = display.contentWidth * 0.5 - 1
        else
            imgBone.x = display.contentWidth * 0.5 + 36 * SCALE_DEFAULT - 1
            options.x = display.contentWidth * 0.5 + 72 * SCALE_DEFAULT - 1
        end
        imgBone.y = display.contentHeight * 0.41 + (12*SCALE_DEFAULT)
        imgBone:scale(SCALE_DEFAULT, SCALE_DEFAULT)
        transition.from(imgBone, options)
        imgBoneGroup:insert(imgBone)
        group:insert(imgBoneGroup)
    end
    
    if score == mScore then
        local winType = "congrats"
        
        if (score > maxScore) and (maxScoreShown == false) and maxScore > 0 then
            winType = "newRecord"
            
            --palpitar
            lblScore.palpitar = function()
                transition.from(lblScore, {time = 600, xScale = 1.5, yScale = 1.5, easing = easing.easeInOut, onComplete = lblScore.palpitar })            
            end
            transition.from(lblScore, {time = 1000, xScale = 1.5, yScale = 1.5, easing = easing.easeInElastic, onComplete = lblScore.palpitar })   
            maxScoreShown = true
        end
        
        --FlurryController:logEvent("in_win_level", { stage = currentStage, level = currentLevel, win_type = winType, bones = tribones, deaths = gameDeaths, score = mScore, time = myTime })
        
        launchAchievemntFBTransitions()
    end
end

function launchAchievemntFBTransitions()
    --transicio del panel superior
    topGroup:insert(imgTribones)
    topGroup:insert(imgBoneGroup)
    
    transition.to( topGroup, {time = 1000, delay = 1000, y = topGroup.y - display.contentHeight * 0.2, transition = easing.inOutQuad, onComplete = function() topGroup = nil end })
    --transition de la mascara
    shine.alpha = 1
    transition.to( shine, {time = 500, delay = 1250, maskScaleX = 2*SCALE_BIG, maskScaleY = 2*SCALE_BIG })
    --transition del achievement
    transition.to( imgAchievement, {time = 250, delay = 1500, xScale = SCALE_DEFAULT*2, yScale = SCALE_DEFAULT*2, alpha = 1 })
    
    if maxScoreShown == true then--transition del congratulations text
        --transition del FB
        transition.to( btnFB, {time = 250, delay = 3250, alpha = 1, rotation = 0, xScale = SCALE_DEFAULT, yScale = SCALE_DEFAULT, onComplete = function() btnFB.active = true end})
        
        transition.to( btnGameServiceAchievements, {time = 250, delay = 3400, alpha = 1, rotation = 0, xScale = SCALE_DEFAULT, yScale = SCALE_DEFAULT, onComplete = function() btnGameServiceAchievements.active = true end})
        transition.to( btnGameServiceLeaderboard, {time = 250, delay = 3550, alpha = 1, rotation = 0, xScale = SCALE_DEFAULT, yScale = SCALE_DEFAULT, onComplete = function() btnGameServiceLeaderboard.active = true end})
        
        AZ.audio.playFX(AZ.soundLibrary.newRecord, AZ.audio.AUDIO_VOLUME_OTHER_FX)
        lblNewRecord.text = translate("new_record")
        transition.to( lblNewRecord, {time = 1500, delay = 1500, x = display.contentWidth * 0.5, transition = easing.inOutExpo})
        transition.to( btnLevels, {time = 250, delay = 3500, alpha = 1, onComplete = function() btnLevels.active = false  end })
        transition.to( btnReplay, {time = 250, delay = 3500, alpha = 1, onComplete = function() btnReplay.active = false  end })
        transition.to( btnNext, {time = 250, delay = 3500, alpha = 1, onComplete = function() btnNext.active = false  end })
    else
        --transition del FB
        transition.to( btnFB, {time = 250, delay = 2500, xScale = SCALE_DEFAULT, yScale = SCALE_DEFAULT, onComplete = function() btnFB.active = true end})
        transition.to( btnFB, {time = 250, delay = 2500, alpha = 1, rotation = 0})

        transition.to( btnGameServiceAchievements, {time = 250, delay = 2650, alpha = 1, rotation = 0, xScale = SCALE_DEFAULT, yScale = SCALE_DEFAULT, onComplete = function() btnGameServiceAchievements.active = true end})
        transition.to( btnGameServiceLeaderboard, {time = 250, delay = 2800, alpha = 1, rotation = 0, xScale = SCALE_DEFAULT, yScale = SCALE_DEFAULT, onComplete = function() btnGameServiceLeaderboard.active = true end})
        
        transition.to( lblNewRecord, {time = 1500, delay = 1500, x = display.contentWidth * 0.5, transition = easing.inOutExpo})
        transition.to( btnLevels, {time = 250, delay = 2750, alpha = 1, onComplete = function() btnLevels.active = false  end })
        transition.to( btnReplay, {time = 250, delay = 2750, alpha = 1, onComplete = function() btnReplay.active = false  end })
        transition.to( btnNext, {time = 250, delay = 2750, alpha = 1, onComplete = function() btnNext.active = false  end })
    end
	
	finishedAnim = true
end

function incrementTimeScore()
    local myScore = currentDeaths * SCORE_DEATHS + currentLives * SCORE_LIFE + currentCombos + currentTime
    checkScore(myScore, true)
    lblScore.text = myScore
    lblScore.xScale, lblScore.yScale = 1, 1
    transition.from(lblScore, { time = LIVES_TIME, xScale = 2, yScale = 2, transition = easing.easeInBack})--, onComplete = addBones})
end

function doTimeBonus()
    if (currentTime > 0) then
        if lblCombos == nil then
            lblCombos = display.newText(
                translate("bonus_time_score") ..": "..currentTime,
                0,
                display.contentHeight * 0.65,
                INTERSTATE_REGULAR,
                SMALL_FONT_SIZE * SCALE_DEFAULT
            )
            lblCombos:setTextColor(FONT_BLACK_COLOR[1], FONT_BLACK_COLOR[2], FONT_BLACK_COLOR[3], FONT_BLACK_COLOR[4])
            lblCombos.anchorX, lblCombos.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
            lblCombos.x = display.contentWidth * 0.5
            lblCombos.alpha = 0
            group:insert(lblCombos)
        else
            lblCombos.text = translate("bonus_time_score") ..": "..currentTime
        end
        timerID = timer.performWithDelay( LIVES_TIME, function()
            transition.to(lblCombos, {time = LIVES_TIME, alpha = 1, transition = easing.inOutExpo, onComplete = function()
                --es mante el lbl sense sumarse res)
                timerID = timer.performWithDelay(LOLLIPOPCOMBO_TIME, function()
                    --despareix el lbl
                    transition.to(lblCombos, {time = LOLLIPOPCOMBO_TIME, alpha = 0, transition = easing.inExpo})
                    --suma la puntuacio
                    timerID = timer.performWithDelay(LOLLIPOPCOMBO_TIME, incrementTimeScore, 1)
                end, 1)
            end})
        end, 1)
    else
        print("Current Combos: ".. currentCombos ..", current time: ".. currentTime)
        local myScore = currentDeaths * SCORE_DEATHS + currentLives * SCORE_LIFE + currentCombos + currentTime 
        print("MyScore: ".. myScore ..", real score: ".. mScore)
        checkScore(myScore)
    end
end

function incrementCombosScore()
    currentCombos = gameCombos
    local myScore = currentDeaths * SCORE_DEATHS + currentLives * SCORE_LIFE + currentCombos
    checkScore(myScore)
    lblScore.text = myScore
    lblScore.xScale, lblScore.yScale = 1, 1
    transition.from(lblScore, { time = LIVES_TIME, xScale = 2, yScale = 2, transition = easing.easeInBack})
    
    doTimeBonus()
    
end

function incrementLivesScore()
    currentLives = currentLives + 1

    local score = currentDeaths * SCORE_DEATHS + currentLives * SCORE_LIFE
    checkScore(score)

    lblScore.text = score
    lblScore.xScale, lblScore.yScale = 1, 1
    transition.from(lblScore, { time = LIVES_TIME, xScale = 2, yScale = 2, transition = easing.easeInBack})

    if currentLives == gameLives then
        if gameCombos > 0 then
            --animacio dels combos
            lblCombos = display.newText(
                translate("bonus_combo_score") ..": ".. gameCombos,
                0,
                display.contentHeight * 0.65,
                INTERSTATE_REGULAR,
                SMALL_FONT_SIZE * SCALE_DEFAULT
            )
            lblCombos:setTextColor(FONT_BLACK_COLOR[1], FONT_BLACK_COLOR[2], FONT_BLACK_COLOR[3], FONT_BLACK_COLOR[4])
            lblCombos.anchorX, lblCombos.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
            lblCombos.x = display.contentWidth * 0.5
            lblCombos.alpha = 0
            group:insert(lblCombos)
            --apareix el lblCombos
            transition.to(lblCombos, {time = LIVES_TIME, alpha = 1, transition = easing.inOutExpo, onComplete = function()
                --es mante el lbl sense sumarse res)
                timerID = timer.performWithDelay(LOLLIPOPCOMBO_TIME, function()
                    --despareix el lbl
                    transition.to(lblCombos, {time = LOLLIPOPCOMBO_TIME, alpha = 0, transition = easing.inExpo})
                    --suma la puntuacio
                    timerID = timer.performWithDelay(LOLLIPOPCOMBO_TIME, incrementCombosScore, 1)
                end, 1)
            end})
        else
            doTimeBonus()
        end
    end
end

local function lollipopsEffect()
    local x = display.contentWidth * 0.5
    local h = gameLives - 1
    local soundCount = 1
    for i = 1, gameLives, 1 do
        local imgLollipop = display.newImage(winLevelSheet, 22, 0, display.contentHeight * 0.55)
        imgLollipop:scale(2.5*SCALE_DEFAULT,2.5*SCALE_DEFAULT)
        if gameLives == 3 then
            imgLollipop.x = x + (50 * SCALE_DEFAULT * (i - 2))
        elseif gameLives == 2 then
            imgLollipop.x = x + (25 * SCALE_DEFAULT * (i * 2 - 3))
        else
            imgLollipop.x = x
        end
        imgLollipop.alpha = 0
        imgLollipop.anim = function(i, h)
            local _delay = LOLLIPOPCOMBO_TIME * (h-1) - LOLLIPOPCOMBO_TIME * 0.5 * i
            --apareixer
            imgLollipop.transitionID = transition.to(imgLollipop, {delay = LOLLIPOPCOMBO_TIME * i, time = LOLLIPOPCOMBO_TIME, alpha = 1, xScale = SCALE_DEFAULT, yScale = SCALE_DEFAULT, onComplete = function()
                --moure cap a score
                local lollipopInfo = AZ.soundLibrary.lollipopSound
                imgLollipop.timerID = timer.performWithDelay( _delay + 100, function()
                    AZ.audio.playFX(lollipopInfo[soundCount], AZ.audio.AUDIO_VOLUME_OTHER_FX)
                    soundCount = soundCount + 1
                end, 1)
                imgLollipop.transitionID = transition.to(imgLollipop, {delay = _delay * i, time = LIVES_TIME * 3, alpha = 0, x = lblScore.x, y = lblScore.y, xScale = 0.01, yScale = 0.01, transition = easing.inExpo, onComplete = imgLollipop.disappear})
            end
            })
        end
        imgLollipop.anim(i, h+1)
        imgLollipop.disappear = function()
            incrementLivesScore()
            imgLollipop.immediateDestroy()
        end

        imgLollipop.immediateDestroy = function()
            if imgLollipop ~= nil then
                if imgLollipop.transitionID ~= nil then
                    transition.cancel(imgLollipop.transitionID)
                end

                if imgLollipop.timerID ~= nil then
                    timer.cancel(imgLollipop.timerID)
                end

                imgLollipop:removeSelf()
                imgLollipop = nil
            end
        end
        group:insert(imgLollipop)
        lollipopsTable[i] = imgLollipop
        h = h - 1
    end
end
            
function incrementDeathScore( )
    currentDeaths = currentDeaths + 1
    lblDeaths.text = currentDeaths
    local score = currentDeaths * SCORE_DEATHS
    checkScore(score)
    lblScore.text = score

    if currentDeaths == gameDeaths then
        lollipopsEffect()
    end
end

local runtime = 0

local function getDeltaTime()
   local temp = system.getTimer()  --Get current game time in ms
   local dt = (temp-runtime) / 1000
   runtime = temp  --Store game time
   return dt
end

local function rotate()
    if shine.rotate ~= nil then
        local rotation = ROTATION_SPEED * getDeltaTime()
        shine:rotate(rotation)
        shine.maskRotation = shine.maskRotation - rotation
    end
end

function scene:createScene( event )
	
	finishedAnim = false
	
    group = self.view
    
    translate = AZ.utils.translate
    
    imgBoneGroup = display.newGroup()
    
    maxScoreShown = false
    
    winLevelSheet = graphics.newImageSheet("assets/guiSheet/levelsIngameWinLose.png", AZ.atlas:getSheet())
    
    local background = display.newImage(WIN_PATH)
    background:scale(display.contentHeight/background.height, display.contentHeight/background.height) 
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    currentStage = event.params.currentStage
    currentLevel = event.params.currentLevel
    gameDeaths = event.params.gameDeaths
    gameLives = event.params.gameLives
    gameCombos = event.params.gameCombos
    currentDeaths = 0
    currentLives = 0
    currentCombos = 0
    
    shine = display.newImage(winLevelSheet, 23)
    shine.x = display.contentWidth* 0.33
    shine.y = display.contentHeight * 0.52
    shine:scale(SCALE_BIG *1.5, SCALE_BIG *1.5)
    local shine_mask = graphics.newMask("assets/mascaragirador.jpg")
    shine.maskX = shine.x
    shine.maskY = shine.y
    shine:setMask(shine_mask)
    --se li posa un valor molt petit a la mascara perque si esta a 0, es com no tenir mascara
    --l'alpha es posa a 0 per assegurar-nos de que no veiem cap pixel fins que no començem l'animació
    shine.maskScaleX = 0.001
    shine.maskScaleY = 0.001
    shine.alpha = 0
    
    myTime = event.params.gameTime
    
    group:insert(background)
    group:insert(shine)
    group:insert(createWinButtons())
    group:insert(createWinGUI(event.params.gameTime))
    writeInfo(event.params.gameCombos, event.params.gameDeaths, event.params.gameLives, event.params.gameTime)
    group:insert(imgTribones)

    
    
    Runtime:addEventListener("enterFrame", rotate)
end
 
local function bonesPerCent(stageInfo)
    local sum = 0
    for i=1, 9 do
        --sum = sum + stageInfo[i].tribones
    end
    return math.round(sum*100/27)
end

function scene:enterScene()
    
	finishedAnim = false
	
    if currentLevel == 9 then
        AZ.audio.playBSO(AZ.soundLibrary.ultimateWinLoop, AZ.audio.AUDIO_VOLUME_BSO)
    else
        audio.stop(1)
        if AZ.audio.BSO_ENABLED == true then
            al.Source(audio.getSourceFromChannel(1), al.PITCH, 1)
            audio.play(AZ.soundLibrary.winSound, { channel = 1 })
            audio.setVolume(AZ.audio.AUDIO_VOLUME_BSO, { channel = 1 })
        end
    end
    
    local connection = AZ.utils.testConnection()
    
    if gameDeaths > 0 then
        timerID =  timer.performWithDelay(DEATHS_TIME / gameDeaths, incrementDeathScore, gameDeaths)
    else
        --skip to next anim
        lollipopsEffect()
        --zombie activist achievement completed
        if connection == true then
            --local sendActivistAchievement = function()
                GameServicesController:sendAchievement(1,100)
                
            --    coroutine.yield()
            --end
            
            --local achivement = coroutine.create(sendActivistAchievement)
            --coroutine.resume(achievement)
        end
    end
    
    -- enviar puntuacions i achievement
    if connection == true then
        --local sendOtherAchievements = function()
            GameServicesController:sendAllToScoreboard(currentStage)--puntuacions
            GameServicesController:sendAchievement(stage_level_info[currentLevel].emblem, 100)--achievement del nivell
            stageInfo = AZ.personal.loadPersonalData(AZ.personal.relativeLevels .. currentStage ..".json")--calcul del golden bone del stage
            GameServicesController:sendAchievement(golden_bone[currentStage],bonesPerCent(stageInfo))--achievement del golden bone del stage
            
        --    coroutine.yield()
        --end
        
        --local achievements = coroutine.create(sendOtherAchievements)
        --coroutine.resume(achievements)
    end
end

function scene:destroyScene( event )
    local group = self.view
    for i=1, gameLives do
        if lollipopsTable[i] ~= nil then
            lollipopsTable[i].immediateDestroy()
        end
    end
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
--scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene)

return scene

