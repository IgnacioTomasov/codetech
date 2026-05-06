local inputControl = {}

function inputControl.moveIntention(dt, character)
    --Actualiza los atributos de "intención de cambios de posición" de un caracter. 
    local dx, dy = 0, 0
    local speed = character.speed


    if love.keyboard.isDown("space") then
        speed = speed * 2
    end

    if love.keyboard.isDown("right") then 
    character.direction=1
    dx = speed * dt 
    end
    if love.keyboard.isDown("left") then
    character.direction=-1
    dx = -speed * dt
    end

    if love.keyboard.isDown("down") then
    dy = speed * dt
    end
    if love.keyboard.isDown("up") then
    dy = -speed * dt
    end

    return dx, dy

end

return inputControl
