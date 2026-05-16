local GameSession = {}
GameSession.__index = GameSession

function GameSession:new()

    local session = {

        stats = {
            anciedad = 0,
            prestigio = 0,
            energia = 100,
        },

        time = {
            day = 1,
            hour = 9,
            minute = 0,
        },

    }

    setmetatable(session, self)

    return session
end

return GameSession