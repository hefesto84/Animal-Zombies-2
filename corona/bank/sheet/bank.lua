--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:10f20173bb69bae68c0f0fcf47b2e34c:fa92563053f57c3f4d402fa6dd406001:77a56fd8637e333104fba7ccbc960844$
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
            x=476,
            y=383,
            width=31,
            height=20,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 33,
            sourceHeight = 22
        },
        {
            -- bolsa
            x=372,
            y=173,
            width=139,
            height=95,

            sourceX = 23,
            sourceY = 32,
            sourceWidth = 185,
            sourceHeight = 137
        },
        {
            -- boton shop
            x=424,
            y=735,
            width=70,
            height=66,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 72,
            sourceHeight = 68
        },
        {
            -- boton
            x=0,
            y=0,
            width=373,
            height=148,

            sourceX = 5,
            sourceY = 1,
            sourceWidth = 383,
            sourceHeight = 150
        },
        {
            -- boton_press
            x=0,
            y=149,
            width=371,
            height=148,

            sourceX = 6,
            sourceY = 0,
            sourceWidth = 383,
            sourceHeight = 150
        },
        {
            -- boton_sombra
            x=0,
            y=298,
            width=371,
            height=147,

            sourceX = 8,
            sourceY = 1,
            sourceWidth = 387,
            sourceHeight = 151
        },
        {
            -- brillo1
            x=372,
            y=383,
            width=103,
            height=103,

            sourceX = 11,
            sourceY = 11,
            sourceWidth = 125,
            sourceHeight = 125
        },
        {
            -- brillo2
            x=372,
            y=269,
            width=113,
            height=113,

            sourceX = 5,
            sourceY = 5,
            sourceWidth = 125,
            sourceHeight = 125
        },
        {
            -- brillo_pq
            x=0,
            y=446,
            width=200,
            height=214,

            sourceX = 14,
            sourceY = 6,
            sourceWidth = 226,
            sourceHeight = 226
        },
        {
            -- caja fuerte
            x=347,
            y=609,
            width=143,
            height=125,

            sourceX = 6,
            sourceY = 11,
            sourceWidth = 185,
            sourceHeight = 137
        },
        {
            -- cerrar
            x=424,
            y=802,
            width=42,
            height=44,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 46,
            sourceHeight = 46
        },
        {
            -- cofre
            x=201,
            y=506,
            width=145,
            height=115,

            sourceX = 22,
            sourceY = 15,
            sourceWidth = 185,
            sourceHeight = 137
        },
        {
            -- corazon
            x=374,
            y=120,
            width=117,
            height=52,

        },
        {
            -- facebook
            x=374,
            y=0,
            width=131,
            height=119,

            sourceX = 24,
            sourceY = 18,
            sourceWidth = 185,
            sourceHeight = 137
        },
        {
            -- ic_moneda
            x=343,
            y=735,
            width=80,
            height=80,

        },
        {
            -- maleta
            x=358,
            y=487,
            width=147,
            height=121,

            sourceX = 16,
            sourceY = 9,
            sourceWidth = 185,
            sourceHeight = 137
        },
        {
            -- monedas
            x=201,
            y=446,
            width=156,
            height=59,

        },
        {
            -- saco
            x=201,
            y=622,
            width=141,
            height=119,

            sourceX = 36,
            sourceY = 7,
            sourceWidth = 185,
            sourceHeight = 137
        },
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 1024
}

SheetInfo.frameIndex =
{

    ["alert_shop"] = 1,
    ["bag"] = 2,
    ["boton_shop"] = 3,
    ["boton"] = 4,
    ["boton_press"] = 5,
    ["boton_sombra"] = 6,
    ["brillo1"] = 7,
    ["brillo2"] = 8,
    ["brillo_pq"] = 9,
    ["safe"] = 10,
    ["cerrar"] = 11,
    ["chest"] = 12,
    ["corazon"] = 13,
    ["facebook"] = 14,
    ["ic_moneda"] = 15,
    ["briefcase"] = 16,
    ["coin"] = 17,
    ["sack"] = 18,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
