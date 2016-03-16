AZ = {}

local isInitialized = false

AZ.S = nil

AZ.userInfo = nil
AZ.gameInfo = {}
AZ.slotInfo = nil
AZ.bankInfo = nil
AZ.shopInfo = nil
AZ.localization = nil
AZ.tipsInfo = nil

-- si activem aquesta opció, NO sobreescriurem els json de gamedonia
AZ.isOfflineMode = false

AZ.versionCode = 29

-- other settings
--AZ.gotoGameplay = { stage = 1, level = 6 }
AZ.spawnPatterns = true
AZ.showTips = true
AZ.isTest = false
AZ.isGodMode = false
AZ.isUnlimitedAmmo = false
AZ.isUnlimitedCoins = false
AZ.isSurvivalEnabled = false


function AZ:unloadModule(m)
    AZ.utils.unloadModule(m)
end

function AZ:assertParam(param, errorName, errorMessage)
    AZ.utils.assertParam(param, errorName, errorMessage)
end

function AZ:saveData()
    AZ.jsonIO:writeFile(FILE_USER_INFO, AZ.userInfo)
    AZ.Gamedonia:updateUserData()
end

function AZ:getConnextion()
	return network.getConnectionStatus().isConnected
end

local function prepare()

    AZ.S					= require "superStoryboard"
    AZ.utils				= require "utils"
    AZ.ui					= require "ui"
    AZ.gui					= require "gui"
    AZ.audio				= require "controller.audio.audioController"
    AZ.animsLibrary		= require "test_animsLibrary"
    AZ.soundLibrary		= require "soundsLibrary"
    AZ.zombiesLibrary		= require "zombiesLibrary"      
    AZ.atlas				= require "atlas"
    AZ.jsonIO				= require "jsonIO"
    AZ.fb					= require "controller.fb"
	AZ.achievementsManager	= require "achievements.achievementsManager"
	
    AZ.notificationController = require "test_notificationController"
    AZ.notificationController:init({}); 
    
    AZ.recoveryController = require "test_recoveryController"
    AZ.recoveryController:init({});
        
    require "constants"
    require "test_constants"
    require "resolutions"
--    AZ.translations	= require "translations"
    AZ.loader			= require "loader"
	
    system.setIdleTimer(false)
    display.setStatusBar(display.HiddenStatusBar)
    
    AZ.utils.activateDeactivateMultitouch(false)
    AZ.utils.platform = system.getInfo("platformName")
	
	AZ.soundLibrary.loadSounds()
	
	if AZ.isTest then
		require "debugLog"
	end
	
	AZ.Gamedonia = require "controller.gamedonia.GamedoniaController"
	AZ.Gamedonia:init()
end

function AZ:configureUser()
    
    AZ.audio.setBSO(AZ.userInfo.music == 1)
    AZ.audio.setFX(AZ.userInfo.sound == 1)
    AZ.utils.setVibration(AZ.userInfo.vibration == 1)

    if AZ.isUnlimitedCoins then
        AZ.userInfo.money = 999999
    end
end

function AZ:initialize()
    if not isInitialized then
        prepare()
        isInitialized = true
    end
end

return AZ