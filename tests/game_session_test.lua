-- Pruebas de src/core/game_session.lua
local GameSession = require("src.core.game_session")

return {

    ["initialize declara los stats por defecto"] = function()
        local session = GameSession:new()
        igual(session.stats.ansiedad, 0)
        igual(session.stats.prestigio, 0)
        igual(session.stats.energia, 100)
    end,

    ["initialize declara el reloj por defecto"] = function()
        local session = GameSession:new()
        igual(session.clock.day, 1)
        igual(session.clock.hour, 9)
        igual(session.clock.minute, 0)
    end,

    ["office_access comienza deshabilitada"] = function()
        local session = GameSession:new()
        falso(session:isFlagEnabled("office_access"))
    end,

    ["setFlag/getFlag roundtrip"] = function()
        local session = GameSession:new()
        falso(session:isFlagEnabled("contract_signed"))

        session:setFlag("contract_signed", true)

        igual(session:getFlag("contract_signed"), true)
        verdad(session:isFlagEnabled("contract_signed"))
    end,

}
