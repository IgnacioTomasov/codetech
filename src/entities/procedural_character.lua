-- Personaje procedural: genera un personaje completo a partir de parámetros
-- (paleta, proporciones, rostro, accesorios) y lo "hornea" una sola vez en un
-- sprite sheet de 4 columnas (frames de caminar) x 4 filas (abajo, derecha,
-- arriba, izquierda). La hoja resultante se usa como cualquier sprite con anim8.

local esqueleto = require("src.entities.procedural_esqueleto")

local PersonajeProcedural = {}
PersonajeProcedural.__index = PersonajeProcedural

----------------------------------------------------------------------
-- Paletas base (tonos "de oficina")
----------------------------------------------------------------------

local PALETAS_BASE = {
    pieles = {
        { 0.98, 0.85, 0.72 },
        { 0.90, 0.72, 0.55 },
        { 0.72, 0.52, 0.38 },
    },
    pelos = {
        { 0.15, 0.12, 0.10 },
        { 0.35, 0.22, 0.12 },
        { 0.60, 0.60, 0.60 },
        { 0.80, 0.72, 0.45 },
    },
    camisas = {
        { 0.55, 0.70, 0.88 },
        { 0.85, 0.87, 0.90 },
        { 0.45, 0.55, 0.70 },
        { 0.90, 0.85, 0.70 },
    },
    pantalones = {
        { 0.20, 0.25, 0.40 },
        { 0.30, 0.30, 0.35 },
        { 0.40, 0.30, 0.22 },
    },
    zapatos = {
        { 0.15, 0.15, 0.18 },
        { 0.30, 0.20, 0.15 },
    },
}

local ESTILOS_ROSTRO = {
    ojos = { [1] = "puntos", [2] = "abiertos" },
    boca = { [1] = "linea", [2] = "sonrisa", [3] = "abierta" },
    cejas = { [1] = "normales", [2] = "ningunas" },
}

local COLOR_MALETIN = { 0.42, 0.28, 0.16 }
local COLOR_OJOS = { 0.10, 0.10, 0.12 }
local FILTRO_PIXELES = "nearest"

----------------------------------------------------------------------
-- Utilidades
----------------------------------------------------------------------

local function elegir(lista, azar)
    return lista[math.floor(azar() * #lista) + 1]
end

local function colorTabla(color)
    return { color[1], color[2], color[3], color[4] or 1 }
end

-- Atenúa un color (factor < 1): sirve para dar contraste a las mangas.
local function atenuar(color, factor)
    return {
        color[1] * factor,
        color[2] * factor,
        color[3] * factor,
        color[4] or 1,
    }
end

----------------------------------------------------------------------
-- Constructor
----------------------------------------------------------------------

-- opciones (todas opcionales):
--   semilla    = número (variantes deterministas; nil = valores por defecto)
--   paleta     = { piel, pelo, camisa, pantalon, zapatos } (cada uno {r,g,b,a})
--   cuerpo     = proporciones (ver esqueleto.cuerpoPorDefecto)
--   rostro     = { ojos =, boca =, cejas = }
--   accesorios = { maletin = bool, gafas = bool }
function PersonajeProcedural.nuevo(opciones)
    opciones = opciones or {}
    local self = setmetatable({}, PersonajeProcedural)

    local cuerpo = esqueleto.completarCuerpo(opciones.cuerpo)
    local accesorios = {
        maletin = opciones.accesorios and opciones.accesorios.maletin or false,
        gafas = opciones.accesorios and opciones.accesorios.gafas or false,
    }
    local estilo = {
        ojos = (opciones.rostro and opciones.rostro.ojos) or "puntos",
        boca = (opciones.rostro and opciones.rostro.boca) or "linea",
        cejas = (opciones.rostro and opciones.rostro.cejas) or "normales",
    }
    local paleta = {
        piel = colorTabla((opciones.paleta and opciones.paleta.piel) or PALETAS_BASE.pieles[1]),
        pelo = colorTabla((opciones.paleta and opciones.paleta.pelo) or PALETAS_BASE.pelos[1]),
        camisa = colorTabla((opciones.paleta and opciones.paleta.camisa) or PALETAS_BASE.camisas[1]),
        pantalon = colorTabla((opciones.paleta and opciones.paleta.pantalon) or PALETAS_BASE.pantalones[1]),
        zapatos = colorTabla((opciones.paleta and opciones.paleta.zapatos) or PALETAS_BASE.zapatos[1]),
    }

    -- Variante determinista a partir de la semilla.
    if opciones.semilla then
        local azar = esqueleto.crearAzar(opciones.semilla)

        paleta.piel = colorTabla(elegir(PALETAS_BASE.pieles, azar))
        paleta.pelo = colorTabla(elegir(PALETAS_BASE.pelos, azar))
        paleta.camisa = colorTabla(elegir(PALETAS_BASE.camisas, azar))
        paleta.pantalon = colorTabla(elegir(PALETAS_BASE.pantalones, azar))
        paleta.zapatos = colorTabla(elegir(PALETAS_BASE.zapatos, azar))

        estilo.ojos = elegir(ESTILOS_ROSTRO.ojos, azar)
        estilo.boca = elegir(ESTILOS_ROSTRO.boca, azar)
        estilo.cejas = elegir(ESTILOS_ROSTRO.cejas, azar)

        cuerpo.radioCabeza = 5 + math.floor(azar() * 3)      -- 5..7
        cuerpo.anchoTorso = 9 + math.floor(azar() * 3)       -- 9..11
        cuerpo.grosorMiembro = 3 + math.floor(azar() * 2)    -- 3..4

        accesorios.maletin = azar() < 0.3
    end

    -- Las opciones explícitas tienen la última palabra sobre la variante.
    if opciones.paleta then
        for clave, valor in pairs(opciones.paleta) do
            paleta[clave] = colorTabla(valor)
        end
    end
    if opciones.accesorios then
        for clave, valor in pairs(opciones.accesorios) do
            accesorios[clave] = valor
        end
    end
    if opciones.rostro then
        for clave, valor in pairs(opciones.rostro) do
            estilo[clave] = valor
        end
    end

    self.semilla = opciones.semilla
    self.paleta = paleta
    -- Mangas ligeramente más oscuras que el torso, para que el movimiento
    -- de brazos se distinga del torso.
    paleta.camisaManga = atenuar(paleta.camisa, 0.82)
    self.cuerpo = cuerpo
    self.rostro = estilo
    self.accesorios = accesorios

    -- Alto real de la celda: respeta el pedido, pero garantiza que quepa la figura.
    self.altoFrame = math.max(cuerpo.altoTotal, esqueleto.altoRequerido(cuerpo))

    self.hoja = nil -- se hornea perezosamente en obtenerHoja()

    return self
end

----------------------------------------------------------------------
-- Dibujo de una vista en el lienzo actual
----------------------------------------------------------------------

local function dibujarRects(rects, color)
    love.graphics.setColor(color)
    for _, rect in ipairs(rects) do
        love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)
    end
end

local function dibujarRostro(forma, self)
    local rostro = forma.rostro
    if not rostro then return end

    local centroCabeza = forma.cabeza

    -- Cejas (color de pelo)
    if rostro.cejas then
        love.graphics.setColor(self.paleta.pelo)
        for _, ceja in ipairs(rostro.cejas) do
            love.graphics.rectangle("fill", ceja.x - 1, ceja.y, 2, 1)
        end
    end

    -- Ojos
    love.graphics.setColor(COLOR_OJOS)
    for _, ojo in ipairs(rostro.ojos) do
        if self.rostro.ojos == "abiertos" then
            love.graphics.rectangle("fill", ojo.x, ojo.y - 1, 1, 2)
        else
            love.graphics.rectangle("fill", ojo.x, ojo.y, 1, 1)
        end
    end

    -- Gafas: marco alrededor de los ojos
    if self.accesorios.gafas and #rostro.ojos > 1 then
        local x1, y1 = rostro.ojos[1].x, rostro.ojos[1].y
        local x2 = rostro.ojos[#rostro.ojos].x
        love.graphics.rectangle("line", x1 - 2, y1 - 2, (x2 - x1) + 4, 4)
    end

    -- Boca
    local boca = rostro.boca
    love.graphics.setColor(COLOR_OJOS)
    if boca.estilo == "sonrisa" then
        love.graphics.rectangle("fill", boca.x, boca.y, 1, 1)
        love.graphics.rectangle("fill", boca.x + boca.ancho - 1, boca.y, 1, 1)
        love.graphics.rectangle("fill", boca.x + 1, boca.y + 1, boca.ancho - 2, 1)
    elseif boca.estilo == "abierta" then
        love.graphics.rectangle("fill", boca.x, boca.y, boca.ancho, 2)
    else -- "linea"
        love.graphics.rectangle("fill", boca.x, boca.y, boca.ancho, 1)
    end
end

-- Dibuja la vista completa del personaje en la posición actual del lienzo.
function PersonajeProcedural:dibujarVista(direccion, frame)
    local forma = esqueleto.calcular(direccion, frame, self.cuerpo, self.accesorios, self.rostro)

    -- Piernas, zapatos, cadera, torso y brazos
    dibujarRects(forma.piernas, self.paleta.pantalon)
    dibujarRects(forma.zapatos, self.paleta.zapatos)
    dibujarRects({ forma.cadera }, self.paleta.pantalon)
    dibujarRects({ forma.torso }, self.paleta.camisa)
    dibujarRects(forma.brazos, self.paleta.camisaManga)

    -- Manos (piel al final de cada brazo)
    love.graphics.setColor(self.paleta.piel)
    for _, brazo in ipairs(forma.brazos) do
        love.graphics.rectangle("fill", brazo.x, brazo.y + brazo.h - 2, brazo.w, 2)
    end

    -- Maletín
    if forma.maletin then
        dibujarRects({ forma.maletin }, COLOR_MALETIN)
        love.graphics.setColor(COLOR_MALETIN)
        love.graphics.rectangle("fill", forma.maletin.x + 1, forma.maletin.y, forma.maletin.w - 2, 1)
    end

    -- Cabeza: piel de frente, pelo de espalda
    local cabeza = forma.cabeza
    if forma.mostrarRostro then
        love.graphics.setColor(self.paleta.piel)
        love.graphics.circle("fill", cabeza.x, cabeza.y, cabeza.r)
        -- Pelo: mitad superior de la cabeza
        love.graphics.setColor(self.paleta.pelo)
        love.graphics.arc("fill", cabeza.x, cabeza.y, cabeza.r + 0.5, math.pi, 2 * math.pi)
        dibujarRostro(forma, self)
    else
        love.graphics.setColor(self.paleta.pelo)
        love.graphics.circle("fill", cabeza.x, cabeza.y, cabeza.r)
    end
end

----------------------------------------------------------------------
-- Horneado a sprite sheet
----------------------------------------------------------------------

-- Genera (una vez) el sprite sheet 4x4 y lo devuelve en el formato que
-- entiende src/entities/character.lua.
function PersonajeProcedural:obtenerHoja()
    if self.hoja then
        return self.hoja
    end

    local anchoFrame = self.cuerpo.anchoFrame
    local altoFrame = self.altoFrame

    local lienzo = love.graphics.newCanvas(anchoFrame * 4, altoFrame * 4)
    lienzo:setFilter(FILTRO_PIXELES, FILTRO_PIXELES)

    lienzo:renderTo(function()
        love.graphics.clear(0, 0, 0, 0)
        for fila, direccion in ipairs(esqueleto.DIRECCIONES) do
            for frame = 1, 4 do
                love.graphics.push()
                love.graphics.translate((frame - 1) * anchoFrame, (fila - 1) * altoFrame)
                self:dibujarVista(direccion, frame)
                love.graphics.pop()
            end
        end
    end)

    self.hoja = {
        imagen = lienzo,
        anchoFrame = anchoFrame,
        altoFrame = altoFrame,
        filas = 4,
        -- Orden de filas, para depuración y pruebas:
        direcciones = {
            [1] = "abajo",
            [2] = "derecha",
            [3] = "arriba",
            [4] = "izquierda",
        },
    }

    return self.hoja
end

return PersonajeProcedural
