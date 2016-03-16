---------------------
-----
-- Gamedonia User Default
-----
---------------------

local Library = require "CoronaLibrary"
local lib = Library:new{ name='controller.gamedonia.plugin.GamedoniaUserDefault', publisherId='com.Gamedonia' }

local json = require "json"

local JSON_FILE_NAME = "gdUserDefault.json"

lib.values = {}

lib.loadFile = function(base)
    -- set default base dir if none specified
    if not base then 
        base = system.DocumentsDirectory 
    end

    -- create a file path for corona i/o
    local path = system.pathForFile(JSON_FILE_NAME, base)
--	print ("Gameuserdefault.loadfile - path: "..path)
    -- will hold contents of file
    local content

    -- io.open opens a file at path. returns nil if no file found
    local file = io.open(path, "r")
    if file then
--    	print("Gamedonia.userdefault - file opened")
        -- read all contents of file into a string
        content = file:read( "*a" )
        if content ~= nil then
            lib.values = json.decode(content)
        end
        io.close(file) -- close the file after using it
--        lib.debug()
    else
    	print("Gamedonia.userdefault - no file opened")
    end
end

lib.saveFile = function(base)
    -- set default base dir if none specified
    if not base then 
        base = system.DocumentsDirectory 
    end

    -- create a file path for corona i/o
    local path = system.pathForFile(JSON_FILE_NAME, base)

    -- io.open opens a file at path. returns nil if no file found
    local file = io.open(path, "w+")
    if file then
--    	print("Gamedonia.userdefault - File saved")
--    	lib.debug()
        -- write all contents of file into a string
        file:write(json.encode(lib.values))
        io.close(file) -- close the file after using it
    else
    	print("Gamedonia.userdefault - no file saved")
    end
end

lib.setValue = function(key, value)
    lib.values[key] = value
end

lib.getValue = function(key)
    return lib.values[key]
end

lib.flush = function()
    lib.saveFile()
end

lib.debug = function()
	print ("GamedoniaUserDefault.values - debug")
	for key,value in pairs(lib.values) do print(key,value) end
end

lib.loadFile()


-- Return lib instead of using 'module()' which pollutes the global namespace
return lib
