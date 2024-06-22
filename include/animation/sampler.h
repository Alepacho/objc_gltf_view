#ifndef ANIMATION_SAMPLER_H
#define ANIMATION_SAMPLER_H
#import "base/all.h"

#include "vector.h"

typedef enum {
	AI_LINEAR,
	AI_STEP,
	AI_CUBIC_SPLINE,
} AnimationInterpolation;

// array of keys, basically
@interface AnimationSampler : BaseObject {
	// * default: AI_LINEAR
	AnimationInterpolation m_interpolation;

	// input
	float* m_timestamps;
	Size m_timestamps_size;

	// output
	// TODO: use class inheritance instead

	// float* m_data;
	// Size m_data_size;
	Array<Vector>* m_data;
}

- (const AnimationInterpolation)interpolation;
- (void)setInterpolation:(const AnimationInterpolation)value;
- (float*)timestamps;
- (Size)timestampsSize;
- (void)setTimestamps:(float*)value size:(Size)size;
// - (float*)data;
// - (Size)dataSize;
// - (void)setData:(float*)value size:(Size)size;
- (Array<Vector>*)data;

- (void)destroy;

@end

#endif // ANIMATION_SAMPLER_H
