
// File:	 srf_ca_skybox_multiply_2uv_clip.fx
// Author:	 mahlin
// Date:	 04/14/2014
//
// Surface Shader - Multiplies two textures together, the second texture is in the second uv set, it also has clip capabilities
//
//
//

#define DISABLE_LIGHTING_TANGENT_FRAME
#define DISABLE_LIGHTING_VERTEX_COLOR
#define DISABLE_SHARPEN_FALLOFF

// Core Includes

#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"


// Texture Samplers

DECLARE_SAMPLER( base_texture, "Base Texture", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( lightmap_texture, "Multiply Texture", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

// Parameters
DECLARE_RGB_COLOR_WITH_DEFAULT(base_color,		"Base Texture Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(base_intensity, "Base Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

#define MATERIAL_SHADER_ANNOTATIONS 	<bool is_alpha_clip = true;>

DECLARE_FLOAT_WITH_DEFAULT(clip_threshold,		"Clipping Threshold", "", 0, 1, float(0.3));
#include "used_float.fxh"


struct s_shader_data {
	s_common_shader_data common;
	
};

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
			
{

	float2 uv = pixel_shader_input.texcoord.xy;
	float2 uv2 = pixel_shader_input.texcoord.zw;

		// Sample base texture
	float2 base_map_uv   = transform_texcoord(uv, base_texture_transform);
	float4 base_map = sample2DGamma(base_texture, base_map_uv);
	
		// Sample lightmap texture
	const float MACRO_MULTIPLIER = 4.59479f;		// 4.59479f == 2 ^ 2.2  (sRGB gamma)
	float2 lightmap_uv   = transform_texcoord(uv2, lightmap_texture_transform);
	float4 lightmap = sample2DGamma(lightmap_texture, lightmap_uv)*MACRO_MULTIPLIER;


        //Colorize the textures
    float3 base_colorized = base_map * base_color * base_intensity;
	base_colorized *= lightmap.rgb;
    shader_data.common.albedo.rgb = base_colorized;
	shader_data.common.albedo.a = base_map.a;
	//shader_data.common.albedo.rgb = (cloud_a_colorized * cloud_b_colorized * cloud_mask) + base_colorized;
	

	// Tex kill pixel
	clip(shader_data.common.albedo.a - clip_threshold);
	

}	

    float4 pixel_lighting(
	in s_pixel_shader_input pixel_shader_input,
	inout s_shader_data shader_data)
	
{

	float2 uv = pixel_shader_input.texcoord.xy;
 
	///..input from s_shader_data
    float4 albedo         = shader_data.common.albedo;


    	//.. Finalize Output Color

	float4 out_color = float4(0.0f, 0.0f, 0.0f, 1.0f);
	out_color.rgb = shader_data.common.albedo.rgb;
	out_color.a   = albedo.a;

	return out_color;
}


#include "techniques.fxh"













		
