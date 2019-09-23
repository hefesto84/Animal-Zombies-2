--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:192b3bde232f77d7c89d915c6b02c1b2:f11225166d9b04aa4163da28d44de1ef:dfc94d5501f209a54bfd677380a2d95b$
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
            y=0,
            width=128,
            height=128,

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
    ["hielo"] = 2,
    ["manguera"] = 3,
    ["piedra"] = 4,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
