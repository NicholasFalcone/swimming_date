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

local lastTime = playdate.getCurrentTimeMilliseconds()

function playdate.update()
    gfx.clear()
    
    local currentTime = playdate.getCurrentTimeMilliseconds()
    local dt = (currentTime - lastTime) / 1000.0
    lastTime = currentTime
    
    -- Cap dt to 100ms to avoid physics jumps after pauses or lag
    if dt > 0.1 then dt = 0.1 end

    player:update()
    world:draw(camera, dt)
    
    for _, fish in ipairs(fishies) do
        fish:update(dt)
        fish:draw(camera)
    end
end
