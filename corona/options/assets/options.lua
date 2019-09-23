--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:443609dadd6ee91f6890030f65d42b41:bf97f2d20ca5b210730251a9e7684834:8ea76534897fb16fcd882426903338f2$
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
            -- bot_idioma
            x=0,
            y=75,
            width=180,
            height=74,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 179,
            sourceHeight = 74
        },
        {
            -- bot_reset
            x=0,
            y=0,
            width=180,
            height=74,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 179,
            sourceHeight = 74
        },
        {
            -- exit
            x=41,
            y=150,
            width=106,
            height=72,

            sourceX = 0,
            sourceY = 2,
            sourceWidth = 108,
            sourceHeight = 73
        },
        {
            -- musica on
            x=181,
            y=146,
            width=74,
            height=72,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 73,
            sourceHeight = 72
        },
        {
            -- off
            x=0,
            y=219,
            width=40,
            height=6,

            sourceX = 16,
            sourceY = 26,
            sourceWidth = 73,
            sourceHeight = 72
        },
        {
            -- sonido on
            x=181,
            y=73,
            width=74,
            height=72,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 73,
            sourceHeight = 72
        },
        {
            -- vibracion on
            x=181,
            y=0,
            width=74,
            height=72,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 73,
            sourceHeight = 72
        },
    },
    
    sheetContentWidth = 256,
    sheetContentHeight = 256
}

SheetInfo.frameIndex =
{

    ["bot_idioma"] = 1,
    ["bot_reset"] = 2,
    ["exit"] = 3,
    ["musica on"] = 4,
    ["off"] = 5,
    ["sonido on"] = 6,
    ["vibracion on"] = 7,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
