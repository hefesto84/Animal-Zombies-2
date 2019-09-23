-- Objecte que retornem
local nController = {}

-- Propietats internes

-- LISTENERS -------------------------------------------------------------------
local function notificationListener( event )
    if ( event.type == "remote" ) then
        --És un missatge de push 

    elseif ( event.type == "local" ) then
        --És una notificació local
        --Ens assegurem de que el badge no tingui cap valor
        native.setProperty( "applicationIconBadgeNumber", 0 );
        
        --Avisem al sistema de recuperació de vides
        AZ.recoveryController:updateRecoveryStatus();
    end
end


-- FUNCIONS PÚBLIQUES ----------------------------------------------------------
function nController:cancelPendingNotifications ()
    --Volem cancel·lar totes les notificacions programades que encara no han aparegut
    system.cancelNotification();
end

function nController:launchNewNotification (timeInSeconds, message)
    --Volem programar una notificació per al dispositiu actual
    --Calcul·lem els paràmetres de la crida
    local options =  {
        alert = message,
        budge = 0,
        custom = { msg = "Alarm" }
    }

    --Programem la notificació
    system.scheduleNotification(timeInSeconds, options);
end


-- INICIALITZACIÓ I DESTRUCCIÓ -------------------------------------------------
local function assertInitParams (params)
    --Comprovem que hem rebut tots els paràmetres necessaris
    local msg = "Tried to initialize the notificationController module without ";
    AZ:assertParam(params, "notificationController Init Error", msg .."params");
end

function nController:init(params)
    --Comprovem que s'hagi inicialitzat correctament
    assertInitParams(params);
    
    --Assignem els paràmetres
    
    --Programem el Listener
    Runtime:addEventListener( "notification", notificationListener )
end

function nController:destroy()
    --Se'ns demana destruïr el mòdul
    --Cancel·lem els listeners
    Runtime:removeEventListener( "notification", notificationListener )
    
    nController = nil
end

return nController 

