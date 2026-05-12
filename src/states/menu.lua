local StateManager = require("src.managers.state_manager")
local GameState = require("src.states.game")

local menu = {}

menu.options = {
    "Jugar",
    "Salir",
}

local FONT_SIZE = 32

menu.selected = 1

function menu:load()
    self.font = love.graphics.newFont(FONT_SIZE)
end

function menu:update(dt)
end

function menu:draw()

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

function menu:keypressed(key)

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

        local option = self.options[self.selected]

        if option == "Jugar" then
            
            StateManager:switch(GameState)
        end

        if option == "Salir" then
            love.event.quit()
        end
    end
end

return menu