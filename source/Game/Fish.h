#ifndef FISH_H
#define FISH_H

#include <pd_api.h>

#include "Core/Camera.h"
#include "World.h"

#define FISH_VARIANTS 4

typedef struct {
    Vector3 position;
    Vector3 velocity;
    World* world;
    float speed;
    float wobble_phase;
    float turn_timer;
    float size;
    float accumulated_dt;
    int sprite_index;
} Fish;

void fish_load_assets(PlaydateAPI* pd);
void fish_init(Fish* fish, Vector3 position, World* world);
void fish_update(Fish* fish, float dt);
void fish_draw(const Fish* fish, const Camera* camera, PlaydateAPI* pd);

#endif
