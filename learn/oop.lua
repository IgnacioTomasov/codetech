Animal = {a = 1}

Amigos = {b = 2}


print("Animal:", Animal.a)
print("Amigos:", Amigos.b)
print("Animal atributo mal heredado:", Animal.b)

--Pero si hago:
Amigos.__index = Amigos
setmetatable(Animal, Amigos)

print("Animal atributo bien heredado:", Animal.b)

-- Se puede entender como, que index y metatable habilitan a "Animal" para que busque atributos en "Amigos"
