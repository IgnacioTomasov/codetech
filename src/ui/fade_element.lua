local FadeElement = {}

function FadeElement:new(config)

    local element = {

        -- Visual
        image = config.image or nil,
        animation = config.animation or nil,
        text = config.text or nil,
        font = config.font or love.graphics.getFont(),

        -- Position
        x = config.x or 0,
        y = config.y or 0,
        centered = config.centered or false,

        -- Scale
        scaleX = config.scaleX or 1,
        scaleY = config.scaleY or 1,

        -- Timing
        delay = config.delay or 0,
        fadeSpeed = config.fadeSpeed or 1,

        -- State
        timer = 0,
        alpha = 0,
        visible = false,
        finished = false
    }

    setmetatable(element, self)
    self.__index = self

    return element
end

function FadeElement:update(dt)

    if self.finished then
        return
    end

    self.timer = self.timer + dt

    if self.timer >= self.delay then
        self.visible = true
    end

    if self.visible then

        if self.animation then
            self.animation:update(dt)
        end

        self.alpha = math.min(
            self.alpha + self.fadeSpeed * dt,
            1
        )

        if self.alpha >= 1 then
            self.finished = true
        end
    end
end

function FadeElement:draw()

    if not self.visible then
        return
    end

    love.graphics.setColor(1, 1, 1, self.alpha)

    if self.animation and self.image then

        self.animation:draw(
            self.image,
            self.x,
            self.y,
            0,
            self.scaleX,
            self.scaleY
        )

    elseif self.image then

        love.graphics.draw(
            self.image,
            self.x,
            self.y,
            0,
            self.scaleX,
            self.scaleY
        )

    elseif self.text then

        love.graphics.setFont(self.font)

        if self.centered then

            local textWidth = self.font:getWidth(self.text)

            local centeredX =
                (love.graphics.getWidth() - textWidth) / 2

            love.graphics.print(
                self.text,
                centeredX + self.x,
                self.y
            )

        else

            love.graphics.print(
                self.text,
                self.x,
                self.y
            )
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return FadeElement