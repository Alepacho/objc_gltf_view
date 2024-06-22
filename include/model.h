#ifndef MODEL_H
#define MODEL_H
#import "base/all.h"

#import "animation.h"
#import "material.h"
#import "mesh.h"
#import "node.h"
#import "skin.h"
#import "texture.h"

@interface Model : BaseObject {
	Array<Mesh*>* m_meshes;
	Array<Texture*>* m_textures;
	Array<Material*>* m_materials;
	Array<Animation*>* m_animations;
	Array<Skin*>* m_skins;
	Array<Node*>* m_nodes;
	Array<Node*>* m_scene_nodes; // root nodes

	Animation* m_current_animation;
}

- (void)load:(const char*)path;

- (const Animation*)currentAnimation;

- (void)update:(const float)time;
- (void)render:(mat4*)modelMatrix;

@end

#endif // MODEL_H
