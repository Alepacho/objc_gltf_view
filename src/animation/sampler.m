#import "animation/sampler.h"

@implementation AnimationSampler

// @private

- (void)destroyTimestamps {
	if (!m_timestamps) return;
	free(m_timestamps);
	m_timestamps = nil;
	m_timestamps_size = 0;
}

// - (void)destroyData {
// 	if (!m_data) return;
// 	free(m_data);
// 	m_data = nil;
// 	m_data_size = 0;
// }

// @public

- (id)init {
	if (self = [super init]) {
		m_interpolation = AI_LINEAR;
		m_timestamps = nil;
		m_timestamps_size = 0;
		m_data = [Array<Vector> new];
		// m_data = nil;
		// m_data_size = 0;
	}
	return self;
}

- (void)dealloc {
	[self destroy];
	[m_data dealloc];
	m_data = nil;
	[super dealloc];
}

- (const AnimationInterpolation)interpolation {
	return m_interpolation;
}
- (void)setInterpolation:(const AnimationInterpolation)value {
	m_interpolation = value;
}

- (float*)timestamps {
	return m_timestamps;
}
- (Size)timestampsSize {
	return m_timestamps_size;
}
- (void)setTimestamps:(float*)value size:(Size)size {
	[self destroyTimestamps];
	m_timestamps = value;
	m_timestamps_size = size;
	// [System debug:"m_timestamps_size: %i", m_timestamps_size];
	// for (Size i = 0; i < m_timestamps_size; ++i) {
	// 	[System debug:"%04i. %f", m_timestamps[i]];
	// }
}

// - (float*)data {
// 	return m_data;
// }
// - (Size)dataSize {
// 	return m_data_size;
// }
// - (void)setData:(float*)value size:(Size)size {
// 	[self destroyData];
// 	m_data = value;
// 	m_data_size = size;
// 	// [System print:"data: "];
// 	// for (Size i = 0; i < size; i++) {
// 	// 	[System print:"%f ", m_data[i]];
// 	// }
// 	// [System println:""];
// }
- (Array<Vector>*)data {
	return m_data;
}

- (void)destroy {
	[self destroyTimestamps];
	// [self destroyData];
	[m_data clear];
}

@end
