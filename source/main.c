#include <pd_api.h>

#include <stdlib.h>

#include "Core/Camera.h"
#include "Core/Vector3.h"
#include "Game/Fish.h"
#include "Game/Player.h"
#include "Game/World.h"

#define FISH_COUNT 10

static PlaydateAPI* playdate = NULL;

typedef struct {
    Camera camera;
    World world;
    Player player;
    Fish fish[FISH_COUNT];
    uint32_t last_time_ms;
} GameState;

static GameState game;

static float random_range(float min_value, float max_value) {
    const float random_unit = (float)rand() / (float)RAND_MAX;
    return min_value + random_unit * (max_value - min_value);
}

static int update(void* userdata) {
    (void)userdata;

    playdate->graphics->clear(kColorWhite);

    const uint32_t now_ms = playdate->system->getCurrentTimeMilliseconds();
    float dt = (float)(now_ms - game.last_time_ms) / 1000.0f;
    game.last_time_ms = now_ms;

    if (dt > 0.1f) {
        dt = 0.1f;
    }

    player_update(&game.player, playdate);
    world_draw(&game.world, &game.camera, playdate, dt);

    for (int i = 0; i < FISH_COUNT; ++i) {
        fish_update(&game.fish[i], dt);
        fish_draw(&game.fish[i], &game.camera, playdate);
    }

    return 1;
}

int eventHandler(PlaydateAPI* pd, PDSystemEvent event, uint32_t arg) {
    (void)arg;

    if (event == kEventInit) {
        playdate = pd;
        srand((unsigned int)pd->system->getSecondsSinceEpoch(NULL));

        camera_init(&game.camera, vector3_create(0.0f, 0.0f, -10.0f), vector3_create(0.0f, 0.0f, 0.0f));
        world_init(&game.world, 400);
        player_init(&game.player, &game.camera, &game.world);

        fish_load_assets(pd);

        for (int i = 0; i < FISH_COUNT; ++i) {
            const float bound = (float)game.world.size - 20.0f;
            fish_init(
                &game.fish[i],
                vector3_create(
                    random_range(-bound, bound),
                    random_range(-bound, bound),
                    random_range(-bound, bound)
                ),
                &game.world
            );
        }

        game.last_time_ms = pd->system->getCurrentTimeMilliseconds();
        pd->system->setUpdateCallback(update, NULL);
    }

    return 0;
}
