-- Runner mínimo de pruebas: lua tests/run.lua
-- Cada archivo tests/*_test.lua retorna una tabla { nombre_prueba = función }.

package.path = "./?.lua;./?/init.lua;" .. package.path

-- Helpers globales disponibles para las pruebas.
function verdad(cond, msg)
    if not cond then
        error(msg or "se esperaba verdadero", 2)
    end
end

function falso(cond, msg)
    if cond then
        error(msg or "se esperaba falso", 2)
    end
end

function igual(actual, esperado, msg)
    if actual ~= esperado then
        error(
            (msg and msg .. ": " or "") ..
            string.format(
                "se esperaba %s pero se obtuvo %s",
                tostring(esperado),
                tostring(actual)
            ),
            2
        )
    end
end

local archivos = {}

local salida = io.popen("ls tests/*_test.lua 2>/dev/null")
for archivo in salida:lines() do
    table.insert(archivos, archivo)
end
salida:close()

if #archivos == 0 then
    print("No se encontraron pruebas en tests/")
    os.exit(1)
end

local total = 0
local fallos = 0

local function ejecutar(nombre, fn)
    total = total + 1

    local ok, err = pcall(fn)

    if ok then
        print("  [OK] " .. nombre)
    else
        fallos = fallos + 1
        print("  [FALLO] " .. nombre)
        print("          " .. tostring(err))
    end
end

for _, archivo in ipairs(archivos) do
    print(archivo)

    local modulo = assert(dofile(archivo))

    -- Orden determinista para poder comparar ejecuciones.
    local nombres = {}
    for nombre in pairs(modulo) do
        table.insert(nombres, nombre)
    end
    table.sort(nombres)

    for _, nombre in ipairs(nombres) do
        ejecutar(nombre, modulo[nombre])
    end
end

print(string.format("\n%d pruebas, %d fallos", total, fallos))
os.exit(fallos > 0 and 1 or 0)
