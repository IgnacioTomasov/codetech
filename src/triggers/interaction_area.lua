local InteractionArea = {}
InteractionArea.__index = InteractionArea

function InteractionArea:new(x, y, w, h, callback)

    return setmetatable({
        x = x,
        y = y,
        w = w,
        h = h,
        callback = callback,
        playerInside = false
    }, self)

end

function InteractionArea:update(player)

    self.playerInside =
        player.x >= self.x
        and player.x <= self.x + self.w
        and player.y >= self.y
        and player.y <= self.y + self.h

end

function InteractionArea:keypressed(key)

    if not self.playerInside then
        return
    end

    if key == "space" then
        self.callback()
    end

end

function InteractionArea:draw()

    if self.playerInside then
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

return InteractionArea