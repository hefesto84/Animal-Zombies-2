--
-- created with TexturePacker (http://www.texturepacker.com)
--
-- $TexturePacker:SmartUpdate:f32bb20ed3578628947b97cf85d3cd79$
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
            x=105,
            y=336,
            width=102,
            height=50,

            sourceX = 19,
            sourceY = 0,
            sourceWidth = 218,
            sourceHeight = 50
        },
        {
            -- 00_luceswin_alas_sup_izq
            x=0,
            y=408,
            width=94,
            height=50,

            sourceX = 99,
            sourceY = 0,
            sourceWidth = 212,
            sourceHeight = 50
        },
        {
            -- 01_luceswin_alas_sup_der
            x=105,
            y=387,
            width=99,
            height=26,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 181,
            sourceHeight = 36
        },
        {
            -- 01_luceswin_alas_sup_izq
            x=95,
            y=414,
            width=94,
            height=26,

            sourceX = 84,
            sourceY = 1,
            sourceWidth = 178,
            sourceHeight = 36
        },
        {
            -- 02_luceswin_ojos
            x=190,
            y=420,
            width=71,
            height=28,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 71,
            sourceHeight = 36
        },
        {
            -- 04_luceswin_centro_der
            x=338,
            y=0,
            width=158,
            height=244,

            sourceX = 17,
            sourceY = 11,
            sourceWidth = 218,
            sourceHeight = 256
        },
        {
            -- 04_luceswin_centro_izq
            x=335,
            y=245,
            width=154,
            height=244,

            sourceX = 43,
            sourceY = 11,
            sourceWidth = 212,
            sourceHeight = 256
        },
        {
            -- 05_luceswin_inf_der_01
            x=289,
            y=381,
            width=19,
            height=111,

            sourceX = 4,
            sourceY = 76,
            sourceWidth = 23,
            sourceHeight = 187
        },
        {
            -- 05_luceswin_inf_der_02
            x=490,
            y=245,
            width=19,
            height=153,

            sourceX = 3,
            sourceY = 34,
            sourceWidth = 25,
            sourceHeight = 187
        },
        {
            -- 05_luceswin_inf_der_03
            x=309,
            y=411,
            width=18,
            height=185,

            sourceX = 4,
            sourceY = 0,
            sourceWidth = 28,
            sourceHeight = 187
        },
        {
            -- 05_luceswin_inf_izq_01
            x=490,
            y=399,
            width=19,
            height=111,

            sourceX = 0,
            sourceY = 76,
            sourceWidth = 23,
            sourceHeight = 187
        },
        {
            -- 05_luceswin_inf_izq_02
            x=293,
            y=227,
            width=21,
            height=153,

            sourceX = 3,
            sourceY = 34,
            sourceWidth = 27,
            sourceHeight = 187
        },
        {
            -- 05_luceswin_inf_izq_03
            x=315,
            y=227,
            width=19,
            height=183,

            sourceX = 3,
            sourceY = 2,
            sourceWidth = 25,
            sourceHeight = 187
        },
        {
            -- alert shop
            x=293,
            y=206,
            width=31,
            height=20,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 33,
            sourceHeight = 22
        },
        {
            -- boton shop
            x=95,
            y=441,
            width=70,
            height=66,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 72,
            sourceHeight = 68
        },
        {
            -- botonprizes_push
            x=0,
            y=206,
            width=292,
            height=66,

        },
        {
            -- botonprizes_unpush
            x=0,
            y=273,
            width=288,
            height=62,

            sourceX = 2,
            sourceY = 2,
            sourceWidth = 292,
            sourceHeight = 66
        },
        {
            -- left
            x=0,
            y=336,
            width=104,
            height=71,

            sourceX = 2,
            sourceY = 2,
            sourceWidth = 108,
            sourceHeight = 73
        },
        {
            -- palanca
            x=208,
            y=336,
            width=80,
            height=83,

        },
        {
            -- slotmachine_anim_sombras
            x=0,
            y=0,
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
    ["boton_shop"] = 15,
    ["botonprizes_push"] = 16,
    ["botonprizes_unpush"] = 17,
    ["left"] = 18,
    ["palanca"] = 19,
    ["slotmachine_anim_sombras"] = 20,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
