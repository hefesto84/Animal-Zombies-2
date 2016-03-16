module(..., package.seeall)

local whereHasBeenRated = ""

--rate us variables
RATE_US_IOSAPPID = "123456789a"
RATE_US_NOOKAPPEAN = "123456789a"
RATE_US_ANDROID_STORE = { "google" }--{ "amazon", "google", "nook", "samsung" } es recomana que cada build del projecte per cada store siguin separades i escollim la opcio adecuada, per tant hauriem de escollir només una opcio. Hi han casos d'apps a les que els han denegat la pujada a l'store perque poden redireccionar equivocadament a un altra store i no volem aquest tipus enviar usuaris a la competencia ]]

--l'usuari esta dins del rang de temps (3 dies = 3 * 24 * 60 * 60 = 259200)?
local function checkRateUsDate()

    local margeDeTemps = 259200
    if (os.time() - AZ.userInfo.lastRateUsRequestDate > margeDeTemps) then
        return true
    end
    return false
    
end

--ens han valorat?
local function checkRatedUs()
    return AZ.userInfo.rated
end

--quan hem preguntat, guarda el dia en el que estem (en segons) 
local function updateRateUsRequestDate()

    AZ.userInfo.lastRateUsRequestDate = os.time()
    AZ:saveData()
   -- AZ.personal.savePersonalData(AZ.userInfo, AZ.personal.AZ.userInfo)
    
end

--hem estat valorats, per tant guardem la informacio per no tornar a preguntar
local function WeHaveBeenRated()

    AZ.userInfo.rated = true
    AZ:saveData()
   
end

local function calculateDays() 
    local days = math.floor((os.time() - AZ.userInfo.day) /86400)
    return days
end

--function que comprova quin boto de la finestra nativa ha presionat l'usuari
function onComplete( event )
    if "clicked" == event.action then
        --valorar la aplicacio
        if event.index == 1 then
            
            --FlurryController:logEvent("rated_game_in_".. whereHasBeenRated, { days = calculateDays() })

            WeHaveBeenRated()
            --itunes: "itms-apps://itunes.apple.com/app/pages/id"..idQueAssignaApple.."?mt=8&uo=4" es pot aconseguir mitjançant http://itunes.apple.com/linkmaker si cal quan estigui pujat a la app store
            --google play: "market://details?id="..nom del paquet
            if system.getInfo("platformName") == "Android" then
                system.openURL( "market://details?id=com.thousandgears.animalzombies" )
            else
                system.openURL( "itms-apps://itunes.apple.com/app/pages/id674450957?mt=8&uo=4" )
            end
                
        --recordar mes tard
        elseif event.index == 2 then
            --FlurryController:logEvent("in_rate_game", { answer = "later" })

            updateRateUsRequestDate()
        else
            --FlurryController:logEvent("in_rate_game", { answer = "no" })

            WeHaveBeenRated()
        end
    end
end

--function que mostra el missatge de valorar l'aplicació.
--force = ha de forçar el missatge encara que el jugador encara no hagi probat el joc el minim de dies (ideat per quan acaba un stage)
function rateUs(force, where)
    
    whereHasBeenRated = where
    
    if checkRatedUs() == false then
        if force == true or checkRateUsDate() == true then
            local loc, lang = AZ.translations.translations, AZ.currentLanguage
            native.showAlert(loc["rate_app"][lang], loc["rate_app_details"][lang], { loc["yes"][lang], loc["remind_later"][lang], loc["cancel"][lang] }, onComplete )
        end
    end
end 