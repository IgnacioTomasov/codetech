local TriggerArea = {}
TriggerArea.__index = TriggerArea

function TriggerArea:new(x, y, w, h, callback)

    return setmetatable({
        x = x,
        y = y,
        w = w,
        h = h,
        callback = callback,
        triggered = false
    }, self)

end

function TriggerArea:update(player)

    if self.triggered then
        return
    end

    if player.x >= self.x
        and player.x <= self.x + self.w
        and player.y >= self.y
        and player.y <= self.y + self.h then

        self.triggered = true
        self.callback()

    end
end

function TriggerArea:draw()

    if self.triggered then
        love.graphics.setColor(0, 1, 0, 0.4)
    else
        love.graphics.setColor(1, 1, 0, 0.4)
    end

    love.graphics.rectangle(
        "fill",
        self.x,
        self.y,
        self.w,
        self.h
    )

    love.graphics.setColor(1, 1, 1, 1)

end

return TriggerArea