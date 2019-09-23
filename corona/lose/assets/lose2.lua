--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:593de65f7ef478b45502775c7cf61822:6833c17e88d96781bdbb9693941a6db8:5d45f060e0941d65e6b6ce820bc7919b$
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
            -- cacatua
            x=166,
            y=520,
            width=165,
            height=125,

            sourceX = 12,
            sourceY = 75,
            sourceWidth = 181,
            sourceHeight = 235
        },
        {
            -- cerdo
            x=330,
            y=770,
            width=165,
            height=103,

            sourceX = 11,
            sourceY = 98,
            sourceWidth = 181,
            sourceHeight = 235
        },
        {
            -- chihuahua
            x=328,
            y=874,
            width=165,
            height=97,

            sourceX = 9,
            sourceY = 103,
            sourceWidth = 181,
            sourceHeight = 235
        },
        {
            -- ciervo
            x=0,
            y=0,
            width=181,
            height=171,

            sourceX = 0,
            sourceY = 35,
            sourceWidth = 181,
            sourceHeight = 235
        },
        {
            -- conejo
            x=340,
            y=376,
            width=165,
            height=163,

            sourceX = 10,
            sourceY = 38,
            sourceWidth = 181,
            sourceHeight = 235
        },
        {
            -- fatkid
            x=166,
            y=870,
            width=161,
            height=117,

            sourceX = 13,
            sourceY = 83,
            sourceWidth = 181,
            sourceHeight = 233
        },
        {
            -- gato
            x=0,
            y=642,
            width=165,
            height=117,

            sourceX = 10,
            sourceY = 83,
            sourceWidth = 181,
            sourceHeight = 235
        },
        {
            -- girlscout
            x=0,
            y=770,
            width=163,
            height=151,

            sourceX = 11,
            sourceY = 49,
            sourceWidth = 181,
            sourceHeight = 233
        },
        {
            -- jaula
            x=166,
            y=384,
            width=165,
            height=135,

            sourceX = 9,
            sourceY = 68,
            sourceWidth = 181,
            sourceHeight = 235
        },
        {
            -- mofeta
            x=182,
            y=0,
            width=173,
            height=199,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 181,
            sourceHeight = 235
        },
        {
            -- oso
            x=0,
            y=172,
            width=171,
            height=163,

            sourceX = 8,
            sourceY = 41,
            sourceWidth = 181,
            sourceHeight = 235
        },
        {
            -- pato
            x=0,
            y=514,
            width=165,
            height=127,

            sourceX = 9,
            sourceY = 73,
            sourceWidth = 181,
            sourceHeight = 235
        },
        {
            -- pavo
            x=0,
            y=336,
            width=165,
            height=177,

            sourceX = 9,
            sourceY = 48,
            sourceWidth = 181,
            sourceHeight = 235
        },
        {
            -- perro
            x=332,
            y=540,
            width=165,
            height=115,

            sourceX = 9,
            sourceY = 85,
            sourceWidth = 181,
            sourceHeight = 235
        },
        {
            -- pez
            x=0,
            y=922,
            width=165,
            height=99,

            sourceX = 9,
            sourceY = 101,
            sourceWidth = 181,
            sourceHeight = 235
        },
        {
            -- queenie
            x=172,
            y=200,
            width=167,
            height=183,

            sourceX = 10,
            sourceY = 39,
            sourceWidth = 181,
            sourceHeight = 233
        },
        {
            -- rata
            x=332,
            y=656,
            width=165,
            height=113,

            sourceX = 8,
            sourceY = 87,
            sourceWidth = 181,
            sourceHeight = 235
        },
        {
            -- topo
            x=164,
            y=760,
            width=165,
            height=109,

            sourceX = 9,
            sourceY = 92,
            sourceWidth = 181,
            sourceHeight = 233
        },
        {
            -- tortuga
            x=166,
            y=646,
            width=165,
            height=113,

            sourceX = 9,
            sourceY = 86,
            sourceWidth = 181,
            sourceHeight = 235
        },
        {
            -- zarigüella
            x=340,
            y=200,
            width=165,
            height=175,

            sourceX = 8,
            sourceY = 24,
            sourceWidth = 181,
            sourceHeight = 235
        },
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 1024
}

SheetInfo.frameIndex =
{

    ["cacatua"] = 1,
    ["cerdo"] = 2,
    ["chihuahua"] = 3,
    ["ciervo"] = 4,
    ["conejo"] = 5,
    ["fatkid"] = 6,
    ["gato"] = 7,
    ["girlscout"] = 8,
    ["jaula"] = 9,
    ["mofeta"] = 10,
    ["oso"] = 11,
    ["pato"] = 12,
    ["pavo"] = 13,
    ["perro"] = 14,
    ["pez"] = 15,
    ["queenie"] = 16,
    ["rata"] = 17,
    ["topo"] = 18,
    ["tortuga"] = 19,
    ["zarigüella"] = 20,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
