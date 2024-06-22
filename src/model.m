#import "model.h"
#import "model/process.m"

#import "main.h"
#import "shader.h"

@implementation Model

// @private

- (const char*)getResultString:(const cgltf_result)result {
	switch (result) {
		case cgltf_result_success: return "success";
		case cgltf_result_data_too_short: return "data too short";
		case cgltf_result_unknown_format: return "unknown format";
		case cgltf_result_invalid_json: return "invalid json";
		case cgltf_result_invalid_gltf: return "invalid gltf";
		case cgltf_result_invalid_options: return "invalid options";
		case cgltf_result_file_not_found: return "file not found";
		case cgltf_result_io_error: return "io error";
		case cgltf_result_out_of_memory: return "out of memory";
		case cgltf_result_legacy_gltf: return "legacy gltf";
		default: return "??";
	}
}

- (void)processNodeGlobalMatrix:(const Node*)node matrix:(mat4*)parentMatrix {
	if (node == nil) return;
	// mat4 matrix;
	// glm_mat4_copy(, matrix);
	glm_mat4_mul(*parentMatrix, *[node calcLocalMatrix], *[node globalMatrix]);
	// glm_mat4_copy(matrix, );
	// glm_mat4_mul(matrix, *[node local], *[node local]);

	for (Size i = 0; i < [[node children] count]; i++) {
		const Node* child = [[node children] getByIndex:i];
		if (child) [self processNodeGlobalMatrix:child matrix:[node globalMatrix]];
	}
}

- (void)updateGlobalMatrices {
	for (Size i = 0; i < [m_scene_nodes count]; i++) {
		mat4 identity;
		glm_mat4_identity(identity);
		const Node* node = [m_scene_nodes getByIndex:i];
		[self processNodeGlobalMatrix:node matrix:&identity];
	}
}

- (void)updateSkin:(const Skin*)skin {
	// Application* app = [Application getInstance];
	// Shader* shader = [Shader current];
	const Size size = fmin([[skin joints] count], MAX_JOINT_MATRICES);
	const Animation* current = m_current_animation;

	const Node* skeleton = [skin skeleton];
	mat4 inverse;
	if (!skeleton) {
		// not sure how to deal with it
		glm_mat4_identity(inverse);
	} else {
		glm_mat4_inv(*[skeleton globalMatrix], inverse);
		// glm_mat4_print(*[skeleton globalMatrix], stdout);
	}

	for (Size i = 0; i < size; ++i) {
		const Node* joint = [[skin joints] getByIndex:i];
		const Size j = [joint jointIndex];
		mat4 matrix;
		glm_mat4_identity(matrix);
		glm_mat4_mul(matrix, inverse, matrix);
		glm_mat4_mul(matrix, *[joint globalMatrix], matrix);
		glm_mat4_mul(matrix, [skin inverseBindMatrices][j], matrix);

		[current setJointMatrix:j matrix:&matrix];
	}
}

// @public

- (id)init {
	if (self = [super init]) {
		m_meshes = [Array new];
		m_materials = [Array new];
		m_textures = [Array new];
		m_animations = [Array new];
		m_nodes = [Array new];
		m_scene_nodes = [Array new];
		m_skins = [Array new];

		m_current_animation = nil;
	}
	return self;
}

- (void)dealloc {
	[m_meshes dealloc];
	[m_materials dealloc];
	[m_textures dealloc];
	[m_animations dealloc];
	[m_nodes dealloc];
	[m_scene_nodes clear:NO];
	[m_scene_nodes dealloc];
	[m_skins dealloc];
	[super dealloc];
}

- (void)load:(const char*)path {
	[System debug:"Loading model: %s", path];

	cgltf_options options = { 0 };
	cgltf_data* data = NULL;
	cgltf_result result = cgltf_parse_file(&options, path, &data);
	if (result != cgltf_result_success) {
		[System error:"Failed to load model (%s): %s", [self getResultString:result], path];
		cgltf_free(data);
		return;
	}

	result = cgltf_validate(data);
	if (result != cgltf_result_success) {
		[System error:"Failed to validate model (%s): %s", [self getResultString:result], path];
		cgltf_free(data);
		return;
	}

	result = cgltf_load_buffers(&options, data, path);
	if (result != cgltf_result_success) {
		[System error:"Failed to load model buffers (%s): %s", [self getResultString:result], path];
		cgltf_free(data);
		return;
	}

	[self process:data];
	[self updateGlobalMatrices];
	// if (m_current_animation) [m_current_animation update:0.0f];

	cgltf_free(data);
}

- (const Animation*)currentAnimation {
	return m_current_animation;
}

- (void)update:(const float)time {
	const Animation* current = m_current_animation;

	// no need to update if it is a static model (no animations)
	if (!current) return;
	[self updateGlobalMatrices];

	[current update:time];
	const Shader* shader = [Shader current];
	if (shader) [current passJointMatrices:shader];

	// const Node* firstNode = [m_nodes getFirst];
	// [self processNodeGlobalMatrix:firstNode matrix:&identity];

	for (Size i = 0; i < [m_skins count]; i++)
		[self updateSkin:[m_skins getByIndex:i]];
}

- (void)render:(mat4*)modelMatrix {

	// Animation* animation = [m_animations getByIndex:m_animation_index];
	// [[m_nodes getFirst] render:modelMatrix];
	for (Size i = 0; i < [m_scene_nodes count]; i++) {
		const Node* node = [m_scene_nodes getByIndex:i];
		[node render:modelMatrix];
	}

	const Application* app = [Application getInstance];
	if (![app canDrawJoints]) return;
	Mesh* cube = [app cubeMesh];
	Shader* shader = [Shader current];
	if (shader) {
		[[app whiteTexture] bind];
		[shader set:"u_joint_count" integer:0];
		for (Size i = 0; i < [m_nodes count]; i++) {
			const Node* node = [m_nodes getByIndex:i];
			mat4 mat;
			glm_mat4_mul(*modelMatrix, *[node globalMatrix], mat);
			[cube render:&mat];
		}
	}
}

@end
