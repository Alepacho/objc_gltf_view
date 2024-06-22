#ifndef MODEL_PROCESS_H
#define MODEL_PROCESS_H
#import "base/all.h"

#import "model.h"

#define CGLTF_IMPLEMENTATION
#include "cgltf.h"

@interface Model (Process)

- (void)printNodes:(const Node*)node index:(Size)idx;

- (void)process:(const cgltf_data*)data;

- (void)processSceneNodes:(const cgltf_data*)data;
- (void)processTextures:(const cgltf_data*)data;
- (void)processMaterials:(const cgltf_data*)data;
- (void)processMeshes:(const cgltf_data*)data;
- (void)processNodes:(const cgltf_data*)data;
- (void)processAnimations:(const cgltf_data*)data;
- (void)processSceneNodes:(const cgltf_data*)data;
- (void)processSkins:(const cgltf_data*)data;

@end

#endif // MODEL_PROCESS_H
