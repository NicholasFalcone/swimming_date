class('Camera').extends()

function Camera:init(position, rotation)
    self.position = position or Vector3(0, 0, -10)
    self.rotation = rotation or Vector3(0, 0, 0) -- Euler angles in radians: pitch, yaw, roll
    self.focalLength = 300
    self.displayCenterX = 200
    self.displayCenterY = 120
end

function Camera:transform(point)
    -- Translate relative to camera
    local p = point:sub(self.position)
    
    -- Rotate (inverse camera rotation)
    -- Order: Y (Yaw), X (Pitch), Z (Roll)
    p = p:rotateY(-self.rotation.y)
    p = p:rotateX(-self.rotation.x)
    p = p:rotateZ(-self.rotation.z)
    
    return p
end

function Camera:project(point)
    local p = self:transform(point)
    
    -- Clip if behind camera (z > 0 in this system where forward is +Z? Or -Z? 
    -- Usually OpenGL is -Z forward. Let's assume +Z is forward for simplicity or check Vector3.
    -- If we move "Forward" by adding Z, then +Z is forward.
    -- If p.z <= 0, it's behind or at lens.
    
    if p.z <= 1 then return nil end -- Near clip plane
    
    local scale = self.focalLength / p.z
    local screenX = p.x * scale + self.displayCenterX
    local screenY = p.y * scale * -1 + self.displayCenterY -- Flip Y for screen coords
    
    return { x = screenX, y = screenY, scale = scale, z = p.z }
end

function Camera:getForwardVector()
    -- Calculate forward vector from rotation
    -- Default forward is (0, 0, 1)
    local v = Vector3(0, 0, 1)
    v = v:rotateX(self.rotation.x)
    v = v:rotateY(self.rotation.y)
    return v
end

function Camera:getRightVector()
    -- Default right is (1, 0, 0)
    local v = Vector3(1, 0, 0)
    v = v:rotateX(self.rotation.x)
    v = v:rotateY(self.rotation.y)
    return v
end

function Camera:getUpVector()
    -- Default up is (0, 1, 0)
    local v = Vector3(0, 1, 0)
    v = v:rotateX(self.rotation.x)
    v = v:rotateY(self.rotation.y)
    return v
end
