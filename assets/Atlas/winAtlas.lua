--
-- created with TexturePacker (http://www.texturepacker.com)
--
-- $TexturePacker:SmartUpdate:12e14db94dcee6dc8f6ec12fa38d7247$
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
            -- alertShop
            x=459,
            y=244,
            width=31,
            height=20,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 33,
            sourceHeight = 22
        },
        {
            -- achievementBlocked
            x=128,
            y=292,
            width=56,
            height=57,

        },
        {
            -- achievementBlockedPress
            x=71,
            y=292,
            width=56,
            height=57,

        },
        {
            -- winLowerBar
            x=0,
            y=0,
            width=512,
            height=145,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 512,
            sourceHeight = 163
        },
        {
            -- winUpperBar
            x=0,
            y=146,
            width=512,
            height=27,

            sourceX = 0,
            sourceY = 3,
            sourceWidth = 512,
            sourceHeight = 37
        },
        {
            -- bonesBg
            x=0,
            y=174,
            width=257,
            height=100,

            sourceX = 32,
            sourceY = 17,
            sourceWidth = 311,
            sourceHeight = 130
        },
        {
            -- bone
            x=459,
            y=313,
            width=40,
            height=47,

            sourceX = 2,
            sourceY = 2,
            sourceWidth = 44,
            sourceHeight = 51
        },
        {
            -- winReplayBtn
            x=0,
            y=438,
            width=88,
            height=71,

            sourceX = 3,
            sourceY = 2,
            sourceWidth = 96,
            sourceHeight = 81
        },
        {
            -- loseReplayBtn
            x=363,
            y=244,
            width=95,
            height=75,

            sourceX = 2,
            sourceY = 2,
            sourceWidth = 101,
            sourceHeight = 81
        },
        {
            -- shopBtn
            x=0,
            y=292,
            width=70,
            height=66,

            sourceX = 1,
            sourceY = 1,
            sourceWidth = 72,
            sourceHeight = 68
        },
        {
            -- ironSheet
            x=258,
            y=174,
            width=128,
            height=47,

            sourceX = 7,
            sourceY = 6,
            sourceWidth = 142,
            sourceHeight = 61
        },
        {
            -- achievementBtnPress
            x=202,
            y=361,
            width=65,
            height=46,

        },
        {
            -- achievementBtn
            x=155,
            y=408,
            width=65,
            height=46,

        },
        {
            -- heart
            x=71,
            y=361,
            width=64,
            height=60,

            sourceX = 5,
            sourceY = 4,
            sourceWidth = 74,
            sourceHeight = 70
        },
        {
            -- winLvlBtn
            x=258,
            y=222,
            width=104,
            height=69,

            sourceX = 1,
            sourceY = 4,
            sourceWidth = 108,
            sourceHeight = 73
        },
        {
            -- loseLvlBtn
            x=387,
            y=174,
            width=104,
            height=69,

            sourceX = 1,
            sourceY = 3,
            sourceWidth = 108,
            sourceHeight = 73
        },
        {
            -- androidLeaderboardBtnPress
            x=251,
            y=292,
            width=65,
            height=46,

        },
        {
            -- androidLeaderboardBtn
            x=136,
            y=361,
            width=65,
            height=46,

        },
        {
            -- iosLeaderboardBtnPress
            x=89,
            y=422,
            width=65,
            height=46,

        },
        {
            -- iosLeaderboardBtn
            x=185,
            y=275,
            width=65,
            height=46,

        },
        {
            -- emptyBone
            x=459,
            y=265,
            width=40,
            height=47,

            sourceX = 2,
            sourceY = 2,
            sourceWidth = 44,
            sourceHeight = 51
        },
        {
            -- lineSeparator
            x=492,
            y=174,
            width=2,
            height=76,

        },
        {
            -- addHeartsBtn
            x=89,
            y=469,
            width=26,
            height=26,

            sourceX = 0,
            sourceY = 3,
            sourceWidth = 26,
            sourceHeight = 32
        },
        {
            -- addHeartsBtnPress
            x=185,
            y=322,
            width=26,
            height=26,

            sourceX = 0,
            sourceY = 3,
            sourceWidth = 26,
            sourceHeight = 32
        },
		{
            -- lollipop
            x=0,
            y=361,
            width=70,
            height=76,

            sourceX = 11,
            sourceY = 3,
            sourceWidth = 92,
            sourceHeight = 80
        },
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 512
}

SheetInfo.frameIndex =
{

    ["alertShop"] = 1,
    ["achievementBlocked"] = 2,
    ["achievementBlockedPress"] = 3,
    ["winLowerBar"] = 4,
    ["winUpperBar"] = 5,
    ["bonesBg"] = 6,
    ["bone"] = 7,
    ["winReplayBtn"] = 8,
    ["loseReplayBtn"] = 9,
    ["shopBtn"] = 10,
    ["ironSheet"] = 11,
    ["achievementBtnPress"] = 12,
    ["achievementBtn"] = 13,
    ["heart"] = 14,
    ["winLvlBtn"] = 15,
    ["loseLvlBtn"] = 16,
    ["androidLeaderboardBtnPress"] = 17,
    ["androidLeaderboardBtn"] = 18,
    ["iosLeaderboardBtnPress"] = 19,
    ["iosLeaderboardBtn"] = 20,
    ["emptyBone"] = 21,
    ["lineSeparator"] = 22,
    ["addHeartsBtn"] = 23,
    ["addHeartsBtnPress"] = 24,
	["lollipop"] = 25,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
