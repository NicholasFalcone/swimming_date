#include "Fish.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

static LCDBitmap* fish_sprites[FISH_VARIANTS] = {0};

static float random_range(float min_value, float max_value) {
    const float random_unit = (float)rand() / (float)RAND_MAX;
    return min_value + random_unit * (max_value - min_value);
}

void fish_load_assets(PlaydateAPI* pd) {
    const char* out_error = NULL;
    for (int i = 0; i < FISH_VARIANTS; ++i) {
        if (fish_sprites[i] != NULL) {
            continue;
        }

        char path[32];
        snprintf(path, sizeof(path), "Assets/fish_v%d", i + 1);
        fish_sprites[i] = pd->graphics->loadBitmap(path, &out_error);
    }
}

void fish_init(Fish* fish, Vector3 position, World* world) {
    fish->position = position;
    fish->world = world;

    fish->velocity = vector3_normalize(vector3_create(
        random_range(-1.0f, 1.0f),
        random_range(-1.0f, 1.0f),
        random_range(-1.0f, 1.0f)
    ));

    fish->velocity = vector3_mul(fish->velocity, random_range(0.1f, 0.3f));
    fish->speed = random_range(0.2f, 0.5f);
    fish->wobble_phase = random_range(0.0f, 6.283185f);
    fish->turn_timer = random_range(2.0f, 5.0f);
    fish->size = random_range(0.8f, 1.3f);
    fish->accumulated_dt = 0.0f;
    fish->sprite_index = rand() % FISH_VARIANTS;
}

void fish_update(Fish* fish, float dt) {
    fish->accumulated_dt += dt;

    if (fish->accumulated_dt >= 1.0f) {
        fish->turn_timer -= fish->accumulated_dt;

        if (fish->turn_timer <= 0.0f) {
            fish->turn_timer = random_range(2.0f, 6.0f);

            const Vector3 turn = vector3_create(
                random_range(-0.3f, 0.3f),
                random_range(-0.3f, 0.3f),
                random_range(-0.3f, 0.3f)
            );

            fish->velocity = vector3_add(fish->velocity, turn);
            fish->velocity = vector3_mul(vector3_normalize(fish->velocity), fish->speed);
        }

        const float limit = (float)fish->world->size - 30.0f;
        const float bounce = 0.5f;

        if (fish->position.x > limit) {
            fish->position.x = limit;
            fish->velocity.x = -fabsf(fish->velocity.x) * bounce;
        } else if (fish->position.x < -limit) {
            fish->position.x = -limit;
            fish->velocity.x = fabsf(fish->velocity.x) * bounce;
        }

        if (fish->position.y > limit) {
            fish->position.y = limit;
            fish->velocity.y = -fabsf(fish->velocity.y) * bounce;
        } else if (fish->position.y < -limit) {
            fish->position.y = -limit;
            fish->velocity.y = fabsf(fish->velocity.y) * bounce;
        }

        if (fish->position.z > limit) {
            fish->position.z = limit;
            fish->velocity.z = -fabsf(fish->velocity.z) * bounce;
        } else if (fish->position.z < -limit) {
            fish->position.z = -limit;
            fish->velocity.z = fabsf(fish->velocity.z) * bounce;
        }

        fish->accumulated_dt = 0.0f;
    }

    fish->position = vector3_add(fish->position, vector3_mul(fish->velocity, dt * 40.0f));
}

void fish_draw(const Fish* fish, const Camera* camera, PlaydateAPI* pd) {
    ProjectedPoint projected;
    if (!camera_project(camera, fish->position, &projected)) {
        return;
    }

    const float elapsed_seconds = (float)pd->system->getCurrentTimeMilliseconds() / 1000.0f;
    const float wobble_y = sinf(elapsed_seconds * 5.0f + fish->wobble_phase) * 2.0f;
    const float draw_scale = projected.scale * 0.05f * fish->size;

    LCDBitmap* sprite = fish_sprites[fish->sprite_index];
    if (sprite != NULL && draw_scale > 0.0f) {
        int width;
        int height;
        pd->graphics->getBitmapData(sprite, &width, &height, NULL, NULL, NULL);

        const float offset_x = ((float)width * draw_scale) * 0.5f;
        const float offset_y = ((float)height * draw_scale) * 0.5f;

        pd->graphics->drawScaledBitmap(
            sprite,
            (int)(projected.x - offset_x),
            (int)(projected.y + wobble_y - offset_y),
            draw_scale,
            draw_scale
        );
        return;
    }

    float radius = projected.scale * 2.0f * fish->size;
    if (radius < 2.0f) {
        radius = 2.0f;
    }

    pd->graphics->fillEllipse(
        (int)(projected.x - radius),
        (int)(projected.y - radius),
        (int)(radius * 2.0f),
        (int)(radius * 2.0f),
        0.0f,
        0.0f,
        kColorBlack
    );
}
