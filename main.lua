local sti = require("libraries/sti")
local map = sti('maps/testMap.lua')

local bump = require("libraries/bump")
local world = bump.newWorld(64)

local character = require("src.character")
local player = character.new(350,300,60,30,200,'sprites/bingo_row_1.png')
local playe2 = character.new(24*64,24*64,60,30,100,'sprites/praga_row_1.png')

local inputControl = require("src.input")

local camera = require 'libraries/camera'
local cam = camera()
local cameraControl = require("src.camera")

local collisions = require("src.collisions")


-- nota, las funciones inferiores pueden ver las variables locales creadas. No así las superiores.

function love.load()

  world:add(player, player.x, player.y, player.w, player.h)
  world:add(playe2, playe2.x, playe2.y, playe2.w, playe2.h)

  -- cargar colisiones desde Tiled
  collisions.solve("Arboles", "solid", world, map)
end

function love.update(dt)

  local dx1, dy1 = inputControl.moveIntention(dt, player)
  local dx2, dy2 = inputControl.randomMoveIntention(dt, playe2, 1)

  --resuleve colisiones y mueve.
  player:move(dx1, dy1, world)
  playe2:move(dx2, dy2, world)

  cameraControl.limitsCorrection(cam, map, player.x, player.y)
  player:update(dt)
  playe2:update(dt)

end

function love.draw()

  cam:attach()
    map:drawLayer(map.layers["Base"])
    map:drawLayer(map.layers["Arboles"])
    playe2:draw(false)
    player:draw(false)
    collisions.draw(false, world, player)
  cam:detach()
  
end

