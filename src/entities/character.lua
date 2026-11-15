-- se crea una plantilla "character" la cual tendrá metodos para trabajar. La idea es que cualquier personaje,
-- pueda instanciarse desde aquí.

local anim8 = require("libraries.anim8")

local character = {}
character.__index = character

function character.new(x,y,w,h,spriteOffsetX,spriteOffsetY,speed,spriteName)
    -- Se crea una nueva tabla, self, que buscará en character sus atributos.”
    local self = setmetatable({}, character)

    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.speed = speed

    -- Offset visual del sprite respecto al collider
    self.spriteOffsetX = spriteOffsetX
    self.spriteOffsetY = spriteOffsetY

    -- Movimiento

    self.timeLastMove = 0
    self.timeChangeDirection=0 --tiempo cuando ocurrió el último cambio de tasa de movimiento (no movimiento en sí)
    self.last_dx = 0
    self.last_dy = 0

    self.isInteracting = false -- se actualiza con interactions.isClose
    self.isClose = false
    self.isMoving = false
    self.isCompleted = false

    self.direction=1
    -- Resolver frames para animación:
    self.direction=1
    self.characterScale=1

    self.animations = {}

    -- El último parámetro acepta una ruta de imagen (como siempre) o una hoja
    -- generada por PersonajeProcedural: { imagen, anchoFrame, altoFrame, filas }.
    local anchoFrame, altoFrame, filas

    if type(spriteName) == "table" then
        self.spriteSheet = spriteName.imagen
        anchoFrame = spriteName.anchoFrame
        altoFrame = spriteName.altoFrame
        filas = spriteName.filas or 4
    else
        self.spriteSheet = love.graphics.newImage(spriteName)
        anchoFrame = math.floor(self.spriteSheet:getWidth() / 4)
        altoFrame = math.floor(self.spriteSheet:getHeight() / 1) -- <-- recordar actualizar el número de rows en la hoja de sprits
        filas = 1
    end

    self.grid = anim8.newGrid(anchoFrame,
                              altoFrame,
                                self.spriteSheet:getWidth(),
                                self.spriteSheet:getHeight())

    if filas > 1 then
        -- Hoja procedural: una fila por dirección (abajo, derecha, arriba, izquierda).
        local nombres = {
            [1] = "abajo",
            [2] = "derecha",
            [3] = "arriba",
            [4] = "izquierda",
        }
        for fila, nombre in ipairs(nombres) do
            self.animations[nombre] = anim8.newAnimation(self.grid('1-4', fila), 0.1)
        end
        self.animacionActual = "abajo"
    else
        self.frames = self.grid('1-4', 1)
        self.animations.walk = anim8.newAnimation(self.frames, 0.1)
        self.animacionActual = "walk"
    end

    -- self.frames_2 = self.grid('1-4', 2) 
    -- self.animations.moveTail = anim8.newAnimation(self.frames_2, 0.1) 


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

    local goalX = self.x + dx
    local goalY = self.y + dy

    local actualX, actualY = world:move(self, goalX, goalY)

    self.x = actualX
    self.y = actualY

    self.last_dx = dx
    self.last_dy = dy

    -- Orientación (solo hojas procedurales con las 4 direcciones)
    if self.animations.derecha then
        if dx > 0 then
            self.animacionActual = "derecha"
        elseif dx < 0 then
            self.animacionActual = "izquierda"
        elseif dy > 0 then
            self.animacionActual = "abajo"
        elseif dy < 0 then
            self.animacionActual = "arriba"
        end
    end

end

function character:update(dt)


    if self.isMoving then
        local animacion = self.animations[self.animacionActual]
        if animacion then
            animacion:update(dt)
        end
    end

end

function character:draw(showCharRectangle)

    if showCharRectangle then
        -- dibujar jugador
        love.graphics.rectangle(
            "fill",
            self.x,
            self.y,
            self.w,
            self.h
        )
    end

    local drawX = self.x + self.spriteOffsetX
    local drawY = self.y + self.spriteOffsetY

    -- print(drawX, drawY)
    local function walk()
        local animacion = self.animations[self.animacionActual]
        if animacion then
            animacion:draw(
            self.spriteSheet,
            drawX,
            drawY)
        end

    end
    -- Recordar mantener la consistencia con la capa de update

    walk()


end

return character