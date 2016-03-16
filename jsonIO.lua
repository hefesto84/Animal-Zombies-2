-- Objeto principal que se retorna
local jsonIO = {}

jsonIO._json = require "json"

-- Path del projecte i de guardat
jsonIO.projectPath = system.ResourceDirectory
jsonIO.documentsPath = system.DocumentsDirectory


function jsonIO:synchronize()
    
    local path = system.pathForFile("user.json", jsonIO.documentsPath)
    
    local function synchronizeListener(event)
        if event.isError then
            print("ERROR!")
        else
            print("Synchronize: "..event.response)
        end

    end
    
    --local params = {}
   
   -- local headers = {}
    --headers["Content-Type"] = "application/json"
    --params.headers = headers    
    
    --local params = {}
    --local body = "data=ddd"
    --params.body = body
    --network.upload("http://23.92.24.222/animalzombies/algo.php","GET",synchronizeListener,params,"user.json",jsonIO.documentsPath,"application/json")
end

function jsonIO:readFile(filename, isInProject) 

    local d = system.DocumentsDirectory
    
    if isInProject then
        d = system.ResourceDirectory
    end

    local path = system.pathForFile(filename, d)
    
    local valueJSON = nil
    local file = io.open(path, "r")
    
    if file then
        local contents = file:read("*a")
        io.close(file)

        valueJSON = jsonIO._json.decode(contents)
    end
    
    return valueJSON
end

--[[
function jsonIO:readFile(filename, isInProject) 
    -- volem carregar un fitxer de JSON
    -- la crida ens indica d'on obtenim el fitxer, si del projecte o de documents
    local path = jsonIO.documentsPath
    if isInProject then
        path = jsonIO.projectPath
    end
    path = system.pathForFile(filename, path)
    
    local valueJSON = nil
    local file = io.open(path, "r")
    if file then
        -- el fitxer s'ha pogut obrir per a lectura
        local contents = file:read("*a")
        io.close(file)
        valueJSON = jsonIO._json.decode(contents)
    end
    
    return valueJSON
end
]]--

function jsonIO:writeFile(filename, data)
    -- volem escriure el contingut del array JSON a un fitxer del qual sabem el path
    -- només es pot escriue a la carpeta de Documents
    local path = system.pathForFile(filename, jsonIO.documentsPath)
    local file = io.open(path, "w");
    if file then
        --El fitxer s'ha pogut obrir per a escriptura
        file:write(jsonIO._json.encode(data))
        io.close(file)
    end
    
    return file ~= nil
end

return jsonIO
