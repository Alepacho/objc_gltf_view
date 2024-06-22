#ifndef TEXTURE_H
#define TEXTURE_H
#import "base/all.h"

#include "glad/glad.h"

@interface Texture : BaseObject {
	GLuint m_id;
	Size m_width, m_height;
	uint8_t m_comp;
}

- (void)destroy;
- (void)create:(const uint8_t*)buffer width:(int)width height:(int)height comp:(int)comp;
- (void)load:(const uint8_t*)buffer length:(Size)length;
- (void)load:(const char*)path;

- (void)bind;

@end

#endif // TEXTURE_H
