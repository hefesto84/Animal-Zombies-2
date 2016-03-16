-- Objecte que retornem
local prop = {}

-- Propietats internes
local board         = nil;
local background    = nil;
local animInfo      = nil;


-- FUNCIONS PÚBLIQUES ----------------------------------------------------------
function prop:create (propSS, propIndex, boardIndex)
    --Volem crear un nou objecte Prop       
    local newProp = display.newImage(propSS, propIndex);
    newProp.x = 0;
    newProp.y = 0;
    newProp.index = boardIndex;
    newProp.objType = BOARD_OBJECT_TYPES.PROP;
    newProp.eatAnim = nil;
    newProp.canBeEaten = true;
    newProp.isFence = false;
    
    newProp.destroy = function ()
        --Volem destruïr el prop
        --Destruïm l'animació
        newProp.eatAnim:removeSelf();
        newProp.eatAnim = nil;
        
        --Destruïm l'objecte
        newProp:removeSelf();
        newProp = nil;
    end
    
    newProp.finishDisappear = function(index)
        --Ha acabat l'animació de desaparèixer
        --Enviem l'event per a notificar-ho al wController
        Runtime:dispatchEvent({ name = OBJECT_PROP_JUST_ERASED, boardID = index });
    end
    
    newProp.finishEaten = function (index)
        --El Zombie ha acabat l'animació menjar-se el Prop
        --Canviem l'estat
        newProp.canBeEaten = false;
        
        --Aturem l'animació de destrucció i iniciem la de final
        newProp.eatAnim:pause();
        newProp.eatAnim.isVisible = false;
        newProp.finishDisappear(index);
    end
    
    newProp.cancelEaten = function()
        --El zombie ha cancel·lat l'animació de menjar-se el prop
        --Canviem l'estat
        newProp.canBeEaten = true;
        
        --Aturem l'animació de destrucció
        newProp.eatAnim:pause();
        newProp.eatAnim.isVisible = false;
    end
    
    newProp.pauseResumeEat = function (isPaused)
        --Volem assignar el nou estat de pausa de l'animació
        if isPaused then
            newProp.eatAnim:pause();
            newProp.eatAnim.isVisible = false;
        else
            newProp.eatAnim:play();
            newProp.eatAnim.isVisible = true;
        end
    end
    
    newProp.startEaten = function ()
        --Comença el procés de ésser menjat
        --Canviem l'estat
        newProp.canBeEaten = false;
        
        --Activem l'animació
        newProp.eatAnim.isVisible = true;
        newProp.eatAnim:play();
    end
    
    --Preparem l'animació de menjar (aturada i invisible)
    newProp.eatAnim = display.newSprite(animInfo.imageSheet, animInfo.sequenceData);
    background.group:insert(newProp.eatAnim);
    newProp.eatAnim.x, newProp.eatAnim.y = board:getTilePos(newProp.index);
    newProp.eatAnim.isVisible = false;
    
    --Fem que escolti l'event de mort
    newProp:addEventListener(OBJECT_DESTROY_EVNAME, newProp.destroy);
    
    return newProp;
end


-- INICIALITZACIÓ I DESTRUCCIÓ -------------------------------------------------
local function assertInitParams (params)
    --Comprovem que hem rebut tots els paràmetres necessaris
    local msg = "Tried to initialize the Prop module without ";
    AZ:assertParam(params, "Prop Init Error", msg .."params");
    AZ:assertParam(params.board, "Prop Init Error", msg .."'params.board'");
    AZ:assertParam(params.background, "Prop Init Error", msg .."'params.background'");
    
end

function prop:init(params)
    --Comprovem que s'hagi inicialitzat correctament
    assertInitParams(params);
    
    --Assignem els paràmetres
    board = params.board;
    background = params.background;
    
    --Inicialitzem el SS
    animInfo = AZ.animsLibrary.eatingPropAnim();
end

function prop:destroy()
    --Se'ns demana destruïr el mòdul
    --Cada prop individual s'el·limina capturant l'event 
    prop = nil
end

return prop