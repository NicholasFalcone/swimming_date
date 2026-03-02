#ifndef WORLD_H
#define WORLD_H

#include <pd_api.h>

#include "Core/Camera.h"

#define WORLD_VERTEX_COUNT 8
#define WORLD_EDGE_COUNT 12
#define WORLD_SURFACE_ROWS 4
#define WORLD_SURFACE_COLS 4
#define WORLD_SURFACE_POINT_COUNT ((WORLD_SURFACE_ROWS + 1) * (WORLD_SURFACE_COLS + 1))
#define WORLD_PARTICLE_COUNT 60

typedef struct {
    Vector3 base;
    Vector3 current;
} SurfacePoint;

typedef struct {
    int size;
    Vector3 vertices[WORLD_VERTEX_COUNT];
    int edges[WORLD_EDGE_COUNT][2];
    SurfacePoint surface_points[WORLD_SURFACE_POINT_COUNT];
    Vector3 particles[WORLD_PARTICLE_COUNT];
    float accumulated_wave_dt;
} World;

void world_init(World* world, int size);
void world_draw(World* world, const Camera* camera, PlaydateAPI* pd, float dt);

#endif
