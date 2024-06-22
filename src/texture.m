#import "texture.h"

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

const GLsizei texture_level = 0; // mipmap

@implementation Texture

- (id)init {
	if (self = [super init]) {
		m_id = 0;
		m_comp = 0;
		m_width = m_height = 0;
	}
	return self;
}

- (void)dealloc {
	[self destroy];
	[super dealloc];
}

- (void)destroy {
	if (m_id == 0) return;
	glDeleteTextures(1, &m_id);
	m_id = 0;
	m_width = m_height = 0;
	m_comp = 0;
}

- (void)create:(const uint8_t*)buffer width:(int)width height:(int)height comp:(int)comp {
	[self destroy];
	[System debug:"Create Texture: %i, %i, %i", width, height, comp];
	m_width = width;
	m_height = height;
	m_comp = comp;

	glGenTextures(1, &m_id);
	[self bind];

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

	const float border_color[] = { 0.0f, 0.0f, 0.0f, 1.0f };
	glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, border_color);

	switch (comp) {
		case 3: {
			glTexImage2D(GL_TEXTURE_2D, texture_level, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, buffer);
		} break;
		case 4: {
			glTexImage2D(GL_TEXTURE_2D, texture_level, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
		} break;
		default: [System fatal:"Unable to create image: %s", "wrong comp!"];
	}

	// glGenerateMipmap(GL_TEXTURE_2D);
}

- (void)load:(const uint8_t*)buffer length:(Size)length {
	int w, h, c;
	uint8_t* result = stbi_load_from_memory(buffer, length, &w, &h, &c, 4);
	if (result == NULL) [System fatal:"Failed to load image from memory (length: %lu)", length];
	[self create:result width:w height:h comp:4];
	stbi_image_free(result);
}

- (void)load:(const char*)path {
	uint8_t* buffer = nil;
	int w, h, c;
	buffer = stbi_load(path, &w, &h, &c, 4);
	if (buffer == NULL) [System fatal:"Failed to load image: %s", path];

	[self create:buffer width:w height:h comp:4];
	stbi_image_free(buffer);
}

- (void)bind {
	glBindTexture(GL_TEXTURE_2D, m_id);
}

@end
