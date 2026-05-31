local AudioManager = {}

AudioManager.music = {}
AudioManager.sfx = {}

AudioManager.currentMusic = nil

function AudioManager:load()

    self.music.intro =
        love.audio.newSource(
            "assets/audio/music/intro.wav",
            "stream"
        )

    self.music.intro:setLooping(true)
    self.music.intro:setVolume(0.3)

    -- self.music.email =
    --     love.audio.newSource(
    --         "assets/audio/music/email.ogg",
    --         "stream"
    --     )

    -- self.music.email:setLooping(true)

    self.sfx.move_low =
        love.audio.newSource(
            "assets/audio/sfx/menu_move_low.wav",
            "static"
        )
    self.sfx.move_low:setVolume(0.3)

    self.sfx.accept = 
        love.audio.newSource(
            "assets/audio/sfx/menu_accept_ascending.wav",
            "static")
    self.sfx.accept:setVolume(0.3)
end

function AudioManager:playMusic(name)

    local music = self.music[name]

    if not music then
        return
    end

    if self.currentMusic == music then
        return
    end

    if self.currentMusic then
        self.currentMusic:stop()
    end

    self.currentMusic = music

    self.currentMusic:play()
end

function AudioManager:playSfx(name)

    local sfx = self.sfx[name]

    if sfx then
        sfx:clone():play()
    end
end

return AudioManager