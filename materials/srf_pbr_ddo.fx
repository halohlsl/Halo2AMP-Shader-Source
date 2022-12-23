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

DECLARE_SAMPLER( spec_map, "Spec Map", "Spec Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( rough_map, "Roughness Map", "Roughness Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( cavity_map, "Cavity Map", "Cavity Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER_CUBE(reflection_map,  "Reflection Map", "", "shaders/default_bitmaps/bitmaps/default_cube.tif")
#include "next_texture.fxh"



#ifdef TINTABLE_VERSION
	DECLARE_RGB_COLOR_WITH_DEFAULT(base_color,	"Base Color", "", float3(1,1,1));
	#include "used_float3.fxh"

	// Diffuse Primary and Secondary Change Colors
	#if defined(cgfx) || defined(ARMOR_PREVIS)
		DECLARE_RGB_COLOR_WITH_DEFAULT(tmp_primary_cc,	"Test Primary Color", "", float3(1,1,1));
		#include "used_float3.fxh"
		DECLARE_RGB_COLOR_WITH_DEFAULT(tmp_secondary_cc,	"Test Secondary Color", "", float3(1,1,1));
		#include "used_float3.fxh"
	#endif

#endif 
// Diffuse
DECLARE_RGB_COLOR_WITH_DEFAULT(albedo_tint,		"Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(roughness, "Roughness Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(spec_multiplier, "Specular Multiplier", "", 0, 1, float(0.04));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(reflection_multiplier, "Reflection Multiplier", "", 0, 1, float(1));
#include "used_float.fxh"
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
		shader_data.common.normal = mul(shader_data.common.normal, shader_data.common.tangent_frame);
    }

    {// Sample color map.
	    float2 color_map_uv = transform_texcoord(uv, color_map_transform);
		
		
		#ifdef TINTABLE_VERSION
		
			float4 control_map = sample2DGamma(color_map, color_map_uv);
			// determine surface color
			// primary change color engine mappings, using temp values in maya for prototyping
			float4 primary_cc = 1.0;
			float3 secondary_cc = 1.0f;

			#if defined(cgfx)  || defined(ARMOR_PREVIS)
				primary_cc   = float4(tmp_primary_cc, 1.0);
				secondary_cc = float4(tmp_secondary_cc,1.0);
			#else
				primary_cc   = ps_material_object_parameters[0];
				secondary_cc = ps_material_object_parameters[1];
			#endif

			float3 surface_colors[3] = {base_color.rgb,
										secondary_cc.rgb,
										primary_cc.rgb};
			float3 surface_color;
			
			surface_color = primary_cc * control_map.r;
			surface_color += secondary_cc * control_map.g;
			surface_color += base_color * control_map.b;
			
			surface_color = lerp(control_map.rgb, surface_color, control_map.a);
			// output color
			shader_data.common.albedo.rgb = surface_color;
		#else
			shader_data.common.albedo = sample2DGamma(color_map, color_map_uv);
		#endif 
		
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
	
	albedo.rgb *= albedo_tint.rgb;

	// Sample specular map
	float2 spec_map_uv	= transform_texcoord(uv, spec_map_transform);
	float4 specular_map 	= sample2D(spec_map, spec_map_uv);
	specular_map.rgb = pow(specular_map.rgb, 2.2);

    float3 specular = 0.0f;
	float rough = pow(specular_map.a, 1) * roughness;
	float gamma_rough = pow(specular_map.a, 1/2.2) * roughness;

	// using blinn specular model
	float3 specular_color = specular_map.rgb * spec_multiplier;
	calc_specular_blinnphong(specular, shader_data.common, normal, specular_color, gamma_rough);

    float3 diffuse = 0.0f;
	float3 diffuse_reflection_mask = 0.0f;

	calc_diffuse_lambert(diffuse, shader_data.common, normal);
    
	float3 reflection = 0.0f;
	
		// sample reflection
	float3 view = shader_data.common.view_dir_distance.xyz;
		 
	float3 rVec = reflect(view, normal);

	float mip_index = (1-rough) * 7.0f;
	float4 reflectionMap = pow(sampleCUBELOD(reflection_map, rVec, mip_index, false), 1);

	float3 fresnel = FresnelSchlickWithRoughness(specular_color, -view, normal, rough);
	reflection = reflectionMap.rgb * reflectionMap.a * reflection_multiplier * fresnel ;
   
  
	//.. Finalize Output Color
    float4 out_color;
	out_color.a   = shader_data.alpha;
	
	float2 cavity_map_uv	= transform_texcoord(uv, cavity_map_transform);
	float4 cavity 	= sample2D(cavity_map, cavity_map_uv);
	
	float3 color_map =  albedo; 
	
    out_color.rgb =  color_map * diffuse + specular + (reflection * diffuse);
	out_color.rgb *= cavity.rgb;
	return out_color;
}


#include "techniques.fxh"