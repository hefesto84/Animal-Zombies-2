--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:c196cad94de00b779885246c40a824d4:81dd4ddc094ebd6efc9c559f549b8f9f:88294c61a4a97a0bd76ca560ca6ae9eb$
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
            -- gato
            x=387,
            y=101,
            width=100,
            height=100,

        },
        {
            -- jarron
            x=387,
            y=0,
            width=100,
            height=100,

        },
        {
            -- lapida1
            x=404,
            y=359,
            width=100,
            height=100,

        },
        {
            -- lapida2
            x=359,
            y=258,
            width=100,
            height=100,

        },
        {
            -- lapida3
            x=303,
            y=359,
            width=100,
            height=100,

        },
        {
            -- lapida4
            x=258,
            y=258,
            width=100,
            height=100,

        },
        {
            -- lapida5
            x=202,
            y=387,
            width=100,
            height=100,

        },
        {
            -- perro
            x=101,
            y=387,
            width=100,
            height=100,

        },
        {
            -- pez
            x=0,
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
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 512
}

SheetInfo.frameIndex =
{

    ["gato"] = 1,
    ["jarron"] = 2,
    ["lapida1"] = 3,
    ["lapida2"] = 4,
    ["lapida3"] = 5,
    ["lapida4"] = 6,
    ["lapida5"] = 7,
    ["perro"] = 8,
    ["pez"] = 9,
    ["prop_d"] = 10,
    ["prop_l"] = 11,
    ["prop_ld"] = 12,
    ["prop_lu"] = 13,
    ["prop_r"] = 14,
    ["prop_rd"] = 15,
    ["prop_ru"] = 16,
    ["prop_u"] = 17,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

function SheetInfo:getRandom1x1Index()
    print(#self.frameIndex);
    return math.random(9);
end

return SheetInfo
