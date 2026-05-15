local camaraControl = {}

function camaraControl.limitsCorrection(cam,map,x,y,zoom)

     -- Actualizacion de la posición de la cámara:
    cam:lookAt(x, y)

    -- tamaño visible del mundo considerando zoom
    local w = love.graphics.getWidth() / zoom
    local h = love.graphics.getHeight() / zoom

    if cam.x < w/2 then
        cam.x = w/2
    end
    if cam.y < h/2 then
        cam.y = h/2
    end

    local mapWidth = map.tilewidth * map.width
    local mapHeight = map.tileheight * map.height   

    -- print("tamaño del mapa:", mapWidth,mapHeight)

    if cam.x > mapWidth - w/2 then
        cam.x = mapWidth - w/2
    end
    if cam.y > mapHeight - h/2 then
        cam.y = mapHeight - h/2
    end 

end

return camaraControl