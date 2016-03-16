
local fb = {}

fb._fb = require "facebook"
fb.appID = "1451463131760806"

fb.isLogged = false

-- callbacks
fb.loginCallback = nil
fb.postCallback = nil
fb.shareCallback = nil


local function doCallback(callback, ...)
	if callback then
		callback(...)
	end
	return nil
end

local function fbCallback(event)
	--[[if event.isError then
		AZ.utils.print(event, "fbError")
		return
	end]]
	
	AZ.utils.print(event, "fbEvent")
	
	if event.type == "session" then
		
		fb.isLogged = event.phase == "login"
		
		if fb.isLogged then
			AZ.userInfo.fbToken = event.token
		else
			AZ.userInfo.fbID = nil
		end
		
		fb.loginCallback = doCallback(fb.loginCallback, fb.isLogged)
		
	elseif event.type == "dialog" then
		
		local success = not event.isError
		if success then
			success = type(string.find(event.response, "post_id")) == "number"
		end
		
		fb.shareCallback = doCallback(fb.shareCallback, success)
		fb.postCallback = doCallback(fb.postCallback, success)
		
	elseif event.type == "request" then
		
		AZ.userInfo.fbID = AZ.jsonIO._json.decode(event.response).id
		
		fb.loginCallback = doCallback(fb.loginCallback, true)
		
	else
		AZ.utils.print(event, "other fb event type")
	end
end

function fb:login(callback)
	fb.loginCallback = callback
	fb._fb.login(fb.appID, fbCallback)
end

function fb:shareToFriends(callback)
	
	fb.shareCallback = callback
	
	local function share(isLogged)
		if isLogged then
			
			fb._fb.showDialog("apprequests", { message = "dani gay" })
			
		else
			print("no hi ha connexio per a fer share als amics")
			fb.shareCallback = doCallback(fb.shareCallback, false)
		end
	end
	
	if fb.isLogged then
		share(true)
	else
		fb:login(share)
	end
end

function fb:postMessage(callback)
	
	fb.postCallback = callback
	
	local function postMessage(isLogged)
		if isLogged then
			
			local params = {
				name = "Animal Zombies",
				link = "http://www.codiwans.com/animalzombies/AnimalZombiesRedirectToStores.html",
				description = AZ.utils.translate("fb_caption") .." desc",
				message = AZ.utils.translate("fb_caption") .." msg",
				picture = "https://pbs.twimg.com/profile_images/1217408987/icono_codiwans.png"
			}
			
			--fb._fb.request("me/feed", "POST", params)
			fb._fb.showDialog("feed", params)
			
			print("hem cridat")
		else
			print("no hi ha connexio per a fer post a fb")
			fb.postCallback = doCallback(fb.postCallback, false)
		end
	end
	
	if fb.isLogged then
		postMessage(true)
	else
		fb:login(postMessage)
	end
end

return fb