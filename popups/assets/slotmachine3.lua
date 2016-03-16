--
-- created with TexturePacker (http://www.texturepacker.com)
--
-- $TexturePacker:SmartUpdate:bf2bda7d188d6e446e3ab99c552c5ad4$
--
-- local sheetInfo = require("myExportedImageSheet") -- lua file that Texture packer published
--
-- local myImageSheet = graphics.newImageSheet( "ImageSheet.png", sheetInfo:getSheet() ) -- ImageSheet.png is the image Texture packer published
--
-- local myImage1 = display.newImage( myImageSheet , sheetInfo:getFrameIndex("image_name1"))
-- local myImage2 = display.newImage( myImageSheet , sheetInfo:getFrameIndex("image_name2"))
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- cerrar
            x=525,
            y=0,
            width=42,
            height=44,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 46,
            sourceHeight = 46
        },
        {
            -- claudator1
            x=444,
            y=960,
            width=33,
            height=61,

        },
        {
            -- claudator2
            x=478,
            y=960,
            width=14,
            height=61,

        },
        {
            -- ic_slot_bomba
            x=0,
            y=783,
            width=80,
            height=80,

        },
        {
            -- ic_slot_bomba_h
            x=152,
            y=783,
            width=64,
            height=80,

            sourceX = 7,
            sourceY = 0,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_calavera
            x=444,
            y=832,
            width=78,
            height=64,

            sourceX = 1,
            sourceY = 7,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_hielo
            x=375,
            y=767,
            width=78,
            height=64,

            sourceX = 0,
            sourceY = 5,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_hielo_h
            x=493,
            y=960,
            width=76,
            height=60,

            sourceX = 2,
            sourceY = 10,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_hueso
            x=81,
            y=783,
            width=70,
            height=80,

            sourceX = 4,
            sourceY = 0,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_jaulabuena
            x=217,
            y=702,
            width=76,
            height=76,

            sourceX = 2,
            sourceY = 1,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_jaulabuena_h
            x=294,
            y=848,
            width=74,
            height=72,

            sourceX = 3,
            sourceY = 2,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_jaulamuerte
            x=75,
            y=945,
            width=72,
            height=78,

            sourceX = 6,
            sourceY = 1,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_jaulamuerte_h
            x=219,
            y=854,
            width=74,
            height=74,

            sourceX = 3,
            sourceY = 3,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_lapida
            x=152,
            y=702,
            width=64,
            height=80,

            sourceX = 8,
            sourceY = 0,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_manguera
            x=363,
            y=921,
            width=80,
            height=70,

            sourceX = 0,
            sourceY = 4,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_manguera_h
            x=570,
            y=0,
            width=80,
            height=54,

            sourceX = 0,
            sourceY = 8,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_moneda
            x=0,
            y=702,
            width=80,
            height=80,

        },
        {
            -- ic_slot_moneda_h
            x=217,
            y=943,
            width=76,
            height=76,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_paloma
            x=294,
            y=775,
            width=80,
            height=72,

            sourceX = 0,
            sourceY = 4,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_paloma_h
            x=444,
            y=897,
            width=80,
            height=62,

            sourceX = 0,
            sourceY = 8,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_piedra
            x=454,
            y=45,
            width=78,
            height=54,

            sourceX = 1,
            sourceY = 11,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_piedra_h
            x=375,
            y=702,
            width=78,
            height=64,

            sourceX = 1,
            sourceY = 6,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_piruleta
            x=81,
            y=702,
            width=70,
            height=80,

            sourceX = 4,
            sourceY = 0,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_piruleta_h
            x=0,
            y=945,
            width=74,
            height=78,

            sourceX = 4,
            sourceY = 2,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_rastrillo
            x=148,
            y=945,
            width=68,
            height=78,

            sourceX = 6,
            sourceY = 1,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_rastrillo_h
            x=0,
            y=864,
            width=78,
            height=80,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_rayo
            x=152,
            y=864,
            width=66,
            height=78,

            sourceX = 6,
            sourceY = 0,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_rayo_h
            x=294,
            y=921,
            width=68,
            height=72,

            sourceX = 5,
            sourceY = 4,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_terremoto
            x=217,
            y=779,
            width=76,
            height=74,

            sourceX = 2,
            sourceY = 3,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_terremoto_h
            x=369,
            y=848,
            width=74,
            height=70,

            sourceX = 3,
            sourceY = 6,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_tramparat
            x=79,
            y=864,
            width=72,
            height=80,

            sourceX = 4,
            sourceY = 0,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_tramparat_h
            x=294,
            y=702,
            width=80,
            height=72,

            sourceX = 0,
            sourceY = 4,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- jackpot
            x=0,
            y=0,
            width=450,
            height=701,

            sourceX = 2,
            sourceY = 1,
            sourceWidth = 452,
            sourceHeight = 703
        },
    },
    
    sheetContentWidth = 1024,
    sheetContentHeight = 1024
}

SheetInfo.frameIndex =
{

    ["cerrar"] = 1,
    ["claudator1"] = 2,
    ["claudator2"] = 3,
    ["ic_slot_bomba"] = 4,
    ["ic_slot_bomba_h"] = 5,
    ["ic_slot_calavera"] = 6,
    ["ic_slot_hielo"] = 7,
    ["ic_slot_hielo_h"] = 8,
    ["ic_slot_hueso"] = 9,
    ["ic_slot_jaulabuena"] = 10,
    ["ic_slot_jaulabuena_h"] = 11,
    ["ic_slot_jaulamuerte"] = 12,
    ["ic_slot_jaulamuerte_h"] = 13,
    ["ic_slot_lapida"] = 14,
    ["ic_slot_manguera"] = 15,
    ["ic_slot_manguera_h"] = 16,
    ["ic_slot_moneda"] = 17,
    ["ic_slot_moneda_h"] = 18,
    ["ic_slot_paloma"] = 19,
    ["ic_slot_paloma_h"] = 20,
    ["ic_slot_piedra"] = 21,
    ["ic_slot_piedra_h"] = 22,
    ["ic_slot_piruleta"] = 23,
    ["ic_slot_piruleta_h"] = 24,
    ["ic_slot_rastrillo"] = 25,
    ["ic_slot_rastrillo_h"] = 26,
    ["ic_slot_rayo"] = 27,
    ["ic_slot_rayo_h"] = 28,
    ["ic_slot_terremoto"] = 29,
    ["ic_slot_terremoto_h"] = 30,
    ["ic_slot_tramparat"] = 31,
    ["ic_slot_tramparat_h"] = 32,
    ["jackpot"] = 33,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
