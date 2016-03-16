---------------------
-----
-- Gamedonia Data
-----
---------------------

local Library = require "CoronaLibrary"
local lib = Library:new{ name='controller.gamedonia.plugin.GamedoniaData', publisherId='com.Gamedonia' }

local GamedoniaRequest = require "controller.gamedonia.plugin_GamedoniaRequest"

local json = require "json"
local url = require("socket.url")


------------------
-- Create
------------------
local GamedoniaDataCreate = {}

GamedoniaDataCreate.listener = function(event)
    print("GamedoniaDataCreate - status: "..event.status)
    if ( event.isError ) then
        GamedoniaDataCreate.onRequestFail(event)
    else
        GamedoniaDataCreate.onRequestCompleted(event)
    end
end

GamedoniaDataCreate.onRequestCompleted = function(event)
    print("GamedoniaDataCreate.onRequestCompleted - status: "..event.status)
    --    printResponseLog(response);
    if (event.status == 200) then
        GamedoniaDataCreate.target(true, json.decode(event.response))
    else
        GamedoniaDataCreate.target(false)
    end
end

GamedoniaDataCreate.onRequestFailed = function(event)
    print ("GamedoniaDataCreate.onRequestFailed")
    --    printResponseLog(response);
    GamedoniaDataCreate.target(false)
end

lib.create = function(collection, entity, callback)
    GamedoniaDataCreate.target = callback
    local dataJson = json.encode(entity)
    local path = "/data/"..collection.."/create"
    --	print ("GamedoniaData.Create:\n\turl: "..path.."\n\tjson: "..dataJson)
    GamedoniaRequest.post(path, dataJson, nil, GamedoniaSDKUser.sessionToken, nil, GamedoniaDataCreate.listener)
end


------------------
-- Delete
------------------
local GamedoniaDataDelete = {}

GamedoniaDataDelete.listener = function(event)
    print("GamedoniaDataDelete - status: "..event.status)
    if ( event.isError ) then
        GamedoniaDataDelete.onRequestFail(event)
    else
        GamedoniaDataDelete.onRequestCompleted(event)
    end
end

GamedoniaDataDelete.onRequestCompleted = function(event)
    --    printResponseLog(response);  
    if (event.status == 200) then
        GamedoniaDataDelete.target(true)
    else
        GamedoniaDataDelete.target(false)
    end
end

GamedoniaDataDelete.onRequestFailed = function(event)
    --    printResponseLog(response);
    GamedoniaDataDelete.target(false)
end

lib.delete = function(collection, entityId, callback)
    GamedoniaDataDelete.target = callback
    local path = "/data/"..collection.."/delete/"..entityId
    GamedoniaRequest.delete(path, GamedoniaDataDelete.listener)
end


------------------
-- Update
------------------
local GamedoniaDataUpdate = {}

GamedoniaDataUpdate.listener = function(event)
    print("GamedoniaDataUpdate - status: "..event.status)
    if ( event.isError ) then
        GamedoniaDataUpdate.onRequestFail(event)
    else
        GamedoniaDataUpdate.onRequestCompleted(event)
    end
end

GamedoniaDataUpdate.onRequestCompleted = function(event)
    if (event.status == 200) then
        GamedoniaDataUpdate.target(true, json.decode(event.response))
    else
        GamedoniaDataUpdate.target(false)
    end
end

GamedoniaDataUpdate.onRequestFailed = function(event)
    --    printResponseLog(response);
    GamedoniaDataUpdate.target(false)
end

lib.update = function(collection, entity, callback, overwrite)
    if not overwrite then
        overwrite = false
    end
    GamedoniaDataUpdate.target = callback
    local dataJson = json.encode(entity)
    local path = "/data/"..collection.."/update"
    if overwrite then
    	GamedoniaRequest.put(path, dataJson, nil, GamedoniaSDKUser.sessionToken, nil, GamedoniaDataUpdate.listener)
    else
    	GamedoniaRequest.post(path, dataJson, nil, GamedoniaSDKUser.sessionToken, nil, GamedoniaDataUpdate.listener)
    end
end


------------------
-- Search
------------------
local GamedoniaDataSearch = {}

GamedoniaDataSearch.listener = function(event)
    --print("GamedoniaDataSearch - status: "..event.status)
    if ( event.isError ) then
        GamedoniaDataSearch.onRequestFail(event)
    else
        GamedoniaDataSearch.onRequestCompleted(event)
    end
end

GamedoniaDataSearch.onRequestCompleted = function(event)
    --    print ("GamedoniaDataSearch.onRequestCompleted - event.response: "..event.response)
    if (event.status == 200) then
        GamedoniaDataSearch.target(true, json.decode(event.response))
    else
        GamedoniaDataSearch.target(false, event.status)
    end
end

GamedoniaDataSearch.onRequestFailed = function(event)
    --    printResponseLog(response);
    GamedoniaDataSearch.target(false)
end

lib.search = function(collection, query, callback, timeOut, limit, sort, skip)
    GamedoniaDataSearch.target = callback
    if not limit then
        limit = 0
    end
    if not skip then
        skip = 0
    end
    
    query = url.escape(query)
    local path = "/data/"..collection.."/search"
    local query = "query="..query
    if (limit > 0) then
        query = query.."&limit="..limit
    end
    if (sort ~= null) then
        query = query.."&sort="..sort
    end
    if (skip > 0) then
        query = query.."&skip="..skip
    end
    
    --	print("query: "..query)
    --	GamedoniaUserDefault.debug()
    --	print("GamedoniaSDKUser.sessionToken: "..GamedoniaSDKUser.sessionToken)
    GamedoniaRequest.get(path, query, GamedoniaSDKUser.sessionToken, GamedoniaDataSearch.listener, timeOut)
end


-- Return lib instead of using 'module()' which pollutes the global namespace
return lib
