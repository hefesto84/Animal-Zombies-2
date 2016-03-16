---------------------
-----
-- Gamedonia Script
-----
---------------------

local Library = require "CoronaLibrary"
local lib = Library:new{ name='controller.gamedonia.plugin.GamedoniaScript', publisherId='com.Gamedonia' }

local GamedoniaRequest = require "controller.gamedonia.plugin_GamedoniaRequest"

local json = require "json"


GamedoniaScriptRun.listener = function(event)
	print("GamedoniaDataCreate - status: "..event.status)
	if ( event.isError ) then
		GamedoniaScriptRun.onRequestFail(event)
	else
		GamedoniaGamedoniaScriptRunDataCreate.onRequestCompleted(event)
	end
end

GamedoniaScriptRun.onRequestCompleted = function(event)
	print("GamedoniaDataCreate.onRequestCompleted - status: "..event.status)
--    printResponseLog(response);  
	GamedoniaScriptRun.target(event.status == 200)
end

GamedoniaScriptRun.onRequestFailed = function(event)
	print ("GamedoniaDataCreate.onRequestFailed")
--    printResponseLog(response);
	GamedoniaScriptRun.target(false)
end

lib.run = function(script, parameters, callback)
    local dataJson = json.encode(parameters)
    GamedoniaScriptRun.callback = callback
    GamedoniaRequest.post("/run/" + script, json, nil, GamedoniaUsers.GetSessionToken(), nil, GamedoniaScriptRun.listener)
end


-- Return lib instead of using 'module()' which pollutes the global namespace
return lib
