-- Validador del contenido del juego.
--
-- Uso como script:  lua tests/validador.lua
-- Uso como módulo:  local validar = require("tests.validador"); validar()
--
-- Verifica que todo el contenido sea consumible por el motor:
--   * cada archivo de src/content/ define diálogos con estructura válida
--   * cada gotoDialog resuelve contra DialogRepository
--   * cada ShowDialogAction en src/triggers/ apunta a un diálogo existente
--   * cada flag requerida (puertas, triggers) se define en alguna parte

local repositorio = require("src.content.dialogs")
local GameSession = require("src.core.game_session")

local validador = {}

local function archivosCoincidentes(comando)
    local lista = {}
    local salida = io.popen(comando)
    for archivo in salida:lines() do
        table.insert(lista, archivo)
    end
    salida:close()
    return lista
end

local function leerArchivo(ruta)
    local archivo = io.open(ruta, "r")
    if not archivo then
        return nil
    end
    local contenido = archivo:read("*a")
    archivo:close()
    return contenido
end

local function resolverDialogo(id, errores, contexto)
    local ok, dialogo = pcall(repositorio.get, repositorio, id)
    if not ok or type(dialogo) ~= "table" then
        table.insert(
            errores,
            string.format(
                "%s: el diálogo '%s' no existe (%s)",
                contexto,
                id,
                tostring(ok and dialogo or ok)
            )
        )
        return nil
    end
    return dialogo
end

-- Estructura de un diálogo: { pages = { {text=..., options=...}, ... } }
local function validarDialogo(nombre, dialogo, errores, contexto)
    local etiqueta = contexto .. ":" .. nombre

    if type(dialogo) ~= "table" then
        table.insert(
            errores,
            etiqueta .. ": un diálogo debe ser una tabla"
        )
        return
    end

    local pages = dialogo.pages

    if type(pages) ~= "table" or #pages == 0 then
        table.insert(
            errores,
            etiqueta .. ": debe declarar al menos una página en pages"
        )
        return
    end

    for i, page in ipairs(pages) do
        local etiquetaPagina = etiqueta .. " (página " .. i .. ")"

        if type(page) == "string" then
            -- Página de texto simple: válida.
        elseif type(page) == "table" then
            if type(page.text) ~= "string" then
                table.insert(
                    errores,
                    etiquetaPagina .. ": la página debe declarar text (string)"
                )
            end

            if page.options ~= nil then
                if type(page.options) ~= "table" or #page.options == 0 then
                    table.insert(
                        errores,
                        etiquetaPagina .. ": options debe ser un array no vacío"
                    )
                else
                    for j, opcion in ipairs(page.options) do
                        local etiquetaOpcion =
                            etiquetaPagina .. " (opción " .. j .. ")"

                        if type(opcion) ~= "table"
                            or type(opcion.text) ~= "string" then
                            table.insert(
                                errores,
                                etiquetaOpcion .. ": debe declarar text"
                            )
                        end

                        if opcion.flags ~= nil
                            and type(opcion.flags) ~= "table" then
                            table.insert(
                                errores,
                                etiquetaOpcion .. ": flags debe ser una tabla"
                            )
                        end

                        if opcion.gotoDialog ~= nil then
                            resolverDialogo(
                                opcion.gotoDialog,
                                errores,
                                etiquetaOpcion
                            )
                        end
                    end
                end
            end

            if page.gotoDialog ~= nil then
                resolverDialogo(page.gotoDialog, errores, etiquetaPagina)
            end
        else
            table.insert(
                errores,
                etiquetaPagina .. ": la página debe ser texto o una tabla"
            )
        end
    end
end

-- Las opciones declaran flags = { nombre = valor }: son definiciones.
local function validarFlagsDeDialogo(dialogo, flagsDefinidas)
    for _, page in ipairs(dialogo.pages or {}) do
        if type(page) == "table" and type(page.options) == "table" then
            for _, opcion in ipairs(page.options) do
                if type(opcion.flags) == "table" then
                    for nombre in pairs(opcion.flags) do
                        flagsDefinidas[nombre] = true
                    end
                end
            end
        end
    end
end

local function validarArchivosContenido(errores, flagsDefinidas)
    local archivos = archivosCoincidentes(
        "find src/content -name '*.lua' " ..
        "-not -name 'dialogs.lua' -not -name 'text_formatter.lua'"
    )

    for _, archivo in ipairs(archivos) do
        local rutaModulo = archivo:gsub("%.lua$", ""):gsub("/", ".")
        local ok, modulo = pcall(require, rutaModulo)

        if not ok then
            table.insert(
                errores,
                archivo .. ": no se pudo cargar el módulo (" .. tostring(modulo) .. ")"
            )
        else
            for nombre, dialogo in pairs(modulo) do
                validarDialogo(nombre, dialogo, errores, rutaModulo)
                validarFlagsDeDialogo(dialogo, flagsDefinidas)
            end
        end
    end
end

local function validarTriggers(errores, flagsDefinidas, flagsRequeridas)
    local archivos = archivosCoincidentes("find src/triggers -name '*.lua'")

    for _, archivo in ipairs(archivos) do
        local contenido = leerArchivo(archivo)
        if contenido then
            -- ShowDialogAction:create(session, "carpeta/archivo:id")
            for id in contenido:gmatch(
                'ShowDialogAction%s*:%s*create%s*%(%s*session%s*,%s*"([^"]+)"'
            ) do
                resolverDialogo(id, errores, archivo)
            end

            -- TriggerArea:new(..., session, "flag_que_deshabilita")
            for flag in contenido:gmatch(
                'session%s*,%s*"([%w_]+)"'
            ) do
                flagsRequeridas[flag] = archivo
            end

            -- SetFlagAction:create(session, { flag = true })
            for cuerpo in contenido:gmatch(
                'SetFlagAction%s*:%s*create%s*%(%s*session%s*,%s*%{([^}]*)%}'
            ) do
                for flag in cuerpo:gmatch('([%w_]+)%s*=') do
                    flagsDefinidas[flag] = true
                end
            end
        end
    end
end

-- Las puertas requieren flags: Door:new(world, x, y, "flag", "lado")
local function validarPuertas(errores, flagsDefinidas, flagsRequeridas)
    local archivos = archivosCoincidentes("find src/entities -name '*.lua'")

    for _, archivo in ipairs(archivos) do
        local contenido = leerArchivo(archivo)
        if contenido then
            for flag in contenido:gmatch('"([%w_]+)"%s*,%s*"([%w_]+)"') do
                if flag ~= "left" and flag ~= "right" then
                    flagsRequeridas[flag] = archivo
                end
            end
        end
    end
end

function validador.validar()
    local errores = {}
    local flagsDefinidas = {}
    local flagsRequeridas = {}

    -- Defaults de la sesión cuentan como definidas (ej. office_access).
    local session = GameSession:new()
    for flag in pairs(session.flags.flags) do
        flagsDefinidas[flag] = true
    end

    validarArchivosContenido(errores, flagsDefinidas)
    validarTriggers(errores, flagsDefinidas, flagsRequeridas)
    validarPuertas(errores, flagsDefinidas, flagsRequeridas)

    for flag, origen in pairs(flagsRequeridas) do
        if not flagsDefinidas[flag] then
            table.insert(
                errores,
                string.format(
                    "%s: la flag '%s' se requiere pero nunca se define",
                    origen,
                    flag
                )
            )
        end
    end

    table.sort(errores)
    return errores
end

-- Modo script: lua tests/validador.lua
if arg and arg[0] and arg[0]:match("validador%.lua$") then
    local errores = validador.validar()

    if #errores == 0 then
        print("Contenido válido: diálogos, triggers y flags consistentes.")
        os.exit(0)
    end

    print("Se encontraron " .. #errores .. " problemas:")
    for _, err in ipairs(errores) do
        print("  - " .. err)
    end
    os.exit(1)
end

return validador
