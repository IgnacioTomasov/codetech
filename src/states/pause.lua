local StateManager = require("src.managers.state_manager")
local AudioManager = require("src.managers.audio_manager")
local SaveSystem = require("src.core.save_system")

local pause = {}

local FONT_SIZE = 32

function pause:new(session)

    local state = {
        session = session,
        options = {
            "Guardar partida",
            "Volver a jugar",
            "Salir al menú",
        },
        selected = 1,
    }

    setmetatable(state, self)
    self.__index = self

    return state
end

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

        local option = self.options[self.selected]

        if option == "Guardar partida" then
            SaveSystem.guardar(self.session)
            AudioManager:playSfx("accept")
            StateManager:pop()
        end

        if option == "Volver a jugar" then
            StateManager:pop()
        end

        if option == "Salir al menú" then
            local MenuState = require("src.states.menu")

            StateManager:switch(MenuState:new(self.session))
        end
    end
end

return pause