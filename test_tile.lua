module(..., package.seeall)

-- paràmetres comuns per a cada tile
local size = { w = 0, h = 0 }
local parentGrp = nil

-- events
local onTileTouched         = { name = "", id = 0, x = 0, y = 0, phase = "", touchID = nil, isTouchEnabled = true }
local onIdChange            = { name = "", id = 0 }
local onDrag                = { name = "", isDrag = false }
local onDestroyObject       = { name = "" }
local onDestroySuccessTile  = { name = "", id = 0 }
local onPause = ""
local onDestroyTile = ""


-- funció per a comprovar la disponibilitat de tots els paràmetres necessaris per a l'spawn o el restore d'objectes
local function assertObjParams(params, errorType, action)
    
    local msg = "Tried to spawn an object without "
    AZ:assertParam(params.layer,    "Spawn Tile Error", msg .."'params.layer'")
    AZ:assertParam(params.object,   "Spawn Tile Error", msg .."'params.object'")
    
end

-- funció per a comprovar la disponibilitat de tots els paràmetres necessaris per a la creació del tile
local function assertTileParams(params)
    
    local msg = "Tried to create a tile without "
    AZ:assertParam(parentGrp,       "Create Tile Error",    msg .."having initialized the module")
    AZ:assertParam(params.id,       "Create Tile Error",    msg .."'params.id'")
    AZ:assertParam(params.x,        "Create Tile Error",    msg .."'params.x'")
    AZ:assertParam(params.y,        "Create Tile Error",    msg .."'params.y'")
    AZ:assertParam(params.boardX,   "Create Tile Error",    msg .."'params.boardX'")
    AZ:assertParam(params.boardY,   "Create Tile Error",    msg .."'params.boardY'")

end

-- funció per a comprovar la disponibilitat de tots els paràmetres necessaris per a la inicialització del mòdul
local function assertInitParams(params)
    
    if parentGrp ~= nil then
        AZ:assertParam(nil, "Init Tile Module Error", "Tried to re-initialize the module")
    end 

    local msg = "Tried to intialize the tile module without "
    AZ:assertParam(params.w,                "Init Tile Module Error",   msg .."'params.w'")
    AZ:assertParam(params.h,                "Init Tile Module Error",   msg .."'params.h'")
    AZ:assertParam(params.parentGroup,      "Init Tile Module Error",   msg .."'params.parentGroup'")

end

-- funció que inicialitza els events
local function setupEvents(params)

    -- event que enviem quan s'ha tocat un objecte
    onTileTouched = { name = params.onTileTouched or "", id = 0, x = 0, y = 0, phase = "", touchID = nil }

    -- event que enviem quan intercanviem el tile i actualitzem l'id
    onIdChange = { name = params.onIdChange or "", id = params.id }

    -- event que enviem quan fem o hem acabat de fer drag
    onDrag = { name = params.onDrag or "", isDrag = false }

    -- event que cridarem per a destruir la llògica de l'objecte
    onDestroyObject = { name = params.onFinishObject or "" }

    -- event que ens cridaràn per a pausar el tile
    onPause = params.onPauseTile or ""

    -- event que ens cridaràn per a destruir el tile
    onDestroyTile = params.onDestroyTile or ""

    -- event que enviem quan s'ha destruit el tile satisfactoriament
    onDestroySuccessTile = { name = params.onDestroySuccessTile or "", id = 0 }
end

--[[
necessitem els paràmetres següents: onTileTouched (es dispara al apretar un
tile), onDestroySuccessTile (es dispara una vegada s'ha destruit el tile),
onDestroyTile (event que cridarà el destroy del tile), onIdChange (cridat al
canviar l'objecte de tile), parentGroup i wh
]]
function initialize(params)
    
    assertInitParams(params)
    
    
------------------ si tenim tots els paràmetres, inicialitzem ------------------
    
    setupEvents(params)
    
    size = { w = params.w, h = params.h }
    parentGrp = params.parentGroup
    
    return true
end

--[[
necessitem els paràmetres següents: id, boardX, boardY i xy
]]
function createTile(params)
    
    assertTileParams(params)
    
    
----------------- si tenim tots els paràmetres, creem el tile ------------------
    
    local tile = {}
    tile.originalPos = { x = params.x, y = params.y }
    tile.id = params.id
    tile.isPaused = false
    tile.isTouchEnabled = true
    tile.posInBoard = { x = params.boardX, y = params.boardY }
    tile.tileSprites = nil
    tile.isOccupied = false
    tile.canDrag = true
    tile.bgSpinTimerID = nil
    tile.objDragTransID = nil
    tile.tileGrp = display.newGroup()
    tile.layers = display.newGroup()
    tile.layersReferences = {}
    
    tile.tileGrp.anchorChildren = false
    tile.layers.anchorChildren = false
    
    local grp = display.newGroup()
    
    -- si ens han passat un background...
    if params.bg ~= nil then
        tile.tileSprites = {}
        
        -- ...els afegim...
        for i=1, #params.bg do
            tile.tileSprites[i] = display.newImage(params.bg[i], 0, 0)
            tile.tileSprites[i].width, tile.tileSprites[i].height = size.w, size.h
            tile.tileSprites[i].x, tile.tileSprites[i].y = 0, 0
            
            tile.tileSprites[i].isVisible = (i == 1)
            
            grp:insert(tile.tileSprites[i])
        end
        
        -- ...i els anem canviant
        if #tile.tileSprites > 1 then
            
            tile.currentBG = 1
            
            tile.spinBackground = function()
                tile.tileSprites[tile.currentBG].isVisible = false
                
                tile.currentBG = tile.currentBG +1
                if tile.currentBG > #tile.tileSprites then
                    tile.currentBG = 1
                end
                tile.tileSprites[tile.currentBG].isVisible = true
                
                tile.bgSpinTimerID = timer.performWithDelay(75, tile.spinBackground)
            end
            
            tile.spinBackground()
        end
        
    -- si no tenim background, afegim un frame invisible
    else
        tile.tileSprites = display.newRect(0, 0, size.w, size.h)
        tile.tileSprites.anchorX, tile.tileSprites.anchorY = 0.5, 0.5 --:setReferencePoint(display.CenterReferencePoint)
        tile.tileSprites.x, tile.tileSprites.y = 0, 0
        
        local test = false;
        
        if not test then
            tile.tileSprites.isVisible = false
        else
            local mou = math.random
            tile.tileSprites:setFillColor(mou(0, 1), mou(0, 1), mou(0, 1))
        end
        
        tile.tileSprites.isHitTestable = true
        
        grp:insert(tile.tileSprites)
    end
    
    -- ...i el posem en el primer "layer", el qual serà visible en el cas de que hi hagi gràfic
    tile.tileGrp:insert(grp)
    tile.tileGrp.x, tile.tileGrp.y = params.x, params.y
    
    -- i ara afegim els layers de l'objecte
    tile.tileGrp:insert(tile.layers)
    
    
----------------------------------- FUNCIONS -----------------------------------

    tile.dispatchAtMain = function(event)
        if tile.layersReferences["main"] ~= nil then
            tile.layersReferences["main"]:dispatchEvent(event)
        end
    end

    -- funció que escolta el touch al tile
    tile.touchEventListener = function(event)
        onTileTouched.id = tile.id
        onTileTouched.phase = event.phase
        onTileTouched.touchID = event.id
        onTileTouched.x, onTileTouched.y = event.x, event.y
        Runtime:dispatchEvent(onTileTouched)

        return true
    end

    -- funció per a destruir el tile
    tile.destroy = function()
        
        -- eliminem el listener del pause
        Runtime:removeEventListener(onPause, tile.pause)
        
        -- recorrem els layers [i background] i els destruim
        tile.clearTile()
        for i=1, tile.tileGrp.numChildren do
            display.remove(tile.tileGrp[i])
        end

        -- cancelem timers i transicions
        tile.bgSpinTimerID = timer.safeCancel(tile.bgSpinTimerID)
        tile.objDragTransID = transition.safeCancel(tile.objDragTransID)

        -- enviem l'event conforme hem acabat d'eliminar el tile
        onDestroySuccessTile.id = tile.id
        Runtime:dispatchEvent(onDestroySuccessTile)

        -- eliminem definitivament el tile
        tile = nil
    end

    tile.endDrag = function()
        if not tile.canDrag then
            onDrag.isDrag = false
            tile.dispatchAtMain(onDrag)
        end
        
        tile.tileGrp:insert(tile.layers)
        tile.layers.x, tile.layers.y = 0, 0
        tile.objDragTransID = transition.safeCancel(tile.objDragTransID)
        tile.canDrag = true
    end

    tile.endTileReset = function()
        parentGrp:insert(tile.id, tile.tileGrp)
        tile.objDragTransID = transition.safeCancel(tile.objDragTransID)
        tile.canDrag = true
    end

    tile.pause = function(event)
        
        if event ~= nil then
            tile.isPaused = event.isPause
        end
        
        timer.safePauseResume(tile.bgSpinTimerID, tile.isPaused)
        transition.safePauseResume(tile.objDragTransID, tile.isPaused)
    end

    tile.resetTilePosition = function(time)
        
        if tile.tileGrp.parent == parentGrp and tile.tileGrp.x == tile.originalPos.x and tile.tileGrp.y == tile.originalPos.y then
            tile.objDragTransID = transition.to(tile.tileGrp, { time = 1, onComplete = tile.endTileReset })
        else
            tile.canDrag = false
            
            local tx, ty = tile.tileGrp.x - tile.originalPos.x, tile.layers.y - tile.originalPos.y
            local dist = time or math.sqrt((tx * tx) + (ty * ty))

            tile.objDragTransID = transition.to(tile.tileGrp, { time = dist, x = tile.originalPos.x, y = tile.originalPos.y, rotation = 0, transition = easing.inOutExpo, onComplete = tile.endTileReset })
        end
        
        if tile.isPaused then
            tile.pause()
        end
    end
    
    tile.resetLayersPosition = function(time)
        
        if tile.layers.parent == tile.tileGrp then
            tile.objDragTransID = transition.to(tile.layers, { time = 1, onComplete = tile.endDrag })
        else
            tile.canDrag = false
            
            local tx, ty = tile.layers.x - tile.tileGrp.x, tile.layers.y - tile.tileGrp.y
            local dist = time or math.sqrt((tx * tx) + (ty * ty))

            tile.objDragTransID = transition.to(tile.layers, { time = dist, x = tile.tileGrp.x, y = tile.tileGrp.y, transition = easing.inOutExpo, onComplete = tile.endDrag })
        end
        
        if tile.isPaused then
            tile.pause()
        end
    end

    -- funció per a actualitzar la posició de l'objecte quan s'arrossega
    tile.drag = function(x, y)
        if tile.canDrag then
            parentGrp:insert(tile.layers)
            tile.canDrag = false
            
            onDrag.isDrag = true
            tile.dispatchAtMain(onDrag)
            
        end
        
        tile.layers.x, tile.layers.y = parentGrp:contentToLocal(x, y)
    end
    
    -- funció per eliminar un sol layer
    tile.clearLayerTile = function(l)
        if tile.layersReferences[l] ~= nil then
            
            if l == "main" then
                tile.layersReferences[l]:dispatchEvent(onDestroyObject)
            end
            
            display.remove(tile.layersReferences[l])
            tile.layersReferences[l] = nil
            
            tile.isOccupied = (tile.layers.numChildren > 0)
            
            if not tile.isOccupied then
                tile.endDrag()
            end
            
            return true, not tile.isOccupied
        end
        
        return false, not tile.isOccupied
    end

    -- funció per eliminar tot el contingut del tile
    tile.clearTile = function()
        tile.endDrag()
        
        for key, value in pairs(tile.layersReferences) do
            tile.clearLayerTile(key)
        end

        tile.isOccupied = false
    end

    -- funció que intercanvia els layers del tile passat per paràmetre amb l'actual
    tile.swapTile = function(otherTile, isBackgroundIncluded)
        
        local function setTile(this, other)
            this.layers = display.newGroup()
            this.layers = other.layers
            this.tileGrp:insert(this.layers)
            this.layers.x, this.layers.y = 0, 0
            this.layersReferences = {}
            this.layersReferences = other.layersReferences
            this.canDrag = true
            this.isOccupied = other.isOccupied
            
            if this.id ~= nil then
                onIdChange.id = this.id
                this.dispatchAtMain(onIdChange)
            end
        end
    
        -- primer guardem les dades del tile
        local auxTile = {}
        auxTile.tileGrp = display.newGroup()
        setTile(auxTile, tile)
        
        -- ara invertim els tiles
        setTile(tile, otherTile)
        setTile(otherTile, auxTile)
        
        -- i acabem notificant als tiles que no s'estan arrossegant
        onDrag.isDrag = false
        tile.dispatchAtMain(onDrag)
        otherTile.dispatchAtMain(onDrag)
    end
    
    -- funció per a obtenir un objecte d'un layer
    tile.getObjectInLayer = function(l)
        if tile.layersReferences[l] ~= nil then
            return tile.layersReferences[l]
        end
        
        return nil
    end

    -- funció per a crear un now objecte
    tile.spawnObject = function(params)

        assertObjParams(params)
        
        if tile.layers.numChildren == 0 and params.layer ~= "main" then
            Runtime:dispatchEvent({ name = "_onError", errorType = "Spawn Object Error", message = "Tried to spawn an object in layer ".. params.layer ..". First layer must be named 'main'" })
            return false
        end

        ------------ si tenim tots els paràmetres, creem l'objecte -------------
        tile.isOccupied = true
        
        local s = ((size.w + size.h) *0.5) / ((params.object.width + params.object.height) *0.5)
        params.object:scale(s, s)

        if tile.layersReferences[params.layer] ~= nil then
            print("El tile ".. tile.id .." ja té un layer ".. params.layer)
        end

        tile.layers:insert(tile.layers.numChildren +1, params.object)
        tile.layers[tile.layers.numChildren].layerName = params.layer
        tile.layersReferences[params.layer] = params.object
        
        if params.layer == "main" then
            onIdChange.id = tile.id
            params.object:dispatchEvent(onIdChange)
        end
        
        return true
    end
    
    tile.setTouchEnabled = function(isEnabled)
        tile.isTouchEnabled = isEnabled
    end
    
    tile.scaleTile = function (newScale)
        --Escalem el contingut del Tile
        tile.tileGrp:scale(newScale,newScale); 
    end
    
    tile.scaleToOriginal = function ()
        --Recuperem l'escala original del Tile
        tile.tileGrp.xScale, tile.tileGrp.yScale = 1, 1;
    end
    
    -- finalment afegim event listeners
    tile.tileGrp[1]:addEventListener("touch", tile.touchEventListener)
    Runtime:addEventListener(onPause, tile.pause)
    
    parentGrp:insert(tile.tileGrp)
    
    return tile, tile.layers
end