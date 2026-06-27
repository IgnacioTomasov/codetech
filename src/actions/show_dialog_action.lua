-- show_dialog_action.lua

local StateManager = require("src.managers.state_manager")
local TextBoxState = require("src.states.textbox")

local ShowDialogAction = {}

function ShowDialogAction:create(session, dialogId)

    return function()
        -- Abre un diálogo identificado por dialogId.
        StateManager:push(
            TextBoxState:new(
                session,
                dialogId
            )
        )
    end

end

return ShowDialogAction