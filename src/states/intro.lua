local StateManager = require("src.managers.state_manager")

local intro = {}

local VerticalLayer = {}

-- Objeto que administra los movimientos verticales
function VerticalLayer:new(imagePath, offsetY, speed, scale, limit)

    local layer = {
        image = love.graphics.newImage(imagePath),
        offsetY = offsetY or 0,
        speed = speed or 0,
        scale = scale or 1,
        limit = limit or 0
    }

    setmetatable(layer, self)
    self.__index = self

    return layer
end

function VerticalLayer:update(dt)

    if self.offsetY < self.limit then

        self.offsetY =
            self.offsetY - self.speed * dt

    else
        self.offsetY = self.limit
    end
end

function VerticalLayer:draw()

    local scaleX =
        self.scale *
        love.graphics.getWidth() /
        self.image:getWidth()

    local scaleY =
        self.scale *
        love.graphics.getHeight() /
        self.image:getHeight()

    love.graphics.draw(
        self.image,
        0,
        self.offsetY,
        0,
        scaleX,
        scaleY
    )
end


function intro:new(session)
    -- Es estantard recibir session desde instancias superiores (main)
    local state = {
        session = session
    }

    setmetatable(state, self)
    self.__index = self

    return state
end

function intro:load()

    local speedBase = -10
    self.layers = {

        VerticalLayer:new( --imagePath, offsetY, speed, scale, limit
            'assets/intro/layer_fondo.png',
            -100,
            speedBase,
            1.2,
            0
        ),

        VerticalLayer:new( --imagePath, offsetY, speed, scale
            'assets/intro/layer_edificio_chico.png',
            -100,
            speedBase*2,
            1.2,
            100
        ),

        VerticalLayer:new( --imagePath, offsetY, speed, scale
            'assets/intro/layer_edificio_grande.png',
            -100,
            speedBase*1.25,
            1.2,
            25
        ),
    }

end

function intro:update(dt)

    for _, layer in ipairs(self.layers) do
        layer:update(dt)
    end

end

function intro:draw()

    for _, layer in ipairs(self.layers) do
        layer:draw()
    end

end

function intro:keypressed(key)

    if key == "return" then
        local MenuState = require("src.states.menu")
        StateManager:push(MenuState:new(self.session))
    end
end


return intro
