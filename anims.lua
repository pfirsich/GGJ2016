function animationSet(image, frameCount)
    local animSet = {}
    animSet.image = image
    animSet.frameWidth = image:getWidth()/frameCount
    animSet.frames = {}
    for i = 1, frameCount do
        table.insert(animSet.frames, love.graphics.newQuad((i-1)*animSet.frameWidth, 0, animSet.frameWidth, image:getHeight(), image:getWidth(), image:getHeight()))
    end

    animSet.animations = {}
    animSet.update = function(self, dt)

    end

    animSet.setAnimation = function(self, name, startIndex)
        self.animations[name].index = startIndex or 1
        self.animations[name].time = 0
        self.currentAnimation = name
    end

    animSet.update = function(self, dt)
        self.animations[self.currentAnimation].time = self.animations[self.currentAnimation].time + dt
    end

    animSet.getCurrentFrame = function(self)
        local anim = self.animations[self.currentAnimation]
        local frame = anim.from + math.floor(anim.time * anim.speed) % (anim.to - anim.from)
        if anim.to == anim.from then frame = anim.from end 
        return frame
    end

    animSet.draw = function(self, ...)
        local anim = self.animations[self.currentAnimation]
        love.graphics.draw(animSet.image, animSet.frames[self:getCurrentFrame()], ...)
    end

    return animSet
end

function animation(from, to, speed)
    local anim = {}
    anim.from = from
    anim.to = to
    anim.speed = speed
    return anim
end