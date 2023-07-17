
// File:	 srf_ca_skybox_cloudblend.fx
// Author:	 mahlin
// Date:	 04/14/2014
//
// Surface Shader - Multiplies two cloud textures (with uv disortion) and adds them onto a base texture with alpha channel and vertex alpha
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

DECLARE_SAMPLER( base_texture, "Base Texture", "Base Texture", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( cloud_texture_a, "Cloud Texture A", "Cloud Texture A", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( cloud_texture_b, "Cloud Texture B", "Cloud Texture B", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( cloud_mask_texture, "Cloud Mask", "Cloud Mask", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER(uvOffsetMap, "UV Offset Map", "UV Offset map", "shaders/default_bitmaps/bitmaps/alpha_white.tif")
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(uvOffsetStrength, "UV Offset Strength", "", 0, 1, float(0.1));
#include "used_float.fxh"

DECLARE_SAMPLER(lightmap_texture, "lightmap", "", "shaders/default_bitmaps/bitmaps/alpha_white.tif")
#include "next_texture.fxh"

// Parameters

DECLARE_RGB_COLOR_WITH_DEFAULT(base_color,		"Base Texture Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(base_intensity, "Base Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(cloud_a_color,		"Cloud Texture A Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(cloud_a_intensity, "Cloud A Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(cloud_b_color,		"Cloud Texture B Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(cloud_b_intensity, "Cloud B Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

#ifdef USE_SELF_ILLUM
    DECLARE_SAMPLER( selfillum_map, "SelfIllum Map", "SelfIllum Map", "shaders/default_bitmaps/bitmaps/default_diff.tif")
    #include "next_texture.fxh"

    // Self Illum
    DECLARE_RGB_COLOR_WITH_DEFAULT(si_color,	"SelfIllum Color", "", float3(0,0,0));
    #include "used_float3.fxh"
    DECLARE_FLOAT_WITH_DEFAULT(si_intensity,	"SelfIllum Intensity", "", 0, 1, float(1.0));
    #include "used_float.fxh"
#endif 
struct s_shader_data {
	s_common_shader_data common;
	
};

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
			
{

#if defined(xenon)
	float2 warped_uvs = transform_texcoord(pixel_shader_input.texcoord.zw, uvOffsetMap_transform);
	float2 offsetValue = sample2D(uvOffsetMap, warped_uvs).rg;
	
	// Compute the uv offset
	float2 uvOffset = uvOffsetStrength * offsetValue;
	
	#else // PC for speed
	float2 uvOffset = 0.0f;
	
#endif	

	float2 uv = pixel_shader_input.texcoord.xy;
	float2 uv2 = pixel_shader_input.texcoord.zw;

///	
		// Sample base texture
	float2 base_map_uv   = transform_texcoord(uv, base_texture_transform);
	float4 base_map = sample2DGamma(base_texture, base_map_uv);

		// Sample Cloud_a texture
	float2 cloud_a_uv   = transform_texcoord(uv2, cloud_texture_a_transform) + uvOffset;
	float4 cloud_a = sample2DGamma(cloud_texture_a, cloud_a_uv);

		// Sample Cloud_b texture
	float2 cloud_b_uv   = transform_texcoord(uv2, cloud_texture_b_transform) + uvOffset;
	float4 cloud_b = sample2DGamma(cloud_texture_b, cloud_b_uv);

		// Sample lerp mask texture
	float2 cloud_mask_uv   = transform_texcoord(uv, cloud_mask_texture_transform);
	float4 cloud_mask = sample2DGamma(cloud_mask_texture, cloud_mask_uv);
	
		// Sample lightmap texture
	const float MACRO_MULTIPLIER = 4.59479f;		// 4.59479f == 2 ^ 2.2  (sRGB gamma)
	float2 lightmap_uv   = transform_texcoord(uv2, lightmap_texture_transform);
	float4 lightmap = sample2DGamma(lightmap_texture, lightmap_uv)*MACRO_MULTIPLIER;


        //Colorize the textures
    float3 base_colorized = base_map * base_color * base_intensity;
    float3 cloud_a_colorized = cloud_a * cloud_a_color * cloud_a_intensity;    
    float3 cloud_b_colorized = cloud_b * cloud_b_color * cloud_b_intensity;


        //Combine the textures
	float3 combined_clouds = cloud_a_colorized * cloud_b_colorized;
	combined_clouds *= lightmap.rgb;
    shader_data.common.albedo.rgb = lerp(base_colorized, combined_clouds, cloud_mask.r);
	//shader_data.common.albedo.rgb = (cloud_a_colorized * cloud_b_colorized * cloud_mask) + base_colorized;
	
	// Respect vertex alpha
	shader_data.common.albedo.a = base_map.a  * shader_data.common.vertexColor.a;

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
	
    #ifdef USE_SELF_ILLUM 
        
        float2 si_map_uv 	   = transform_texcoord(uv, selfillum_map_transform);
        float3 self_illum = sample2DGamma(selfillum_map, si_map_uv).rgb;
        self_illum *= si_color * si_intensity;
        out_color.rgb += self_illum;

        // Output self-illum intensity as linear luminance of the added value
        shader_data.common.selfIllumIntensity = GetLinearColorIntensity(self_illum);    

    #endif     
    out_color.a   = albedo.a;

	return out_color;
}


#include "techniques.fxh"













		
