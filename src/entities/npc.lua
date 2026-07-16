local character = require("src.entities.character")
local Pecera = require("src.entities.pecera")
local Door = require("src.entities.doors")
local inputControl = require("src.input")

local npc = {} -- función a exportar
local npcs = {} -- lista de npc y personajes
local doors = {}

-- local npcPositions = {
--     {x = 760,  y = 320},
--     {x = 1180, y = 240},
--     {x = 1640, y = 1640},
-- }

local npcPositions = {
}

local peceras = {
    Pecera.new((37) * 32, (7) * 32, 'assets/Characters/pecera.png', 0.6),
    Pecera.new((42) * 32, (7) * 32, 'assets/Characters/pecera.png', 0.7),
    Pecera.new((38) * 32, (6) * 32, 'assets/Characters/pecera.png', 0.8),
    Pecera.new((43) * 32, (6) * 32, 'assets/Characters/pecera.png', 0.65),
}

for _, pos in ipairs(npcPositions) do
    -- x/y = posición física
    -- w/h = collider lógico
    local entity = character.new(
        pos.x,
        pos.y,
        24,
        14,
        50,
        'sprites/praga_grid.png'
    )

    table.insert(npcs, entity)
end

function npc.worldAdd(world)
    for _, entity in ipairs(npcs) do
        world:add(entity, entity.x, entity.y, entity.w, entity.h)
    end

    doors = {
        -- Entrada
        Door:new(world, 43 * 32, 21 * 32, "contract_signed", "left"),
        Door:new(world, 44 * 32, 21 * 32, "contract_signed", "right"),
        Door:new(world, 46 * 32, 21 * 32, "contract_signed", "left"),
        Door:new(world, 47 * 32, 21 * 32, "contract_signed", "right"),

        -- Oficina C Hipo 
        Door:new(world, 44 * 32, 12 * 32, "contract_signed", "left"),
        Door:new(world, 45 * 32, 12 * 32, "contract_signed", "right"),

        -- Oficina A
        Door:new(world, 20 * 32, 12 * 32, "contract_signed", "left"),
        Door:new(world, 21 * 32, 12 * 32, "contract_signed", "right"),

        -- Oficina B
        Door:new(world, 29 * 32, 12 * 32, "contract_signed", "left"),
        Door:new(world, 30 * 32, 12 * 32, "contract_signed", "right"),

        -- Oficina D
        Door:new(world, 59 * 32, 12 * 32, "contract_signed", "left"),
        Door:new(world, 60 * 32, 12 * 32, "contract_signed", "right"),
    }
end

function npc.move(dt, world, player)
    for _, entity in ipairs(npcs) do
        local dx, dy = inputControl.randomMoveIntention(dt, entity, 1)

        entity:move(dx, dy, world)

        inputControl.tailReaction(player, entity, 80)
    end
end

function npc.update(dt, session, player)
    for _, entity in ipairs(npcs) do
        entity:update(dt)
    end
    
    for _, pecera in ipairs(peceras) do
        pecera:update(dt)
    end

    for _, door in ipairs(doors) do
        door:update(dt, session, player)
    end
end

function npc.draw()
    for _, entity in ipairs(npcs) do
        entity:draw(false)
    end
    
    for _, pecera in ipairs(peceras) do
        pecera:draw()
    end

    for _, door in ipairs(doors) do
        door:draw()
    end
end

function npc.getAll()
    return npcs
end

function npc.getCompletedCount()

    local completed = 0

    for _, entity in ipairs(npcs) do
        if entity.isCompleted then
            completed = completed + 1
        end
    end

    return completed
end

function npc.getTotalCount()
    return #npcs
end

return npc