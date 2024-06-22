#ifndef MATRIX_H
#define MATRIX_H
#import "base/all.h"

#include "cglm/cglm.h"

@interface Matrix : BaseObject {
	mat4 m_data;
}

- (void)create:(mat4*)data;
- (mat4*)data;

@end

#endif // MATRIX_H
