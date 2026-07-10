local TriggerArea = require("src.triggers.trigger_area")
local InteractionArea = require("src.triggers.interaction_area")
local SetFlagAction = require("src.actions.set_flag_action")
local ShowDialogAction = require("src.actions.show_dialog_action")

local officeTriggers = {}

local items = {}

function officeTriggers.load(session)

    items = {}

    table.insert(
        items,
        TriggerArea:new(
            1376, 844, 160, 128,
            SetFlagAction:create(
                session,
                {
                    contract_signed = true
                }
            ),
            session,
            "contract_signed"
        )
    )

    local contractIntroAction = ShowDialogAction:create(
        session,
        "la_llegada/control_acceso:contract_intro"
    )

    table.insert(
        items,
        InteractionArea:new(
            41 * 32, 23 * 32, 32, 32,
            contractIntroAction
        )
    )

end

function officeTriggers.keypressed(key)

    for _, trigger in ipairs(items) do
        if trigger.keypressed then
            trigger:keypressed(key)
        end
    end

end

function officeTriggers.update(player)

    for _, trigger in ipairs(items) do
        trigger:update(player)
    end

end

function officeTriggers.draw()

    for _, trigger in ipairs(items) do
        trigger:draw()
    end

end

return officeTriggers