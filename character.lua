

-- se crea una plantilla "Character" la cual tendrá metodos para trabajar. La idea es que cualquier personaje,
-- pueda instanciarse desde aquí.


local anim8 = require("libraries.anim8")

local Character = {}
Character.__index = Character

function Character.new()
    -- Se crea una nueva tabla, self, que buscará en player sus atributos.”
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

return Character