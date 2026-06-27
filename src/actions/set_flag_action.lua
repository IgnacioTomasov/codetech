-- set_flag_action.lua
-- Acción reutilizable para establecer una o más flags.

local SetFlagAction = {}

function SetFlagAction:create(session, flags)

    return function()

        for flagName, value in pairs(flags) do
            session:setFlag(flagName, value)
        end

    end

end

return SetFlagAction