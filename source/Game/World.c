#include "World.h"

#include <math.h>
#include <stdlib.h>

static float random_range(float min_value, float max_value) {
    const float random_unit = (float)rand() / (float)RAND_MAX;
    return min_value + random_unit * (max_value - min_value);
}

static void world_update_surface(World* world, float elapsed_seconds, float dt) {
    world->accumulated_wave_dt += dt;

    if (world->accumulated_wave_dt < 1.0f) {
        return;
    }

    for (int i = 0; i < WORLD_SURFACE_POINT_COUNT; ++i) {
        SurfacePoint* point = &world->surface_points[i];

        const float wave_y = sinf(point->base.x * 0.03f + elapsed_seconds * 2.5f) * 8.0f
                           + cosf(point->base.z * 0.04f + elapsed_seconds * 2.0f) * 8.0f;

        const float refract_x = sinf(point->base.z * 0.05f + elapsed_seconds * 3.0f) * 12.0f;
        const float refract_z = cosf(point->base.x * 0.05f + elapsed_seconds * 2.5f) * 12.0f;

        point->current.x = point->base.x + refract_x;
        point->current.y = point->base.y + wave_y;
        point->current.z = point->base.z + refract_z;
    }

    world->accumulated_wave_dt = 0.0f;
}

void world_init(World* world, int size) {
    world->size = size;
    world->accumulated_wave_dt = 0.0f;

    const float s = (float)size;

    world->vertices[0] = vector3_create(-s, -s, -s);
    world->vertices[1] = vector3_create(s, -s, -s);
    world->vertices[2] = vector3_create(s, s, -s);
    world->vertices[3] = vector3_create(-s, s, -s);
    world->vertices[4] = vector3_create(-s, -s, s);
    world->vertices[5] = vector3_create(s, -s, s);
    world->vertices[6] = vector3_create(s, s, s);
    world->vertices[7] = vector3_create(-s, s, s);

    const int edges[WORLD_EDGE_COUNT][2] = {
        {0, 1}, {1, 2}, {2, 3}, {3, 0},
        {4, 5}, {5, 6}, {6, 7}, {7, 4},
        {0, 4}, {1, 5}, {2, 6}, {3, 7}
    };

    for (int i = 0; i < WORLD_EDGE_COUNT; ++i) {
        world->edges[i][0] = edges[i][0];
        world->edges[i][1] = edges[i][1];
    }

    const float step_x = (s * 2.0f) / (float)WORLD_SURFACE_ROWS;
    const float step_z = (s * 2.0f) / (float)WORLD_SURFACE_COLS;
    int index = 0;

    for (int x = 0; x <= WORLD_SURFACE_ROWS; ++x) {
        for (int z = 0; z <= WORLD_SURFACE_COLS; ++z) {
            const float point_x = -s + (float)x * step_x;
            const float point_z = -s + (float)z * step_z;
            const Vector3 point = vector3_create(point_x, s, point_z);
            world->surface_points[index].base = point;
            world->surface_points[index].current = point;
            ++index;
        }
    }

    for (int i = 0; i < WORLD_PARTICLE_COUNT; ++i) {
        world->particles[i] = vector3_create(
            random_range(-s, s),
            random_range(-s, s),
            random_range(-s, s)
        );
    }
}

void world_draw(World* world, const Camera* camera, PlaydateAPI* pd, float dt) {
    const float elapsed_seconds = (float)pd->system->getCurrentTimeMilliseconds() / 1000.0f;
    world_update_surface(world, elapsed_seconds, dt);

    pd->graphics->setLineCapStyle(kLineCapStyleRound);

    ProjectedPoint projected_vertices[WORLD_VERTEX_COUNT];
    int is_visible[WORLD_VERTEX_COUNT];

    for (int i = 0; i < WORLD_VERTEX_COUNT; ++i) {
        is_visible[i] = camera_project(camera, world->vertices[i], &projected_vertices[i]);
    }

    for (int i = 0; i < WORLD_EDGE_COUNT; ++i) {
        const int a = world->edges[i][0];
        const int b = world->edges[i][1];

        if (is_visible[a] && is_visible[b]) {
            pd->graphics->drawLine(
                (int)projected_vertices[a].x,
                (int)projected_vertices[a].y,
                (int)projected_vertices[b].x,
                (int)projected_vertices[b].y,
                2,
                kColorBlack
            );
        }
    }

    int idx = 0;
    const int cols = WORLD_SURFACE_COLS + 1;

    for (int x = 0; x <= WORLD_SURFACE_ROWS; ++x) {
        for (int z = 0; z <= WORLD_SURFACE_COLS; ++z) {
            ProjectedPoint current_projection;
            if (camera_project(camera, world->surface_points[idx].current, &current_projection)) {
                if (z < WORLD_SURFACE_COLS) {
                    ProjectedPoint next_projection_z;
                    if (camera_project(camera, world->surface_points[idx + 1].current, &next_projection_z)) {
                        pd->graphics->drawLine(
                            (int)current_projection.x,
                            (int)current_projection.y,
                            (int)next_projection_z.x,
                            (int)next_projection_z.y,
                            1,
                            kColorBlack
                        );
                    }
                }

                if (x < WORLD_SURFACE_ROWS) {
                    ProjectedPoint next_projection_x;
                    if (camera_project(camera, world->surface_points[idx + cols].current, &next_projection_x)) {
                        pd->graphics->drawLine(
                            (int)current_projection.x,
                            (int)current_projection.y,
                            (int)next_projection_x.x,
                            (int)next_projection_x.y,
                            1,
                            kColorBlack
                        );
                    }
                }
            }
            ++idx;
        }
    }

    for (int i = 0; i < WORLD_PARTICLE_COUNT; ++i) {
        ProjectedPoint particle_projection;
        if (!camera_project(camera, world->particles[i], &particle_projection)) {
            continue;
        }

        float radius = 200.0f / particle_projection.z;
        if (radius < 1.0f) {
            radius = 1.0f;
        }
        if (radius > 8.0f) {
            radius = 8.0f;
        }

        pd->graphics->fillEllipse(
            (int)(particle_projection.x - radius),
            (int)(particle_projection.y - radius),
            (int)(radius * 2.0f),
            (int)(radius * 2.0f),
            0.0f,
            0.0f,
            kColorBlack
        );
    }

    const float limit = (float)world->size - 5.0f;
    if (fabsf(camera->position.x) >= limit || fabsf(camera->position.y) >= limit || fabsf(camera->position.z) >= limit) {
        pd->graphics->drawText("WALL HIT", 8, kUTF8Encoding, 5, 220);
    }

}
