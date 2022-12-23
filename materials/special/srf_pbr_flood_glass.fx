//
// File:	 srf_blinn.fx
// Author:	 hocoulby
// Date:	 06/16/10
//
// Surface Shader - Standard Blinn
//
// Copyright (c) 343 Industries. All rights reserved.
//
// Notes:
//

#if !defined(ALPHA_CLIP)
	#define DISABLE_LIGHTING_TANGENT_FRAME
	#define DISABLE_LIGHTING_VERTEX_COLOR

	#define DISABLE_SHARPEN_FALLOFF
#endif


// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"

//.. Artistic Parameters

// Texture Samplers
DECLARE_SAMPLER( color_map, "Color Map", "Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( normal_map, "Normal Map", "Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( combo_map, "Combo Map", "Combo Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"


DECLARE_SAMPLER_CUBE(reflection_map,  "Reflection Map", "", "shaders/default_bitmaps/bitmaps/default_cube.tif")
#include "next_texture.fxh"

// Diffuse
DECLARE_RGB_COLOR_WITH_DEFAULT(albedo_tint,		"Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(roughness, "Roughness Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(metallicness, "Metallicness Multiplier", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(cavity_mult, "Cavity Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(emissive_mult, "Emissive Multiplier", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(emissive_tint,		"Emissive Tint", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(opaqueness, "Opaqueness", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(reflection_intensity, "Reflection Intensity", "", 0, 10, float(5.0));
#include "used_float.fxh"

#if defined(ALPHA_CLIP)
#define MATERIAL_SHADER_ANNOTATIONS 	<bool is_alpha_clip = true;>
#endif

#if defined(HEIGHT_MASK)
    DECLARE_FLOAT_WITH_DEFAULT(height_influence, "Height Map Influence", "", 0, 1, float(1.0));
    #include "used_float.fxh"
    DECLARE_FLOAT_WITH_DEFAULT(threshold_softness, "Height Map Threshold Softness", "", 0.01, 1, float(0.1));
    #include "used_float.fxh"
#endif


///
#if defined(ALPHA_CLIP) && !defined(ALPHA_CLIP_ALBEDO_ONLY)
DECLARE_FLOAT_WITH_DEFAULT(clip_threshold,		"Clipping Threshold", "", 0, 1, float(0.3));
#include "used_float.fxh"
#elif defined(ALPHA_CLIP)
static const float clip_threshold = 240.0f / 255.0f;
#endif

struct s_shader_data {
	s_common_shader_data common;
};

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;

	shader_data.common.shaderValues.x = 1.0f; 			// Default specular mask

	// Calculate the normal map value
    {
		// Sample normal maps
    	float2 normal_uv   = transform_texcoord(uv, normal_map_transform);
        float3 base_normal = sample_2d_normal_approx(normal_map, normal_uv);
		// Use the base normal map
		shader_data.common.normal = base_normal;

		// Transform from tangent space to world space
		shader_data.common.normal = mul(shader_data.common.normal, shader_data.common.tangent_frame);
    }

    {// Sample color map.
	
	    float2 color_map_uv = transform_texcoord(uv, color_map_transform);
		shader_data.common.albedo = sample2DGamma(color_map, color_map_uv);

		shader_data.common.albedo.rgb *= albedo_tint.rgb;
	 
		 float alpha;
		 alpha	= shader_data.common.albedo.a;


	#if defined(HEIGHT_MASK)
		//shader_data.common.albedo.a is the height_mask
		alpha = saturate( (shader_data.common.vertexColor.a - ( 1 - shader_data.common.albedo.a )) / max(0.001, threshold_softness)  );
		alpha = lerp( shader_data.common.vertexColor.a, alpha, height_influence );
	#endif

	#if defined(ALPHA_CLIP)
		// Tex kill pixel
		clip(alpha - clip_threshold);
	#endif


#if defined(VERTEX_ALPHA)
		alpha *= shader_data.common.vertexColor.a;
#endif

#if defined(ALPHA_CLIP) && defined(ALPHA_CLIP_ALBEDO_ONLY)
		// Tex kill non-opaque pixels in albedo pass; tex kill opaque pixels in all other passes
		if (shader_data.common.shaderPass != SP_SINGLE_PASS_LIGHTING)
		{
			// Clip anything that is less than white in the alpha
			clip(alpha - clip_threshold);
		}
		else
		{
			// Reverse the order, so anything larger than the near-white threshold is clipped
			clip(clip_threshold - alpha);
		}
#elif defined(ALPHA_CLIP)
		// Tex kill pixel
		clip(alpha - clip_threshold);
#endif

        shader_data.common.shaderValues.y = alpha;
	}
}

 
 
float4 pixel_lighting(
	        in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data) 
{
	float2 uv = pixel_shader_input.texcoord.xy;
	float alpha = shader_data.common.shaderValues.y;
 
    // input from s_shader_data
    float4 albedo         = shader_data.common.albedo;
    float3 normal         = shader_data.common.normal;
	
	// Sample combo map, r = metalicness, g = cavity multiplier (fake AO), b = Self Illume map, a = roughness
	float2 combo_map_uv	= transform_texcoord(uv, combo_map_transform);
	float4 combo 	= sample2D(combo_map, combo_map_uv);
 
    float3 specular = 0.0f;
	float rough = roughness * combo.a;
	// using blinn specular model
	float metallic = metallicness * combo.r; 
    
	//calculate diffuse
	float3 diffuse = 0.0f;
	calc_diffuse_lambert(diffuse, shader_data.common, normal); 
	float3 specular_color = lerp(pow(float3(0.04, 0.04, 0.04), 2.2), albedo , metallic);
	// sample reflection
	float3 view = shader_data.common.view_dir_distance.xyz;
		 
	float3 rVec = reflect(view, normal);
	float mip_index = (1-rough) * 7.0f;
	float4 reflectionMap = sampleCUBELOD(reflection_map, rVec, mip_index, false);
	float3 fresnel = FresnelSchlick(specular_color, -view, normal);
	//float3 reflection = reflectionMap.rgb * fresnel * reflection_intensity;
    float3 reflection =  (reflectionMap.rgb + (reflectionMap.a * reflectionMap.rgb * reflection_intensity)) * saturate(reflection_intensity)  * fresnel;
	albedo = albedo * (1- metallic);
	//.. Finalize Output Color
    float4 out_color;
	out_color.a   = alpha;

	float3 color_map =  albedo * alpha;//the albedo color will come through the specular if we are metalic
	
    out_color.rgb =  ( color_map * diffuse.rgb ) + ( reflection );
	float3 rgb2lum = float3(0.30, 0.59, 0.11);
	out_color.a += dot(reflection , rgb2lum);
	
	out_color.a = lerp(out_color.a, 1, opaqueness);
	//add self alumination
	float3 selIllum = combo.b * emissive_mult * emissive_tint;
	out_color.rgb += selIllum;

	//Cavity AO
	float cavity_ao = lerp(1, combo.g, cavity_mult);
	out_color.rgb *= cavity_ao;
	
	// Output self-illum intensity as linear luminance of the added value
	shader_data.common.selfIllumIntensity =  GetLinearColorIntensity(selIllum * cavity_ao);	

	return out_color;
}


#include "techniques.fxh"
