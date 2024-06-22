#ifndef ANIMATION_H
#define ANIMATION_H
#import "base/all.h"

#import "animation/channel.h"
#import "animation/sampler.h"

#include "cglm/cglm.h"

// TODO: move to Skin class
#define MAX_JOINT_MATRICES 128

@class Shader;

@interface Animation : BaseObject {
	String* m_name;
	Array<AnimationSampler*>* m_samplers;
	Array<AnimationChannel*>* m_channels;

	float m_start_time;
	float m_end_time;
	// float m_speed;
	float m_time; // current time
	float m_factor;
	int m_start_index;
	int m_end_index;

	mat4 m_joint_matrices[MAX_JOINT_MATRICES];
}

- (String*)name;

- (Array<AnimationSampler*>*)samplers;
- (void)setSamplers:(Array<AnimationSampler*>*)value;
- (Array<AnimationChannel*>*)channels;
- (void)setChannels:(Array<AnimationChannel*>*)value;

- (const float)minTime;
- (void)setMinTime:(const float)value;
- (const float)maxTime;
- (void)setMaxTime:(const float)value;

// - (const float)speed;
// - (void)setSpeed:(const float)value;

- (void)setJointMatrix:(Size)index matrix:(mat4*)value;
- (mat4*)jointMatrices;
- (void)passJointMatrices:(const Shader*)shader;

- (void)destroy;

// - (void)start;
- (void)update:(const float)duration;

@end

#endif // ANIMATION_H
