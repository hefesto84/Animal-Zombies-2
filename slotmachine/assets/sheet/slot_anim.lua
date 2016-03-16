--
-- created with TexturePacker (http://www.texturepacker.com)
--
-- $TexturePacker:SmartUpdate:9d6eb4c5af3be5cafecd82b7203488fb$
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
            -- slot_efecto_mov_pq1
            x=93,
            y=2,
            width=89,
            height=205,

        },
        {
            -- slot_efecto_mov_pq2
            x=2,
            y=2,
            width=89,
            height=205,

        },
        {
            -- slot_efecto_mov_pq3
            x=2,
            y=209,
            width=87,
            height=205,

            sourceX = 1,
            sourceY = 0,
            sourceWidth = 89,
            sourceHeight = 205
        },
        {
            -- slot_efecto_mov_pq4
            x=91,
            y=209,
            width=83,
            height=205,

            sourceX = 3,
            sourceY = 0,
            sourceWidth = 89,
            sourceHeight = 205
        },
    },
    
    sheetContentWidth = 256,
    sheetContentHeight = 512
}

SheetInfo.frameIndex =
{

    ["slot_efecto_mov_pq1"] = 1,
    ["slot_efecto_mov_pq2"] = 2,
    ["slot_efecto_mov_pq3"] = 3,
    ["slot_efecto_mov_pq4"] = 4,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
