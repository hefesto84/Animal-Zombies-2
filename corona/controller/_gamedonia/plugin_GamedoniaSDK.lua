---------------------
-----
-- Gamedonia SDK
-----
---------------------

local Library = require "CoronaLibrary"
local lib = Library:new{ name='controller.gamedonia.plugin.GamedoniaSDK', publisherId='com.Gamedonia' }

local GamedoniaSDKUser = require "controller.gamedonia.plugin_GamedoniaSDKUser"


lib.apiKey = ""
lib.secret = ""
lib.apiServerUrl = ""
lib.apiVersion = ""
lib.sharedUserValue = nil


lib.initialize = function(apiKey, secret, apiServerUrl, apiVersion, options)
    lib.apiKey = apiKey;
    lib.secret = secret;
    lib.apiServerUrl = apiServerUrl;
    lib.apiVersion = apiVersion;

    print("Initializing Gamedonia SDK");
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
        lib.sharedUserValue = GamedoniaSDKUser
    end
    return lib.sharedUserValue
end


-- Return lib instead of using 'module()' which pollutes the global namespace
return lib
