local StateManager = require("src.managers.state_manager")

local sti = require("libraries/sti")
local map = sti('maps/testMap.lua')

local bump = require("libraries/bump")
local world = bump.newWorld(64)

local character = require("src.entities.character")
local player = character.new(350,300,60,30,200,'sprites/bingo_grid.png')
local npc = require("src.entities.npc")

local inputControl = require("src.input")

local camera = require 'libraries/camera'
local cam = camera()
local cameraControl = require("src.camera")

local collisions = require("src.collisions")


local game = {}

function game:load()

  world:add(player, player.x, player.y, player.w, player.h)
  npc.worldAdd(world, npcs)

  -- cargar colisiones desde Tiled
  collisions.solve("Arboles", "solid", world, map)
end

function game:update(dt)

  --resuleve colisiones y mueve.
  local dx1, dy1 = inputControl.moveIntention(dt, player)
  player:move(dx1, dy1, world)
  
  npc.move(dt, world, player)

  cameraControl.limitsCorrection(cam, map, player.x, player.y)
  player:update(dt)
  npc.update(dt)

end

function game:draw()

  cam:attach()
    map:drawLayer(map.layers["Base"])
    map:drawLayer(map.layers["Arboles"])
    npc.draw()
    player:draw(false)
    collisions.draw(false, world, player)
  cam:detach()
  
end

function game:keypressed(key)

    if key == "return" then
        local PauseState = require("src.states.pause")
        StateManager:push(PauseState)
    end
end


return game

