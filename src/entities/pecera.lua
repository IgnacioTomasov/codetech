local anim8 = require("libraries.anim8")

local Pecera = {}
Pecera.__index = Pecera

function Pecera.new(x, y, spriteName, frameDuration)
    local self = setmetatable({}, Pecera)

    self.x = x
    self.y = y
    self.frameDuration = frameDuration

    self.spriteSheet = love.graphics.newImage(spriteName)

    local frameWidth = math.floor(self.spriteSheet:getWidth() / 2)
    local frameHeight = self.spriteSheet:getHeight()

    self.grid = anim8.newGrid(
        frameWidth,
        frameHeight,
        self.spriteSheet:getWidth(),
        self.spriteSheet:getHeight()
    )

    self.frames = self.grid('1-2', 1)
    self.animation = anim8.newAnimation(self.frames, self.frameDuration)

    return self
end

function Pecera:update(dt)
    self.animation:update(dt)
end

function Pecera:draw()
    self.animation:draw(
        self.spriteSheet,
        self.x,
        self.y
    )
end

return Pecera