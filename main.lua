local StateManager = require("src.managers.state_manager")
local MenuState = require("src.states.menu")

local GameSession = require("src.core.game_session")
local session = GameSession:new()

function love.load()
    -- usar state manager para instanciar primero el menú. El cual
    -- debe recibi la session para inicializarse.
    StateManager:switch(MenuState:new(session))
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