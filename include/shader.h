#ifndef SHADER_H
#define SHADER_H

#import "base/all.h"

#include "SDL3/SDL.h"
#include "glad/glad.h"

#include "cglm/cglm.h"

@interface Shader : BaseObject {
	GLuint program;
}

+ (Shader*)current;

- (void)create:(const char*)path;
- (void)createVert:(const char*)vert frag:(const char*)frag;
- (void)bind;

- (GLint)getUniform:(const char*)uniform;

- (void)set:(const char*)uniform flag:(const BOOL)value;
- (void)set:(const char*)uniform integer:(const int)value;
- (void)set:(const char*)uniform vec2:(const vec2*)value;
- (void)set:(const char*)uniform vec3:(const vec3*)value;
- (void)set:(const char*)uniform vec4:(const vec4*)value;
- (void)set:(const char*)uniform mat4:(const mat4*)value;
- (void)set:(const char*)uniform mat4:(const mat4*)value count:(Size)count;

@end

#endif // SHADER_H
