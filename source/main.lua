import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "Core/Vector3"
import "Core/Camera"
import "Game/World"
import "Game/Player"

local gfx = playdate.graphics

-- Global Game State
player = nil
world = nil
camera = nil

function playdate.update()
    gfx.clear()
    
    if not player then
        -- Initialize Game
        camera = Camera(Vector3(0, 0, -10), Vector3(0, 0, 0))
        world = World(200) -- Cube radius
        player = Player(camera, world)
    end

    player:update()
    world:draw(camera)
    
    -- Debug Info
    -- gfx.drawText("FPS: " .. playdate.getFPS(), 5, 5)
end
