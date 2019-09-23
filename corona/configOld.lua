
local model = system.getInfo("model")

--iPads
if string.sub(model,1,4) == "iPad" then
    application = 
    {
        content =
        {
            --graphicsCompatibility = 1,
            fps = 60,
            width = 360,
            height = 480,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }
--iPhone 5
elseif string.sub(model,1,2) == "iP" and display.pixelHeight > 960 then
    application = 
    {
        content =
        {
            ---graphicsCompatibility = 1,
            fps = 60,
            width = 320,
            height = 568,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }
--iPhone <5
elseif string.sub(model,1,2) == "iP" then
    application = 
    {
        content =
        {
            --graphicsCompatibility = 1,
            fps = 60,
            width = 320,
            height = 480,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }
--resolucio del s3
elseif display.pixelHeight == 1280 and display.pixelWidth == 720 then
    application = 
    {
        content =
        {
            --graphicsCompatibility = 1,
            fps = 60,
            width = 480,
            height = 855,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
    }
--androids pantalla llarga
elseif display.pixelHeight / display.pixelWidth > 1.72 then
    application = 
    {
        content =
        {
            --graphicsCompatibility = 1,
            fps = 60,
            width = 480,
            height = 854,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
    }
--altres
else
    application = 
    {
        content =
        {
            --graphicsCompatibility = 1,
            fps = 60,
            width = 480,
            height = 800,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }
end
