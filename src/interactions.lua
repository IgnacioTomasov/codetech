local interactions = {}

function interactions.isClose(player1, player2, threshold)

    local close = false

    distance = math.sqrt(
        math.pow(player1.x - player2.x, 2) +
        math.pow(player1.y - player2.y, 2)
    )
    if distance < threshold then
        close = true
    end

    -- print("distance:", distance, "| close:", close)

    return close
end


return interactions
    
