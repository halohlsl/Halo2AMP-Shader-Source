// File:	 srf_ca_skybox_billboard_diffuse_only.fx
// Author:	 lkruel
// Date:	 12/09/13
//
// Surface Shader - Generic Skybox Shader with fake lighting
// Built in lighting and fog based on exposed vector parameters. 
//
// Notes:
//

#define DISABLE_LIGHTING_TANGENT_FRAME
#define DISABLE_LIGHTING_VERTEX_COLOR
#define DISABLE_SHARPEN_FALLOFF


// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"


//.. Artistic Parameters

// Texture Samplers

DECLARE_SAMPLER( normal_map, "Normal Map", "", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( color_map, "Albedo Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(albedo_tint,		"Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"


//Fake lighting
DECLARE_BOOL_WITH_DEFAULT(divider_01, "===========================", "", false);
	

DECLARE_FLOAT_WITH_DEFAULT(light_1_x, "Light 1         X", "", -1, 1, float(0.6));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_y, "Light 1         Y", "", -1, 1, float(0.2));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_z, "Light 1         Z", "", -1, 1, float(0.2));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_intensity, "Light 1      Int", "", 0, 100, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(light_1_color, "Light 1  Color", "", float3(1,.937,.831));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_wrap, "Light 1  Wrap", "", 0, 1, float(0.0));
#include "used_float3.fxh"


DECLARE_FLOAT_WITH_DEFAULT(light_2_x, "Light 2         X", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_y, "Light 2         Y", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_z, "Light 2         Z", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_intensity, "Light 2      Int", "", 0, 100, float(0.5));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(light_2_color, "Light 2  Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_wrap, "Light 2  Wrap", "", 0, 1, float(0.0));
#include "used_float3.fxh"



DECLARE_BOOL_WITH_DEFAULT(divider_03, "===========================", "", false);

DECLARE_RGB_COLOR_WITH_DEFAULT(ambient_color, "Ambient Color", "", float3(0,0,0));
#include "used_float3.fxh"

///

struct s_shader_data {
	s_common_shader_data common;
    //float  alpha;
};

#ifndef cgfx

	#define custom_deformer(vertex, vertexColor, localToWorld) \
	{																		\
		float2x3 basis;\
		basis[0] = vs_view_camera_right;\
		basis[1] = vs_view_camera_up;\
		vertex.position.xyz = mul(vertex.position, basis);\
		vertex.normal.xyz = mul(vertex.normal, basis);\
		vertex.tangent.xyz = mul(vertex.tangent, basis);\
	}

#endif 


void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
			
{
	float2 uv = pixel_shader_input.texcoord.xy;

	shader_data.common.shaderValues.x = 1.0f; 			// Default specular mask
   	float2 normal_uv   = transform_texcoord(uv, normal_map_transform);
    float3 normal = sample_2d_normal_approx(normal_map, normal_uv);
		
	// Transform from tangent space to world space
	shader_data.common.normal = mul(normalize(normal), shader_data.common.tangent_frame);
		
	
	// Sample water color map and alpha
	float2 color_map_uv = transform_texcoord(uv, color_map_transform);
	float4 albedo = sample2DGamma(color_map, color_map_uv);
	
	shader_data.common.albedo.rgb = albedo.rgb * albedo_tint;
	
}		
		
		
float4 pixel_lighting(
	in s_pixel_shader_input pixel_shader_input,
	inout s_shader_data shader_data) 
{
 	float2 uv = pixel_shader_input.texcoord.xy;
		// input from s_shader_data
    float4 albedo         = shader_data.common.albedo ;
    float3 normal         = shader_data.common.normal;
	

	float3 light_1 = normalize(float3(light_1_x, light_1_y, light_1_z));
	float3 light_2 = normalize(float3(light_2_x, light_2_y, light_2_z));
	
    float3 diffuse = 0.0f;

	///..Half Lambert 
	float wrap_1 = 1-light_1_wrap;
	float wrap_2 = 1-light_2_wrap;
	float lambert_1 = saturate(dot(normal, light_1)  * wrap_1 + (1-wrap_1)) ;
	float lambert_2 = saturate(dot(normal, light_2)  * wrap_2 + (1-wrap_2)) ;
	diffuse = (lambert_1 * light_1_color * light_1_intensity) + (lambert_2 * light_2_color * light_2_intensity);


	float4 out_color = float4(0.0f, 0.0f, 0.0f, 1.0f);
	out_color.rgb = shader_data.common.albedo.rgb;
	

		//.. Finalize Output Color
	//out_color.a   = shader_data.alpha;
	float3 color_map =  albedo; 
	diffuse +=  ambient_color.rgb;
	out_color.rgb = color_map * diffuse;
	return out_color;
}


#include "techniques.fxh"
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	






