GamedoniaRequest      = nil --
GamedoniaSDK          = nil -- plugin itself
GamedoniaSDKUser      = nil --
GamedoniaTypes        = nil --
GamedoniaCrypto       = nil --
GamedoniaUserDefault  = nil --
GamedoniaData         = nil --
-- devices
-- push
-- store
-- SCRIPT --

OpenUDID = require "controller.gamedonia.openudid"--"plugin.openudid" -----

local Gamedonia = {}
Gamedonia.isLogged = false

local Gamedonia_TAG          = "[GAMEDONIA] - "

-- La API Key de Gamedonia. Deberá modificarse por 7f7f4dbd-8737-4f89-aabf-a0fe8bcb6be5 cuando
-- queramos pasar la aplicación a producción. Con 67636db3-f97c-4774-8a0f-c28795fcda79, la tenemos
-- en modo development.

local Gamedonia_APIKEY       = "67636db3-f97c-4774-8a0f-c28795fcda79"

-- El Game Secret único para cada aplicación dada de alta en Gamedonia
local Gamedonia_SECRET       = "9102776193b9a629a0c411176326ca70"

-- La URL del servidor que usamos para linkarnos a Gamedonia
local Gamedonia_APISERVERURL = "http://api.gamedonia.com"

-- La versión de la API. En este caso, V1
local Gamedonia_APIVERSION   = "v1"

local GamedoniaStatus        = {}

-- Este es el usuario que usaremos para el login con Gamedonia
local GamedoniaUser          = nil

-- Número de ficheros que se han recuperado
local GamedoniaFilesRetrieved = 0

-- Array con los ficheros que vamos a descargar
local GamedoniaFilesArray = {
    --"DefaultUser_DATA",
    --"UserConfig_DATA",
    "Shop_DATA",
    "Bank_DATA",
    "Slot_DATA",
    "Stage1_DATA",
    "Stage2_DATA",
    "Stage3_DATA",
    "Stage4_DATA"
}

-- Número de ficheros que hay en el array
local GamedoniaFiles = #GamedoniaFilesArray

-- temps per a donar timeouts
local requestTimeOutSeconds = 5
local loginTimeOutSeconds = 10

-- par saber si teniem configuració d'usuari al server
local hadConfig = true

-- identificador únic que utilitzarem per a generar l'usuari i per a recuperar la seva configuració
local uid = nil

local forcedConnectionStatus = true
if not forcedConnectionStatus then
    print("\n", "", "", "NO TENIM CONNEXIÓ\n")
end

-- booleana que es posa a false quan dona algun timeOut
local hasConnection = forcedConnectionStatus and system.getInfo("platformName") ~= "Win"

local isDebug = false


local function debugLog(...)
    if isDebug then
        print(...)
    end
end

local function userLogged()
    Gamedonia.isLogged = true
    Runtime:dispatchEvent({ name = GAMEDONIA_JUST_SETTED_EVNAME })
    
    AZ:saveData()
end

local function setInitialConfig(data)
    
    AZ.userInfo = data
    
    if not hadConfig then
        AZ.userInfo.userId = uid
        AZ.userInfo.language = AZ.utils.getInitLanguage()
    else
        AZ.jsonIO:writeFile(FILE_USER_INFO, AZ.userInfo)
    end
        
    userLogged()
end

local function getUserConfig()
    AZ.userInfo = AZ.jsonIO:readFile(FILE_USER_INFO, false)
    
    -- no tenim configuració local, mirarem en gamedonia si tenim una
    -- si no, intentarem agafar un usuari default de gamedonia i, a les males, el treurem del project
    if not AZ.userInfo then
        debugLog("", "we don't have local info, requesting gamedonia's")
        
        local timeoutTimerID = nil
        local timeoutFunc = nil
        local requestedFile = ""
        
        local function defaultUserTimeoutFunc()
            timeoutTimerID = timer.safeCancel(timeoutTimerID)
            debugLog("", "requesting 'DefaultUser_DATA' timeout, reading from project")
            
            hasConnection = false
            
            local defaultUser = AZ.jsonIO:readFile("configFiles/user-template.json", true)
            hadConfig = false
            setInitialConfig(defaultUser)
        end
        
        local function userTimeoutFunc()
            timeoutTimerID = timer.safeCancel(timeoutTimerID)
            debugLog("", "requesting 'UserConfig_DATA' timeout, reading default from project")
            defaultUserTimeoutFunc()
        end
        
        local function callback(success, data)
            
            debugLog("", "current file received: ".. requestedFile ..", success? ".. tostring(success))
            
            timeoutTimerID = timer.safeCancel(timeoutTimerID)
            
            if success then
                if #data == 0 then
                    -- no tenim configuració a gamedonia, demanem el default
                    timeoutFunc = defaultUserTimeoutFunc
                    timeoutTimerID = timer.performWithDelay(requestTimeOutSeconds *1000, timeoutFunc)
                    
                    requestedFile = "DefaultUser_DATA"
                    GamedoniaData.search(requestedFile, "{}", callback, requestTimeOutSeconds)
                else
                    hadConfig = requestedFile == "UserConfig_DATA"
                    setInitialConfig(data[1])
                end
            else
                print("", "requested '".. requestedFile .."' failed, wait for time out")
                timeoutFunc()
            end
        end
        
        timeoutFunc = userTimeoutFunc
        timeoutTimerID = timer.performWithDelay(requestTimeOutSeconds *1000, timeoutFunc)
        
        requestedFile = "UserConfig_DATA"
        if hasConnection then
            GamedoniaData.search(requestedFile, "{ 'userId': '".. uid .."' }", callback, requestTimeOutSeconds)
        else
            timeoutFunc()
        end
    else
        debugLog("", "we've local info")
        userLogged()
    end
end

-- Más adelante podremos usar esta función para dar avisos personalizados
-- al usuario si lo desea.
local function onGetMe(success, profile)
    if success then
        getUserConfig()
    else
        print("", "onGetMe failed")
        hasConnection = false
        getUserConfig()
    end
end

-- Función para la creación de un usuario válido para el login de Gamedonia
local function prepareUser() 
    -- Creamos un usuario mediante GamedoniaTypes
    local user = GamedoniaTypes.user
    
    -- Generamos un identificador único por dispositivo
    uid = OpenUDID.getValue()
    
    -- Como queremos un login silencioso, creamos un mail asociado al uid anterior
    user.credentials.type = {"mail"}
    user.credentials.open_udid  = uid
    user.credentials.email      = uid .."@".. uid ..".com"
    user.credentials.password   = uid
    user.profile.nickname       = uid
    user.profile.registerDate   = os.date()
    
    -- Devolvemos el usuario que hemos creado
    return user
end

-- Función para logear al usuario que tenemos
function Gamedonia:login()
    
    local loginTimerID = nil
    
    local function loginTimeOutFunc()
        
        print("login timeOut")
        
        loginTimerID = timer.safeCancel(loginTimerID)
        
        hasConnection = false
        
        onGetMe(false, nil)
    end
    
    local onLogin = function(success)
        
        loginTimerID = timer.safeCancel(loginTimerID)
        
        -- Si no nos hemos podido logear, es porque no tenemos un usuario válido aún
        if not success then
            print("", "login failed, user doesn't exist")
            -- Ejecutamos el proceso de creación y alta de un usuario, pasándole GamedoniaUser como parámetro
            GamedoniaSDKUser.createUser(GamedoniaUser,
            function () 
                debugLog("", "user created")
                
                loginTimerID = timer.performWithDelay(loginTimeOutSeconds *1000, loginTimeOutFunc)
                
                -- Una vez hemos creado el usuario en Gamedonia, nos volvemos a intentar logear
                GamedoniaSDKUser.loginUserWithOpenUDID(
                function(success) 
                    loginTimerID = timer.safeCancel(loginTimerID)
                    
                    if success then
                        -- Si el login ha funcionado, ya estamos vinculados con Gamedonia
                        debugLog("", "login success, new user")
                        GamedoniaSDKUser.getMe(onGetMe, requestTimeOutSeconds)
                    else
                        -- Si el login no ha funcionado, es que todo va fatal
                        print("", "login failed, new user")
                        loginTimeOutFunc()
                    end
                end,
                loginTimeOutSeconds
                )
            end
            )
        else
            debugLog("", "login success. user already exists")
            GamedoniaSDKUser.getMe(onGetMe, requestTimeOutSeconds)
        end
    end
    
    if not hasConnection then
        onGetMe(false, nil)
        return
    end
    
    loginTimerID = timer.performWithDelay(loginTimeOutSeconds *1000, loginTimeOutFunc)
    
    -- Nos intenamos logear con el usuario
    GamedoniaSDKUser.loginUserWithOpenUDID(onLogin, loginTimeOutSeconds)
end

-- Función para iniciar el proceso de link con Gamedonia
function Gamedonia:init()
    
    if AZ.isOfflineMode then
        hasConnection = false
        onGetMe(true, nil)
        
        return
    end
    
    -- Cargamos los módulos necesarios de Gamedonia (el plugin nos lo han diseñado tan bien, que el orden es importante T^T)
    GamedoniaRequest        = require "controller.gamedonia.plugin_GamedoniaRequest"
    GamedoniaSDK            = require "controller.gamedonia.plugin_GamedoniaSDK"
    GamedoniaSDKUser        = require "controller.gamedonia.plugin_GamedoniaSDKUser"
    GamedoniaTypes          = require "controller.gamedonia.plugin_GamedoniaTypes"
    GamedoniaCrypto         = require "controller.gamedonia.plugin_GamedoniaCrypto"
    GamedoniaUserDefault    = require "controller.gamedonia.plugin_GamedoniaUserDefault"
    GamedoniaData           = require "controller.gamedonia.plugin_GamedoniaData"
    
    -- Inicializamos el SDK de Gamedonia
    GamedoniaSDK.initialize(Gamedonia_APIKEY, Gamedonia_SECRET, Gamedonia_APISERVERURL, Gamedonia_APIVERSION)
    
    -- Preparamos el usuario mediante OpenUDID
    GamedoniaUser = prepareUser()
    
    -- Intentamos loggear al usuario creado
    Gamedonia:login()
end

-- Función para controlar cuantos ficheros de configuración nos quedan por descargar
local function filesRemaining()
    if GamedoniaFilesRetrieved ~= GamedoniaFiles then
        return true
    else
        return false
    end
end

-- Función para la recuperación de los json de Gamedonia
function Gamedonia:getData()
    
    local timeOutTimerId = nil
    
    local function response(success, data)
        
        debugLog("", "current file received: ".. GamedoniaFilesArray[GamedoniaFilesRetrieved] ..", success? ".. tostring(success))
        
        if success then
            
            timeOutTimerId = timer.safeCancel(timeOutTimerId)
            
            -- MUY IMPORTANTE: Todos los ficheros JSON, deben ser recuperados a partir de su entrada 1. Por ejemplo: data[1], ya que Gamedonia, cuando devuelve el JSON
            -- no devuelve el mismo fichero exactamente como lo tenemos, sino que añade un nivel más de datos, creando un array de más.
            if GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Bank_DATA" then
                AZ.bankInfo = data[1]
                AZ.jsonIO:writeFile(FILE_BANK_INFO, data[1])
                
            elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Shop_DATA" then
                AZ.shopInfo = data[1]
                AZ.jsonIO:writeFile(FILE_SHOP_INFO, data[1])
                
            elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Slot_DATA" then
                AZ.slotInfo = data[1]
                AZ.jsonIO:writeFile(FILE_SLOT_INFO, data[1])
                
            elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Stage1_DATA" then
                AZ.gameInfo[1] = data[1]
                AZ.jsonIO:writeFile(FILE_STG1_INFO, data[1])
                
            elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Stage2_DATA" then
                AZ.gameInfo[2] = data[1]
                AZ.jsonIO:writeFile(FILE_STG2_INFO, data[1])
                
            elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Stage3_DATA" then
                AZ.gameInfo[3] = data[1]
                AZ.jsonIO:writeFile(FILE_STG3_INFO, data[1])
                
            elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Stage4_DATA" then
                AZ.gameInfo[4] = data[1]
                AZ.jsonIO:writeFile(FILE_STG4_INFO, data[1])
            end
            
            -- Cada vez que hemos procesado un fichero, lanzamos un evento Gamedonia, que thousandgears.lua recibe. Cuando se detecta que el campo "remains" del evento,
            -- es falso, significa que ya no hay más ficheros pendientes de descarga y por lo tanto, podemos pasar directamente al menú principal.
            Runtime:dispatchEvent({ name = GAMEDONIA_DATA_RECEIVED_EVNAME, remains = filesRemaining() })
        else
            print("", "requested ".. tostring(GamedoniaFilesArray[GamedoniaFilesRetrieved]) .." failed, wait for time out")
        end
    end 
    
    local function timeOutFunc()
        
        local data = nil
        
        debugLog("", "requesting ".. GamedoniaFilesArray[GamedoniaFilesRetrieved] .." timeout, reading from cache")
        hasConnection = false
        
        local function readFile(f)
            local data = AZ.jsonIO:readFile(f, false)
            if not data then
                print("", "", "file ".. GamedoniaFilesArray[GamedoniaFilesRetrieved] .." doesn't exist, reading from project")
                data = AZ.jsonIO:readFile("configFiles/".. f, true)
            end
            return data
        end
        
        if GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Bank_DATA" then     data = readFile(FILE_BANK_INFO) end
        if GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Shop_DATA" then     data = readFile(FILE_SHOP_INFO) end
        if GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Slot_DATA" then     data = readFile(FILE_SLOT_INFO) end
        if GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Stage1_DATA" then   data = readFile(FILE_STG1_INFO) end
        if GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Stage2_DATA" then   data = readFile(FILE_STG2_INFO) end
        if GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Stage3_DATA" then   data = readFile(FILE_STG3_INFO) end
        if GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Stage4_DATA" then   data = readFile(FILE_STG4_INFO) end
        
        response(true, { data })
    end
    
    -- contador amb els fitxers de gamedonia que queden per obtenir
    GamedoniaFilesRetrieved = GamedoniaFilesRetrieved + 1
    
    if not hasConnection then
        timeOutFunc()
    else
        timeOutTimerId = timer.performWithDelay(requestTimeOutSeconds *1000, timeOutFunc)

        -- anem recuperant les dades, procedents de les col·lecions de dades de gamedonia
        if GamedoniaFilesArray[GamedoniaFilesRetrieved] == "UserConfig_DATA" then
            GamedoniaData.search("UserConfig_DATA", "{ 'userId': '".. uid .."' }", response, requestTimeOutSeconds)
        else
            GamedoniaData.search(GamedoniaFilesArray[GamedoniaFilesRetrieved], "{}", response, requestTimeOutSeconds)
        end
    end
end

-- funció que actualitza les dades de configuració i partida de l'usuari
function Gamedonia:updateUserData()
    
    if AZ.isOfflineMode or not hasConnection then
        return
    end
    
    local function updateCallback(success, response)
        print("* config synchronized with gamedonia: ".. tostring(success) .." *")
        
        if success and not AZ.userInfo._id then
            AZ.userInfo._id = response._id
            AZ.jsonIO:writeFile(FILE_USER_INFO, AZ.userInfo)
        end
    end
    
    if AZ.userInfo._acl then
        AZ.userInfo._acl.owner = nil
    end
    
    if not hadConfig then
        AZ.userInfo._id = nil
        GamedoniaData.create("UserConfig_DATA", AZ.userInfo, updateCallback)
        hadConfig = true
    else
        GamedoniaData.update("UserConfig_DATA", AZ.userInfo, updateCallback, true)
    end
end

return Gamedonia