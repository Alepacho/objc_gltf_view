#ifndef NODE_H
#define NODE_H
#import "base/all.h"

#include "cglm/cglm.h"

@class Mesh;
@class Skin;

@interface Node : BaseObject {
	String* m_name;
	Node* m_parent;
	Array<Node*>* m_children;

	// True  = Node have ONLY matrix
	// False = Node have ONLY TRS
	BOOL m_has_matrix;

	mat4 m_matrix;
	vec3 m_translation;
	vec4 m_rotation;
	vec3 m_scale;

	Skin* m_skin;
	Mesh* m_mesh;
	Size m_joint_index;

	// predefined matrix with parent matrices
	// HINT: see model.m -> processNodeGlobalMatrix
	mat4 m_global_matrix;

	// calculated local matrix
	// basically it is: translation * rotation * scale // * matrix
	mat4 m_local_matrix;
}

- (String*)name;

- (Node*)parent;
- (void)setParent:(Node*)value;
- (Array<Node*>*)children;

- (const BOOL)hasMatrix;
- (void)setHasMatrix:(const BOOL)value;

- (mat4*)matrix;
- (vec3*)translation;
- (vec4*)rotation;
- (vec3*)scale;

- (Skin*)skin;
- (void)setSkin:(Skin*)value;
- (Mesh*)mesh;
- (void)setMesh:(Mesh*)value;
- (const Size)jointIndex;
- (void)setJointIndex:(const Size)value;

- (mat4*)globalMatrix;
- (mat4*)calcLocalMatrix;
- (mat4*)localMatrix;

- (void)render:(mat4*)modelMatrix;

@end

#endif // NODE_H
