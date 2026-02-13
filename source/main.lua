import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "Core/Vector3"
import "Core/Camera"
import "Game/World"
import "Game/Player"
import "Game/Fish"

local gfx = playdate.graphics

-- Global Game State
player = nil
world = nil
camera = nil

fishies = {}

-- Initialize Global Game State
camera = Camera(Vector3(0, 0, -10), Vector3(0, 0, 0))
world = World(400) -- Cube radius
player = Player(camera, world)

-- Initialize Fish
for i = 1, 10 do
    local randomPos = Vector3(
        math.random(-world.size + 20, world.size - 20),
        math.random(-world.size + 20, world.size - 20),
        math.random(-world.size + 20, world.size - 20)
    )
    table.insert(fishies, Fish(randomPos, world))
end

function playdate.update()
    gfx.clear()
    
    local dt = playdate.getElapsedTime()

    player:update()
    world:draw(camera)
    
    for _, fish in ipairs(fishies) do
        fish:update(dt)
        fish:draw(camera)
    end

    -- Debug Info
    -- gfx.drawText("FPS: " .. playdate.getFPS(), 5, 5)
end
