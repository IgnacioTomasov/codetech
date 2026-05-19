local StateManager = require("src.managers.state_manager")
local anim8 = require("libraries.anim8")

local intro = {}

local VerticalLayer = {}

-- Objeto que administra los movimientos verticales
function VerticalLayer:new(imagePath, offsetY, speed, scale, limit)

    local layer = {
        image = love.graphics.newImage(imagePath),
        offsetY = offsetY or 0,
        speed = speed or 0,
        baseSpeed = speed or 0,
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

        self.offsetY = self.offsetY - self.speed * dt
        self.speed = self.speed + math.abs(self.baseSpeed) * 0.001

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

    local speedBase = -10
    local scale = 1.2
    self.layers = {

        VerticalLayer:new( --imagePath, offsetY, speed, scale, limit
            'assets/intro/layer_fondo.png',
            -100,
            speedBase,
            scale,
            0
        ),

        VerticalLayer:new( --imagePath, offsetY, speed, scale
            'assets/intro/layer_edificio_chico.png',
            -100,
            speedBase*2,
            scale,
            100
        ),

        VerticalLayer:new( --imagePath, offsetY, speed, scale
            'assets/intro/layer_edificio_grande.png',
            -100,
            speedBase*1.25,
            scale,
            25
        ),
    }

    --Letras Sobre la intro:
    self.titleFont = love.graphics.newFont(72)

    --
    self.LogoSpriteSheet = love.graphics.newImage('assets/intro/layer_logo.png')
    self.grid = anim8.newGrid(math.floor(self.LogoSpriteSheet:getWidth()/2),
                              math.floor(self.LogoSpriteSheet:getHeight()/1), 
                                self.LogoSpriteSheet:getWidth(),
                                self.LogoSpriteSheet:getHeight())

    self.frames = self.grid('1-2', 1) 
    self.animation = anim8.newAnimation(self.frames, 1) 

    self.logoTimer = 0

    self.logoAlpha = 0
    self.fadeSpeed = 0.5
end

function intro:update(dt)

    local allFinished = true
    local LogoIntroDelay = 2 --segundos
    

    for _, layer in ipairs(self.layers) do

        layer:update(dt)

        if not layer.finished then
            allFinished = false
        end
    end

    self.logoTimer = self.logoTimer + dt

    if self.logoTimer > LogoIntroDelay then
        self.showText = true
    else
        self.showText = false
    end

    if self.showText then
        self.animation:update(dt)
        self.logoAlpha = math.min(self.logoAlpha + self.fadeSpeed * dt,1) --min es para evitar pasarse de 1
    end

end

function intro:draw()

    for _, layer in ipairs(self.layers) do
        layer:draw()
    end

    if self.showText then

        love.graphics.setColor(1,1,1,self.logoAlpha) -- transparecia
        self.animation:draw(
            self.LogoSpriteSheet,
            0,
            0,
            0,
            2, -- escala del logo x
            2 -- escala del logo y
        )
        love.graphics.setColor(1,1,1,1) -- sin transparecia
    end

end

function intro:keypressed(key)

    if key == "return" then
        local MenuState = require("src.states.menu")
        StateManager:push(MenuState:new(self.session))
    end
end


return intro
