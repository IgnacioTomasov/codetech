local StatusBar = {}

local BAR_WIDTH = 200
local PADDING = 20
local LINE_HEIGHT = 30
local BOX_PADDING = 30

function StatusBar:new(session)

    local ui = {
        session = session,
        width = BAR_WIDTH,
        padding = PADDING,
        box_padding = BOX_PADDING,
        border_radius = 12
    }

    setmetatable(ui, self)
    self.__index = self

    return ui
end

function StatusBar:load()

    self.font = love.graphics.newFont(18)
end

function StatusBar:update(dt)

end

function StatusBar:draw()

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local x = screenWidth - self.width - self.box_padding

    local y = self.box_padding
    local width = self.width
    local height = screenHeight - 2 * self.box_padding

    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle(
        "fill",
        x,
        y,
        width,
        height,
        self.border_radius,
        self.border_radius
    )

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        "line",
        x,
        y,
        width,
        height,
        self.border_radius,
        self.border_radius
    )

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.font)

    local stats = self.session.stats

    local startY = self.padding + self.box_padding

    love.graphics.print(
        "ESTADO",
        x + self.padding,
        startY
    )

    love.graphics.print(
        "Ansiedad: " .. tostring(stats.ansiedad),
        x + self.padding,
        startY + LINE_HEIGHT * 2
    )

    love.graphics.print(
        "Prestigio: " .. tostring(stats.prestigio),
        x + self.padding,
        startY + LINE_HEIGHT * 3
    )

    love.graphics.print(
        "Energia: " .. tostring(stats.energia),
        x + self.padding,
        startY + LINE_HEIGHT * 4
    )
end

return StatusBar