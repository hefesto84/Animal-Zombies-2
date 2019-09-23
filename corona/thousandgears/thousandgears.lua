
local scene = AZ.S.newScene()

local loaderTrans = nil


function scene.endSplash(event)
    
    if event.remains then
        AZ.Gamedonia:getData()
    else
        Runtime:removeEventListener(GAMEDONIA_DATA_RECEIVED_EVNAME, scene.endSplash)
        
        AZ:configureUser()
        if type(AZ.userInfo.shopNewItems) == "number" then
			AZ.userInfo.shopNewItems = {}
		end
		
		local function gotoMenu()
			
			loaderTrans = transition.safeCancel(loaderTrans)
			
			if AZ.gotoGameplay then
				AZ.S.gotoScene("test_ingameScene", { params = { stage = AZ.gotoGameplay.stage, level = AZ.gotoGameplay.level } })
			else
				AZ.S.gotoScene("menu.menu", { effect = SCENE_TRANSITION_EFFECT, time = SCENE_TRANSITION_TIME })
			end
		end
		
		--[[if AZ.userInfo.fbToken then
			AZ.fb:login(gotoMenu)
		else]]
			gotoMenu()
		--end
    end
end

function scene:createScene(event)
    
	require "GameServicesController"
    GameServicesController:initialize()
	
    local bg = display.newImage("thousandgears/assets/splash_tg.jpg")
    bg:scale(display.contentHeight/bg.height, display.contentHeight/bg.height) 
    bg.x, bg.y = display.contentCenterX, display.contentCenterY
    scene.view:insert(bg)
	
	local loader = display.newImage("assets/loader.png")
	loader.x, loader.y = display.contentCenterX, display.contentHeight *0.85
	loader:scale(SCALE_DEFAULT, SCALE_DEFAULT)
	scene.view:insert(loader)
	
	local function rotate()
		loader.rotation = 0
		loaderTrans = transition.to(loader, { time = 1000, rotation = 360, onComplete = rotate })
	end
	rotate()
end

function scene.loggedInGamedonia()
    Runtime:removeEventListener(GAMEDONIA_JUST_SETTED_EVNAME, scene.loggedInGamedonia)
    
    AZ.Gamedonia:getData()
end

function scene:enterScene(event)
    
    Runtime:addEventListener(GAMEDONIA_DATA_RECEIVED_EVNAME, scene.endSplash)
    
    if AZ.Gamedonia.isUserSetted then
        AZ.Gamedonia:getData()
    else
        Runtime:addEventListener(GAMEDONIA_JUST_SETTED_EVNAME, scene.loggedInGamedonia)
    end
end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )

return scene