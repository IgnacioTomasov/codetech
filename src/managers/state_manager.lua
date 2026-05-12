local StateManager = {}

StateManager.stack = {}


function StateManager:push(state)

    table.insert(self.stack, state)

    -- Ejecutar load solo una vez
    if not state.loaded and state.load then
        state:load()
        state.loaded = true
    end

    -- Ejecutar enter cada vez
    if state.enter then
        state:enter()
    end
end

function StateManager:pop()

    local state = table.remove(self.stack)
    return state
end

function StateManager:current()
    -- acceder al top del stack a través del largo de la tabla (#)
    return self.stack[#self.stack]

end

function StateManager:switch(state)
    -- Cada estado entregado en switch debe ser una clase con los métodos update, draw y keypressed.
    self.stack = {}
    self:push(state)
end

function StateManager:update(dt)

    local current = self:current()

    if current and current.update then
        current:update(dt)
    end
end

function StateManager:draw()

    local current = self:current()

    if current and current.draw then
        current:draw()
    end

end

function StateManager:keypressed(key)

    local current = self:current()

    if current and current.keypressed then
        current:keypressed(key)
    end

end



return StateManager