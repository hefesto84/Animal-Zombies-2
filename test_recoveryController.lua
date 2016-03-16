-- Objecte que retornem
local rController = {}


-- FUNCIONS PRIVADES -----------------------------------------------------------
local saveInfoToJSON = function()
    --Volem guardar el valor de la informació del User al JSON corresponent
	print("", "recovery saveData")
    AZ:saveData()
end

local cancelPendingRecovery = function()
    --Volem deixar el sistema indicant que ja no hi ha cap recuperació de vides pendent
    --Actualitzem les dades del sistema
    AZ.userInfo.recoveryStatus.waitingForIndex = 0;
    AZ.userInfo.recoveryStatus.notifsInProcess = {};
    AZ.userInfo.recoveryStatus.initTime = 0;
	print("", "recovery cancel")
    saveInfoToJSON();
    
    --Cancel·lem les notificacions pendents
    AZ.notificationController:cancelPendingNotifications();
end

local getRecoveryDataFromLevel = function (currentStageNum, currentLevelNum)
   --A partir d'un nivell i stage concrets, retornem les dades de recovery que necessitem per a preparar el sistema
   
   --Recorrem l'array amb les informacions de recovery fins a troba la secció que ens afecta
   local infoRecoveryArray = AZ.gameInfo[currentStageNum].gameplay.recoveryInfo;
   for i = 1, #infoRecoveryArray, 1 do
       local aux = infoRecoveryArray[i];
       if currentLevelNum <= aux.levelLimit then
           --Hem trobat el que ens afecta
           --Retornem la informació de tots els blocs de recuperació per a la secció trobada
           return aux.notifsInfo;
       end
   end
   
   --Això no passarà mai
   return nil;
end

local function recomputeRecoveryStatus()
    --Actualitzem l'estat actual del sistema de recuperació
    --Cal mirar si hi ha una recuperació de vides pendent
    --Obtenim també l'estat actual del progrés
	
    local recoveryInfo = AZ.userInfo.recoveryStatus;
    local fullRecoveryInfo = recoveryInfo.notifsInProcess;
    local waitingForIndex = recoveryInfo.waitingForIndex;
    local initTime = recoveryInfo.initTime;
    
    --AZ.utils.printDictionary(recoveryInfo);
     
    if waitingForIndex > 0 then
        --Hi ha una recarga de vides pendent
        --Preparem les dades necessàries. Agafem els valors guardats de l'Stage actual
        local currentTime = os.time(os.date( '*t' ));
        local deltaTimeFromInit = currentTime - initTime;
        
        --Recorrem la llista de notificacions pendents (començant per la que estem esperant) per saber en quin punt ens trobem i quantes vides cal afegir
        local lifesToAdd = 0;
        for i = waitingForIndex, #fullRecoveryInfo, 1 do
            local currentNotifInfo = fullRecoveryInfo[i];
            local currentDeltaTimeToApply = currentNotifInfo.minutesElapsed * 60;
            if deltaTimeFromInit >= currentDeltaTimeToApply then
                --Hem passat l'umbral d'aquesta notificació. L'apliquem
                lifesToAdd = lifesToAdd + currentNotifInfo.lifesEarned;
                
                --Actualitzem el comptador
                if i == #fullRecoveryInfo then
                    --Ja hem rebut la última notificació. Aturem el procés
                    cancelPendingRecovery();
                end
                
            else
                --Encara no hem arribat a poder aplicar aquesta notificació     
                AZ.userInfo.recoveryStatus.waitingForIndex = i;
                
                --No cal seguir mirant
                break;
            end
        end
        
        if lifesToAdd > 0 then
            --Tenim vides a incrementar
            AZ.userInfo.lifesCurrent = math.min(AZ.userInfo.lifesCurrent + lifesToAdd, AZ.userInfo.lifesMax);
            
            --native.showAlert("Animal Zombies", "Has recuperat vides: "..tostring(lifesToAdd.." i ara en tens: "..AZ.userInfo.lifesCurrent), {"OK"});
			
			Runtime:dispatchEvent({ name = RECOVERED_LIFES_EVNAME, lifes = AZ.userInfo.lifesCurrent })
        end
        
        --Guardem tots els canvis al JSON
		print("", "recovery recompute")
        saveInfoToJSON();
    end
end


-- LISTENERS -------------------------------------------------------------------
local newSystemState = function(event)
    --El sistema ha canviat d'estat
    if event.type == "applicationStart" then
        --No fem res, perquè en aquest punt encara no s'han carregat els JSON
        --Dins AZController ja es crida quan estiguin carregats
        
    elseif event.type == "applicationResume" then
        --Tornem de BackGround
        --Ens assegurem de que el badge no tingui cap valor
        native.setProperty( "applicationIconBadgeNumber", 0 );
        
        --Avisem al sistema de recuperació de vides
        recomputeRecoveryStatus();
    end
end


-- FUNCIONS PÚBLIQUES ----------------------------------------------------------
function rController:updateRecoveryStatus ()
    --Volem actualitzar l'estat actual de la recuperació
    recomputeRecoveryStatus();
end

local function getCurrentLevel(currentStageNum)
	local stg = AZ.userInfo.progress.stages[currentStageNum]
	for i = 1, #stg.levels do
		if stg.levels[i].tribones == 0 then
			return i
		end
	end
	return #stg.levels
end

function rController:initRecoveryProcess ()
    --El jugador ha perdut totes les vides, i voldrem iniciar el procés de recuperació
    --Cancel·lem totes les notificacions que hi hagués pendents
    cancelPendingRecovery();
    
    --Obtenim la informació de l'estat actual, per a programar les accions
    local currentTime = os.time(os.date( '*t' ));
    local currentStageNum = math.min(AZ.userInfo.lastStageFinished + 1, #AZ.gameInfo);
    local currentLevelNum = getCurrentLevel(currentStageNum);
    local fullRecoveryInfo = getRecoveryDataFromLevel(currentStageNum, currentLevelNum);
    
    --Amb tota la informació que hi ha de recuperació llencem les notificacions i esperem a que el sistema entri a la funció de tractament
    for i = 1, #fullRecoveryInfo, 1 do
        local currentNotifInfo = fullRecoveryInfo[i];
        local timeToNotif = currentNotifInfo.minutesElapsed * 60;
        local lifestoNotif = currentNotifInfo.lifesEarned;
        
        --Llencem la notificació
        AZ.notificationController:launchNewNotification (timeToNotif, lifestoNotif.." piruletes recuperades");
        
        --Afegim la informació d'aquesta notificació a la informació del User, per a quan arribin
        AZ.userInfo.recoveryStatus.notifsInProcess[i] = currentNotifInfo;
    end
    
    --Preparem la resta d'informació que cal guardar al User
    AZ.userInfo.recoveryStatus.initTime = currentTime;
    AZ.userInfo.recoveryStatus.waitingForIndex = 1;
	print("", "recovery init")
    saveInfoToJSON();
end

function rController:getCurrentRecoveryStatus()
    --Retornem l'estat actual de l'espera, per a notificar-ho al jugador
    --Coses necessàries:
    -- Hi ha una espera pendent?
    -- Temps del compte enrera
    -- Vides a guanyar
    
    local recoveryInfo = AZ.userInfo.recoveryStatus;
    local fullRecoveryInfo = recoveryInfo.notifsInProcess;
    local waitingIndex = recoveryInfo.waitingForIndex;
    local initTime = recoveryInfo.initTime;
    
    local anyWaiting = waitingIndex > 0;
    local lifesToWin = 0;
    local secondsToEarn = 0;
    
    if anyWaiting then
        lifesToWin = fullRecoveryInfo[waitingIndex].lifesEarned;
        secondsToEarn = initTime + (fullRecoveryInfo[waitingIndex].minutesElapsed*60) - os.time(os.date( '*t' ));
    end
    
    return anyWaiting, lifesToWin, secondsToEarn;
end


-- INICIALITZACIÓ I DESTRUCCIÓ -------------------------------------------------
local function assertInitParams (params)
    --Comprovem que hem rebut tots els paràmetres necessaris
    local msg = "Tried to initialize the notificationController module without ";
    AZ:assertParam(params, "recoveryController Init Error", msg .."params");
end

function rController:init(params)
    --Comprovem que s'hagi inicialitzat correctament
    assertInitParams(params);
    
    --Preparem el Listener per a l'estat de l'aplicació (canvi Foreground - Background)
    Runtime:addEventListener("system", newSystemState); 
end

function rController:destroy()
    --Se'ns demana destruïr el mòdul
    rController = nil
end

return rController 