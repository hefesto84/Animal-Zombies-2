--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:6b1e409d22e6e18b86a7161273847d1f:9ef83606afe85e132cb41d7ccfef7bbb:1296a9cb50733aa2a4ebfadfa3645b63$
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
            -- bomba fetida_S
            x=2,
            y=320,
            width=60,
            height=78,

            sourceX = 16,
            sourceY = 2,
            sourceWidth = 92,
            sourceHeight = 80
        },
        {
            -- cuadro_S
            x=160,
            y=306,
            width=57,
            height=55,

        },
        {
            -- electricidad_S
            x=180,
            y=2,
            width=72,
            height=78,

            sourceX = 9,
            sourceY = 1,
            sourceWidth = 92,
            sourceHeight = 80
        },
        {
            -- esfera_num_S
            x=219,
            y=306,
            width=31,
            height=20,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 33,
            sourceHeight = 22
        },
        {
            -- hielo_S
            x=88,
            y=84,
            width=82,
            height=64,

            sourceX = 4,
            sourceY = 9,
            sourceWidth = 92,
            sourceHeight = 80
        },
        {
            -- manguera_S
            x=2,
            y=2,
            width=90,
            height=56,

            sourceX = 1,
            sourceY = 15,
            sourceWidth = 92,
            sourceHeight = 80
        },
        {
            -- pala_S
            x=84,
            y=214,
            width=78,
            height=78,

            sourceX = 7,
            sourceY = 1,
            sourceWidth = 92,
            sourceHeight = 80
        },
        {
            -- palomas_S
            x=84,
            y=150,
            width=80,
            height=62,

            sourceX = 6,
            sourceY = 9,
            sourceWidth = 92,
            sourceHeight = 80
        },
        {
            -- pausa_S
            x=2,
            y=136,
            width=80,
            height=104,

        },
        {
            -- piedra_S
            x=164,
            y=242,
            width=78,
            height=62,

            sourceX = 7,
            sourceY = 11,
            sourceWidth = 92,
            sourceHeight = 80
        },
        {
            -- piruleta_S
            x=180,
            y=82,
            width=70,
            height=76,

            sourceX = 11,
            sourceY = 3,
            sourceWidth = 92,
            sourceHeight = 80
        },
        {
            -- rastrillo_S
            x=82,
            y=294,
            width=76,
            height=78,

            sourceX = 8,
            sourceY = 2,
            sourceWidth = 92,
            sourceHeight = 80
        },
        {
            -- terremoto_S
            x=94,
            y=2,
            width=84,
            height=80,

            sourceX = 4,
            sourceY = 0,
            sourceWidth = 92,
            sourceHeight = 80
        },
        {
            -- trampa buena_S
            x=2,
            y=242,
            width=78,
            height=76,

            sourceX = 7,
            sourceY = 4,
            sourceWidth = 92,
            sourceHeight = 80
        },
        {
            -- trampa explosiva_S
            x=166,
            y=160,
            width=78,
            height=80,

            sourceX = 6,
            sourceY = 0,
            sourceWidth = 92,
            sourceHeight = 80
        },
        {
            -- trampa_S
            x=2,
            y=60,
            width=84,
            height=74,

            sourceX = 3,
            sourceY = 4,
            sourceWidth = 92,
            sourceHeight = 80
        },
    },
    
    sheetContentWidth = 256,
    sheetContentHeight = 512
}

SheetInfo.frameIndex =
{

    ["bomba fetida_S"] = 1,
    ["cuadro_S"] = 2,
    ["electricidad_S"] = 3,
    ["esfera_num_S"] = 4,
    ["hielo_S"] = 5,
    ["manguera_S"] = 6,
    ["pala_S"] = 7,
    ["palomas_S"] = 8,
    ["pausa_S"] = 9,
    ["piedra_S"] = 10,
    ["piruleta_S"] = 11,
    ["rastrillo_S"] = 12,
    ["terremoto_S"] = 13,
    ["trampa buena_S"] = 14,
    ["trampa explosiva_S"] = 15,
    ["trampa_S"] = 16,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
