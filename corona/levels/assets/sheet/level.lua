--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:2d986cd2e22b55cf97c6411f3516a6e6:e884c85b1bb913dcccf346af90165fb9:ed4d60969c44e63128a340413e4b7c07$
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
            -- alert shop
            x=82,
            y=239,
            width=31,
            height=20,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 33,
            sourceHeight = 22
        },
        {
            -- boton shop
            x=132,
            y=286,
            width=70,
            height=66,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 72,
            sourceHeight = 68
        },
        {
            -- boton slotmachine
            x=2,
            y=136,
            width=129,
            height=101,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 129,
            sourceHeight = 103
        },
        {
            -- corazon
            x=133,
            y=159,
            width=117,
            height=52,

        },
        {
            -- flecha
            x=133,
            y=213,
            width=104,
            height=71,

            sourceX = 2,
            sourceY = 2,
            sourceWidth = 108,
            sourceHeight = 73
        },
        {
            -- hueso
            x=232,
            y=104,
            width=20,
            height=22,

        },
        {
            -- level selector block
            x=2,
            y=239,
            width=78,
            height=79,

            sourceX = 54,
            sourceY = 33,
            sourceWidth = 188,
            sourceHeight = 151
        },
        {
            -- level selector clean
            x=152,
            y=73,
            width=78,
            height=79,

            sourceX = 54,
            sourceY = 33,
            sourceWidth = 188,
            sourceHeight = 151
        },
        {
            -- luces
            x=160,
            y=43,
            width=89,
            height=28,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 91,
            sourceHeight = 28
        },
        {
            -- monedas
            x=2,
            y=2,
            width=156,
            height=59,

        },
        {
            -- pergamino
            x=2,
            y=63,
            width=148,
            height=71,

            sourceX = 18,
            sourceY = 72,
            sourceWidth = 188,
            sourceHeight = 151
        },
        {
            -- slot_crono
            x=160,
            y=2,
            width=91,
            height=39,

        },
        {
            -- slot_rueda_01
            x=232,
            y=73,
            width=21,
            height=29,

            sourceX = 3,
            sourceY = 0,
            sourceWidth = 29,
            sourceHeight = 29
        },
        {
            -- slot_rueda_02
            x=107,
            y=261,
            width=23,
            height=29,

            sourceX = 3,
            sourceY = 0,
            sourceWidth = 29,
            sourceHeight = 29
        },
        {
            -- slot_rueda_03
            x=232,
            y=128,
            width=19,
            height=29,

            sourceX = 4,
            sourceY = 0,
            sourceWidth = 29,
            sourceHeight = 29
        },
        {
            -- slot_rueda_04
            x=82,
            y=261,
            width=23,
            height=29,

            sourceX = 3,
            sourceY = 0,
            sourceWidth = 29,
            sourceHeight = 29
        },
    },
    
    sheetContentWidth = 256,
    sheetContentHeight = 512
}

SheetInfo.frameIndex =
{

    ["alert_shop"] = 1,
    ["boton_shop"] = 2,
    ["boton_slotmachine"] = 3,
    ["corazon"] = 4,
    ["flecha"] = 5,
    ["hueso"] = 6,
    ["level_selector_block"] = 7,
    ["level_selector_clean"] = 8,
    ["luces"] = 9,
    ["monedas"] = 10,
    ["pergamino"] = 11,
    ["slot_crono"] = 12,
    ["slot_rueda_01"] = 13,
    ["slot_rueda_02"] = 14,
    ["slot_rueda_03"] = 15,
    ["slot_rueda_04"] = 16,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
