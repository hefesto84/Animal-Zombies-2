--
-- created with TexturePacker (http://www.texturepacker.com)
--
-- $TexturePacker:SmartUpdate:93c1ea124c84391c408016ba529a09e0$
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
            -- 00_luceswin_alas_sup_der
            x=2,
            y=341,
            width=104,
            height=50,

            sourceX = 18,
            sourceY = 0,
            sourceWidth = 218,
            sourceHeight = 50
        },
        {
            -- 00_luceswin_alas_sup_izq
            x=108,
            y=341,
            width=96,
            height=50,

            sourceX = 97,
            sourceY = 0,
            sourceWidth = 212,
            sourceHeight = 50
        },
        {
            -- 01_luceswin_alas_sup_der
            x=228,
            y=519,
            width=99,
            height=26,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 181,
            sourceHeight = 36
        },
        {
            -- 01_luceswin_alas_sup_izq
            x=72,
            y=580,
            width=94,
            height=28,

            sourceX = 84,
            sourceY = 0,
            sourceWidth = 178,
            sourceHeight = 36
        },
        {
            -- 02_luceswin_ojos
            x=228,
            y=396,
            width=71,
            height=28,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 71,
            sourceHeight = 36
        },
        {
            -- 04_luceswin_centro_der
            x=341,
            y=2,
            width=158,
            height=244,

            sourceX = 17,
            sourceY = 11,
            sourceWidth = 218,
            sourceHeight = 256
        },
        {
            -- 04_luceswin_centro_izq
            x=338,
            y=248,
            width=154,
            height=244,

            sourceX = 43,
            sourceY = 11,
            sourceWidth = 212,
            sourceHeight = 256
        },
        {
            -- 05_luceswin_inf_der_01
            x=486,
            y=607,
            width=19,
            height=111,

            sourceX = 4,
            sourceY = 76,
            sourceWidth = 23,
            sourceHeight = 187
        },
        {
            -- 05_luceswin_inf_der_02
            x=317,
            y=364,
            width=19,
            height=153,

            sourceX = 3,
            sourceY = 34,
            sourceWidth = 25,
            sourceHeight = 187
        },
        {
            -- 05_luceswin_inf_der_03
            x=2,
            y=720,
            width=18,
            height=185,

            sourceX = 4,
            sourceY = 2,
            sourceWidth = 28,
            sourceHeight = 187
        },
        {
            -- 05_luceswin_inf_izq_01
            x=486,
            y=494,
            width=19,
            height=111,

            sourceX = 0,
            sourceY = 76,
            sourceWidth = 23,
            sourceHeight = 187
        },
        {
            -- 05_luceswin_inf_izq_02
            x=317,
            y=209,
            width=19,
            height=153,

            sourceX = 2,
            sourceY = 34,
            sourceWidth = 27,
            sourceHeight = 187
        },
        {
            -- 05_luceswin_inf_izq_03
            x=296,
            y=209,
            width=19,
            height=185,

            sourceX = 3,
            sourceY = 2,
            sourceWidth = 25,
            sourceHeight = 187
        },
        {
            -- alert shop
            x=2,
            y=580,
            width=68,
            height=31,

        },
        {
            -- boton shop neg
            x=115,
            y=396,
            width=111,
            height=182,

        },
        {
            -- boton shop
            x=2,
            y=396,
            width=111,
            height=182,

        },
        {
            -- botonprizes_push
            x=2,
            y=209,
            width=292,
            height=66,

        },
        {
            -- botonprizes_unpush
            x=2,
            y=277,
            width=288,
            height=62,

            sourceX = 2,
            sourceY = 2,
            sourceWidth = 292,
            sourceHeight = 66
        },
        {
            -- left
            x=168,
            y=580,
            width=146,
            height=125,

        },
        {
            -- left_neg
            x=338,
            y=494,
            width=146,
            height=125,

        },
        {
            -- palanca
            x=2,
            y=621,
            width=80,
            height=83,

        },
        {
            -- slotmachine_anim_sombras
            x=2,
            y=2,
            width=337,
            height=205,

        },
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 1024
}

SheetInfo.frameIndex =
{

    ["00_luceswin_alas_sup_der"] = 1,
    ["00_luceswin_alas_sup_izq"] = 2,
    ["01_luceswin_alas_sup_der"] = 3,
    ["01_luceswin_alas_sup_izq"] = 4,
    ["02_luceswin_ojos"] = 5,
    ["04_luceswin_centro_der"] = 6,
    ["04_luceswin_centro_izq"] = 7,
    ["05_luceswin_inf_der_01"] = 8,
    ["05_luceswin_inf_der_02"] = 9,
    ["05_luceswin_inf_der_03"] = 10,
    ["05_luceswin_inf_izq_01"] = 11,
    ["05_luceswin_inf_izq_02"] = 12,
    ["05_luceswin_inf_izq_03"] = 13,
    ["alert_shop"] = 14,
    ["boton_shop_neg"] = 15,
    ["boton_shop"] = 16,
    ["botonprizes_push"] = 17,
    ["botonprizes_unpush"] = 18,
    ["left"] = 19,
    ["left_neg"] = 20,
    ["palanca"] = 21,
    ["slotmachine_anim_sombras"] = 22,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
