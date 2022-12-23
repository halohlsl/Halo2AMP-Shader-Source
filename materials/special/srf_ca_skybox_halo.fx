//
// File:	 srf_ca_skybox_halo.fx
// Author:	 lkruel
// Date:	 12/09/13
//
// Surface Shader - Skybox Halo Shader
// Built in lighting based on exposed vector parameters. 
//
// Notes:
//

#define DISABLE_LIGHTING_TANGENT_FRAME
#define DISABLE_LIGHTING_VERTEX_COLOR
#define DISABLE_SHARPEN_FALLOFF
#define VERTEX_ALPHA

// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"


//.. Artistic Parameters

// Texture Samplers
DECLARE_SAMPLER( color_map, "Color Map", "Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( shadow_map, "Shadow Map", "Shadow Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( cloud_map, "Cloud Map", "Cloud Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"


// Diffuse
DECLARE_FLOAT_WITH_DEFAULT(cloud_intensity, 	"Cloud Intensity", "", 0, 10, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(cloud_shadow_intensity, 	"Cloud Shadow Intensity", "", 0, 10, float(1.0));
#include "used_float.fxh"


DECLARE_RGB_COLOR_WITH_DEFAULT(ambient_color, "Ambient Color", "", float3(0,0,0));
#include "used_float3.fxh"

#ifdef cgfx
DECLARE_BOOL_WITH_DEFAULT(divider_04, "===========================", "", false);
#endif 

DECLARE_FLOAT_WITH_DEFAULT(fog_start,	"Fog Start", "", 0, 9999, float(1000.00));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_end,		"Fog End  ", "", 0, 9999, float(4000.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_bottom,		"Fog Bottom ", "", -1000000, 1000000, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_top,		"Fog Top ", "", -1000000, 1000000, float(2000.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_y_multiplier_start,		"Fog Y Multiplier Start", "", -1000000, 1000000, float(500.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_y_multiplier_end,		"Fog Y Multiplier End", "", -1000000, 1000000, float(2000.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(fog_color, "Fog Color", "", float3(.514,.722,.757));
#include "used_float3.fxh"



struct s_shader_data {
	s_common_shader_data common;
};

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;
	float2 uv2 = pixel_shader_input.texcoord.zw;

    {// Sample color map.
	    float2 color_map_uv = transform_texcoord(uv, color_map_transform);
	    float4 color = sample2DGamma(color_map, color_map_uv);
		
	// Sample shadow map.
		float2 shadow_map_uv = transform_texcoord(uv2, shadow_map_transform); 
		float4 shadow = sample2DGamma(shadow_map, shadow_map_uv);
		
	// Sample cloud map.
		float2 cloud_map_uv = transform_texcoord(uv, cloud_map_transform); 
		float4 clouds = sample2DGamma(cloud_map, cloud_map_uv);
		
		
	//..Fake Fog
	float depthFade = 1.0f;
	float depth_fade = float_remap(shader_data.common.view_dir_distance.w, fog_start, fog_end, 1, 0);
	float depth_height = float_remap(shader_data.common.position.z, fog_bottom, fog_top, 0, 1);
	float3 final_fog_value = saturate(1-depth_fade * 1-depth_height) * shader_data.common.vertexColor.a * shadow;
	
	#if defined(cgfx)
	final_fog_value *= 0.0f;
	#endif
	
	float3 cloud_shadows = saturate(1-clouds.g * cloud_shadow_intensity);
	
	shader_data.common.albedo = (color * float4(cloud_shadows, 0)) + float4(ambient_color.rgb, 0) + (clouds.r * cloud_intensity);
	shader_data.common.albedo = shader_data.common.albedo * shadow;
	shader_data.common.albedo *= shader_data.common.vertexColor.a;
	
	shader_data.common.albedo.rgb = lerp(shader_data.common.albedo.rgb, fog_color, final_fog_value);

	}
	
}

 
float4 pixel_lighting(
	        in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)

			
{
		// input from s_shader_data
    float4 albedo  = shader_data.common.albedo ;

	
		//.. Finalize Output Color
	float4 out_color = float4(0.0f, 0.0f, 0.0f, 1.0f);
	out_color.rgb =  albedo;

	
	return out_color;
}


#include "techniques.fxh"