
---------------------
-----
-- Gamedonia SDK
-----
---------------------

local lib = {}

local Os = require "os"
local Url = require "socket.url"
local mime = require "mime"
local Json = require "json"
local store = require "store"
local crypto = require "crypto"
local Network = require "network"
    

---------------------
-----
-- Gamedonia Crypto
-----
---------------------
local Crypto = {}

local MD5_BUFFER_LENGTH = 16


Crypto.MD5 = function(input)
    local output = crypto.digest(crypto.md5, input)
    return output
end


Crypto.HMAC_SHA1 = function(text, key)
    local output = crypto.hmac(crypto.sha1, text, key)
    return output
end


Crypto.signPost = function(apiKey, secret, data, contentType, date, requestMethod, path)
    -- print("\napiKey: "..apiKey.."\nsecret: "..secret.."\ndata: "..data.."\ncontentType: "..contentType.."\ndate: "..date.."\nrequestMethod: "..requestMethod.."\npath: "..path.."\n")
    local contentMd5 = Crypto.MD5(data)
    local str = requestMethod.."\n"..contentMd5.."\n"..contentType.."\n"..date.."\n"..path
    -- print ("signPost:\n"..str)
    local calculatedSignature = Crypto.HMAC_SHA1(str, secret)
    return calculatedSignature;
end


Crypto.signGet = function(apiKey, secret, date, requestMethod, path)
    -- print("\napiKey: "..apiKey.."\nsecret: "..secret.."\ndate: "..date.."\nrequestMethod: "..requestMethod.."\npath: "..path.."\n")
    local str = requestMethod.."\n"..date.."\n"..path
    
    calculatedSignature = Crypto.HMAC_SHA1(str, secret)
    
    return calculatedSignature
end

lib.Crypto = Crypto



---------------------
-----
-- Gamedonia Devices
-----
---------------------
local Devices = {}

Devices.device = {}

Devices.deviceType = function ()
    local ret = ""
    local platName = system.getInfo("platformName")
    if platName == "iPhone OS" then
        ret = "ios"
    elseif platName == "Android" then
        ret = "android"
    else
        ret = "editor"
    end
    return ret
end

Devices.device.deviceId = system.getInfo( "deviceID" )
Devices.device.deviceType = Devices.deviceType()
Devices.device.deviceToken = nil
Devices.device.uid = nil

------------------
-- Register
------------------
local GamedoniaDevicesRegister = {}

GamedoniaDevicesRegister.listener = function ( event )
	AZ.utils.print(event, "devicesRegisterEvent")
    if ( event.isError ) then
        print ("GamedoniaDevicesRegister.listener - errror: "..event.status.."\n\t"..tostring(event.response))
    else
        print ("GamedoniaDevicesRegister.listener - event: "..event.status)
    end
end

Devices.register = function()
    local dataJson = Json.encode(Devices.device)
    -- print( "lib.Devices.register - json\n"..dataJson )
    lib.Request.post("/device/register",dataJson, nil, nil, nil, GamedoniaDevicesRegister.listener)
end


lib.Devices = Devices



---------------------
-----
-- Gamedonia Request
-----
---------------------
local Request = {}

local GD_API_KEY = "X-Gamedonia-ApiKey"
local GD_SIGNATURE = "X-Gamedonia-Signature"
local GD_SESSION_TOKEN = "X-Gamedonia-SessionToken"
local GD_AUTH = "Authorization"
local DATE_HEADER = "Date"
local GD_GAMEID = "gameid"
local REQUEST_TIMEOUT = 20


Request.getCurrentDate = function()
    local date = Os.date( "%Y-%m-%d %H:%M:%S" )
    return date
end

Request.ping = function(cb)
    Request.get("/ping", nil, nil, cb)
end


Request.get = function(url, query, sessionToken, callback, timeoutTime)
    local currentDate = Request.getCurrentDate()
    -- print("lib.getApiServerUrl() - "..lib.getApiServerUrl())
    -- print("lib.getApiVersion() - "..lib.getApiVersion())
    -- print("url - "..url)
    local urlBuf = string.format("%s/%s%s", lib.getApiServerUrl(), lib.getApiVersion(), url)
    
    if query ~= nil and query:len()>0 then
        urlBuf = urlBuf..query
    end

    local headers = {}
    headers["X-Gamedonia-ApiKey"] = lib.getApiKey()
    headers["Date"] = currentDate
    if sessionToken ~= nil and sessionToken:len() > 0 then
        headers["X-Gamedonia-SessionToken"] = sessionToken;
    end
    local path = string.format("/%s%s", lib.getApiVersion(), url)
    local hmac = lib.Crypto.signGet(lib.getApiKey(), lib.getSecret(), currentDate, "GET", path)
    headers["X-Gamedonia-Signature"] = hmac

    local params = {}
    params.headers = headers
    params.timeout = timeoutTime or 20

    -- print("urlBuf: "..urlBuf)
    -- print("path: "..path)
    -- print ("lib.Request.get - params.headers:")
    -- printTables(params.headers)
    Network.request(urlBuf, "GET", callback, params)
end


Request.post = function(url, content, auth, sessionToken, gameid, callback, timeoutTime)
    local currentDate = Request.getCurrentDate()

    local urlBuf = string.format("%s/%s%s", lib.getApiServerUrl(), lib.getApiVersion(), url)
    -- print ("url:\n"..urlBuf)

    local params = {}
    local headers = {}

    params.timeout = timeoutTime or 20
    headers["X-Gamedonia-ApiKey"] = lib.getApiKey()
    headers["Content-Type"] = "application/json"
    headers["Date"] = currentDate

    if content ~= nil and content:len() > 0 then
        params.body = content
        local path = string.format("/%s%s", lib.getApiVersion(), url)
        local hmac = lib.Crypto.signPost(lib.getApiKey(), lib.getSecret(), content, "application/json; charset=UTF-8", currentDate, "POST", path)
        headers["X-Gamedonia-Signature"] = hmac
        -- print ("params.body:\n"..params.body)
    end

    if (auth ~= nil and auth:len() > 0) then
        headers["Authorization"] = auth
    end
    
    if (sessionToken ~= nil and sessionToken:len() > 0) then
        headers["X-Gamedonia-SessionToken"] = sessionToken
       -- print ("lib.post - X-Gamedonia-SessionToken: "..sessionToken)
    end
    
    if (gameid ~= nil and gameid:len() > 0) then
        headers["gameid"] = gameid
    end
    
    params.headers = headers

    Network.request(urlBuf, "POST", callback, params)
end


Request.put = function(url, content, auth, sessionToken, gameid, callback, timeoutTime)
    local urlBuf = string.format("%s/%s%s", lib.getApiServerUrl(), lib.getApiVersion(), url)

    local currentDate = Request.getCurrentDate()
    local params = {}
    local headers = {}

    params.timeout = timeoutTime or 20
    headers["X-Gamedonia-ApiKey"] = lib.getApiKey()
    headers["Content-Type"] = "application/json"
    headers["Date"] = currentDate

    if (auth ~= nil and auth:len() > 0) then
        headers["Authorization"] = auth
    end
    
    if (sessionToken ~= nil and sessionToken:len() > 0) then
        headers["X-Gamedonia-SessionToken"] = sessionToken
    end
    
    if (gameid ~= nil and gameid:len() > 0) then
        headers["gameid"] = gameid
    end
    
    if (content ~= nil and content:len() > 0) then
        params.body = content
        local path = string.format("/%s%s", lib.getApiVersion(), url)
        local hmac = lib.Crypto.signPost(lib.getApiKey(), lib.getSecret(), content, "application/json; charset=UTF-8", currentDate, "PUT", path)
        headers["X-Gamedonia-Signature"] = hmac
    end

    params.headers = headers

   -- print ("url:\n"..urlBuf)
   -- print ("params.body:\n"..params.body)
    Network.request(urlBuf, "PUT", callback, params)
end


Request.delete = function(url, callback, timeoutTime)
    local currentDate = Request.getCurrentDate()

    local urlBuf = string.format("%s/%s%s", lib.getApiServerUrl(), lib.getApiVersion(), url)

    local params = {}
    local headers = {}

    params.timeout = timeoutTime or 20
    headers["X-Gamedonia-ApiKey"] = lib.getApiKey()
    headers["Date"] = currentDate

    params.headers = headers

   -- print ("url:\n"..urlBuf)
   -- print ("params.body:\n"..params.body)
    Network.request(urlBuf, "DELETE", callback, params)
end


lib.Request = Request



---------------------
-----
-- Gamedonia push notifications
-----
---------------------
local PushNotifications = {}

PushNotifications.notifs = {}
PushNotifications.token = nil
PushNotifications.localNotificationCB = function (event)
    print( "Local notification callback is not defined." )
    -- printTable(event)
end
PushNotifications.remoteNotificationCB = function (notification)
    print( "Remote notification callback is not defined." )
    -- printTable(notification)
end
local count = 0


------------------
-- Notification listener
------------------
PushNotifications.notificationListener = function(event)
    -- print( "lib.PushNotifications.notificationListener - event.type: "..tostring(event.type))
    -- printTable(event)
    if event.type == "remote" then
        local notification = {}
        notification.message = event.alert
        notification.payload = {event.alert, event.badge, event.sound, event.custom}
        PushNotifications.remoteNotificationCB(notification)
    elseif event.type == "remoteRegistration" then
        PushNotifications.token = event.token
        lib.Devices.device.deviceToken = PushNotifications.token
        -- lib.Devices.register()
    elseif event.type == "local" then
        PushNotifications.localNotificationCB(event)
    end
end

Runtime:addEventListener( "notification", PushNotifications.notificationListener )

lib.PushNotifications = PushNotifications



---------------------
-----
-- Gamedonia Script
-----
---------------------
local Script = {}

local GamedoniaScriptRun = {}

GamedoniaScriptRun.listener = function(event)
    -- print("GamedoniaScriptRun - status: "..event.status)
    if ( event.isError ) then
        GamedoniaScriptRun.onRequestFail(event)
    else
        GamedoniaScriptRun.onRequestCompleted(event)
    end
end

GamedoniaScriptRun.onRequestCompleted = function(event)
    -- print("GamedoniaScriptRun.onRequestCompleted - status: "..event.status)
    local data = Json.decode(event.response)
    GamedoniaScriptRun.callback(event.status == 200, data)
end

GamedoniaScriptRun.onRequestFailed = function(event, data)
    -- print ("GamedoniaScriptRun.onRequestFailed")
    GamedoniaScriptRun.callback(false, data)
end

Script.run = function(script, parameters, callback)
    local dataJson = Json.encode(parameters)
    GamedoniaScriptRun.callback = callback
    lib.Request.post("/run/" .. script, dataJson, nil, lib.User.sessionToken, nil, GamedoniaScriptRun.listener)
end

lib.Script = Script



---------------------
-----
-- Gamedonia Store
-----
---------------------
local Store = {}
local transaction = nil
Store.storeIn = "apple"
if store.target == "google" then
    store = require("plugin.google.iap.v3")
	Store.storeIn = "google"
end

local function hexToString( str )
    str = str:sub(2, -2)
    str = str:gsub("%s+", "")
    local ret = ""
    for i = 1, #str, 2 do
        ret = ret..string.char( tonumber(str:sub(i, i+1), 16) )
    end
    return ret
end

------------------
-- Callbacks
------------------
local callbacks = {}

callbacks.listener = function (event)
    print( "GamedoniaStore.callbakcs.listener" )
	
	AZ.utils.print(event, "gamedoniaEvent")
	
    transaction = event.transaction
    local msg = transaction.state
    -- print ("GamedoniaStore.callbakcs.listener - state: "..transaction.state)
    -- printTable (transaction)
	if transaction.state == "cancelled" or transaction.state == "failed" then
		
		print("cancelled o failed")
		
		callbacks.userCB(false)
		
	elseif transaction.state == "consumed" then
		
		print("hem consumit")
		
	
    elseif transaction.state == "purchased" then
        -- If store.purchase() was successful, you should end up in here for each product you buy.
        -- print("Transaction succuessful!")
        -- printTable(event)
		
		print("hem comprat")
		
        if Store.storeIn == "apple" then
            local parameters = {}
            parameters.deviceId = lib.Devices.device.deviceId
            local hs = hexToString(transaction.receipt)
            parameters.receipt = mime.b64(hs)
            Store.verify(parameters)
        else
			store.consumePurchase(transaction.productIdentifier)
			
			callbacks.userCB(true, transaction)
        end
    -- elseif transaction.state == "restored" then
        -- print("Transaction restored (from previous session)")
        --[[ print("productIdentifier", transaction.productIdentifier)
        print("receipt", transaction.receipt)
        print("transactionIdentifier", transaction.identifier)
        print("date", transaction.date)
        print("originalReceipt", transaction.originalReceipt)
        print("originalTransactionIdentifier", transaction.originalIdentifier)
        print("originalDate", transaction.originalDate) --]]
    -- elseif transaction.state == "cancelled" then
        -- print("User cancelled transaction")
    -- elseif transaction.state == "failed" then
        -- print("Transaction failed, type:", transaction.errorType, transaction.errorString)
    -- else
        -- print("unknown event")
    end

    -- Once we are done with a transaction, call this to tell the store
    -- we are done with the transaction.
    -- If you are providing downloadable content, wait to call this until
    -- after the download completes.
	
	print("finish transaction")
	
    store.finishTransaction(transaction)
    -- print("Finished transaction.")
end

callbacks.requestProducts = function (event)
    -- print ("GamedoniaStore.callbacks.requestProducts")
    --[[print("showing valid products", #event.products)
    for i=1, #event.products do
        print(event.products[i].title)    -- This is a string.
        print(event.products[i].description)    -- This is a string.
        print(event.products[i].price)    -- This is a number.
        print(event.products[i].localizedPrice)    -- This is a string.
        print(event.products[i].productIdentifier)    -- This is a string.
    end

    print("showing invalidProducts", #event.invalidProducts)
    for i=1, #event.invalidProducts do
        print(event.invalidProducts[i])
    end--]]
    if callbacks.userRequestCB then
        callbacks.userRequestCB(event.products, event.invalidProducts)
    end
end

callbacks.verifyListener = function (event)
    -- print("Gamedonia.store.verifyListener")
    if ( event.isError ) then
        print("\tGamedoniaStore.verifyListener - Error.")
    else
        print("\tGamedoniaStore.verifyListener - status: "..event.status.."\n"..event.response)
    end
    if callbacks.userCB then
		callbacks.userCB(event.status == 200, transaction)
    end
end

------------------
-- Init
------------------
Store.init = function()
    print("Gamedonia.init")
    -- if not store.canMakePurchases or not store.canLoadProducts then
        store.init(Store.storeIn, callbacks.listener)
    -- else
        -- print("GamedoniaStore.init - Error")
    -- end
end

------------------
-- Is Active -- gerard
------------------
Store.isActive = function()
    return store.isActive
end

------------------
-- Can make payments
------------------
Store.canMakePayments = function()
    print( "Gamedonia.store.canMakePayments" )
    return store.canMakePurchases
end

------------------
-- Request products
------------------
Store.requestProducts = function(listOfProducts, callback)
    print ("Gamedonia.store.requestProducts")
    callbacks.userRequestCB = callback
    if store.canLoadProducts then
        --[[ print("list of products")
        printTable(listOfProducts) --]]
        store.loadProducts(listOfProducts, callbacks.requestProducts)
    else
        print ("GamedoniaStore.requestProducts - Error")
    end
end

------------------
-- Buy product
------------------
Store.buyProducts = function(listOfProducts, callback, consume)
    print ("Gamedonia.store.buyProducts")
    callbacks.userCB = callback
    -- print( "1" )
    -- print( "#listOfProducts = "..#listOfProducts )
    -- printTable(listOfProducts)
    -- lib.init()
    --[[if Store.storeIn == "google" and consume then
        store.consumePurchase("bank_00_coins") --listOfProducts)
    else]]
		
		if Store.storeIn == "apple" and type(listOfProducts) == "string" then
			listOfProducts = { listOfProducts }
		end
		
        store.purchase(listOfProducts)
    --end
    -- print( "2" )
end

------------------
-- Restore
------------------
Store.restore = function()
    print ("Gamedonia.store.requestProducts")
    -- lib.init()
    store.restore()
end

------------------
-- Verify
------------------
Store.verify = function(parameters)
    print ("Gamedonia.store.verify")
    local dataJson = Json.encode(parameters)
	
    -- print( "GamedoniaStore.verify")
    -- printTable(parameters)
    -- print ("dataJson:\n"..dataJson)
    lib.Request.post("/purchase/verify", dataJson, nil, lib.User.sessionToken, nil, callbacks.verifyListener)
end

Store.init()

lib.Store = Store



---------------------
-----
-- Gamedonia Types
-----
---------------------
local Types = {}

Types.user = {}
Types.user.credentials = {}
Types.user.credentials.type = nil
Types.user.credentials.space = "default"
Types.user.credentials.email = nil
Types.user.credentials.password = nil
Types.user.credentials.fb_access_token = nil
Types.user.credentials.fb_uid = nil
Types.user.credentials.tw_token_secret = nil
Types.user.credentials.tw_token = nil
Types.user.credentials.tw_uid = nil
Types.user.credentials.openUDID = nil
Types.user.profile = {}


lib.Types = Types



---------------------
-----
-- Gamedonia Data
-----
---------------------
local Data = {}

------------------
-- Create
------------------
local GamedoniaDataCreate = {}

GamedoniaDataCreate.listener = function(event)
    -- print("GamedoniaDataCreate - status: "..event.status)
    if ( event.isError ) then
        GamedoniaDataCreate.onRequestFail(event)
    else
        GamedoniaDataCreate.onRequestCompleted(event)
    end
end

GamedoniaDataCreate.onRequestCompleted = function(event)
    -- print("GamedoniaDataCreate.onRequestCompleted - status: "..event.status)
    if (event.status == 200) then
        GamedoniaDataCreate.target(true, Json.decode(event.response))
    else
        GamedoniaDataCreate.target(false)
    end
end

GamedoniaDataCreate.onRequestFailed = function(event)
    -- print ("GamedoniaDataCreate.onRequestFailed")
    GamedoniaDataCreate.target(false)
end

Data.create = function(collection, entity, callback)
    GamedoniaDataCreate.target = callback
    local dataJson = Json.encode(entity)
    local path = "/data/"..collection.."/create"
    -- print ("GamedoniaData.Create:\n\turl: "..path.."\n\tjson: "..dataJson)
    lib.Request.post(path, dataJson, nil, lib.User.sessionToken, nil, GamedoniaDataCreate.listener)
end


------------------
-- Delete
------------------
local GamedoniaDataDelete = {}

GamedoniaDataDelete.listener = function(event)
    -- print("GamedoniaDataDelete - status: "..event.status)
    if ( event.isError ) then
        GamedoniaDataDelete.onRequestFail(event)
    else
        GamedoniaDataDelete.onRequestCompleted(event)
    end
end

GamedoniaDataDelete.onRequestCompleted = function(event)
    if (event.status == 200) then
        GamedoniaDataDelete.callback(true)
    else
        GamedoniaDataDelete.callback(false)
    end
end

GamedoniaDataDelete.onRequestFailed = function(event)
    GamedoniaDataDelete.callback(false)
end

Data.delete = function(collection, entityId, callback)
    GamedoniaDataDelete.callback = callback
    local path = "/data/"..collection.."/delete/"..entityId
    lib.Request.delete(path, GamedoniaDataDelete.listener)
end


------------------
-- Update
------------------
local GamedoniaDataUpdate = {}

GamedoniaDataUpdate.listener = function(event)
    -- print("GamedoniaDataUpdate - status: "..event.status)
    if ( event.isError ) then
        GamedoniaDataUpdate.onRequestFail(event)
    else
        GamedoniaDataUpdate.onRequestCompleted(event)
    end
end

GamedoniaDataUpdate.onRequestCompleted = function(event)
    if (event.status == 200) then
        GamedoniaDataUpdate.target(true, Json.decode(event.response))
    else
        GamedoniaDataUpdate.target(false)
    end
end

GamedoniaDataUpdate.onRequestFailed = function(event)
    GamedoniaDataUpdate.target(false)
end

Data.update = function(collection, entity, callback, overwrite)
    if not overwrite then
        overwrite = false
    end
    GamedoniaDataUpdate.target = callback
    local dataJson = Json.encode(entity)
    local path = "/data/"..collection.."/update"
    if overwrite then
        lib.Request.put(path, dataJson, nil, lib.User.sessionToken, nil, GamedoniaDataUpdate.listener)
    else
        lib.Request.post(path, dataJson, nil, lib.User.sessionToken, nil, GamedoniaDataUpdate.listener)
    end
end


------------------
-- Search
------------------
local GamedoniaDataSearch = {}

GamedoniaDataSearch.listener = function(event)
    -- print("GamedoniaDataSearch - status: "..event.status)
    if ( event.isError ) then
        GamedoniaDataSearch.onRequestFail(event)
    else
        GamedoniaDataSearch.onRequestCompleted(event)
    end
end

GamedoniaDataSearch.onRequestCompleted = function(event)
    -- print ("GamedoniaDataSearch.onRequestCompleted - event.response: "..event.response)
    if (event.status == 200) then
        GamedoniaDataSearch.target(true, Json.decode(event.response))
    else
        GamedoniaDataSearch.target(false)
    end
end

GamedoniaDataSearch.onRequestFailed = function(event)
    GamedoniaDataSearch.target(false)
end

Data.search = function(collection, query, callback, limit, sort, skip, timeoutTime)
    GamedoniaDataSearch.target = callback
    if not limit then
        limit = 0
    end
    if not skip then
        skip = 0
    end
    local path = "/data/"..collection.."/search"
    if query then
        query = "?query="..Url.escape(query)
        if (limit > 0) then
            query = query.."&limit="..limit
        end
        if (sort ~= null) then
            query = query.."&sort="..Url.escape(sort)
        end
        if (skip > 0) then
            query = query.."&skip="..skip
        end
    end
    -- print("query: "..query)
    -- print("path: "..path)
    -- GamedoniaUserDefault.debug()
    -- print("GamedoniaUser.sessionToken: "..GamedoniaUser.sessionToken)
    lib.Request.get(path, query, lib.User.sessionToken, GamedoniaDataSearch.listener, timeoutTime)
end


------------------
-- Count
------------------
local GamedoniaDataCount = {}

GamedoniaDataCount.listener = function(event)
    -- print("GamedoniaDataCount - status: "..event.status)
    if ( event.isError ) then
        GamedoniaDataCount.onRequestFail(event)
    else
        GamedoniaDataCount.onRequestCompleted(event)
    end
end

GamedoniaDataCount.onRequestCompleted = function(event)
    -- print ("GamedoniaDataCount.onRequestCompleted - event.response: "..event.response)
    if (event.status == 200) then
        -- print(event.response)
        GamedoniaDataCount.target(true, Json.decode(event.response).count)
    else
        GamedoniaDataCount.target(false)
    end
end

GamedoniaDataCount.onRequestFailed = function(event)
    GamedoniaDataCount.target(false)
end

Data.count = function(collection, query, callback)
    GamedoniaDataCount.target = callback
    local path = "/data/"..collection.."/count"
    if query then
        query = "?query="..Url.escape(query)
    end
    lib.Request.get(path, query, lib.User.sessionToken, GamedoniaDataCount.listener)
end


lib.Data = Data



---------------------
-----
-- Gamedonia User Default
-----
---------------------
local UserDefault = {}

local JSON_FILE_NAME = "gdUserDefault.json"

UserDefault.values = {}

UserDefault.loadFile = function(base)
    -- set default base dir if none specified
    if not base then 
        base = system.DocumentsDirectory 
    end

    -- create a file path for corona i/o
    local path = system.pathForFile(JSON_FILE_NAME, base)
    -- print ("Gameuserdefault.loadfile - path: "..path)
    -- will hold contents of file
    local content

    -- io.open opens a file at path. returns nil if no file found
    local file = io.open(path, "r")
    if file then
        -- print("Gamedonia.userdefault - file opened")
        -- read all contents of file into a string
        content = file:read( "*a" )
        if content ~= nil then
            UserDefault.values = Json.decode(content)
        end
        io.close(file) -- close the file after using it
        -- UserDefault.debug()
    else
        print("Gamedonia.userdefault - no file opened")
    end
end

UserDefault.saveFile = function(base)
    -- set default base dir if none specified
    if not base then 
        base = system.DocumentsDirectory 
    end

    -- create a file path for corona i/o
    local path = system.pathForFile(JSON_FILE_NAME, base)

    -- io.open opens a file at path. returns nil if no file found
    local file = io.open(path, "w+")
    if file then
        -- print("Gamedonia.userdefault - File saved")
        -- printTable(UserDefault.values)
        -- write all contents of file into a string
        file:write(Json.encode(lib.values))
        io.close(file) -- close the file after using it
    else
        print("Gamedonia.userdefault - no file saved")
    end
end

UserDefault.setValue = function(key, value)
    if not UserDefault.values then
        UserDefault.values = {}
    end
    UserDefault.values[key] = value
end

UserDefault.getValue = function(key)
    return UserDefault.values[key]
end

UserDefault.flush = function()
    UserDefault.saveFile()
end

UserDefault.loadFile()

lib.UserDefault = UserDefault



---------------------
-----
-- Gamedonia User
-----
---------------------
local User = {}

User.isLoggedIn = function()
    return true
end

User.sessionToken = nil
User.email = nil
User.password = nil


------------------
-- Create
------------------
local GamedoniaUserCreate = {}

GamedoniaUserCreate.listener = function(event)
    -- print("GamedoniaUserCreate.listener - status: "..event.status.."\n"..event.response)
    if ( event.isError ) then
        GamedoniaUserCreate.onRequestFailed(event)
    else
        GamedoniaUserCreate.onRequestCompleted(event)
    end
end

GamedoniaUserCreate.onRequestCompleted = function(event)
    -- print ("GamedoniaUserCreate.onRequestCompleted - status: "..event.status)
    GamedoniaUserCreate.callback(event.status == 200)
end

GamedoniaUserCreate.onRequestFailed = function(event)
    -- print ("GamedoniaUserCreate.onRequestFailed - status: "..event.status)
    GamedoniaUserCreate.callback(false)
end

User.create = function(user, callback, timeoutTime)
    local userJson = Json.encode(user)
    -- print ("userJson: "..userJson)
    GamedoniaUserCreate.callback = callback
    lib.Request.post("/account/create", userJson, nil, nil, nil, GamedoniaUserCreate.listener, timeoutTime)
end


------------------
-- Email
------------------
local GamedoniaUserLoginEmail = {}

GamedoniaUserLoginEmail.listener = function(event)
    -- print ("GamedoniaUserLoginEmail.listener")
    if ( event.isError ) then
        GamedoniaUserLoginEmail.onRequestFailed(event)
    else
        GamedoniaUserLoginEmail.onRequestCompleted(event)
    end
end

GamedoniaUserLoginEmail.onRequestCompleted = function(event)
    -- print ("GamedoniaUserLoginEmail.onRequestCompleted - event: "..event.status)
    if (event.status == 200) then
        local docJson = Json.decode(event.response)
        User.sessionToken = docJson.session_token
        -- print ("sessionToken: "..User.sessionToken)
        lib.UserDefault.setValue("gd_session_token", User.sessionToken)
        lib.UserDefault.flush()

        GamedoniaUserLoginEmail.callback(true)
    else
        GamedoniaUserLoginEmail.callback(false)
    end
end

GamedoniaUserLoginEmail.onRequestFailed = function(event)
    -- print("GamedoniaUserLoginEmail.onRequestFailed\n\tevent: "..event.status)
    GamedoniaUserLoginEmail.callback(false)
end

User.loginWithEmail = function(email, password, callback)
    if (email ~= nil and email:len() > 0 and password ~= nil and password:len() > 0) then
        User.email = email
        User.password = password
        GamedoniaUserLoginEmail.callback = callback
        local ccauth = string.format("email|%s|%s", email, password)
        local auth = mime.b64(ccauth)
        local data = {}
        data["X-Gamedonia-ApiKey"] = lib.getApiKey()
        data["Authorization"] = "Basic "..auth
        local dataJson = Json.encode(data)
        -- print("dataJson:\n"..dataJson)
        lib.Request.post("/account/login", dataJson, auth, nil, nil, GamedoniaUserLoginEmail.listener)
    else
        -- Invalid email credentials;
    end
end


------------------
-- Open UDID
------------------
local GamedoniaUserLoginOpenUDID = {}

GamedoniaUserLoginOpenUDID.listener = function(event)
    -- print ("GamedoniaUserLoginOpenUDID.listener - status: "..event.status)
    if ( event.isError ) then
        GamedoniaUserLoginOpenUDID.onRequestFailed(event)
    else
        GamedoniaUserLoginOpenUDID.onRequestCompleted(event)
    end
end

GamedoniaUserLoginOpenUDID.onRequestCompleted = function(event)
    if (event.status == 200) then
        local docJson = Json.decode(event.response)
        User.sessionToken = docJson.session_token
        lib.UserDefault.setValue("gd_session_token", User.sessionToken)
        lib.UserDefault.flush()
    end
    GamedoniaUserLoginOpenUDID.callback(event.status == 200, event)
end

GamedoniaUserLoginOpenUDID.onRequestFailed = function(event)
    GamedoniaUserLoginOpenUDID.callback(false, event)
end

User.loginWithOpenUDID = function(callback, timeoutTime)
    local opid = lib.Devices.device.deviceId
    if (opid ~= nil and opid:len() > 0) then
        -- print("openUDID: "..opid)
        GamedoniaUserLoginOpenUDID.callback = callback
        local ccauth = string.format("silent|%s", opid)
        local auth = mime.b64(ccauth)
        local data = {}
        data["X-Gamedonia-ApiKey"] = lib.getApiKey()
        data["Authorization"] = "Basic "..auth
        local dataJson = Json.encode(data)
        lib.Request.post("/account/login", dataJson, auth, nil, nil, GamedoniaUserLoginOpenUDID.listener, timeoutTime);
    else
        print("loginWithOpenUDID - Error")
    end
end


------------------
-- Session Token
------------------
local GamedoniaUserLoginSessionToken = {}

GamedoniaUserLoginSessionToken.listener = function(event)
    -- print ("GamedoniaUserLoginSessionToken - status: "..event.status)
    if ( event.isError ) then
        GamedoniaUserLoginSessionToken.onRequestFail(event)
    else
        GamedoniaUserLoginSessionToken.onRequestCompleted(event)
    end
end

GamedoniaUserLoginSessionToken.onRequestCompleted = function(event)
    if (event.status == 200) then
        local docJson = Json.decode(event.response)
        sessionToken = docJson.session_token
        User.sessionToken = docJson.session_token
        GamedoniaUserDefault.setValue("gd_session_token", User.sessionToken)
        GamedoniaUserDefault.flush()

        GamedoniaUserLoginSessionToken.callback(true)
    else
        GamedoniaUserLoginSessionToken.callback(false)
    end
end

GamedoniaUserLoginSessionToken.onRequestFailed = function(request, response, errorCode)
    GamedoniaUserLoginSessionToken.callback(false)
end

User.loginWithSessionToken = function(callback)
    local sessionToken = GamedoniaUserDefault.getValue("gd_session_token")
    if (sessionToken ~=nil and sessionToken:len() > 0) then
        GamedoniaUserLoginSessionToken.callback = callback
        local ccauth = "session_token|"..sessionToken
        local auth = mime.b64(ccauth)
        local data = {}
        data["X-Gamedonia-ApiKey"] = lib.getApiKey()
        data["Authorization"] = "Basic "..auth
        local dataJson = Json.encode(data)
        lib.Request.post("/account/login", dataJson, auth, nil, nil, GamedoniaUserLoginSessionToken.listener)
    else
       -- Invalid session token credentials
    end
end


------------------
-- Logout
------------------
local GamedoniaUserLogout = {}

GamedoniaUserLogout.listener = function(event)
    -- print ("GamedoniaUserLogout.listener")
    if ( event.isError ) then
        GamedoniaUserLogout.onRequestFailed(event)
    else
        GamedoniaUserLogout.onRequestCompleted(event)
    end
end

GamedoniaUserLogout.onRequestCompleted = function(event)
    -- print ("GamedoniaUserLogout.onRequestCompleted\n\tevent: "..event.status)
    if (event.status == 200) then
        -- print ("GamedoniaUserLogout.onRequestCompleted\n\tevent.response: "..event.response)
        -- local docJson = Json.decode(event.response)
        -- User.sessionToken = docJson.session_token
        -- lib.UserDefault.setValue("gd_session_token", User.sessionToken)
        -- lib.UserDefault.flush()

        GamedoniaUserLogout.callback(true)
    else
        GamedoniaUserLogout.callback(false)
    end
end

GamedoniaUserLogout.onRequestFailed = function(event)
    -- print ("GamedoniaUserLogout.onRequestFailed\n\tevent: "..event.status)
    GamedoniaUserLogout.callback(false)
end

User.logout = function(callback)
    if (User.sessionToken ~= nil) then
        GamedoniaUserLogout.callback = callback
        local data = {}
        data["X-Gamedonia-ApiKey"] = lib.getApiKey()
        data["X-Gamedonia-SessionToken"] = sessionToken
        local dataJson = Json.encode(data)
        lib.Request.post("/account/logout", dataJson, nil, User.sessionToken, nil, GamedoniaUserLogout.listener)
    else
        print("You are not logged in")
    end
end


------------------
-- Update
------------------
local GamedoniaUserUpdate = {}

GamedoniaUserUpdate.listener = function(event)
    if ( event.isError ) then
        GamedoniaUserUpdate.onRequestFail(event)
    else
        GamedoniaUserUpdate.onRequestCompleted(event)
    end
end

GamedoniaUserUpdate.onRequestCompleted = function(event)
    GamedoniaUserUpdate.callback(event.status == 200)
end

GamedoniaUserUpdate.onRequestFailed = function(request, response, errorCode)
    GamedoniaUserUpdate.callback(false)
end

User.update = function(profile, callback, overwrite)
    GamedoniaUserUpdate.callback = callback
    local profileJson = Json.encode(profile)
    -- print (profileJson)
    if overwrite then
        lib.Request.put("/account/update", profileJson, nil, User.sessionToken, nil, GamedoniaUserUpdate.listener)  
    else
        lib.Request.post("/account/update", profileJson, nil, User.sessionToken, nil, GamedoniaUserUpdate.listener)
    end
end


------------------
-- Reset password
------------------
local GamedoniaUserResetPassword = {}

GamedoniaUserResetPassword.listener = function(event)
    -- print ("GamedoniaUserResetPassword.listener - status: "..event.status)
    if (event.isError) then
        GamedoniaUserResetPassword.onRequestFail(event)
    else
        GamedoniaUserResetPassword.onRequestCompleted(event)
    end
end

GamedoniaUserResetPassword.onRequestCompleted = function(event)
    GamedoniaUserResetPassword.callback(event.status == 200)
end

GamedoniaUserResetPassword.onRequestFailed = function(request, response, errorCode)
    GamedoniaUserResetPassword.callback(false)
end

User.resetPasswordEmail = function(email, callback)
    GamedoniaUserResetPassword.callback = callback

    local dataJson = Json.encode({['email'] = email})
    lib.Request.post("/account/password/reset", dataJson, nil, nil, nil, GamedoniaUserResetPassword.listener)
end


------------------
-- Change password
------------------
local GamedoniaUserChangePassword = {}

GamedoniaUserChangePassword.listener = function(event)
    -- print ("GamedoniaUserChangePassword.listener - status: "..event.status)
    if (event.isError) then
        GamedoniaUserChangePassword.onRequestFail(event)
    else
        GamedoniaUserChangePassword.onRequestCompleted(event)
    end
end

GamedoniaUserChangePassword.onRequestCompleted = function(event)
    GamedoniaUserChangePassword.callback(event.status == 200)
end

GamedoniaUserChangePassword.onRequestFailed = function(request, response, errorCode)
    GamedoniaUserChangePassword.callback(false)
end

User.changePassword = function(email, currentPassword, newPassword, callback)
    GamedoniaUserChangePassword.callback = callback
    local ccauth = string.format("email|%s|%s", email, currentPassword)
    local auth = mime.b64(ccauth)

    local dataJson = Json.encode({['password'] = newPassword})
    lib.Request.post("/account/password/change", dataJson, auth, nil, nil, GamedoniaUserChangePassword.listener)
end


------------------
-- Restore password
------------------
local GamedoniaUserRestorePassword = {}

GamedoniaUserRestorePassword.listener = function(event)
    -- print ("GamedoniaUserRestorePassword.listener - status: "..event.status)
    if (event.isError) then
        GamedoniaUserRestorePassword.onRequestFail(event)
    else
        GamedoniaUserRestorePassword.onRequestCompleted(event)
    end
end

GamedoniaUserRestorePassword.onRequestCompleted = function(event)
    GamedoniaUserRestorePassword.callback(event.status == 200)
end

GamedoniaUserRestorePassword.onRequestFailed = function(request, response, errorCode)
    GamedoniaUserRestorePassword.callback(false)
end

User.changePassword = function(restoreToken, newPassword, callback)
    GamedoniaUserRestorePassword.callback = callback
    local sessionToken = lib.UserDefault.getValue("gd_session_token")
    local dataJson = Json.encode({['password'] = newPassword})
    lib.Request.post("/account/password/restore", dataJson, nil, sessionToken, nil, GamedoniaUserRestorePassword.listener)
end


------------------
-- Search user
------------------
local GamedoniaUserSearch = {}

GamedoniaUserSearch.listener = function(event)
    -- print ("GamedoniaUserSearch.listener - status: "..event.status)
    if (event.isError) then
        GamedoniaUserSearch.onRequestFail(event)
    else
        GamedoniaUserSearch.onRequestCompleted(event)
    end
end

GamedoniaUserSearch.onRequestCompleted = function(event)
   -- print ("GamedoniaUserSearch.onRequestCompleted - event.response: "..event.response)
    if (event.status == 200) then
        GamedoniaUserSearch.callback(true, Json.decode(event.response))
    else
        GamedoniaUserSearch.callback(false)
    end
end

GamedoniaUserSearch.onRequestFailed = function(request, response, errorCode)
    GamedoniaUserSearch.callback(false)
end

User.search = function(query, limit, sort, skip, callback)
    GamedoniaUserSearch.callback = callback
    local queryStr = nil
    if query then
        queryStr = "?query="..Url.escape(query)
        if limit and limit > 0 then
           queryStr = queryStr.."&limit="..limit
        end
        if sort ~= nil then
          queryStr = queryStr.."&sort="..Url.escape(sort)
        end
        if skip and skip > 0 then
          queryStr = queryStr.."&skip="..skip
        end
    end
    local sessionToken = lib.UserDefault.getValue("gd_session_token")
    -- print("query - "..query)
    lib.Request.get("/account/search", queryStr, sessionToken, GamedoniaUserSearch.listener)
end


------------------
-- Count user
------------------
local GamedoniaUserCount = {}

GamedoniaUserCount.listener = function(event)
    -- print ("GamedoniaUserCount.listener - status: "..event.status)
    if (event.isError) then
        GamedoniaUserCount.onRequestFail(event)
    else
        GamedoniaUserCount.onRequestCompleted(event)
    end
end

GamedoniaUserCount.onRequestCompleted = function(event)
   -- print ("GamedoniaUserCount.onRequestCompleted - event.response: "..event.response)
    if (event.status == 200) then
        GamedoniaUserCount.callback(true, Json.decode(event.response).count)
    else
        GamedoniaUserCount.callback(false)
    end
end

GamedoniaUserCount.onRequestFailed = function(event)
    GamedoniaUserCount.callback(false)
end

User.count = function(query, callback)
    GamedoniaUserCount.callback = callback
    local queryStr = nil
    if query then
        queryStr = "?query="..Url.escape(query)
    end
    local sessionToken = lib.UserDefault.getValue("gd_session_token")
    -- print("query - "..query)
    lib.Request.get("/account/count", queryStr, sessionToken, GamedoniaUserCount.listener)
end


------------------
-- Get user
------------------
local GamedoniaUserGetUser = {}

GamedoniaUserGetUser.listener = function(event)
    if ( event.isError ) then
        GamedoniaUserGetUser.onRequestFail(event)
    else
        GamedoniaUserGetUser.onRequestCompleted(event)
    end
end

GamedoniaUserGetUser.onRequestCompleted = function(event)
    if (event.status == 200) then
        local profile = Json.decode(event.response)

        GamedoniaUserGetUser.callback(true)
    else
        GamedoniaUserGetUser.callback(false)
    end
end

GamedoniaUserGetUser.onRequestFailed = function(event)
    GamedoniaUserGetUser.callback(false)
end

User.getUser = function(userId, callback)
    if (userId ~= nil and userId:len() >0) then
        GamedoniaUserGetUser.callback = callback
        local data = {}
        data["X-Gamedonia-ApiKey"] = lib.getApiKey()
        data["_id"] = userId
        local dataJson = Json.encode(dict)
        lib.Request.post("/account/retrieve", dataJson, nil, sessionToken, nil, GamedoniaUserGetUser.listener)
    else
        print ("GamedoniaUser.getUser - Error")
    end
end


------------------
-- Get me
------------------
local GamedoniaUserGetMe = {}

GamedoniaUserGetMe.onRequestCompleted = function(event)
   -- print ("GamedoniaUserGetMe.onRequestCompleted\n\tevent: "..event.status)
    if (event.status == 200) then
        local profile = Json.decode(event.response)
        GamedoniaUserGetMe.callback(true, profile)
    else
        GamedoniaUserGetMe.callback(false, "Error ".. event.status) -- gerard
    end
end

GamedoniaUserGetMe.onRequestFailed = function(event)
   -- print ("GamedoniaUserGetMe.onRequestFailed\n\tevent: "..event.status)
    GamedoniaUserGetMe.callback(false, "Request Failed") -- gerard
end

GamedoniaUserGetMe.listener = function(event)
   -- print ("GamedoniaUserGetMe.listener")
    if ( event.isError ) then
        GamedoniaUserGetMe.onRequestFailed(event)
    else
        GamedoniaUserGetMe.onRequestCompleted(event)
    end
end

User.getMe = function(callback, timeoutTime)
    if (User.sessionToken ~= nil) then
        GamedoniaUserGetMe.callback = callback
        lib.Request.get("/account/me", nil, User.sessionToken, GamedoniaUserGetMe.listener, timeoutTime)
    else
        print ("getMe - error")
    end
end
    

lib.User = User



---------------------
-----
-- Gamedonia
-----
---------------------
lib.apiKey = ""
lib.secret = ""
lib.apiServerUrl = ""
lib.apiVersion = ""
lib.sharedUserValue = nil

local function cbRegDev(event)
    if ( event.isError ) then
        missatges.text =  "Error al donar d'alta el dispositiu."
    else
        missatges.text =  "Alta dispositiu - status: "..event.status
    end 
end

lib.initialize = function(apiKey, secret, apiServerUrl, apiVersion)
    lib.apiKey = apiKey;
    lib.secret = secret;
    lib.apiServerUrl = apiServerUrl;
    lib.apiVersion = apiVersion;
end


lib.getApiKey = function()
    return lib.apiKey
end

lib.getSecret = function()
    return lib.secret
end

lib.getApiServerUrl = function()
    return lib.apiServerUrl
end

lib.getApiVersion = function()
    return lib.apiVersion
end


lib.sharedUser = function()
    if (lib.sharedUserValue == nil) then
        lib.sharedUserValue = lib.User
    end
    return lib.sharedUserValue
end



-- Return lib instead of using 'module()' which pollutes the global namespace
return lib
