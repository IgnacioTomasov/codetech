-- office_access_event.lua

local StateManager = require("src.managers.state_manager")
local TextBoxState = require("src.states.textbox")

local ShowContractEvent = {}

function ShowContractEvent:create(session)

    return function()

        StateManager:push(
            TextBoxState:new(session, {
                pages = {

                    {
                        text = "Bienvenido a Codetech."
                    },

                    {
                        text = "¿Deseas firmar?",

                        options = {
                            {
                                text = "Aceptar",
                                flag = "contract_signed"
                            },
                            {
                                text = "Rechazar",
                                flag = "contract_rejected"
                            }
                        }
                    }

                }
            })
        )

        print("Mostrar contrato")

    end

end

return ShowContractEvent