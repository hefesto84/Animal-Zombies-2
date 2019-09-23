module(..., package.seeall)

local loll
local rake

local board = {}
math.randomseed(os.clock() *1000000)
boardSize = 0

local function tryToKill(x, y)
    if board[x][y][BOARD_CHARACTER_ID_POSITION] ~= 0 then
        board[x][y][BOARD_CHARACTER_POINTER].damage(5, "pig")
    end
end

function killByProximity(id)
    for x=1, BOARD_MAX_X do
        for y=1, BOARD_MAX_Y do
            
            if board[x][y][BOARD_CHARACTER_ID_POSITION] == id then
                
                --matarem a dreta i esquerra
                if x -1 >= 1 then
                    tryToKill(x -1, y)
                end
                if x +1 <= BOARD_MAX_X then
                    tryToKill(x +1, y)
                end
                    
                --matarem adalt i abaix
                if y -1 >= 1 then
                    tryToKill(x, y -1)
                end
                if y +1 <= BOARD_MAX_Y then
                    tryToKill(x, y +1)
                end
            end
        end
    end
end

local function alignZombies()
    for x=1, BOARD_MAX_X do
        for y=BOARD_MAX_Y, 1, -1 do
            local currentZombie = board[x][y][BOARD_CHARACTER_POINTER]
            if currentZombie ~= nil then
                currentZombie:toBack()
            end
        end
    end
    
    if loll.lollipopInstance ~= nil then
        loll.lollipopInstance:toFront()
    end
    if rake.rakeInstance ~= nil then
        rake.rakeInstance:toFront()
    end
end

function getPos(x, y)
    return ZOMBIE_MATRIX_COLUMN[x], ZOMBIE_MATRIX_ROW[y]
end

local function searchAndAdd(zombie)
    local found = 0
    local x, y
    
    while found == 0 do
        x = math.random(1,BOARD_MAX_X)
        y = math.random(1,BOARD_MAX_Y)
        
        if board[x][y][BOARD_CHARACTER_ID_POSITION]     == 0 then
           board[x][y][BOARD_CHARACTER_ID_POSITION]     = zombie.id
           board[x][y][BOARD_CHARACTER_NAME_POSITION]   = zombie.name
           board[x][y][BOARD_CHARACTER_POINTER]         = zombie
           zombie.x, zombie.y = getPos(x, y)
           
           found = 1
           boardSize = boardSize +1
           
           alignZombies()
           
           return
        end
    end
end

local function searchAndDel(zombie)
    for x=1, BOARD_MAX_X do
        for y=1, BOARD_MAX_Y do
            
            if board[x][y][BOARD_CHARACTER_ID_POSITION]     == zombie.id then
                
               board[x][y][BOARD_CHARACTER_ID_POSITION]     = 0
               board[x][y][BOARD_CHARACTER_NAME_POSITION]   = BOARD_CHARACTER_NAME_DEFAULT
               board[x][y][BOARD_CHARACTER_POINTER]         = nil
            
               boardSize = boardSize -1
                
               return
            end
        end
    end
end

function deleteAll()
    for x=1, BOARD_MAX_X do
        for y=1, BOARD_MAX_Y do
            if board[x][y][BOARD_CHARACTER_POINTER] ~= nil then
                board[x][y][BOARD_CHARACTER_POINTER].destroyZombie()
                
                board[x][y][BOARD_CHARACTER_ID_POSITION]    = 0
                board[x][y][BOARD_CHARACTER_NAME_POSITION]  = BOARD_CHARACTER_NAME_DEFAULT
                board[x][y][BOARD_CHARACTER_POINTER]        = nil
            end
        end
    end
    
    boardSize = 0
end

function addZombieInPos(zombie, x, y)
    if board[x][y][BOARD_CHARACTER_ID_POSITION]     == 0 then
        board[x][y][BOARD_CHARACTER_ID_POSITION]     = zombie.id
        board[x][y][BOARD_CHARACTER_NAME_POSITION]   = zombie.name
        board[x][y][BOARD_CHARACTER_POINTER]         = zombie
        zombie.x, zombie.y = getPos(x, y)
           
        boardSize = boardSize +1
        
        alignZombies()
           
        return
    else
        print("COULDN'T SET THE ".. zombie.zType .." IN POS ".. x .."x".. y)
    end    
end

function getZombieInPos(x, y)
    local z = board[x][y][BOARD_CHARACTER_POINTER]
    
    if z == nil then
        print("COULDN'T FIND ANY ZOMBIE IN POS ".. x .."x".. y)
    end
    
    return z
end

function add(zombie)
    searchAndAdd(zombie)
end

function del(zombie)
    searchAndDel(zombie)
end

function pause(isPause)
    for x=1, BOARD_MAX_X do
        for y=1, BOARD_MAX_Y do
            if board[x][y][BOARD_CHARACTER_POINTER] ~= nil then
                board[x][y][BOARD_CHARACTER_POINTER].pauseZombie(isPause)
            end
        end
    end
end

function hideAll()
    for x=1, BOARD_MAX_X do
        for y=1, BOARD_MAX_Y do
            if board[x][y][BOARD_CHARACTER_POINTER] ~= nil then
                board[x][y][BOARD_CHARACTER_POINTER].exitZombie()
            end
        end
    end
end

function init()
   for x=1, BOARD_MAX_X do
       board[x] = {}
       for y=1, BOARD_MAX_Y do
           board[x][y] = {}
           board[x][y][BOARD_CHARACTER_ID_POSITION]     = 0
           board[x][y][BOARD_CHARACTER_NAME_POSITION]   = BOARD_CHARACTER_NAME_DEFAULT
           board[x][y][BOARD_CHARACTER_POINTER]         = nil
       end
   end
   
    if loll == nil then
        loll = require "lollipop"
        rake = require "rake"
    end
end