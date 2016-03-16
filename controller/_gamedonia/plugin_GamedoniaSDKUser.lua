---------------------
-----
-- Gamedonia SDK User
-----
---------------------
local Library = require "CoronaLibrary"
local lib = Library:new{ name='controller.gamedonia.plugin.GamedoniaSDKUser', publisherId='com.Gamedonia' }

local GamedoniaRequest = require "controller.gamedonia.plugin_GamedoniaRequest"
local GamedoniaUserDefault = require "controller.gamedonia.plugin_GamedoniaUserDefault"

local mime = require "mime"
local json = require "json"
local OpenUDID = require "controller.gamedonia.openudid" --"plugin.openudid"

lib.isLoggedIn = function()
    return true
end

lib.sessionToken = nil


------------------
-- Create user
------------------
local GamedoniaSDKUserCreateUser = {}

GamedoniaSDKUserCreateUser.listener = function(event)
	if ( event.isError ) then
		GamedoniaSDKUserCreateUser.onRequestFailed(event)
	else
		GamedoniaSDKUserCreateUser.onRequestCompleted(event)
	end
end

GamedoniaSDKUserCreateUser.onRequestCompleted = function(event)
--    print ("GamedoniaSDKUserCreateUser.onRequestCompleted - status: "..event.status)
--    printResponseLog(response);
    GamedoniaSDKUserCreateUser.callback(event.status == 200)
end

GamedoniaSDKUserCreateUser.onRequestFailed = function(event)
--    print ("GamedoniaSDKUserCreateUser.onRequestFailed - status: "..event.status)
--    printResponseLog(response);
    GamedoniaSDKUserCreateUser.callback(false)
end

lib.createUser = function(user, callback)
    local userJson = json.encode(user)
--    print ("userJson: "..userJson)
	GamedoniaSDKUserCreateUser.callback = callback
    GamedoniaRequest.post("/account/create", userJson, nil, nil, nil, GamedoniaSDKUserCreateUser.listener);
end


------------------
-- Email
------------------
local GamedoniaSDKUserLoginEmail = {}

GamedoniaSDKUserLoginEmail.onRequestCompleted = function(event)
--    print ("GamedoniaSDKUserLoginEmail.onRequestCompleted\n\tevent: "..event.status)
    if (event.status == 200) then
        local docJson = json.decode(event.response)
        lib.sessionToken = docJson.session_token
--        print ("sessionToken: "..lib.sessionToken)
        GamedoniaUserDefault.setValue("gd_session_token", lib.sessionToken)
        GamedoniaUserDefault.flush()
        
        GamedoniaSDKUserLoginEmail.callback(true)
    else
        GamedoniaSDKUserLoginEmail.callback(false)
    end
end

GamedoniaSDKUserLoginEmail.onRequestFailed = function(event)
--    print("GamedoniaSDKUserLoginEmail.onRequestFailed\n\tevent: "..event.status)
    GamedoniaSDKUserLoginEmail.callback(false)
end

GamedoniaSDKUserLoginEmail.listener = function(event)
--    print ("GamedoniaSDKUserLoginEmail.listener")
    if ( event.isError ) then
        GamedoniaSDKUserLoginEmail.onRequestFailed(event)
    else
        GamedoniaSDKUserLoginEmail.onRequestCompleted(event)
    end
end

lib.loginUserWithEmail = function(email, password, callback)
    if (email ~= nil and email:len() > 0 and password ~= nil and password:len() > 0) then
        GamedoniaSDKUserLoginEmail.callback = callback
        local ccauth = string.format("email|%s|%s", email, password)
--        print ("ccauth: "..ccauth)
        local auth = mime.b64(ccauth)
        local data = {}
        data["X-Gamedonia-ApiKey"] = GamedoniaSDK.getApiKey()
        data["Authorization"] = "Basic "..auth
        local dataJson = json.encode(data)
--        print("dataJson:\n"..dataJson)
        GamedoniaRequest.post("/account/login", dataJson, auth, nil, nil, GamedoniaSDKUserLoginEmail.listener)
    else
--        LOG("Invalid email credentials");
    end
end


------------------
-- Open UDID
------------------
local GamedoniaSDKUserLoginOpenUDID = {}

GamedoniaSDKUserLoginOpenUDID.listener = function(event)
    print ("GamedoniaSDKUserLoginOpenUDID.listener - status: "..event.status)
	if ( event.isError ) then
		GamedoniaSDKUserLoginOpenUDID.onRequestFailed(event)
	else
		GamedoniaSDKUserLoginOpenUDID.onRequestCompleted(event)
	end
end

GamedoniaSDKUserLoginOpenUDID.onRequestCompleted = function(event)
    if (event.status == 200) then
        local docJson = json.decode(event.response)
        lib.sessionToken = docJson.session_token
        GamedoniaUserDefault.setValue("gd_session_token", lib.sessionToken)
        GamedoniaUserDefault.flush()
    end
    GamedoniaSDKUserLoginOpenUDID.callback(event.status == 200)
end

GamedoniaSDKUserLoginOpenUDID.onRequestFailed = function(event)
--    printResponseLog(response);
    GamedoniaSDKUserLoginOpenUDID.callback(false)
end

lib.loginUserWithOpenUDID = function(callback, timeOut)
    local opid = OpenUDID.getValue()
    if (opid ~= nil and opid:len() > 0) then
        GamedoniaSDKUserLoginOpenUDID.callback = callback
        local ccauth = string.format("silent|%s", opid)
        local auth = mime.b64(ccauth)
        local data = {}
        data["X-Gamedonia-ApiKey"] = GamedoniaSDK.getApiKey()
        data["Authorization"] = "Basic "..auth
        local dataJson = json.encode(data)
        GamedoniaRequest.post("/account/login", dataJson, auth, nil, nil, GamedoniaSDKUserLoginOpenUDID.listener, timeOut);
    else
    	print("loginUserWithOpenUDID - Error")
--        LOG("Couldn't resolve OpenUDID for device");
    end
end


------------------
-- Facebook
------------------
local GamedoniaSDKUserLoginFacebook = {}

GamedoniaSDKUserLoginFacebook.listener = function(event)
	if ( event.isError ) then
		GamedoniaSDKUserLoginFacebook.onRequestFailed(event)
	else
		GamedoniaSDKUserLoginFacebook.onRequestCompleted(event)
	end
end

GamedoniaSDKUserLoginFacebook.onRequestCompleted = function(request, response)
--    printResponseLog(response);
    if (event.status == 200) then
        local docJson = json.decode(event.response)
        sessionToken = docJson.session_token
        lib.sessionToken = docJson.session_token
        GamedoniaUserDefault.setValue("gd_session_token", lib.sessionToken)
        GamedoniaUserDefault.flush()

        GamedoniaSDKUserLoginFacebook.callback(true)
    else
        GamedoniaSDKUserLoginFacebook.callback(false)
    end
end

GamedoniaSDKUserLoginFacebook.onRequestFailed = function(request, response, errorCode)
--    printResponseLog(response);
    GamedoniaSDKUserLoginFacebook.callback(false)
end

lib.loginUserWithFacebook = function(fbuid, fbAccessToken, callback, timeOut)
    if (fbuid ~= nil and fbuid:len() > 0 and fbAccessToken ~= nil and fbAccessToken:len() > 0) then
        GamedoniaSDKUserLoginFacebook.callback = callback
        local ccauth = string.format("facebook|%@|%@", fbuid, fbAccessToken)
        local auth = mime.b64(ccauth)
        local data = {}
        data["X-Gamedonia-ApiKey"] = GamedoniaSDK.getApiKey()
        data["Authorization"] = "Basic "..auth
        local dataJson = json.encode(data)
        GamedoniaRequest.post("/account/login", dataJson, auth, nil, nil, GamedoniaSDKUserLoginFacebook.listener, timeOut)
    else
        LOG("Invalid facebook credentials");
    end
end


------------------
-- Twitter
------------------
local GamedoniaSDKUserLoginTwitter = {}

GamedoniaSDKUserLoginTwitter.listener = function(event)
	if ( event.isError ) then
		GamedoniaSDKUserLoginTwitter.onRequestFailed(event)
	else
		GamedoniaSDKUserLoginTwitter.onRequestCompleted(event)
	end
end

GamedoniaSDKUserLoginTwitter.onRequestCompleted = function(request, response)
--    printResponseLog(response);
    
    if (event.status == 200) then
        local docJson = json.decode(event.response)
        sessionToken = docJson.session_token
        lib.sessionToken = docJson.session_token
        GamedoniaUserDefault.setValue("gd_session_token", lib.sessionToken)
        GamedoniaUserDefault.flush()

        GamedoniaSDKUserLoginTwitter.callback(true)
    else
        GamedoniaSDKUserLoginTwitter.callback(false)
    end
end

GamedoniaSDKUserLoginTwitter.onRequestFailed = function(request, response, errorCode)
--    printResponseLog(response);
    GamedoniaSDKUserLoginTwitter.callback(false)
end

lib.loginUserWithTwitter = function(twuid, twTokenSecret, twToken, callback, timeOut)
    if (twuid ~= nil and twuid:len() > 0 and twTokenSecret ~= nil and twTokenSecret:len() > 0 and twToken ~= nil and twToken:len() > 0) then
        GamedoniaSDKUserLoginTwitter.callback = callback
        local ccauth = string.format("twitter|%@|%@|%@", twuid, twTokenSecret, twToken)
        local auth = mime.b64(ccauth)
        local data = {}
        data["X-Gamedonia-ApiKey"] = GamedoniaSDK.getApiKey()
        data["Authorization"] = "Basic "..auth
        local dataJson = json.encode(data)
        GamedoniaRequest.post("/account/login", dataJson, auth, nil, nil, GamedoniaSDKUserLoginTwitter.listener, timeOut)
    else
--        LOG("Invalid twitter credentials");
    end
end


------------------
-- Session Token
------------------
local GamedoniaSDKUserLoginSessionToken = {}

GamedoniaSDKUserLoginSessionToken.listener = function(event)
	print ("GamedoniaSDKUserLoginSessionToken - status: "..event.status)
	if ( event.isError ) then
		GamedoniaSDKUserLoginSessionToken.onRequestFail(event)
	else
		GamedoniaSDKUserLoginSessionToken.onRequestCompleted(event)
	end
end

GamedoniaSDKUserLoginSessionToken.onRequestCompleted = function(event)
--    printResponseLog(response);
    if (event.status == 200) then
        local docJson = json.decode(event.response)
        sessionToken = docJson.session_token
        lib.sessionToken = docJson.session_token
        GamedoniaUserDefault.setValue("gd_session_token", lib.sessionToken)
        GamedoniaUserDefault.flush()

	    GamedoniaSDKUserLoginSessionToken.callback(true)
    else
	    GamedoniaSDKUserLoginSessionToken.callback(false)
    end
end

GamedoniaSDKUserLoginSessionToken.onRequestFailed = function(request, response, errorCode)
--    printResponseLog(response);
	GamedoniaSDKUserLoginSessionToken.callback(false)
end

lib.loginUserWithSessionToken = function(callback, timeOut)
    local sessionToken = GamedoniaUserDefault.getValue("gd_session_token")
    if (sessionToken ~=nil and sessionToken:len() > 0) then
	    GamedoniaSDKUserLoginSessionToken.callback = callback
	    print ("Session Token:\n\t"..sessionToken)
        local ccauth = "session_token|"..sessionToken
        local auth = mime.b64(ccauth)
        local data = {}
        data["X-Gamedonia-ApiKey"] = GamedoniaSDK.getApiKey()
        data["Authorization"] = "Basic "..auth
        local dataJson = json.encode(data)
        GamedoniaRequest.post("/account/login", dataJson, auth, nil, nil, GamedoniaSDKUserLoginSessionToken.listener, timeOut)
    else
--        LOG("Invalid session token credentials");
    end
end


------------------
-- Game Center Id
------------------
local GamedoniaSDKUserLoginGameCenter = {}

GamedoniaSDKUserLoginGameCenter.listener = function(event)
	if ( event.isError ) then
		GamedoniaSDKUserLoginGameCenter.onRequestFail(event)
	else
		GamedoniaSDKUserLoginGameCenter.onRequestCompleted(event)
	end
end

GamedoniaSDKUserLoginGameCenter.onRequestCompleted = function(request, response)
--    printResponseLog(response);
    if (event.status == 200) then
        local docJson = json.decode(event.response)
        sessionToken = docJson.session_token
        lib.sessionToken = docJson.session_token
        GamedoniaUserDefault.setValue("gd_session_token", lib.sessionToken)
        GamedoniaUserDefault.flush()

	    GamedoniaSDKUserLoginGameCenter.callback(true)
    else
	    GamedoniaSDKUserLoginGameCenter.callback(false)
    end
end

GamedoniaSDKUserLoginGameCenter.onRequestFailed = function(request, response, errorCode)
--    printResponseLog(response);
	GamedoniaSDKUserLoginGameCenter.callback(false)
end

lib.loginUserWithGameCenterId = function(gamecenterId, callback, timeOut)
    if (gamecenterId ~= nil and gamecenterId:len() > 0) then
	    GamedoniaSDKUserLoginGameCenter.callback = callback
        local ccauth = string.format("gamecenter|%@", gamecenterId)
        local auth = mime.b64(ccauth)
        local data = {}
        data["X-Gamedonia-ApiKey"] = GamedoniaSDK.getApiKey()
        data["Authorization"] = "Basic "..auth
        local dataJson = json.encode(data)
        GamedoniaRequest.post("/account/login", dataJson, auth, nil, nil, GamedoniaSDKUserLoginGameCenter.listener, timeOut)
    else
--        LOG("Invalid gamecenter credentials");
    end
end


------------------
-- Logout user
------------------
local GamedoniaSDKUserLogout = {}

GamedoniaSDKUserLogout.onRequestCompleted = function(event)
--    printResponseLog(response);
--    print ("GamedoniaSDKUserLogout.onRequestCompleted\n\tevent: "..event.status)
    if (event.status == 200) then
--	    print ("GamedoniaSDKUserLogout.onRequestCompleted\n\tevent.response: "..event.response)
--        local docJson = json.decode(event.response)
--        lib.sessionToken = docJson.session_token
--        GamedoniaUserDefault.setValue("gd_session_token", lib.sessionToken)
--        GamedoniaUserDefault.flush()

	    GamedoniaSDKUserLogout.callback(true)
    else
	    GamedoniaSDKUserLogout.callback(false)
    end
end

GamedoniaSDKUserLogout.onRequestFailed = function(event)
--    print ("GamedoniaSDKUserLogout.onRequestFailed\n\tevent: "..event.status)
    GamedoniaSDKUserLogout.callback(false)
end

GamedoniaSDKUserLogout.listener = function(event)
--	print ("GamedoniaSDKUserLogout.listener")
	if ( event.isError ) then
		GamedoniaSDKUserLogout.onRequestFailed(event)
	else
		GamedoniaSDKUserLogout.onRequestCompleted(event)
	end
end

lib.logoutUser = function(callback)
    if (lib.sessionToken ~= nil) then
        GamedoniaSDKUserLogout.callback = callback
        local data = {}
        data["X-Gamedonia-ApiKey"] = GamedoniaSDK.getApiKey()
        data["X-Gamedonia-SessionToken"] = sessionToken
        local dataJson = json.encode(data)
        GamedoniaRequest.post("/account/logout", dataJson, nil, lib.sessionToken, nil, GamedoniaSDKUserLogout.listener)
    else
        print("You are not logged in")
    end
end


------------------
-- Get user
------------------
local GamedoniaSDKUserGetUser = {}

GamedoniaSDKUserGetUser.listener = function(event)
	if ( event.isError ) then
		GamedoniaSDKUserGetUser.onRequestFail(event)
	else
		GamedoniaSDKUserGetUser.onRequestCompleted(event)
	end
end

GamedoniaSDKUserGetUser.onRequestCompleted = function(event)
--    printResponseLog(response);  
    if (event.status == 200) then
        local profile = json.decode(event.response)

	    GamedoniaSDKUserGetUser.callback(true)
    else
	    GamedoniaSDKUserGetUser.callback(false)
    end
end

GamedoniaSDKUserGetUser.onRequestFailed = function(event)
--    printResponseLog(response);
	GamedoniaSDKUserGetUser.callback(false)
end

lib.getUser = function(userId, callback, timeOut)
    if (userId ~= nil and userId:len() >0) then
--        NO2MutableDictionary *dict = new NO2MutableDictionary();
--        dict->addObjectForKey(userId, "_id");
	    GamedoniaSDKUserGetUser.callback = callback
        local data = {}
        data["X-Gamedonia-ApiKey"] = GamedoniaSDK.getApiKey()
        data["_id"] = userId
        local dataJson = json.encode(dict)
        GamedoniaRequest.post("/account/retrieve", dataJson, nil, sessionToken, nil, GamedoniaSDKUserGetUser.listener, timeOut)
    else
--        LOG("Couldn't perform getUser, userId is empty");
    end
end


------------------
-- Get me
------------------
local GamedoniaSDKUserGetMe = {}

GamedoniaSDKUserGetMe.onRequestCompleted = function(event)
--    print ("GamedoniaSDKUserGetMe.onRequestCompleted\n\tevent: "..event.status)
--    printResponseLog(response);
    if (event.status == 200) then
        local profile = json.decode(event.response)
	    GamedoniaSDKUserGetMe.callback(true, profile)
    else
	    GamedoniaSDKUserGetMe.callback(false)
    end
end

GamedoniaSDKUserGetMe.onRequestFailed = function(event)
--    print ("GamedoniaSDKUserGetMe.onRequestFailed\n\tevent: "..event.status)
--    printResponseLog(response);
	GamedoniaSDKUserGetMe.callback(false)
end

GamedoniaSDKUserGetMe.listener = function(event)
--    print ("GamedoniaSDKUserGetMe.listener")
	if ( event.isError ) then
		GamedoniaSDKUserGetMe.onRequestFailed(event)
	else
		GamedoniaSDKUserGetMe.onRequestCompleted(event)
	end
end

lib.getMe = function(callback, timeOut)
    if (lib.sessionToken ~= nil) then
        GamedoniaSDKUserGetMe.callback = callback
        GamedoniaRequest.get("/account/me", nil, lib.sessionToken, GamedoniaSDKUserGetMe.listener, timeOut)
    else
    	print ("getMe - error")
--        LOG("Couldn't perform getMe, you are not logged in");
    end
end


------------------
-- Update
------------------
local GamedoniaSDKUpdate = {}

GamedoniaSDKUpdate.listener = function(event)
	if ( event.isError ) then
		GamedoniaSDKUpdate.onRequestFail(event)
	else
		GamedoniaSDKUpdate.onRequestCompleted(event)
	end
end

GamedoniaSDKUpdate.onRequestCompleted = function(event)
--    printResponseLog(response);  
    if (event.status == 200) then
	    GamedoniaSDKUpdate.callback(true)
    else
	    GamedoniaSDKUpdate.callback(false)
    end
end

GamedoniaSDKUpdate.onRequestFailed = function(request, response, errorCode)
--    printResponseLog(response);
	GamedoniaSDKUpdate.callback(false)
end

lib.updateUser = function(profile, callback, overwrite)
	if not overwrite then
		overwrite = false
	end
    GamedoniaSDKUpdate.callback = callback
	local profileJson = json.encode(profile)
	if overwrite then
		GamedoniaRequest.put("/account/update", profileJson, nil, lib.sessionToken, nil, GamedoniaSDKUpdate.listener)	
	else
		GamedoniaRequest.post("/account/update", profileJson, nil, lib.sessionToken, nil, GamedoniaSDKUpdate.listener)
	end
end


------------------
-- Reset password
------------------
local GamedoniaSDKResetPassword = {}

GamedoniaSDKResetPassword.listener = function(event)
	if (event.isError) then
		GamedoniaSDKResetPassword.onRequestFail(event)
	else
		GamedoniaSDKResetPassword.onRequestCompleted(event)
	end
end

GamedoniaSDKResetPassword.onRequestCompleted = function(event)
--    printResponseLog(response);  
    if (event.status == 200) then
	    GamedoniaSDKResetPassword.callback(true)
    else
	    GamedoniaSDKResetPassword.callback(false)
    end
end

GamedoniaSDKResetPassword.onRequestFailed = function(request, response, errorCode)
--    printResponseLog(response);
	GamedoniaSDKResetPassword.callback(false)
end

lib.resetPasswordEmail = function(email, callback)
	GamedoniaSDKResetPassword.callback = callback

	local dataJson = json.encode(profile)
	GamedoniaRequest.post("/account/password/reset", dataJson, nil, nil, nil, GamedoniaSDKResetPassword.listener)
end
	


-- Return lib instead of using 'module()' which pollutes the global namespace
return lib
