local StateManager = require("src.managers.state_manager")
local MenuState = require("src.states.menu")

function love.load()
    StateManager:switch(MenuState)
end

function love.update(dt)
    StateManager:update(dt)
end

function love.draw()
    StateManager:draw()
end

function love.keypressed(key)
    StateManager:keypressed(key)
end