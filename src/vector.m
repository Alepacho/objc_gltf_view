#import "vector.h"

@implementation Vector3

- (id)init {
	if (self = [super init]) {
		glm_vec3_zero(m_data);
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (const VectorType)type {
	return VT_VECTOR3;
}

- (vec3*)data {
	return &m_data;
}

- (const float)x {
	return m_data[0];
}
- (const float)y {
	return m_data[1];
}
- (const float)z {
	return m_data[2];
}

- (void)setX:(const float)value {
	m_data[0] = value;
}
- (void)setY:(const float)value {
	m_data[1] = value;
}
- (void)setZ:(const float)value {
	m_data[2] = value;
}

- (void)setX:(const float)x setY:(const float)y {
	m_data[0] = x;
	m_data[1] = y;
}
- (void)setX:(const float)x setY:(const float)y setZ:(const float)z {
	m_data[0] = x;
	m_data[1] = y;
	m_data[2] = z;
}

@end

@implementation Vector4

- (id)init {
	if (self = [super init]) {
		glm_vec4_zero(m_data);
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (const VectorType)type {
	return VT_VECTOR4;
}

- (vec4*)data {
	return &m_data;
}

- (const float)x {
	return m_data[0];
}
- (const float)y {
	return m_data[1];
}
- (const float)z {
	return m_data[2];
}
- (const float)w {
	return m_data[3];
}

- (void)setX:(const float)value {
	m_data[0] = value;
}
- (void)setY:(const float)value {
	m_data[1] = value;
}
- (void)setZ:(const float)value {
	m_data[2] = value;
}
- (void)setW:(const float)value {
	m_data[3] = value;
}

- (void)setX:(const float)x setY:(const float)y {
	m_data[0] = x;
	m_data[1] = y;
}
- (void)setX:(const float)x setY:(const float)y setZ:(const float)z {
	m_data[0] = x;
	m_data[1] = y;
	m_data[2] = z;
}
- (void)setX:(const float)x setY:(const float)y setZ:(const float)z setW:(const float)w {
	m_data[0] = x;
	m_data[1] = y;
	m_data[2] = z;
	m_data[3] = w;
}

@end
