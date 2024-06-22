#import "model/process.h"

#include "cglm/cglm.h"

typedef struct {
	struct {
		float* data;
		Size count;
	} position;
	struct {
		float* data;
		cgltf_component_type type;
		Size count;
	} texcoord[2];
	struct {
		float* data;
		Size count;
	} normal;
	struct {
		float* data;
		cgltf_component_type type;
		cgltf_type atype;
		Size count;
	} color;
	struct {
		float* data;
		Size count;
	} tangent;
	struct {
		unsigned short* data;
		cgltf_component_type type;
		Size count;
	} joints;
	struct {
		float* data;
		cgltf_component_type type;
		Size count;
	} weights;
} ModelData;

@implementation Model (Process)

- (void)printNodes:(const Node*)node index:(Size)idx {
	String* tabs = [String new];
	[tabs setBuffer:""];
	for (Size t = 0; t < idx; t++)
		[tabs appendBuffer:" "];
	const char* tbuf = [tabs buffer];
	[System println:"%s%03lu. node: %s (%x)", tbuf, idx, [[node name] buffer], [m_nodes getByIndex:idx]];
	// [System println:"%s* animated: %x", tbuf, [node animated]];
	[System println:"%s* parent: %x", tbuf, [node parent]];
	[System println:"%s* skin  : %x", tbuf, [node skin]];

	for (Size i = 0; i < [[node children] count]; i++)
		[self printNodes:[[node children] getByIndex:i] index:idx + 1];

	[tabs dealloc];
}

// - (void)textAnimIndex:(const AnimationChannel*)channel {
// 	if (channel == nil) return;
// 	[System debug:"Index: %lu", [channel index]];
// 	// for (Size i = 0; i < [channel c])
// }

- (void)process:(const cgltf_data*)data {
	[self processTextures:data];
	[self processMaterials:data];
	[self processMeshes:data];
	[self processNodes:data];
	[self processSkins:data];
	[self processAnimations:data];
	[self processSceneNodes:data];

	[System debug:"nodes      : %lu", [m_nodes count]];
	// [self printNodes:[m_nodes getByIndex:0] index:0];
	[System debug:"scene nodes: %lu", [m_scene_nodes count]];
	// for (Size i = 0; i < [m_scene_nodes count]; i++) {
	// 	// const Node* node = [m_scene_nodes getByIndex:i];
	// 	// [System debug:"%03lu. scene node (%x)", i, [m_scene_nodes getByIndex:i]];
	// 	// [System debug:"* parent: %x", [node parent]];
	// 	// [System debug:"* skin  : %x", [node skin]];
	// }
	[System debug:"meshes     : %lu (%lu)", [m_meshes count], (data->meshes_count)];
	[System debug:"materials  : %lu", [m_materials count]];
	[System debug:"textures   : %lu", [m_textures count]];
	[System debug:"skins      : %lu", [m_skins count]];
	for (Size i = 0; i < [m_skins count]; i++) {
		const Skin* skin = [m_skins getByIndex:i];
		[System debug:"* skeleton : %x", [skin skeleton]];
		if ([skin joints]) [System debug:"* joints   : %lu", [[skin joints] count]];
	}
	[System debug:"animations : %lu", [m_animations count]];
	for (Size i = 0; i < [m_animations count]; i++) {
		const Animation* animation = [m_animations getByIndex:i];
		[System debug:"* min time : %f", [animation minTime]];
		[System debug:"* max time : %f", [animation maxTime]];
		if ([animation channels]) {
			[System debug:"* channels : %lu", [[animation channels] count]];
		}
		if ([animation samplers]) {
			[System debug:"* samplers : %lu", [[animation samplers] count]];
			// for (Size j = 0; j < [[animation samplers] count]; j++) {
			// 	const AnimationSampler* sampler = [[animation samplers] getByIndex:j];
			// 	[System debug:" * timestamps: %lu", [sampler timestampsSize]];
			// }
		}
	}
}

- (void)processTextures:(const cgltf_data*)data {
	for (cgltf_size t = 0; t < data->textures_count; t++) {
		const cgltf_texture* tex = &data->textures[t];
		const cgltf_image* img = tex->image;
		const cgltf_buffer_view* bview = img->buffer_view;
		// [System debug:"texture name %s", tex->name];
		// [System debug:"image name %s", img->name];
		// [System debug:"image mime %s", img->mime_type];
		// [System debug:"buffer view name %s", bview->name];
		// [System debug:"buffer view size %i", bview->size];
		// [System debug:"uri %s", img->uri];

		Texture* texture = [Texture new];
		const uint8_t* buf = bview->buffer->data + bview->offset;
		// for (Size i = 0; i < 32; i++) {
		// 	[System print:"%x ", (uint8_t)(*(buf + i))];
		// }
		// [System println:""];
		[texture load:buf length:bview->size];
		[m_textures push:texture];
	}
}

- (void)processMaterials:(const cgltf_data*)data {
	for (cgltf_size m = 0; m < data->materials_count; m++) {
		const cgltf_material* mtrl = &data->materials[m];
		Material* material = [Material new];

		// get albedo
		if (mtrl->has_pbr_metallic_roughness) {
			const cgltf_pbr_metallic_roughness* pbrmr = &mtrl->pbr_metallic_roughness;
			[material setAlbedoColor:(float*)pbrmr->base_color_factor];
			// [material setAlbedoColor:(float[4]){ 0.0f, 1.0f, 0.5f, 1.0f }];
			{
				// [material se]
				const cgltf_texture_view* tview = &pbrmr->base_color_texture;
				if (tview->texture) {
					// [System debug:"scale %i", tview->scale];
					// [System debug:"has transform %s", tview->has_transform ? "YES" : "NO"];
					const cgltf_size index = cgltf_texture_index(data, tview->texture);
					[material setAlbedo:[m_textures getByIndex:index]];
				}
			}
		}
		[m_materials push:material];
	}
}

- (void)processMeshes:(const cgltf_data*)data {
	// mdata->meshes_count
	for (cgltf_size m = 0; m < data->meshes_count; m++) {
		const cgltf_mesh* data_mesh = &data->meshes[m];
		Array<MeshPrimitive*>* primitives = [Array new];
		for (cgltf_size p = 0; p < data_mesh->primitives_count; p++) {
			const cgltf_primitive* prim = &data_mesh->primitives[p];
			MeshPrimitive* primitive = [MeshPrimitive new];

			if (prim->indices != NULL) { // process indices
				const cgltf_accessor* acce = prim->indices;
				const cgltf_buffer_view* bview = acce->buffer_view;
				// [System debug:"indices? %s", (indi_bview->type == cgltf_buffer_view_type_indices) ? "YES" : "NO"];
				unsigned int* indices = malloc(acce->count * sizeof(unsigned int));
				if (acce->component_type == cgltf_component_type_r_32u) {
					// just copy
					unsigned int* ptr = bview->buffer->data + acce->offset + bview->offset;
					memcpy(indices, ptr, acce->count * sizeof(unsigned int));
				} else if (acce->component_type == cgltf_component_type_r_16u) {
					for (Size i = 0; i < acce->count; i++) {
						unsigned short* ptr = bview->buffer->data + acce->offset + bview->offset;
						indices[i] = (unsigned short)ptr[i];
					}
				}
				[primitive setIndices:indices indicesCount:acce->count];
			}

			// clang-format off
			ModelData model_data = {
                .position = {
                    .data = nil,
                    .count = 0
                }, 
                .texcoord[0] = {
                    .data = nil,
                    .type = cgltf_component_type_r_32f,
                    .count = 0
                }, 
                .texcoord[1] = {
                    .data = nil,
                    .type = cgltf_component_type_r_32f,
                    .count = 0
                }, 
                .normal = {
                    .data = nil,
                    .count = 0
                }, 
                .color = {
                    .data = nil,
                    .type = cgltf_component_type_r_32f,
                    .count = 0
                }, 
                .tangent = {
                    .data = nil,
                    .count = 0
                }, 
                .joints = {
                    .data = nil,
                    .type = cgltf_component_type_r_16u,
                    .count = 0
                }, 
                .weights = {
                    .data = nil,
                    .type = cgltf_component_type_r_32f,
                    .count = 0
                }, 
            };
			// clang-format on

			// process attributes
			MeshAttribute* attributes = malloc(prim->attributes_count * sizeof(MeshAttribute));
			for (cgltf_size i = 0; i < prim->attributes_count; i++) {
				const cgltf_attribute* attr = &prim->attributes[i];
				const cgltf_accessor* acce = attr->data;
				const cgltf_buffer_view* bview = acce->buffer_view;
				// [System debug:"Attribute: %s", attr->name];
				// [System debug:"Count: %i", acce->count];
				// [System debug:"Stride: %i", acce->stride];
				switch (attr->type) {
					case cgltf_attribute_type_position: {
						model_data.position.data = bview->buffer->data + acce->offset + bview->offset;
						model_data.position.count = acce->count;
						attributes[i] = MA_POSITION3;
					} break;
					case cgltf_attribute_type_normal: {
						model_data.normal.data = bview->buffer->data + acce->offset + bview->offset;
						model_data.normal.count = acce->count;
						attributes[i] = MA_NORMAL3;
					} break;
					case cgltf_attribute_type_tangent: {
						model_data.tangent.data = bview->buffer->data + acce->offset + bview->offset;
						model_data.tangent.count = acce->count;
						attributes[i] = MA_TANGENT;
					} break;
					case cgltf_attribute_type_texcoord: {
						if (attr->index == 0) {
							model_data.texcoord[0].data = bview->buffer->data + acce->offset + bview->offset;
							model_data.texcoord[0].type = acce->component_type;
							model_data.texcoord[0].count = acce->count;
						} else {
							model_data.texcoord[1].data = bview->buffer->data + acce->offset + bview->offset;
							model_data.texcoord[1].type = acce->component_type;
							model_data.texcoord[1].count = acce->count;
						}
						attributes[i] = MA_TEXCOORD;
					} break;
					case cgltf_attribute_type_color: {
						model_data.color.data = bview->buffer->data + acce->offset + bview->offset;
						model_data.color.type = acce->component_type;
						model_data.color.count = acce->count;
						attributes[i] = MA_COLOR4;
					} break;
					case cgltf_attribute_type_joints: {
						model_data.joints.data = bview->buffer->data + acce->offset + bview->offset;
						model_data.joints.type = acce->component_type;
						model_data.joints.count = acce->count;
						attributes[i] = MA_JOINTS;
					} break;
					case cgltf_attribute_type_weights: {
						model_data.weights.data = bview->buffer->data + acce->offset + bview->offset;
						model_data.weights.type = acce->component_type;
						model_data.weights.count = acce->count;
						attributes[i] = MA_WEIGHTS;
					} break;
					default: [System fatal:"Unknown Mesh Attribute Type: %i", attr->type];
				}
			}
			[primitive setAttributes:attributes attributesCount:prim->attributes_count];

			// get primitive type
			MeshPrimitiveMode mode = MPT_TRIANGLE_STRIP;
			switch (prim->type) {
				case cgltf_primitive_type_points: mode = MPT_POINTS; break;
				case cgltf_primitive_type_lines: mode = MPT_LINES; break;
				case cgltf_primitive_type_line_loop: mode = MPT_LINE_LOOP; break;
				case cgltf_primitive_type_line_strip: mode = MPT_LINE_STRIP; break;
				case cgltf_primitive_type_triangles: mode = MPT_TRIANGLES; break;
				case cgltf_primitive_type_triangle_strip: mode = MPT_TRIANGLE_STRIP; break;
				case cgltf_primitive_type_triangle_fan: mode = MPT_TRIANGLE_FAN; break;
				default: mode = MPT_TRIANGLE_STRIP;
			}

			// process vertices
			if (model_data.position.count == 0) [System fatal:"This model does not have 'POSITION' attribute!"];
			// [System debug:"%i", model_data.position.count];
			MeshVertex* vertices = calloc(model_data.position.count, sizeof(MeshVertex));
			for (Size i = 0; i < model_data.position.count; i++) {
				MeshVertex* vertex = &vertices[i];
				// position
				memcpy(vertex->position, model_data.position.data + i * 3, 3 * sizeof(float));
				// color
				if (model_data.color.count != 0) {
					if (model_data.color.atype == cgltf_type_vec3) {
						if (model_data.color.type == cgltf_component_type_r_8u) {
							[System fatal:"VEC3 Byte colors are unsupported!"];
						} else if (model_data.color.type == cgltf_component_type_r_16u) {
							[System fatal:"VEC3 Short colors are unsupported!"];
						} else {
							// float
							memcpy(vertex->color, model_data.color.data + i * 3, 3 * sizeof(float));
							vertex->color[3] = 1.0f;
						}
					} else {
						if (model_data.color.type == cgltf_component_type_r_8u) {
							[System fatal:"VEC4 Byte colors are unsupported!"];
						} else if (model_data.color.type == cgltf_component_type_r_16u) {
							[System fatal:"VEC4 Short colors are unsupported!"];
						} else {
							// float
							memcpy(vertex->color, model_data.color.data + i * 4, 4 * sizeof(float));
						}
					}
				} else
					memcpy(vertex->color, (float[4]){ 1.0f, 1.0f, 1.0f, 1.0f }, 4 * sizeof(float));
				// normal
				if (model_data.normal.count != 0) {
					memcpy(vertex->normal, model_data.normal.data + i * 3, 3 * sizeof(float));
				} // else
				  // memcpy(vertex->normal, (float[3]){ 0.0f, 0.0f, 0.0f }, 3 * sizeof(float));

				// texcoords
				if (model_data.texcoord[0].count != 0) {
					if (model_data.texcoord[0].type != cgltf_component_type_r_32f) {
						[System fatal:"vec2 float texcoords are only supported!"];
					}
					vertex->texcoord0_u = *(model_data.texcoord[0].data + i * 2 + 0);
					vertex->texcoord0_v = *(model_data.texcoord[0].data + i * 2 + 1);
				}
				if (model_data.texcoord[1].count != 0) {
					if (model_data.texcoord[1].type != cgltf_component_type_r_32f) {
						[System fatal:"vec2 float texcoords are only supported!"];
					}
					vertex->texcoord1[0] = *(model_data.texcoord[1].data + i * 2 + 0);
					vertex->texcoord1[1] = *(model_data.texcoord[1].data + i * 2 + 1);
				}

				// joints
				if (model_data.joints.count != 0) {
					if (model_data.joints.type == cgltf_component_type_r_16u) {
						memcpy(vertex->joints, model_data.joints.data + i * 4, 4 * sizeof(unsigned short));
					} else if (model_data.joints.type == cgltf_component_type_r_8u) {
						uint8_t* ptr = (uint8_t*)model_data.joints.data;
						vertex->joints[0] = ptr[i * 4 + 0];
						vertex->joints[1] = ptr[i * 4 + 1];
						vertex->joints[2] = ptr[i * 4 + 2];
						vertex->joints[3] = ptr[i * 4 + 3];
					} else
						[System fatal:"joints support only 'unsigned short/byte' type!"];
				} else {
					// default value
					memcpy(vertex->joints, (unsigned short[4]){ -1, -1, -1, -1 }, 4 * sizeof(unsigned short));
				}

				// weights
				if (model_data.weights.count != 0) {
					if (model_data.weights.type == cgltf_component_type_r_32f) {
						memcpy(vertex->weights, model_data.weights.data + i * 4, 4 * sizeof(float));
					} else if (model_data.weights.type == cgltf_component_type_r_8u) {
						[System fatal:"8u"];
						const uint8_t* ptr = (uint8_t*)model_data.weights.data;
						vertex->weights[0] = ((float)ptr[i * 4 + 0] / 255.0f);
						vertex->weights[1] = ((float)ptr[i * 4 + 1] / 255.0f);
						vertex->weights[2] = ((float)ptr[i * 4 + 2] / 255.0f);
						vertex->weights[3] = ((float)ptr[i * 4 + 3] / 255.0f);
					} else if (model_data.weights.type == cgltf_component_type_r_16u) {
						[System fatal:"16u"];
						const uint16_t* ptr = (uint16_t*)model_data.weights.data;
						vertex->weights[0] = ((float)ptr[i * 4 + 0] / 65535.0f);
						vertex->weights[1] = ((float)ptr[i * 4 + 1] / 65535.0f);
						vertex->weights[2] = ((float)ptr[i * 4 + 2] / 65535.0f);
						vertex->weights[3] = ((float)ptr[i * 4 + 3] / 65535.0f);
					} else
						[System fatal:"weights support only 'unsigned short/byte' or 'float' type!"];
				} else {
					memcpy(vertex->weights, (float[4]){ 0.0f, 0.0f, 0.0f, 0.0f }, 4 * sizeof(float));
				}
			}

			// process material
			// prim->material
			if (prim->material) {
				const cgltf_size mindex = cgltf_material_index(data, prim->material);
				[primitive setMaterial:[m_materials getByIndex:mindex]];
			}

			[primitive setVertices:vertices verticesCount:model_data.position.count];
			[primitive create:mode];
			[primitives push:primitive];
		}
		Mesh* mesh = [Mesh new];
		[mesh create:primitives]; // weights:data_mesh->weights weightsCount:data_mesh->weights_count
		[m_meshes push:mesh];
		// * no need to dealloc cuz it will be assigned in the Mesh class
		// [primitives dealloc];
	}
}

- (void)processNodes:(const cgltf_data*)data {
	// process nodes
	for (cgltf_size n = 0; n < data->nodes_count; n++) {
		const cgltf_node* dnode = &data->nodes[n];
		// [System debug:"%004lu. node: %s", dnode->name];
		Node* node = [Node new];
		[[node name] setBuffer:dnode->name];
		if (dnode->mesh) {
			[node setMesh:[m_meshes getByIndex:cgltf_mesh_index(data, dnode->mesh)]];
		}
		if (dnode->has_matrix) glm_mat4_make(dnode->matrix, *[node matrix]);
		if (dnode->has_translation) glm_vec3_make(dnode->translation, *[node translation]);
		if (dnode->has_rotation) glm_vec4_make(dnode->rotation, *[node rotation]);
		if (dnode->has_scale) glm_vec3_make(dnode->scale, *[node scale]);

		[m_nodes push:node];
	}

	// process nodes parent/children
	for (cgltf_size n = 0; n < data->nodes_count; n++) {
		const cgltf_node* dnode = &data->nodes[n];
		Node* node = [m_nodes getByIndex:n];
		if (dnode->parent) {
			const cgltf_size index = cgltf_node_index(data, dnode->parent);
			[node setParent:[m_nodes getByIndex:index]];
		}
		if (dnode->children_count != 0) {
			for (cgltf_size c = 0; c < dnode->children_count; c++) {
				const cgltf_size index = cgltf_node_index(data, dnode->children[c]);
				[[node children] push:[m_nodes getByIndex:index]];
			}
		}
	}
}

- (void)processAnimations:(const cgltf_data*)data {
	// process animation
	for (cgltf_size a = 0; a < data->animations_count; a++) {
		const cgltf_animation* anim = &data->animations[a];
		Animation* animation = [Animation new];
		Array<AnimationSampler*>* samplers = [Array new];
		Array<AnimationChannel*>* channels = [Array new];
		// [System debug:"Animation: %s", anim->name];
		// process samplers
		for (cgltf_size i = 0; i < anim->samplers_count; i++) {
			const cgltf_animation_sampler* smpl = &anim->samplers[i];
			AnimationSampler* sampler = [AnimationSampler new];

			// process interpolation
			switch (smpl->interpolation) {
				case cgltf_interpolation_type_linear: [sampler setInterpolation:AI_LINEAR]; break;
				case cgltf_interpolation_type_step: [sampler setInterpolation:AI_STEP]; break;
				case cgltf_interpolation_type_cubic_spline: [sampler setInterpolation:AI_CUBIC_SPLINE]; break;
				default: [System fatal:"Unknown Animation Interpolation Type: %i", smpl->interpolation];
			}
			// process input
			// TODO: there might be more than one timestamps
			//
			{
				const cgltf_accessor* acce = smpl->input;
				const cgltf_buffer_view* bv = acce->buffer_view;
				// const uint8_t* ptr = bv->buffer->data + acce->offset + bv->offset;
				// [sampler setTimestamp:*ptr];
				float* result = malloc(acce->count * sizeof(float));
				if (result == NULL) [System fatal:"Out of memory!!!"];
				if (acce->component_type != cgltf_component_type_r_32f) [System fatal:"Input should be 'FLOAT' only!"];

				// memcpy(result, ptr, size * sizeof(float));
				for (Size j = 0; j < acce->count; ++j) {
					const size_t offset = acce->offset + bv->offset + j * acce->stride;
					const float* ptr = bv->buffer->data + offset;
					// result[j] = *(ptr + j * acce->stride);
					result[j] = *ptr;

					if (result[j] > [animation maxTime]) [animation setMaxTime:result[j]];
					if (result[j] < [animation minTime]) [animation setMinTime:result[j]];
				}
				// [System debug:"input : %i, %lu", acce->type, acce->count];
				[sampler setTimestamps:result size:acce->count];

				// calculate min/max time
			}
			// process output
			{
				const cgltf_accessor* acce = smpl->output;
				const cgltf_buffer_view* bv = acce->buffer_view;
				if (acce->component_type != cgltf_component_type_r_32f) [System debug:"no"];

				if (acce->type == cgltf_type_vec4) {
					for (cgltf_size j = 0; j < acce->count; ++j) {
						const size_t offset = acce->offset + bv->offset + j * acce->stride;
						const float* ptr = bv->buffer->data + offset;
						Vector4* result = [Vector4 new];
						float val[4];
						memcpy(val, ptr, sizeof(float[4]));

						// [System debug:"%f, %f, %f, %f", val[0], val[1], val[2], val[3]];
						[result setX:val[0] setY:val[1] setZ:val[2] setW:val[3]];
						[[sampler data] push:result];
					}
				} else if (acce->type == cgltf_type_vec3) {
					for (cgltf_size j = 0; j < acce->count; ++j) {
						const size_t offset = acce->offset + bv->offset + j * acce->stride;
						const float* ptr = bv->buffer->data + offset;
						Vector3* result = [Vector3 new];
						float val[3];
						memcpy(val, ptr, sizeof(float[3]));

						[result setX:val[0] setY:val[1] setZ:val[2]];
						// [System debug:"%f, %f, %f", val[0], val[1], val[2]];
						[[sampler data] push:result];
					}
				} else if (acce->type == cgltf_type_scalar) {
					[System fatal:"what?"];
				}

				// [System debug:"sampler: %i", [[sampler data] count]];
				// for (Size i = 0; i < [[sampler data] count]; ++i) {
				// 	Vector3* vec = [[sampler data] getByIndex:i];
				// 	if ([vec type] == VT_VECTOR4) {
				// 		Vector4* vecc = (Vector4*)vec;
				// 		[System debug:"%003i. %f, %f, %f, %f", i, [vecc x], [vecc y], [vecc z], [vecc w]];
				// 		// glm_vec4_print(*[vecc data], stdout);
				// 	} else {
				// 		[System debug:"%003i. %f, %f, %f", i, [vec x], [vec y], [vec z]];
				// 		// glm_vec3_print(*[vec data], stdout);
				// 	}
				// }

				// Size size = 1;
				// if (acce->type == cgltf_type_vec3) size = 3;
				// if (acce->type == cgltf_type_vec4) size = 4;
				// // float* result = malloc(size * sizeof(float) * acce->count);
				// // if (result == NULL) [System fatal:"Out of memory!!!"];

				// if (acce->component_type == cgltf_component_type_r_32f) {
				// 	const float* ptr = bv->buffer->data + acce->offset + bv->offset;
				// 	// for (cgltf_size j = 0; j < acce->count; ++j) {
				// 	// 	// glm_vec4_make(ptr + (j * acce->stride), result[j]);
				// 	// 	for (cgltf_size k = 0; k < size; k++)
				// 	// 		result[j * size + k] = *(ptr + (j * acce->stride) + k);
				// 	// 	// result[j * size + k] = ptr[j * acce->stride + k];
				// 	// }
				// } else [System fatal:"no"];
				// else if (acce->component_type == cgltf_component_type_r_8) {
				// 	[System fatal:"a 8"];
				// 	const int8_t* ptr = bv->buffer->data + acce->offset + bv->offset;
				// 	for (cgltf_size j = 0; j < acce->count; j++) {
				// 		for (cgltf_size k = 0; k < size; k++)
				// 			result[j * size + k] = fmaxf(*(ptr + (j * acce->stride) + k) / 127.0f, -1.0f);
				// 	}
				// } else if (acce->component_type == cgltf_component_type_r_8u) {
				// 	[System fatal:"a 8u"];
				// 	const uint8_t* ptr = bv->buffer->data + acce->offset + bv->offset;
				// 	for (cgltf_size j = 0; j < acce->count; j++) {
				// 		for (cgltf_size k = 0; k < size; k++)
				// 			result[j * size + k] = *(ptr + (j * acce->stride) + k) / 255.0f;
				// 	}
				// } else if (acce->component_type == cgltf_component_type_r_16) {
				// 	[System fatal:"a 16"];
				// 	const int16_t* ptr = bv->buffer->data + acce->offset + bv->offset;
				// 	for (cgltf_size j = 0; j < acce->count; j++) {
				// 		for (cgltf_size k = 0; k < size; k++)
				// 			result[j * size + k] = fmaxf(*(ptr + (j * acce->stride) + k) / 32767.0f, -1.0f);
				// 	}
				// } else if (acce->component_type == cgltf_component_type_r_16u) {
				// 	[System fatal:"a 16u"];
				// 	const uint16_t* ptr = bv->buffer->data + acce->offset + bv->offset;
				// 	for (cgltf_size j = 0; j < acce->count; j++) {
				// 		for (cgltf_size k = 0; k < size; k++)
				// 			result[j * size + k] = *(ptr + (j * acce->stride) + k) / 65535.0f;
				// 	}
				// }
				// [System debug:"output: %i, %lu", acce->type, acce->count];
				// [sampler setData:result size:acce->count];
			}

			// [System debug:"input : %i", ain->component_type];
			// [System debug:"output: %i", aout->component_type];
			[samplers push:sampler];
		}
		// process channels
		for (cgltf_size i = 0; i < anim->channels_count; i++) {
			const cgltf_animation_channel* chnl = &anim->channels[i];
			// [System debug:"channel: %s", chnl->target_node->name];
			AnimationChannel* channel = [AnimationChannel new];

			AnimationSampler* sampler = [samplers getByIndex:cgltf_animation_sampler_index(anim, chnl->sampler)];
			AnimationType type = AT_TRANSLATION;
			switch (chnl->target_path) {
				case cgltf_animation_path_type_translation: type = AT_TRANSLATION; break;
				case cgltf_animation_path_type_rotation: type = AT_ROTATION; break;
				case cgltf_animation_path_type_scale: type = AT_SCALE; break;
				case cgltf_animation_path_type_weights: type = AT_WEIGHTS; break;
				default: [System fatal:"Unknown Animation Path Type: %i", chnl->target_path];
			}

			// Size node_index = cgltf_node_index(data, chnl->target_node);
			Size node_index = cgltf_node_index(data, chnl->target_node);
			Node* target = [m_nodes getByIndex:node_index];
			[channel create:sampler type:type target:target];
			[channel setIndex:node_index];
			[channels push:channel];
		}
		[[animation name] setBuffer:anim->name];
		[animation setSamplers:samplers];
		[animation setChannels:channels];
		[m_animations push:animation];
	}
	if ([m_animations count] > 0) m_current_animation = [m_animations getFirst];
}

- (void)processSceneNodes:(const cgltf_data*)data {
	// process scene nodes
	for (cgltf_size s = 0; s < data->scenes_count; s++) {
		const cgltf_scene* dscn = &data->scenes[s];
		for (cgltf_size n = 0; n < dscn->nodes_count; n++) {
			const cgltf_size index = cgltf_node_index(data, dscn->nodes[n]);
			[m_scene_nodes push:[m_nodes getByIndex:index]];
			[System debug:"Node '%s' is a scene node", [[[m_nodes getByIndex:index] name] buffer]];
		}
		// [m_scene_nodes push:node];
	}
}

- (void)processSkins:(const cgltf_data*)data {
	for (cgltf_size i = 0; i < data->skins_count; i++) {
		const cgltf_skin* skin = &data->skins[i];
		Skin* result = [Skin new];

		// set skeleton root node

		if (skin->skeleton) [result setSkeleton:[m_nodes getByIndex:cgltf_node_index(data, skin->skeleton)]];

		// set joints
		Array<Node*>* joints = [Array new];
		for (cgltf_size j = 0; j < skin->joints_count; j++) {
			const cgltf_size index = cgltf_node_index(data, skin->joints[j]);
			Node* node = [m_nodes getByIndex:index];
			[node setJointIndex:j];
			[joints push:node];
		}
		// TODO: change to just pushing nodes
		[result setJoints:joints];

		// set inverse bind matrices
		if (skin->inverse_bind_matrices) {
			const cgltf_accessor* acce = skin->inverse_bind_matrices;
			const cgltf_buffer_view* bv = acce->buffer_view;
			const cgltf_buffer* b = bv->buffer;
			if (acce->type != cgltf_type_mat4) [System fatal:"Inverse bind matrices accessor is not in MAT4 format!"];
			if (acce->component_type != cgltf_component_type_r_32f) [System fatal:"Inverse bind matrices accessor data sould be in 'FLOAT' type!"];
			mat4* matrices = calloc(acce->count, sizeof(mat4));
			for (Size m = 0; m < acce->count; m++) {
				const size_t offset = bv->offset + acce->offset + m * acce->stride;
				const float* ptr = b->data + offset;
				// mat4 temp; //  = &matrices[m];
				glm_mat4_make(ptr, matrices[m]);
				// glm_mat4_print(temp, stdout);
				// glm_mat4_copy(temp, matrices[m]);
				// glm_mat4_print(matrices[m], stdout);
			}
			[result setInverseBindMatrices:matrices size:acce->count];
		} else {
			// TODO: generate inverse bind matrices
			[System fatal:"generate inverse bind matrices not supported"];
		}
		[m_skins push:result];
	}

	//
	for (Size i = 0; i < data->nodes_count; i++) {
		const cgltf_node* data_node = &data->nodes[i];
		if (data_node->skin) {
			const Size index = cgltf_skin_index(data, data_node->skin);
			Node* node = [m_nodes getByIndex:i];
			[node setSkin:[m_skins getByIndex:index]];
			[System debug:"Node '%s' has skin", [[node name] buffer]];
		}
	}
}

@end
