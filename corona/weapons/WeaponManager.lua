local WeaponManager = {}

local _weapons = {}
local _size = 0

function WeaponManager:init(shovelsAmount, requiredWeapons)
    _weapons = nil
    _weapons = {}
    
	local function isRequiredWeapon(wName)
		
		if not requiredWeapons then return false end
		
		for i = 1, #requiredWeapons do
			if requiredWeapons[i] == wName then
				return true
			end
		end
		return false
	end
	
    for i=1, #AZ.userInfo.weapons do
        local w = table.copyDictionary(AZ.userInfo.weapons[i])
        
        if AZ.isUnlimitedAmmo or (not w.isBlocked and w.quantity ~= "0") or isRequiredWeapon(w.name) then
            if AZ.isUnlimitedAmmo then
                w.quantity = 1
			elseif w.name == SHOVEL_NAME then
				w.quantity = shovelsAmount or tonumber(w.quantity)
            elseif AZ.userInfo.weapons[i].isBlocked and w.name == unlockedWeaponName then
                w.quantity = 0
            else
                w.quantity = tonumber(w.quantity)
            end
            
            table.insert(_weapons, w)
        end
    end
    _size = #_weapons
end

function WeaponManager:getWeaponAmount(name)
    for i=1,#_weapons do
       if _weapons[i].name == name then
           return _weapons[i].quantity
       end
   end
   print("WARNING", "", "Tried to get weapon '".. tostring(name) .."' amount but not found!")
   return -1
end

function WeaponManager:updateWeaponAmount(name, amount)
   if AZ.isUnlimitedAmmo then
       return 1
   end
   
   amount = amount or -1
   
   for i=1,#_weapons do
       if _weapons[i].name == name then
           _weapons[i].quantity = _weapons[i].quantity + amount
           return _weapons[i].quantity
       end
   end
   print("WARNING", "", "Tried to update weapon '".. tostring(name) .."' amount but not found!")
   return -1
end

function WeaponManager:getRandomWeapon()
    math.randomseed(os.time())
    return _weapons[math.random(1, #_weapons)]
end

function WeaponManager:getByName(name)
   for i=1,#_weapons do
       if _weapons[i].name == name then
           return _weapons[i]
       end
   end
end

function WeaponManager:getById(id)
    return _weapons[id]
end

function WeaponManager:size()
   return _size
end

function WeaponManager:list()
    return _weapons
end

return WeaponManager
