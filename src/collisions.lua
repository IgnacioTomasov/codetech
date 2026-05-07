local collisions = {}

function getLayerByName(map, name)
  for _, layer in ipairs(map.layers) do
    if layer.name == name then
      return layer
    end
  end
  return nil
end

function collisions.solve(layerName, solidName, world, map)

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

function collisions.draw(enabled, world, player)
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


return collisions