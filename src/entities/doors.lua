local Door = {}
Door.__index = Door

function Door:new(world, x, y, w, h, requiredFlag)

    local door = setmetatable({
        x = x,
        y = y,
        w = w,
        h = h,
        requiredFlag = requiredFlag,
        isOpen = false
    }, self)

    world:add(door, x, y, w, h)

    return door
end

function Door:update(dt,session)

    self.isOpen = session:isFlagEnabled(self.requiredFlag)
    print(self.isOpen)

end

function Door:draw()

    -- if self.isOpen then
    --     love.graphics.setColor(0, 1, 0, 0.4)
    -- else
    --     love.graphics.setColor(1, 0, 0, 0.4)
    -- end
    love.graphics.setColor(0.7,1,1)

    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

end

return Door