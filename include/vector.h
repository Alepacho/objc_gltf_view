#ifndef VECTOR_H
#define VECTOR_H
#import "base/all.h"

#include "cglm/cglm.h"

typedef enum {
	VT_VECTOR3,
	VT_VECTOR4,
} VectorType;

@protocol Vector

// I can use isMemberOf or whatever but yeah
// C-like style rulez
- (const VectorType)type;

@end

@interface Vector3 : BaseObject <Vector> {
	vec3 m_data;
}

- (vec3*)data;

- (const float)x;
- (const float)y;
- (const float)z;

- (void)setX:(const float)value;
- (void)setY:(const float)value;
- (void)setZ:(const float)value;

- (void)setX:(const float)x setY:(const float)y;
- (void)setX:(const float)x setY:(const float)y setZ:(const float)z;

@end

@interface Vector4 : BaseObject <Vector> {
	vec4 m_data;
}

- (vec4*)data;

- (const float)x;
- (const float)y;
- (const float)z;
- (const float)w;

- (void)setX:(const float)value;
- (void)setY:(const float)value;
- (void)setZ:(const float)value;
- (void)setW:(const float)value;

- (void)setX:(const float)x setY:(const float)y;
- (void)setX:(const float)x setY:(const float)y setZ:(const float)z;
- (void)setX:(const float)x setY:(const float)y setZ:(const float)z setW:(const float)w;

@end

#endif // VECTOR_H
