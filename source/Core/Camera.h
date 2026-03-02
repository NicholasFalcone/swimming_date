#ifndef CAMERA_H
#define CAMERA_H

#include "Vector3.h"

typedef struct {
    float x;
    float y;
    float scale;
    float z;
} ProjectedPoint;

typedef struct {
    Vector3 position;
    Vector3 rotation;
    float focal_length;
    float center_x;
    float center_y;
} Camera;

void camera_init(Camera* camera, Vector3 position, Vector3 rotation);
Vector3 camera_transform(const Camera* camera, Vector3 point);
int camera_project(const Camera* camera, Vector3 point, ProjectedPoint* out_point);
Vector3 camera_get_forward_vector(const Camera* camera);
Vector3 camera_get_right_vector(const Camera* camera);
Vector3 camera_get_up_vector(const Camera* camera);

#endif
