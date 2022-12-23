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
#define REFLECTION

#define DISABLE_LIGHTING_TANGENT_FRAME
#define DISABLE_LIGHTING_VERTEX_COLOR

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
//DECLARE_SAMPLER( specular_map, "Specular Map", "Specular Map", "shaders/default_bitmaps/bitmaps/default_spec.tif");
//#include "next_texture.fxh"

// Foam Texture
DECLARE_SAMPLER( foam_map, "Foam Map", "Foam Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(foam_tint,		"Foam Tint", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(foam_intensity,		"Foam Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(foam_power,		"Foam Power", "", 0, 10, float(3.0));
#include "used_float.fxh"

//Normal map intensity
DECLARE_FLOAT_WITH_DEFAULT(normal_intensity,		"Normal Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"
//DECLARE_FLOAT_WITH_DEFAULT(detail_normal_intensity,		"Detail Normal Intensity", "", 0, 1, float(1.0));
//#include "used_float.fxh"

#if defined(REFLECTION)
DECLARE_SAMPLER_CUBE(reflection_map,  "Reflection Map", "", "shaders/default_bitmaps/bitmaps/default_cube.tif")
#include "next_texture.fxh"
#endif

// Diffuse
DECLARE_RGB_COLOR_WITH_DEFAULT(albedo_tint,		"Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(diffuse_intensity,		"Diffuse Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

#if defined(REFLECTION)
DECLARE_FLOAT_WITH_DEFAULT(diffuse_mask_reflection,	"Diffuse Mask Reflection", "", 0, 1, float(1.0));
#include "used_float.fxh"
#endif

DECLARE_FLOAT_WITH_DEFAULT(diffuse_alpha_mask_specular, "Diffuse Alpha Masks Specular", "", 0, 1, float(0.0));
#include "used_float.fxh"

// Specular
DECLARE_RGB_COLOR_WITH_DEFAULT(specular_color,		"Specular Color", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(specular_intensity,		"Specular Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(specular_power_min,		"Specular Power White", "", 0, 1, float(0.01));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(specular_power_max,		"Specular Power Black", "", 0, 1, float(0.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(specular_mix_albedo,		"Specular Mix Albedo", "", 0, 1, float(0.0));
#include "used_float.fxh"

#if defined(REFLECTION)
// Reflection
DECLARE_RGB_COLOR_WITH_DEFAULT(reflection_color,	"Reflection Color", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(reflection_intensity,		"Reflection Intensity", "", 0, 1, float(0.8));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(reflection_normal,		"Reflection Normal", "", 0, 1, float(0.0));
#include "used_float.fxh"

// Fresnel
DECLARE_FLOAT_WITH_DEFAULT(fresnel_intensity,		"Fresnel Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fresnel_power,			"Fresnel Power", "", 0, 10, float(3.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fresnel_mask_reflection,	"Fresnel Mask Reflection", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(fresnel_inv,				"Fresnel Invert", "", 0, 1, float(1.0));
#include "used_float.fxh"
#endif

// Detail Normal Map
DECLARE_BOOL_WITH_DEFAULT(detail_normals, "Detail Normals Enabled", "", true);
#include "next_bool_parameter.fxh"

DECLARE_SAMPLER(normal_detail_map,		"Detail Normal Map", "detail_normals", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(normal_detail_dist_max,	"Detail Start Dist.", "detail_normals", 0, 1, float(5.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(normal_detail_dist_min, 	"Detail End Dist.", "detail_normals", 0, 1, float(1.0));
#include "used_float.fxh"

// a couple parameters for vertex animation
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_frequency,	"Animation Frequency", "", 0, 1, float(360.0));
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_intensity,	"Animation Intensity", "", 0, 1, float(0.04));
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(wave_x_warp_frequency,	"Wave X Warp Frequency", "", 0, 1, float(0.0));
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(wave_x_warp,	"Wave X Warp", "", 0, 1, float(0.0));
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(wave_x_frequency,	"Wave X Frequency", "", 0, 1, float(360.0));
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(wave_x_speed,	"Wave X Speed", "", 0, 1, float(360.0));
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(wave_x_scale,	"Wave X Scale ", "", 0, 1, float(1.0));
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(wave_y_frequency,	"Wave Y Frequency", "", 0, 1, float(360.0));
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(wave_y_speed,	"Wave Y Speed", "", 0, 1, float(360.0));
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(wave_y_scale,	"Wave Y Scale ", "", 0, 1, float(1.0));
#include "used_vertex_float.fxh"

struct s_shader_data {
	s_common_shader_data common;

    float  alpha;
};

#if defined(xenon) || defined(cgfx) || (DX_VERSION == 11)

#define custom_deformer(vertex, vertexColor, local_to_world)			\
{																		\
	float wave_x_warp_amt = sin(vertex.position.y * wave_x_warp_frequency) * wave_x_warp; \
	float wave_x = sin(((vertex.position.x + wave_x_warp_amt)* wave_x_frequency) + (frac(vs_time.x/600.0f) * wave_x_speed)) + 1.0; \
	wave_x *= wave_x_scale; \
	float wave_y = (cos(vertex.position.x * wave_y_frequency) * cos((vertex.position.y * wave_y_frequency) + sin(frac(vs_time.x/600.0f)) * wave_y_speed)) + 1.0; \
	wave_y *= wave_y_scale; \
	float wave = wave_y * wave_x; \
	vertex.position.z += wave * vertexColor.a; \
	vertexColor.a = wave; \
}

#endif


void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;
	
	float waveMask = shader_data.common.vertexColor.a;

	// Sample color map.
	float2 color_map_uv = transform_texcoord(uv, color_map_transform);
	shader_data.common.albedo = sample2DGamma(color_map, color_map_uv);

	shader_data.common.shaderValues.x = 1.0f; 			// Default specular mask

	// Calculate the normal map value
    {
		// Sample normal maps
    	float2 normal_uv   = transform_texcoord(uv, normal_map_transform);
        float3 base_normal = sample_2d_normal_approx(normal_map, normal_uv);
		
		float3 flat_normal = float3(0,0,1);
		
		base_normal = lerp(flat_normal, base_normal, normal_intensity);

		STATIC_BRANCH
		if (detail_normals)
		{
			// Composite detail normal map onto the base normal map
			float2 detail_uv = pixel_shader_input.texcoord.xy;
			
			detail_uv = transform_texcoord(detail_uv, normal_detail_map_transform);
			
			shader_data.common.normal = CompositeDetailNormalMap(shader_data.common,
																 base_normal,
																 normal_detail_map,
																 detail_uv,
																 normal_detail_dist_min,
																 normal_detail_dist_max);
																 
		}
		else
		{
			// Use the base normal map
			shader_data.common.normal = base_normal;
		}

		//
		// Fade normals by shore
		shader_data.common.normal = lerp(flat_normal, shader_data.common.normal, shader_data.common.albedo.a), 
		
		// Transform from tangent space to world space
		shader_data.common.normal = mul(shader_data.common.normal, shader_data.common.tangent_frame);
    }



    {// Sample color map.

	
		float specularMask = lerp(1.0f, shader_data.common.albedo.w, diffuse_alpha_mask_specular);
		shader_data.common.shaderValues.x *= specularMask;

        shader_data.alpha	= shader_data.common.albedo.a;

		shader_data.common.albedo.rgb *= albedo_tint;
		
		//Foam Map
		float2 foam_map_uv = transform_texcoord(uv, foam_map_transform);
		float4 foam = sample2DGamma(foam_map, foam_map_uv);
		
		foam.rgb *= foam_tint;
		
		waveMask = saturate(pow(waveMask, foam_power) * foam_intensity);
		foam.a *= waveMask;		
		
		shader_data.common.albedo.rgb = lerp(shader_data.common.albedo.rgb, foam.rgb, foam.a);
		shader_data.common.shaderValues.x *= (1 - foam.a);
		
        shader_data.common.albedo.a = shader_data.alpha;

#if defined(REFLECTION)
		float fresnel = 0.0f;
		{ // Compute fresnel to modulate reflection
			float3 view = -shader_data.common.view_dir_distance.xyz;
			float  vdotn = saturate(dot(view, shader_data.common.normal));
			fresnel = vdotn + fresnel_inv - 2 * fresnel_inv * vdotn;	// equivalent to lerp(vdotn, 1 - vdotn, fresnel_inv);
			fresnel = pow(fresnel, fresnel_power) * fresnel_intensity;
		}

		// Fresnel mask for reflection
		shader_data.common.shaderValues.y = lerp(1.0, fresnel, fresnel_mask_reflection);
#endif
	}
	
}



float4 pixel_lighting(
	        in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;

    // input from s_shader_data
    float4 albedo         = shader_data.common.albedo;
    float3 normal         = shader_data.common.normal;

	// Sample specular map
	//float2 specular_map_uv	= transform_texcoord(uv, specular_map_transform);
	//float4 specular_mask 	= sample2DGamma(specular_map, specular_map_uv);
	float4 specular_mask 	= float4(1.0, 1.0, 1.0, 1.0);

	// Apply the specular mask from the albedo pass
	specular_mask.rgb *= shader_data.common.shaderValues.x;

#if defined(REFLECTION)

	// Sample control mask
	//float2 control_map_uv	= transform_texcoord(uv, control_map_SpGlRf_transform);
	//float4 control_mask		= sample2DGamma(control_map_SpGlRf, control_map_uv);
	float4 control_mask = float4(1.0, 1.0, 1.0, 1.0);

	specular_mask.rgb *= control_mask.r;
    specular_mask.a  = control_mask.g;

	// Multiply the control mask by the reflection fresnel multiplier (calculated in albedo pass)
	float reflectionMask = shader_data.common.shaderValues.y * shader_data.common.shaderValues.x;

#endif

    float3 specular = 0.0f;

	{ // Compute Specular
		float3 specNormal = normal;

        // pre-computing roughness with independent control over white and black point in gloss map
        float power = calc_roughness(specular_mask.a, specular_power_min, specular_power_max );

	    // using blinn specular model
    	calc_specular_blinn(specular, shader_data.common, specNormal, albedo.a, power);

        // mix specular_color with albedo_color
        float3 specular_col = lerp(specular_color, albedo.rgb, specular_mix_albedo);

        // modulate by mask, color, and intensity
        specular *= specular_mask.rgb * specular_col * specular_intensity;
	}


    float3 diffuse = 0.0f;
	float3 diffuse_reflection_mask = 0.0f;

	{ // Compute Diffuse

        // using standard lambert model
        calc_diffuse_lambert(diffuse, shader_data.common, normal);

		// Store the mask for diffuse reflection
        diffuse_reflection_mask = diffuse;

        // modulate by albedo, color, and intensity
    	diffuse *= albedo.rgb * diffuse_intensity;
    }

#if defined(REFLECTION)
	float3 reflection = 0.0f;
	if (AllowReflection(shader_data.common))
	{
		// sample reflection
		float3 view = shader_data.common.view_dir_distance.xyz;
		float3 rNormal = lerp(shader_data.common.geometricNormal, shader_data.common.normal, reflection_normal);

		float3 rVec = reflect(view, rNormal);
		float4 reflectionMap = sampleCUBEGamma(reflection_map, rVec);

		reflection =
			reflectionMap.rgb *							// reflection cube sample
			reflection_color *							// RGB reflection color from material
			reflection_intensity *						// scalar reflection intensity from material
			reflectionMask *							// control mask reflection intensity channel * fresnel intensity
			reflectionMap.a;							// intensity scalar from reflection cube

		reflection = lerp(reflection, reflection * diffuse_reflection_mask, diffuse_mask_reflection);
	}
#endif


	//.. Finalize Output Color
    float4 out_color;
	out_color.rgb = diffuse + specular;
	out_color.a   = shader_data.alpha;

#if defined(REFLECTION)
	out_color.rgb += reflection;
#endif

	return out_color;
}


#include "techniques.fxh"