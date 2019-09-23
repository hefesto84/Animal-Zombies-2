module(..., package.seeall)


--  0: not played
--  1: 1 bone
--  2: 2 bones
--  3: 3 bones

function createTribone(myImageSheet, x, y, value, _S, index)
	local tb = display.newGroup()
        
		index = index or 7
        x = x - (37 * _S)
        
        for i=1, 3 do
            local myBone
            
            if i <= value then
                myBone = display.newImage(myImageSheet, index)
                myBone.alpha = 1
            else
                myBone = display.newImage(myImageSheet, index)
                myBone.alpha = 0
            end
            
            myBone.x, myBone.y = x, 0
            myBone:scale(_S, _S)
            tb:insert(myBone)
            
            x = x + (37 * _S)
        end
        
        tb.y = y
        
        return tb
end

