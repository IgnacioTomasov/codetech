local email = {}

local EmailRepository = require("src.core.email.email_repository")

function email:new(session)

    local state = {
        session = session,

        emails = EmailRepository,

        selected = 1,
        openedEmail = nil,
    }

    setmetatable(state, self)
    self.__index = self

    return state
end

function email:load()

    self.font = love.graphics.newFont(18)
end

function email:update(dt)

end

function email:draw()

    love.graphics.setFont(self.font)

    love.graphics.print("INBOX", 50, 30)

    for i, mail in ipairs(self.emails) do

        local prefix = "  "

        if i == self.selected then
            prefix = "> "
        end

        love.graphics.print(
            prefix .. mail.subject,
            50,
            60 + (i * 25)
        )
    end
end

function email:keypressed(key)

    if key == "down" then
        self.selected =
            math.min(
                self.selected + 1,
                #self.emails
            )
    end

    if key == "up" then
        self.selected =
            math.max(
                self.selected - 1,
                1
            )
    end

    if key == "escape" then

        local StateManager =
            require("src.managers.state_manager")

        StateManager:pop()
    end
end

return email