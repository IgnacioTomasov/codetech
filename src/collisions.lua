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
  local layer = getLayerByName(map, layerName)
  local tileW = map.tilewidth
  local tileH = map.tileheight

  -- print("Layer detected name:",layer.name)

  for y = 1, layer.height do
    for x = 1, layer.width do
      local tile = layer.data[y][x]

      -- considerar huecos (nil) explícitamente
      if tile and tile.properties and tile.properties[solidName] then
        local collider = { type = "wall" }

        local x_coord_corr = 0
        local x_with_corr = 0
        local widthCollider = tileW -- Solo definimos ancho, ya que solo hay paredes con fragmentos de tiles solidos.

        --considerar corrección para paredes que solo tienen un lado solido:
        if tile.properties["r_wall_solid_px"] then
          x_coord_corr = tile.properties["r_wall_solid_px"]
          x_with_corr = tile.properties["r_wall_solid_px"]
          widthCollider = tileW - x_with_corr

        elseif tile.properties["l_wall_solid_px"] then
          x_coord_corr = 0
          widthCollider = tile.properties["l_wall_solid_px"]
        end

        local x_cood = (x - 1) * tileW + x_coord_corr
        local y_cood = (y - 1) * tileH


        world:add(
          collider,
          x_cood,
          y_cood,
          widthCollider,
          tileH 
        )

        wallCount = wallCount + 1
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