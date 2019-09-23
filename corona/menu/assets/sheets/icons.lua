--
-- created with TexturePacker (http://www.texturepacker.com)
--
-- $TexturePacker:SmartUpdate:a62cb729aca97799c14161d10b325e2c$
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
            -- boton_facebook
            x=72,
            y=52,
            width=58,
            height=58,

        },
        {
            -- boton_twitter
            x=2,
            y=2,
            width=58,
            height=58,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 58,
            sourceHeight = 57
        },
        {
            -- configure neg
            x=72,
            y=162,
            width=68,
            height=48,

        },
        {
            -- configure
            x=2,
            y=162,
            width=68,
            height=48,

        },
        {
            -- copa_neg
            x=142,
            y=152,
            width=68,
            height=48,

        },
        {
            -- copa_pos
            x=142,
            y=102,
            width=68,
            height=48,

        },
        {
            -- game_google_neg
            x=132,
            y=52,
            width=68,
            height=48,

        },
        {
            -- game_google_pos
            x=132,
            y=2,
            width=68,
            height=48,

        },
        {
            -- game_ios_neg
            x=72,
            y=112,
            width=68,
            height=48,

        },
        {
            -- game_ios_pos
            x=2,
            y=112,
            width=68,
            height=48,

        },
        {
            -- info neg
            x=62,
            y=2,
            width=68,
            height=48,

        },
        {
            -- info
            x=2,
            y=62,
            width=68,
            height=48,

        },
    },
    
    sheetContentWidth = 212,
    sheetContentHeight = 212
}

SheetInfo.frameIndex =
{

    ["boton_facebook"] = 1,
    ["boton_twitter"] = 2,
    ["configure neg"] = 3,
    ["configure"] = 4,
    ["copa_neg"] = 5,
    ["copa_pos"] = 6,
    ["game_google_neg"] = 7,
    ["game_google_pos"] = 8,
    ["game_ios_neg"] = 9,
    ["game_ios_pos"] = 10,
    ["info neg"] = 11,
    ["info"] = 12,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
