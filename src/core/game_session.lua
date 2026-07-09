local GameFlags = require("src.core.game_flags")

local GameSession = {}
GameSession.__index = GameSession

function GameSession:new()

    local session = {
        flags = GameFlags:new(),
        stats = {},
        clock = {},
        player = {},
    }

    setmetatable(session, self)

    session:initialize()

    return session
end

function GameSession:initialize()

    self.stats = {
        ansiedad = 0,
        prestigio = 0,
        energia = 100,
    }

    self.clock = {
        day = 1,
        hour = 9,
        minute = 0,
    }
    
    self.player = {
        -- Nombre temporal. Más adelante será definido
        -- por el jugador al comenzar una partida.
        name = "Ignacio",
    }
    
    self.flags:set("office_access", false)

end

function GameSession:setFlag(flag, value)
    self.flags:set(flag, value)
end

function GameSession:getFlag(flag)
    return self.flags:get(flag)
end

function GameSession:isFlagEnabled(flag)
    return self.flags:isEnabled(flag)
end

return GameSession