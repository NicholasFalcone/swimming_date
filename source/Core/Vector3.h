#ifndef VECTOR3_H
#define VECTOR3_H

typedef struct {
    float x;
    float y;
    float z;
} Vector3;

Vector3 vector3_create(float x, float y, float z);
Vector3 vector3_add(Vector3 a, Vector3 b);
Vector3 vector3_sub(Vector3 a, Vector3 b);
Vector3 vector3_mul(Vector3 v, float scalar);
Vector3 vector3_div(Vector3 v, float scalar);
float vector3_dot(Vector3 a, Vector3 b);
Vector3 vector3_cross(Vector3 a, Vector3 b);
float vector3_magnitude(Vector3 v);
Vector3 vector3_normalize(Vector3 v);
Vector3 vector3_rotate_x(Vector3 v, float angle);
Vector3 vector3_rotate_y(Vector3 v, float angle);
Vector3 vector3_rotate_z(Vector3 v, float angle);

#endif
