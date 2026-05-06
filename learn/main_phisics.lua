function love.load()

    wf = require "libraries/windfield"

    world = wf.newWorld(0,500)

    player = world:newRectangleCollider(350,100,80,80)

    ground = world:newRectangleCollider(100,400,600,100)

    ground:setType('static')



end


function love.update(dt)
    world:update(dt)
end


function love.draw()
    world:draw()
end

function love.keypressed(key)
    if key == 'up' then
        player:applyLinearImpulse(0,-5000)
    end
end


