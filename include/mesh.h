#ifndef MESH_H
#define MESH_H
#import "base/all.h"

#import "material.h"

#include "cglm/cglm.h"
#include "glad/glad.h"

typedef enum {
	MA_POSITION2,
	MA_POSITION3,
	MA_COLOR3,
	MA_COLOR4,
	MA_NORMAL2,
	MA_NORMAL3,
	MA_TEXCOORD,
	MA_TANGENT,
	MA_JOINTS,
	MA_WEIGHTS,
} MeshAttribute;

typedef enum {
	MPT_POINTS,
	MPT_LINES,
	MPT_LINE_LOOP,
	MPT_LINE_STRIP,
	MPT_TRIANGLES,
	MPT_TRIANGLE_STRIP,
	MPT_TRIANGLE_FAN,
} MeshPrimitiveMode;

typedef struct {
	float position[3];
	float texcoord0_u; // align 4
	float normal[3];
	float texcoord0_v; // align 4
	float color[4];
	float tangent[4];
	unsigned short joints[4];
	float weights[4];
	float texcoord1[2];
} MeshVertex;

@interface MeshPrimitive : BaseObject {
	GLuint m_vao, m_vbo, m_ebo;
	GLenum m_type;

	//
	MeshVertex* m_vertices;
	Size m_vertices_count;
	unsigned int* m_indices;
	Size m_indices_count;
	MeshAttribute* m_attributes;
	Size m_attributes_count;

	Material* m_material;
}

- (void)setVertices:(MeshVertex*)vertices verticesCount:(Size)verticesCount;
- (void)setAttributes:(MeshAttribute*)attributes attributesCount:(Size)attributesCount;
- (void)setIndices:(unsigned int*)indices indicesCount:(Size)indicesCount;

- (void)setMaterial:(Material*)value;
- (Material*)material;

- (void)create:(MeshPrimitiveMode)mode;

- (void)render;

@end

@interface Mesh : BaseObject {
	Array<MeshPrimitive*>* m_primitives;

	// unused (morph only)
	// float* m_weights;
	// Size m_weights_count;
}

- (void)destroy;
- (void)create:(Array<MeshPrimitive*>*)primitives; // weights:(float*)weights weightsCount:(Size)weightsCount;

- (void)render:(mat4*)modelMatrix;

@end

#endif // MESH_H
