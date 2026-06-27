local DialogRepository = {}

local cache = {}

local function splitDialogId(dialogId)

    local modulePath, dialogName = string.match(
        dialogId,
        "^(.-):(.+)$"
    )

    assert(modulePath, "Invalid dialog id: " .. dialogId)
    assert(dialogName, "Invalid dialog id: " .. dialogId)

    return modulePath, dialogName
end

function DialogRepository:get(dialogId)

    local modulePath, dialogName = splitDialogId(dialogId)

    if not cache[modulePath] then
        cache[modulePath] = require(
            "src.content." .. modulePath
        )
    end

    local dialog = cache[modulePath][dialogName]

    assert(
        dialog,
        string.format(
            "Dialog '%s' not found in module '%s'",
            dialogName,
            modulePath
        )
    )

    return dialog

end

return DialogRepository
