-- Pruebas de src/core/save_system.lua
local SaveSystem = require("src.core.save_system")
local GameSession = require("src.core.game_session")

local function crearSesionDePrueba()
    local session = GameSession:new()

    session:setFlag("contract_signed", true)
    session:setFlag("office_access", true)
    session:setFlag("tutorial_completed", false)

    session.stats.ansiedad = 7
    session.stats.prestigio = 3
    session.stats.energia = 55

    session.clock.day = 3
    session.clock.hour = 14
    session.clock.minute = 45

    session.player.name = "Ada"

    return session
end

return {

    ["roundtrip conserva flags, stats, clock y player"] = function()
        local original = crearSesionDePrueba()

        local restaurada = SaveSystem.restore(
            SaveSystem.deserialize(SaveSystem.serialize(original))
        )

        verdad(restaurada:isFlagEnabled("contract_signed"), "contract_signed")
        verdad(restaurada:isFlagEnabled("office_access"), "office_access")
        falso(restaurada:isFlagEnabled("tutorial_completed"), "tutorial_completed")

        igual(restaurada.stats.ansiedad, 7)
        igual(restaurada.stats.prestigio, 3)
        igual(restaurada.stats.energia, 55)

        igual(restaurada.clock.day, 3)
        igual(restaurada.clock.hour, 14)
        igual(restaurada.clock.minute, 45)

        igual(restaurada.player.name, "Ada")
    end,

    ["roundtrip de una sesión sin cambios conserva los defaults"] = function()
        local original = GameSession:new()

        local restaurada = SaveSystem.restore(
            SaveSystem.deserialize(SaveSystem.serialize(original))
        )

        igual(restaurada.stats.ansiedad, 0)
        igual(restaurada.clock.day, 1)
        igual(restaurada.player.name, "Ignacio")
        falso(restaurada:isFlagEnabled("office_access"))
    end,

    ["roundtrip conserva strings con caracteres especiales"] = function()
        local original = GameSession:new()
        original.player.name = 'Ada "Lovelace" \n test'

        local restaurada = SaveSystem.restore(
            SaveSystem.deserialize(SaveSystem.serialize(original))
        )

        igual(restaurada.player.name, 'Ada "Lovelace" \n test')
    end,

    ["aplicar reemplaza las flags previas de la sesión"] = function()
        local original = crearSesionDePrueba()
        local texto = SaveSystem.serialize(original)

        local destino = GameSession:new()
        destino:setFlag("flag_previa", true)

        SaveSystem.aplicar(destino, SaveSystem.deserialize(texto))

        falso(destino:isFlagEnabled("flag_previa"), "las flags previas deben limpiarse")
        verdad(destino:isFlagEnabled("contract_signed"))
        igual(destino.player.name, "Ada")
    end,

    ["aplicar mantiene la identidad de la sesión"] = function()
        local original = crearSesionDePrueba()
        local texto = SaveSystem.serialize(original)

        local destino = GameSession:new()
        local resultado = SaveSystem.aplicar(destino, SaveSystem.deserialize(texto))

        igual(resultado, destino)
    end,

    ["deserialize rechaza texto corrupto"] = function()
        local ok = pcall(SaveSystem.deserialize, "esto no es lua")
        falso(ok, "texto no interpretable debe fallar")

        ok = pcall(SaveSystem.deserialize, "return 5")
        falso(ok, "un valor que no es tabla debe fallar")
    end,

    ["deserialize rechaza versión desconocida"] = function()
        local ok = pcall(SaveSystem.deserialize, "return { version = 999 }")
        falso(ok, "una versión futura debe fallar")
    end,

    ["guardar y cargar con archivo"] = function()
        local ruta = os.tmpname()
        local original = crearSesionDePrueba()

        verdad(SaveSystem.guardar(original, ruta))

        local restaurada = SaveSystem.cargar(ruta)
        verdad(restaurada ~= nil)
        igual(restaurada.player.name, "Ada")
        verdad(restaurada:isFlagEnabled("office_access"))
        igual(restaurada.clock.day, 3)

        os.remove(ruta)
    end,

    ["cargarEn restaura sobre una sesión existente con archivo"] = function()
        local ruta = os.tmpname()
        SaveSystem.guardar(crearSesionDePrueba(), ruta)

        local destino = GameSession:new()
        destino:setFlag("flag_previa", true)

        local resultado = SaveSystem.cargarEn(destino, ruta)

        igual(resultado, destino)
        falso(destino:isFlagEnabled("flag_previa"))
        igual(destino.stats.energia, 55)

        os.remove(ruta)
    end,

    ["existeGuardado detecta el archivo"] = function()
        local ruta = os.tmpname()
        os.remove(ruta) -- en POSIX os.tmpname crea el archivo

        falso(SaveSystem.existeGuardado(ruta), "no debe existir todavía")

        SaveSystem.guardar(crearSesionDePrueba(), ruta)
        verdad(SaveSystem.existeGuardado(ruta))

        os.remove(ruta)
        falso(SaveSystem.existeGuardado(ruta), "tras eliminar no debe existir")
    end,

    ["cargar sobre archivo inexistente retorna nil"] = function()
        local ruta = os.tmpname()
        os.remove(ruta)
        igual(SaveSystem.cargar(ruta), nil)
        igual(SaveSystem.cargarEn(GameSession:new(), ruta), nil)
    end,

}
