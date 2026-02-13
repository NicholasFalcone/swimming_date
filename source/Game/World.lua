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
        {1,2}, {2,3}, {3,4}, {4,1}, -- Back face
        {5,6}, {6,7}, {7,8}, {8,5}, -- Front face
        {1,5}, {2,6}, {3,7}, {4,8}  -- Connecting edges
    }
    
    -- Generate random particles
    math.randomseed(playdate.getSecondsSinceEpoch())
    for i=1, 100 do
        table.insert(self.particles, Vector3(
            math.random(-size, size),
            math.random(-size, size),
            math.random(-size, size)
        ))
    end
end

function World:draw(camera)
    local gfx = playdate.graphics
    
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
