local character = require("src.entities.character")
local inputControl = require("src.input")

local npc = {} -- función a exportar
local npcs = {} -- lista de npc y personajes

local npcPositions = {
    {x = 760,  y = 320},
    {x = 1180, y = 240},

    {x = 540,  y = 760},
    {x = 920,  y = 680},
    {x = 1360, y = 820},

    {x = 340,  y = 1240},
    {x = 840,  y = 1420},
    {x = 1280, y = 1360},
    {x = 1640, y = 1180},
    {x = 1640, y = 1640},
}

for _, pos in ipairs(npcPositions) do
    local entity = character.new(
        pos.x,
        pos.y,
        60,
        30,
        50,
        'sprites/praga_grid.png'
    )

    table.insert(npcs, entity)
end

function npc.worldAdd(world)
    for _, entity in ipairs(npcs) do
        world:add(entity, entity.x, entity.y, entity.w, entity.h)
    end
end

function npc.move(dt, world, player)
    for _, entity in ipairs(npcs) do
        local dx, dy = inputControl.randomMoveIntention(dt, entity, 1)

        entity:move(dx, dy, world)

        inputControl.tailReaction(player, entity, 80)
    end
end

function npc.update(dt)
    for _, entity in ipairs(npcs) do
        entity:update(dt)
    end
end

function npc.draw()
    for _, entity in ipairs(npcs) do
        entity:draw(false)
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