#import "main.h"

#import "model.h"
#import "shader.h"
#import "texture.h"

@implementation Application

// @private

- (const char*)getOpenGLErrorInfo:(const GLenum)err {
	switch (err) {
		case GL_NO_ERROR: return "No error";
		case GL_INVALID_ENUM: return "Invalid enum";
		case GL_INVALID_VALUE: return "Invalid value";
		case GL_INVALID_OPERATION: return "Invalid operation";
		case GL_STACK_OVERFLOW: return "Stack overflow";
		case GL_STACK_UNDERFLOW: return "Stack underflow";
		case GL_OUT_OF_MEMORY: return "Out of memory";
		default: return "Unknown error";
	}
}

- (BOOL)checkOpenGL {
	BOOL result = NO;
	for (;;) {
		const GLenum err = glGetError();
		if (GL_NO_ERROR == err) break;
		[System error:"OpenGL Error: %s", [self getOpenGLErrorInfo:err]];
		result = true;
	}
	return result;
}

- (const BOOL)parse:(Array<String*>*)args {
	if (args == nil) return YES;
	if ([args count] == 1) {
		[System println:"usage: %s <model path>", [[args getFirst] buffer]];
		return YES;
	}
	[modelPath setString:[args getByIndex:1]];

	return NO;
}

// @public

- (id)init {
	if (self = [super init]) {
		window = nil;
		ctx = nil;
		running = YES;
		modelPath = [String new];
		model = [Model new];
		shader = [Shader new];
		whiteTexture = [Texture new];
		cube_mesh = nil;
		keyFrame = 0;
		updateAnimation = YES;
		canDrawJoints = NO;
	}
	return self;
}

- (void)dealloc {
	if (cube_mesh) {
		[cube_mesh dealloc];
		cube_mesh = nil;
	}
	if (shader) {
		[shader dealloc];
		shader = nil;
	}
	if (model) {
		[model dealloc];
		model = nil;
	}
	if (modelPath) {
		[modelPath dealloc];
		modelPath = nil;
	}
	if (whiteTexture) {
		[whiteTexture dealloc];
		whiteTexture = nil;
	}
	if (ctx) {
		SDL_GL_DeleteContext(ctx);
		ctx = nil;
	}
	if (window) {
		SDL_DestroyWindow(window);
		window = nil;
	}
	SDL_Quit();
	[super dealloc];
}

+ (Application*)getInstance {
	static Application* _instance = nil;
	if (_instance == nil) {
		_instance = [Application new];
	}
	return _instance;
}

- (int)run:(Array<String*>*)args {
	if ([self parse:args]) [System fatal:"Failed to parse config."];
	if (SDL_Init(SDL_INIT_VIDEO)) [System fatal:"Failed to init SDL: %s", SDL_GetError()];

	const char* title = ".gltf viewer!";
	int width = 800;
	int height = 600;
	const Uint32 window_flags = SDL_WINDOW_RESIZABLE;
	window = SDL_CreateWindow(title, width, height, window_flags);
	if (window == NULL) [System fatal:"Failed to create window: %s", SDL_GetError()];

	SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
	SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 8);

	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
	SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL, 1);
	SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);

	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

	ctx = SDL_GL_CreateContext(window);
	if (ctx == nil) [System fatal:"Failed to create context: %s", SDL_GetError()];

	SDL_GL_MakeCurrent(window, ctx);
	SDL_GL_SetSwapInterval(1);

	if (!gladLoadGLLoader((GLADloadproc)SDL_GL_GetProcAddress)) [System fatal:"Failed to initialize GLAD!"];

	glEnable(GL_BLEND);
	glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glEnable(GL_DEPTH_TEST);

	int v;
	// OpenGL information
	[System debug:"Vendor      : %s", glGetString(GL_VENDOR)];
	[System debug:"Renderer    : %s", glGetString(GL_RENDERER)];
	[System debug:"Version     : %s", glGetString(GL_VERSION)];
	[System debug:"GLSL Version: %s", glGetString(GL_SHADING_LANGUAGE_VERSION)];

	// useful info for mat4 arrays
	glGetIntegerv(GL_MAX_VERTEX_UNIFORM_COMPONENTS, &v);
	[System debug:"GLSL Max Vertex Uniforms  : %i", v];
	glGetIntegerv(GL_MAX_FRAGMENT_UNIFORM_COMPONENTS, &v);
	[System debug:"GLSL Max Fragment Uniforms: %i", v];
	glGetIntegerv(GL_MAX_GEOMETRY_UNIFORM_COMPONENTS, &v);
	[System debug:"GLSL Max Geometry Uniforms: %i", v];

	[whiteTexture create:(uint8_t[]){ 255, 255, 255, 255 } width:1 height:1 comp:4];

	cube_mesh = [Mesh new];
	{
		Array<MeshPrimitive*>* primitives = [Array new];
		MeshPrimitive* prim = [MeshPrimitive new];
		{
			// clang-format off
			MeshAttribute attributes[] = {
				MA_POSITION3, MA_COLOR4,
			};
			const float alpha = 0.5f;
			const float size = 0.05f;
			MeshVertex vertices[] = {
				{ .position = { -size, -size,  size }, .color = { 0.0f, 1.0f, 0.5f, alpha }},
				{ .position = {  size, -size,  size }, .color = { 0.0f, 1.0f, 0.5f, alpha }},
				{ .position = { -size,  size,  size }, .color = { 0.0f, 1.0f, 0.5f, alpha }},
				{ .position = {  size,  size,  size }, .color = { 0.0f, 1.0f, 0.5f, alpha }},
				{ .position = { -size, -size, -size }, .color = { 1.0f, 0.0f, 0.5f, alpha }},
				{ .position = {  size, -size, -size }, .color = { 1.0f, 0.0f, 0.5f, alpha }},
				{ .position = { -size,  size, -size }, .color = { 1.0f, 0.0f, 0.5f, alpha }},
				{ .position = {  size,  size, -size }, .color = { 1.0f, 0.0f, 0.5f, alpha }},
			};
			uint32_t indices[] = {
				2, 6, 7, 2, 3, 7, // Top
				0, 4, 5, 0, 1, 5, // Bottom
				0, 2, 6, 0, 4, 6, // Left
				1, 3, 7, 1, 5, 7, // Right
				0, 2, 3, 0, 1, 3, // Front
				4, 6, 7, 4, 5, 7, // Back
			};
			// clang-format on
			[prim setAttributes:attributes attributesCount:(sizeof(attributes) / sizeof(MeshAttribute))];
			[prim setVertices:vertices verticesCount:(sizeof(vertices) / sizeof(MeshVertex))];
			[prim setIndices:indices indicesCount:(sizeof(indices) / sizeof(uint32_t))];
		}
		[prim create:MPT_TRIANGLES];
		[primitives push:prim];
		[cube_mesh create:primitives]; // weights:nil weightsCount:0
	}

	[shader create:"./shader.glsl"];
	[model load:[modelPath buffer]];
	SDL_Event e;

	mat4 mat_model, mat_view, mat_projection;
	glm_mat4_identity(mat_model);
	glm_mat4_identity(mat_view);
	glm_mat4_identity(mat_projection);

	// glm_rotate(mat_model, -1.52f, (vec3){ 1.0f, 0.0f, 0.0f });
	glm_translate(mat_view, (vec3){ 0.0f, 0.0f, -5.0f });
	glm_perspective(70.0f, (float)width / (float)height, 0.1f, 100.0f, mat_projection);

	BOOL auto_rotate = NO;
	static float tick = 0.0f;

	BOOL auto_animate = NO;

	while (running) {
		// OpenGL error check
		if ([self checkOpenGL]) {
			[self close];
			break;
		}

		// update
		while (SDL_PollEvent(&e)) {
			switch (e.type) {
				case SDL_EVENT_QUIT: [self close]; break;
				case SDL_EVENT_WINDOW_RESIZED: {
					SDL_GetWindowSize(window, &width, &height);
					glm_perspective(70.0f, (float)width / (float)height, 0.1f, 100.0f, mat_projection);
				} break;
				case SDL_EVENT_KEY_DOWN: {
					const SDL_Scancode s = e.key.keysym.scancode;
					if (s == SDL_SCANCODE_ESCAPE) [self close];
					float vvvv = 0.1f;
					if (e.key.keysym.mod == SDL_KMOD_LSHIFT) vvvv = 1.0f;
					if (s == SDL_SCANCODE_W) glm_translate(mat_view, (vec3){ 0.0f, vvvv, 0.0f });
					if (s == SDL_SCANCODE_S) glm_translate(mat_view, (vec3){ 0.0f, -vvvv, 0.0f });
					if (s == SDL_SCANCODE_A) glm_translate(mat_view, (vec3){ -vvvv, 0.0f, 0.0f });
					if (s == SDL_SCANCODE_D) glm_translate(mat_view, (vec3){ vvvv, 0.0f, 0.0f });
					if (s == SDL_SCANCODE_Q) glm_translate(mat_view, (vec3){ 0.0f, 0.0f, -vvvv });
					if (s == SDL_SCANCODE_E) glm_translate(mat_view, (vec3){ 0.0f, 0.0f, vvvv });
					if (s == SDL_SCANCODE_UP) glm_rotate(mat_view, -vvvv, (vec3){ 1.0f, 0.0f, 0.0f });
					if (s == SDL_SCANCODE_DOWN) glm_rotate(mat_view, vvvv, (vec3){ 1.0f, 0.0f, 0.0f });
					if (s == SDL_SCANCODE_LEFT) glm_rotate(mat_view, -vvvv, (vec3){ 0.0f, 0.0f, 1.0f });
					if (s == SDL_SCANCODE_RIGHT) glm_rotate(mat_view, vvvv, (vec3){ 0.0f, 0.0f, 1.0f });
					if (s == SDL_SCANCODE_COMMA) glm_rotate(mat_view, -vvvv, (vec3){ 0.0f, 1.0f, 0.0f });
					if (s == SDL_SCANCODE_PERIOD) glm_rotate(mat_view, vvvv, (vec3){ 0.0f, 1.0f, 0.0f });
					if (s == SDL_SCANCODE_SPACE) auto_rotate = !auto_rotate;
					if (s == SDL_SCANCODE_RETURN) auto_animate = !auto_animate;
					if (s == SDL_SCANCODE_J) canDrawJoints = !canDrawJoints;

					const float tspd = 0.05f * vvvv;
					if (s == SDL_SCANCODE_1) {
						keyFrame--;
						// [System debug:"key: %i", keyFrame];
						tick -= tspd;
						updateAnimation = YES;
					}
					if (s == SDL_SCANCODE_2) {
						keyFrame++;
						// [System debug:"key: %i", keyFrame];
						tick += tspd;
						updateAnimation = YES;
					}
					if (s == SDL_SCANCODE_5) {
						[System debug:"tick: %f", tick];
					}
				} break;
			}
		}

		if (auto_rotate) {
			float tick = 0.25f * M_PI / 180.0f;
			glm_rotate(mat_model, tick, (vec3){ 0.0f, 0.0f, 1.0f });
		}

		if (auto_animate) {
			updateAnimation = YES;
			tick += 1.0f / 60.0f;
		}

		// if (updateAnimation)
		[model update:tick];

		// render
		glViewport(0, 0, width, height);
		glClearColor(0.5f, 0.8f, 0.9f, 1.0f);
		// glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		[whiteTexture bind];
		[shader bind];
		// [shader set:"u_model" mat4:&mat_model];
		[shader set:"u_view" mat4:&mat_view];
		[shader set:"u_projection" mat4:&mat_projection];

		// mat4 identity;
		// glm_mat4_identity(identity);
		[model render:&mat_model]; // mat_model

		updateAnimation = NO;
		SDL_GL_SwapWindow(window);
	}

	return 0;
}

- (void)close {
	running = NO;
}

- (Mesh*)cubeMesh {
	return cube_mesh;
}

- (Texture*)whiteTexture {
	return whiteTexture;
}

- (int)keyFrame {
	return keyFrame;
}

- (BOOL)updateAnimation {
	return updateAnimation;
}

- (BOOL)canDrawJoints {
	return canDrawJoints;
}

@end

int main(int argc, char* argv[]) {
	[System debug:".gltf viewer!"];
	Array<String*>* args = [Array new];
	for (Size i = 0; i < argc; i++)
		[args push:[[String alloc] initWithBuffer:argv[i]]];
	const int result = [[Application getInstance] run:args];
	[args dealloc];
	return result;
}
