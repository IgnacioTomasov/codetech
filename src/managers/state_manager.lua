local StateManager = {}

StateManager.current = nil

function StateManager:switch(state)
    -- Cada estado entregado en switch debe ser una clase con los métodos update, draw y keypressed.
    self.current = state

    -- Ejecutar load del estado una vez.
    if self.current.load then
        self.current:load()
    end
end

function StateManager:update(dt)
    self.current:update(dt)
end

function StateManager:draw()
    self.current:draw()
end

function StateManager:keypressed(key)
    self.current:keypressed(key)
end

return StateManager