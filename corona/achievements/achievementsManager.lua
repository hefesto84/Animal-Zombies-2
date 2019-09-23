
local achievementsMngr = {}

achievementsMngr.dict 				= {}
achievementsMngr.unlocked 			= {}
achievementsMngr.perLevelWeapons 	= {}
achievementsMngr.perLevelZombies 	= {}
achievementsMngr.gameNetwork 		= require "gameNetwork"
achievementsMngr.loggedIntoGC 		= false
achievementsMngr.gameServiceName 	= nil
achievementsMngr.savedAchievements	= {}


local function gameNetworkListener(event)
	AZ.utils.print(event, "gameNetworkEvent")
end

function achievementsMngr:sendAchievementToGC(achievement, showCompletionBanner)
	
	if (system.getInfo("platformName") == "Android") then
		achievementsMngr.gameNetwork.request( "unlockAchievement",
			{
				achievement =
				{
					identifier = achievement.googlePlayID,
				},
				listener=gameNetworkListener
			})
	else
		achievementsMngr.gameNetwork.request("unlockAchievement",{achievement = {identifier=achievement.name, percentComplete=100, showsCompletionBanner= showCompletionBanner }, listener=gameNetworkListener})
	end
	
end

local function sendAchievement(achievement, showCompletionBanner)
	
	if achievementsMngr.loggedIntoGC then
		-- enviem l'achievement
		
		achievementsMngr:sendAchievementToGC(achievement, showCompletionBanner)
		
		for i = 1, #achievementsMngr.savedAchievements do
			if achievementsMngr.savedAchievements[i] == achievement then
				table.remove(achievementsMngr.savedAchievements, i)
			end
		end
		
		return true
	else
		
		achievementsMngr:connectToGC(function() sendAchievement(achievement, false) end)
		
		table.insert(achievementsMngr.savedAchievements, achievement)
		return false
	end
end

local function unlockAchievement(achievement)
	
	if not achievement.isUnlocked then
		achievement.isUnlocked = true
		AZ.utils.print(achievement.name, "\t\tdesbloquegem")
		table.insert(achievementsMngr.unlocked, achievement.name)
		
		AZ.userInfo.achievements = achievementsMngr.dict
		
		return sendAchievement(achievement, true)
	end
	return false
end

local function addParameterAndCheckAchievements(param, amountKey)
	
	if not param then return end
	
	param[amountKey] = param[amountKey] +1
	
	for i = 1, #param.amounts do
		if param.amounts[i].amount <= param[amountKey] then
			unlockAchievement(param.amounts[i])
		else
			return
		end
	end
end

function achievementsMngr:getUnlocked()
	local unlocked = table.copyDictionary(achievementsMngr.unlocked)
	achievementsMngr.unlocked = {}
	
	return unlocked
end

function achievementsMngr:weaponUsed(wName)
	
	if wName == SHOVEL_NAME then return end
	
	if not achievementsMngr.dict or not achievementsMngr.dict.weapons then
		return
	end
	
	addParameterAndCheckAchievements(achievementsMngr.dict.weapons, "totalUsed")
	addParameterAndCheckAchievements(achievementsMngr.dict.weapons.types[wName], "used")
	
	if not achievementsMngr.dict.perLevel.weapons then
		return
	end
	
	addParameterAndCheckAchievements(achievementsMngr.dict.perLevel.weapons, "totalUsed")
	addParameterAndCheckAchievements(achievementsMngr.dict.perLevel.weapons.types[wName], "used")
end

function achievementsMngr:zombieKilled(zType, how)
	
	if not achievementsMngr.dict or not achievementsMngr.dict.zombies then
		return
	end
	
	addParameterAndCheckAchievements(achievementsMngr.dict.zombies, "totalKills")
	addParameterAndCheckAchievements(achievementsMngr.dict.zombies.types[zType], "kills")
	
	if not achievementsMngr.dict.perLevel.zombies then
		return
	end
	
	addParameterAndCheckAchievements(achievementsMngr.dict.perLevel.zombies, "totalKills")
	addParameterAndCheckAchievements(achievementsMngr.dict.perLevel.zombies.types[zType], "kills")
end

function achievementsMngr:combo(comboAmount)

	if not achievementsMngr.dict or not achievementsMngr.dict.misc or not achievementsMngr.dict.misc.combos then
		return
	end
	
	local combos = achievementsMngr.dict.misc.combos.amounts
	
	for i = 1, #combos do
		if combos[i].amount <= comboAmount then
			unlockAchievement(achievementsMngr.dict.misc.combos.amounts[i])
		end
	end
end

function achievementsMngr:countStageFinished(stage)
	unlockAchievement(achievementsMngr.dict.stages.completed.amounts[stage])
end

function achievementsMngr:unblockGoldenBone(stage)
	unlockAchievement(achievementsMngr.dict.stages.fullbones.amounts[stage])
end

function achievementsMngr:levelPlayed(hasWon)
	
	addParameterAndCheckAchievements(achievementsMngr.dict.games, "totalGames")
	
	if hasWon then
		addParameterAndCheckAchievements(achievementsMngr.dict.games.win, "totalWin")
	else
		addParameterAndCheckAchievements(achievementsMngr.dict.games.lose, "totalLose")
	end	
end

local function sendSavedAchievements()
	
	local achievementsToSend = table.copyDictionary(achievementsMngr.savedAchievements)
	achievementsMngr.savedAchievements = {}
	
	for i = 1, #achievementsToSend do
		sendAchievement(achievementsToSend[i], false)	
	end
end

--Funcio de callback que controla que ens haguem loguejat al Game Center d'Apple
function achievementsMngr.loginListener(event)
	if event.data then
		achievementsMngr.loggedIntoGC = true
		print("Estas loguejat al Game Center d'Apple")
		
		if achievementsMngr.loginCallback then
			achievementsMngr.loginCallback()
		end
	else
		achievementsMngr.loggedIntoGC = false
		print(event.errorCode, event.errorMessage)
	end
end

--Funcio de callback que controla que ens haguem loguejat al Google Play Game Services
function achievementsMngr.androidLoginListener(event)
	if event.isError == nil then
		achievementsMngr.loggedIntoGC = true
		print("Estas loguejat al Google Play Game Services")
		
		if achievementsMngr.loginCallback then
			achievementsMngr.loginCallback()
		end
	else
		achievementsMngr.loggedIntoGC = false
		print(event.errorCode, event.errorMessage)
	end
end

--Funcio que crida el login al servei de jocs corresponent
function achievementsMngr:login(isAndroid, callback)
	
	achievementsMngr.loginCallback = callback
	
	--En el cas que no estiguem loguejats, ens loguegem
	if not achievementsMngr.loggedIntoGC then
		if isAndroid then
			achievementsMngr.gameNetwork.init(achievementsMngr.gameServiceName, achievementsMngr.androidLoginListener)
		else
			achievementsMngr.gameNetwork.init(achievementsMngr.gameServiceName, achievementsMngr.loginListener)
		end
	end
	
end

function achievementsMngr:connectToGC(callback)
	
	--Inicialitzem els game services
	if (system.getInfo("platformName") == "Android") then
        achievementsMngr.gameServiceName = "google"
        achievementsMngr:login(true, callback)
    else
        achievementsMngr.gameServiceName = "gamecenter"
        achievementsMngr:login(false, callback)
    end
end

function achievementsMngr:setup(info, saved)
	achievementsMngr.dict = info
	achievementsMngr.savedAchievements = saved or {}
	
	achievementsMngr:connectToGC(sendSavedAchievements)
end






local jarl = {
	misc = {
		combos = {
			amounts = {
				{
					name = "combo1",
					amount = 2,
					isUnlocked = false
				},
				{
					name = "combo5",
					amount = 5,
					isUnlocked = false
				},
				{
					name = "combo10",
					amount = 10,
					isUnlocked = false
				}
			}
		}
	},
	games = {
		totalGames = 0,
		amounts = {
			{
				name = "games1",
				amount = 1,
				isUnlocked = false
			},
			{
				name = "games50",
				amount = 50,
				isUnlocked = false
			},
			{
				name = "games200",
				amount = 200,
				isUnlocked = false
			},
			{
				name = "games500",
				amount = 500,
				isUnlocked = false
			}
		},
		win = {
			totalWin = 0,
			amounts = {
				{
					name = "win10",
					amount = 10,
					isUnlocked = false
				},
				{
					name = "win50",
					amount = 50,
					isUnlocked = false
				},
				{
					name = "win100",
					amount = 100,
					isUnlocked = false
				}
			}
		},
		lose = {
			totalLose = 0,
			amounts = {
				{
					name = "lose1",
					amount = 10,
					isUnlocked = false
				},
				{
					name = "lose50",
					amount = 50,
					isUnlocked = false
				},
				{
					name = "lose100",
					amount = 100,
					isUnlocked = false
				}
			}
		}
	},
	weapons = {
		totalUsed = 0,
		amounts = {
			{
				name = "weapons10",
				amount = 10,
				isUnlocked = false
			},
			{
				name = "weapons30",
				amount = 30,
				isUnlocked = false
			},
			{
				name = "weapons100",
				amount = 100,
				isUnlocked = false
			}
		},
		types = {
			rake = {
				used = 0,
				amounts = {
					{
						name = "rake5",
						amount = 5,
						isUnlocked = false
					},
					{
						name = "rake20",
						amount = 20,
						isUnlocked = false
					},
					{
						name = "rake50",
						amount = 50,
						isUnlocked = false
					}
				}
			}
		}
	},
	zombies = {
		totalKills = 0,
		amounts = {
			{
				name = "zombies20",
				amount = 20,
				isUnlocked = false
			},
			{
				name = "zombies40",
				amount = 40,
				isUnlocked = false
			},
			{
				name = "zombies50",
				amount = 50,
				isUnlocked = false
			}
		},
		types = {
			rabbit = {
				kills = 0,
				amounts = {
					{
						name = "rabbit7",
						amount = 7,
						isUnlocked = false
					},
					{
						name = "rabbit15",
						amount = 15,
						isUnlocked = false
					},
					{
						name = "rabbit25",
						amount = 25,
						isUnlocked = false
					}
				}
			}
		}
	},
	perLevel = {
		weapons = {
			totalUsed = 0,
			amounts = {
				{
					name = "perLevel weapons10",
					amount = 10,
					isUnlocked = false
				},
				{
					name = "perLevel weapons30",
					amount = 30,
					isUnlocked = false
				},
				{
					name = "perLevel weapons100",
					amount = 100,
					isUnlocked = false
				}
			},
			types = {
				rake = {
					used = 0,
					amounts = {
						{
							name = "perLevel rake5",
							amount = 5,
							isUnlocked = false
						},
						{
							name = "perLevel rake20",
							amount = 20,
							isUnlocked = false
						},
						{
							name = "perLevel rake50",
							amount = 50,
							isUnlocked = false
						}
					}
				}
			}
		},
		zombies = {
			totalKills = 0,
			amounts = {
				{
					name = "perLevel zombies5",
					amount = 5,
					isUnlocked = false
				},
				{
					name = "perLevel zombies10",
					amount = 10,
					isUnlocked = false
				},
				{
					name = "perLevel zombies15",
					amount = 15,
					isUnlocked = false
				}
			},
			types = {
				rabbit = {
					kills = 0,
					amounts = {
						{
							name = "perLevel rabbit1",
							amount = 1,
							isUnlocked = false
						},
						{
							name = "perLevel rabbit3",
							amount = 3,
							isUnlocked = false
						},
						{
							name = "perLevel rabbit5",
							amount = 5,
							isUnlocked = false
						}
					}
				}
			}
		}
	}
}
--achievementsMngr:setup(jarl)


return achievementsMngr