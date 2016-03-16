--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:51c6a9b94e637501dfab63fe869eac14:e03b460f631ff0559cba774ec24ec9f9:8f3585f1f5bf134e41b8e945113b9247$
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
            -- Arbusto
            x=387,
            y=101,
            width=100,
            height=100,

        },
        {
            -- Arbusto2
            x=387,
            y=0,
            width=100,
            height=100,

        },
        {
            -- Arbusto3
            x=101,
            y=387,
            width=100,
            height=100,

        },
        {
            -- Hoguera
            x=0,
            y=387,
            width=100,
            height=100,

        },
        {
            -- Leña
            x=359,
            y=359,
            width=100,
            height=100,

        },
        {
            -- Tocon
            x=359,
            y=258,
            width=100,
            height=100,

        },
        {
            -- Totem
            x=258,
            y=359,
            width=100,
            height=100,

        },
        {
            -- Tronco
            x=258,
            y=258,
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

    ["Arbusto"] = 1,
    ["Arbusto2"] = 2,
    ["Arbusto3"] = 3,
    ["Hoguera"] = 4,
    ["Leña"] = 5,
    ["Tocon"] = 6,
    ["Totem"] = 7,
    ["Tronco"] = 8,
    ["prop_d"] = 9,
    ["prop_l"] = 10,
    ["prop_ld"] = 11,
    ["prop_lu"] = 12,
    ["prop_r"] = 13,
    ["prop_rd"] = 14,
    ["prop_ru"] = 15,
    ["prop_u"] = 16,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
