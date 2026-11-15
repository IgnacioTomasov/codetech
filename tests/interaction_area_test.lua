-- Pruebas de src/triggers/interaction_area.lua
local InteractionArea = require("src.triggers.interaction_area")

return {

    ["dispara con espacio si el jugador está dentro"] = function()
        local llamadas = 0
        local area = InteractionArea:new(
            0, 0, 32, 32,
            function() llamadas = llamadas + 1 end
        )

        area:update({ x = 10, y = 10 })
        area:keypressed("space")

        igual(llamadas, 1)
    end,

    ["no dispara con otra tecla"] = function()
        local llamadas = 0
        local area = InteractionArea:new(
            0, 0, 32, 32,
            function() llamadas = llamadas + 1 end
        )

        area:update({ x = 10, y = 10 })
        area:keypressed("return")

        igual(llamadas, 0)
    end,

    ["no dispara si el jugador está fuera"] = function()
        local llamadas = 0
        local area = InteractionArea:new(
            0, 0, 32, 32,
            function() llamadas = llamadas + 1 end
        )

        area:update({ x = 100, y = 100 })
        area:keypressed("space")

        igual(llamadas, 0)
    end,

    ["update marca la presencia del jugador"] = function()
        local area = InteractionArea:new(
            0, 0, 32, 32,
            function() end
        )

        falso(area.playerInside)

        area:update({ x = 10, y = 10 })
        verdad(area.playerInside, "jugador dentro debería marcarse")
    end,

}
