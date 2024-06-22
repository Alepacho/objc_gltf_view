#ifndef MAIN_H
#define MAIN_H

#import "base/all.h"

#include "SDL3/SDL.h"
#include "glad/glad.h"

@class Model;
@class Shader;
@class Texture;
@class Mesh;

@interface Application : BaseObject {
	SDL_Window* window;
	SDL_GLContext ctx;
	BOOL running;
	String* modelPath;
	Model* model;
	Shader* shader;
	Texture* whiteTexture;
	Mesh* cube_mesh;
	int keyFrame;
	BOOL updateAnimation;
	BOOL canDrawJoints;
}

+ (Application*)getInstance;
- (int)run:(Array<String*>*)args;
- (void)close;

- (Mesh*)cubeMesh;
- (Texture*)whiteTexture;

- (int)keyFrame;
- (BOOL)updateAnimation;
- (BOOL)canDrawJoints;

@end

#endif // MAIN_H