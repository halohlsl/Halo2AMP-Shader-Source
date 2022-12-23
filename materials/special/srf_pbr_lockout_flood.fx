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
#define ALPHA_CLIP

// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"

//.. Artistic Parameters

// Texture Samplers
DECLARE_SAMPLER( color_map, "Color Map", "Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"


DECLARE_SAMPLER( detail_color_map, "Detail Color Map", "Detail Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"    

DECLARE_SAMPLER( normal_map, "Normal Map", "Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( detail_normal_map, "Detail Normal Map", "Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( combo_map, "Combo Map", "Combo Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
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

DECLARE_FLOAT_WITH_DEFAULT(normal_intensity,		"Normal Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(detail_normal_intensity,		"Detail Normal Intensity", "", 0, 1, float(1.0));
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

DECLARE_FLOAT_WITH_DEFAULT(spec_fudge, "Spec Fudge Factor", "", 0, 1, float(1.0));
#include "used_float.fxh"

        // a couple parameters for vertex animation
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_frequency,	"Foliage Animation Frequency", "", 0, 1, float(360.0));
        #include "used_vertex_float.fxh"
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_speed,	"Foliage Animation Speed", "", 0, 1, float(360.0));
        #include "used_vertex_float.fxh"		
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_intensity,	"Foliage Animation Intensity", "", 0, 1, float(0.04));
        #include "used_vertex_float.fxh"
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_offset_x,	"Foliage Animation Offset X", "", 0, 1, float(0.0));
        #include "used_vertex_float.fxh"
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_offset_y,	"Foliage Animation Offset Y", "", 0, 1, float(0.0));
        #include "used_vertex_float.fxh"
		
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(bob_distance,	"Bob Distance", "", 0, 1, float(1.0));
        #include "used_vertex_float.fxh"
		DECLARE_VERTEX_FLOAT_WITH_DEFAULT(bob_speed,	"Bob Speed", "", 0, 1, float(1.0));
        #include "used_vertex_float.fxh"

		
		
DECLARE_FLOAT_WITH_DEFAULT(spec_coeff, "Spec Coefficient", "", 0, 1, float(0.08));
#include "used_float.fxh"
		
#if defined(ALPHA_CLIP)

    #if defined(FRESNEL_CONTROL)

        DECLARE_FLOAT_WITH_DEFAULT(fresnel_power,			"Fresnel Power", "", 0, 10, float(1.0));
        #include "used_float.fxh"

        DECLARE_FLOAT_WITH_DEFAULT(fresnel_intensity,			"Fresnel Intensity", "", 0, 1, float(1.0));
        #include "used_float.fxh"

        DECLARE_FLOAT_WITH_DEFAULT(fresnel_offset,			"Fresmel Offset", "", 0, 1, float(0.0));
        #include "used_float.fxh"
    #endif 

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



float PeriodicVibration(in float animationOffset)
{
#if !defined(cgfx)
	float vibrationBase = 2.0 * abs(frac(animationOffset + animation_speed * vs_time.z) - 0.5);
#else
	float vibrationBase = 2.0 * abs(frac(animationOffset + animation_speed * frac(vs_time.x/600.0f)) - 0.5);
#endif
	return sin((0.5f - vibrationBase) * 3.14159265f);
}

float3 GetVibrationOffset(in float2 texture_coord, float animationOffset, float4 color)
{
	float2 vibrationCoeff;
	float distance = frac(texture_coord.x * animation_frequency);

	float id = texture_coord.x * animation_frequency + animation_offset_x - distance + animationOffset;
	vibrationCoeff.x = PeriodicVibration(id / 0.53);

	id = texture_coord.y * animation_frequency + animation_offset_y  - distance + animationOffset;
	vibrationCoeff.y = PeriodicVibration(id / 1.1173);

	float2 direction = frac(id.xx / float2(0.727, 0.371)) - 0.5;
	float3 result = distance * animation_intensity * color.a * vibrationCoeff.xxy * float3(direction.xy, 0.3f);
	
	#if !defined(cgfx)
		result.z += sin((0.5f - bob_speed *frac(vs_time.z )) * 3.14159265f) * bob_distance;
	#else
		result.y += sin((0.5f - bob_speed * frac(vs_time.x/600.0f ) )* 3.14159265f) * bob_distance;
	#endif
	
	return result;
}

#define custom_deformer(vertex, vertexColor, local_to_world)			\
{																		\
	float animationOffset = dot(float3(1,1,1), vertex.position.xyz);	\
	vertex.position.xyz += GetVibrationOffset(vertex.position.xy, animationOffset, vertexColor);\
}



void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;
    float2 uv2 = pixel_shader_input.texcoord.zw;

	shader_data.common.shaderValues.x = 1.0f; 			// Default specular mask
	float2 combo_map_uv	= transform_texcoord(uv, combo_map_transform);
	float4 combo 	= pow(sample2D(combo_map, combo_map_uv), 1);
	float normal_detail_mask = combo.a;
	
	// Calculate the normal map value
    {
		// Sample normal maps
    	float2 normal_uv   = transform_texcoord(uv, normal_map_transform);
        float3 base_normal = sample_2d_normal_approx(normal_map, normal_uv);
		base_normal.xy *= normal_intensity;
    	float2 detail_normal_uv   = transform_texcoord(uv, detail_normal_map_transform);
        float3 detail_normal = sample_2d_normal_approx(detail_normal_map, detail_normal_uv)  - float3(0,0,1);		
		detail_normal.xy *= detail_normal_intensity;
		// Use the base normal map
		shader_data.common.normal = base_normal;
		shader_data.common.normal += detail_normal * normal_detail_mask ;
		// Transform from tangent space to world space
		shader_data.common.normal = mul(shader_data.common.normal, shader_data.common.tangent_frame);
    }

    {// Sample color map.
	    float2 color_map_uv = transform_texcoord(uv, color_map_transform);
	    shader_data.common.albedo = sample2DGamma(color_map, color_map_uv);
	 
        const float detail_MULTIPLIER = 4.59479f;		// 4.59479f == 2 ^ 2.2  (sRGB gamma)
		float2 detail_coMap_uv = transform_texcoord(uv2, detail_color_map_transform);
		float4 detail_color = sample2DGamma(detail_color_map, detail_coMap_uv) ;
		detail_color.rgb *= detail_MULTIPLIER;
		shader_data.common.albedo = lerp(shader_data.common.albedo, shader_data.common.albedo * detail_color, normal_detail_mask);
        
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
        
         #if defined(FRESNEL_CONTROL)
            float3 view = -shader_data.common.view_dir_distance.xyz;
            float fresnel_mask = pow(saturate(dot(view, shader_data.common.normal.xyz)), fresnel_power) * fresnel_intensity + fresnel_offset;
        
            clip(shader_data.alpha * fresnel_mask - clip_threshold);
        #else
        
            clip(shader_data.alpha - clip_threshold);
        #endif 
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
	#ifdef USE_UNLIT 
		return float4(albedo.rgb, shader_data.alpha);
	#endif 
	// Sample specular map
	float2 combo_map_uv	= transform_texcoord(uv, combo_map_transform);
	float4 combo 	= pow(sample2D(combo_map, combo_map_uv), 1);
 
    float3 specular = 0.0f;
	float rough = roughness * combo.r;
	// using blinn specular model
	float metallic = metallicness ; 
	float3 specular_color = lerp(float3(spec_coeff, spec_coeff, spec_coeff), albedo , metallic);
	calc_specular_blinnphong(specular, shader_data.common, normal, specular_color, pow(rough, 1));
    float3 diffuse = 0.0f;
	

	calc_diffuse_lambert(diffuse, shader_data.common, normal);
    
	
	
		// sample reflection

   	float3 subsurface = 0.0f;
	
	calc_subsurface(subsurface, shader_data.common, normal, float3(subsurface_distortion, subsurface_power, subsurface_scale), float2(combo.b,0));
	
  
	//.. Finalize Output Color
    float4 out_color;
	out_color.a   = shader_data.alpha;

	float3 color_map =  albedo; 
	
    out_color.rgb =  color_map * diffuse + specular * spec_fudge;
	out_color.rgb += color_map * (subsurface + subsurface_ambient * combo.b)* subsurface_color ;
	
	out_color.rgb *= lerp(1, combo.g, cavity_mult);
	
	//out_color.rgb = roughness * combo.g;
	return out_color;
}


#include "techniques.fxh"
