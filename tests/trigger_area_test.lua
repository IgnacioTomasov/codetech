-- Pruebas de src/triggers/trigger_area.lua
local TriggerArea = require("src.triggers.trigger_area")

local function crearSessionConFlag(habilitada)
    return {
        isFlagEnabled = function(_, _)
            return habilitada
        end,
    }
end

return {

    ["dispara una vez al entrar y resetea al salir"] = function()
        local llamadas = 0
        local area = TriggerArea:new(
            10, 10, 32, 32,
            function() llamadas = llamadas + 1 end,
            nil,
            nil
        )

        -- Fuera del área.
        area:update({ x = 0, y = 0 })
        igual(llamadas, 0)

        -- Al entrar dispara.
        area:update({ x = 20, y = 20 })
        igual(llamadas, 1)

        -- Seguir dentro no dispara de nuevo.
        area:update({ x = 30, y = 30 })
        igual(llamadas, 1, "no debe disparar dos veces sin salir")

        -- Salir y volver a entrar dispara otra vez.
        area:update({ x = 200, y = 200 })
        area:update({ x = 20, y = 20 })
        igual(llamadas, 2)
    end,

    ["disableFlag habilitada impide el disparo"] = function()
        local llamadas = 0
        local session = crearSessionConFlag(true)

        local area = TriggerArea:new(
            10, 10, 32, 32,
            function() llamadas = llamadas + 1 end,
            session,
            "contrato_firmado"
        )

        area:update({ x = 20, y = 20 })
        igual(llamadas, 0, "con la flag activa no debe dispararse")
    end,

    ["disableFlag deshabilitada permite el disparo"] = function()
        local llamadas = 0
        local session = crearSessionConFlag(false)

        local area = TriggerArea:new(
            10, 10, 32, 32,
            function() llamadas = llamadas + 1 end,
            session,
            "contrato_firmado"
        )

        area:update({ x = 20, y = 20 })
        igual(llamadas, 1)
    end,

}
