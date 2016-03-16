
local Gamedonia = {}
Gamedonia.isUserLogged = false
Gamedonia.isUserSetted = false
Gamedonia.isBankSetted = false

-- variable on guardarem el plugin de Gamedonia
local plugin = nil

-- API Key de Gamedonia
-- producció:   7f7f4dbd-8737-4f89-aabf-a0fe8bcb6be5
-- development: 67636db3-f97c-4774-8a0f-c28795fcda79
local Gamedonia_APIKEY       = "67636db3-f97c-4774-8a0f-c28795fcda79"

-- el Game Secret únic per a cada app donada d'alta en Gamedonia
local Gamedonia_SECRET       = "9102776193b9a629a0c411176326ca70"

-- URL del server que utilitzem per a linkar-nos a Gamedonia
local Gamedonia_APISERVERURL = "http://api.gamedonia.com"

-- versión de l'API
local Gamedonia_APIVERSION   = "v1"

-- usuari que utilitzarems per al login amb Gamedonia
local GamedoniaUser          = nil

-- número de json recuperats
local GamedoniaFilesRetrieved = 0

-- array amb els json que descarregarem a l'inici de cada execució
local GamedoniaFilesArray = {
	"Bank_DATA",
	"Shop_DATA",
	"Slot_DATA",
	"Localization_DATA",
	"Stage1_DATA",
	"Stage2_DATA",
	"Stage3_DATA",
	"Stage4_DATA",
	"Tips_DATA"
}

-- múmero de jsons dins l'array
local GamedoniaFiles = #GamedoniaFilesArray

-- temps per a donar timeouts
local requestTimeOutSeconds = 5
local loginTimeOutSeconds = 10

-- el user tenia configuració?
local hadConfig = true

-- identificador únic que utilitzarem per a generar l'usuari i per a recuperar la seva configuració
local uid = nil

-- booleana que es posa a false quan dona algun timeOut
local initConnection = not AZ.isOfflineMode and system.getInfo("platformName") ~= "Win"
local hasConnection = initConnection

-- variable debug per a printar informació
local isDebug = false


local function debugLog(...)
    if isDebug then
        print(...)
    end
end

-- l'usuari ja s'ha loggejat i setejat
local function userLogged()
    
    Gamedonia.isUserSetted = true
    Runtime:dispatchEvent({ name = GAMEDONIA_JUST_SETTED_EVNAME })
    
	AZ.userInfo.device = tostring(system.getInfo("model")) .." ".. tostring(system.getInfo("name"))
	
	print("", "user logged saveData")
    AZ:saveData()
	
	-- actualitzem el recovery de les vides
	AZ.recoveryController:updateRecoveryStatus()
	
    -- una vegada hem acabat el procés, tornem a setejar la connexió per a un nou intent
    hasConnection = initConnection
end

-- funció per a setejar l'usuari si no teniem configuració local
local function setInitialConfig(data)
    
    AZ.userInfo = data
    
    if not hadConfig then
        AZ.userInfo.userId = uid
        AZ.userInfo.language = AZ.utils.getInitLanguage()
    else
        local function tryToRestore(canRestore)
            if canRestore then
                debugLog("", "previous purchases restored")
                plugin.Store.restore()
            else
                native.showAlert("CONNECTION ERROR", "Couldn't restore your previous purchases", {"OK"})
            end
        end
        
        Gamedonia:doStoreAction(tryToRestore)
    end
        
    userLogged()
end

-- funció per a obtenir la configuració de l'usuari
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
                    -- no tenim configuració a Gamedonia, demanem el default
                    debugLog("", "There's no previous user data, requesting DefaultUser_DATA")
                    
                    timeoutFunc = defaultUserTimeoutFunc
                    timeoutTimerID = timer.performWithDelay(requestTimeOutSeconds *1000, timeoutFunc)
                    
                    requestedFile = "DefaultUser_DATA"
                    plugin.Data.search(requestedFile, "{}", callback, requestTimeOutSeconds)
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
            plugin.Data.search(requestedFile, "{ 'userId': '".. uid .."' }", callback, requestTimeOutSeconds)
        else
            timeoutFunc()
        end
    else
        debugLog("", "we've local info")
        userLogged()
    end
end

-- funció disparada quan ja hem estat loggejats inicialment [o no]
local function onGetMe(success, msg)
    if not success then
        print("", "onGetMe failed", msg)
        hasConnection = false 
    end
	
	getUserConfig()

end

-- función per a la creació d'un usuari vàlid per al login de Gamedonia
local function prepareUser() 
    -- creems un usuari mitançant el GamedoniaTypes
    local user = plugin.Types.user
    
    -- agafem el deviceId
    uid = plugin.Devices.device.deviceId
    
    -- creems un mail associat al deviceId per tal de fer un login silenciós
    user.credentials.type = {"mail"}
    user.credentials.open_udid  = uid
    user.credentials.email      = uid .."@".. uid ..".com"
    user.credentials.password   = uid
    user.profile.nickname       = uid
    user.profile.registerDate   = os.date()
    
    -- retornem lusuari creat
    return user
end

local function setUser(userType, userValue)
	-- creems un usuari mitançant el GamedoniaTypes
    local user = plugin.Types.user
    
    -- agafem el deviceId
    uid = plugin.Devices.device.deviceId
    
	userValue = userValue or uid
	
    -- creems un mail associat al deviceId per tal de fer un login silenciós
    user.credentials.type = {"mail"}
    user.credentials.open_udid  = uid
    user.credentials.email      = userValue .."@".. userValue ..".com"
    user.credentials.password   = userValue
    user.profile.nickname       = userType
    user.profile.registerDate   = os.date()
    
    -- retornem lusuari creat
    return user
end

-- funció per a loggejar l'usuari que tenim
function Gamedonia:login(callback)
    
    local loginTimerID = nil
    
    local function loginTimeOutFunc(msg)
        print("login timeOut")
        
        loginTimerID = timer.safeCancel(loginTimerID)
        
        hasConnection = false
        Gamedonia.isUserLogged = false
        
        if not type(msg) == "string" then
          msg = "Request timeout"
        end
        
        callback(false, msg)
    end
    
	local function onLoginSuccessCallback(...)
		Gamedonia.isUserLogged = true
		
		plugin.Devices.register()
		
		callback(...)
	end
	
    local onLogin = function(success)
        
        loginTimerID = timer.safeCancel(loginTimerID)
        
        -- si no ens hem pogut loggejar és perque no tenim un usuari vàlid encara
        if not success then
            print("", "login failed, user doesn't exist")
            
            loginTimerID = timer.performWithDelay(loginTimeOutSeconds *1000, loginTimeOutFunc)
            
            -- executamos el procés de creació i alta d'un usuari, passant el GamedoniaUser com a paràmetre
            plugin.User.create(GamedoniaUser, function()
                debugLog("", "user created")
                
                loginTimerID = timer.safeCancel(loginTimerID)
                loginTimerID = timer.performWithDelay(loginTimeOutSeconds *1000, loginTimeOutFunc)
                
                -- una vegada creat l'usuari en Gamedonia, ens intentem loggejar de nou
                plugin.User.loginWithOpenUDID(function(success) 
                    
                    loginTimerID = timer.safeCancel(loginTimerID)
                    
                    if success then
						-- si el login ha funcionat, ja estem vinculats amb Gamedonia
						debugLog("", "login success, new user")
						
						plugin.User.getMe(onLoginSuccessCallback, requestTimeOutSeconds)
                    else
                        -- si el login no ha funcionat, és que tot va fatal
                        print("", "login failed, new user")
                        loginTimeOutFunc("User created but failed when logging in")
                    end
                end,
                loginTimeOutSeconds
                )
            end,
            loginTimeOutSeconds
            )
        else
            debugLog("", "login success. user already exists")
            plugin.User.getMe(onLoginSuccessCallback, requestTimeOutSeconds)
        end
    end
    
    if not hasConnection then
        Gamedonia.isUserLogged = false
        callback(false, "There's no connection")
        return
    end
    
    loginTimerID = timer.performWithDelay(loginTimeOutSeconds *1000, loginTimeOutFunc)
    
    -- ens intentems loggejar amb l'usuari
    plugin.User.loginWithOpenUDID(onLogin, loginTimeOutSeconds)
end

function Gamedonia:doStoreAction(callback)
    
    local function doCallback()
        if not plugin.Store.isActive() then
			plugin.Store.init()
        end

        callback(true)
    end
    
    local function loginCallback(success, errorMsg)
        if success then
            doCallback()
        else
            native.showAlert("CONNECTION ERROR", errorMsg or "", {"OK"})
            callback(false)
        end
    end
    
    if not Gamedonia.isUserLogged then
        Gamedonia:login(loginCallback)
    else
        doCallback()
    end
end

-- funcio per a actualitzar els preus del banc
function Gamedonia:getBankData()
	
	local function loadProductsCallback(success, products, invalidProducts)
		
		Gamedonia.isBankSetted = success
		
		if success then
			
			local function findBankProduct(storeID)
				for i = 1, #AZ.bankInfo.bankShop.bank do
					if storeID == AZ.bankInfo.bankShop.bank[i].storeID then
						return i
					end
				end
			end
			
			for i = 1, #products do
				
				if products[i].productIdentifier == AZ.userInfo.recoveryStatus.refillHeartsStoreID then
					AZ.userInfo.recoveryStatus.refillHeartsPrice = products[i].localizedPrice
					
				elseif products[i].productIdentifier == AZ.userInfo.recoveryStatus.refillLollipopsStoreID then
					AZ.userInfo.recoveryStatus.refillLollipopsPrice = products[i].localizedPrice
					
				else
					local productID = findBankProduct(products[i].productIdentifier)
					AZ.bankInfo.bankShop.bank[productID].price = products[i].localizedPrice
					AZ.bankInfo.bankShop.bank[productID].isValid = true
					
					local desc = products[i].description
					local sharpPos = string.find(desc, "#")
					
					AZ.bankInfo.bankShop.bank[productID].quantity = string.sub(desc, 1, sharpPos -1)
					AZ.bankInfo.bankShop.bank[productID].itemDescription = string.sub(desc, sharpPos +1, #desc)
					
				end
			end
			
			if #invalidProducts > 0 then
				print("WARNING!\tCouldn't load these products: ".. table.concat(invalidProducts, ", "))
				
				for i = 1, #invalidProducts do
					local productID = findBankProduct(invalidProducts[i])
					AZ.bankInfo.bankShop.bank[productID].isValid = false
				end
			end
			
			AZ.jsonIO:writeFile(FILE_BANK_INFO, AZ.bankInfo)
		else
			native.showAlert("CONNECTION ERROR", "Couldn't load any bank item", {"OK"})
		end
		
		print("", "get bank data saveData")
		AZ:saveData()
	end
	
	if system.getInfo("environment") == "simulator" then
		for i = 1, #AZ.bankInfo.bankShop.bank do
			AZ.bankInfo.bankShop.bank[i].isValid = true
		end
		return
	end
	
	local products = { AZ.userInfo.recoveryStatus.refillHeartsStoreID, AZ.userInfo.recoveryStatus.refillLollipopsStoreID }
	for i = 1, #AZ.bankInfo.bankShop.bank do
		table.insert(products, AZ.bankInfo.bankShop.bank[i].storeID)
	end
	
	Gamedonia:loadProducts(products, loadProductsCallback)
end

-- el callback inclou un bool, segons si s'ha pogut carregar productes, i, en cas afirmatiu, un array de productes vàlids i un altre [opcional] d'invàlids
-- valids = { title, description, price, localizedPrice, productIdentifier }
function Gamedonia:loadProducts(products, callback)
    
    local function loadCallback(ok, ko)
        callback(true, ok, ko)
    end
    
    local function tryToLoadProducts(canLoad)
        if canLoad then
            plugin.Store.requestProducts(products, loadCallback)
        else
            native.showAlert("CONNECTION ERROR", "Couldn't load any item", {"OK"})
            callback(false)
        end
    end
	
    Gamedonia:doStoreAction(tryToLoadProducts)
end

-- el callback inclou un bool, segons si s'ha pogut produir la compra, i, en cas afirmatiu, un diccionari:
-- { productIdentifier, receipt, identifier, date }
function Gamedonia:buyProduct(productID, callback, isConsumible)
    
    local function tryToBuy(canBuy)
        if canBuy then
			
			--if type(productID) == "string" then	productID = { productID }	end
			if isConsumible == nil then			isConsumible = true		end
			
			AZ.utils.print(productID, "product id")
			
			plugin.Store.buyProducts(productID, callback, isConsumible)
        else
            native.showAlert("CONNECTION ERROR", "Couldn't purchase this item", {"OK"})
            callback(false)
        end
    end
    
    Gamedonia:doStoreAction(tryToBuy)
end

-- funcio per a resetejar el player
function Gamedonia:resetUser()
	
	local timeOutTimerId = nil
	
	local function resetData(defaultData)
		
		defaultData.music = AZ.userInfo.music
		defaultData.sound = AZ.userInfo.sound
		defaultData.vibration = AZ.userInfo.vibration
		defaultData.language = AZ.userInfo.language
		
		defaultData.rateTime = AZ.userInfo.rateTime
		defaultData.isRated = AZ.userInfo.isRated
		
		defaultData.userId = AZ.userInfo.userId
		defaultData.device = AZ.userInfo.device
		
		defaultData._id = AZ.userInfo._id
		defaultData._acl = AZ.userInfo._acl
		
		-- Descomentar aquestes linies perque es guardin les compres que havia fet l'usuari
		-- tot i ressetejar el progres.
		defaultData.weapons = AZ.userInfo.weapons
		for i = 1, #defaultData.weapons do
			if defaultData.weapons[i].name ~= SHOVEL_NAME then
				defaultData.weapons[i].isBlocked = true
			end
		end
		
		AZ.userInfo = defaultData
		
		print("", "reset user saveData")
		AZ:saveData()
	end
	
	local function timeOutFunc()
        timeOutTimerId = timer.safeCancel(timeOutTimerId)
        
		debugLog("", "requesting 'DefaultUser_DATA' timeout, reading from project")
        
		local data = AZ.jsonIO:readFile("configFiles/".. FILE_USER_TEMPLATE_INFO, true)
        
		resetData(data)
    end
	
	local function response(success, data)
        
        debugLog("", "current file received: 'DefaultUser_DATA', success? ".. tostring(success))
        
        timeOutTimerId = timer.safeCancel(timeOutTimerId)
        
        if success then
            resetData(data[1])
        else
            print("", "requested '".. DefaultUser_DATA .."' failed, wait for time out")
            timeOutFunc()
        end
    end
	
	timeOutTimerId = timer.performWithDelay(requestTimeOutSeconds, timeOutFunc)
	
	plugin.Data.search("DefaultUser_DATA", "{}", response, requestTimeOutSeconds)
	
end

-- funció per a iniciar el procés de link amb Gamedonia
function Gamedonia:init()
    
    if AZ.isOfflineMode then
        AZ.utils.print(false, "Tenim connexió?")
    end
    
    -- carreguem el plugin de Gamedonia
    plugin = require "controller.gamedonia.plugin_gamedonia"
    
    -- inicialitzems l'SDK de Gamedonia
    plugin.initialize(Gamedonia_APIKEY, Gamedonia_SECRET, Gamedonia_APISERVERURL, Gamedonia_APIVERSION)
    
    -- preparems l'usuari
    GamedoniaUser = prepareUser()
    
    -- intentamos loggejar l'usuari creat
    Gamedonia:login(onGetMe)
end

-- función que retorna si encara hi ha jsons per a descarregar
local function filesRemaining()
    return GamedoniaFilesRetrieved ~= GamedoniaFiles
end

-- función per a la recuperació dels json de Gamedonia
function Gamedonia:getData()
    
    local timeOutTimerId = nil
    
	local function dispatchFileReceivedEvent()
		local remainingFiles = filesRemaining()
		
		if not remainingFiles then
			-- demanem info del banc
			Gamedonia:getBankData()
		end
		
        Runtime:dispatchEvent({ name = GAMEDONIA_DATA_RECEIVED_EVNAME, remains = remainingFiles })
	end
	
    local function timeOutFunc()
        timeOutTimerId = timer.safeCancel(timeOutTimerId)
        
        debugLog("", "requesting ".. GamedoniaFilesArray[GamedoniaFilesRetrieved] .." timeout, reading from cache")
        --hasConnection = false
        
        local function readFromLocalFile(f)
            local data = AZ.jsonIO:readFile(f, false)
            if not data then
                print("", "", "file ".. GamedoniaFilesArray[GamedoniaFilesRetrieved] .." doesn't exist, reading from project")
                data = AZ.jsonIO:readFile("configFiles/".. f, true)
                return false, data
            end
            return true, data
        end
        
        local data, isFromLocal, fileName
        
        if GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Bank_DATA" then         fileName = FILE_BANK_INFO
        elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Shop_DATA" then     fileName = FILE_SHOP_INFO
        elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Slot_DATA" then     fileName = FILE_SLOT_INFO
        elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Stage1_DATA" then   fileName = FILE_STG1_INFO
        elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Stage2_DATA" then   fileName = FILE_STG2_INFO
        elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Stage3_DATA" then   fileName = FILE_STG3_INFO
        elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Stage4_DATA" then   fileName = FILE_STG4_INFO
		elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Localization_DATA" then fileName = FILE_LOCALIZATION_INFO 
		elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Tips_DATA" then		fileName = FILE_TIPS_INFO end
        
        isFromLocal, data = readFromLocalFile(fileName)
        
        if not isFromLocal then
            AZ.jsonIO:writeFile(fileName, data)
        end
        
        if GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Bank_DATA" then         AZ.bankInfo = data
        elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Shop_DATA" then     AZ.shopInfo = data
        elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Slot_DATA" then     AZ.slotInfo = data
        elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Stage1_DATA" then   AZ.gameInfo[1] = data
        elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Stage2_DATA" then   AZ.gameInfo[2] = data
        elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Stage3_DATA" then   AZ.gameInfo[3] = data
        elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Stage4_DATA" then   AZ.gameInfo[4] = data 
		elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Localization_DATA" then AZ.localization = data 
		elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Tips_DATA" then 		AZ.tipsInfo = data end
        
        -- cada vegada que processem un fitxer, llencem un event que thousandgears.lua capturarà
		dispatchFileReceivedEvent()
    end
    
    local function response(success, data)
        
        debugLog("", "current file received: ".. GamedoniaFilesArray[GamedoniaFilesRetrieved] ..", success? ".. tostring(success))
        
        timeOutTimerId = timer.safeCancel(timeOutTimerId)
        
        if success then
            
            -- IMPORTANT
            -- tots els jsons han de recuperar-se a partir de l'entrada 1. Ex: data[1]
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
			elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Localization_DATA" then
				AZ.localization = data[1]
				AZ.jsonIO:writeFile(FILE_LOCALIZATION_INFO, data[1])
			elseif GamedoniaFilesArray[GamedoniaFilesRetrieved] == "Tips_DATA" then
				AZ.tipsInfo = data[1]
				AZ.jsonIO:writeFile(FILE_TIPS_INFO, data[1])
            end
            
            -- cada vegada que processem un fitxer, llencem un event que thousandgears.lua capturarà
            dispatchFileReceivedEvent()
        else
            print("", "requested ".. tostring(GamedoniaFilesArray[GamedoniaFilesRetrieved]) .." failed, wait for time out")
            timeOutFunc()
        end
    end
    
    -- comptador amb els fitxers de gamedonia que queden per obtenir
    GamedoniaFilesRetrieved = GamedoniaFilesRetrieved + 1
    
    if not hasConnection then
        timeOutFunc()
    else
        timeOutTimerId = timer.performWithDelay(requestTimeOutSeconds *1000, timeOutFunc)

        -- anem recuperant les dades, procedents de les col·lecions de dades de gamedonia
        if GamedoniaFilesArray[GamedoniaFilesRetrieved] == "UserConfig_DATA" then
            plugin.Data.search("UserConfig_DATA", "{ 'userId': '".. uid .."' }", response, requestTimeOutSeconds)
        else
            plugin.Data.search(GamedoniaFilesArray[GamedoniaFilesRetrieved], "{}", response, requestTimeOutSeconds)
        end
    end
end

-- funció que actualitza les dades de configuració i partida de l'usuari
function Gamedonia:updateUserData()
    
    if not hasConnection then
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
        plugin.Data.create("UserConfig_DATA", AZ.userInfo, updateCallback)
        hadConfig = true
    else
        plugin.Data.update("UserConfig_DATA", AZ.userInfo, updateCallback, true)
    end
end

return Gamedonia