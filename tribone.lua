module(..., package.seeall)


--  0: not played
--  1: 1 bone
--  2: 2 bones
--  3: 3 bones

function createTribone(x, y, value)
	local tb = display.newGroup()
	local myImageSheet = graphics.newImageSheet("assets/guiSheet/levelsIngameWinLose.png", AZ.atlas:getSheet())
        
        x = x - (35 * SCALE_DEFAULT)
        
        for i=1, 3 do
            local myBone
            
            if i <= value then
                myBone = display.newImage(myImageSheet, 16)
            else
                myBone = display.newImage(myImageSheet, 17)
            end
            
            myBone.x, myBone.y = x, 0
            myBone:scale(SCALE_DEFAULT, SCALE_DEFAULT)
            tb:insert(myBone)
            
            x = x + (35 * SCALE_DEFAULT)
        end
        
        tb.y = y
        
        return tb
end