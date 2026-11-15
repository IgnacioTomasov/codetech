-- Pruebas de src/entities/procedural_esqueleto.lua (lógica pura, sin LÖVE)
local esqueleto = require("src.entities.procedural_esqueleto")

return {

    ["completarCuerpo rellena los valores por defecto"] = function()
        local cuerpo = esqueleto.completarCuerpo({ radioCabeza = 5 })
        igual(cuerpo.radioCabeza, 5)
        igual(cuerpo.anchoFrame, 32)
        igual(cuerpo.altoTotal, 48)
        igual(cuerpo.largoPierna, 13)
    end,

    ["acotarFrame limita el frame a 1..4"] = function()
        igual(esqueleto.acotarFrame(0), 1)
        igual(esqueleto.acotarFrame(2), 2)
        igual(esqueleto.acotarFrame(7), 4)
    end,

    ["calcular soporta las 4 direcciones"] = function()
        for _, direccion in ipairs(esqueleto.DIRECCIONES) do
            local forma = esqueleto.calcular(direccion, 1)
            verdad(forma.cabeza ~= nil, "falta cabeza en " .. direccion)
            verdad(forma.torso ~= nil, "falta torso en " .. direccion)
            verdad(#forma.piernas == 2, "se esperaban 2 piernas en " .. direccion)
        end
    end,

    ["calcular rechaza direcciones desconocidas"] = function()
        local ok, err = pcall(function()
            esqueleto.calcular("diagonal", 1)
        end)
        falso(ok)
        verdad(tostring(err):find("dirección desconocida") ~= nil)
    end,

    ["la vista frontal muestra rostro y la de espalda no"] = function()
        verdad(esqueleto.calcular("abajo", 1).mostrarRostro)
        verdad(esqueleto.calcular("abajo", 1).rostro ~= nil)
        falso(esqueleto.calcular("arriba", 1).mostrarRostro)
        igual(esqueleto.calcular("arriba", 1).rostro, nil)
    end,

    ["el perfil tiene un solo ojo y el frontal dos"] = function()
        igual(#esqueleto.calcular("abajo", 1).rostro.ojos, 2)
        igual(#esqueleto.calcular("derecha", 1).rostro.ojos, 1)
    end,

    ["izquierda es derecha reflejada"] = function()
        for frame = 1, 4 do
            local derecha = esqueleto.calcular("derecha", frame)
            local izquierda = esqueleto.calcular("izquierda", frame)
            local espejo = esqueleto.espejarFormas(derecha, 32)

            igual(izquierda.cabeza.x, espejo.cabeza.x, "cabeza frame " .. frame)
            igual(izquierda.torso.x, espejo.torso.x, "torso frame " .. frame)
            igual(izquierda.cadera.x, espejo.cadera.x, "cadera frame " .. frame)
            igual(izquierda.piernas[1].x, espejo.piernas[1].x, "pierna frame " .. frame)

            -- El reflejo conserva las alturas
            igual(izquierda.cabeza.y, derecha.cabeza.y, "altura cabeza frame " .. frame)
            igual(izquierda.piernas[1].y, derecha.piernas[1].y, "altura pierna frame " .. frame)
        end
    end,

    ["las formas caben dentro de la celda del frame"] = function()
        local cuerpo = esqueleto.completarCuerpo()
        for _, direccion in ipairs(esqueleto.DIRECCIONES) do
            for frame = 1, 4 do
                local forma = esqueleto.calcular(direccion, frame, cuerpo)

                local function verificarRect(rect, nombre)
                    verdad(rect.x >= 0, nombre .. " se sale por la izquierda en " .. direccion)
                    verdad(rect.x + rect.w <= cuerpo.anchoFrame, nombre .. " se sale por la derecha en " .. direccion)
                    verdad(rect.y >= 0, nombre .. " se sale por arriba en " .. direccion)
                    verdad(rect.y + rect.h <= cuerpo.altoTotal, nombre .. " se sale por abajo en " .. direccion)
                end

                verificarRect(forma.torso, "torso")
                verificarRect(forma.cadera, "cadera")
                for _, pierna in ipairs(forma.piernas) do verificarRect(pierna, "pierna") end
                for _, zapato in ipairs(forma.zapatos) do verificarRect(zapato, "zapato") end

                local cabeza = forma.cabeza
                verdad(cabeza.x - cabeza.r >= 0, "cabeza se sale por la izquierda en " .. direccion)
                verdad(cabeza.x + cabeza.r <= cuerpo.anchoFrame, "cabeza se sale por la derecha en " .. direccion)
                verdad(cabeza.y - cabeza.r >= 0, "cabeza se sale por arriba en " .. direccion)
            end
        end
    end,

    ["la zancada cambia entre frames (marcha en el sitio)"] = function()
        local p1 = esqueleto.calcular("derecha", 1).piernas
        local p2 = esqueleto.calcular("derecha", 2).piernas
        falso(p1[1].x == p2[1].x and p1[2].x == p2[2].x,
            "las piernas no cambian de posición entre frames")
    end,

    ["en perfil las piernas permanecen dentro del ancho del torso"] = function()
        for frame = 1, 4 do
            local forma = esqueleto.calcular("derecha", frame)
            local torso = forma.torso
            for indice, pierna in ipairs(forma.piernas) do
                verdad(pierna.x >= torso.x,
                    string.format("frame %d: la pierna %d excede el torso por la izquierda", frame, indice))
                verdad(pierna.x + pierna.w <= torso.x + torso.w,
                    string.format("frame %d: la pierna %d excede el torso por la derecha", frame, indice))
            end
        end
    end,

    ["en perfil la pierna que adelanta se recoge"] = function()
        local largo = esqueleto.cuerpoPorDefecto().largoPierna

        -- Frame 1: adelanta la delantera (índice 2)
        local forma1 = esqueleto.calcular("derecha", 1)
        igual(forma1.piernas[1].h, largo, "la trasera no debe recogerse en el frame 1")
        igual(forma1.piernas[2].h, largo - 2, "la delantera debe recogerse en el frame 1")

        -- Frame 2: apoyo, ambas completas
        local forma2 = esqueleto.calcular("derecha", 2)
        igual(forma2.piernas[1].h, largo, "la trasera no debe recogerse en el frame 2")
        igual(forma2.piernas[2].h, largo, "la delantera no debe recogerse en el frame 2")

        -- Frame 3: adelanta la trasera (índice 1)
        local forma3 = esqueleto.calcular("derecha", 3)
        igual(forma3.piernas[1].h, largo - 2, "la trasera debe recogerse en el frame 3")
        igual(forma3.piernas[2].h, largo, "la delantera no debe recogerse en el frame 3")
    end,

    ["en perfil las piernas van en contrafase"] = function()
        local forma1 = esqueleto.calcular("derecha", 1)
        local forma3 = esqueleto.calcular("derecha", 3)

        local deltaTrasera = forma3.piernas[1].x - forma1.piernas[1].x
        local deltaDelantera = forma3.piernas[2].x - forma1.piernas[2].x

        falso(deltaTrasera == 0, "la trasera no se mueve")
        falso(deltaDelantera == 0, "la delantera no se mueve")
        verdad((deltaTrasera > 0 and deltaDelantera < 0) or (deltaTrasera < 0 and deltaDelantera > 0),
            "las piernas no se mueven en sentidos opuestos")
    end,

    ["los zapatos siguen a cada pierna"] = function()
        for frame = 1, 4 do
            local forma = esqueleto.calcular("derecha", frame)
            for indice, pierna in ipairs(forma.piernas) do
                local zapato = forma.zapatos[indice]
                igual(zapato.y, pierna.y + pierna.h,
                    string.format("frame %d: el zapato %d no apoya en su pierna", frame, indice))
            end
        end
    end,

    ["en perfil el pie apunta hacia adelante (talón detrás)"] = function()
        for frame = 1, 4 do
            local forma = esqueleto.calcular("derecha", frame)
            for indice, pierna in ipairs(forma.piernas) do
                local zapato = forma.zapatos[indice]
                igual(zapato.x, pierna.x,
                    string.format("frame %d: el talón del zapato %d no está en la parte trasera de la pierna", frame, indice))
                verdad(zapato.x + zapato.w > pierna.x + pierna.w,
                    string.format("frame %d: el zapato %d no avanza hacia el frente", frame, indice))
            end
        end
    end,

    ["en frontal las manos se mueven en contrafase con las piernas"] = function()
        local baseIzquierda = 11 - 3 -- xTorso - grosorMiembro
        local baseDerecha = 11 + 10  -- xTorso + anchoTorso

        -- Frame 1: se abre la pierna izquierda, se mueve la mano derecha
        local forma1 = esqueleto.calcular("abajo", 1)
        igual(forma1.brazos[1].x, baseIzquierda, "la mano izquierda debe estar quieta en el frame 1")
        igual(forma1.brazos[2].x, baseDerecha - 1, "la mano derecha debe moverse en el frame 1")

        -- Frame 2: apoyo, ambas quietas
        local forma2 = esqueleto.calcular("abajo", 2)
        igual(forma2.brazos[1].x, baseIzquierda, "la mano izquierda debe estar quieta en el frame 2")
        igual(forma2.brazos[2].x, baseDerecha, "la mano derecha debe estar quieta en el frame 2")

        -- Frame 3: se abre la pierna derecha, se mueve la mano izquierda
        local forma3 = esqueleto.calcular("abajo", 3)
        igual(forma3.brazos[1].x, baseIzquierda + 1, "la mano izquierda debe moverse en el frame 3")
        igual(forma3.brazos[2].x, baseDerecha, "la mano derecha debe estar quieta en el frame 3")

        -- Frame 4: apoyo, ambas quietas
        local forma4 = esqueleto.calcular("abajo", 4)
        igual(forma4.brazos[1].x, baseIzquierda, "la mano izquierda debe estar quieta en el frame 4")
        igual(forma4.brazos[2].x, baseDerecha, "la mano derecha debe estar quieta en el frame 4")
    end,

    ["todas las vistas incluyen el bloque de cadera"] = function()
        for _, direccion in ipairs(esqueleto.DIRECCIONES) do
            local forma = esqueleto.calcular(direccion, 2)
            verdad(forma.cadera ~= nil, "falta la cadera en " .. direccion)
            verdad(forma.cadera.h > 0, "cadera sin alto en " .. direccion)
            -- La cadera cubre el ancho del torso (une torso y piernas)
            igual(forma.cadera.x, forma.torso.x, "cadera desalineada con el torso en " .. direccion)
        end
    end,

    ["en frontal las piernas alternan: una se abre y la otra queda quieta"] = function()
        local reposoIzquierda = 16 - 4 -- cx - anchoPierna
        local reposoDerecha = 16       -- cx

        local forma1 = esqueleto.calcular("abajo", 1)
        igual(forma1.piernas[1].x, reposoIzquierda - 2, "la izquierda debe abrirse en el frame 1")
        igual(forma1.piernas[2].x, reposoDerecha, "la derecha debe quedarse quieta en el frame 1")

        local forma2 = esqueleto.calcular("abajo", 2)
        igual(forma2.piernas[1].x, reposoIzquierda, "la izquierda debe volver en el frame 2")
        igual(forma2.piernas[2].x, reposoDerecha, "la derecha debe estar quieta en el frame 2")

        local forma3 = esqueleto.calcular("abajo", 3)
        igual(forma3.piernas[1].x, reposoIzquierda, "la izquierda debe quedarse quieta en el frame 3")
        igual(forma3.piernas[2].x, reposoDerecha + 2, "la derecha debe abrirse en el frame 3")

        local forma4 = esqueleto.calcular("abajo", 4)
        igual(forma4.piernas[1].x, reposoIzquierda, "la izquierda debe volver en el frame 4")
        igual(forma4.piernas[2].x, reposoDerecha, "la derecha debe estar quieta en el frame 4")
    end,

    ["crearAzar es determinista con la misma semilla"] = function()
        local azar1 = esqueleto.crearAzar(42)
        local azar2 = esqueleto.crearAzar(42)
        for _ = 1, 10 do
            igual(azar1(), azar2())
        end

        local azar3 = esqueleto.crearAzar(43)
        falso(azar3() == esqueleto.crearAzar(42)())
    end,

    ["crearAzar devuelve valores entre 0 y 1"] = function()
        local azar = esqueleto.crearAzar(7)
        for _ = 1, 100 do
            local valor = azar()
            verdad(valor >= 0 and valor < 1, "valor fuera de rango: " .. tostring(valor))
        end
    end,

    ["altoRequerido cabe en el alto por defecto"] = function()
        verdad(esqueleto.altoRequerido(nil) <= 48,
            "el cuerpo por defecto no cabe en la celda de 48px")
    end,

}
