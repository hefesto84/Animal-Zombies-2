
local pName = system.getInfo("platformName")

if pName == "Android" or pName == "Win" then
    
    local udid = {}
    
    function udid.getValue()
        return system.getInfo("deviceID")
    end
    
    return udid
else
    return require "plugin.openudid"
end