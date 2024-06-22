#ifndef MATERIAL_H
#define MATERIAL_H
#import "base/all.h"

typedef enum {
	MAM_OPAQUE,
	MAM_MASK,
	MAM_BLEND
} MaterialAlphaMode;

@class Texture;

@interface Material : BaseObject {
	MaterialAlphaMode m_alpha_mode;
	// MaterialFactors m_factors;

	float m_albedo_color[4];
	float m_metallic_factor;
	float m_roughness_factor;

	Texture* m_albedo;
}

- (Texture*)albedo;
- (void)setAlbedo:(Texture*)value;

- (float*)albedoColor;
- (void)setAlbedoColor:(float[4])value;

- (void)bind;

@end

#endif // MATERIAL_H
