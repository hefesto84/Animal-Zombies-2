
local scene = AZ.S.newScene() 

local currentStage = nil
local currentLevel = nil
local params = nil
-- paràmetre que es fa servir per escalar texts i botons
local _R = SCALE_BIG
-- paràmetre que es fa servir per escalar les posicions dels elements
local _S = nil

--array per guardar la posició de cada zombie a l'spriteSheet i la crida a la traducció pertinent
local z = AZ.zombiesLibrary
--S'haurà de canviar la descripció local perquè apunti a l'arxiu tranlations
local zombies = {
    [z.ZOMBIE_RABBIT_NAME] = {5, "The Rabbit has killed you"}, 
    [z.ZOMBIE_MOLE_NAME] = {18, "A Mole has died"}, --s'haurà de canviar quan hi hagi el nou spriteSheet
    [z.ZOMBIE_DOG_NAME] = {14, "The Dog has killed you"}, 
    [z.ZOMBIE_PARROT_NAME] = {1, "The Parrot has killed you"}, 
    [z.ZOMBIE_PIG_NAME] = {2, "The Pig has killed you"}, 
    [z.ZOMBIE_CAT_NAME] = {7, "The Cat has killed you"}, 
    [z.ZOMBIE_FISH_NAME] = {15, "The Fish has killed you"}, 
    [z.ZOMBIE_TORTOISE_NAME] = {19, "The Tortoise has killed you"}, 
    [z.ZOMBIE_QUEEN_NAME] = {16, "Miss Hysterical has died"},--s'haurà de canviar quan hi hagi el nou spriteSheet 
    [z.ZOMBIE_CHIHUAHUA_NAME] = {3, "The Chihuahua has killed you"}, 
    [z.ZOMBIE_DUCK_NAME] = {12, "The Duck has killed you"}, 
    [z.ZOMBIE_TURKEY_NAME] = {13, "The Turkey has killed you"}, 
    [z.ZOMBIE_CAGE_NAME] = {9, "The Cage has killed you"}, 
    [z.ZOMBIE_RAT_NAME] = {17, "The Rat has killed you"}, 
    [z.ZOMBIE_POSSUM_NAME] = {20, "The Possum has killed you"}, 
    [z.ZOMBIE_BEAR_NAME] = {11, "The Bear has killed you"}, 
    [z.ZOMBIE_MOOSE_NAME] = {4, "The Moose has killed you"}, 
    [z.ZOMBIE_SKUNK_NAME] = {10, "The Skunk has killed you"},
    [z.ZOMBIE_GIRL_SCOUT_NAME]  = {8, "The Girl Scout has died"},
    [z.ZOMBIE_UTER_NAME] = {6, "Uter has died"}
}

local btnLives = nil
local translate = nil

local onTouch = function(event)
    if event.phase == "ended" or event.phase == "release" then
        local options = {
            effect = SCENE_TRANSITION_EFFECT,
            time = SCENE_TRANSITION_TIME,
            params = { stage = currentStage, level = currentLevel }
        }
        
        if timerID ~= nil then
            timer.cancel(timerID)
        end
        
        --FlurryController:logEvent("in_loose_level", { stage = currentStage, level = currentLevel, loose_button = event.id })
        
        if event.isBackKey or (event.target.id == "Levels" and event.target.isWithinBounds) then
			options.effect = "slideRight"
            AZ.S.gotoScene("levels.levels2", options)
        elseif event.target.id == "Replay" and event.target.isWithinBounds then
			if AZ.userInfo.lifesCurrent > 0 then
				AZ.S.gotoScene("loading.loading", options)
			else
				local options = {
					effect = "crossFade",
					time = 1000,
					isModal = true
				}
				AZ.S.showOverlay("popups.popupwolives", options)
			end
        elseif event.target.id == "Shop" and event.target.isWithinBounds then
            options.params = params
            options.params.source = {"lose.lose"}
            AZ.S.gotoScene("shop.shop", options)
        elseif event.target.id == "Lifes" and event.target.isWithinBounds then
            local options = {
                effect = "crossFade",
                time = 1000,
                isModal = true
            }
            AZ.S.showOverlay("popups.popupwolives", options)
        end
    end
end 

function scene.onBackTouch()
	onTouch({ phase = "ended", isBackKey = true })
end

function scene.createBtn(params)--(myImageSheet, id, x, y, btnIndex, grp, scale, iconIndex, iconX, iconY, txtParams)
	local btn = AZ.ui.newTouchButton({ id = params.id, x = params.x, y = params.y, touchSound = params.touchSound or AZ.soundLibrary.buttonSound, releaseSound = params.releaseSound, btnIndex = params.btnIndex, iconIndex = params.iconIndex, iconX = params.iconX, iconY = params.iconY, txtParams = params.txtParams, imageSheet = params.imageSheet, onTouch = onTouch })
	btn:setScale(params.scale, params.scale)
	if params.grp then
		params.grp:insert(btn)
	end
	return btn
end

local function createLooseButtons(myImageSheet)

	local grp = display.newGroup()
	local y = display.contentHeight -(SCALE_DEFAULT *100)
	local scale = _R *1.2
	
	local btnLevels = scene.createBtn({imageSheet = myImageSheet, id = "Levels", x = display.contentWidth *0.17, y = y, btnIndex = 5, grp = grp, scale = scale, touchSound = AZ.soundLibrary.backBtnSound})
	local btnReplay = scene.createBtn({imageSheet = myImageSheet, id = "Replay", x = display.contentWidth *0.83, y = y, btnIndex = 2, grp = grp, scale = scale, touchSound = AZ.soundLibrary.forwardBtnSound})
	local btnShop = scene.createBtn({imageSheet = myImageSheet, id = "Shop", x = display.contentCenterX, y = y, btnIndex = 3, grp = grp, scale = scale})
	if #AZ.userInfo.shopNewItems > 0 then
		btnShop.newItemsMarker = display.newImage(myImageSheet, 1, -30, -30)
		btnShop:insert(btnShop.newItemsMarker)
		btnShop.newItemsLabel = display.newText({ text = tostring(#AZ.userInfo.shopNewItems), font = INTERSTATE_BOLD, fontSize = 20, x = -30, y = -31 })
		btnShop.newItemsLabel:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
		btnShop:insert(btnShop.newItemsLabel)
	end
	
	btnShop.anchorY = 1
    
    return grp
end

local function getTime(t)
    local min, sec = 0
    
    min = math.floor( t/60 )
    if min < 10 then
        min = "0"..min
    end
    sec = math.floor( t%60 )
    if sec < 10 then
        sec = "0"..sec
    end
    return (min..":"..sec)
end

local function createKillerZombie(params, myImageSheet)
    local group = display.newGroup()
    
	if params.killer == "none" then
		print("\tel killer era none")
		return group
	end
	
    local killerZombie = display.newImage(myImageSheet, zombies[params.killer][1])
    killerZombie:scale(_R, _R)
    killerZombie.anchorX, killerZombie.anchorY = 0.5, 0.5
    killerZombie.x, killerZombie.y = display.contentCenterX+110*_S, display.contentHeight*0.47
    group:insert(killerZombie)
    
    local killerZombieDesc = display.newEmbossedText(
        zombies[params.killer][2], 
        display.contentCenterX, 
        display.contentHeight*0.62, 
        display.contentWidth*0.8, 
        0, 
        INTERSTATE_REGULAR, 
        SMALL_FONT_SIZE * SCALE_DEFAULT
    )
    killerZombieDesc:setFillColor(1, 1, 1)
    group:insert(killerZombieDesc)
    
    return group
end

local function currentLifesListener(event)
	btnLives.txt.text = event.lifes
end

local function createLooseGUI(params,myImageSheet, myImageSheet2)
    
	local groupLooseGUI = display.newGroup()
	
    --GameOver title
    local gameOverTxt = AZ.ui.createShadowText(translate("game_over"), display.contentCenterX, display.contentHeight *0.1, 45 * SCALE_BIG)
    groupLooseGUI:insert(gameOverTxt)
    
    --Deaths board
    local lblDeathsTitle = display.newText(
        translate("deaths"),
        display.contentWidth/2 - 145*_S,
        display.contentHeight * 0.72,
        BRUSH_SCRIPT,
        SMALL_FONT_SIZE * SCALE_DEFAULT
    )
    lblDeathsTitle.anchorX, lblDeathsTitle.anchorY = 0.5, 0.5
    lblDeathsTitle:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
    groupLooseGUI:insert(lblDeathsTitle)
	
    local lblDeaths = display.newText(
        tostring(params.gameDeaths),
        display.contentWidth/2 - 145*_S,
        display.contentHeight * 0.76,
        INTERSTATE_BOLD,
        (BIG_FONT_SIZE + 5) * SCALE_DEFAULT
    )
    lblDeaths.anchorX, lblDeaths.anchorY = 0.5, 0.5
    lblDeaths:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
    groupLooseGUI:insert(lblDeaths)
    
    local deathsScoreBar = display.newLine(0, 0, 0, 75*_S)
    deathsScoreBar.anchorX, deathsScoreBar.anchorY = 0.5, 0.5
    deathsScoreBar.x, deathsScoreBar.y = display.contentWidth/2 - 105*_S, display.contentHeight * 0.69
    deathsScoreBar.stroke = {0.2,0.2,0.2,0.2}
    deathsScoreBar.strokeWidth = 2*_S
    groupLooseGUI:insert(deathsScoreBar)
    
    --Score board
    local lblScoreTitle = display.newText(
        translate("score"),
        display.contentWidth/2 - 55*_S,
        display.contentHeight * 0.72,
        BRUSH_SCRIPT,
        SMALL_FONT_SIZE * SCALE_DEFAULT
    )
    lblScoreTitle.anchorX, lblScoreTitle.anchorY = 0.5, 0.5
    lblScoreTitle:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
    groupLooseGUI:insert(lblScoreTitle)
	
    local lblScore = display.newText(
        tostring(params.gameDeaths*SCORE_DEATHS+params.gameCombos),
        display.contentWidth/2 - 55*_S,
        display.contentHeight * 0.76,
        INTERSTATE_BOLD,
        (BIG_FONT_SIZE + 5) * SCALE_DEFAULT
    )
    lblScore.anchorX, lblScore.anchorY = 0.5, 0.5
    lblScore:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
    groupLooseGUI:insert(lblScore)
    
    local scoreTimeBar = display.newLine(0, 0, 0, 75*_S)
    scoreTimeBar.anchorX, scoreTimeBar.anchorY = 0.5, 0.5
    scoreTimeBar.x, scoreTimeBar.y = display.contentWidth/2 - 5*_S, display.contentHeight * 0.69
    scoreTimeBar.stroke = {0.2,0.2,0.2,0.2}
    scoreTimeBar.strokeWidth = 2*_S
    groupLooseGUI:insert(scoreTimeBar)
    
    --Time board
    local lblTimeTitle = display.newText(
        translate("time"),
        display.contentWidth/2 + 45*_S,
        display.contentHeight * 0.72,
        BRUSH_SCRIPT,
        SMALL_FONT_SIZE * SCALE_DEFAULT
    )
    lblTimeTitle.anchorX, lblTimeTitle.anchorY = 0.5, 0.5
    lblTimeTitle:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
    groupLooseGUI:insert(lblTimeTitle)
	
    local t = params.gameTime *0.001
    local lblTime = display.newText(
        getTime(t),
        display.contentWidth/2 + 45*_S,
        display.contentHeight * 0.76,
        INTERSTATE_BOLD,
        (BIG_FONT_SIZE + 5) * SCALE_DEFAULT
    )
    lblTime.anchorX, lblTime.anchorY = 0.5, 0.5
    lblTime:setFillColor(AZ.utils.getColor(AZ_DARK_RGB))
    groupLooseGUI:insert(lblTime)
    
    local timeLifesBar = display.newLine(0, 0, 0, 75*_S)
    timeLifesBar.anchorX, timeLifesBar.anchorY = 0.5, 0.5
    timeLifesBar.x, timeLifesBar.y = display.contentWidth/2 + 90*_S, display.contentHeight * 0.69
    timeLifesBar.stroke = {0.2,0.2,0.2,0.2}
    timeLifesBar.strokeWidth = 2*_S
    groupLooseGUI:insert(timeLifesBar)

    --Lives board
	btnLives = scene.createBtn({
		imageSheet = myImageSheet,
		id = "Lifes", 
		x = display.contentWidth/2+135*_S,
		y = display.contentHeight*0.74,
		btnIndex = 4,
		scale = _S,
		iconIndex = 7, 
		iconX = 40, 
		iconY = 15, 
		txtParams = {
			text = tostring(AZ.userInfo.lifesCurrent), 
			x = 0, 
			y = -3, 
			font = INTERSTATE_BOLD, 
			fontSize = 30,
			color = AZ_DARK_RGB
		},
		touchSound = AZ.soundLibrary.heartsAccessSound
	})
    groupLooseGUI:insert(btnLives)
	
    groupLooseGUI:insert(createKillerZombie(params, myImageSheet2))

    return groupLooseGUI
    
end

function scene:createScene( event )
    
    AZ.userInfo.lifesCurrent = AZ.userInfo.lifesCurrent -1
    AZ:saveData()
	
	translate = AZ.utils.translate
    
    local group = self.view
    local infoSheet = require "lose.assets.lose"
    local myImageSheet = graphics.newImageSheet("lose/assets/lose.png", infoSheet:getSheet())
    local infoSheet2 = require "lose.assets.lose2"
    local myImageSheet2 = graphics.newImageSheet("lose/assets/lose2.png", infoSheet2:getSheet())
    params = event.params
    
    
    --FlurryController:logEvent("in_loose_level", { stage = event.params.currentStage, level = event.params.currentLevel, deaths = event.params.gameDeaths, time = event.params.gameTime })

    local background = display.newImage("lose/assets/lose_bg.jpg")
    _S = display.contentHeight/background.height
    background:scale(display.contentHeight/background.height, display.contentHeight/background.height) 
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    currentStage = event.params.currentStage
    currentLevel = event.params.currentLevel
    
    group:insert(background)
	scene.loseButtonsGroup = createLooseButtons(myImageSheet)
    group:insert(scene.loseButtonsGroup)
	scene.loseButtonsGroup.x = display.contentWidth
	scene.loseButtonsGroup.alpha = 0
    group:insert(createLooseGUI(params,myImageSheet, myImageSheet2))
	
	Runtime:addEventListener(RECOVERED_LIFES_EVNAME, currentLifesListener)
    
end

function scene:enterScene( event )
    audio.stop(1)
    if AZ.audio.BSO_ENABLED == true then
        al.Source(audio.getSourceFromChannel(1), al.PITCH, 1)
        audio.play(AZ.soundLibrary.loseSound, { channel = 1 })
        audio.setVolume(AZ.audio.AUDIO_VOLUME_BSO, { channel = 1 })
    end
    
    if AZ.userInfo.lifesCurrent == 0 then
        AZ.recoveryController:initRecoveryProcess()
    end    
	
	transition.to( scene.loseButtonsGroup, {time = 500, delay = 500, alpha = 1, x = 0, transition = easing.outElastic})
end

function scene:exitScene(event)
	Runtime:removeEventListener(RECOVERED_LIFES_EVNAME, currentLifesListener)
	transition.cancel(scene.loseButtonsGroup)
end

function scene:overlayEnded(event)
	currentLifesListener({lifes = AZ.userInfo.lifesCurrent})
end

scene:addEventListener(ANDROID_BACK_BUTTON_TOUCH_EVNAME, scene.onBackTouch)

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener("exitScene", scene ) 
scene:addEventListener( "overlayEnded", scene )
 
return scene



