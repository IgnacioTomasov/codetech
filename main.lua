local sti = require("libraries/sti")
local bump = require("libraries/bump")
local Character = require("character")

function love.load()
  -- mundo de colisiones
  world = bump.newWorld(64)
  player = Character.new()
  -- cargar mapa
  map = sti('maps/testMap.lua')

  -- Usar bump para crear jugador
  world:add(player, player.x, player.y, player.w, player.h)

  -- cargar colisiones desde Tiled
  solveCollision("Arboles", "solid")
end

function love.update(dt)

  local isMoving = false 
  local dx, dy = 0, 0

  if love.keyboard.isDown("right") then 
    player.direction=1
    dx = player.speed * dt 
    isMoving = true
  end
  if love.keyboard.isDown("left") then
    player.direction=-1
    dx = -player.speed * dt
    isMoving = true
  end

  if love.keyboard.isDown("down") then
    dy = player.speed * dt
    isMoving = true
  end
  if love.keyboard.isDown("up") then
    dy = -player.speed * dt
    isMoving = true
  end

  local goalX = player.x + dx
  local goalY = player.y + dy

  --Intenta mover el objeto desde su posición actual → hacia (goalX, goalY)
  local actualX, actualY, cols, len = world:move(player, goalX, goalY)

  player.x = actualX
  player.y = actualY

  if isMoving then
      player.animations.caminar:update(dt)
  end

end

function love.draw()
  map:draw()

  -- dibujar jugador
  love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)

  local fw = player.grid.frameWidth
  local fh = player.grid.frameHeight
  local alinea =  (math.abs(player.direction) - player.direction) / 2

  player.animations.caminar:draw(
                player.spriteSheet,
                player.x,
                player.y,
                nil,
                0.2 * player.direction,
                0.2,
                (fw-100) * alinea,   -- cuando direction es negativa, mutiplica por -2 el ofset del ancho total
                fh / 2   -- oy (centro en Y)
            )


  drawCollisions(true)
end

--HELPERS:

function getLayerByName(map, name)
  for _, layer in ipairs(map.layers) do
    if layer.name == name then
      return layer
    end
  end
  return nil
end

function solveCollision(layerName, solidName)

  local wallCount = 0
  local layer = getLayerByName(map, "Arboles")
  local width = layer.width
  local tileW = map.tilewidth
  local tileH = map.tileheight

  -- print("Layer detected name:",layer.name)

  for y = 1, layer.height do
    for x = 1, layer.width do
      local tile = layer.data[y][x]

      -- considerar huecos (nil) explícitamente
      if tile and tile.properties and tile.properties[solidName] then
        local collider = { type = "wall" }

        world:add(
          collider,
          (x - 1) * tileW,
          (y - 1) * tileH,
          tileW,
          tileH
        )

        local wallCount = wallCount + 1
      end
    end
  end
  -- print("walls:", wallCount)
end

function drawCollisions(enabled)
  if not enabled then return end

  love.graphics.setColor(1, 0, 0, 0.4)
  for item in pairs(world.rects) do
    if item ~= player then
      local x, y, w, h = world:getRect(item)
      love.graphics.rectangle("fill", x, y, w, h)
    end
  end
  love.graphics.setColor(1, 1, 1, 1)
end