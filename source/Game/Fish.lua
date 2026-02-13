class('Fish').extends()

local fishSprites = {}

function Fish:init(position, world)
    self.position = position or Vector3(0, 0, 0)
    self.world = world
    
    -- Load images once
    if #fishSprites == 0 then
        for i = 1, 4 do
            local img = playdate.graphics.image.new('Assets/fish_v' .. i)
            if img then
                local w, h = img:getSize()
                local flipped = playdate.graphics.image.new(w, h)
                playdate.graphics.lockFocus(flipped)
                img:draw(0, 0, playdate.graphics.kImageFlippedX)
                playdate.graphics.unlockFocus()
                
                table.insert(fishSprites, {img = img, flipped = flipped})
            end
        end
    end
    
    -- Assign random sprite
    if #fishSprites > 0 then
        self.spriteIndex = math.random(1, #fishSprites)
    else
        self.spriteIndex = 0
    end
    
    -- Movement
    self.velocity = Vector3(
        math.random() * 2 - 1,
        math.random() * 2 - 1,
        math.random() * 2 - 1
    ):normalize():mul(math.random() * 0.2 + 0.1)
    
    self.speed = math.random() * 0.3 + 0.2
    self.wobblePhase = math.random() * math.pi * 2
    self.turnTimer = math.random() * 3.0 + 2.0 -- Time until direction change
    
    -- Visual
    self.size = math.random() * 0.5 + 0.8 -- Base scale for sprite
    self.rotation = 0 -- Yaw rotation
    self.flip = playdate.graphics.kImageUnflipped

    self.frameCounter = math.random(0, 59)
    self.accumulatedDt = 0
end

function Fish:update(dt)
    local time = playdate.getCurrentTimeMilliseconds() / 1000.0
    
    -- Update AI and collisions only every 1.0 second
    self.accumulatedDt = self.accumulatedDt + dt
    if self.accumulatedDt >= 1.0 then
        -- Update direction periodically
        self.turnTimer = self.turnTimer - self.accumulatedDt
        if self.turnTimer <= 0 then
            self.turnTimer = math.random() * 4.0 + 2.0
            -- Slight direction change
            local turn = Vector3(
                (math.random() * 2 - 1) * 0.3,
                (math.random() * 2 - 1) * 0.3,
                (math.random() * 2 - 1) * 0.3
            )
            self.velocity = self.velocity:add(turn):normalize():mul(self.speed)
        end
        
        -- Wall avoidance
        local limit = self.world.size - 30
        local bounce = 0.5
        
        if self.position.x > limit then
            self.position.x = limit
            self.velocity.x = -math.abs(self.velocity.x) * bounce
        elseif self.position.x < -limit then
            self.position.x = -limit
            self.velocity.x = math.abs(self.velocity.x) * bounce
        end
        
        if self.position.y > limit then
            self.position.y = limit
            self.velocity.y = -math.abs(self.velocity.y) * bounce
        elseif self.position.y < -limit then
            self.position.y = -limit
            self.velocity.y = math.abs(self.velocity.y) * bounce
        end
        
        if self.position.z > limit then
            self.position.z = limit
            self.velocity.z = -math.abs(self.velocity.z) * bounce
        elseif self.position.z < -limit then
            self.position.z = -limit
            self.velocity.z = math.abs(self.velocity.z) * bounce
        end
        
        -- Calculate rotation (yaw) based on velocity direction
        if self.velocity:magnitude() > 0.01 then
            self.rotation = math.atan2(self.velocity.x, self.velocity.z)
            -- Determine flip based on horizontal movement
            if self.velocity.x > 0 then
                self.flip = playdate.graphics.kImageUnflipped -- Right
            else
                self.flip = playdate.graphics.kImageFlippedX -- Left
            end
        end
        
        self.accumulatedDt = 0
    end

    -- Always apply velocity for smooth movement
    self.position = self.position:add(self.velocity:mul(dt * 40))
end

function Fish:draw(camera)
    local proj = camera:project(self.position)
    if proj then
        local spriteData = fishSprites[self.spriteIndex]
        if spriteData then
            -- Scale by depth (proj.scale) and base fish size
            local drawScale = proj.scale * 0.05 * self.size
            
            -- Add a tiny bit of wobble to the sprite position
            local time = playdate.getCurrentTimeMilliseconds() / 1000.0
            local wobbleY = math.sin(time * 5.0 + self.wobblePhase) * 2
            
            local img = spriteData.img
            if self.flip == playdate.graphics.kImageFlippedX then
                img = spriteData.flipped
            end
            
            -- Center the sprite
            local w, h = img:getSize()
            local offX = (w * drawScale) / 2
            local offY = (h * drawScale) / 2
            
            img:drawScaled(proj.x - offX, proj.y + wobbleY - offY, drawScale)
        else
            -- Fallback: simple circle if image is missing
            local gfx = playdate.graphics
            local r = math.max(2, proj.scale * 2 * self.size)
            gfx.setColor(gfx.kColorBlack)
            gfx.fillCircleAtPoint(proj.x, proj.y, r)
        end
    end
end
