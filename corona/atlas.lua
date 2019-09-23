--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:c946e513bb97a9f3817bad2e3ba7268c$
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
            -- copyright
            x=0,
            y=1000,
            width=198,
            height=16,

            sourceX = 9,
            sourceY = 11,
            sourceWidth = 216,
            sourceHeight = 36
        },
        {
            -- credits
            x=0,
            y=551,
            width=444,
            height=448,

            sourceX = 24,
            sourceY = 26,
            sourceWidth = 480,
            sourceHeight = 518
        },
        {
            -- ilustracionnivelbloqueado
            x=445,
            y=633,
            width=343,
            height=351,

        },
        {
            -- logomenus
            x=550,
            y=380,
            width=393,
            height=252,

            sourceX = 75,
            sourceY = 46,
            sourceWidth = 533,
            sourceHeight = 360
        },
        {
            -- marco
            x=0,
            y=0,
            width=549,
            height=550,

            sourceX = 86,
            sourceY = 107,
            sourceWidth = 719,
            sourceHeight = 748
        },
        {
            -- rotura
            x=550,
            y=0,
            width=377,
            height=379,

            sourceX = 57,
            sourceY = 67,
            sourceWidth = 491,
            sourceHeight = 513
        },
        {
            -- thousandGears
            x=789,
            y=633,
            width=140,
            height=187,

            sourceX = 41,
            sourceY = 15,
            sourceWidth = 220,
            sourceHeight = 221
        },
        {
            -- botonpausa-push
            x=419,
            y=563,
            width=86,
            height=106,

            sourceX = 20,
            sourceY = 16,
            sourceWidth = 126,
            sourceHeight = 142
        },
        {
            -- botonpausa
            x=419,
            y=456,
            width=86,
            height=106,

            sourceX = 20,
            sourceY = 16,
            sourceWidth = 126,
            sourceHeight = 142
        },
        {
            -- candado
            x=473,
            y=668,
            width=32,
            height=40,

            sourceX = 44,
            sourceY = 34,
            sourceWidth = 112,
            sourceHeight = 112
        },
        {
            -- choose a level
            x=0,
            y=481,
            width=415,
            height=90,

            sourceX = 54,
            sourceY = 76,
            sourceWidth = 515,
            sourceHeight = 246
        },
        {
            -- cuentaatras-1
            x=340,
            y=572,
            width=78,
            height=237,

            sourceX = 40,
            sourceY = 33,
            sourceWidth = 172,
            sourceHeight = 305
        },
        {
            -- cuentaatras-2
            x=345,
            y=0,
            width=147,
            height=245,

            sourceX = 24,
            sourceY = 10,
            sourceWidth = 197,
            sourceHeight = 283
        },
        {
            -- cuentaatras-3
            x=0,
            y=653,
            width=142,
            height=250,

            sourceX = 22,
            sourceY = 20,
            sourceWidth = 180,
            sourceHeight = 292
        },
        {
            -- gameover
            x=0,
            y=572,
            width=338,
            height=80,

            sourceX = 44,
            sourceY = 43,
            sourceWidth = 424,
            sourceHeight = 176
        },
        {
            -- huesoblanco
            x=419,
            y=730,
            width=52,
            height=61,

            sourceX = 22,
            sourceY = 15,
            sourceWidth = 92,
            sourceHeight = 97
        },
        {
            -- huesogris
            x=419,
            y=668,
            width=53,
            height=61,

            sourceX = 29,
            sourceY = 26,
            sourceWidth = 113,
            sourceHeight = 115
        },
        {
            -- iconRastrillo
            x=406,
            y=246,
            width=106,
            height=103,

        },
        {
            -- marcadorhuesos
            x=0,
            y=343,
            width=382,
            height=137,

            sourceX = 40,
            sourceY = 45,
            sourceWidth = 454,
            sourceHeight = 229
        },
        {
            -- marcadormuertes
            x=143,
            y=799,
            width=164,
            height=125,

            sourceX = 40,
            sourceY = 0,
            sourceWidth = 238,
            sourceHeight = 173
        },
        {
            -- marcadorvidas-tiempo
            x=143,
            y=653,
            width=196,
            height=145,

            sourceX = 33,
            sourceY = 0,
            sourceWidth = 266,
            sourceHeight = 191
        },
        {
            -- piruleta
            x=345,
            y=246,
            width=60,
            height=85,

            sourceX = 26,
            sourceY = 14,
            sourceWidth = 106,
            sourceHeight = 123
        },
        {
            -- wingirador2
            x=0,
            y=0,
            width=344,
            height=342,

            sourceX = 24,
            sourceY = 25,
            sourceWidth = 400,
            sourceHeight = 400
        },
        {
            -- x2
            x=308,
            y=810,
            width=108,
            height=106,

            sourceX = 21,
            sourceY = 19,
            sourceWidth = 152,
            sourceHeight = 144
        },
        {
            -- x3
            x=308,
            y=917,
            width=104,
            height=106,

            sourceX = 24,
            sourceY = 16,
            sourceWidth = 152,
            sourceHeight = 146
        },
        {
            -- x4
            x=0,
            y=904,
            width=112,
            height=107,

            sourceX = 23,
            sourceY = 26,
            sourceWidth = 154,
            sourceHeight = 155
        },
        {
            -- x5
            x=383,
            y=350,
            width=108,
            height=105,

            sourceX = 23,
            sourceY = 28,
            sourceWidth = 154,
            sourceHeight = 155
        },
        {
            -- CREDITSblanco
            x=0,
            y=924,
            width=223,
            height=78,

            sourceX = 32,
            sourceY = 21,
            sourceWidth = 293,
            sourceHeight = 138
        },
        {
            -- CREDITSnegro
            x=224,
            y=924,
            width=223,
            height=72,

            sourceX = 32,
            sourceY = 27,
            sourceWidth = 293,
            sourceHeight = 138
        },
        {
            -- OPTIONSblanco
            x=0,
            y=759,
            width=247,
            height=71,

            sourceX = 38,
            sourceY = 38,
            sourceWidth = 319,
            sourceHeight = 151
        },
        {
            -- OPTIONSnegro
            x=0,
            y=687,
            width=247,
            height=71,

            sourceX = 38,
            sourceY = 38,
            sourceWidth = 319,
            sourceHeight = 151
        },
        {
            -- PLAYblanco
            x=297,
            y=651,
            width=151,
            height=78,

            sourceX = 40,
            sourceY = 39,
            sourceWidth = 227,
            sourceHeight = 152
        },
        {
            -- PLAYnegro
            x=292,
            y=730,
            width=151,
            height=72,

            sourceX = 40,
            sourceY = 38,
            sourceWidth = 227,
            sourceHeight = 152
        },
        {
            -- SURVIVALblanco
            x=0,
            y=194,
            width=422,
            height=85,

            sourceX = 33,
            sourceY = 16,
            sourceWidth = 494,
            sourceHeight = 125
        },
        {
            -- SURVIVALnegro
            x=0,
            y=280,
            width=422,
            height=71,

            sourceX = 33,
            sourceY = 23,
            sourceWidth = 494,
            sourceHeight = 125
        },
        {
            -- boton options-push
            x=0,
            y=424,
            width=303,
            height=71,

            sourceX = 1,
            sourceY = 2,
            sourceWidth = 305,
            sourceHeight = 75
        },
        {
            -- boton options
            x=0,
            y=352,
            width=303,
            height=71,

            sourceX = 1,
            sourceY = 2,
            sourceWidth = 305,
            sourceHeight = 75
        },
        {
            -- loading
            x=0,
            y=831,
            width=238,
            height=92,

            sourceX = 21,
            sourceY = 23,
            sourceWidth = 290,
            sourceHeight = 142
        },
        {
            -- logomenus2
            x=0,
            y=496,
            width=296,
            height=190,

            sourceX = 56,
            sourceY = 34,
            sourceWidth = 400,
            sourceHeight = 270
        },
        {
            -- musica off
            x=423,
            y=344,
            width=61,
            height=49,

            sourceX = 2,
            sourceY = 1,
            sourceWidth = 65,
            sourceHeight = 51
        },
        {
            -- musica on
            x=248,
            y=687,
            width=43,
            height=43,

            sourceX = 7,
            sourceY = 5,
            sourceWidth = 65,
            sourceHeight = 51
        },
        {
            -- options
            x=248,
            y=803,
            width=246,
            height=77,

            sourceX = 33,
            sourceY = 21,
            sourceWidth = 312,
            sourceHeight = 127
        },
        {
            -- paw
            x=304,
            y=394,
            width=187,
            height=256,

            sourceX = 9,
            sourceY = 0,
            sourceWidth = 197,
            sourceHeight = 256
        },
        {
            -- reset off
            x=423,
            y=294,
            width=61,
            height=49,

            sourceX = 1,
            sourceY = 3,
            sourceWidth = 63,
            sourceHeight = 53
        },
        {
            -- reset on
            x=248,
            y=731,
            width=39,
            height=47,

            sourceX = 11,
            sourceY = 2,
            sourceWidth = 63,
            sourceHeight = 53
        },
        {
            -- sonido off
            x=423,
            y=244,
            width=61,
            height=49,

            sourceX = 2,
            sourceY = 2,
            sourceWidth = 65,
            sourceHeight = 53
        },
        {
            -- sonido on
            x=449,
            y=651,
            width=49,
            height=47,

            sourceX = 9,
            sourceY = 1,
            sourceWidth = 65,
            sourceHeight = 53
        },
        {
            -- superiorcorte480
            x=0,
            y=0,
            width=480,
            height=193,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 480,
            sourceHeight = 211
        },
        {
            -- vibracion off
            x=423,
            y=194,
            width=61,
            height=49,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 63,
            sourceHeight = 51
        },
        {
            -- vibracion on
            x=449,
            y=699,
            width=49,
            height=45,

            sourceX = 7,
            sourceY = 3,
            sourceWidth = 63,
            sourceHeight = 51
        },
        {
            -- AnimalScience
            x=344,
            y=264,
            width=116,
            height=116,

        },
        {
            -- ConciliationMaster
            x=230,
            y=615,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- CookieEmporium
            x=115,
            y=548,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- CrimePrevention
            x=0,
            y=548,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- DogCare
            x=345,
            y=498,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- Gardening
            x=230,
            y=498,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- ReptileStudy
            x=115,
            y=431,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- UltimateFarmer
            x=0,
            y=431,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- WildernessSurvival
            x=344,
            y=381,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- frame_cementerio
            x=0,
            y=79,
            width=343,
            height=351,

        },
        {
            -- lapidalevelstage1
            x=344,
            y=79,
            width=127,
            height=184,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 127,
            sourceHeight = 184
        },
        {
            -- petcemetery
            x=0,
            y=0,
            width=405,
            height=78,

            sourceX = 42,
            sourceY = 27,
            sourceWidth = 479,
            sourceHeight = 152
        },
        {
            -- AnimalBreeding
            x=115,
            y=549,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- FairSavior
            x=0,
            y=549,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- LittleMissShovel
            x=345,
            y=522,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- MammalStudy
            x=230,
            y=522,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- MarmaladeMaker
            x=115,
            y=432,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- PestControl
            x=0,
            y=432,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- PoultryAvenger
            x=344,
            y=405,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- SugarSmuggler
            x=344,
            y=288,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- WildlifeManagement
            x=344,
            y=171,
            width=114,
            height=116,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 116,
            sourceHeight = 116
        },
        {
            -- countyfair
            x=0,
            y=0,
            width=390,
            height=79,

            sourceX = 35,
            sourceY = 22,
            sourceWidth = 462,
            sourceHeight = 121
        },
        {
            -- frame_feria
            x=0,
            y=80,
            width=343,
            height=351,

        },
        {
            -- lapidalevelstage2
            x=391,
            y=0,
            width=115,
            height=170,

            sourceX = 0,
            sourceY = 12,
            sourceWidth = 120,
            sourceHeight = 184
        },
        {
            -- back-push
            x=0,
            y=245,
            width=149,
            height=128,

            sourceX = 16,
            sourceY = 10,
            sourceWidth = 185,
            sourceHeight = 156
        },
        {
            -- back
            x=150,
            y=243,
            width=147,
            height=127,

            sourceX = 47,
            sourceY = 54,
            sourceWidth = 237,
            sourceHeight = 241
        },
        {
            -- boton facebook-push
            x=232,
            y=0,
            width=231,
            height=114,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 245,
            sourceHeight = 132
        },
        {
            -- boton facebook
            x=0,
            y=0,
            width=231,
            height=114,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 245,
            sourceHeight = 132
        },
        {
            -- botonmenu
            x=298,
            y=369,
            width=156,
            height=73,

            sourceX = 67,
            sourceY = 72,
            sourceWidth = 302,
            sourceHeight = 217
        },
        {
            -- menu-flecha-push
            x=149,
            y=374,
            width=148,
            height=128,

            sourceX = 26,
            sourceY = 23,
            sourceWidth = 212,
            sourceHeight = 181
        },
        {
            -- menu-push
            x=298,
            y=295,
            width=156,
            height=73,

            sourceX = 67,
            sourceY = 72,
            sourceWidth = 302,
            sourceHeight = 217
        },
        {
            -- menu
            x=0,
            y=374,
            width=148,
            height=128,

            sourceX = 26,
            sourceY = 23,
            sourceWidth = 212,
            sourceHeight = 181
        },
        {
            -- next-push
            x=0,
            y=115,
            width=149,
            height=129,

            sourceX = 37,
            sourceY = 24,
            sourceWidth = 211,
            sourceHeight = 181
        },
        {
            -- next
            x=150,
            y=115,
            width=147,
            height=127,

            sourceX = 59,
            sourceY = 60,
            sourceWidth = 247,
            sourceHeight = 253
        },
        {
            -- replay-push
            x=298,
            y=115,
            width=183,
            height=90,

            sourceX = 60,
            sourceY = 64,
            sourceWidth = 303,
            sourceHeight = 226
        },
        {
            -- replay
            x=298,
            y=206,
            width=181,
            height=88,

            sourceX = 60,
            sourceY = 65,
            sourceWidth = 303,
            sourceHeight = 226
        },
        {
            -- copa_neg
            x=102,
            y=144,
            width=101,
            height=71,

        },
        {
            -- copa_pos
            x=102,
            y=72,
            width=101,
            height=71,

        },
        {
            -- game_google_neg
            x=0,
            y=144,
            width=101,
            height=71,

        },
        {
            -- game_google_pos
            x=0,
            y=72,
            width=101,
            height=71,

        },
        {
            -- game_ios_neg
            x=102,
            y=0,
            width=101,
            height=71,

        },
        {
            -- game_ios_pos
            x=0,
            y=0,
            width=101,
            height=71,

        },
        {
            -- configure
            x=266,
            y=304,
            width=118,
            height=97,

            sourceX = 41,
            sourceY = 13,
            sourceWidth = 200,
            sourceHeight = 125
        },
        {
            -- configure_neg
            x=147,
            y=402,
            width=118,
            height=97,

            sourceX = 14,
            sourceY = 13,
            sourceWidth = 146,
            sourceHeight = 125
        },
        {
            -- exit
            x=304,
            y=126,
            width=156,
            height=79,

            sourceX = 25,
            sourceY = 24,
            sourceWidth = 200,
            sourceHeight = 125
        },
        {
            -- exit_left
            x=0,
            y=378,
            width=146,
            height=125,

            sourceX = 26,
            sourceY = 0,
            sourceWidth = 200,
            sourceHeight = 125
        },
        {
            -- exit_left_neg
            x=0,
            y=252,
            width=146,
            height=125,

            sourceX = 26,
            sourceY = 0,
            sourceWidth = 200,
            sourceHeight = 125
        },
        {
            -- exit_neg
            x=147,
            y=126,
            width=156,
            height=79,

            sourceX = 25,
            sourceY = 24,
            sourceWidth = 200,
            sourceHeight = 125
        },
        {
            -- info
            x=147,
            y=304,
            width=118,
            height=97,

            sourceX = 41,
            sourceY = 13,
            sourceWidth = 200,
            sourceHeight = 125
        },
        {
            -- info_neg
            x=385,
            y=206,
            width=118,
            height=97,

            sourceX = 14,
            sourceY = 13,
            sourceWidth = 146,
            sourceHeight = 125
        },
        {
            -- left
            x=0,
            y=126,
            width=146,
            height=125,

        },
        {
            -- left_neg
            x=294,
            y=0,
            width=146,
            height=125,

        },
        {
            -- replay2
            x=266,
            y=206,
            width=118,
            height=97,

            sourceX = 41,
            sourceY = 13,
            sourceWidth = 200,
            sourceHeight = 125
        },
        {
            -- replay2_neg
            x=147,
            y=206,
            width=118,
            height=97,

            sourceX = 14,
            sourceY = 13,
            sourceWidth = 146,
            sourceHeight = 125
        },
        {
            -- right
            x=147,
            y=0,
            width=146,
            height=125,

        },
        {
            -- right_neg
            x=0,
            y=0,
            width=146,
            height=125,

        },
        {
            -- alert shop
            x=266,
            y=441,
            width=68,
            height=31,

        },
        {
            -- boton shop neg
            x=0,
            y=183,
            width=111,
            height=182,

        },
        {
            -- boton shop
            x=0,
            y=0,
            width=111,
            height=182,

        },
        {
            -- boton slotmachine neg
            x=112,
            y=275,
            width=120,
            height=87,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 120,
            sourceHeight = 89
        },
        {
            -- boton slotmachine
            x=112,
            y=187,
            width=120,
            height=87,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 120,
            sourceHeight = 89
        },
        {
            -- candado
            x=112,
            y=0,
            width=34,
            height=51,

            sourceX = 75,
            sourceY = 45,
            sourceWidth = 188,
            sourceHeight = 151
        },
        {
            -- corazon
            x=148,
            y=441,
            width=117,
            height=52,

        },
        {
            -- flecha neg
            x=148,
            y=60,
            width=147,
            height=126,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 149,
            sourceHeight = 128
        },
        {
            -- flecha
            x=0,
            y=366,
            width=147,
            height=126,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 149,
            sourceHeight = 128
        },
        {
            -- hueso
            x=112,
            y=52,
            width=20,
            height=22,

        },
        {
            -- level selector block
            x=227,
            y=363,
            width=78,
            height=77,

            sourceX = 53,
            sourceY = 33,
            sourceWidth = 188,
            sourceHeight = 151
        },
        {
            -- level selector clean
            x=148,
            y=363,
            width=78,
            height=77,

            sourceX = 52,
            sourceY = 33,
            sourceWidth = 188,
            sourceHeight = 151
        },
        {
            -- monedas
            x=148,
            y=0,
            width=156,
            height=59,

        },
        {
            -- pergamino
            x=305,
            y=0,
            width=148,
            height=71,

            sourceX = 18,
            sourceY = 72,
            sourceWidth = 188,
            sourceHeight = 151
        }
    },
}

SheetInfo.frameIndex =
{

    ["copyright"] = 1,
    ["credits"] = 2,
    ["ilustracionnivelbloqueado"] = 3,
    ["logomenus"] = 4,
    ["marco"] = 5,
    ["rotura"] = 6,
    ["thousandGears"] = 7,
    ["botonpausa-push"] = 8,
    ["botonpausa"] = 9,
    ["candado"] = 10,
    ["choose a level"] = 11,
    ["cuentaatras-1"] = 12,
    ["cuentaatras-2"] = 13,
    ["cuentaatras-3"] = 14,
    ["gameover"] = 15,
    ["huesoblanco"] = 16,
    ["huesogris"] = 17,
    ["iconRastrillo"] = 18,
    ["marcadorhuesos"] = 19,
    ["marcadormuertes"] = 20,
    ["marcadorvidas-tiempo"] = 21,
    ["piruleta"] = 22,
    ["wingirador2"] = 23,
    ["x2"] = 24,
    ["x3"] = 25,
    ["x4"] = 26,
    ["x5"] = 27,
    ["CREDITSblanco"] = 28,
    ["CREDITSnegro"] = 29,
    ["OPTIONSblanco"] = 30,
    ["OPTIONSnegro"] = 31,
    ["PLAYblanco"] = 32,
    ["PLAYnegro"] = 33,
    ["SURVIVALblanco"] = 34,
    ["SURVIVALnegro"] = 35,
    ["boton options-push"] = 36,
    ["boton options"] = 37,
    ["loading"] = 38,
    ["logomenus2"] = 39,
    ["musica off"] = 40,
    ["musica on"] = 41,
    ["options"] = 42,
    ["paw"] = 43,
    ["reset off"] = 44,
    ["reset on"] = 45,
    ["sonido off"] = 46,
    ["sonido on"] = 47,
    ["superiorcorte480"] = 48,
    ["vibracion off"] = 49,
    ["vibracion on"] = 50,
    ["AnimalScience"] = 51,
    ["ConciliationMaster"] = 52,
    ["CookieEmporium"] = 53,
    ["CrimePrevention"] = 54,
    ["DogCare"] = 55,
    ["Gardening"] = 56,
    ["ReptileStudy"] = 57,
    ["UltimateFarmer"] = 58,
    ["WildernessSurvival"] = 59,
    ["frame_cementerio"] = 60,
    ["lapidalevelstage1"] = 61,
    ["petcemetery"] = 62,
    ["AnimalBreeding"] = 63,
    ["FairSavior"] = 64,
    ["LittleMissShovel"] = 65,
    ["MammalStudy"] = 66,
    ["MarmaladeMaker"] = 67,
    ["PestControl"] = 68,
    ["PoultryAvenger"] = 69,
    ["SugarSmuggler"] = 70,
    ["WildlifeManagement"] = 71,
    ["countyfair"] = 72,
    ["frame_feria"] = 73,
    ["lapidalevelstage2"] = 74,
    ["back-push"] = 75,
    ["back"] = 76,
    ["boton facebook-push"] = 77,
    ["boton facebook"] = 78,
    ["botonmenu"] = 79,
    ["menu-flecha-push"] = 80,
    ["menu-push"] = 81,
    ["menu"] = 82,
    ["next-push"] = 83,
    ["next"] = 84,
    ["replay-push"] = 85,
    ["replay"] = 86,
    ["copa_neg"] = 87,
    ["copa_pos"] = 88,
    ["game_google_neg"] = 89,
    ["game_google_pos"] = 90,
    ["game_ios_neg"] = 91,
    ["game_ios_pos"] = 92,
    ["configure"] = 93,
    ["configure_neg"] = 94,
    ["exit"] = 95,
    ["exit_left"] = 96,
    ["exit_left_neg"] = 97,
    ["exit_neg"] = 98,
    ["info"] = 99,
    ["info_neg"] = 100,
    ["left"] = 101,
    ["left_neg"] = 102,
    ["replay2"] = 103,
    ["replay2_neg"] = 104,
    ["right"] = 105,
    ["right_neg"] = 106,
    ["alert shop"] = 107,
    ["boton shop neg"] = 108,
    ["boton shop"] = 109,
    ["boton slotmachine neg"] = 110,
    ["boton slotmachine"] = 111,
    ["candado"] = 112,
    ["corazon"] = 113,
    ["flecha neg"] = 114,
    ["flecha"] = 115,
    ["hueso"] = 116,
    ["level selector block"] = 117,
    ["level selector clean"] = 118,
    ["monedas"] = 119,
    ["pergamino"] = 120,
}

function SheetInfo:getSpriteSheet(index)
    if index < 8 then
        return "assets/guiSheet/creditsStage.png"
    elseif index < 28 then
        return "assets/guiSheet/levelsIngameWinLose.png"
    elseif index < 51 then
        return "assets/guiSheet/menuOptionsPauseLoading.png"
    elseif index < 63 then
        return "assets/guiSheet/stage1.png"
    elseif index < 75 then
        return "assets/guiSheet/stage2.png"
    elseif index < 87 then
        return "assets/guiSheet/buttons.png"
    elseif index < 93 then
        return "assets/guiSheet/achievements.png"
    elseif index < 107 then
        return "assets/guiSheet/newButtons.png"
    elseif index < 121 then
        return "assets/level/level.png"
    end
    print("Index ".. index .." not found!")
    return ""
end

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

function SheetInfo:getFrameIndexAndSpriteSheet(nameOrIndex)
    local index = nameOrIndex
    
    if tonumber(nameOrIndex) == nil then
        index = SheetInfo:getFrameIndex(nameOrIndex)
    end
    
    return index, SheetInfo:getSpriteSheet(index)
end

return SheetInfo