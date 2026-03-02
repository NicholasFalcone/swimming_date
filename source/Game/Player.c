#include "Player.h"

#include <math.h>

void player_init(Player* player, Camera* camera, World* world) {
    player->camera = camera;
    player->world = world;
    player->velocity = vector3_create(0.0f, 0.0f, 0.0f);
    player->acceleration = 1.0f;
    player->friction = 0.95f;
    player->look_speed = 0.05f;
    player->wobble_speed = 0.002f;
    player->wobble_amount = 0.02f;
}

void player_update(Player* player, PlaydateAPI* pd) {
    const uint32_t current_time_ms = pd->system->getCurrentTimeMilliseconds();
    player->camera->rotation.z = sinf((float)current_time_ms * player->wobble_speed) * player->wobble_amount;

    PDButtons current;
    PDButtons pushed;
    PDButtons released;
    pd->system->getButtonState(&current, &pushed, &released);

    if ((current & kButtonUp) != 0) {
        player->camera->rotation.x -= player->look_speed;
    } else if ((current & kButtonDown) != 0) {
        player->camera->rotation.x += player->look_speed;
    }

    if ((current & kButtonLeft) != 0) {
        player->camera->rotation.y -= player->look_speed;
    } else if ((current & kButtonRight) != 0) {
        player->camera->rotation.y += player->look_speed;
    }

    const float max_pitch = 1.553343f;
    if (player->camera->rotation.x > max_pitch) {
        player->camera->rotation.x = max_pitch;
    }
    if (player->camera->rotation.x < -max_pitch) {
        player->camera->rotation.x = -max_pitch;
    }

    const float crank_change = pd->system->getCrankChange();
    if (crank_change != 0.0f) {
        const float impulse = player->acceleration * (crank_change / 5.0f);
        const Vector3 forward = camera_get_forward_vector(player->camera);
        player->velocity = vector3_add(player->velocity, vector3_mul(forward, impulse));
    }

    player->velocity = vector3_mul(player->velocity, player->friction);

    if (vector3_magnitude(player->velocity) < 0.01f) {
        player->velocity = vector3_create(0.0f, 0.0f, 0.0f);
    }

    if (vector3_magnitude(player->velocity) > 0.0f) {
        Vector3 new_position = vector3_add(player->camera->position, player->velocity);

        if (player->world != NULL) {
            const float limit = (float)player->world->size - 5.0f;

            if (new_position.x > limit) {
                new_position.x = limit;
                player->velocity.x = 0.0f;
            } else if (new_position.x < -limit) {
                new_position.x = -limit;
                player->velocity.x = 0.0f;
            }

            if (new_position.y > limit) {
                new_position.y = limit;
                player->velocity.y = 0.0f;
            } else if (new_position.y < -limit) {
                new_position.y = -limit;
                player->velocity.y = 0.0f;
            }

            if (new_position.z > limit) {
                new_position.z = limit;
                player->velocity.z = 0.0f;
            } else if (new_position.z < -limit) {
                new_position.z = -limit;
                player->velocity.z = 0.0f;
            }
        }

        player->camera->position = new_position;
    }
}
