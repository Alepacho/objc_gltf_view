#ifndef SKIN_H
#define SKIN_H
#import "base/all.h"

#include "cglm/cglm.h"

#include "node.h"

@interface Skin : BaseObject {
	Array<Node*>* m_joints;

	mat4* m_inverse_bind_matrices;
	Size m_inverse_bind_matrices_size;
	Node* m_skeleton; // bone root node (might be undefined)
}

- (Array<Node*>*)joints;
- (void)setJoints:(Array<Node*>*)value;

- (mat4*)inverseBindMatrices;
- (Size)inverseBindMatricesSize;
- (void)setInverseBindMatrices:(mat4*)value size:(Size)size;

- (Node*)skeleton;
- (void)setSkeleton:(Node*)value;

- (void)destroy;

@end

#endif // SKIN_H
