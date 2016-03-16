--
-- created with TexturePacker (http://www.texturepacker.com)
--
-- $TexturePacker:SmartUpdate:963450e0bc11fea5298116d38ad26174$
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
            -- configBtn
            x=306,
            y=492,
            width=68,
            height=69,

            sourceX = 0,
            sourceY = 4,
            sourceWidth = 68,
            sourceHeight = 73
        },
        {
            -- fbBtn
            x=0,
            y=743,
            width=229,
            height=87,

        },
        {
            -- infoBtn
            x=375,
            y=492,
            width=66,
            height=69,

            sourceX = 0,
            sourceY = 4,
            sourceWidth = 68,
            sourceHeight = 73
        },
        {
            -- playBtn
            x=0,
            y=492,
            width=305,
            height=113,

        },
        {
            -- logo
            x=0,
            y=606,
            width=290,
            height=136,

            sourceX = 10,
            sourceY = 8,
            sourceWidth = 306,
            sourceHeight = 152
        },
        {
            -- landscape
            x=0,
            y=0,
            width=512,
            height=491,

            sourceX = 0,
            sourceY = 18,
            sourceWidth = 512,
            sourceHeight = 509
        },
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 1024
}

SheetInfo.frameIndex =
{

    ["configBtn"] = 1,
    ["fbBtn"] = 2,
    ["infoBtn"] = 3,
    ["playBtn"] = 4,
    ["logo"] = 5,
    ["landscape"] = 6,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
