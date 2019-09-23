--
-- created with TexturePacker (http://www.texturepacker.com)
--
-- $TexturePacker:SmartUpdate:5c6791d7650f9d08f7648096e1ec98cb$
--
-- local sheetInfo = require("myExportedImageSheet") -- lua file that Texture packer published
--
-- local myImageSheet = graphics.newImageSheet( "ImageSheet.png", sheetInfo:getSheet() ) -- ImageSheet.png is the image Texture packer published
--
-- local myImage1 = display.newImage( myImageSheet , sheetInfo:getFrameIndex("image_name1"))
-- local myImage2 = display.newImage( myImageSheet , sheetInfo:getFrameIndex("image_name2"))
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- alert shop
            x=201,
            y=0,
            width=31,
            height=20,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 33,
            sourceHeight = 22
        },
        {
            -- boton retry
            x=105,
            y=0,
            width=95,
            height=75,

            sourceX = 2,
            sourceY = 2,
            sourceWidth = 101,
            sourceHeight = 81
        },
        {
            -- boton shop
            x=0,
            y=70,
            width=70,
            height=66,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 72,
            sourceHeight = 68
        },
        {
            -- corazon
            x=0,
            y=137,
            width=64,
            height=60,

            sourceX = 5,
            sourceY = 4,
            sourceWidth = 74,
            sourceHeight = 70
        },
        {
            -- flecha levels
            x=0,
            y=0,
            width=104,
            height=69,

            sourceX = 1,
            sourceY = 3,
            sourceWidth = 108,
            sourceHeight = 73
        },
        {
            -- separador_vert
            x=233,
            y=0,
            width=2,
            height=76,

        },
        {
            -- vidas plus
            x=201,
            y=48,
            width=26,
            height=26,

            sourceX = 0,
            sourceY = 3,
            sourceWidth = 26,
            sourceHeight = 32
        },
        {
            -- vidas plus_press
            x=201,
            y=21,
            width=26,
            height=26,

            sourceX = 0,
            sourceY = 3,
            sourceWidth = 26,
            sourceHeight = 32
        },
    },
    
    sheetContentWidth = 256,
    sheetContentHeight = 256
}

SheetInfo.frameIndex =
{

    ["alert_shop"] = 1,
    ["boton_retry"] = 2,
    ["boton_shop"] = 3,
    ["corazon"] = 4,
    ["flecha_levels"] = 5,
    ["separador_vert"] = 6,
    ["vidas_plus"] = 7,
    ["vidas_plus_press"] = 8,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
