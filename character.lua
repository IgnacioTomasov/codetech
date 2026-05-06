-- se crea una plantilla "Character" la cual tendrá metodos para trabajar. La idea es que cualquier personaje,
-- pueda instanciarse desde aquí.

local anim8 = require("libraries.anim8")

local Character = {}
Character.__index = Character

function Character.new()
    -- Se crea una nueva tabla, self, que buscará en Character sus atributos.”
    local self = setmetatable({}, Character)

    self.x = 350
    self.y = 300
    self.w = 80
    self.h = 30
    -- Movimiento
    self.speed = 200
    self.speer_ini = 200

    -- Resolver frames para animación: 
    self.spriteSheet = love.graphics.newImage('sprites/bingo_row_1.png')
    self.grid = anim8.newGrid(490,368,1962,368,0,0,2)
    self.frames = self.grid('1-4', 1)
    self.direction=1
    
    self.animations = {}
    self.animations.caminar = anim8.newAnimation(self.frames, 0.1) 

    self.frames = self.grid("1-4", 1)

    return self
end

function Character:move(dx, dy, world)

    --Inferir si se está moviendo:
    self.isMoving = dx ~= 0 or dy ~= 0

    local goalX = self.x + dx
    local goalY = self.y + dy

    local actualX, actualY = world:move(self, goalX, goalY)

    self.x = actualX
    self.y = actualY

end

function Character:update(dt)

    if self.isMoving then
        self.animations.caminar:update(dt)
    end

end

function Character:draw()

    -- dibujar jugador
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    local fw = self.grid.frameWidth
    local fh = self.grid.frameHeight
    local alinea =  (math.abs(self.direction) - self.direction) / 2

    self.animations.caminar:draw(
                    self.spriteSheet,
                    self.x,
                    self.y,
                    nil,
                    0.2 * self.direction,
                    0.2,
                    (fw-100) * alinea,   -- cuando direction es negativa, mutiplica por -2 el ofset del ancho total
                    fh / 2   -- oy (centro en Y)
                )

end

return Character