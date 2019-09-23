--
-- created with TexturePacker (http://www.texturepacker.com)
--
-- $TexturePacker:SmartUpdate:2de417dc9c4ee248be9834c7414ab618$
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
            x=400,
            y=985,
            width=32,
            height=33,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 34,
            sourceHeight = 35
        },
        {
            -- claudator1
            x=456,
            y=845,
            width=33,
            height=61,

        },
        {
            -- claudator2
            x=482,
            y=908,
            width=14,
            height=61,

        },
        {
            -- ic_slot_bomba
            x=2,
            y=787,
            width=80,
            height=80,

        },
        {
            -- ic_slot_bomba_h
            x=156,
            y=787,
            width=64,
            height=80,

            sourceX = 7,
            sourceY = 0,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_calavera
            x=452,
            y=779,
            width=78,
            height=64,

            sourceX = 1,
            sourceY = 7,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_hielo
            x=376,
            y=855,
            width=78,
            height=64,

            sourceX = 0,
            sourceY = 5,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_hielo_h
            x=491,
            y=845,
            width=76,
            height=60,

            sourceX = 2,
            sourceY = 10,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_hueso
            x=84,
            y=787,
            width=70,
            height=80,

            sourceX = 4,
            sourceY = 0,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_jaulabuena
            x=292,
            y=785,
            width=76,
            height=76,

            sourceX = 2,
            sourceY = 1,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_jaulabuena_h
            x=374,
            y=705,
            width=74,
            height=72,

            sourceX = 3,
            sourceY = 2,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_jaulamuerte
            x=222,
            y=705,
            width=72,
            height=78,

            sourceX = 6,
            sourceY = 1,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_jaulamuerte_h
            x=300,
            y=863,
            width=74,
            height=74,

            sourceX = 3,
            sourceY = 3,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_lapida
            x=156,
            y=705,
            width=64,
            height=80,

            sourceX = 8,
            sourceY = 0,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_manguera
            x=2,
            y=951,
            width=80,
            height=70,

            sourceX = 0,
            sourceY = 4,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_manguera_h
            x=498,
            y=907,
            width=80,
            height=54,

            sourceX = 0,
            sourceY = 8,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_moneda
            x=2,
            y=705,
            width=80,
            height=80,

        },
        {
            -- ic_slot_moneda_h
            x=242,
            y=945,
            width=76,
            height=76,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_paloma
            x=370,
            y=781,
            width=80,
            height=72,

            sourceX = 0,
            sourceY = 4,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_paloma_h
            x=400,
            y=921,
            width=80,
            height=62,

            sourceX = 0,
            sourceY = 8,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_piedra
            x=498,
            y=963,
            width=78,
            height=54,

            sourceX = 1,
            sourceY = 11,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_piedra_h
            x=320,
            y=939,
            width=78,
            height=64,

            sourceX = 1,
            sourceY = 6,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_piruleta
            x=84,
            y=705,
            width=70,
            height=80,

            sourceX = 4,
            sourceY = 0,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_piruleta_h
            x=156,
            y=869,
            width=74,
            height=78,

            sourceX = 4,
            sourceY = 2,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_rastrillo
            x=222,
            y=785,
            width=68,
            height=78,

            sourceX = 6,
            sourceY = 1,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_rastrillo_h
            x=2,
            y=869,
            width=78,
            height=80,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_rayo
            x=232,
            y=865,
            width=66,
            height=78,

            sourceX = 6,
            sourceY = 0,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_rayo_h
            x=450,
            y=705,
            width=68,
            height=72,

            sourceX = 5,
            sourceY = 4,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_terremoto
            x=296,
            y=705,
            width=76,
            height=74,

            sourceX = 2,
            sourceY = 3,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_terremoto_h
            x=84,
            y=951,
            width=74,
            height=70,

            sourceX = 3,
            sourceY = 6,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_tramparat
            x=82,
            y=869,
            width=72,
            height=80,

            sourceX = 4,
            sourceY = 0,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- ic_slot_tramparat_h
            x=160,
            y=949,
            width=80,
            height=72,

            sourceX = 0,
            sourceY = 4,
            sourceWidth = 80,
            sourceHeight = 80
        },
        {
            -- jackpot
            x=2,
            y=2,
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
