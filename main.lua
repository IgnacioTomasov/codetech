local sti = require("libraries/sti")
local map = sti('maps/testMap.lua')

local bump = require("libraries/bump")
local world = bump.newWorld(64)

local character = require("src.character")
local player = character.new()

local inputControl = require("src.input")


local camera = require 'libraries/camera'
local cam = camera()
local cameraControl = require("src.camera")


-- nota, las funciones inferiores pueden ver las variables locales creadas. No así las superiores.

function love.load()

  world:add(player, player.x, player.y, player.w, player.h)

  -- cargar colisiones desde Tiled
  solveCollision("Arboles", "solid")
end

function love.update(dt)

  local dx, dy = inputControl.moveIntention(dt, player)

  player:move(dx, dy, world)
  cameraControl.limitsCorrection(cam, map, player.x, player.y)
  player:update(dt)

  

end

function love.draw()

  cam:attach()
    map:drawLayer(map.layers["Base"])
    map:drawLayer(map.layers["Arboles"])
    player:draw(false)
    drawCollisions(false)
  cam:detach()
  
  
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