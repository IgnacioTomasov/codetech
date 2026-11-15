-- Probador de personajes procedurales: muestra varias semillas con sus 4
-- direcciones animando en sitio. Atajo en main.lua (DEBUG_CHARS).

local StateManager = require("src.managers.state_manager")
local character = require("src.entities.character")
local PersonajeProcedural = require("src.entities.procedural_character")

local DIRECCIONES = { "abajo", "derecha", "arriba", "izquierda" }

local probador = {}

function probador:new(session)
    local state = {
        session = session
    }

    setmetatable(state, self)
    self.__index = self

    return state
end

function probador:load()
    self.baseSemilla = 1
    self.cantidad = 4 -- 4 semillas por página (2 columnas x 2 filas)
    self:generar()
end

function probador:generar()
    self.personajes = {}

    for i = 0, self.cantidad - 1 do
        local semilla = self.baseSemilla + i
        local plantilla = PersonajeProcedural.nuevo({ semilla = semilla })
        local hoja = plantilla:obtenerHoja()

        local entidades = {}
        for _, direccion in ipairs(DIRECCIONES) do
            local entidad = character.new(0, 0, 32, 48, 0, 0, 0, hoja)
            entidad.animacionActual = direccion
            entidad.isMoving = true -- animar caminando en sitio
            table.insert(entidades, entidad)
        end

        table.insert(self.personajes, { semilla = semilla, entidades = entidades })
    end
end

function probador:update(dt)
    for _, grupo in ipairs(self.personajes) do
        for _, entidad in ipairs(grupo.entidades) do
            entidad:update(dt)
        end
    end
end

function probador:draw()
    love.graphics.clear(0.12, 0.12, 0.14)

    love.graphics.push()
    love.graphics.scale(2)

    local margenX, margenY = 20, 24
    local pasoX, pasoY = 70, 96
    local anchoBloque = #DIRECCIONES * pasoX

    for indiceGrupo, grupo in ipairs(self.personajes) do
        local columna = (indiceGrupo - 1) % 2
        local fila = math.floor((indiceGrupo - 1) / 2)
        local x0 = margenX + columna * (anchoBloque + 20)
        local y0 = margenY + fila * pasoY

        for indiceEntidad, entidad in ipairs(grupo.entidades) do
            local x = x0 + (indiceEntidad - 1) * pasoX
            local animacion = entidad.animations[entidad.animacionActual]
            animacion:draw(entidad.spriteSheet, x, y0)
        end

        love.graphics.print("semilla " .. grupo.semilla, x0, y0 + 50)
    end

    love.graphics.print("espacio: siguientes semillas - escape: volver", margenX, 340)
    love.graphics.pop()
end

function probador:keypressed(key)
    if key == "escape" then
        local IntroState = require("src.states.intro")
        StateManager:switch(IntroState:new(self.session))
    elseif key == "space" then
        self.baseSemilla = self.baseSemilla + self.cantidad
        self:generar()
    end
end

return probador
