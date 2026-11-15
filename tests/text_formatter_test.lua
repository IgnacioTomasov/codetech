-- Pruebas de src/content/text_formatter.lua
local TextFormatter = require("src.content.text_formatter")

return {

    ["resuelve placeholder conocido desde session"] = function()
        local session = { player = { name = "Ada" } }
        igual(
            TextFormatter:format(session, "Bienvenido {player_name}."),
            "Bienvenido Ada."
        )
    end,

    ["player sin nombre retorna el valor por defecto"] = function()
        local session = { player = {} }
        igual(
            TextFormatter:format(session, "Hola {player_name}"),
            "Hola Jugador"
        )
    end,

    ["company_name es constante"] = function()
        igual(
            TextFormatter:format({}, "Vienes a {company_name}"),
            "Vienes a Codetech"
        )
    end,

    ["placeholder desconocido se conserva"] = function()
        igual(
            TextFormatter:format({}, "Texto {que_no_existe} igual"),
            "Texto {que_no_existe} igual"
        )
    end,

    ["texto nil retorna cadena vacía"] = function()
        igual(TextFormatter:format({}, nil), "")
    end,

    ["placeholders registrados dinámicamente leen session"] = function()
        TextFormatter:register("prueba_dinamica", function(session)
            return session.valor
        end)

        igual(
            TextFormatter:format({ valor = "dinamico" }, "{prueba_dinamica}!"),
            "dinamico!"
        )
    end,

}
