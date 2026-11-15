-- Pruebas de src/content/dialogs.lua (DialogRepository)
local DialogRepository = require("src.content.dialogs")

return {

    ["resuelve un id de diálogo válido"] = function()
        local dialogo = DialogRepository:get(
            "la_llegada/control_acceso:contract_intro"
        )

        verdad(type(dialogo) == "table", "el diálogo debe ser una tabla")
        verdad(#dialogo.pages > 0, "debe tener páginas")
    end,

    ["falla con id sin separador"] = function()
        local ok, err = pcall(DialogRepository.get, DialogRepository, "sin_separador")
        falso(ok, "debería fallar con un id sin ':'")
    end,

    ["falla con diálogo inexistente en un módulo existente"] = function()
        local ok = pcall(
            DialogRepository.get,
            DialogRepository,
            "la_llegada/control_acceso:no_existe"
        )
        falso(ok, "debería fallar con un nombre de diálogo inexistente")
    end,

}
