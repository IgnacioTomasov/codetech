-- Pruebas de src/core/game_flags.lua
local GameFlags = require("src.core.game_flags")

return {

    ["set/get guarda el valor"] = function()
        local flags = GameFlags:new()
        flags:set("mi_flag", true)
        igual(flags:get("mi_flag"), true)
    end,

    ["get de flag inexistente retorna nil"] = function()
        local flags = GameFlags:new()
        igual(flags:get("no_existe"), nil)
    end,

    ["isEnabled solo es verdadero con true"] = function()
        local flags = GameFlags:new()
        flags:set("a", true)
        flags:set("b", false)

        verdad(flags:isEnabled("a"), "a debería estar habilitada")
        falso(flags:isEnabled("b"), "b con false no debería estar habilitada")
        falso(flags:isEnabled("no_existe"), "inexistente no debería estar habilitada")
    end,

}
