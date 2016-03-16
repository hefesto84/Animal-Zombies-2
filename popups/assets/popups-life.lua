--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:70eaf40f516a1f1c72e931e5f2c6aa91:8f23166cb991132c3bbe5ea40cdae644:8733ede597a7f58ca8d29f7f414f733a$
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
            -- button_empty_life
            x=0,
            y=799,
            width=360,
            height=112,

            sourceX = 14,
            sourceY = 14,
            sourceWidth = 388,
            sourceHeight = 139
        },
        {
            -- button_empty_life_inactive
            x=0,
            y=686,
            width=360,
            height=112,

            sourceX = 14,
            sourceY = 14,
            sourceWidth = 388,
            sourceHeight = 139
        },
        {
            -- button_empty_life_press
            x=0,
            y=573,
            width=360,
            height=112,

            sourceX = 14,
            sourceY = 14,
            sourceWidth = 388,
            sourceHeight = 139
        },
        {
            -- button_empty_life_press_inactive
            x=0,
            y=460,
            width=360,
            height=112,

            sourceX = 14,
            sourceY = 14,
            sourceWidth = 388,
            sourceHeight = 139
        },
        {
            -- button_facebook
            x=0,
            y=345,
            width=360,
            height=114,

            sourceX = 6,
            sourceY = 0,
            sourceWidth = 372,
            sourceHeight = 115
        },
        {
            -- button_facebook_nolife
            x=0,
            y=230,
            width=360,
            height=114,

            sourceX = 6,
            sourceY = 0,
            sourceWidth = 372,
            sourceHeight = 115
        },
        {
            -- button_facebook_press
            x=0,
            y=115,
            width=360,
            height=114,

            sourceX = 6,
            sourceY = 0,
            sourceWidth = 372,
            sourceHeight = 115
        },
        {
            -- button_facebook_press_nolife
            x=0,
            y=0,
            width=360,
            height=114,

            sourceX = 6,
            sourceY = 0,
            sourceWidth = 372,
            sourceHeight = 115
        },
        {
            -- cerrar
            x=361,
            y=110,
            width=44,
            height=44,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 46,
            sourceHeight = 46
        },
        {
            -- vida_empty
            x=422,
            y=55,
            width=60,
            height=54,

            sourceX = 4,
            sourceY = 6,
            sourceWidth = 71,
            sourceHeight = 66
        },
        {
            -- vida_future
            x=361,
            y=0,
            width=62,
            height=54,

            sourceX = 4,
            sourceY = 6,
            sourceWidth = 71,
            sourceHeight = 66
        },
        {
            -- vida_next
            x=361,
            y=55,
            width=60,
            height=54,

            sourceX = 6,
            sourceY = 6,
            sourceWidth = 71,
            sourceHeight = 66
        },
        {
            -- vida_now
            x=424,
            y=0,
            width=60,
            height=54,

            sourceX = 6,
            sourceY = 6,
            sourceWidth = 71,
            sourceHeight = 66
        },
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 1024
}

SheetInfo.frameIndex =
{

    ["button_empty_life"] = 1,
    ["button_empty_life_inactive"] = 2,
    ["button_empty_life_press"] = 3,
    ["button_empty_life_press_inactive"] = 4,
    ["button_facebook"] = 5,
    ["button_facebook_nolife"] = 6,
    ["button_facebook_press"] = 7,
    ["button_facebook_press_nolife"] = 8,
    ["cerrar"] = 9,
    ["vida_empty"] = 10,
    ["vida_future"] = 11,
    ["vida_next"] = 12,
    ["vida_now"] = 13,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
