-- save_system.lua
-- Guarda y restaura el estado persistente de GameSession.
--
-- Serializa flags, stats, clock y player a texto Lua y los restaura
-- sobre una sesión nueva o existente. No guarda la posición del
-- jugador en el mapa ni el estado de las entidades.
--
-- Uso:
--   SaveSystem.guardar(session)       -- escribe guardado.lua
--   SaveSystem.cargarEn(session)      -- restaura en la sesión dada
--   SaveSystem.existeGuardado()       -- ¿hay guardado?

local GameSession = require("src.core.game_session")
local GameFlags = require("src.core.game_flags")

local SaveSystem = {}

SaveSystem.ARCHIVO = "guardado.lua"
SaveSystem.VERSION = 1

local cargarChunk = load or loadstring

-- ---------------------------------------------------------------- serializar

local function escapar(valor)
    valor = valor:gsub("\\", "\\\\")
    valor = valor:gsub('"', '\\"')
    valor = valor:gsub("\n", "\\n")
    valor = valor:gsub("\r", "\\r")
    valor = valor:gsub("\t", "\\t")
    return '"' .. valor .. '"'
end

local function serializarValor(valor, indent)
    if type(valor) == "string" then
        return escapar(valor)
    end

    if type(valor) == "boolean" or type(valor) == "number" then
        return tostring(valor)
    end

    if type(valor) ~= "table" then
        error("tipo no serializable: " .. type(valor))
    end

    local claves = {}
    for k in pairs(valor) do
        table.insert(claves, k)
    end
    -- Orden determinista para que los guardados sean comparables.
    table.sort(claves, function(a, b)
        return tostring(a) < tostring(b)
    end)

    local partes = {}
    for _, k in ipairs(claves) do
        local clave
        if type(k) == "string" and k:match("^[%a_][%w_]*$") then
            clave = k
        else
            clave = "[" .. serializarValor(k, indent) .. "]"
        end
        table.insert(
            partes,
            indent .. "  " .. clave .. " = "
                .. serializarValor(valor[k], indent .. "  ")
        )
    end

    if #partes == 0 then
        return "{}"
    end

    return "{\n" .. table.concat(partes, ",\n") .. "\n" .. indent .. "}"
end

local function copiar(origen)
    local copia = {}
    for k, v in pairs(origen) do
        copia[k] = (type(v) == "table") and copiar(v) or v
    end
    return copia
end

function SaveSystem.serialize(session)
    local data = {
        version = SaveSystem.VERSION,
        flags = copiar(session.flags.flags),
        stats = copiar(session.stats),
        clock = copiar(session.clock),
        player = copiar(session.player),
    }
    return "return " .. serializarValor(data, "")
end

-- -------------------------------------------------------------- deserializar

function SaveSystem.deserialize(texto)
    local chunk = cargarChunk(texto)
    if not chunk then
        error("guardado corrupto: no se puede interpretar")
    end

    local ok, data = pcall(chunk)
    if not ok or type(data) ~= "table" then
        error("guardado corrupto: no es una tabla de sesión")
    end

    if data.version ~= SaveSystem.VERSION then
        error("versión de guardado no soportada: " .. tostring(data.version))
    end

    return data
end

-- ------------------------------------------------------------------ restaurar

-- Restaura data sobre una sesión existente. Limpia las flags previas:
-- la sesión queda exactamente con el contenido del guardado.
function SaveSystem.aplicar(session, data)
    session.flags = GameFlags:new()

    for nombre, valor in pairs(data.flags or {}) do
        session:setFlag(nombre, valor)
    end

    if data.stats then
        session.stats = copiar(data.stats)
    end

    if data.clock then
        session.clock = copiar(data.clock)
    end

    if data.player then
        session.player = copiar(data.player)
    end

    return session
end

function SaveSystem.restore(data)
    local session = GameSession:new()
    return SaveSystem.aplicar(session, data)
end

-- ------------------------------------------------------------ archivo (E/S)

local function leerArchivo(nombre)
    if love and love.filesystem then
        return love.filesystem.read(nombre)
    end
    local archivo = io.open(nombre, "r")
    if not archivo then
        return nil
    end
    local texto = archivo:read("*a")
    archivo:close()
    return texto
end

local function escribirArchivo(nombre, texto)
    if love and love.filesystem then
        return love.filesystem.write(nombre, texto)
    end
    local archivo = assert(io.open(nombre, "w"), "no se pudo abrir " .. nombre)
    archivo:write(texto)
    archivo:close()
    return true
end

function SaveSystem.guardar(session, nombre)
    local texto = SaveSystem.serialize(session)
    return escribirArchivo(nombre or SaveSystem.ARCHIVO, texto)
end

function SaveSystem.existeGuardado(nombre)
    local ruta = nombre or SaveSystem.ARCHIVO

    if love and love.filesystem then
        return love.filesystem.getInfo(ruta) ~= nil
    end

    local archivo = io.open(ruta, "r")
    if archivo then
        archivo:close()
        return true
    end
    return false
end

-- Restaura sobre una sesión existente. Retorna la sesión o nil si no
-- hay guardado.
function SaveSystem.cargarEn(session, nombre)
    local texto = leerArchivo(nombre or SaveSystem.ARCHIVO)
    if not texto then
        return nil
    end
    return SaveSystem.aplicar(session, SaveSystem.deserialize(texto))
end

-- Crea una sesión nueva con el contenido del guardado. Retorna la
-- sesión o nil si no hay guardado.
function SaveSystem.cargar(nombre)
    local texto = leerArchivo(nombre or SaveSystem.ARCHIVO)
    if not texto then
        return nil
    end
    return SaveSystem.restore(SaveSystem.deserialize(texto))
end

return SaveSystem
