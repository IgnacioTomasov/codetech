local StateManager = require("src.managers.state_manager")
local AudioManager = require("src.managers.audio_manager")
local anim8 = require("libraries.anim8")
local FadeElement = require("src.ui.fade_element")
local VerticalLayer = require("src.ui.vertical_animation")

local intro = {}
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
    AudioManager:playMusic("intro")

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

    -- para test, mecanismo parar verificar un flag:
    -- print("office_access:",self.session:isFlagEnabled("office_access"))
    -- self.session:setFlag("office_access",true)

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

    self.logo = FadeElement:new({
        image = self.LogoSpriteSheet,
        animation = self.animation,
        x = 0,
        y = 0,
        scaleX = 2,
        scaleY = 2,
        delay = 2,
        fadeSpeed = 0.5
    })

    self.pressEnter = FadeElement:new({
        text = "< PRESIONA ENTER >",
        font = love.graphics.newFont(20),
        centered = true,
        y = 250,
        delay = 4,
        fadeSpeed = 0.5
    })
end

function intro:update(dt)

    local allFinished = true
    

    for _, layer in ipairs(self.layers) do

        layer:update(dt)

        if not layer.finished then
            allFinished = false
        end
    end

    self.logo:update(dt)
    self.pressEnter:update(dt)

end

function intro:draw()

    for _, layer in ipairs(self.layers) do
        layer:draw()
    end

    self.logo:draw()
    self.pressEnter:draw()

end

function intro:keypressed(key)

    if key == "return" then
        local MenuState = require("src.states.menu")
        StateManager:push(MenuState:new(self.session))
    end
end


return intro
