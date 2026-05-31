local StateManager = require("src.managers.state_manager")
local AudioManager = require("src.managers.audio_manager")
local GameState = require("src.states.game")

local menu = {}
local version = require("src.version")

local FONT_SIZE = 32
local TITLE = "CodeTech"

function menu:new(session)

    local state = {
        session = session,
        options = {
            "Jugar",
            "Salir",
        },
        selected = 1,
    }

    setmetatable(state, self)
    self.__index = self

    return state
end

function menu:load()
    AudioManager.currentMusic:stop()
    self.font = love.graphics.newFont(FONT_SIZE)
    self.fontTitle = love.graphics.newFont(FONT_SIZE*1.5)
end

function menu:update(dt)
end

function menu:draw()

    love.graphics.setFont(self.fontTitle)
    
    local screenWidth = love.graphics.getWidth()
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

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    love.graphics.print(
        version.number,
        screenWidth - 120,
        screenHeight - 60
    )
    
end

function menu:keypressed(key)

    if key == "down" then
        self.selected = math.min(
            self.selected + 1,
            #self.options
        )

        AudioManager:playSfx("move_low")
    end

    if key == "up" then
        self.selected = math.max(
            self.selected - 1,
            1
        )
        AudioManager:playSfx("move_low")
    end

    if key == "return" then

        local option = self.options[self.selected]

        if option == "Jugar" then
            AudioManager:playSfx("accept")
            StateManager:switch(GameState:new(self.session))
        end

        if option == "Salir" then
            love.event.quit()
        end
    end
end

return menu