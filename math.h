// This file is added here because raymath.h include math.h, but clang doesn't come with it and it makes the bindings generation fail.
// It is possible that raylib starts using more functions from math.h, they must be declared here then

float floorf(float);
float fabsf(float);
float fmaxf(float, float);
float sqrtf(float);
float atan2f(float, float);
float fminf(float, float);
float cosf(float);
float sinf(float);
double tan(double);
float acosf(float);
float asinf(float);