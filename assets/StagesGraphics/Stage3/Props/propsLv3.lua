--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:8473346db6c751244e21a821acdc8248:44b66e452d5fc8376f09bf1dba01a6d5:42090d48bfc43d8f25b13a173a897f0d$
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
            -- barbacoa
            x=387,
            y=101,
            width=100,
            height=100,

        },
        {
            -- caseta
            x=387,
            y=0,
            width=100,
            height=100,

        },
        {
            -- cubo
            x=404,
            y=359,
            width=100,
            height=100,

        },
        {
            -- cubo1
            x=359,
            y=258,
            width=100,
            height=100,

        },
        {
            -- cubo2
            x=303,
            y=359,
            width=100,
            height=100,

        },
        {
            -- planta1
            x=258,
            y=258,
            width=100,
            height=100,

        },
        {
            -- planta2
            x=202,
            y=387,
            width=100,
            height=100,

        },
        {
            -- prop_d
            x=258,
            y=129,
            width=128,
            height=128,

        },
        {
            -- prop_l
            x=258,
            y=0,
            width=128,
            height=128,

        },
        {
            -- prop_ld
            x=129,
            y=258,
            width=128,
            height=128,

        },
        {
            -- prop_lu
            x=129,
            y=129,
            width=128,
            height=128,

        },
        {
            -- prop_r
            x=129,
            y=0,
            width=128,
            height=128,

        },
        {
            -- prop_rd
            x=0,
            y=258,
            width=128,
            height=128,

        },
        {
            -- prop_ru
            x=0,
            y=129,
            width=128,
            height=128,

        },
        {
            -- prop_u
            x=0,
            y=0,
            width=128,
            height=128,

        },
        {
            -- rueda
            x=101,
            y=387,
            width=100,
            height=100,

        },
        {
            -- silla
            x=0,
            y=387,
            width=100,
            height=100,

        },
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 512
}

SheetInfo.frameIndex =
{

    ["barbacoa"] = 1,
    ["caseta"] = 2,
    ["cubo"] = 3,
    ["cubo1"] = 4,
    ["cubo2"] = 5,
    ["planta1"] = 6,
    ["planta2"] = 7,
    ["prop_d"] = 8,
    ["prop_l"] = 9,
    ["prop_ld"] = 10,
    ["prop_lu"] = 11,
    ["prop_r"] = 12,
    ["prop_rd"] = 13,
    ["prop_ru"] = 14,
    ["prop_u"] = 15,
    ["rueda"] = 16,
    ["silla"] = 17,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
