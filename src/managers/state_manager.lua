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

    local stackSize = #self.stack

    if stackSize == 0 then
        return
    end

    -- Buscar el primer estado que debe dibujarse.
    -- Si hay overlays encima, se dibujará también el estado base.
    local startIndex = stackSize

    while startIndex > 1 do

        local state = self.stack[startIndex]

        if not state.isOverlay then
            break
        end

        startIndex = startIndex - 1

    end

    -- Dibujar desde el estado base hasta el top
    for i = startIndex, stackSize do

        local state = self.stack[i]

        if state and state.draw then
            state:draw()
        end

    end

end

function StateManager:keypressed(key)

    local current = self:current()

    if current and current.keypressed then
        current:keypressed(key)
    end

end



return StateManager