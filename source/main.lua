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

function playdate.init()
    for i = 1, 100 do
        table.insert(fishies, Fish(world))
    end
end

function playdate.update()
    gfx.clear()
    
    if not player then
        -- Initialize Game
        camera = Camera(Vector3(0, 0, -10), Vector3(0, 0, 0))
        world = World(400) -- Cube radius
        player = Player(camera, world)
    end

    player:update()
    world:draw(camera)
    
    for _, fish in ipairs(fishies) do
        fish:update()
        fish:draw(camera)
    end

    -- Debug Info
    -- gfx.drawText("FPS: " .. playdate.getFPS(), 5, 5)
end
