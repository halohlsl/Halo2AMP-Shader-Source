
// File:	 srf_ca_skybox_cloudlayer.fx
// Author:	 mahlin
// Date:	 02/26/2014
//
// Surface Shader - Skybox cloud layer with depth fade
// Built in lighting and fog based on exposed vector parameters. 
//
// Notes:
//


#define DISABLE_LIGHTING_TANGENT_FRAME
#define DISABLE_LIGHTING_VERTEX_COLOR
#define DISABLE_SHARPEN_FALLOFF

#define ENABLE_DEPTH_INTERPOLATER

#if defined(xenon)
#define ENABLE_VPOS
#endif

// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"
#include "ca_depth_access.fxh"

// Texture Samplers

DECLARE_SAMPLER( cloud_alpha_map, "Cloud Alpha Map", "Cloud Alpha Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( cloud_normal_map, "Cloud Normal Map", "Cloud Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

#ifdef USE_MASK
	DECLARE_SAMPLER( cloud_mask_map, "Cloud Mask Map", "Cloud Mask Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
	#include "next_texture.fxh"
#endif

// Diffuse
DECLARE_RGB_COLOR_WITH_DEFAULT(cloud_color,		"Cloud Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(cloud_opacity, "Cloud Opacity", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(normal_strength, "Normal Strength", "", 0, 10, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(depth_fade_range,  "Depth Fade Range", "", 0, 5, float(0.4));
#include "used_float.fxh"

#ifdef cgfx
	//Fake lighting
	DECLARE_BOOL_WITH_DEFAULT(divider_01, "===========================", "", false);
#endif 

DECLARE_FLOAT_WITH_DEFAULT(light_1_x, "Light 1         X", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_y, "Light 1         Y", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_z, "Light 1         Z", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_intensity, "Light 1      Int", "", 0, 100, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(light_1_color, "Light 1  Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_wrap, "Light 1  Wrap", "", 0, 1, float(0.0));
#include "used_float3.fxh"

#ifdef cgfx
	DECLARE_BOOL_WITH_DEFAULT(divider_02, "===========================", "", false);
#endif 

DECLARE_FLOAT_WITH_DEFAULT(light_2_x, "Light 2         X", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_y, "Light 2         Y", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_z, "Light 2         Z", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_intensity, "Light 2      Int", "", 0, 100, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(light_2_color, "Light 2  Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_wrap, "Light 2  Wrap", "", 0, 1, float(0.0));
#include "used_float3.fxh"

struct s_shader_data {
	s_common_shader_data common;
	float  alpha;
};

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
			
{
		float2 uv = pixel_shader_input.texcoord.xy;
		float2 uv2 = pixel_shader_input.texcoord.zw;
	
///	
		// Sample alpha map
    	float2 cloud_alpha_uv   = transform_texcoord(uv, cloud_alpha_map_transform);
        float4 cloud_alpha = sample2DGamma(cloud_alpha_map, cloud_alpha_uv);
		
		// Sample normal map
    	float2 cloud_normal_uv   = transform_texcoord(uv, cloud_normal_map_transform);
        float3 cloud_normal = sample_2d_normal_approx(cloud_normal_map, cloud_normal_uv);

	float depthFadeAmount = 1.0;
	#ifndef USE_MASK
		///Depth factor	
			
		#if defined(xenon) || (DX_VERSION == 11)
		{
			float sceneDepth = 0;
			float2 vPos = shader_data.common.platform_input.fragment_position.xy;
			sampleDepth( vPos * psDepthConstants.z, sceneDepth );

			float deltaDepth = sceneDepth - pixel_shader_input.view_vector.w;
			depthFadeAmount = saturate(deltaDepth / depth_fade_range);
		}
		#endif
	#else
		float2 cloud_mask_uv   = transform_texcoord(uv2, cloud_mask_map_transform);
        float4 cloud_mask = sample2DGamma(cloud_mask_map, cloud_mask_uv);
		depthFadeAmount = cloud_mask.r;
	
	#endif
		
		float3 color = cloud_color;
		shader_data.common.albedo.rgb = cloud_alpha * cloud_color * depthFadeAmount;
				
		shader_data.alpha = cloud_alpha * cloud_opacity * depthFadeAmount;
		
		shader_data.common.normal = cloud_normal;
		shader_data.common.normal.xy = shader_data.common.normal.xy * normal_strength;
		
		// Transform from tangent space to world space
		shader_data.common.normal = mul(normalize(shader_data.common.normal), shader_data.common.tangent_frame);

}		
		
		
float4 pixel_lighting(
	in s_pixel_shader_input pixel_shader_input,
	inout s_shader_data shader_data)
	
{

	float2 uv = pixel_shader_input.texcoord.xy;
 
	///..input from s_shader_data
    float4 albedo         = shader_data.common.albedo;
    float3 normal         = shader_data.common.normal;

	///..Fake lighting vectors
	float3 light_1 = normalize(float3(light_1_x, light_1_y, light_1_z));
	float3 light_2 = normalize(float3(light_2_x, light_2_y, light_2_z));

    float3 diffuse = 0.0f;
	
	///..Half Lambert 
	float wrap_1 = 1-light_1_wrap;
	float wrap_2 = 1-light_2_wrap;
	float lambert_1 = saturate(dot(normal, light_1)  * wrap_1 + (1-wrap_1)) ;
	float lambert_2 = saturate(dot(normal, light_2)  * wrap_2 + (1-wrap_2)) ;
	diffuse = (lambert_1 * light_1_color * light_1_intensity) + (lambert_2 * light_2_color * light_2_intensity);

	
		//.. Finalize Output Color

	float4 out_color = float4(0.0f, 0.0f, 0.0f, shader_data.alpha);
	out_color.rgb =  diffuse * albedo;
	out_color.a   = shader_data.alpha;

	return out_color;
}


#include "techniques.fxh"
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	