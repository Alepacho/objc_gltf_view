#import "matrix.h"

@implementation Matrix

- (id)init {
	if (self = [super init]) {
		glm_mat4_identity(m_data);
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (void)create:(mat4*)data {
	glm_mat4_copy(*data, m_data);
}

- (mat4*)data {
	return &m_data;
}

@end
