local UI = require("src.ui.ui_constants")

local StatusBar = {}

local LINE_HEIGHT = 30


function StatusBar:new(session)

    local ui = {
        session = session,
        width = UI.STATUS_BAR.WIDTH,
        padding = UI.STATUS_BAR.PADDING,
        box_padding =  UI.STATUS_BAR.BOX_PADDING,
        border_radius = UI.BORDER_RADIUS
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

    local reservedBottomSpace = UI.RESERVED_BOTTOM_SPACE

    local height =
        screenHeight
        - (2 * self.box_padding)
        - reservedBottomSpace

    love.graphics.setColor(UI.COLORS.PANEL_BACKGROUND)
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