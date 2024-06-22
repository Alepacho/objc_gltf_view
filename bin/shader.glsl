/*
|| 3D Shader with Animation
|| Copyright (c) 2024 Alepacho
*/

#select general
#version 330 core

#select vertex
layout(location = 0) in vec3  a_position;
layout(location = 1) in float a_texcoord0_u;
layout(location = 2) in vec3  a_normal;
layout(location = 3) in float a_texcoord0_v;
layout(location = 4) in vec4  a_color;
layout(location = 5) in vec4  a_tangent;
layout(location = 6) in ivec4 a_joints;
layout(location = 7) in vec4  a_weights;
layout(location = 8) in vec2  a_texcoord1;

uniform mat4 u_model;
uniform mat4 u_view;
uniform mat4 u_projection;

#define MAX_JOINT_MATRICES 128
uniform mat4 u_joint_matrices[MAX_JOINT_MATRICES];
uniform int u_joint_count;

out Data {
	vec3 position;
	vec4 color;
	vec2 texcoord;
} io_data;

mat4 getSkinMatrix() {
	if (u_joint_count == 0) return mat4(1.0);
	mat4 result = 
		a_weights.x * u_joint_matrices[a_joints.x] +
		a_weights.y * u_joint_matrices[a_joints.y] +
		a_weights.z * u_joint_matrices[a_joints.z] +
		a_weights.w * u_joint_matrices[a_joints.w];
	return result;
}

void main() {
	mat4 skinMatrix = getSkinMatrix();
	vec4 position = vec4(a_position, 1.0);
	mat4 mv = u_view * u_model;
	mat4 mvp = u_projection * mv;

	io_data.position = (mv * skinMatrix * position).xyz;
	io_data.color = a_color;
	io_data.texcoord = vec2(a_texcoord0_u, a_texcoord0_v);
    
	gl_Position = mvp * skinMatrix * position;
}

#select fragment
out vec4 out_FragColor;

in Data {
	vec3 position;
	vec4 color;
	vec2 texcoord;
} io_data;

uniform vec4 u_base_color = vec4(1.0);

uniform sampler2D u_albedo;

void main() {
	vec4 tex = texture(u_albedo, io_data.texcoord);
	vec4 color =  tex * io_data.color;
	out_FragColor = color * vec4(u_base_color.rgb, 1.0);
}
