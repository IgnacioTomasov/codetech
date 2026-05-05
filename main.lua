local sti = require("libraries/sti")
local bump = require("libraries/bump")

function love.load()
  -- mundo de colisiones
  world = bump.newWorld(64)

  -- cargar mapa
  map = sti('maps/testMap.lua')

  -- jugador
  player = {
    x = 100,
    y = 100,
    w = 32,
    h = 32,
    speed = 200
  }

  world:add(player, player.x, player.y, player.w, player.h)

  -- cargar colisiones desde Tiled
  solveCollision("Arboles", "solid")
end

function love.update(dt)
  local dx, dy = 0, 0

  if love.keyboard.isDown("right") then dx = player.speed * dt end
  if love.keyboard.isDown("left") then dx = -player.speed * dt end
  if love.keyboard.isDown("down") then dy = player.speed * dt end
  if love.keyboard.isDown("up") then dy = -player.speed * dt end

  local goalX = player.x + dx
  local goalY = player.y + dy

  --Intenta mover el objeto desde su posición actual → hacia (goalX, goalY)
  local actualX, actualY, cols, len = world:move(player, goalX, goalY)

  player.x = actualX
  player.y = actualY
end

function love.draw()
  map:draw()

  -- dibujar jugador
  love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)

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