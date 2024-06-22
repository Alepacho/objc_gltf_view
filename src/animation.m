#import "animation.h"

#import "main.h"
#import "node.h"
#import "shader.h"

@implementation Animation

// @private

- (void)destroyChannels {
	if (!m_channels) return;
	[m_channels dealloc];
	m_channels = nil;
}

- (void)destroySamplers {
	if (!m_samplers) return;
	[m_samplers dealloc];
	m_samplers = nil;
}

- (float)interpolateScalar:(const AnimationSampler*)sampler time:(const float)currentTime {
	// const Size count = [sampler timestampsSize];
	// const float* timestamps = [sampler timestamps];
	// float* data = [sampler data];

	// for (Size i = 0; i < count - 1; ++i) {
	// 	if (currentTime < timestamps[i + 1]) {
	// 		const float t = (currentTime - timestamps[i]) / (timestamps[i + 1] - timestamps[i]);
	// 		return glm_lerp(data[i], data[i + 1], t);
	// 		// return data[i + 1];
	// 	}
	// }
	// return data[count - 1];
	return 0;
}

// same as below but only one timestamp
- (const float)getTimestepFactor:(const AnimationSampler*)sampler time:(const float)time end:(Size)end {
	const float* timestamps = [sampler timestamps];
	const float t = (time) / (timestamps[end]);
	return t;
}

- (const float)getTimestepFactor:(const AnimationSampler*)sampler {
	const float* timestamps = [sampler timestamps];
	const float s = timestamps[m_start_index];
	const float e = timestamps[m_end_index];
	float t;
	if (m_start_index < m_end_index) {
		t = fmaxf(0.0f, m_time - s) / (e - s);
	} else {
		t = fmaxf(0.0f, m_time - (s - m_end_time)) / (e - (s - m_end_time));
	}
	return t;
}

- (void)interpolateVector:(const AnimationSampler*)sampler result:(vec3)result {
	const Array<Vector>* data = [sampler data];
	vec3* s = [(Vector3*)[data getByIndex:m_start_index] data];
	vec3* e = [(Vector3*)[data getByIndex:m_end_index] data];
	glm_vec3_lerp(*s, *e, m_factor, result);
}

- (void)interpolateQuat:(const AnimationSampler*)sampler result:(vec4)result {
	const Array<Vector>* data = [sampler data];
	vec4* s = [(Vector4*)[data getByIndex:m_start_index] data];
	vec4* e = [(Vector4*)[data getByIndex:m_end_index] data];
	glm_quat_slerp(*s, *e, m_factor, result);
}

- (void)processChannel:(const AnimationChannel*)channel {
	const AnimationSampler* sampler = [channel sampler];

	const Size count = [sampler timestampsSize];
	for (Size i = 0; i < count - 1; ++i) {
		if (m_time < [sampler timestamps][i + 1]) {
			m_start_index = i;
			m_end_index = i + 1;
			m_factor = [self getTimestepFactor:sampler];

			switch ([sampler interpolation]) {
				case AI_LINEAR: {
					[self processLinearAnimation:channel];
				} break;
				case AI_STEP: {
					[System fatal:"step"];
				} break;
				case AI_CUBIC_SPLINE: {
					[System fatal:"cubic"];
				} break;
				default: [System fatal:"Unknown interpolation type!"];
			}

			return;
		}
	}

	m_start_index = count - 1;
	m_end_index = count - 1;

	m_factor = [self getTimestepFactor:sampler];
	// use step instead
	switch ([sampler interpolation]) {
		case AI_LINEAR: {
			[self processLinearAnimation:channel];
		} break;
		case AI_STEP: {
			[System fatal:"step"];
		} break;
		case AI_CUBIC_SPLINE: {
			[System fatal:"cubic"];
		} break;
		default: [System fatal:"Unknown interpolation type!"];
	}
}

- (void)processLinearAnimation:(const AnimationChannel*)channel {
	const AnimationSampler* sampler = [channel sampler];
	const Node* target = [channel target];

	switch ([channel type]) {
		case AT_TRANSLATION: {
			vec3 result;
			[self interpolateVector:sampler result:result];
			glm_vec3_copy(result, *[target translation]);
		} break;
		case AT_ROTATION: {
			vec4 result;
			[self interpolateQuat:sampler result:result];
			glm_quat_copy(result, *[target rotation]);
		} break;
		case AT_SCALE: {
			vec3 result;
			[self interpolateVector:sampler result:result];
			glm_vec3_copy(result, *[target scale]);
		} break;
		case AT_WEIGHTS: {
			[System fatal:"Weights..."];
		} break;
	}
}

// @public

- (id)init {
	if (self = [super init]) {
		m_name = [String new];
		m_samplers = nil;
		m_channels = nil;

		//
		for (Size i = 0; i < MAX_JOINT_MATRICES; i++) {
			// mat4* ptr = &m_joint_matrices[i];
			// glm_mat4_identity(*ptr);
			glm_mat4_identity(m_joint_matrices[i]);
		}

		m_time = 0.0f;
		m_factor = 0.0f;
		m_start_index = 0;
		m_end_index = 0;
		// m_speed = 0.1f;

		m_start_time = FLT_MAX;
		m_end_time = FLT_MIN;
	}
	return self;
}

- (void)dealloc {
	[self destroy];
	if (m_name) {
		[m_name dealloc];
		m_name = nil;
	}
	[super dealloc];
}

- (String*)name {
	return m_name;
}

- (Array<AnimationSampler*>*)samplers {
	return m_samplers;
}

- (void)setSamplers:(Array<AnimationSampler*>*)value {
	[self destroySamplers];
	m_samplers = value;
}

- (Array<AnimationChannel*>*)channels {
	return m_channels;
}

- (void)setChannels:(Array<AnimationChannel*>*)value {
	[self destroyChannels];
	m_channels = value;
}

- (const float)minTime {
	return m_start_time;
}
- (void)setMinTime:(const float)value {
	m_start_time = value;
}
- (const float)maxTime {
	return m_end_time;
}
- (void)setMaxTime:(const float)value {
	m_end_time = value;
}

// - (const float)speed {
// 	return m_speed;
// }
// - (void)setSpeed:(const float)value {
// 	m_speed = value;
// }

- (void)setJointMatrix:(Size)index matrix:(mat4*)value {
	mat4* result = &m_joint_matrices[index];
	glm_mat4_copy(*value, *result);
}
- (mat4*)jointMatrices {
	return m_joint_matrices;
}
- (void)passJointMatrices:(const Shader*)shader {
	[shader set:"u_joint_matrices" mat4:m_joint_matrices count:MAX_JOINT_MATRICES];
}

- (void)destroy {
	[self destroyChannels];
	[self destroySamplers];
}

// - (void)start {
// 	for (Size i = 0; i < MAX_JOINT_MATRICES; i++) {
// 		glm_mat4_identity(m_joint_matrices[i]);
// 	}
// }

- (void)update:(const float)duration {
	if (!m_channels) return;

	m_time = fmodf(duration, m_end_time);
	if (m_time < 0) m_time += m_end_time;

	for (Size i = 0; i < [m_channels count]; ++i) {
		[self processChannel:[m_channels getByIndex:i]];
	}
}

@end
