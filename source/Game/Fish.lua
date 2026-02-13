class('Fish').extends()

function Fish:init(position, world)
    self.position = position or Vector3(0, 0, 0)
    self.world = world
    
    -- Movement
    self.velocity = Vector3(
        math.random() * 2 - 1,
        math.random() * 2 - 1,
        math.random() * 2 - 1
    ):normalize():mul(math.random() * 0.5 + 0.3)
    
    self.speed = math.random() * 0.8 + 0.5
    self.wobblePhase = math.random() * math.pi * 2
    self.turnTimer = math.random() * 3.0 + 2.0 -- Time until direction change
    
    -- Visual
    self.size = math.random() * 8 + 12 -- Fish length
    self.rotation = 0 -- Yaw rotation
    
    -- Define fish shape (simple wireframe)
    -- Body: triangle + tail
    self.model = {
        -- Body triangle
        {Vector3(0, 0, 0), Vector3(0, 1, -0.3)},     -- nose to top
        {Vector3(0, 0, 0), Vector3(0, -1, -0.3)},    -- nose to bottom
        {Vector3(0, 1, -0.3), Vector3(0, 0, -1)},    -- top to tail base
        {Vector3(0, -1, -0.3), Vector3(0, 0, -1)},   -- bottom to tail base
        -- Tail fin
        {Vector3(0, 0, -1), Vector3(0, 0.5, -1.3)},  -- tail base to top fin
        {Vector3(0, 0, -1), Vector3(0, -0.5, -1.3)}, -- tail base to bottom fin
    }
end

function Fish:update(dt)
    local time = playdate.getCurrentTimeMilliseconds() / 1000.0
    
    -- Swimming wobble (tail movement simulation)
    local wobble = math.sin(time * 5.0 + self.wobblePhase) * 0.02
    
    -- Update direction periodically
    self.turnTimer = self.turnTimer - dt
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
    
    -- Apply velocity
    self.position = self.position:add(self.velocity:mul(dt * 60))
    
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
    end
end

function Fish:draw(camera)
    local gfx = playdate.graphics
    
    -- Draw fish wireframe
    for _, line in ipairs(self.model) do
        -- Scale, rotate, and translate vertices
        local v1 = self:transformVertex(line[1])
        local v2 = self:transformVertex(line[2])
        
        local p1 = camera:project(v1)
        local p2 = camera:project(v2)
        
        if p1 and p2 then
            -- Depth-based line width
            local avgZ = (p1.z + p2.z) / 2
            if avgZ < 150 then
                gfx.setLineWidth(2)
            else
                gfx.setLineWidth(1)
            end
            
            gfx.setColor(gfx.kColorBlack)
            gfx.drawLine(p1.x, p1.y, p2.x, p2.y)
        end
    end
end

function Fish:transformVertex(vertex)
    -- Scale by fish size
    local scaled = Vector3(
        vertex.x * self.size,
        vertex.y * self.size,
        vertex.z * self.size
    )
    
    -- Rotate around Y axis (yaw)
    local rotated = scaled:rotateY(self.rotation)
    
    -- Translate to fish position
    return rotated:add(self.position)
end
