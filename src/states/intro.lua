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
        ,finished = false
    }

    setmetatable(layer, self)
    self.__index = self

    return layer
end

function VerticalLayer:update(dt)

    if self.finished then
        return
    end

    if self.offsetY < self.limit then

        self.offsetY =
            self.offsetY - self.speed * dt

    else
        self.offsetY = self.limit
        self.finished = true
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

    local speedBase = -20
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


    --Letras Sobre la intro:
    self.titleFont = love.graphics.newFont(72)
end

function intro:update(dt)

    local allFinished = true

    for _, layer in ipairs(self.layers) do

        layer:update(dt)

        if not layer.finished then
            allFinished = false
        end
    end

    self.showText = allFinished

end

function intro:draw()

    for _, layer in ipairs(self.layers) do
        layer:draw()
    end

    if self.showText then
        love.graphics.setFont(self.titleFont)

        love.graphics.printf(
                "CodeTech",
                0,
                100,
                love.graphics.getWidth(),
                "center"
            )
    end

end

function intro:keypressed(key)

    if key == "return" then
        local MenuState = require("src.states.menu")
        StateManager:push(MenuState:new(self.session))
    end
end


return intro
