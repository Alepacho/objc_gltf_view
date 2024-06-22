#ifndef ANIMATION_CHANNEL_H
#define ANIMATION_CHANNEL_H
#import "base/all.h"

typedef enum {
	AT_TRANSLATION, // vec3
	AT_ROTATION,	// vec4
	AT_SCALE,		// vec3
	AT_WEIGHTS,		// scalar (just float)
} AnimationType;

@class Node;
@class AnimationSampler;

//
@interface AnimationChannel : BaseObject {
	AnimationSampler* m_sampler;
	AnimationType m_type;
	Node* m_target;

	Size m_index;
}

- (AnimationSampler*)sampler;
- (void)setSampler:(AnimationSampler*)value;
- (const AnimationType)type;
- (void)setType:(const AnimationType)value;
- (Node*)target;
- (void)setTarget:(Node*)value;
- (const Size)index;
- (void)setIndex:(const Size)value;

- (void)create:(AnimationSampler*)sampler type:(AnimationType)type target:(Node*)target;

@end

#endif //