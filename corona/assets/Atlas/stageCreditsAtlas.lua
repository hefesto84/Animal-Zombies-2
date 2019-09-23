--
-- created with TexturePacker (http://www.texturepacker.com)
--
-- $TexturePacker:SmartUpdate:19a4e79618a5001f5b0254e746669502$
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
            -- menuBtn
            x=0,
            y=889,
            width=104,
            height=71,

            sourceX = 1,
            sourceY = 2,
            sourceWidth = 108,
            sourceHeight = 73
        },
        {
            -- brokenGlass
            x=0,
            y=513,
            width=374,
            height=375,

        },
        {
            -- lowerLock
            x=105,
            y=889,
            width=92,
            height=67,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 96,
            sourceHeight = 69
        },
        {
            -- upperLock
            x=0,
            y=961,
            width=47,
            height=46,

        },
        {
            -- frame
            x=0,
            y=0,
            width=510,
            height=512,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 512,
            sourceHeight = 512
        },
        {
            -- logoAZ
            x=719,
            y=0,
            width=290,
            height=136,

            sourceX = 10,
            sourceY = 8,
            sourceWidth = 306,
            sourceHeight = 152
        },
        {
            -- logoTG
            x=511,
            y=0,
            width=139,
            height=188,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 141,
            sourceHeight = 188
        },
        {
            -- voidStage
            x=375,
            y=513,
            width=343,
            height=351,

        },
    },
    
    sheetContentWidth = 1024,
    sheetContentHeight = 1024
}

SheetInfo.frameIndex =
{

    ["menuBtn"] = 1,
    ["brokenGlass"] = 2,
    ["lowerLock"] = 3,
    ["upperLock"] = 4,
    ["frame"] = 5,
    ["logoAZ"] = 6,
    ["logoTG"] = 7,
    ["voidStage"] = 8,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
