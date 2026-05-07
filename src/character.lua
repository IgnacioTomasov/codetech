-- se crea una plantilla "character" la cual tendrá metodos para trabajar. La idea es que cualquier personaje,
-- pueda instanciarse desde aquí.

local anim8 = require("libraries.anim8")

local character = {}
character.__index = character

function character.new(x,y,w,h,speed,spriteName)
    -- Se crea una nueva tabla, self, que buscará en character sus atributos.”
    local self = setmetatable({}, character)

    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.speed = speed
    -- Movimiento

    self.timeLastMove = 0
    self.timeChangeDirection=0 --tiempo cuando ocurrió el último cambio de tasa de movimiento (no movimiento en sí)
    self.last_dx = 0
    self.last_dy = 0

    -- Resolver frames para animación: 
    self.spriteSheet = love.graphics.newImage(spriteName)
    self.grid = anim8.newGrid(490,368,1962,368,0,0,2)
    self.frames = self.grid('1-4', 1)
    self.direction=1
    
    self.animations = {}
    self.animations.caminar = anim8.newAnimation(self.frames, 0.1) 

    self.frames = self.grid("1-4", 1)

    return self
end

function character:move(dx, dy, world)

    --Inferir si se está moviendo:
    self.isMoving = dx ~= 0 or dy ~= 0

    if self.isMoving then
        self.timeLastMove = love.timer.getTime()
    end

    if dx ~= self.last_dx or dy ~= self.last_dy then
        self.timeChangeDirection = love.timer.getTime()
        -- print("cambio de dirección", self.timeChangeDirection)
    end

    self.last_dx = dx
    self.last_dy = dy


    local goalX = self.x + dx
    local goalY = self.y + dy

    local actualX, actualY = world:move(self, goalX, goalY)

    self.x = actualX
    self.y = actualY

end

function character:update(dt)

    if self.isMoving then
        self.animations.caminar:update(dt)
    end

end

function character:draw(showCharRectangle)

    if showCharRectangle then
        -- dibujar jugador
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    end

    local fw = self.grid.frameWidth
    local fh = self.grid.frameHeight
    local alinea =  (math.abs(self.direction) - self.direction) / 2

    self.animations.caminar:draw(
                    self.spriteSheet,
                    self.x,
                    self.y,
                    nil,
                    0.18 * self.direction,
                    0.18,
                    (fw-100) * alinea,   -- cuando direction es negativa, mutiplica por -2 el ofset del ancho total
                    fh / 2   -- oy (centro en Y)
                )

end

return character