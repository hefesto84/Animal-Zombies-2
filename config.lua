
application =
{
	content =
	{
		fps = 60,
		scale = "letterBox",
		xAlign = "center",
		yAlign = "center",
		--[[imageSuffix = 
		{
			["@2x"] = 1.5,
			["@4x"] = 3.0,
		},]]
		notification = { iphone = { types = { "badge", "sound", "alert" } } }
	},
	license = { google = { key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkbjBK7+3Gl5FNBlQ3PQ2FxLPGIBt8mPKHJL1VdhmUEHb/eOsWNLkfoEAWcBE1vpwAjrA+Hcsy2HuhKVJA5me85VflDwrwnmaIuOCtMtDMbE8HIIWPtevChAUmD93v8Vgsrhw0yCvvWDI/w/GnxuHEQBldUEEK6Q6z+LwFdMJmURu6Ys2TmEiNwDbZeeFBzmvN5mg4cKeJJOa8QxhKhePC+i7zo/NkYlwkfJxyZEbXhkjgQHZfF5gPbSnx+XzK/+KL5HzTKmOyCr7QKx/1bPFvGgs+hGE0cUDE+Nu3nAiHZv8qmADB+BB/pHCce2U2EsgujDFlPBPfYRLqvaHokKynQIDAQAB" } }
}

local model = system.getInfo("model")

-- iPads
if string.sub(model,1,4) == "iPad" then
	application.content.width = 360
	application.content.height = 480

-- iPhone 5
elseif string.sub(model,1,2) == "iP" and display.pixelHeight > 960 then
	application.content.width = 320
	application.content.height = 568
	
-- iPhone <5
elseif string.sub(model,1,2) == "iP" then
	application.content.width = 320
	application.content.height = 480
	
-- samsung s3 resolution androids
elseif display.pixelHeight == 1280 and display.pixelWidth == 720 then
	application.content.width = 480
	application.content.height = 855
	
-- wide screen androids
elseif display.pixelHeight / display.pixelWidth > 1.72 then
	application.content.width = 480
	application.content.height = 854

-- other androids
else
	application.content.width = 480
	application.content.height = 800
end