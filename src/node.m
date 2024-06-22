#import "node.h"

#import "mesh.h"

#import "main.h"
#import "shader.h"
#import "skin.h"

@implementation Node

- (id)init {
	if (self = [super init]) {
		m_name = [String new];
		m_parent = nil;
		m_children = [Array new];
		m_has_matrix = NO;

		glm_mat4_identity(m_matrix);
		glm_vec3_zero(m_translation);
		glm_vec4((vec3){ 0, 0, 0 }, 1.0f, m_rotation);
		glm_vec3_one(m_scale);

		m_skin = nil;
		m_mesh = nil;
		m_joint_index = -1;

		glm_mat4_identity(m_local_matrix);
		glm_mat4_identity(m_global_matrix);
	}

	return self;
}

- (void)dealloc {
	if (m_name) {
		[m_name dealloc];
		m_name = nil;
	}

	if (m_children) {
		[m_children clear:NO];
		[m_children dealloc];
		m_children = nil;
	}
	[super dealloc];
}

- (String*)name {
	return m_name;
}

- (Node*)parent {
	return m_parent;
}
- (void)setParent:(Node*)value {
	m_parent = value;
}
- (Array<Node*>*)children {
	return m_children;
}

- (const BOOL)hasMatrix {
	return m_has_matrix;
}
- (void)setHasMatrix:(const BOOL)value {
	m_has_matrix = value;
}

- (mat4*)matrix {
	return &m_matrix;
}
- (vec3*)translation {
	return &m_translation;
}
- (vec4*)rotation {
	return &m_rotation;
}
- (vec3*)scale {
	return &m_scale;
}

- (Skin*)skin {
	return m_skin;
}
- (void)setSkin:(Skin*)value {
	m_skin = value;

	// ?
	if (value) {
		if (![value skeleton]) {
			[value setSkeleton:self];
		}
	}
}
- (Mesh*)mesh {
	return m_mesh;
}
- (void)setMesh:(Mesh*)value {
	m_mesh = value;
}
- (const Size)jointIndex {
	return m_joint_index;
}
- (void)setJointIndex:(const Size)value {
	m_joint_index = value;
}

- (mat4*)globalMatrix {
	return &m_global_matrix;
}

- (mat4*)calcLocalMatrix {
	glm_mat4_identity(m_local_matrix);
	if (m_has_matrix) {
		glm_mat4_mul(m_local_matrix, m_matrix, m_local_matrix);
	} else {
		glm_translate(m_local_matrix, m_translation);
		glm_quat_rotate(m_local_matrix, m_rotation, m_local_matrix);
		glm_scale(m_local_matrix, m_scale);

		// ! kinda useless cuz it may be only TRS or only Matrix
		// glm_mat4_mul(m_local_matrix, m_matrix, m_local_matrix);
	}
	return &m_local_matrix;
}

- (mat4*)localMatrix {
	return &m_local_matrix;
}

- (void)render:(mat4*)modelMatrix {
	mat4 matrix;
	glm_mat4_mul(*modelMatrix, m_global_matrix, matrix);
	if ([m_children count] != 0) {
		for (Size i = 0; i < [m_children count]; i++) {
			Node* node = [m_children getByIndex:i];
			[node render:modelMatrix];
		}
	}

	const Shader* shader = [Shader current];
	if (m_skin) {
		[shader set:"u_joint_count" integer:[[m_skin joints] count]];
	}

	if (m_mesh) [m_mesh render:&matrix];
}

@end
