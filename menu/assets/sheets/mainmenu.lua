--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:cd9d0b76abdd956c7cf1a04c1cde64dc:a94657a5ad4ef816b4f652b1c906b940:e02ae266594c7f506f77f38f6ba46db7$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- boton_facebook
            x=149,
            y=0,
            width=58,
            height=58,

        },
        {
            -- boton_twitter
            x=149,
            y=59,
            width=58,
            height=57,

        },
        {
            -- configure neg
            x=346,
            y=0,
            width=68,
            height=48,

        },
        {
            -- configure
            x=218,
            y=196,
            width=68,
            height=48,

        },
        {
            -- copa_neg
            x=218,
            y=147,
            width=68,
            height=48,

        },
        {
            -- copa_pos
            x=277,
            y=49,
            width=68,
            height=48,

        },
        {
            -- game_google_neg
            x=277,
            y=0,
            width=68,
            height=48,

        },
        {
            -- game_google_pos
            x=218,
            y=98,
            width=68,
            height=48,

        },
        {
            -- game_ios_neg
            x=208,
            y=49,
            width=68,
            height=48,

        },
        {
            -- game_ios_pos
            x=208,
            y=0,
            width=68,
            height=48,

        },
        {
            -- garra
            x=0,
            y=0,
            width=148,
            height=234,

        },
        {
            -- info neg
            x=149,
            y=166,
            width=68,
            height=48,

        },
        {
            -- info
            x=149,
            y=117,
            width=68,
            height=48,

        },
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 256
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
    ["garra"] = 11,
    ["info neg"] = 12,
    ["info"] = 13,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
