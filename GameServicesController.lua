local middleclass = require 'middleclass'

require "scoreboardContainer"
require "emblemContainer"

local active = false

GameServicesController = class('Singleton')
Singleton = GameServicesController()

GameServicesController.loggedIntoGC = nil
GameServicesController.retryStage = nil
GameServicesController.retryEmblem = nil
GameServicesController.retryShow = nil

-- gameServiceName ha de ser gamecenter (iOS) o google (Android)
GameServicesController.gameServiceName = ""

GameServicesController.achievements = {}

--[[flow de funcions:
al principi de l'aplicacio fem login amb GameServicesController:login() -> GameServicesController:loginListener() -> esperar
                                                \--si es android--> GameServicesController:androidListener()--/
quan s'envia la puntuacio GameServicesController:sendAllToScoreboard(stage) ---si ja haviem entrat---> sendScoreTime(stage) i altres funcions locals que envien i calculen la puntuacio
                            \- sino fem login -> GameServicesController:login() -> GameServicesController:loginListener() -/

no cal implementar un codi que controli que els emblemas que s'han afegit anteriorment han arribat per mirar d'intentar enviar-los despres: ho fa el game center sol.
]]
 
local function getTime(t)
    if not active then return end
    local min, sec = 0

    min = math.floor( t/60 )
    sec = math.floor( t%60 )
    if sec < 10 then
        sec = "0"..sec
    end
    return (min..":"..sec)
end

--calcula el temps total que ha trigat l'usuari a pasar-se el stage o el joc (si no s'ho ha passat sencer, aborta retornant nil)
--parametre stage opcional
local function calcTime(stage)
    if not active then return end
    local time = 0
    local stageData = {}
    --si hem de calcular tots els stages
    if (stage == nil) then
        for i = 1, STAGES_COUNT do
            stageData = AZ.personal.loadPersonalData(AZ.personal.relativeLevels .. i .. ".json")
            for j = 1, 9 do
                --if a value is not yet set, quit
                if stageData[j].time == -1 then
                    --print("***GAME SERVICE***: aborting global time count because of level: "..i.."-"..j)
                    return nil
                else
                    time = time + stageData[j].time/1000
                end
            end
        end
    --sino, calculem el de un
    else
        stageData = AZ.personal.loadPersonalData(AZ.personal.relativeLevels .. stage .. ".json")
        for j = 1, 9 do
            --if a value is not yet set, quit
            if stageData[j].time == -1 then
                --print("***GAME SERVICE***: aborting stage time count because of level: "..stage.."-"..j)
                return nil
            else
                time = time + stageData[j].time/1000
            end
        end
    end
    return time
 end
 
--calcula el temps total que ha trigat l'usuari a pasar-se el stage o el joc (si no s'ho ha passat sencer, aborta retornant el valor que ha contat fins el moment)
--parametre stage opcional
local function calcScore(stage)
     if not active then return end
     local score = 0
     local stageData = {}
     --si hem de calcular tots els stages
     if (stage == nil) then
         for i = 1,STAGES_COUNT do
             stageData = AZ.personal.loadPersonalData(AZ.personal.relativeLevels .. i .. ".json")
             for j = 1, 9 do
                 --if a value is not yet set, return the score we have counted up untill now
                 if stageData[j].score == 0 then
                     return score
                 else
                    score = score + stageData[j].score
                 end
             end
         end
    --sino, calculem el de un
     else
         stageData = AZ.personal.loadPersonalData(AZ.personal.relativeLevels .. stage .. ".json")
         for j = 1, 9 do
             --if a value is not yet set, return the score we have counted up untill now
             if stageData[j].score == 0 then
                 return score
             else
                 score = score + stageData[j].score
             end
         end
     end
     return score
 end
 
 --function que reporta que s'ha conseguit l'emblema del nivell i stage que se li passa per parametre
local function sendScoreTime(stage)
    if not active then return end
    --les variables score i time tenen el valor del stage que li hem passat
    --sending max score del stage
    require "scoreboardContainer"
    local score = calcScore(stage)
    --print("***GAME SERVICE***: setting max score stage "..stage..", id: "..tostring(scoreboard_container[stage*2+1].gameServiceID)..", value: "..score)
    gameNetwork.request( "setHighScore", { localPlayerScore = { category = scoreboard_container[stage*2+1].gameServiceID, value = score }})
    
    --sending time del stage
    local time = calcTime(stage)
    --time es nil quan no ens hem passat tot el stage, i per tant quan no volem enviar la puntuació de temp i superusuari
    if time ~= nil then
        --print("***GAME SERVICE***: setting min time stage "..stage..", id: "..tostring(scoreboard_container[stage*2+1].gameServiceID)..", value: "..getTime(time))
        gameNetwork.request( "setHighScore", { localPlayerScore = { category = scoreboard_container[stage*2+2].gameServiceID, value = time}})
        
        --a partir d'aqui reciclem les variables score i time per que tinguin el valor del joc sencer
        --sending max score del joc
        score = calcScore(stage)
        --print("***GAME SERVICE***: setting max score global, id: "..tostring(scoreboard_container[stage*2+1].gameServiceID)..", value: "..score)
        gameNetwork.request( "setHighScore", { localPlayerScore = { category = scoreboard_container[1].gameServiceID, value = score }})
        
        --sending time del joc
        time = calcTime()
        --time es nil quan no ens hem passat tot el joc, i per tant quan no volem enviar la puntuació de temps i superusuari
        if time ~= nil then
            --print("***GAME SERVICE***: setting min time global, id: "..tostring(scoreboard_container[2].gameServiceID)..", value: "..getTime(time))
            gameNetwork.request( "setHighScore", { localPlayerScore = { category = scoreboard_container[2].gameServiceID, value = time}})
        end
    else--aixo s'executa (ALGU HA DIT SEXE!?) nomes quan estem a meitat d'un stage i volem enviar la puntuacio
        --sending max score del joc
        score = calcScore()
        --print("***GAME SERVICE***: setting max score global, id: "..tostring(scoreboard_container[stage*2+1].gameServiceID)..", value: "..score)
        gameNetwork.request( "setHighScore", { localPlayerScore = { category = scoreboard_container[1].gameServiceID, value = score }})
    end
end
 --function principal 1 del arxiu que llança les demes, envia les puntuacions guardades
function GameServicesController:sendAllToScoreboard(stage)
    if not active then return end
    
    if GameServicesController.loggedIntoGC ~= nil then
        
        sendScoreTime(stage)
        GameServicesController.retryStage = nil
        
    else
        --si no hem entrat, guardem l'stage que tenim que calcular i li demanem a l'usuari que entri. Quan ho hagi fet, tornem a enviar les puntuacions
        GameServicesController.retryStage = stage
        GameServicesController:login(system.getInfo("platformName") == "Android")
        
    end
end

local function saveAchievementsLocal()
    
    if not active then return end
    
    local myInfo = AZ.personal.loadPersonalData(AZ.personal.genericInfo)
    
    myInfo.achievements = GameServicesController.achievements
    
    AZ.personal.savePersonalData(myInfo, AZ.personal.genericInfo)
end

local function loadAchievementsLocal()
    
    if not active then return end
    local myInfo = AZ.personal.loadPersonalData(AZ.personal.genericInfo)
    
    GameServicesController.achievements = myInfo.achievements
end

 --function principal 2 del arxiu que envia el emblema que s'ha aconseguit
function GameServicesController:sendAchievement(emblem, percent)
if not active then return end

    if GameServicesController.loggedIntoGC ~= nil then
        if (system.getInfo("platformName") == "Android") and percent ~= 100 then
            print("***GAME SERVICE***: got a new achievement, id: "..tostring(emblem_container[emblem].gameServiceID)..", percent: "..percent.." but we couldnt unpload it to the gpgs because corona didint implement incremental achievements yet")
        else

            --completem l'achievement
            --print("***GAME SERVICE***: got a new achievement, id: "..tostring(emblem_container[emblem].gameServiceID)..", percent: "..percent)
            gameNetwork.request("unlockAchievement",{achievement = {identifier=emblem_container[emblem].gameServiceID, percentComplete=percent, showsCompletionBanner= (not GameServicesController.achievements[emblem]) }})

            --guardem de forma local que hem completat l'achievement
            if percent == 100 and GameServicesController.achievements[emblem] == false then
                --FlurryController:logEvent("in_achievement", { achievement = emblem_container[emblem].fbName })

                GameServicesController.achievements[emblem] = true
                saveAchievementsLocal()
            end
            GameServicesController.retryEmblem = nil
        end
        
    else
        --si no hem entrat, guardem l'stage que tenim que calcular i li demanem a l'usuari que entri. Quan ho hagi fet, tornem a enviar les puntuacions
        GameServicesController.retryEmblem = emblem
        GameServicesController:login(system.getInfo("platformName") == "Android")
        
    end
end

--event que es llança quan l'usuari ha acabat l'inici de sessio
function loginListener(event)
    
    if not active then return end
    
    if event ~= nil then
        --print("***GAME SERVICE***: global listener "..AZ.json.encode(event))
        if event.isError == true then
            --print("***GAME SERVICE***: global listener "..tostring(event.isError))
            if event.errorMessage ~= nil then
                print("***GAME SERVICE***: No hem fet login al game center/service correctament. "..event.errorMessage)
            end
        else
            --print("Hem fet login al game center/service correctament.")
            GameServicesController.loggedIntoGC = true
            --loadAchievementsLocal()
            if GameServicesController.retryStage ~= nil then
                GameServicesController:sendAllToScoreboard(GameServicesController.retryStage)
            end
            if GameServicesController.retryEmblem ~= nil then
                GameServicesController:sendAchievement(GameServicesController.retryEmblem)
            end
            if GameServicesController.retryShow ~= nil then
                GameServicesController:show(GameServicesController.retryShow)
            end
        end
    end
end

function androidLoginListener()
    
    if not active then return end
    
    --print("***GAME SERVICE***: android listener")
    GameServicesController.loggedIntoGC = true    
    gameNetwork.request( "login", { userInitiated=true, listener=loginListener } )
end

function GameServicesController:show(options)
    if not active then return end
    
    --print("***GAME SERVICE***: show "..tostring(GameServicesController.loggedIntoGC))
    if GameServicesController.loggedIntoGC ~= nil then
        gameNetwork.show( options )
        GameServicesController.retryShow = nil
    else
        GameServicesController.retryShow = options
        GameServicesController:login(system.getInfo("platformName") == "Android")
    end
end

function GameServicesController:reset()
    if not active then return end
    
    if GameServicesController.loggedIntoGC ~= nil then
        gameNetwork.request("resetAchievements")
    end
end

-- function que inicia sessio
-- comprovem si isAndroid es true perque si ho es, despres del gameNetwork.init s'ha de fer un gameNetwork.request("login", ...
-- iOs ho fa automaticament
function GameServicesController:login(isAndroid)
    
    if not active then return end
    
    if GameServicesController.loggedIntoGC == nil then
        --print("***GAME SERVICE***: login "..tostring(isAndroid))
        if isAndroid then
            gameNetwork.init( GameServicesController.gameServiceName, androidLoginListener )
        else
            gameNetwork.init( GameServicesController.gameServiceName, loginListener )
        end
        
        if(gameNetwork==nil) then
            print("Google Play Game Services or Apple Game Center module error. Check Corona SDK compiler version")
        end
    end
end

function GameServicesController:initialize()
    if not active then return end
    
    local gameNetwork = require "gameNetwork"
    GameServicesController.loggedIntoGC = nil
    --saveAchievementsLocal()
    loadAchievementsLocal()
    
    --print("***GAME SERVICE***: initialize "..tostring(GameServicesController.loggedIntoGC))
    if (system.getInfo("platformName") == "Android") then
        GameServicesController.gameServiceName = "google"
        GameServicesController:login(true)
    else
        GameServicesController.gameServiceName = "gamecenter"
        GameServicesController:login(false)
    end
end
