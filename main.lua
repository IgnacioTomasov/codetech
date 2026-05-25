local StateManager = require("src.managers.state_manager")
local AudioManager = require("src.managers.audio_manager")
local GameSession = require("src.core.game_session")
local session = GameSession:new()
local START_STATE = "intro"

function love.load()
    local statePath = "src.states." .. START_STATE

    local StateClass = require(statePath)

    AudioManager:load() -- nota: luego el objeto de audio manager puede ser importado con require y ya estará "cargado" (con load)

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