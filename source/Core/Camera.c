#include "Camera.h"

void camera_init(Camera* camera, Vector3 position, Vector3 rotation) {
    camera->position = position;
    camera->rotation = rotation;
    camera->focal_length = 300.0f;
    camera->center_x = 200.0f;
    camera->center_y = 120.0f;
}

Vector3 camera_transform(const Camera* camera, Vector3 point) {
    Vector3 relative = vector3_sub(point, camera->position);
    relative = vector3_rotate_y(relative, -camera->rotation.y);
    relative = vector3_rotate_x(relative, -camera->rotation.x);
    relative = vector3_rotate_z(relative, -camera->rotation.z);
    return relative;
}

int camera_project(const Camera* camera, Vector3 point, ProjectedPoint* out_point) {
    const Vector3 transformed = camera_transform(camera, point);

    if (transformed.z <= 1.0f) {
        return 0;
    }

    const float scale = camera->focal_length / transformed.z;

    out_point->x = transformed.x * scale + camera->center_x;
    out_point->y = transformed.y * scale * -1.0f + camera->center_y;
    out_point->scale = scale;
    out_point->z = transformed.z;

    return 1;
}

Vector3 camera_get_forward_vector(const Camera* camera) {
    Vector3 value = vector3_create(0.0f, 0.0f, 1.0f);
    value = vector3_rotate_x(value, camera->rotation.x);
    value = vector3_rotate_y(value, camera->rotation.y);
    return value;
}

Vector3 camera_get_right_vector(const Camera* camera) {
    Vector3 value = vector3_create(1.0f, 0.0f, 0.0f);
    value = vector3_rotate_x(value, camera->rotation.x);
    value = vector3_rotate_y(value, camera->rotation.y);
    return value;
}

Vector3 camera_get_up_vector(const Camera* camera) {
    Vector3 value = vector3_create(0.0f, 1.0f, 0.0f);
    value = vector3_rotate_x(value, camera->rotation.x);
    value = vector3_rotate_y(value, camera->rotation.y);
    return value;
}
