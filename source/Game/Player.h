#ifndef PLAYER_H
#define PLAYER_H

#include <pd_api.h>

#include "Core/Camera.h"
#include "World.h"

typedef struct {
    Camera* camera;
    World* world;
    Vector3 velocity;
    float acceleration;
    float friction;
    float look_speed;
    float wobble_speed;
    float wobble_amount;
} Player;

void player_init(Player* player, Camera* camera, World* world);
void player_update(Player* player, PlaydateAPI* pd);

#endif
