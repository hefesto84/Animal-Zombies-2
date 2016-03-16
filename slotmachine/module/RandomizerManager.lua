--[[

ooo        ooooo                 .o88o.                                                         
`88.       .888'                 888 `"                                                         
 888b     d'888   .ooooo.       o888oo  oooo  oooo  ooo. .oo.  .oo.    .ooooo.                  
 8 Y88. .P  888  d88' `88b       888    `888  `888  `888P"Y88bP"Y88b  d88' `88b                 
 8  `888'   888  888ooo888       888     888   888   888   888   888  888ooo888                 
 8    Y     888  888    .o       888     888   888   888   888   888  888    .o                 
o8o        o888o `Y8bod8P'      o888o    `V88V"V8P' o888o o888o o888o `Y8bod8P'                 
                                                                                                
                                                                                                
                                                                                                
  .o    .oooo.                                                                                  
o888   d8P'`Y8b                                                                                 
 888  888    888      oo.ooooo.   .ooooo.  oooo d8b oooo d8b  .ooooo.   .oooo.o                 
 888  888    888       888' `88b d88' `88b `888""8P `888""8P d88' `88b d88(  "8                 
 888  888    888       888   888 888   888  888      888     888   888 `"Y88b.                  
 888  `88b  d88'       888   888 888   888  888      888     888   888 o.  )88b                 
o888o  `Y8bd8P'        888bod8P' `Y8bod8P' d888b    d888b    `Y8bod8P' 8""888P'                 
                       888                                                                      
                      o888o                                                                     
                                                                                                
                                             oooo                                               
                                             `888                                               
oo.ooooo.   .oooo.   oooo d8b  .oooo.         888 .oo.    .oooo.    .ooooo.   .ooooo.  oooo d8b 
 888' `88b `P  )88b  `888""8P `P  )88b        888P"Y88b  `P  )88b  d88' `"Y8 d88' `88b `888""8P 
 888   888  .oP"888   888      .oP"888        888   888   .oP"888  888       888ooo888  888     
 888   888 d8(  888   888     d8(  888        888   888  d8(  888  888   .o8 888    .o  888     
 888bod8P' `Y888""8o d888b    `Y888""8o      o888o o888o `Y888""8o `Y8bod8P' `Y8bod8P' d888b    
 888                                                                                            
o888o                                                                                           
                                                                                                
                       .                             oooo                         .             
                     .o8                             `888                       .o8             
 .ooooo.   .oooo.o .o888oo  .oooo.        oo.ooooo.   888   .oooo.    .oooo.o .o888oo  .oooo.   
d88' `88b d88(  "8   888   `P  )88b        888' `88b  888  `P  )88b  d88(  "8   888   `P  )88b  
888ooo888 `"Y88b.    888    .oP"888        888   888  888   .oP"888  `"Y88b.    888    .oP"888  
888    .o o.  )88b   888 . d8(  888        888   888  888  d8(  888  o.  )88b   888 . d8(  888  
`Y8bod8P' 8""888P'   "888" `Y888""8o       888bod8P' o888o `Y888""8o 8""888P'   "888" `Y888""8o 
                                           888                                                  
                                          o888o                                                 
                                                                                                
 o8o               .o88o.                                          .o8       oooo               
 `"'               888 `"                                         "888       `888               
oooo  ooo. .oo.   o888oo  oooo  oooo  ooo. .oo.  .oo.    .oooo.    888oooo.   888   .ooooo.     
`888  `888P"Y88b   888    `888  `888  `888P"Y88bP"Y88b  `P  )88b   d88' `88b  888  d88' `88b    
 888   888   888   888     888   888   888   888   888   .oP"888   888   888  888  888ooo888    
 888   888   888   888     888   888   888   888   888  d8(  888   888   888  888  888    .o    
o888o o888o o888o o888o    `V88V"V8P' o888o o888o o888o `Y888""8o  `Y8bod8P' o888o `Y8bod8P'    
                                                                                                

]]

local RandomizerManager = {}

local level = 1
local stage = 1
local m = nil

-- Configura el RandomizerManager en base a uns paràmetres
function RandomizerManager:configure(lastLevelFinished, currentStage, prob)
    level = lastLevelFinished
    stage = currentStage
    m = prob
    math.randomseed(os.clock())
end

local function calculate(w,c)
    local r = {}
    
    local resultats = {}
    for i = 1, 3 do
        x = math.random(0,100)
        local k = 100
        local l = 0
        for j = 1, #w do
            resultats[j] = math.abs(w[j] - x)
        end
        
        for j = 1, #resultats do
            if resultats[j] < k then
                k = resultats[j]
                l = j
            end
        end
        
        r[i] = m.weapons[l]
    end
    
    if c == 2 then
        local p1 = math.random(3)
        if p1 == 2 then
            r[3] = r[2]
        else
            r[1] = r[2] 
        end
    end
    
    if c == 3 then
        r[3] = r[1]
        r[2] = r[1]
    end
    
    return r
end

-- Retorna un resultat en base al randomizer
function RandomizerManager:getResult()
    
    -- Decidim si farem sortir 2 o 3 elements iguals
    local combo = 1
    local _c = 0
    
    local p2 = m.prob2 * 100
    local p3 = m.prob3 * 100
    local p1 = 100 - (p2+p3)
    
    _c = math.random(100)
    if _c > 0 and _c < p1 then
        combo = 1
    elseif _c > p1 and _c < p1+p2 then
        combo = 2
    elseif _c > p1+p2 then
        combo = 3
    end
    local weaponp = {}
    local j = 0
    
    for i = 1, #m.weapons do
        weaponp[i] = j + (m.weapons[i].prob)*100
        j = weaponp[i]
    end
    
    local result = calculate(weaponp, combo)
    
    return result
end

return RandomizerManager

