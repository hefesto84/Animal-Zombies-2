---------------------
-----
-- Gamedonia Request
-----
---------------------

local Library = require "CoronaLibrary"
local lib = Library:new{ name='controller.gamedonia.plugin.GamedoniaRequest', publisherId='com.Gamedonia' }

local GamedoniaCrypto = require "controller.gamedonia.plugin_GamedoniaCrypto"

local network = require "network"
local os = require "os"

local GD_API_KEY = "X-Gamedonia-ApiKey" 
local GD_SIGNATURE = "X-Gamedonia-Signature"
local GD_SESSION_TOKEN = "X-Gamedonia-SessionToken"
local GD_AUTH = "Authorization"
local DATE_HEADER = "Date"
local GD_GAMEID = "gameid"
local REQUEST_TIMEOUT = 20


lib.getCurrentDate = function()
    local date = os.date( "%Y-%m-%d %H:%M:%S" )
    return date
end

lib.ping = function(cb)
    lib.get("/ping", nil, nil, cb)
end


lib.get = function(url, queryString, sessionToken, callback, timeOut)
    --    LOG("[Api Call] - %s",url)
    local currentDate = lib.getCurrentDate()
    local urlBuf = string.format("%s/%s%s", GamedoniaSDK.getApiServerUrl(), GamedoniaSDK.getApiVersion(), url)
    
    if (queryString ~= nil and queryString:len()>0) then
        urlBuf = urlBuf.."?"..queryString
    end
    
    local headers = {}
    headers["X-Gamedonia-ApiKey"] = GamedoniaSDK.getApiKey()
    headers["Date"] = currentDate
    if (sessionToken ~= nil and sessionToken:len() > 0) then
        headers["X-Gamedonia-SessionToken"] = sessionToken;
    end
    local path = string.format("/%s%s", GamedoniaSDK.getApiVersion(), url)
    local hmac = GamedoniaCrypto.signGet(GamedoniaSDK.getApiKey(), GamedoniaSDK.getSecret(), currentDate, "GET", path)
    headers["X-Gamedonia-Signature"] = hmac
    
    local params = {}
    params.headers = headers
    params.timeout = timeOut or REQUEST_TIMEOUT
    
    --	print("urlBuf: "..urlBuf)
    --	print("path: "..path)
    --	print ("GamedoniaRequest.get - params.headers:")
    --	for key,value in pairs(params.headers) do print(key,value) end
    network.request(urlBuf, "GET", callback, params)
end


lib.post = function(url, content, auth, sessionToken, gameid, callback, timeOut)
    --    LOG("[Api Call] - %s %s",url, content);
    
    local currentDate = lib.getCurrentDate()
    
    local urlBuf = string.format("%s/%s%s", GamedoniaSDK.getApiServerUrl(), GamedoniaSDK.getApiVersion(), url)
    --    print ("url:\n"..urlBuf)
    
    local params = {}
    local headers = {}
    
    params.timeout = timeOut or REQUEST_TIMEOUT
    headers["X-Gamedonia-ApiKey"] = GamedoniaSDK.getApiKey()
    headers["Content-Type"] = "application/json"
    headers["Date"] = currentDate
    
    if (content ~= nil and content:len() > 0) then
        params.body = content
        local path = string.format("/%s%s", GamedoniaSDK.getApiVersion(), url)
        local hmac = GamedoniaCrypto.signPost(GamedoniaSDK.getApiKey(), GamedoniaSDK.getSecret(), content, "application/json; charset=UTF-8", currentDate, "POST", path)
        headers["X-Gamedonia-Signature"] = hmac
        --	    print ("params.body:\n"..params.body)
    end
    
    if (auth ~= nil and auth:len() > 0) then
        headers["Authorization"] = auth
    end
    
    if (sessionToken ~= nil and sessionToken:len() > 0) then
        headers["X-Gamedonia-SessionToken"] = sessionToken
        --        print ("Gamedonia.post - X-Gamedonia-SessionToken: "..sessionToken)
    end
    
    if (gameid ~= nil and gameid:len() > 0) then
        headers["gameid"] = gameid
    end
    
    params.headers = headers
    
    network.request(urlBuf, "POST", callback, params)
end


lib.put = function(url, content, auth, sessionToken, gameid, callback, timeOut)
    --    LOG("[Api Call] - %s %s",url, content);
    
    local urlBuf = string.format("%s/%s%s", GamedoniaSDK.getApiServerUrl(), GamedoniaSDK.getApiVersion(), url)
    
    local currentDate = lib.getCurrentDate()
    local params = {}
    local headers = {}
    
    params.timeout = timeOut or REQUEST_TIMEOUT
    headers["X-Gamedonia-ApiKey"] = GamedoniaSDK.getApiKey()
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
        local path = string.format("/%s%s", GamedoniaSDK.getApiVersion(), url)
        local hmac = GamedoniaCrypto.signPost(GamedoniaSDK.getApiKey(), GamedoniaSDK.getSecret(), content, "application/json; charset=UTF-8", currentDate, "PUT", path)
        headers["X-Gamedonia-Signature"] = hmac
    end
    
    params.headers = headers
    
    --    print ("url:\n"..urlBuf)
    --    print ("params.body:\n"..params.body)
    network.request(urlBuf, "PUT", callback, params)
end


lib.delete = function(url, callback, timeOut)
    --    LOG("[Api Call] - %s %s",url, content);
    
    local currentDate = lib.getCurrentDate()
    
    local urlBuf = string.format("%s/%s%s", GamedoniaSDK.getApiServerUrl(), GamedoniaSDK.getApiVersion(), url)
    
    local params = {}
    local headers = {}
    
    params.timeout = timeOut or REQUEST_TIMEOUT
    headers["X-Gamedonia-ApiKey"] = GamedoniaSDK.getApiKey()
    headers["Date"] = currentDate
    
    params.headers = headers
    
    --    print ("url:\n"..urlBuf)
    --    print ("params.body:\n"..params.body)
    network.request(urlBuf, "DELETE", callback, params)
end


-- Return lib instead of using 'module()' which pollutes the global namespace
return lib