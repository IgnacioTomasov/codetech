local inputControl = {}

function inputControl.moveIntention(dt, character)
    --Actualiza los atributos de "intención de cambios de posición" de un caracter. 
    local dx, dy = 0, 0

    if love.keyboard.isDown("right") then 
    character.direction=1
    dx = character.speed * dt 
    end
    if love.keyboard.isDown("left") then
    character.direction=-1
    dx = -character.speed * dt
    end

    if love.keyboard.isDown("down") then
    dy = character.speed * dt
    end
    if love.keyboard.isDown("up") then
    dy = -character.speed * dt
    end

    return dx, dy

end

return inputControl
