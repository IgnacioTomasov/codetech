local GameFlags = {}
GameFlags.__index = GameFlags

function GameFlags:new()

    local obj = {
        flags = {}
    }

    setmetatable(obj, self)

    return obj
end

function GameFlags:set(flag, value)
    self.flags[flag] = value
end

function GameFlags:get(flag)
    return self.flags[flag]
end

function GameFlags:isEnabled(flag)
    return self.flags[flag] == true
end

return GameFlags