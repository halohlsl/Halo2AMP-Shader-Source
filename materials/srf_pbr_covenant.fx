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

#define DISABLE_LIGHTING_TANGENT_FRAME
#define DISABLE_LIGHTING_VERTEX_COLOR

#define DISABLE_SHARPEN_FALLOFF

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

DECLARE_SAMPLER( combo_map_2, "Combo Map 2", "Combo Map 2", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( rainbow_map, "Rainbow Map", "Rainbow Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( clearcoat_normal_map, "Clearcoat Normal Map", "Clearcoat Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
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

DECLARE_RGB_COLOR_WITH_DEFAULT(emissive_tint,		"Emissive Tint", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(emissive, "Emissive Multiplier", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(reflection_multiplier, "Reflection Multiplier", "", 0, 1, float(1));
#include "used_float.fxh"

// Clear Coat 

DECLARE_FLOAT_WITH_DEFAULT(clearcoat_roughness, "Clear Coat Roughness Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(clearcoat_specular_color,		"Clear Coat Spec", "", float3(0.04,0.04,0.04));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(clearcoat_normal_scale, "Clear Coat Normal Scale", "", 0, 1, float(0.0));
#include "used_float.fxh"

// Iridescence 
DECLARE_FLOAT_WITH_DEFAULT(iridescence_coeff, "Iridescence Coefficient", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(iridescence_intensity, "Iridescence Intensity", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(iridescence_offset, "Iridescence Offset", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(iridescence_scale, "Iridescence Scale", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(iridescence_color_blend, "Iridescence Color Blend", "", 0, 1, float(0.5));
#include "used_float.fxh"

// SSS 
DECLARE_FLOAT_WITH_DEFAULT(subsurface_distortion, "Subsurface Distortion", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(subsurface_scale, "Subsurface Scale", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(subsurface_power, "Subsurface Power", "", 0, 10, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(subsurface_ambient, "Subsurface Ambient", "", 0, 1, float(0.1));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(subsurface_color,		"Subsurface Color", "", float3(1,0,0));
#include "used_float3.fxh"



#if defined(ALPHA_CLIP)
#define MATERIAL_SHADER_ANNOTATIONS 	<bool is_alpha_clip = true;>
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
    float  alpha;
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
		shader_data.common.normal = normalize(mul(shader_data.common.normal, shader_data.common.tangent_frame));
		
	}

    {// Sample color map.
	    float2 color_map_uv = transform_texcoord(uv, color_map_transform);
	    shader_data.common.albedo = sample2DGamma(color_map, color_map_uv);
	 

#if defined(FIXED_ALPHA)
        float2 alpha_uv		= uv;
		shader_data.alpha	= sample2DGamma(color_map, alpha_uv).a;
#else
        shader_data.alpha	= shader_data.common.albedo.a;
#endif

#if defined(VERTEX_ALPHA)
		shader_data.alpha *= shader_data.common.vertexColor.a;
#endif

#if defined(ALPHA_CLIP) && defined(ALPHA_CLIP_ALBEDO_ONLY)
		// Tex kill non-opaque pixels in albedo pass; tex kill opaque pixels in all other passes
		if (shader_data.common.shaderPass != SP_SINGLE_PASS_LIGHTING)
		{
			// Clip anything that is less than white in the alpha
			clip(shader_data.alpha - clip_threshold);
		}
		else
		{
			// Reverse the order, so anything larger than the near-white threshold is clipped
			clip(clip_threshold - shader_data.alpha);
		}
#elif defined(ALPHA_CLIP)
		// Tex kill pixel
		clip(shader_data.alpha - clip_threshold);
#endif

        shader_data.common.albedo.a = shader_data.alpha;

	}
}

 
 
float4 pixel_lighting(
	        in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data) 
{
	float2 uv = pixel_shader_input.texcoord.xy;
 
    // input from s_shader_data
    float4 albedo         = shader_data.common.albedo ;
    float3 normal         = shader_data.common.normal;
	
	float2 clearcoat_normal_uv   = transform_texcoord(uv, clearcoat_normal_map_transform);
	float3 clearcoat_normal = sample_2d_normal_approx(clearcoat_normal_map, clearcoat_normal_uv);
		
	float3 spec_normal = normal;
	spec_normal.xy += clearcoat_normal.xy * clearcoat_normal_scale;
	spec_normal = normalize(spec_normal);
	
	albedo.rgb *= albedo_tint.rgb;

	// Sample specular map
	float2 combo_map_uv	= transform_texcoord(uv, combo_map_transform);
	float4 combo 	= sample2D(combo_map, combo_map_uv);

	float2 combo_map_2_uv	= transform_texcoord(uv, combo_map_2_transform);
	float4 combo_2 	= sample2D(combo_map_2, combo_map_2_uv);

    float3 specular = 0.0f;
	float3 clearcoat_specular = 0.0f;
	
	float rough = roughness * combo.a;
	
	// using blinn specular model
	float metallic = metallicness * combo.r ; 
	
	float3 specular_color = lerp(pow(float3(0.04, 0.04, 0.04), 2.2), albedo , metallic);

	calc_specular_blinnphong(specular, shader_data.common, normal, specular_color, rough);
	
	calc_specular_blinnphong(clearcoat_specular, shader_data.common, spec_normal, clearcoat_specular_color, pow(clearcoat_roughness, 2.2));

	float3 subsurface = 0.0f;
	
	calc_subsurface(subsurface, shader_data.common, normal, float3(subsurface_distortion, subsurface_power, subsurface_scale), float2(combo_2.r, 0));
	
    float3 diffuse = 0.0f;
	float3 diffuse_reflection_mask = 0.0f;

	calc_diffuse_lambert(diffuse, shader_data.common, normal);
    
	float3 reflection = 0.0f;
	
		// sample reflection
	float3 view = -shader_data.common.view_dir_distance.xyz;
		 
	float3 rVec = reflect(-view, normal);
	
	float mip_index = (1-rough) * 7.0f;
	
	float4 reflectionMap = sampleCUBELOD(reflection_map, rVec, mip_index, false);
	
	float3 rgb2lum = float3(0.30, 0.59, 0.11);
	
	float3 fresnel = FresnelSchlickWithRoughness(specular_color, view, normal, rough);
	reflection = reflectionMap.rgb * reflectionMap.a * reflection_multiplier * fresnel;
   
   // iridescence
   float clearcoat_mip_index = (1-clearcoat_roughness) * 7.0f;
   float s_ndotv = saturate(dot(spec_normal, view));
   float3 clearcoat_rVec = reflect(-view, spec_normal);
   float4 clearcoat_reflection = sampleCUBELOD(reflection_map, clearcoat_rVec, clearcoat_mip_index, false);
   float3 iridescence = sample2D(rainbow_map, (float2(s_ndotv , s_ndotv ) + dot(rgb2lum, clearcoat_reflection)) * iridescence_scale + iridescence_offset  ).rgb;  
   iridescence = lerp (iridescence, clearcoat_reflection, iridescence_color_blend); 
   
   iridescence *=  FresnelSchlick(iridescence_coeff, view, spec_normal) * combo_2.g * iridescence_intensity;
	
	
	//.. Finalize Output Color
    float4 out_color;
	out_color.a   = shader_data.alpha;

	float3 color_map =  lerp(albedo, float3(0,0,0), metallic); 
	
    out_color.rgb =  color_map * diffuse + diffuse.rgb * reflection + specular;
	float3 selIllum = emissive_tint * combo.b * emissive;
	out_color.rgb += iridescence * diffuse;
	out_color.rgb += clearcoat_specular * combo_2.g;
	out_color.rgb += (subsurface + subsurface_ambient * combo_2.r)* subsurface_color ;
	out_color.rgb += selIllum;
	
	out_color.rgb *= lerp(1, combo.g, cavity_mult);
	// Output self-illum intensity as linear luminance of the added value
	shader_data.common.selfIllumIntensity =  GetLinearColorIntensity(selIllum * lerp(1, combo.g, cavity_mult));	
	//out_color.rgb = clearcoat_specular;
	return out_color;
}


#include "techniques.fxh"
