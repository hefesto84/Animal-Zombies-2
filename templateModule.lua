-- Objecte principal que es retorna
local gaviot = {}

-- Atributs de la classe

-- Inicialitzem el mòdul amb els paràmetres necessàris
local function assertInitParams (params)
    --Comprovem que hem rebut tots els paràmetres
    local msg = "Tried to initialize the module without "
    AZ:assertParam(params, "Module Init Error", msg .." params");
      
    return true;
end

function gaviot:init ( params )
    --Fem la comprovació de que tots els paràmetres són correctes
    assertInitParams(params);
    
    --Si hem arribat fins aquí és perquè tots els paràmetres són correctes
    
    return true;
end

-- Destruim el mòdul
function gaviot:destroy ()
    
end

-- Funcions públiques


-- Retornem l'objecte principal
return gaviot;

