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




// Diffuse
DECLARE_RGB_COLOR_WITH_DEFAULT(albedo_tint,		"Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(roughness, "Roughness Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(metallicness, "Metallicness Multiplier", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(cavity_mult, "Cavity Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(emissive, "Emissive Multiplier", "", 0, 1, float(0.0));
#include "used_float.fxh"

// Layer 1 -----------------------------------------------------------------------------

DECLARE_SAMPLER( layer_1_color_map, "Layer 1 Color Map", "Layer 1 Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( layer_1_normal_map, "Layer 1 Normal Map", "Layer 1 Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( layer_1_combo_map, "Layer 1 Combo Map", "Layer 1 Combo Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"


DECLARE_RGB_COLOR_WITH_DEFAULT(layer_1_albedo_tint,		"Layer 1 Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(layer_1_roughness, "Layer 1 Roughness Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(layer_1_metallicness, "Layer 1 Metallicness Multiplier", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(layer_1_cavity_mult, "Layer 1 Cavity Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(layer_1_emissive, "Layer 1 Emissive Multiplier", "", 0, 1, float(0.0));
#include "used_float.fxh"

// Layer 2 -----------------------------------------------------------------------------
#if defined(TWO_LAYERS)

	DECLARE_SAMPLER( layer_2_color_map, "Layer 2 Color Map", "Layer 2 Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
	#include "next_texture.fxh"

	DECLARE_SAMPLER( layer_2_normal_map, "Layer 2 Normal Map", "Layer 2 Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
	#include "next_texture.fxh"

	DECLARE_SAMPLER( layer_2_combo_map, "Layer 2 Combo Map", "Layer 2 Combo Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
	#include "next_texture.fxh"

	DECLARE_RGB_COLOR_WITH_DEFAULT(layer_2_albedo_tint, "Layer 2 Color Tint", "", float3(1,1,1));
	#include "used_float3.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(layer_2_roughness, "Layer 2 Roughness Multiplier", "", 0, 1, float(1.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(layer_2_metallicness, "Layer 2 Metallicness Multiplier", "", 0, 1, float(0.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(layer_2_cavity_mult, "Layer 2 Cavity Multiplier", "", 0, 1, float(1.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(layer_2_emissive, "Layer 2 Emissive Multiplier", "", 0, 1, float(0.0));
	#include "used_float.fxh"
#endif 

DECLARE_SAMPLER_CUBE(reflection_map,  "Reflection Map", "", "shaders/default_bitmaps/bitmaps/default_cube.tif")
#include "next_texture.fxh"

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
	float2 layer_masks;
};

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;
	float2 uv2 = pixel_shader_input.texcoord.zw;

	shader_data.common.shaderValues.x = 1.0f; 			// Default specular mask

	// Calculate the normal map value


    {// Sample color map.
	    float2 color_map_uv = transform_texcoord(uv, color_map_transform);
	    shader_data.common.albedo = sample2DGamma(color_map, color_map_uv) ;
		shader_data.common.albedo.rgb *= albedo_tint.rgb;
	 
	    float2 layer_1_color_map_uv = transform_texcoord(uv2, layer_1_color_map_transform);
	    float4 layer_1_albedo = sample2DGamma(layer_1_color_map, layer_1_color_map_uv) ;
		layer_1_albedo.rgb *= layer_1_albedo_tint.rgb;
		shader_data.layer_masks.r = layer_1_albedo.a * shader_data.common.vertexColor.a;
		
		shader_data.common.albedo.rgb = lerp(shader_data.common.albedo.rgb, layer_1_albedo.rgb, shader_data.layer_masks.r);
		
		#if defined(TWO_LAYERS)
			float2 layer_2_color_map_uv = transform_texcoord(uv2, layer_2_color_map_transform);
			float4 layer_2_albedo = sample2DGamma(layer_2_color_map, layer_2_color_map_uv) ;
			layer_2_albedo.rgb *= layer_2_albedo_tint.rgb;
			shader_data.layer_masks.g = layer_2_albedo.a * shader_data.common.vertexColor.a;
			shader_data.common.albedo.rgb = lerp(shader_data.common.albedo.rgb, layer_2_albedo.rgb, shader_data.layer_masks.g);
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
	
    {
		// Sample normal maps
    	float2 normal_uv   = transform_texcoord(uv, normal_map_transform);
        float3 base_normal = sample_2d_normal_approx(normal_map, normal_uv);
		
		float2 layer_1_normal_uv   = transform_texcoord(uv2, layer_1_normal_map_transform);
        float3 layer_1_base_normal = sample_2d_normal_approx(layer_1_normal_map, layer_1_normal_uv);
		
		base_normal.xy = lerp(base_normal.xy, layer_1_base_normal.xy, shader_data.layer_masks.r);
		
		#if defined(TWO_LAYERS)
			float2 layer_2_normal_uv   = transform_texcoord(uv2, layer_2_normal_map_transform);
			float3 layer_2_base_normal = sample_2d_normal_approx(layer_2_normal_map, layer_2_normal_uv);
			base_normal.xy = lerp(base_normal.xy, layer_2_base_normal.xy , shader_data.layer_masks.g);
		#endif
		
		base_normal = normalize(base_normal);
		
		// Use the base normal map
		shader_data.common.normal = base_normal;

		// Transform from tangent space to world space
		shader_data.common.normal = mul(shader_data.common.normal, shader_data.common.tangent_frame);
    }	
	
	
}

 
 
float4 pixel_lighting(
	        in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data) 
{
	float2 uv = pixel_shader_input.texcoord.xy;
	float2 uv2 = pixel_shader_input.texcoord.zw;
 
    // input from s_shader_data
    float4 albedo         = shader_data.common.albedo ;
    float3 normal         = shader_data.common.normal;
	
	// Sample specular map
	float2 combo_map_uv	= transform_texcoord(uv, combo_map_transform);
	float4 combo 	= pow(sample2D(combo_map, combo_map_uv), 1);
 
 	float2 layer_1_combo_map_uv	= transform_texcoord(uv2, layer_1_combo_map_transform);
	float4 layer_1_combo 	= pow(sample2D(layer_1_combo_map, layer_1_combo_map_uv), 1);
	
	float3 specular = 0.0f;
	 
	float cavity = lerp(1, combo.g, cavity_mult);
	
	cavity = lerp(cavity, lerp(1, layer_1_combo.g, layer_1_cavity_mult), shader_data.layer_masks.r);
	 
	float emissiviness = combo.b * emissive;
	emissiviness = lerp(emissiviness, layer_1_emissive * layer_1_combo.b, shader_data.layer_masks.r);

	float rough = roughness * combo.a;
	rough = lerp(rough, layer_1_roughness * layer_1_combo.a, shader_data.layer_masks.r);
	
	float metallic = metallicness * combo.r ; 
	metallic = lerp(metallic, layer_1_metallicness * layer_1_combo.r, shader_data.layer_masks.r);
	
	#if defined(TWO_LAYERS)
	 	float2 layer_2_combo_map_uv	= transform_texcoord(uv2, layer_2_combo_map_transform);
		float4 layer_2_combo 	= pow(sample2D(layer_2_combo_map, layer_2_combo_map_uv), 1);
		
		rough = lerp(rough, layer_2_roughness * layer_2_combo.a, shader_data.layer_masks.g);
		metallic = lerp(metallic, layer_2_metallicness * layer_2_combo.r, shader_data.layer_masks.g);
		emissiviness = lerp(emissiviness, layer_2_emissive * layer_2_combo.b, shader_data.layer_masks.g);
		cavity = lerp(cavity, lerp(1, layer_2_combo.g, layer_2_cavity_mult), shader_data.layer_masks.g);
	
	#endif 
	
	
	
	float3 specular_color = lerp(pow(float3(0.04, 0.04, 0.04), 2.2), albedo , metallic);
	calc_specular_blinnphong(specular, shader_data.common, normal, specular_color, pow(rough, 1/2.2));



    float3 diffuse = 0.0f;
	float3 diffuse_reflection_mask = 0.0f;

	calc_diffuse_lambert(diffuse, shader_data.common, normal);
    
	float3 reflection = 0.0f;
	
		// sample reflection
	float3 view = shader_data.common.view_dir_distance.xyz;
		 
	float3 rVec = reflect(view, normal);
	float mip_index = (1-rough) * 7.0f;
	float4 reflectionMap = pow(sampleCUBELOD(reflection_map, rVec, mip_index, false), 1);
	float3 rgb2lum = float3(0.30, 0.59, 0.11);
	
	float3 fresnel = FresnelSchlickWithRoughness(specular_color, -view, normal, rough);
	reflection = reflectionMap.rgb * reflectionMap.a * reflection_multiplier * fresnel;
   
  
	//.. Finalize Output Color
    float4 out_color;
	out_color.a   = shader_data.alpha;

	float3 color_map =  lerp(albedo, float3(0,0,0), metallic); 
	
    out_color.rgb =  color_map * diffuse + diffuse.rgb * reflection + specular;
	
	float3 selIllum = shader_data.common.albedo.rgb * emissiviness;
	
	
	out_color.rgb += selIllum;
	out_color.rgb *= cavity;
	
	
	// Output self-illum intensity as linear luminance of the added value
	shader_data.common.selfIllumIntensity =  GetLinearColorIntensity(selIllum * lerp(1, combo.g, cavity_mult));	
	//out_color.rgb = roughness * combo.g;
	return out_color;
}


#include "techniques.fxh"
