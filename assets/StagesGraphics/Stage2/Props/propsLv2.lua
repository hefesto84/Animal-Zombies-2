--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:bc0ea381264b11a9d8acafa54b6f1594:025147f6d62fdbe7c205686540919990:790a3719be956946760f12ab346f64e9$
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
            -- Banderas
            x=404,
            y=359,
            width=100,
            height=100,

        },
        {
            -- Cartel Cakes
            x=359,
            y=258,
            width=100,
            height=100,

        },
        {
            -- Cartel popcorn
            x=303,
            y=359,
            width=100,
            height=100,

        },
        {
            -- Globos
            x=258,
            y=258,
            width=100,
            height=100,

        },
        {
            -- Papelera
            x=202,
            y=387,
            width=100,
            height=100,

        },
        {
            -- Papelera2
            x=101,
            y=387,
            width=100,
            height=100,

        },
        {
            -- Sacos
            x=0,
            y=387,
            width=100,
            height=100,

        },
        {
            -- prop_d
            x=303,
            y=129,
            width=128,
            height=128,

        },
        {
            -- prop_l
            x=129,
            y=258,
            width=128,
            height=128,

        },
        {
            -- prop_ld
            x=129,
            y=129,
            width=128,
            height=128,

        },
        {
            -- prop_lu
            x=331,
            y=0,
            width=128,
            height=128,

        },
        {
            -- prop_r
            x=202,
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
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 512
}

SheetInfo.frameIndex =
{

    ["Banderas"] = 1,
    ["Cartel Cakes"] = 2,
    ["Cartel popcorn"] = 3,
    ["Globos"] = 4,
    ["Papelera"] = 5,
    ["Papelera2"] = 6,
    ["Sacos"] = 7,
    ["prop_d"] = 8,
    ["prop_l"] = 9,
    ["prop_ld"] = 10,
    ["prop_lu"] = 11,
    ["prop_r"] = 12,
    ["prop_rd"] = 13,
    ["prop_ru"] = 14,
    ["prop_u"] = 15,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
