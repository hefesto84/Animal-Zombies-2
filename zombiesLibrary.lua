module(..., package.seeall)

-- modul exclusiu per als tipus de zombies

-- tipus de comportament
ZOMBIE_BEHAVIOUR_NORMAL     = "normal"  -- zombies normals
ZOMBIE_BEHAVIOUR_KINDLY     = "kindly"  -- zombies "bons"
ZOMBIE_BEHAVIOUR_HEAVY      = "heavy"   -- zombies durs
ZOMBIE_BEHAVIOUR_SPECIAL    = "special" -- zombies especials [porc, rata]

-- noms de zombies
ZOMBIE_RABBIT_NAME      = "rabbit"
ZOMBIE_MOLE_NAME        = "mole"
ZOMBIE_DOG_NAME         = "dog"
ZOMBIE_PARROT_NAME      = "parrot"
ZOMBIE_PIG_NAME         = "pig"
ZOMBIE_CAT_NAME         = "cat"
ZOMBIE_FISH_NAME        = "fish"
ZOMBIE_TORTOISE_NAME    = "tortoise"
ZOMBIE_QUEEN_NAME       = "queen"
ZOMBIE_CHIHUAHUA_NAME   = "chihuahua"
ZOMBIE_DUCK_NAME        = "duck"
ZOMBIE_TURKEY_NAME      = "turkey"
ZOMBIE_CAGE_NAME        = "cage"
ZOMBIE_RAT_NAME         = "rat"
ZOMBIE_POSSUM_NAME      = "possum"
ZOMBIE_BEAR_NAME        = "bear"
ZOMBIE_MOOSE_NAME       = "moose"
ZOMBIE_SKUNK_NAME       = "skunk"
ZOMBIE_GIRL_SCOUT_NAME  = "girlScout"
ZOMBIE_UTER_NAME        = "uter"

-- tipus de zombies
ZOMBIE_RABBIT       = nil
ZOMBIE_MOLE         = nil
ZOMBIE_DOG          = nil
ZOMBIE_PARROT       = nil
ZOMBIE_PIG          = nil
ZOMBIE_CAT          = nil
ZOMBIE_FISH         = nil
ZOMBIE_TORTOISE     = nil
ZOMBIE_QUEEN        = nil
ZOMBIE_CHIHUAHUA    = nil
ZOMBIE_DUCK         = nil
ZOMBIE_TURKEY       = nil
ZOMBIE_CAGE         = nil
ZOMBIE_RAT          = nil
ZOMBIE_POSSUM       = nil
ZOMBIE_BEAR         = nil
ZOMBIE_MOOSE        = nil
ZOMBIE_SKUNK        = nil
ZOMBIE_GIRL_SCOUT   = nil
ZOMBIE_UTER         = nil

function getZombie(zombieName)
    if zombieName == ZOMBIE_RABBIT_NAME then
        if ZOMBIE_RABBIT == nil then
            ZOMBIE_RABBIT = { type = ZOMBIE_RABBIT_NAME, lifes = 1, fullSizeIndex = 21, wResistant = {}, behaviour = ZOMBIE_BEHAVIOUR_NORMAL, anim = AZ.animsLibrary.rabbitAnim(), sound = AZ.soundLibrary.rabbitSound }
        end
        return ZOMBIE_RABBIT
		
    elseif zombieName == ZOMBIE_MOLE_NAME then
        if ZOMBIE_MOLE == nil then
            ZOMBIE_MOLE = { type = ZOMBIE_MOLE_NAME, lifes = 1, fullSizeIndex = 34, wResistant = {}, behaviour = ZOMBIE_BEHAVIOUR_KINDLY, anim = AZ.animsLibrary.moleAnim(), sound = AZ.soundLibrary.moleSound }
        end
        return ZOMBIE_MOLE
		
    elseif zombieName == ZOMBIE_DOG_NAME then
        if ZOMBIE_DOG == nil then
            ZOMBIE_DOG = { type = ZOMBIE_DOG_NAME, lifes = 1, fullSizeIndex = 29, wResistant = {}, behaviour = ZOMBIE_BEHAVIOUR_NORMAL, anim = AZ.animsLibrary.dogAnim(), sound = AZ.soundLibrary.dogSound }
        end
        return ZOMBIE_DOG
		
    elseif zombieName == ZOMBIE_PARROT_NAME then
        if ZOMBIE_PARROT == nil then
            ZOMBIE_PARROT = { type = ZOMBIE_PARROT_NAME, lifes = 1, fullSizeIndex = 18, wResistant = {}, behaviour = ZOMBIE_BEHAVIOUR_NORMAL, anim = AZ.animsLibrary.parrotAnim(), sound = AZ.soundLibrary.parrotSound }
        end
        return ZOMBIE_PARROT
		
    elseif zombieName == ZOMBIE_PIG_NAME then
        if ZOMBIE_PIG == nil then
            ZOMBIE_PIG = { type = ZOMBIE_PIG_NAME, lifes = 1, fullSizeIndex = 19, wResistant = {SHOVEL_NAME, STONE_NAME, HOSE_NAME, EXPLOSION_PIG_NAME, EXPLOSION_SKUNK_NAME, STINK_BOMB_NAME}, behaviour = ZOMBIE_BEHAVIOUR_SPECIAL, anim = AZ.animsLibrary.pigAnim(), sound = AZ.soundLibrary.pigSound }
        end
        return ZOMBIE_PIG
		
    elseif zombieName == ZOMBIE_CAT_NAME then
        if ZOMBIE_CAT == nil then
            ZOMBIE_CAT = { type = ZOMBIE_CAT_NAME, lifes = 7, fullSizeIndex = 23, wResistant = {}, behaviour = ZOMBIE_BEHAVIOUR_NORMAL, anim = AZ.animsLibrary.catAnim(), sound = AZ.soundLibrary.catSound }
        end
        return ZOMBIE_CAT
		
    elseif zombieName == ZOMBIE_FISH_NAME then
        if ZOMBIE_FISH == nil then
            ZOMBIE_FISH = { type = ZOMBIE_FISH_NAME, lifes = 1, fullSizeIndex = 30, wResistant = {HOSE_NAME}, behaviour = ZOMBIE_BEHAVIOUR_NORMAL, anim = AZ.animsLibrary.fishAnim(), sound = AZ.soundLibrary.fishSound }
        end
        return ZOMBIE_FISH
		
    elseif zombieName == ZOMBIE_TORTOISE_NAME then
        if ZOMBIE_TORTOISE == nil then
            ZOMBIE_TORTOISE = { type = ZOMBIE_TORTOISE_NAME, lifes = 2, fullSizeIndex = 35, wResistant = {}, behaviour = ZOMBIE_BEHAVIOUR_HEAVY, anim = AZ.animsLibrary.tortoiseAnim(), sound = AZ.soundLibrary.tortoiseSound }
        end
        return ZOMBIE_TORTOISE
		
    elseif zombieName == ZOMBIE_QUEEN_NAME then
        if ZOMBIE_QUEEN == nil then
            ZOMBIE_QUEEN = { type = ZOMBIE_QUEEN_NAME, lifes = 1, fullSizeIndex = 31, wResistant = {}, behaviour = ZOMBIE_BEHAVIOUR_KINDLY, anim = AZ.animsLibrary.queenAnim(), sound = AZ.soundLibrary.queenSound }
        end
        return ZOMBIE_QUEEN
		
    elseif zombieName == ZOMBIE_CHIHUAHUA_NAME then
        if ZOMBIE_CHIHUAHUA == nil then
            ZOMBIE_CHIHUAHUA = { type = ZOMBIE_CHIHUAHUA_NAME, lifes = 1, fullSizeIndex = 20, wResistant = {}, behaviour = ZOMBIE_BEHAVIOUR_NORMAL, anim = AZ.animsLibrary.chihuahuaAnim(), sound = AZ.soundLibrary.chihuahuaSound }
        end
        return ZOMBIE_CHIHUAHUA
		
    elseif zombieName == ZOMBIE_DUCK_NAME then
        if ZOMBIE_DUCK == nil then
            ZOMBIE_DUCK = { type = ZOMBIE_DUCK_NAME, lifes = 1, fullSizeIndex = 27, wResistant = {}, behaviour = ZOMBIE_BEHAVIOUR_NORMAL, anim = AZ.animsLibrary.duckAnim(), sound = AZ.soundLibrary.duckSound }
        end
        return ZOMBIE_DUCK
		
    elseif zombieName == ZOMBIE_TURKEY_NAME then
        if ZOMBIE_TURKEY == nil then
            ZOMBIE_TURKEY = { type = ZOMBIE_TURKEY_NAME, lifes = 1, fullSizeIndex = 28, wResistant = {}, behaviour = ZOMBIE_BEHAVIOUR_NORMAL, anim = AZ.animsLibrary.turkeyAnim(), sound = AZ.soundLibrary.turkeySound }
        end
        return ZOMBIE_TURKEY
		
    elseif zombieName == ZOMBIE_CAGE_NAME then
        if ZOMBIE_CAGE == nil then
            ZOMBIE_CAGE = { type = ZOMBIE_CAGE_NAME, lifes = 3, fullSizeIndex = 33, wResistant = {}, behaviour = ZOMBIE_BEHAVIOUR_HEAVY, anim = AZ.animsLibrary.cageAnim(), sound = AZ.soundLibrary.cageSound }
        end
        return ZOMBIE_CAGE
		
    elseif zombieName == ZOMBIE_RAT_NAME then
        if ZOMBIE_RAT == nil then
            ZOMBIE_RAT = { type = ZOMBIE_RAT_NAME, lifes = 1, fullSizeIndex = 32, wResistant = {}, behaviour = ZOMBIE_BEHAVIOUR_SPECIAL, anim = AZ.animsLibrary.ratAnim(), sound = AZ.soundLibrary.ratSound }
        end
        return ZOMBIE_RAT 
		
    elseif zombieName == ZOMBIE_POSSUM_NAME then
        if ZOMBIE_POSSUM == nil then
            ZOMBIE_POSSUM = { type = ZOMBIE_POSSUM_NAME, lifes = 1, fullSizeIndex = 36, wResistant = {}, behaviour = ZOMBIE_BEHAVIOUR_SPECIAL, anim = AZ.animsLibrary.possumAnim(), sound = AZ.soundLibrary.possumSound }
        end
        return ZOMBIE_POSSUM
		
    elseif zombieName == ZOMBIE_BEAR_NAME then
        if ZOMBIE_BEAR == nil then
			ZOMBIE_BEAR = { type = ZOMBIE_BEAR_NAME, lifes = 10, fullSizeIndex = 26, wResistant = { SHOVEL_NAME, RAKE_NAME, STONE_NAME, TRAP_NAME, GAVIOT_NAME, STINK_BOMB_NAME, HOSE_NAME, LIFE_BOX_NAME, DEATH_BOX_NAME, EXPLOSION_PIG_NAME }, behaviour = ZOMBIE_BEHAVIOUR_SPECIAL, anim = AZ.animsLibrary.bearAnim(), sound = AZ.soundLibrary.bearSound } 
        end
        return ZOMBIE_BEAR
		
    elseif zombieName == ZOMBIE_MOOSE_NAME then
        if ZOMBIE_MOOSE == nil then
            ZOMBIE_MOOSE = { type = ZOMBIE_MOOSE_NAME, lifes = 5, fullSizeIndex = 17, wResistant = { SHOVEL_NAME, RAKE_NAME, STONE_NAME, TRAP_NAME, GAVIOT_NAME, STINK_BOMB_NAME, HOSE_NAME, LIFE_BOX_NAME, DEATH_BOX_NAME, EXPLOSION_PIG_NAME }, behaviour = ZOMBIE_BEHAVIOUR_SPECIAL, anim = AZ.animsLibrary.mooseAnim(), sound = AZ.soundLibrary.mooseSound }
        end
        return ZOMBIE_MOOSE
		
    elseif zombieName == ZOMBIE_SKUNK_NAME then
        if ZOMBIE_SKUNK == nil then
            ZOMBIE_SKUNK = { type = ZOMBIE_SKUNK_NAME, lifes = 1, fullSizeIndex = 25, wResistant = { STINK_BOMB_NAME }, behaviour = ZOMBIE_BEHAVIOUR_SPECIAL, anim = AZ.animsLibrary.skunkAnim(), sound = AZ.soundLibrary.skunkSound }
        end
        return ZOMBIE_SKUNK       
		
    elseif zombieName == ZOMBIE_GIRL_SCOUT_NAME then
        if ZOMBIE_GIRL_SCOUT == nil then
            ZOMBIE_GIRL_SCOUT = { type = ZOMBIE_GIRL_SCOUT_NAME, lifes = 1, fullSizeIndex = 24, wResistant = {}, behaviour = ZOMBIE_BEHAVIOUR_KINDLY, anim = AZ.animsLibrary.girlScoutAnim(), sound = AZ.soundLibrary.girlScoutSound }
        end
        return ZOMBIE_GIRL_SCOUT
		
    elseif zombieName == ZOMBIE_UTER_NAME then
        if ZOMBIE_UTER == nil then
            ZOMBIE_UTER = { type = ZOMBIE_UTER_NAME, lifes = 1, fullSizeIndex = 22, wResistant = {}, behaviour = ZOMBIE_BEHAVIOUR_KINDLY, anim = AZ.animsLibrary.uterAnim(), sound = AZ.soundLibrary.uterSound }
        end
        return ZOMBIE_UTER
		
    else
        print("ERROR!", "Zombie ".. tostring(zombieName) .." requested doesn't exist!")
    end    
end

function freeZombieMemory(zType)
    if zType ~= nil then
        --print("Let's free memory: zombie ".. zType.type)
        display.remove(zType)
    end
    
    return nil
end

function cleanUp()
    ZOMBIE_RABBIT       = freeZombieMemory(ZOMBIE_RABBIT)
    ZOMBIE_MOLE         = freeZombieMemory(ZOMBIE_MOLE)
    ZOMBIE_DOG          = freeZombieMemory(ZOMBIE_DOG)
    ZOMBIE_PARROT       = freeZombieMemory(ZOMBIE_PARROT)
    ZOMBIE_PIG          = freeZombieMemory(ZOMBIE_PIG)
    ZOMBIE_CAT          = freeZombieMemory(ZOMBIE_CAT)
    ZOMBIE_FISH         = freeZombieMemory(ZOMBIE_FISH)
    ZOMBIE_TORTOISE     = freeZombieMemory(ZOMBIE_TORTOISE)
    ZOMBIE_QUEEN        = freeZombieMemory(ZOMBIE_QUEEN)
    ZOMBIE_CHIHUAHUA    = freeZombieMemory(ZOMBIE_CHIHUAHUA)
    ZOMBIE_DUCK         = freeZombieMemory(ZOMBIE_DUCK)
    ZOMBIE_TURKEY       = freeZombieMemory(ZOMBIE_TURKEY)
    ZOMBIE_CAGE         = freeZombieMemory(ZOMBIE_CAGE)
    ZOMBIE_RAT          = freeZombieMemory(ZOMBIE_RAT)
    ZOMBIE_POSSUM       = freeZombieMemory(ZOMBIE_POSSUM)
    ZOMBIE_BEAR         = freeZombieMemory(ZOMBIE_BEAR)
    ZOMBIE_MOOSE        = freeZombieMemory(ZOMBIE_MOOSE)
    ZOMBIE_SKUNK        = freeZombieMemory(ZOMBIE_SKUNK)
    ZOMBIE_GIRL_SCOUT   = freeZombieMemory(ZOMBIE_GIRL_SCOUT)
    ZOMBIE_UTER         = freeZombieMemory(ZOMBIE_UTER)
    
    AZ.animsLibrary.cleanUp()
end