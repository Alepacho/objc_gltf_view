#import "skin.h"

@implementation Skin

// @private

- (void)destroyJoints {
	if (!m_joints) return;
	[m_joints clear:NO];
	[m_joints dealloc];
	m_joints = nil;
}

- (void)destroyMatrices {
	if (!m_inverse_bind_matrices) return;
	free(m_inverse_bind_matrices);
	m_inverse_bind_matrices = nil;
	m_inverse_bind_matrices_size = 0;
}

// @public

- (id)init {
	if (self = [super init]) {
		m_joints = nil;
		m_inverse_bind_matrices = nil;
		m_inverse_bind_matrices_size = 0;
		m_skeleton = nil;
	}
	return self;
}

- (void)dealloc {
	[self destroy];
	[super dealloc];
}

- (Array<Node*>*)joints {
	return m_joints;
}
- (void)setJoints:(Array<Node*>*)value {
	[self destroyJoints];
	m_joints = value;
}

- (mat4*)inverseBindMatrices {
	return m_inverse_bind_matrices;
}
- (Size)inverseBindMatricesSize {
	return m_inverse_bind_matrices_size;
}
- (void)setInverseBindMatrices:(mat4*)value size:(Size)size {
	[self destroyMatrices];
	m_inverse_bind_matrices = malloc(size * sizeof(mat4));
	memcpy(m_inverse_bind_matrices, value, size * sizeof(mat4));
	m_inverse_bind_matrices_size = size;
}

- (Node*)skeleton {
	return m_skeleton;
}
- (void)setSkeleton:(Node*)value {
	m_skeleton = value;
}

- (void)destroy {
	[self destroyJoints];
	[self destroyMatrices];
}

@end
