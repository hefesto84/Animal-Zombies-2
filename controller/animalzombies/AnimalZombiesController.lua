local middleclass = require 'middleclass'

AZ = class('Singleton')
Singleton = AZ()

-- requires
AZ.utils            = ""
AZ.ui               = ""
AZ.gui              = ""
AZ.personal         = ""
--AZ.translations     = ""
AZ.json             = ""
AZ.audio            = ""
AZ.animsLibrary     = ""
AZ.soundLibrary     = ""
AZ.zombiesLibrary   = ""
AZ.constants        = ""
AZ.atlas            = ""
AZ.jsonIO           = ""

-- other settings
AZ.userInfo = nil
AZ.gameInfo = nil
AZ.isAZ2 = true
AZ.showTips = false
AZ.isTest = false
AZ.isGodMode = true
AZ.isSurvivalEnabled = false
AZ.lastVersion = 2


function AZ:unloadModule(m)
    AZ.utils.unloadModule(m)
end

function AZ:assertParam(param, errorName, errorMessage)
    AZ.utils.assertParam(param, errorName, errorMessage)
end

function AZ:setDataInfoFromInternet(filename,typename)
    local params = {}

    params.response = {
        filename = filename,
        baseDirectory = system.DocumentsDirectory
    }
    
    local function networkListener(event)
        
        print(" - Downloading data: "..filename)
        
        if event.isError then
            -- Implementar càrrega per defecte de json buit
        end
        if event.phase == "ended" then
            local path = system.pathForFile(filename, system.DocumentsDirectory)
            local fileHandle, errorString = io.open( path, "r" )
            
            if(fileHandle) then
                
                local contents = AZ.json.decode(fileHandle:read("*a"))
                
                if(typename=="userInfo") then
                    local shopInfo = AZ.personal.loadPersonalData(AZ.personal.shopInfo)
                    local bankInfo = AZ.personal.loadPersonalData(AZ.personal.bankInfo)

                    if shopInfo == nil then
                        AZ.personal.createShopData()
                    end

                    if bankInfo == nil then
                        AZ.personal.createBankData()
                    end

                    AZ.utils.currentLanguage = contents.language

                    AZ.audio.setBSO(false) --contents.sound == 1)
                    AZ.audio.setFX(false) --contents.fx == 1)
                    AZ.utils.setVibration(contents.fx == 1)

                    AZ.userInfo = contents
                    AZ.jsonIO:writeFile(AZ.personal.genericInfo, contents) 
                end
                
                if(typename=="gameInfo") then
                    AZ.gameInfo = contents
                    AZ.jsonIO:writeFile(FILE_GAME_INFO, contents)
                end
                
                AZ.jsonIO:synchronize()
                AZ:setInfo()
            end
            
        end
    end
    network.request("http://23.92.24.222/bpweb/"..filename,"GET",networkListener,params)
    
end

function AZ:setInfo()
    local info = AZ.personal.loadPersonalData(AZ.personal.genericInfo)
    local shopInfo = AZ.personal.loadPersonalData(AZ.personal.shopInfo)
    local bankInfo = AZ.personal.loadPersonalData(AZ.personal.bankInfo)

    if info == nil then
        info = AZ.personal.resetPersonalData()
    else
        AZ.personal.updateAchievements(info.achievements)
        info = AZ.personal.updateVersion(info)
    end
    
    if shopInfo == nil then
        AZ.personal.createShopData()
    end
    
    if bankInfo == nil then
        AZ.personal.createBankData()
    end
    
    AZ.utils.currentLanguage = info.language
    
    AZ.audio.setBSO(info.music == 1)
    AZ.audio.setFX(info.sound == 1)
    AZ.utils.setVibration(info.vibration == 1)
end

function AZ:initSettings()
    
    system.setIdleTimer(false)
    display.setStatusBar(display.HiddenStatusBar)
    AZ.utils.activateDeactivateMultitouch(true)
    AZ.utils.platform = system.getInfo("platformName")
    
    AZ.soundLibrary.loadSounds()
    
    if AZ.isTest then
        require "debugLog"
    end

    --
    AZ:setDataInfoFromInternet("user.json", "userInfo")
    AZ:setDataInfoFromInternet("balance.json", "gameInfo")
end

function AZ:initialize()
    AZ.utils            = require "utils"
    AZ.ui               = require "ui"
    AZ.gui              = require "gui"
    AZ.personal         = require "personal"
    AZ.json             = require "json"
    AZ.audio            = require "controller.audio.audioController"
    AZ.animsLibrary     = require "test_animsLibrary"
    AZ.soundLibrary     = require "soundsLibrary"
    AZ.zombiesLibrary   = require "zombiesLibrary"
    AZ.constants        = require "constants"
    AZ.atlas            = require "atlas"
    AZ.jsonIO           = require "jsonIO"
    
    require "test_constants"
--    AZ.translations     = require "translations"
    
    
    self.initSettings()
end