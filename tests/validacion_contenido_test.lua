-- Prueba que integra el validador de contenido (tests/validador.lua).
local validador = require("tests.validador")

return {

    ["el contenido de diálogos, triggers y flags es consistente"] = function()
        local errores = validador.validar()

        if #errores > 0 then
            error("validación del contenido:\n  - " .. table.concat(errores, "\n  - "))
        end
    end,

}
