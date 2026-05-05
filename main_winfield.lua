function love.load()

    wf = require "libraries/windfield"
    world = wf.newWorld(0,0)

    camera = require 'libraries/camera'
    cam = camera()

    anim8 = require 'libraries/anim8'

    sti = require 'libraries/sti'

    gameMap = sti('maps/testMap.lua')

    player = {}
    --Punto inicial:
    player.x = 400
    player.y = 400

    player.collider = world:newRectangleCollider(player.x, player.y, 80, 40)
    player.collider:setFixedRotation(true)
    

    player.speed = 200
    player.speed_ini = 200
    player.spriteSheet = love.graphics.newImage('sprites/bingo_row_1.png')
    player.grid = anim8.newGrid(490,368,1962,368,0,0,2)
    player.frames = player.grid('1-4', 1)
    player.direction=1
    

    player.animations = {}

    player.animations.right = anim8.newAnimation(player.frames, 0.1) 


    backgroud = love.graphics.newImage('sprites/background.png')

    walls = {}
    if gameMap.layers["Walls"] then
        for i, obj in ipairs(gameMap.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x,obj.y,obj.width,obj.height)
            wall:setType('static')
            table.insert(walls, wall)
        end
    end
end

function love.update(dt)

    --si la direccion es contraria a la flecha, actualiza la direccion:

    if love.keyboard.isDown("right") and player.direction == -1 then
        player.direction = 1
    end
    if love.keyboard.isDown("left") and player.direction == 1 then
        player.direction = -1
    end

    -- acelerar movimiento al apretar espacion:

    if love.keyboard.isDown("space") then
        player.speed = player.speed_ini * 2
    else
        player.speed = player.speed_ini
    end


    --Logica de navegacion
    local isMoving = false 

    local vx = 0
    local vy = 0
    
    if love.keyboard.isDown("right") then
        vx = player.speed 
        isMoving = true
    end
    if love.keyboard.isDown("left") then
        vx = player.speed * -1
        isMoving = true
    end

    if love.keyboard.isDown("up") then
        vy = player.speed * -1
        isMoving = true
    end

    if love.keyboard.isDown("down") then
        vy = player.speed
        isMoving = true
    end

    player.collider:setLinearVelocity(vx, vy)

    
    if isMoving then
        player.animations.right:update(dt)
    end

    -- Actualizacion de la posición de la cámara:
    cam:lookAt(player.x, player.y)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if cam.x < w/2 then
        cam.x = w/2
    end
    if cam.y < h/2 then
        cam.y = h/2
    end

    local mapWidth = gameMap.tilewidth * gameMap.width
    local mapHeight = gameMap.tileheight * gameMap.height   

    if cam.x > mapWidth - w/2 then
        cam.x = mapWidth - w/2
    end
    if cam.y > mapHeight - h/2 then
        cam.y = mapHeight - h/2
    end 

    -- Colisiones:
    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()





end




function love.draw()

    -- love.graphics.circle("fill", player.x, player.y, 100)
    -- love.graphics.draw(backgroud, 0, 0)
    -- love.graphics.draw(player.sprite, player.x, player.y) 
    
    cam:attach()

        -- gameMap:draw() -- No se pueden dibujar todas las capas juntas de Tiles cuando se usa cámara.

        gameMap:drawLayer(gameMap.layers["Base"])
        gameMap:drawLayer(gameMap.layers["Arboles"])
        
        player.animations.right:draw(
                player.spriteSheet,
                player.x,
                player.y,
                nil,
                0.2 * player.direction,
                0.2,
                490 / 2,  -- ox (centro en X)
                3*368 / 4   -- oy (centro en Y)
            )

            world:draw() -- Ver colisiones

    cam:detach()
    


    local width, height = love.graphics.getDimensions()
    love.graphics.print("Resolucion: " .. width .. " x " .. height, 10, 10)
    love.graphics.print("MAP version: ".. gameMap.version, 10, 30)
    love.graphics.print("MAP version: ".. gameMap.tilesets[1].name, 10, 50)

    

end
