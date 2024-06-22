#import "animation/channel.h"

@implementation AnimationChannel

- (id)init {
	if (self = [super init]) {
		m_sampler = nil;
		m_type = AT_TRANSLATION;
		m_target = nil;

		// glm_mat4_identity(m_local);
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (AnimationSampler*)sampler {
	return m_sampler;
}

- (void)setSampler:(AnimationSampler*)value {
	m_sampler = value;
}
- (const AnimationType)type {
	return m_type;
}
- (void)setType:(const AnimationType)value {
	m_type = value;
}

- (Node*)target {
	return m_target;
}
- (void)setTarget:(Node*)value {
	m_target = value;
}

// - (mat4*)local {
// 	return &m_local;
// }
// - (void)setLocal:(mat4*)value {
// 	glm_mat4_copy(*value, m_local);
// }
- (const Size)index {
	return m_index;
}
- (void)setIndex:(const Size)value {
	m_index = value;
}

- (void)create:(AnimationSampler*)sampler type:(AnimationType)type target:(Node*)target {
	m_sampler = sampler;
	m_type = type;
	m_target = target;
}

@end
