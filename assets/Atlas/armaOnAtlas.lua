--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:4e16b42f6068f49e2292406ed4ac0d8e:73c7c18e04298b44baf91d98ca937865:dfc94d5501f209a54bfd677380a2d95b$
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
            -- caca paloma
            x=129,
            y=129,
            width=128,
            height=128,

        },
        {
            -- caseta buena
            x=258,
            y=0,
            width=128,
            height=128,

        },
        {
            -- caseta explosiva
            x=129,
            y=0,
            width=128,
            height=128,

        },
        {
            -- esfera_num_S
            x=0,
            y=387,
            width=23,
            height=23,

        },
        {
            -- hielo
            x=0,
            y=258,
            width=128,
            height=128,

        },
        {
            -- manguera
            x=0,
            y=129,
            width=128,
            height=128,

        },
        {
            -- piedra
            x=0,
            y=0,
            width=128,
            height=128,

        },
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 512
}

SheetInfo.frameIndex =
{

    ["caca paloma"] = 1,
    ["caseta buena"] = 2,
    ["caseta explosiva"] = 3,
    ["esfera_num_S"] = 4,
    ["hielo"] = 5,
    ["manguera"] = 6,
    ["piedra"] = 7,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
