
local loader = {}

local grp
local rotTransID, grpTransID


function loader:showHide(show, t)
	
	--if show then return end
	
	local newAlpha = 0
	if show then
		newAlpha = 1
	end
	
	transition.safePauseResume(rotTransID, not show)
	
	grp:toFront()
	
	grpTransID = transition.safeCancel(grpTransID)
	grpTransID = transition.to(grp, { time = t, alpha = newAlpha })
end

grp = display.newGroup()

local bg = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth *1.2, display.contentHeight *1.2)
bg:setFillColor(0, 0, 0, 0.8)
grp:insert(bg)
bg:addEventListener("touch", function() return true end)

local circle = display.newImage("assets/loader.png")
circle.x, circle.y = display.contentCenterX, display.contentCenterY
circle:scale(SCALE_DEFAULT, SCALE_DEFAULT)
grp:insert(circle)
	
local function rotate()
	circle.rotation = 0
	rotTransID = transition.to(circle, { time = 1000, rotation = 360, onComplete = rotate })
end
rotate()

loader:showHide(false, 0)


return loader