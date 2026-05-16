local actions = {}

--Ejemplo
function actions.acceptOvertime(session)

    session.stats.anxiety =
        session.stats.anxiety + 10

    session.stats.prestige =
        session.stats.prestige + 5

    session.time.hour =
        session.time.hour + 2
end

return actions