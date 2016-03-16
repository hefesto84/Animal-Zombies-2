--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:fa17ccb09103fc2ea1a9b6f526ca7a89:cb4b806e949913ba6f5e6db12178924f:6cf63f454afe8a1aaba27448693b0505$
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
            x=0,
            y=481,
            width=68,
            height=31,

        },
        {
            -- blocked
            x=180,
            y=452,
            width=56,
            height=57,

        },
        {
            -- blocked_press
            x=123,
            y=452,
            width=56,
            height=57,

        },
        {
            -- bloque inferior
            x=0,
            y=0,
            width=512,
            height=139,

            sourceX = 0,
            sourceY = 5,
            sourceWidth = 512,
            sourceHeight = 163
        },
        {
            -- bloque superior
            x=0,
            y=140,
            width=512,
            height=27,

            sourceX = 0,
            sourceY = 3,
            sourceWidth = 512,
            sourceHeight = 37
        },
        {
            -- bones flag
            x=121,
            y=351,
            width=257,
            height=100,

            sourceX = 32,
            sourceY = 17,
            sourceWidth = 311,
            sourceHeight = 130
        },
        {
            -- bones
            x=224,
            y=168,
            width=40,
            height=47,

            sourceX = 2,
            sourceY = 2,
            sourceWidth = 44,
            sourceHeight = 51
        },
        {
            -- boton retry
            x=306,
            y=452,
            width=68,
            height=49,

        },
        {
            -- boton retry_neg
            x=237,
            y=452,
            width=68,
            height=49,

        },
        {
            -- boton shop neg
            x=112,
            y=168,
            width=111,
            height=182,

        },
        {
            -- boton shop
            x=0,
            y=168,
            width=111,
            height=182,

        },
        {
            -- chapa
            x=379,
            y=168,
            width=128,
            height=47,

            sourceX = 7,
            sourceY = 6,
            sourceWidth = 142,
            sourceHeight = 61
        },
        {
            -- copa_neg
            x=428,
            y=263,
            width=65,
            height=46,

        },
        {
            -- copa_pos
            x=356,
            y=216,
            width=65,
            height=46,

        },
        {
            -- corazon
            x=375,
            y=452,
            width=52,
            height=48,

            sourceX = 11,
            sourceY = 10,
            sourceWidth = 74,
            sourceHeight = 70
        },
        {
            -- flecha levels
            x=323,
            y=263,
            width=98,
            height=85,

        },
        {
            -- flecha levels_neg
            x=224,
            y=263,
            width=98,
            height=85,

        },
        {
            -- game_google_neg
            x=265,
            y=168,
            width=65,
            height=46,

        },
        {
            -- game_google_pos
            x=290,
            y=216,
            width=65,
            height=46,

        },
        {
            -- game_ios_neg
            x=224,
            y=216,
            width=65,
            height=46,

        },
        {
            -- game_ios_pos
            x=428,
            y=216,
            width=65,
            height=46,

        },
        {
            -- piruletas
            x=0,
            y=351,
            width=120,
            height=129,

        },
        {
            -- separador_vert
            x=69,
            y=508,
            width=1,
            height=1,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 2,
            sourceHeight = 76
        },
        {
            -- vidas plus
            x=96,
            y=481,
            width=26,
            height=26,

            sourceX = 0,
            sourceY = 3,
            sourceWidth = 26,
            sourceHeight = 32
        },
        {
            -- vidas plus_press
            x=69,
            y=481,
            width=26,
            height=26,

            sourceX = 0,
            sourceY = 3,
            sourceWidth = 26,
            sourceHeight = 32
        },
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 512
}

SheetInfo.frameIndex =
{

    ["alert shop"] = 1,
    ["blocked"] = 2,
    ["blocked_press"] = 3,
    ["bloque inferior"] = 4,
    ["bloque superior"] = 5,
    ["bones flag"] = 6,
    ["bones"] = 7,
    ["boton retry"] = 8,
    ["boton retry_neg"] = 9,
    ["boton shop neg"] = 10,
    ["boton shop"] = 11,
    ["chapa"] = 12,
    ["copa_neg"] = 13,
    ["copa_pos"] = 14,
    ["corazon"] = 15,
    ["flecha levels"] = 16,
    ["flecha levels_neg"] = 17,
    ["game_google_neg"] = 18,
    ["game_google_pos"] = 19,
    ["game_ios_neg"] = 20,
    ["game_ios_pos"] = 21,
    ["piruletas"] = 22,
    ["separador_vert"] = 23,
    ["vidas plus"] = 24,
    ["vidas plus_press"] = 25,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
