local StateManager = require("src.managers.state_manager")

local pause = {}

pause.options = {
    "Volver a jugar",
    "Salir al menú",
}

local FONT_SIZE = 32

pause.selected = 1

function pause:load()
    self.font = love.graphics.newFont(FONT_SIZE)
end

function pause:update(dt)
end

function pause:draw()

    local verticalMargin = 20

    for i, option in ipairs(self.options) do

        local prefix = "  "

        if i == self.selected then
            prefix = "> "
        end

        love.graphics.setFont(self.font)

        love.graphics.print(
            prefix .. option,
            100,
            100 + (i * (FONT_SIZE + verticalMargin))
        )
    end
end

function pause:keypressed(key)

    if key == "down" then
        self.selected = math.min(
            self.selected + 1,
            #self.options
        )
    end

    if key == "up" then
        self.selected = math.max(
            self.selected - 1,
            1
        )
    end

    if key == "return" then

        if self.selected == 1 then
            StateManager:pop()
        end

        if self.selected == 2 then

            local MenuState = require("src.states.menu")

            StateManager:switch(MenuState)
        end
    end
end

return pause