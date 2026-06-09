local Door = {}
local AudioManager = require("src.managers.audio_manager")
Door.__index = Door

function Door:new(world, x, y, requiredFlag, side)

    local door = setmetatable({
        x = x,
        world = world,
        y = y,
        w = 32,
        h = 64,
        requiredFlag = requiredFlag,
        side = side or "left",
        isOpen = false,
        openProgress = 0,
        openTimer = 0,
        activationDistance = 64,
        wasOpen = false
    }, self)

    world:add(door, x, y, door.w, door.h)

    return door
end

function Door:getOffsetX()

    if self.side == "left" then
        return -self.w * self.openProgress
    end

    return self.w * self.openProgress

end

function Door:isPlayerNearby(player)

    local playerCenterX = player.x + player.w / 2
    local playerCenterY = player.y + player.h / 2

    local doorCenterX = self.x + self.w / 2
    local doorCenterY = self.y + self.h / 2

    local dx = playerCenterX - doorCenterX
    local dy = playerCenterY - doorCenterY

    local distance = math.sqrt(dx * dx + dy * dy)

    return distance <= self.activationDistance

end

function Door:update(dt, session, player)

    local speed = 2

    local hasAccess = session:isFlagEnabled(self.requiredFlag)
    -- print("has access to door?", hasAccess)

    if hasAccess and player and self:isPlayerNearby(player)
 then
        self.openTimer = 2
    end

    if self.openTimer > 0 then
        self.openTimer = math.max(0, self.openTimer - dt)
        self.isOpen = true
    else
        self.isOpen = false
    end

    if self.isOpen and not self.wasOpen then
        AudioManager:playSfx("door_shhh_open")
    end

    self.wasOpen = self.isOpen

    if self.isOpen then
        self.openProgress = math.min(
            1,
            self.openProgress + dt * speed
        )
    else
        self.openProgress = math.max(
            0,
            self.openProgress - dt * speed
        )
    end

    local offsetX = self:getOffsetX()

    self.world:update(
        self,
        self.x + offsetX,
        self.y
    )

end

function Door:draw()
    local offsetX = self:getOffsetX()

    local frameColor = {1, 1, 1, 1}
    local glassColor = {0.6, 0.9, 1.0, 0.55}

    love.graphics.setColor(frameColor)
    love.graphics.rectangle(
        "fill",
        self.x + offsetX,
        self.y,
        self.w,
        self.h
    )

    love.graphics.setColor(glassColor)
    love.graphics.rectangle(
        "fill",
        self.x + offsetX + 2,
        self.y + 2,
        self.w - 4,
        self.h - 4
    )

    love.graphics.setColor(frameColor)

    if self.side == "left" then
        love.graphics.line(
            self.x + offsetX + self.w - 4,
            self.y + self.h / 2,
            self.x + offsetX + self.w - 10,
            self.y + self.h / 2
        )
    else
        love.graphics.line(
            self.x + offsetX + 4,
            self.y + self.h / 2,
            self.x + offsetX + 10,
            self.y + self.h / 2
        )
    end

end

return Door