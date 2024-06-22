#import "mesh.h"

#import "shader.h"

@implementation MeshPrimitive

// @private

- (void)destroy {
	if (m_vbo != 0) glDeleteBuffers(1, &m_vbo);
	if (m_ebo != 0) glDeleteBuffers(1, &m_ebo);
	if (m_vao != 0) glDeleteVertexArrays(1, &m_vao);
	m_vbo = m_vao = m_ebo = 0;
}

- (void)destroyIndices {
	if (!m_indices) return;
	free(m_indices);
	m_indices = nil;
	m_indices_count = 0;
}

- (void)destroyVertices {
	if (!m_vertices) return;
	free(m_vertices);
	m_vertices = nil;
	m_vertices_count = 0;
}

- (void)destroyAttributes {
	if (!m_attributes) return;
	free(m_attributes);
	m_attributes = nil;
	m_attributes_count = 0;
}

// @public

- (id)init {
	if (self = [super init]) {
		m_vbo = m_vao = m_ebo = 0;
		m_type = GL_TRIANGLE_STRIP;

		m_indices = nil;
		m_indices_count = 0;
		m_attributes = nil;
		m_attributes_count = 0;
		m_vertices = nil;
		m_vertices_count = 0;

		m_material = nil;
	}
	return self;
}

- (void)dealloc {
	[self destroy];
	[self destroyVertices];
	[self destroyAttributes];
	[self destroyIndices];
	[super dealloc];
}

- (void)setVertices:(MeshVertex*)vertices verticesCount:(Size)verticesCount {
	[self destroyVertices];
	if (verticesCount == 0) return;
	m_vertices = malloc(verticesCount * sizeof(MeshVertex));
	memcpy(m_vertices, vertices, verticesCount * sizeof(MeshVertex));
	m_vertices_count = verticesCount;
}

- (void)setAttributes:(MeshAttribute*)attributes attributesCount:(Size)attributesCount {
	[self destroyAttributes];
	if (attributesCount == 0) return;
	m_attributes = malloc(attributesCount * sizeof(MeshAttribute));
	memcpy(m_attributes, attributes, attributesCount * sizeof(MeshAttribute));
	m_attributes_count = attributesCount;
}

- (void)setIndices:(unsigned int*)indices indicesCount:(Size)indicesCount {
	[self destroyIndices];
	if (indicesCount == 0) return;
	m_indices = malloc(indicesCount * sizeof(unsigned int));
	memcpy(m_indices, indices, indicesCount * sizeof(unsigned int));
	m_indices_count = indicesCount;
}

- (void)setMaterial:(Material*)value {
	if (value == nil) return;
	m_material = value;
}

- (Material*)material {
	return m_material;
}

- (void)create:(MeshPrimitiveMode)mode {
	[self destroy];
	switch (mode) {
		case MPT_POINTS: m_type = GL_POINTS; break;
		case MPT_LINES: m_type = GL_LINES; break;
		case MPT_LINE_LOOP: m_type = GL_LINE_LOOP; break;
		case MPT_LINE_STRIP: m_type = GL_LINE_STRIP; break;
		case MPT_TRIANGLES: m_type = GL_TRIANGLES; break;
		case MPT_TRIANGLE_STRIP: m_type = GL_TRIANGLE_STRIP; break;
		case MPT_TRIANGLE_FAN: m_type = GL_TRIANGLE_FAN; break;
	}

	if (m_attributes == nil) [System fatal:"Mesh should have at least one Attribute!"];
	if (m_vertices == nil) [System fatal:"Mesh should have at least one Vertex!"];

	// [System println:"Vertices: "];
	// for (Size i = 0; i < m_vertices_count; i++) {
	// 	MeshVertex* v = &m_vertices[i];
	// 	[System println:"{ "];
	// 	[System println:"	position  : [%f, %f, %f] ", v->position[0], v->position[1], v->position[2]];
	// 	[System println:"	texcoord0 : [%f, %f] ", v->texcoord0_u, v->texcoord0_v];
	// 	[System println:"	texcoord1 : [%f, %f] ", v->texcoord1[0], v->texcoord1[1]];
	// 	[System println:"	normal    : [%f, %f, %f] ", v->normal[0], v->normal[1], v->normal[2]];
	// 	[System println:"	color     : [%f, %f, %f, %f] ", v->color[0], v->color[1], v->color[2], v->color[3]];
	// 	[System println:"	tangent   : [%f, %f, %f, %f] ", v->tangent[0], v->tangent[1], v->tangent[2], v->tangent[3]];
	// 	[System println:"	joints    : [%u, %u, %u, %u] ", v->joints[0], v->joints[1], v->joints[2], v->joints[3]];
	// 	[System println:"	weights   : [%f, %f, %f, %f] ", v->weights[0], v->weights[1], v->weights[2], v->weights[3]];
	// 	[System println:"} "];
	// }
	// [System println:""];

	GLuint draw_type = GL_STATIC_DRAW;

	glGenVertexArrays(1, &m_vao);
	glBindVertexArray(m_vao);

	glGenBuffers(1, &m_vbo);
	glBindBuffer(GL_ARRAY_BUFFER, m_vbo);
	glBufferData(GL_ARRAY_BUFFER, m_vertices_count * sizeof(MeshVertex), m_vertices, draw_type);

	if (m_indices_count != 0) {
		glGenBuffers(1, &m_ebo);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_ebo);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, m_indices_count * sizeof(unsigned int), m_indices, draw_type);
	}

	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(MeshVertex), (GLvoid*)offsetof(MeshVertex, position));
	glEnableVertexAttribArray(1);
	glVertexAttribPointer(1, 1, GL_FLOAT, GL_FALSE, sizeof(MeshVertex), (GLvoid*)offsetof(MeshVertex, texcoord0_u));
	glEnableVertexAttribArray(2);
	glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, sizeof(MeshVertex), (GLvoid*)offsetof(MeshVertex, normal));
	glEnableVertexAttribArray(3);
	glVertexAttribPointer(3, 1, GL_FLOAT, GL_FALSE, sizeof(MeshVertex), (GLvoid*)offsetof(MeshVertex, texcoord0_v));
	glEnableVertexAttribArray(4);
	glVertexAttribPointer(4, 4, GL_FLOAT, GL_FALSE, sizeof(MeshVertex), (GLvoid*)offsetof(MeshVertex, color));
	glEnableVertexAttribArray(5);
	glVertexAttribPointer(5, 4, GL_FLOAT, GL_FALSE, sizeof(MeshVertex), (GLvoid*)offsetof(MeshVertex, tangent));
	glEnableVertexAttribArray(6);
	glVertexAttribIPointer(6, 4, GL_UNSIGNED_SHORT, sizeof(MeshVertex), (GLvoid*)offsetof(MeshVertex, joints));
	glEnableVertexAttribArray(7);
	glVertexAttribPointer(7, 4, GL_FLOAT, GL_FALSE, sizeof(MeshVertex), (GLvoid*)offsetof(MeshVertex, weights));
	glEnableVertexAttribArray(8);
	glVertexAttribPointer(8, 2, GL_FLOAT, GL_FALSE, sizeof(MeshVertex), (GLvoid*)offsetof(MeshVertex, texcoord1));

	glBindVertexArray(0);
}

- (void)render {
	if (m_vao == 0) return;
	glBindVertexArray(m_vao);

	// glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	if (m_indices_count != 0) {
		glDrawElements(m_type, m_indices_count, GL_UNSIGNED_INT, NULL);
	} else {
		glDrawArrays(m_type, 0, m_vertices_count);
	}
	// glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
}

@end

@implementation Mesh

// @private

// @public

- (id)init {
	if (self = [super init]) {
		m_primitives = nil;
		// m_weights = nil;
		// m_weights_count = 0;
	}
	return self;
}

- (void)dealloc {
	[self destroy];
	[super dealloc];
}

- (void)destroy {
	if (m_primitives == nil) return;
	[m_primitives dealloc];
	// if (m_weights) {
	// 	free(m_weights);
	// 	m_weights = nil;
	// }
	// m_weights_count = 0;
}

- (void)create:(Array<MeshPrimitive*>*)primitives { // weights:(float*)weights weightsCount:(Size)weightsCount
	[self destroy];
	m_primitives = primitives;
	// if (weightsCount != 0) {
	// 	m_weights = malloc(weightsCount * sizeof(float));
	// 	memcpy(m_weights, weights, weightsCount * sizeof(float));
	// 	m_weights_count = weightsCount;
	// }
}

- (void)render:(mat4*)modelMatrix {
	Shader* shader = [Shader current];
	if (shader) {
		[shader set:"u_model" mat4:modelMatrix];
	}

	for (Size i = 0; i < [m_primitives count]; i++) {
		const MeshPrimitive* primitive = [m_primitives getByIndex:i];
		[[primitive material] bind];
		[primitive render];
	}
}

@end
