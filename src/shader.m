#import "shader.h"

typedef enum {
	SS_GENERAL,
	SS_VERTEX,
	SS_FRAGMENT,
	SS_GEOMETRY,
} ShaderSelect;

static Shader* current_shader = nil;

@implementation Shader

// @private

// @public

- (id)init {
	if (self = [super init]) {
		program = 0;
	}
	return self;
}

- (void)dealloc {
	if (program != 0) {
		glDeleteProgram(program);
		program = 0;
	}
	[super dealloc];
}

+ (Shader*)current {
	return current_shader;
}

- (void)create:(const char*)path {
	String* source = [String new];
	File* file = [File new];
	@try {
		[file open:BASE_FILE_READ withBuffer:path];
	} @catch (Exception* ex) {
		[System fatal:"Failed to open '%s' file", path];
	}

	[file readWithString:source];

	ShaderSelect select = SS_GENERAL;
	String* vert = [String new];
	String* frag = [String new];

	char* tok = NULL;
	tok = strtok([source buffer], "\r\n");
	while (tok != NULL) {
		// printf("%s\n", tok);
		if (strncmp(tok, "//", 2) == 0) {
			tok = strtok(NULL, "\r\n");
			continue;
		}

		if (strncmp(tok, "#select", 7) == 0) {
			int i = 7;
			while (tok[i] != '\n' && tok[i] != ' ')
				i++;
			i++;

			// printf("i: %i\n", i);
			const char* sel = (tok + i);
			if (strncmp(sel, "general", 7) == 0) select = SS_GENERAL;
			if (strncmp(sel, "vertex", 6) == 0) select = SS_VERTEX;
			if (strncmp(sel, "fragment", 8) == 0) select = SS_FRAGMENT;
		} else {
			switch (select) {
				case SS_GENERAL:
					[vert appendFormat:"%s\n", tok];
					[frag appendFormat:"%s\n", tok];
					break;
				case SS_VERTEX: [vert appendFormat:"%s\n", tok]; break;
				case SS_FRAGMENT: [frag appendFormat:"%s\n", tok]; break;
				case SS_GEOMETRY: break;
			}
		}
		tok = strtok(NULL, "\r\n");
	}

	// [System debug:"VERTEX START\n%s\nVERTEX END", [vert buffer]];
	// [System debug:"FRAGMENT START\n%s\nFRAGMENT END", [frag buffer]];
	// [System fatal:"sosi"];

	[self createVert:[vert buffer] frag:[frag buffer]];
	[vert dealloc];
	[frag dealloc];
	[source dealloc];
}

- (void)createVert:(const char*)vert frag:(const char*)frag {
	GLint status;
	char error[512];
	GLuint vertex, fragment;
	{
		vertex = glCreateShader(GL_VERTEX_SHADER);
		glShaderSource(vertex, 1, &vert, NULL);
		glCompileShader(vertex);
		glGetShaderiv(vertex, GL_COMPILE_STATUS, &status);
		if (status != GL_TRUE) {
			glGetShaderInfoLog(vertex, sizeof(error), NULL, error);
			error[sizeof(error) - 1] = '\0';
			[System fatal:"Fatal error: Failed to compile vertex shader!\n%s", error];
		}
	}

	{
		fragment = glCreateShader(GL_FRAGMENT_SHADER);
		glShaderSource(fragment, 1, &frag, NULL);
		glCompileShader(fragment);
		glGetShaderiv(fragment, GL_COMPILE_STATUS, &status);
		if (status != GL_TRUE) {
			glGetShaderInfoLog(fragment, sizeof(error), NULL, error);
			error[sizeof(error) - 1] = '\0';
			[System fatal:"Fatal error: Failed to compile fragment shader!\n%s", error];
		}
	}

	program = glCreateProgram();
	glAttachShader(program, vertex);
	glAttachShader(program, fragment);
	glBindFragDataLocation(program, 0, "out_FragColor");
	glLinkProgram(program);

	glValidateProgram(program);

	// TODO: error check

	glDetachShader(program, vertex);
	glDetachShader(program, fragment);
	glDeleteShader(vertex);
	glDeleteShader(fragment);
}

- (void)bind {
	glUseProgram(program);
	current_shader = self;
}

- (GLint)getUniform:(const char*)uniform {
	const GLint result = glGetUniformLocation(program, uniform);
	if (result == -1) [System fatal:"Unknown uniform location: %s", uniform];
	return result;
}

- (void)set:(const char*)uniform flag:(const BOOL)value {
	// glUniform2fv([self getUniform:uniform], 1, *value);
	glUniform1i([self getUniform:uniform], value);
}

- (void)set:(const char*)uniform integer:(const int)value {
	glUniform1i([self getUniform:uniform], value);
}

- (void)set:(const char*)uniform vec2:(const vec2*)value {
	glUniform2fv([self getUniform:uniform], 1, *value);
}

- (void)set:(const char*)uniform vec3:(const vec3*)value {
	glUniform3fv([self getUniform:uniform], 1, *value);
}

- (void)set:(const char*)uniform vec4:(const vec4*)value {
	glUniform4fv([self getUniform:uniform], 1, *value);
}

- (void)set:(const char*)uniform mat4:(const mat4*)value {
	[self set:uniform mat4:value count:1];
}

- (void)set:(const char*)uniform mat4:(const mat4*)value count:(Size)count {
	glUniformMatrix4fv([self getUniform:uniform], count, GL_FALSE, *value[0]);
}

@end
