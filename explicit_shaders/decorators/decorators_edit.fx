#include "core/core.fxh"
#include "core/core_vertex_types.fxh"

#include "deform.fxh"
#include "exposure.fxh"
#include "../utility/wind.fxh"

#include "decorators_registers.fxh"

#define SIMPLE_LIGHT_DATA v_simple_lights
#define SIMPLE_LIGHT_COUNT v_simple_light_count
#undef dynamic_lights_use_array_notation			// decorators dont use array notation, they use loop-friendly notation
#include "lighting/simple_lights.fxh"

#if DX_VERSION == 11
#include "packed_vector.fxh"
#endif

#define k_decorator_alpha_test_threshold 0.5f

#define vertex_compression_scale vs_mesh_position_compression_scale
#define vertex_compression_offset vs_mesh_position_compression_offset
#define texture_compression vs_mesh_uv_compression_scale_offset

LOCAL_SAMPLER2D(diffuse_texture, 0);			// pixel shader

struct s_decorator_vertex_output
{
	float4	position			:	SV_Position;
	float2	texcoord			:	TEXCOORD0;
	float3	world_position		:	TEXCOORD1;
};

struct s_edit_decorator_vertex
{
	float4 position:		POSITION0;
	float2 texcoord:		TEXCOORD0;
};

s_decorator_vertex_output default_vs(
	in s_edit_decorator_vertex input )
{
	s_decorator_vertex_output output;

	float3 vertex_position = input.position;
	//float2 vertex_texcoord = input.texcoord;
	//float2 vertex_texcoord = float2( input.position.w, input.texcoord.x );//AWful HACK, I need to fix the VB format so this is done correctly.
	float2 vertex_texcoord = float2( input.position[3], input.texcoord[1] );//AWful HACK, I need to fix the VB format so this is done correctly. - Best so far - NMates 2015/02/12

	// decompress position
	vertex_position.xyz = vertex_position.xyz * vertex_compression_scale.xyz + vertex_compression_offset.xyz;

	output.world_position= quaternion_transform_point(instance_quaternion, vertex_position.xyz) * instance_position_and_scale.w + instance_position_and_scale.xyz;
	output.position= mul(float4(output.world_position.xyz, 1.0f), vs_view_view_projection_matrix);
	
	output.texcoord= vertex_texcoord.xy * texture_compression.xy + texture_compression.zw;
	return output;
}

float4 default_ps(
	const in s_decorator_vertex_output input) : SV_Target
{
	float4 diffuse_albedo= sample2D(diffuse_texture, input.texcoord.xy);
	clip(diffuse_albedo.a - k_decorator_alpha_test_threshold);				// alpha test

	float4 color= diffuse_albedo * pc_ambient_light * ps_view_exposure.rrrr;

	// blend in selection cursor
	float dist= distance(input.world_position, selection_point.xyz);
	float alpha= step(dist, selection_point.w);
	alpha *= selection_color.w;
	color.rgb= lerp(color.rgb, selection_color.rgb, alpha);

	// dim materials by wet
	//color.rgb*= k_ps_wetness_coefficients.x;
	
	//HACK "pack" rgbk
	color.a = 1.0f;
	
	return color;//apply_exposure(color);
}

BEGIN_TECHNIQUE _default
{
	pass world
	{
		SET_VERTEX_SHADER(default_vs());
		SET_PIXEL_SHADER(default_ps());
	}
}
