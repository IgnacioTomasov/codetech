local inputControl = {}

local interactions = require("src.interactions")

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

function inputControl.randomMoveIntention(dt, character, time2change)
    -- genera movimientos al azar. Solo se mueve cuado cualquier tecla está presionada

    local dx, dy = 0, 0


    local timeSinceChangeDirection = love.timer.getTime() - character.timeChangeDirection


    if timeSinceChangeDirection > time2change then
        
        local randValueX = love.math.random(0, 1) == 0 and -1 or 1
        local randValuey = love.math.random(0, 1) == 0 and -1 or 1

        dx = randValueX * character.speed * dt
        dy = randValuey * character.speed * dt
    
    else 
        dx = character.last_dx
        dy = character.last_dy

    end

    if dx>0 then
        character.direction=1
    else
        character.direction=-1
    end


    return dx, dy
end


function inputControl.tailReaction(player1, player2, threshold)
    
    local isClose = interactions.isClose(player1, player2, threshold)

    if isClose and love.keyboard.isDown("space") then
        -- print("Están cerca, mover colita")
        player1.isInteracting = true
        player2.isInteracting = true
    else
        player1.isInteracting = false
        player2.isInteracting = false
        -- print("Me ejecuté")
    
    end
end


return inputControl
