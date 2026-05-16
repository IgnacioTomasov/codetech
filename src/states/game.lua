local StateManager = require("src.managers.state_manager")

local sti = require("libraries/sti")

local bump = require("libraries/bump")

local character = require("src.entities.character")
local npc = require("src.entities.npc")

local inputControl = require("src.input")

local camera = require 'libraries/camera'

local cameraControl = require("src.camera")

local collisions = require("src.collisions")
local StatusBar = require("src.ui.status_bar")



local game = {}

function game:new(session)

    local state = {
        session = session
    }

    setmetatable(state, self)
    self.__index = self

    return state
end

function game:load()

    self.map = sti('maps/office_floor_14/floor_14.lua')
 
    self.world = bump.newWorld(64)

    -- self.player = character.new(350,300,60,30,200,'sprites/bingo_grid.png')
    -- x, y representan la posición física (pies)
    -- w, h representan únicamente el collider

    local w_sprit = 32 --Ancho original del png en un cuadro 
    local h_sprit = 48 --Alto original del png en un cuadro 
    local restar_pixeles_x = 6 --numero de pixeles a reducir en x (solo en un lado) 

    self.player = character.new(
        1350,
        300,
        w_sprit-2*restar_pixeles_x, -- Ancho x del collider
        h_sprit/2, -- Altura y del collider
        -restar_pixeles_x, -- desplazamiento x respecto al collider
        -h_sprit/2 +2, -- desplazamiento y respecto al collider
        200, --Speed
        'assets/Characters/char_test1.png'
    )
   
    self.cam = camera()
    -- zoom de cámara (1.0 = 100%)
    self.cameraZoom = 1.75
    self.cam:zoom(self.cameraZoom)

    self.statusBar = StatusBar:new(self.session)
    self.statusBar:load()

    -- Registrar collider físico en bump
    self.world:add(self.player, self.player.x, self.player.y, self.player.w, self.player.h)
    npc.worldAdd(self.world, npcs)

    -- cargar colisiones desde Tiled
    collisions.solve("Ventanas-Paredes-Puertas", "solid", self.world, self.map)
end

function game:update(dt)

  --resuleve colisiones y mueve.
  local dx1, dy1 = inputControl.moveIntention(dt, self.player)
  self.player:move(dx1, dy1, self.world)
  
  npc.move(dt, self.world, self.player)

  cameraControl.limitsCorrection(self.cam, self.map, self.player.x, self.player.y, self.cameraZoom,100)
  self.player:update(dt)
  npc.update(dt)
  
  self.statusBar:update(dt)

end

function game:draw()

  self.cam:attach()
    self.map:drawLayer(self.map.layers["Piso"])
    self.map:drawLayer(self.map.layers["Ventanas-Paredes-Puertas"])
    self.map:drawLayer(self.map.layers["Adornos-no-solidos"])
    npc.draw()
    self.player:draw(false)
    -- collisions.draw(true, self.world, self.player)
  self.cam:detach()
  self.statusBar:draw()
end

function game:keypressed(key)

    if key == "return" then
        local PauseState = require("src.states.pause")
        StateManager:push(PauseState:new(self.session))
    end
    if key == "e" then

    local EmailState = require("src.states.email")

    StateManager:push(
        EmailState:new(self.session)
    )
    end
    
end


return game
