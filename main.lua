local StateManager = require("src.managers.state_manager")

local GameSession = require("src.core.game_session")
local session = GameSession:new()
local START_STATE = "menu"

function love.load()
    local statePath = "src.states." .. START_STATE

    local StateClass = require(statePath)

    StateManager:switch(StateClass:new(session))
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