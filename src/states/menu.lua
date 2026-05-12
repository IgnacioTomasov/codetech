local StateManager = require("src.managers.state_manager")
local GameState = require("src.states.game")

local menu = {}

menu.options = {
    "Jugar",
    "Salir",
}

menu.selected = 1

local FONT_SIZE = 32
local TITLE = "Buscando a Praga"

local screenWidth = love.graphics.getWidth()




function menu:load()
    self.font = love.graphics.newFont(FONT_SIZE)
    self.fontTitle = love.graphics.newFont(FONT_SIZE*1.5)
end

function menu:update(dt)
end

function menu:draw()

    love.graphics.setFont(self.fontTitle)

    local titleWidth = self.fontTitle:getWidth(TITLE)
    local x = (screenWidth - titleWidth) / 2
    love.graphics.print(TITLE,x,100)


    love.graphics.setFont(self.font)
    local verticalMargin = 20

    for i, option in ipairs(self.options) do

        local prefix = "  "

        if i == self.selected then
            prefix = "> "
        end


        love.graphics.print(
            prefix .. option,
            100,
            200 + (i * (FONT_SIZE + verticalMargin))
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