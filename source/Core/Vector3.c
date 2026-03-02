#include "Vector3.h"

#include <math.h>

Vector3 vector3_create(float x, float y, float z) {
    Vector3 value = {x, y, z};
    return value;
}

Vector3 vector3_add(Vector3 a, Vector3 b) {
    return vector3_create(a.x + b.x, a.y + b.y, a.z + b.z);
}

Vector3 vector3_sub(Vector3 a, Vector3 b) {
    return vector3_create(a.x - b.x, a.y - b.y, a.z - b.z);
}

Vector3 vector3_mul(Vector3 v, float scalar) {
    return vector3_create(v.x * scalar, v.y * scalar, v.z * scalar);
}

Vector3 vector3_div(Vector3 v, float scalar) {
    return vector3_create(v.x / scalar, v.y / scalar, v.z / scalar);
}

float vector3_dot(Vector3 a, Vector3 b) {
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

Vector3 vector3_cross(Vector3 a, Vector3 b) {
    return vector3_create(
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x
    );
}

float vector3_magnitude(Vector3 v) {
    return sqrtf(v.x * v.x + v.y * v.y + v.z * v.z);
}

Vector3 vector3_normalize(Vector3 v) {
    const float magnitude = vector3_magnitude(v);
    if (magnitude > 0.0f) {
        return vector3_div(v, magnitude);
    }
    return vector3_create(0.0f, 0.0f, 0.0f);
}

Vector3 vector3_rotate_x(Vector3 v, float angle) {
    const float cosine = cosf(angle);
    const float sine = sinf(angle);

    return vector3_create(
        v.x,
        v.y * cosine - v.z * sine,
        v.y * sine + v.z * cosine
    );
}

Vector3 vector3_rotate_y(Vector3 v, float angle) {
    const float cosine = cosf(angle);
    const float sine = sinf(angle);

    return vector3_create(
        v.x * cosine + v.z * sine,
        v.y,
        -v.x * sine + v.z * cosine
    );
}

Vector3 vector3_rotate_z(Vector3 v, float angle) {
    const float cosine = cosf(angle);
    const float sine = sinf(angle);

    return vector3_create(
        v.x * cosine - v.y * sine,
        v.x * sine + v.y * cosine,
        v.z
    );
}
