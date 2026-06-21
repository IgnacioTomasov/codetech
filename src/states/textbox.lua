local StateManager = require("src.managers.state_manager")
local AudioManager = require("src.managers.audio_manager")
local UI = require("src.ui.ui_constants")

local TextBoxState = {}

function TextBoxState:new(session, config)

    local state = {
        session = session,
        pages = config.pages or {},
        currentPage = 1,
        isOverlay = true,

        margin = UI.TEXTBOX.MARGIN,
        boxHeight = UI.TEXTBOX.HEIGHT,
        borderRadius = UI.BORDER_RADIUS
    }

    setmetatable(state, self)
    self.__index = self

    return state

end

function TextBoxState:load()
    self.font = love.graphics.newFont(UI.TEXTBOX.FONT_SIZE)
end

function TextBoxState:update(dt)

end

function TextBoxState:keypressed(key)

    local page = self.pages[self.currentPage]

    if type(page) == "table" and page.options then

        if key == "down" then
            self.selectedOption = math.min(
                (self.selectedOption or 1) + 1,
                #page.options
            )
            AudioManager:playSfx("move_low")
            return
        end

        if key == "up" then
            self.selectedOption = math.max(
                (self.selectedOption or 1) - 1,
                1
            )
            AudioManager:playSfx("move_low")
            return
        end

    end

    if key == "return" then

        local page = self.pages[self.currentPage]

        if type(page) == "table" and page.options then

            local option = page.options[self.selectedOption or 1]

            if option and option.flag then
                self.session:setFlag(option.flag, true)
            end
            AudioManager:playSfx("accept")
        end

        if self.currentPage < #self.pages then
            AudioManager:playSfx("accept")
            self.currentPage = self.currentPage + 1
            self.selectedOption = 1
        else
            AudioManager:playSfx("accept")
            StateManager:pop()
        end

    end

end

function TextBoxState:draw()

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    love.graphics.setColor(UI.COLORS.PANEL_BACKGROUND)

    love.graphics.rectangle(
        "fill",
        self.margin,
        screenHeight - self.boxHeight - self.margin,
        screenWidth - (self.margin * 2),
        self.boxHeight,
        self.borderRadius,
        self.borderRadius
    )

    love.graphics.setColor(1, 1, 1)

    love.graphics.rectangle(
        "line",
        self.margin,
        screenHeight - self.boxHeight - self.margin,
        screenWidth - (self.margin * 2),
        self.boxHeight,
        self.borderRadius,
        self.borderRadius
    )

    love.graphics.setFont(self.font)

    local page = self.pages[self.currentPage]

    local pageText = ""

    if type(page) == "table" then
        pageText = page.text or ""
    else
        pageText = page or ""
    end

    love.graphics.printf(
        pageText,
        self.margin + 15,
        screenHeight - self.boxHeight,
        screenWidth - ((self.margin + 15) * 2),
        "left"
    )

    if type(page) == "table" and page.options then

        local optionsY = screenHeight - self.boxHeight + 40

        for i, option in ipairs(page.options) do

            local prefix = "  "

            if i == (self.selectedOption or 1) then
                prefix = "> "
            end

            love.graphics.print(
                prefix .. option.text,
                self.margin + 20,
                optionsY + ((i - 1) * 24)
            )

        end

    end

    if self.currentPage < #self.pages then
        love.graphics.printf(
            ">>",
            self.margin,
            screenHeight - self.margin - 30,
            screenWidth - (self.margin * 2.5),
            "right"
        )
    end

    love.graphics.setColor(1, 1, 1)

end

return TextBoxState