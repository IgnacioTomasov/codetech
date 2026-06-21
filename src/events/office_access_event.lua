-- office_access_event.lua

local OfficeAccessEvent = {}

function OfficeAccessEvent:create(session)

    return function()

        session:setFlag("contract_signed", true)

        print("Acceso habilitado")

    end

end

return OfficeAccessEvent