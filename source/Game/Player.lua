class('Player').extends()

function Player:init(camera, world)
    self.camera = camera
    self.world = world
    self.velocity = Vector3(0, 0, 0)
    self.acceleration = 1.0 -- Impulse per frame of cranking
    self.friction = 0.95 -- Water drag
    self.lookSpeed = 0.05 -- Radians per frame
    self.wobbleSpeed = 0.002
    self.wobbleAmount = 0.02
end

function Player:update()
    -- Water Wobble (Roll)
    local time = playdate.getCurrentTimeMilliseconds()
    self.camera.rotation.z = math.sin(time * self.wobbleSpeed) * self.wobbleAmount
    
    -- D-Pad for Look (Pitch/Yaw)
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        self.camera.rotation.x -= self.lookSpeed -- Look Up
    elseif playdate.buttonIsPressed(playdate.kButtonDown) then
        self.camera.rotation.x += self.lookSpeed -- Look Down
    end
    
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        self.camera.rotation.y -= self.lookSpeed -- Look Left
    elseif playdate.buttonIsPressed(playdate.kButtonRight) then
        self.camera.rotation.y += self.lookSpeed -- Look Right
    end
    
    -- Clamp Pitch to avoid flipping (optional, but good for FPS)
    local maxPitch = math.rad(89)
    if self.camera.rotation.x > maxPitch then self.camera.rotation.x = maxPitch end
    if self.camera.rotation.x < -maxPitch then self.camera.rotation.x = -maxPitch end
    
    -- Crank for Swimming (Throttle/Impulse)
    local crankChange = playdate.getCrankChange()
    
    if crankChange ~= 0 then
        -- Apply impulse based on crank speed and direction
        -- Positive crank (clockwise) -> Move Forward
        -- Negative crank (counter-clockwise) -> Move Backward
        
        local impulse = 0
        if crankChange > 0 then
            impulse = self.acceleration * (crankChange / 5) -- Scale by speed
        else
            impulse = self.acceleration * (crankChange / 5)
        end
        
        -- Get Forward Vector (Look Direction)
        local forward = self.camera:getForwardVector()
        
        -- Apply acceleration in look direction
        self.velocity = self.velocity:add(forward:mul(impulse))
    end
    
    -- Apply Friction
    self.velocity = self.velocity:mul(self.friction)
    
    -- Stop if very slow
    if self.velocity:magnitude() < 0.01 then
        self.velocity = Vector3(0, 0, 0)
    end
    
    -- Apply Velocity to Position
    if self.velocity:magnitude() > 0 then
        local newPos = self.camera.position:add(self.velocity)
        
        -- Collision with World Cube
        if self.world then
            local limit = self.world.size - 5
            
            if newPos.x > limit then 
                newPos.x = limit 
                self.velocity.x = 0 
            elseif newPos.x < -limit then 
                newPos.x = -limit 
                self.velocity.x = 0 
            end
            
            if newPos.y > limit then 
                newPos.y = limit 
                self.velocity.y = 0 
            elseif newPos.y < -limit then 
                newPos.y = -limit 
                self.velocity.y = 0 
            end
            
            if newPos.z > limit then 
                newPos.z = limit 
                self.velocity.z = 0 
            elseif newPos.z < -limit then 
                newPos.z = -limit 
                self.velocity.z = 0 
            end
        end
        
        self.camera.position = newPos
    end
end
