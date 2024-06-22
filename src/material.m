#import "material.h"

#import "shader.h"
#import "texture.h"

@implementation Material

- (id)init {
	if (self = [super init]) {
		m_albedo_color[0] = 1.0f;
		m_albedo_color[1] = 1.0f;
		m_albedo_color[2] = 1.0f;
		m_albedo_color[3] = 1.0f;
		m_metallic_factor = 1.0f;
		m_roughness_factor = 1.0f;

		m_albedo = nil;
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (Texture*)albedo {
	return m_albedo;
}

- (void)setAlbedo:(Texture*)value {
	m_albedo = value;
}

- (float*)albedoColor {
	return m_albedo_color;
}

- (void)setAlbedoColor:(float[4])value {
	m_albedo_color[0] = value[0];
	m_albedo_color[1] = value[1];
	m_albedo_color[2] = value[2];
	m_albedo_color[3] = value[3];
}

- (void)bind {
	if (m_albedo) [m_albedo bind];

	Shader* shader = [Shader current];
	if (shader == nil) return;
	[shader set:"u_base_color" vec4:(vec4*)m_albedo_color];
}

@end
