class('World').extends()

function World:init(size)
    self.size = size or 200
    self.particles = {}
    
    -- Cube Vertices
    self.vertices = {
        Vector3(-size, -size, -size), Vector3(size, -size, -size),
        Vector3(size, size, -size), Vector3(-size, size, -size),
        Vector3(-size, -size, size), Vector3(size, -size, size),
        Vector3(size, size, size), Vector3(-size, size, size)
    }
    
    -- Cube Edges (indices)
    self.edges = {
        {1,2}, {2,3}, {3,4}, {4,1}, -- Back face (Z-)
        {5,6}, {6,7}, {7,8}, {8,5}, -- Front face (Z+)
        {1,5}, {2,6}, {3,7}, {4,8}  -- Connecting edges
    }
    
    -- Water Surface Grid (Top Face: Y = +size)
    self.surfaceRows = 4
    self.surfaceCols = 4
    self.surfacePoints = {}
    local stepX = (size * 2) / self.surfaceRows
    local stepZ = (size * 2) / self.surfaceCols
    
    for x = 0, self.surfaceRows do
        for z = 0, self.surfaceCols do
            local px = -size + x * stepX
            local pz = -size + z * stepZ
            table.insert(self.surfacePoints, {base = Vector3(px, size, pz), current = Vector3(px, size, pz)})
        end
    end
    
    -- -- Caustic Particles (Bottom Face: Y = -size)
    -- self.caustics = {}
    -- for i=1, 40 do
    --     table.insert(self.caustics, {
    --         pos = Vector3(math.random(-size, size), -size, math.random(-size, size)),
    --         speed = math.random() * 0.05 + 0.02,
    --         offset = math.random() * math.pi * 2
    --     })
    -- end
    
    -- Suspended Particles
    math.randomseed(playdate.getSecondsSinceEpoch())
    for i=1, 60 do
        table.insert(self.particles, Vector3(
            math.random(-size, size), -- X
            math.random(-size, size), -- Y
            math.random(-size, size)  -- Z
        ))
    end
    
    self.accumulatedWaveDt = 0
end

function World:draw(camera, dt)
    local gfx = playdate.graphics
    local time = playdate.getCurrentTimeMilliseconds() / 1000.0
    
    -- Update Surface Waves & Refraction
    self.accumulatedWaveDt = self.accumulatedWaveDt + dt
    if self.accumulatedWaveDt >= 1.0 then
        for _, p in ipairs(self.surfacePoints) do
            -- Vertical Wave (Height)
            local waveY = math.sin(p.base.x * 0.03 + time * 2.5) * 8 
                        + math.cos(p.base.z * 0.04 + time * 2.0) * 8
            
            -- Horizontal Refraction (Fake light bending)
            -- We distort X based on Z, and Z based on X to create swirling feel
            local refractX = math.sin(p.base.z * 0.05 + time * 3.0) * 12
            local refractZ = math.cos(p.base.x * 0.05 + time * 2.5) * 12
            
            p.current.y = p.base.y + waveY
            p.current.x = p.base.x + refractX
            p.current.z = p.base.z + refractZ
        end
        self.accumulatedWaveDt = 0
    end
    
    -- Project Vertices
    local projected = {}
    for i, v in ipairs(self.vertices) do
        projected[i] = camera:project(v)
    end
    
    -- Draw Cube Edges
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(2)
    
    for _, edge in ipairs(self.edges) do
        local p1 = projected[edge[1]]
        local p2 = projected[edge[2]]
        
        if p1 and p2 then
            gfx.drawLine(p1.x, p1.y, p2.x, p2.y)
        end
    end
    
    -- Draw Surface Grid (Waves) with Dithering
    gfx.setLineWidth(1)
    local idx = 1
    local cols = self.surfaceCols + 1
    for x = 0, self.surfaceRows do
        for z = 0, self.surfaceCols do
            local p = self.surfacePoints[idx].current
            local proj = camera:project(p)
            
            if proj then 
                -- Calculate wave intensity for dithering
                local waveIntensity = math.abs(p.y - self.surfacePoints[idx].base.y) / 16
                local distortion = math.abs(p.x - self.surfacePoints[idx].base.x) / 12
                local totalDistortion = waveIntensity + distortion
                
                -- Apply dithering based on distortion level
                if totalDistortion > 1.5 then
                    gfx.setDitherPattern(0.7, gfx.image.kDitherTypeBayer4x4)
                elseif totalDistortion > 1.0 then
                    gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer4x4)
                elseif totalDistortion > 0.5 then
                    gfx.setDitherPattern(0.3, gfx.image.kDitherTypeBayer8x8)
                else
                    gfx.setColor(gfx.kColorBlack)
                end
                
                -- Draw lines to neighbors
                if z < self.surfaceCols then -- Connect Z neighbor
                    local nextZ = self.surfacePoints[idx + 1].current
                    local nextProj = camera:project(nextZ)
                    if nextProj then gfx.drawLine(proj.x, proj.y, nextProj.x, nextProj.y) end
                end
                
                if x < self.surfaceRows then -- Connect X neighbor
                    local nextX = self.surfacePoints[idx + cols].current
                    local nextProj = camera:project(nextX)
                    if nextProj then gfx.drawLine(proj.x, proj.y, nextProj.x, nextProj.y) end
                end
            end
            idx = idx + 1
        end
    end
    
    -- Reset color for next drawing
    gfx.setColor(gfx.kColorBlack)
    
    -- -- Draw Floor Caustics (simulated light patterns)
    -- for _, c in ipairs(self.caustics) do
    --     -- Animate caustic
    --     c.pos.x = c.pos.x + math.sin(time * 2.0 + c.offset) * 1.0
    --     c.pos.z = c.pos.z + math.cos(time * 1.5 + c.offset) * 1.0
        
    --     -- Wrap around
    --     if c.pos.x > self.size then c.pos.x = -self.size end
    --     if c.pos.x < -self.size then c.pos.x = self.size end
    --     if c.pos.z > self.size then c.pos.z = -self.size end
    --     if c.pos.z < -self.size then c.pos.z = self.size end
        
    --     local proj = camera:project(c.pos)
    --     if proj then
    --         -- Caustics are bright, so maybe use white with dithering or just circles?
    --         -- Since background is white (screen clear), we draw black.
    --         -- To make it look like light, it should be inverted? 
    --         -- Playdate is 1-bit. Light = White, Shadow = Black.
    --         -- So "Caustics" (Light) should be White on dark? Or Black patterns on White?
    --         -- Standard Playdate: White background.
    --         -- "Caustics" are usually bright lines.
    --         -- If we draw black circles, they look like shadows.
    --         -- Let's draw rapidly changing dithered circles to simulate shimmering light patterns?
    --         -- Or simple rings.
            
    --         local r = math.max(2, 100 / proj.z)
    --         if r > 15 then r = 15 end
            
    --         -- Draw a "light ring"
    --         gfx.setLineWidth(2)
    --         gfx.drawCircleAtPoint(proj.x, proj.y, r)
            
    --         -- Wobbly inner
    --         -- gfx.fillCircleAtPoint(proj.x, proj.y, r/2)
    --     end
    -- end
    
    -- Draw Particles
    gfx.setLineWidth(1)
    for _, p in ipairs(self.particles) do
        local proj = camera:project(p)
        if proj then
            -- Depth Dithering
            -- Closer particles are darker/solid
            -- Far particles are lighter/dithered
            
            local z = proj.z
            local radius = math.max(1, 200 / z)
            if radius > 8 then radius = 8 end
            
            if z < 100 then
                 gfx.setColor(gfx.kColorBlack)
            elseif z < 200 then
                gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer4x4)
            elseif z < 300 then
                gfx.setDitherPattern(0.2, gfx.image.kDitherTypeBayer8x8)
            else
                gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
            end
            
            gfx.fillCircleAtPoint(proj.x, proj.y, radius)
        end
    end
    
    -- Draw Boundary Warning
    if math.abs(camera.position.x) >= self.size - 5 or
       math.abs(camera.position.y) >= self.size - 5 or
       math.abs(camera.position.z) >= self.size - 5 then
       
       gfx.setColor(gfx.kColorBlack)
       gfx.drawText("WALL HIT", 5, 220)
    end
end
