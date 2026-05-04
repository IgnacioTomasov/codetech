-- archivo: hola.lua
print("Hola mundo")
-- ===============================
-- LUA CHEATSHEET (BÁSICO / PRÁCTICO)
-- ===============================

-- ========= VARIABLES =========
local nombre = "Ignacio"
local edad = 30
local activo = true
local nada = nil

print("Nombre:", nombre)

-- ========= TIPOS =========
print(type(nombre)) -- string
print(type(edad))   -- number
print(type(activo)) -- boolean
print(type(nada))   -- nil

-- ========= OPERADORES =========
local a = 10
local b = 3

print(a + b)  -- suma
print(a - b)  -- resta
print(a * b)  -- multiplicación
print(a / b)  -- división
print(a % b)  -- módulo
print(a ^ b)  -- potencia

-- comparaciones
print(a == b)
print(a ~= b)
print(a > b)
print(a < b)

-- ========= STRINGS =========
local texto = "Hola"
local otro = "Mundo"

print(texto .. " " .. otro) -- concatenación
print(#texto) -- largo

-- ========= CONDICIONALES =========
if edad > 18 then
  print("Adulto")
elseif edad == 18 then
  print("Justo 18")
else
  print("Menor de edad")
end

-- ========= LOOPS =========

-- while
local i = 1
while i <= 3 do
  print("while:", i)
  i = i + 1
end

-- for numérico
for i = 1, 5 do
  print("for:", i)
end

-- ========= TABLES =========
local lista = {10, 20, 30}
print(lista[1]) -- Lua parte en 1

local persona = {
  nombre = "Ignacio",
  edad = 30
}

print(persona.nombre)

-- recorrer tabla
for i, v in ipairs(lista) do
  print(i, v)
end

for k, v in pairs(persona) do
  print(k, v)
end

-- ========= FUNCIONES =========
function saludar(nombre)
  return "Hola " .. nombre
end


function usaVariables(a,b)
    c_local = 10
    local d_local = 20
    return a+b+c_local+d_local
end


print(usaVariables(1,2))
print(c_local) --¿Se imprimime? -> sí
print(d_local) --¿Se imprimime? -> no entrega nil

-- print(saludar("Ignacio"))

-- función anónima
local suma = function(x, y)
  return x + y
end

-- print(suma(2, 3))

-- ========= OOP BÁSICO =========
Persona = {}
Persona.__index = Persona

function Persona:new(nombre)
  local obj = { nombre = nombre }
  setmetatable(obj, self)
  return obj
end

function Persona:saludar()
  print("Hola, soy " .. self.nombre)
end

local p = Persona:new("Ignacio")
p:saludar()

-- ========= CONTROL =========
for i = 1, 5 do
  if i == 3 then
    break
  end
--   print("break en:", i)
end

-- ========= NIL Y DEFAULT =========
local valor = nil
local resultado = valor or "default"
-- print(resultado)

-- ========= REQUIRE (módulos) =========
-- archivo: modulo.lua
-- return { hola = function() print("hola") end }

-- local mod = require("modulo")
-- mod.hola()

-- ========= DEBUG RÁPIDO =========
-- print("Debug:", nombre, edad)

-- ===============================
-- FIN CHEATSHEET
-- ===============================