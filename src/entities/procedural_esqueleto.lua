-- Esqueleto del personaje procedural: lógica pura, sin LÖVE.
-- Dada una dirección, un frame de caminar y las proporciones del cuerpo,
-- devuelve las formas (círculos/rectángulos/puntos) que componen la vista.
-- Todo en coordenadas de la celda del frame (origen arriba-izquierda).

local esqueleto = {}

esqueleto.DIRECCIONES = {
    [1] = "abajo",
    [2] = "derecha",
    [3] = "arriba",
    [4] = "izquierda",
}

-- Patrón clásico de caminar en 4 frames: paso / apoyo / paso / apoyo.
local APERTURA = 2             -- apertura lateral de la pierna vista frontal
local REBOTE = { 0, -1, 0, -1 } -- elevación del cuerpo en los frames de apoyo
local ZANCADA = { -1, 0, 1, 0 } -- zancada de perfil: ±1 px, acotada al tronco
local ELEVACION = 2             -- recogida de la pierna que adelanta (px)
local ALTO_CADERA = 2           -- bloque de cadera que une torso y piernas

function esqueleto.cuerpoPorDefecto()
    return {
        anchoFrame = 32,     -- ancho de la celda del frame
        altoTotal = 48,      -- alto de la celda del frame
        radioCabeza = 6,
        anchoTorso = 10,
        altoTorso = 14,
        grosorMiembro = 3,   -- grosor de brazos y piernas
        largoPierna = 13,
        altoZapato = 3,
    }
end

-- Completa un cuerpo parcial con los valores por defecto.
function esqueleto.completarCuerpo(cuerpo)
    local base = esqueleto.cuerpoPorDefecto()
    for clave, valor in pairs(cuerpo or {}) do
        base[clave] = valor
    end
    return base
end

-- Alto mínimo necesario para que la figura quepa en la celda.
function esqueleto.altoRequerido(cuerpo)
    cuerpo = esqueleto.completarCuerpo(cuerpo)
    local margenSuperior = 2
    local cuello = 1
    local margenInferior = 2
    return margenSuperior
        + cuerpo.radioCabeza * 2
        + cuello
        + cuerpo.altoTorso
        + cuerpo.largoPierna
        + cuerpo.altoZapato
        + margenInferior
end

-- PRNG determinista (LCG de Lehmer) para variantes reproducibles sin LÖVE.
function esqueleto.crearAzar(semilla)
    local estado = (semilla or 1) % 2147483647
    if estado <= 0 then
        estado = estado + 2147483646
    end
    return function()
        estado = (estado * 16807) % 2147483647
        return estado / 2147483647
    end
end

-- Devuelve el frame acotado a 1..4.
function esqueleto.acotarFrame(frame)
    frame = math.floor(tonumber(frame) or 1)
    if frame < 1 then return 1 end
    if frame > 4 then return 4 end
    return frame
end

----------------------------------------------------------------------
-- Rostros (posiciones de rasgos dentro de la cabeza)
----------------------------------------------------------------------

local function rostroFrontal(cx, cy, radioCabeza, estilo)
    local ojos = {
        { x = cx - 2, y = cy },
        { x = cx + 2, y = cy },
    }
    local cejas = {
        { x = cx - 3, y = cy - 3 },
        { x = cx + 3, y = cy - 3 },
    }
    if estilo.cejas == "ningunas" then
        cejas = nil
    end
    return {
        ojos = ojos,
        cejas = cejas,
        boca = { x = cx - 2, y = cy + radioCabeza - 3, ancho = 4, estilo = estilo.boca },
    }
end

local function rostroPerfil(cx, cy, radioCabeza, estilo)
    -- Mirando a la derecha: un solo ojo y la boca en el borde derecho.
    return {
        ojos = { { x = cx + 3, y = cy } },
        cejas = (estilo.cejas == "ningunas") and nil or { { x = cx + 3, y = cy - 3 } },
        boca = { x = cx + 4, y = cy + radioCabeza - 3, ancho = 2, estilo = estilo.boca },
    }
end

----------------------------------------------------------------------
-- Vistas
----------------------------------------------------------------------

local function vistaFrontal(frame, cuerpo, accesorios, estilo)
    local anchoFrame = cuerpo.anchoFrame
    local cx = anchoFrame / 2
    local cy = cuerpo.radioCabeza + 2 + REBOTE[frame]

    local yTorso = cy + cuerpo.radioCabeza + 1
    local yPiernas = yTorso + cuerpo.altoTorso
    local anchoPierna = cuerpo.grosorMiembro + 1
    local brazoLargo = cuerpo.altoTorso - 2
    local xTorso = cx - cuerpo.anchoTorso / 2

    -- Marcha alternada: una pierna se abre lateralmente mientras la otra
    -- permanece quieta; en el frame de apoyo vuelven ambas a su sitio.
    local aperturaIzquierda = (frame == 1) and -APERTURA or 0
    local aperturaDerecha = (frame == 3) and APERTURA or 0

    -- Balanceo de brazos en contrafase: cuando una pierna se abre, la mano
    -- opuesta se desplaza 1 px hacia el cuerpo (y las manos siguen al brazo).
    local balanceoIzquierda = (frame == 3) and 1 or 0
    local balanceoDerecha = (frame == 1) and -1 or 0

    local forma = {
        mostrarRostro = true,
        cabeza = { x = cx, y = cy, r = cuerpo.radioCabeza },
        rostro = rostroFrontal(cx, cy, cuerpo.radioCabeza, estilo),
        torso = { x = xTorso, y = yTorso, w = cuerpo.anchoTorso, h = cuerpo.altoTorso },
        brazos = {
            { x = xTorso - cuerpo.grosorMiembro + balanceoIzquierda, y = yTorso + 1, w = cuerpo.grosorMiembro, h = brazoLargo },
            { x = xTorso + cuerpo.anchoTorso + balanceoDerecha,      y = yTorso + 1, w = cuerpo.grosorMiembro, h = brazoLargo },
        },
        cadera = { x = xTorso, y = yPiernas, w = cuerpo.anchoTorso, h = ALTO_CADERA },
        piernas = {
            { x = cx - anchoPierna + aperturaIzquierda, y = yPiernas, w = anchoPierna, h = cuerpo.largoPierna }, -- izquierda
            { x = cx + aperturaDerecha,                 y = yPiernas, w = anchoPierna, h = cuerpo.largoPierna }, -- derecha
        },
    }

    forma.zapatos = {}
    for indice, pierna in ipairs(forma.piernas) do
        forma.zapatos[indice] = {
            x = pierna.x - 1,
            y = pierna.y + pierna.h,
            w = anchoPierna + 2,
            h = cuerpo.altoZapato,
        }
    end

    if accesorios.maletin then
        local brazo = forma.brazos[2]
        forma.maletin = {
            x = brazo.x + brazo.w + 1,
            y = brazo.y + brazo.h - 6,
            w = 5,
            h = 6,
        }
    end

    return forma
end

local function vistaPerfil(frame, cuerpo, accesorios, estilo)
    -- Mirando a la derecha (la vista izquierda se obtiene reflejando).
    local anchoFrame = cuerpo.anchoFrame
    local cx = anchoFrame / 2
    local cy = cuerpo.radioCabeza + 2 + REBOTE[frame]

    local yTorso = cy + cuerpo.radioCabeza + 1
    local yPiernas = yTorso + cuerpo.altoTorso
    local brazoLargo = cuerpo.altoTorso - 2

    local anchoTorsoPerfil = math.max(cuerpo.anchoTorso - 2, 5)
    local xTorso = cx - anchoTorsoPerfil / 2

    -- Zancada en contrafase: la trasera y la delantera se mueven ±1 px en
    -- sentidos opuestos, siempre dentro del ancho del tronco.
    local paso = ZANCADA[frame]
    local anchoPierna = cuerpo.grosorMiembro
    local piernaTrasera = {
        x = cx - anchoPierna + paso,
        y = yPiernas,
        w = anchoPierna,
        h = cuerpo.largoPierna,
    }
    local piernaDelantera = {
        x = cx - paso,
        y = yPiernas,
        w = anchoPierna,
        h = cuerpo.largoPierna,
    }

    -- La pierna que adelanta se recoge (se acorta) para simular el paso.
    if frame == 1 then
        piernaDelantera.h = piernaDelantera.h - ELEVACION
    elseif frame == 3 then
        piernaTrasera.h = piernaTrasera.h - ELEVACION
    end

    local forma = {
        mostrarRostro = true,
        cabeza = { x = cx, y = cy, r = cuerpo.radioCabeza },
        rostro = rostroPerfil(cx, cy, cuerpo.radioCabeza, estilo),
        torso = { x = xTorso, y = yTorso, w = anchoTorsoPerfil, h = cuerpo.altoTorso },
        cadera = { x = xTorso, y = yPiernas, w = anchoTorsoPerfil, h = ALTO_CADERA },
        brazos = {
            -- Un solo brazo visible, en contrafase con la pierna delantera.
            { x = cx - 1 + paso, y = yTorso + 1, w = cuerpo.grosorMiembro, h = brazoLargo },
        },
        piernas = { piernaTrasera, piernaDelantera },
    }

    forma.zapatos = {}
    for indice, pierna in ipairs(forma.piernas) do
        -- Pie orientado en la dirección de la marcha: talón alineado con la
        -- parte trasera de la pierna y punta adelantada hacia el frente.
        forma.zapatos[indice] = {
            x = pierna.x,
            y = pierna.y + pierna.h,
            w = anchoPierna + 2,
            h = cuerpo.altoZapato,
        }
    end

    if accesorios.maletin then
        forma.maletin = {
            x = cx + cuerpo.radioCabeza,
            y = yTorso + cuerpo.altoTorso - 5,
            w = 6,
            h = 6,
        }
    end

    return forma
end

----------------------------------------------------------------------
-- Reflejo horizontal (para la vista izquierda)
----------------------------------------------------------------------

local function espejarRect(rect, anchoFrame)
    return { x = anchoFrame - rect.x - rect.w, y = rect.y, w = rect.w, h = rect.h }
end

local function espejarPunto(punto, anchoFrame)
    return { x = anchoFrame - punto.x, y = punto.y }
end

-- Refleja una forma completa respecto al eje vertical de la celda.
function esqueleto.espejarFormas(forma, anchoFrame)
    local copia = {
        mostrarRostro = forma.mostrarRostro,
        cabeza = espejarPunto(forma.cabeza, anchoFrame),
    }
    copia.cabeza.r = forma.cabeza.r

    if forma.rostro then
        local rostro = { ojos = {}, cejas = nil }
        for indice, ojo in ipairs(forma.rostro.ojos) do
            rostro.ojos[indice] = espejarPunto(ojo, anchoFrame)
        end
        if forma.rostro.cejas then
            rostro.cejas = {}
            for indice, ceja in ipairs(forma.rostro.cejas) do
                rostro.cejas[indice] = espejarPunto(ceja, anchoFrame)
            end
        end
        local boca = espejarPunto({ x = forma.rostro.boca.x, y = forma.rostro.boca.y }, anchoFrame)
        boca.x = boca.x - forma.rostro.boca.ancho
        boca.ancho = forma.rostro.boca.ancho
        boca.estilo = forma.rostro.boca.estilo
        rostro.boca = boca
        copia.rostro = rostro
    end

    copia.torso = espejarRect(forma.torso, anchoFrame)
    copia.cadera = espejarRect(forma.cadera, anchoFrame)

    copia.brazos = {}
    for indice, brazo in ipairs(forma.brazos) do
        copia.brazos[indice] = espejarRect(brazo, anchoFrame)
    end

    copia.piernas = {}
    for indice, pierna in ipairs(forma.piernas) do
        copia.piernas[indice] = espejarRect(pierna, anchoFrame)
    end

    copia.zapatos = {}
    for indice, zapato in ipairs(forma.zapatos) do
        copia.zapatos[indice] = espejarRect(zapato, anchoFrame)
    end

    if forma.maletin then
        copia.maletin = espejarRect(forma.maletin, anchoFrame)
    end

    return copia
end

----------------------------------------------------------------------
-- API principal
----------------------------------------------------------------------

-- direccion: "abajo" | "arriba" | "derecha" | "izquierda"
-- frame: 1..4 (frames de caminar)
-- cuerpo: proporciones (se completan con valores por defecto)
-- accesorios: { maletin = bool }
-- estilo: { ojos = "puntos"|"abiertos", boca = "linea"|"sonrisa"|"abierta", cejas = "normales"|"ningunas" }
function esqueleto.calcular(direccion, frame, cuerpo, accesorios, estilo)
    cuerpo = esqueleto.completarCuerpo(cuerpo)
    accesorios = accesorios or {}
    estilo = estilo or {}
    frame = esqueleto.acotarFrame(frame)

    if estilo.ojos == nil then estilo.ojos = "puntos" end
    if estilo.boca == nil then estilo.boca = "linea" end
    if estilo.cejas == nil then estilo.cejas = "normales" end

    local forma

    if direccion == "abajo" then
        forma = vistaFrontal(frame, cuerpo, accesorios, estilo)
    elseif direccion == "arriba" then
        -- Espalda: misma estructura frontal, sin rostro (la cabeza se pinta de pelo).
        forma = vistaFrontal(frame, cuerpo, accesorios, estilo)
        forma.mostrarRostro = false
        forma.rostro = nil
    elseif direccion == "derecha" then
        forma = vistaPerfil(frame, cuerpo, accesorios, estilo)
    elseif direccion == "izquierda" then
        forma = esqueleto.espejarFormas(vistaPerfil(frame, cuerpo, accesorios, estilo), cuerpo.anchoFrame)
    else
        error("dirección desconocida: " .. tostring(direccion))
    end

    return forma
end

return esqueleto
