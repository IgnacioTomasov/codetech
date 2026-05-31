local GameFlags = require("src.core.game_flags")

local GameSession = {}
GameSession.__index = GameSession

function GameSession:new()

    local session = {
        flags = GameFlags:new(),
        stats = {},
        clock = {},
    }

    setmetatable(session, self)

    session:initialize()

    return session
end

function GameSession:initialize()

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