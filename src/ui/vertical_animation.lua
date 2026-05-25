-- Objeto que administra los movimientos verticales
local VerticalLayer = {}

function VerticalLayer:new(imagePath, offsetY, speed, scale, limit)

    local layer = {
        image = love.graphics.newImage(imagePath),
        offsetY = offsetY or 0,
        speed = speed or 0,
        baseSpeed = speed or 0,
        scale = scale or 1,
        limit = limit or 0
        ,finished = false
    }

    setmetatable(layer, self)
    self.__index = self

    return layer
end

function VerticalLayer:update(dt)

    if self.finished then
        return
    end

    if self.offsetY < self.limit then

        self.offsetY = self.offsetY - self.speed * dt
        self.speed = self.speed + math.abs(self.baseSpeed) * 0.001

    else
        self.offsetY = self.limit
        self.finished = true
    end
end

function VerticalLayer:draw()

    local scaleX =
        self.scale *
        love.graphics.getWidth() /
        self.image:getWidth()

    local scaleY =
        self.scale *
        love.graphics.getHeight() /
        self.image:getHeight()

    love.graphics.draw(
        self.image,
        0,
        self.offsetY,
        0,
        scaleX,
        scaleY
    )
end

return VerticalLayer
