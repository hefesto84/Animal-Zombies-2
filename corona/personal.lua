-- I/O Module
module(..., package.seeall)
require "constants"
require "emblemContainer"

-- IO files
genericInfo     = "user.json"    -- inclou dades de l'últim stage i nivell finalitzat, tips, configuracio i achievements
relativeLevels  = "19141e79cab839b8604bf70edbfcbfa47"           -- inclou dades dels tribones dels nivells de l'stage i dels storys. El format es: relativeLevels .. stage ..".json"
statistics      = "statistics"                                  -- inclou estadistiques de puntuacio dels nivells. El format es: statistics .. stage ..".json"
shopInfo        = "shopData.json"                               -- inclou el preu dels boosters d'armes amb coins i la informació de quins hi ha comprats o desbloquejats
bankInfo        = "bankData.json"                               -- inclou les dades sobre el preu amb moneda real de cada lot de coins


local function matchLanguage(lang)
    for i=1, #AZ.localization.languages do
        if lang == AZ.localization.languages[i] then
            return lang
        end
    end
    
    return "en"
end

local function getLocale()
    require "string"
    
    local locale
    
    if system.getInfo( "platformName" ) ~= "Android" then
        locale = system.getPreference( "ui", "language" ):lower()
        pos = string.find(locale,"-",0)
    else
        locale = system.getPreference( "locale", "language" ):lower()
        pos = string.find(locale,"_",0)
    end
    
    if(pos==nil) then
        return matchLanguage(locale)
    else
        -- substring fins a la posicio pos
        return matchLanguage(string.sub(locale, pos))
    end
end

-- Save personal data module
function savePersonalData(t, filename)
    local path = system.pathForFile(filename, system.DocumentsDirectory)
    local file = io.open(path, "w")

    if file then
        local contents = AZ.json.encode(t)
        file:write(contents)	
        io.close(file)
        return true
    else
        return false
    end
end

-- Load personal data module
function loadPersonalData(filename)
    local path = system.pathForFile(filename, system.DocumentsDirectory)
    local contents = ""	
    local myTable = {}	
    local file = io.open(path, "r")

    if file == nil then
        return nil
    end

    -- read all contents of file into a string
    local contents = file:read("*a")
    myTable = AZ.json.decode(contents);
    io.close(file)
    return myTable 
end

local function resetStats(stage)
    local myStatistics = {}

    for i=1, 9 do
        myStatistics[i] = { level = i, minScore = 0, maxScore = 0, totalScore = 0, medScore = 0, minTime = 0, maxTime = 0, totalTime = 0, medTime = 0, played = 0 }
    end
    savePersonalData(myStatistics, statistics .. stage .. ".json")
    
    return myStatistics
end

function resetStatistics(currentStage)
    if currentStage > 0 then
        return resetStats(currentStage)
    else
        for i=1, STAGES_COUNT do
            resetStats(i)
        end
        
        return
    end
end

function updateVersion(myInfo)
    local previousVersion = myInfo.version
    
    if previousVersion == nil then
        previousVersion = 1
    end
    
    -- en el primer condicional ha d'anar la ultima versió
    if previousVersion < AZ.lastVersion then
        -- per a cada actualització que afecti al genericInfo, s'ha d'afegir un nou condicional
        if previousVersion < 2 then
            myInfo.language = getLocale()
            AZ.currentLanguage = myInfo.language
            myInfo.day = os.time()
        end
        
        myInfo.version = AZ.lastVersion
        AZ.personal.savePersonalData(myInfo, genericInfo)
    end
    
    return myInfo
end

function updateAchievements(previousAchievements)
    local myAchievementsInfo = nil
    
    if previousAchievements ~= nil then
        myAchievementsInfo = previousAchievements
    else
        myAchievementsInfo = {}
    end
    
    if #myAchievementsInfo ~= #emblem_container then
        for i=#myAchievementsInfo +1, #emblem_container do
            myAchievementsInfo[i] = false
        end
        
        if previousAchievements ~= nil then
            local myInfo = AZ.personal.loadPersonalData(genericInfo)
            myInfo.achievements = myAchievementsInfo
            AZ.personal.savePersonalData(myInfo, genericInfo)
        else
            return myAchievementsInfo
        end    
    end
end

function resetPersonalData(data)
    local myGenericInfo = {}
    local oldGenericInfo = data
    
    if oldGenericInfo == nil then
        loadPersonalData(genericInfo)
    end
    
    if oldGenericInfo ~= nil then
        myGenericInfo.music = oldGenericInfo.music
        myGenericInfo.sound = oldGenericInfo.sound
        myGenericInfo.vibration = oldGenericInfo.vibration
        
        myGenericInfo.version = oldGenericInfo.version
        myGenericInfo.language = oldGenericInfo.language
        
        myGenericInfo.lastRateUsRequestDate = oldGenericInfo.lastRateUsRequestDate
        myGenericInfo.rated = oldGenericInfo.rated
        
        myGenericInfo.achievements = oldGenericInfo.achievements
    else
        myGenericInfo.music = 1
        myGenericInfo.sound = 1
        myGenericInfo.vibration = 1
        
        myGenericInfo.version = AZ.lastVersion
        myGenericInfo.language = getLocale()
        
        myGenericInfo.lastRateUsRequestDate = os.time()
        myGenericInfo.day = os.time()
        myGenericInfo.rated = false
        
        myGenericInfo.achievements = updateAchievements()
    end
        
    myGenericInfo.money = 0
    myGenericInfo.shopNewItems = 0
    myGenericInfo.weapons = {
            {
                name = SHOVEL_NAME,
                isBlocked = false,
                quantity = "∞"
            },
            {
                name = LIFE_BOX_NAME,
                isBlocked = true,
                quantity = 0
            },
            {
                name = STONE_NAME,
                isBlocked = true,
                quantity = 0
            },
            {
                name = ICE_CUBE_NAME,
                isBlocked = true,
                quantity = 0
            },
            {
                name = TRAP_NAME,
                isBlocked = true,
                quantity = 0
            },
            {
                name = RAKE_NAME,
                isBlocked = true,
                quantity = 0
            },
            {
                name = DEATH_BOX_NAME,
                isBlocked = true,
                quantity = 0
            },
            {
                name = HOSE_NAME,
                isBlocked = true,
                quantity = 0
            },
            {
                name = THUNDER_NAME,
                isBlocked = true,
                quantity = 0
            },
            {
                name = STINK_BOMB_NAME,
                isBlocked = true,
                quantity = 0
            },
            {
                name = GAVIOT_NAME,
                isBlocked = true,
                quantity = 0
            },
            {
                name = EARTHQUAKE_NAME,
                isBlocked = true,
                quantity = 0
            },
            {
                name = "life",
                isBlocked = false,
                quantity = 0
            }}
    myGenericInfo.lastStageFinished = 0
    myGenericInfo.lastLevelFinished = 0
    myGenericInfo.tips = { }
    
    AZ.personal.savePersonalData(myGenericInfo, genericInfo)

    for i = 1, STAGES_COUNT do
        createTribonesData(i)
    end
    
    return myGenericInfo
end

function createTribonesData(stage)
    local stageInfo = {}
    for i=1, 9 do
        stageInfo[i] = { tribones = 0, mustShowInfo = true, score = 0, time = -1 }
    end

    AZ.personal.savePersonalData(stageInfo, AZ.personal.relativeLevels .. stage ..".json")
    return stageInfo
end

function createShopData()
    local shopData = {
        shop = {
            weapons = {{
                name = STONE_NAME,
                unblocked = true,
                boosterType = 3,
                realQtt = 0,
                boosterData = {{
                    bought = false,
                    price = 90
                },
                {
                    bought = false,
                    price = 160
                },
                {
                    bought = false,
                    price = 240
                }},
                spriteIndex = 15,
                description = "stone_desc"
            },
            {
                name = ICE_CUBE_NAME,
                unblocked = true,
                boosterType = 3,
                realQtt = 0,
                boosterData = {{
                    bought = false,
                    price = 120
                },
                {
                    bought = false,
                    price = 220
                },
                {
                    bought = false,
                    price = 340
                }},
                spriteIndex = 11,
                description = "iceCube_desc"
            },
            {
                name = TRAP_NAME,
                unblocked = true,
                boosterType = 3,
                realQtt = 0,
                boosterData = {{
                    bought = false,
                    price = 120
                },
                {
                    bought = false,
                    price = 220
                },
                {
                    bought = false,
                    price = 340
                }},
                spriteIndex = 21,
                description = "trap_desc"
            },
            {
                name = RAKE_NAME,
                unblocked = true,
                boosterType = 3,
                realQtt = 0,
                boosterData = {{
                    bought = false,
                    price = 160
                },
                {
                    bought = false,
                    price = 300
                },
                {
                    bought = false,
                    price = 440
                }},
                spriteIndex = 17,
                description = "rake_desc"
            },
            {
                name = LIFE_BOX_NAME,
                unblocked = true,
                boosterType = 1,
                realQtt = 0,
                boosterData = {{
                    bought = false,
                    price = 180
                },
                {
                    bought = false,
                    price = 340
                },
                {
                    bought = false,
                    price = 500
                }},
                spriteIndex = 20,
                description = "lifeBox_desc"
            },
            {
                name = DEATH_BOX_NAME,
                unblocked = true,
                boosterType = 1,
                realQtt = 0,
                boosterData = {{
                    bought = false,
                    price = 180
                },
                {
                    bought = false,
                    price = 340
                },
                {
                    bought = false,
                    price = 500
                }},
                spriteIndex = 12,
                description = "deathBox_desc"
            },
            {
                name = HOSE_NAME,
                unblocked = true,
                boosterType = 1,
                realQtt = 0,
                boosterData = {{
                    bought = false,
                    price = 200
                },
                {
                    bought = false,
                    price = 380
                },
                {
                    bought = false,
                    price = 560
                }},
                spriteIndex = 13,
                description = "hose_desc"
            },
            {
                name = THUNDER_NAME,
                unblocked = true,
                boosterType = 1,
                realQtt = 0,
                boosterData = {{
                    bought = false,
                    price = 220
                },
                {
                    bought = false,
                    price = 400
                },
                {
                    bought = false,
                    price = 620
                }},
                spriteIndex = 10,
                description = "thunder_desc"
            },
            {
                name = STINK_BOMB_NAME,
                unblocked = true,
                boosterType = 1,
                realQtt = 0,
                boosterData = {{
                    bought = false,
                    price = 250
                },
                {
                    bought = false,
                    price = 480
                },
                {
                    bought = false,
                    price = 700
                }},
                spriteIndex = 2,
                description = "stinkBomb_desc"
            },
            {
                name = GAVIOT_NAME,
                unblocked = true,
                boosterType = 1,
                realQtt = 0,
                boosterData = {{
                    bought = false,
                    price = 270
                },
                {
                    bought = false,
                    price = 500
                },
                {
                    bought = false,
                    price = 780
                }},
                spriteIndex = 14,
                description = "gaviot_desc"
            },
            {
                name = EARTHQUAKE_NAME,
                unblocked = true,
                boosterType = 1,
                realQtt = 0,
                boosterData = {{
                    bought = false,
                    price = 300
                },
                {
                    bought = false,
                    price = 340
                },
                {
                    bought = false,
                    price = 800
                }},
                spriteIndex = 19,
                description = "earthquake_desc"
            },
            {
                name = "life",
                unblocked = true,
                boosterType = 7,
                realQtt = 5,
                boosterData = {{
                    bought = false,
                    price = 1500
                }},
                spriteIndex = 1,
                description = "life_desc"
            }}
        }
    }
    
    --savePersonalData(shopData, shopInfo)
end

function createBankData()
    local bankData = {
        bank = {
            items = {{
                    description ="bag_desc",
                    price = 0.89,
                    sheetIndex = 2,
                    qttGained = 140,
                    name = "bag"
                },
                {
                    description = "sack_desc",
                    price = 1.79,
                    sheetIndex = 9,
                    qttGained = 320,
                    name = "sack"
                },
                {
                    description = "briefcase_desc",
                    price = 4.99,
                    sheetIndex = 8,
                    qttGained = 800,
                    name = "briefcase"
                },
                {
                    description = "chest_desc",
                    price = 8.99,
                    sheetIndex = 6,
                    qttGained = 1700,
                    name = "chest"
                },
                {
                    description = "safe_desc",
                    price = 22.49,
                    sheetIndex = 5,
                    qttGained = 4500,
                    name = "safe"
                },
                {
                    description = "twitter_desc",
                    price = 0,
                    sheetIndex = 10,
                    qttGained = 80,
                    name = "twitter"
                },
                {
                    description = "facebook_desc",
                    price = 0,
                    sheetIndex = 7,
                    qttGained = 100,
                    name = "facebook"
                }}
        }
    }
    
    savePersonalData(bankData, bankInfo)
end
