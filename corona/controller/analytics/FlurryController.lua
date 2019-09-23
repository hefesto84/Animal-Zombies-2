local middleclass = require 'middleclass'



local active = false

FlurryController = class('Singleton')
Singleton = FlurryController()

FlurryController._lFlurryId = ""

FlurryController.messagesArray = {}
FlurryController.arrayLength = 15

local index = 1

function FlurryController:initialize()
    
    if not active then return end
    
    local analytics = require "analytics"
    
    local FlurryId = "KMN22M96T66KZ4DMD99Y"
    if system.getInfo("platformName") == "iPhone OS" then
        FlurryId = "5C6YWG4J594VWJDFZJ39"
    end
    
    if AZ.isTest then
        FlurryId = "MS95N3VH8HBMKDV6VWJX"
    end
    
    FlurryController._lFlurryId = FlurryId
    analytics.init(FlurryController._lFlurryId)
    print("--FlurryController instantiated with: "..FlurryController._lFlurryId.." ID")
end

local function printDebugEvent(myEvent)
    if not active then return end
    local message = myEvent.myMessage
    
    if myEvent.myParams ~= nil then
        for key, value in pairs(myEvent.myParams) do
            message = message ..", ".. tostring(key) ..": ".. tostring(value)
        end
    end
            
    print("*FlurryEvent*: ".. message)
end

local function sendEvent(index)
    if not active then return end
    --if (AZ.utils.testConnection(false) == true) then
        local myEvent = FlurryController.messagesArray[index]
        
        if AZ.isTest then
            printDebugEvent(myEvent)
        end
        
        analytics.logEvent(myEvent.myMessage, myEvent.myParams)
        
    --else
    --    print("No hi ha connexió")
    --end
    
    --coroutine.yield()
end

local sender = coroutine.create(sendEvent)

function FlurryController:forceSend()
    if not active then return end
    for i=1, #FlurryController.messagesArray do
        coroutine.resume(sender)
        sendEvent(i)
    end
    
    --FlurryController.messagesArray = {}
end

function FlurryController:logEvent(event, params)
    if not active then return end
    local array = FlurryController.messagesArray
    
    array[#array +1] = { myMessage = event, myParams = params }
    
    if #array >= FlurryController.arrayLength then
        FlurryController:forceSend()
    end
end
