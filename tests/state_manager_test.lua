-- Pruebas de src/managers/state_manager.lua
local StateManager = require("src.managers.state_manager")

-- Estados falsos que registran sus llamadas en una lista.
local function crearEstado(nombre, registro, esOverlay)
    local estado = {
        isOverlay = esOverlay or false,
    }

    function estado:load()
        registro.load[nombre] = (registro.load[nombre] or 0) + 1
    end

    function estado:enter()
        registro.enter[nombre] = (registro.enter[nombre] or 0) + 1
    end

    function estado:update(dt)
        registro.update[nombre] = (registro.update[nombre] or 0) + 1
    end

    function estado:keypressed(key)
        registro.keypressed[nombre] = (registro.keypressed[nombre] or 0) + 1
    end

    function estado:draw()
        table.insert(registro.draw, nombre)
    end

    return estado
end

local function crearRegistro()
    return { load = {}, enter = {}, update = {}, keypressed = {}, draw = {} }
end

return {

    ["push ejecuta load una vez y enter en cada push"] = function()
        local registro = crearRegistro()
        local estado = crearEstado("base", registro)

        StateManager:switch(estado)
        igual(registro.load.base, 1)
        igual(registro.enter.base, 1)

        StateManager:push(estado)
        igual(registro.load.base, 1, "load no debe repetirse")
        igual(registro.enter.base, 2, "enter debe ejecutarse de nuevo")
    end,

    ["switch limpia la pila"] = function()
        local registro = crearRegistro()
        local a = crearEstado("a", registro)
        local b = crearEstado("b", registro)

        StateManager:switch(a)
        StateManager:push(b)
        StateManager:switch(a)

        igual(StateManager:current(), a)
        igual(StateManager:pop(), a, "la pila debe tener un solo estado")
        igual(StateManager:pop(), nil)
    end,

    ["update y keypressed solo tocan el tope"] = function()
        local registro = crearRegistro()
        local base = crearEstado("base", registro)
        local overlay = crearEstado("overlay", registro, true)

        StateManager:switch(base)
        StateManager:push(overlay)

        StateManager:update(0.1)
        StateManager:keypressed("space")

        igual(registro.update.overlay, 1)
        igual(registro.update.base, nil, "el estado bajo el overlay no se actualiza")
        igual(registro.keypressed.overlay, 1)
        igual(registro.keypressed.base, nil)
    end,

    ["draw de overlay incluye el estado base"] = function()
        local registro = crearRegistro()
        local base = crearEstado("base", registro)
        local overlay = crearEstado("overlay", registro, true)

        StateManager:switch(base)
        StateManager:push(overlay)
        StateManager:draw()

        igual(registro.draw[1], "base", "el estado base se dibuja primero")
        igual(registro.draw[2], "overlay")
        igual(#registro.draw, 2)
    end,

    ["draw sin overlay dibuja solo el tope"] = function()
        local registro = crearRegistro()
        local base = crearEstado("base", registro)
        local tope = crearEstado("tope", registro)

        StateManager:switch(base)
        StateManager:push(tope)
        StateManager:draw()

        igual(registro.draw[1], "tope")
        igual(#registro.draw, 1, "el estado bajo un no-overlay no debe dibujarse")
    end,

}
