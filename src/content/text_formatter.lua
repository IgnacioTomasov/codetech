local TextFormatter = {}

local placeholders = {

    player_name = function(session)
        return session.player and session.player.name or "Jugador"
    end,

    company_name = function(session)
        return "Codetech"
    end,

}

function TextFormatter:register(name, resolver)
    placeholders[name] = resolver
end

function TextFormatter:format(session, text)

    if not text then
        return ""
    end

    local formatted = text

    formatted = formatted:gsub("{(.-)}", function(key)

        local resolver = placeholders[key]

        if resolver then
            return tostring(resolver(session))
        end

        -- Placeholder desconocido: conservar el texto original.
        return "{" .. key .. "}"

    end)

    return formatted

end

return TextFormatter