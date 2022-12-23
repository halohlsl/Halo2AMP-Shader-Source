//
// File:	 srf_pbr_forerunner.fx
// Author:	 Will Fuller
// Date:	 2014/01/06
//
// Surface Shader - PBR Forerunner
//
// Copyright (c) Certain Affinity. All rights reserved.
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

DECLARE_SAMPLER_CUBE(reflection_map,  "Reflection Map", "", "shaders/default_bitmaps/bitmaps/default_cube.tif")
#include "next_texture.fxh"


#ifdef USE_HOLOGRAM
	DECLARE_SAMPLER( detail_map, "Detail Map", "Detail Map", "shaders/default_bitmaps/bitmaps/color_black.tif");
	#include "next_texture.fxh"
#endif 

#ifdef USE_DIRT

	DECLARE_SAMPLER( dirt_color_map, "Dirt Color Map", "", "shaders/default_bitmaps/bitmaps/default_diff.tif");
	#include "next_texture.fxh"

	DECLARE_SAMPLER( dirt_normal_map, "Dirt Normal Map", "", "shaders/default_bitmaps/bitmaps/default_normal.tif");
	#include "next_texture.fxh"

	DECLARE_SAMPLER( dirt_combo_map, "Dirt Combo Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
	#include "next_texture.fxh"

	DECLARE_SAMPLER( cloud_map, "Cloud Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
	#include "next_texture.fxh"
	
	DECLARE_FLOAT_WITH_DEFAULT(layer1_height_influence, "Layer1 Height Map Influence", "", 0, 1, float(1.0));
	#include "used_float.fxh"
	
	DECLARE_FLOAT_WITH_DEFAULT(layer1_height_multiplier, "Layer1 Height Map Multiplier", "", 0, 1, float(1.0));
	#include "used_float.fxh"	
	
	DECLARE_FLOAT_WITH_DEFAULT(layer1_cloud_influence, "Layer1 Cloud Map Influence", "", 0, 1, float(0.0));
	#include "used_float.fxh"
	
	DECLARE_FLOAT_WITH_DEFAULT(dirt_roughness, "Dirt Roughness Multiplier", "", 0, 1, float(1.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(dirt_cavity_mult, "Dirt Cavity Multiplier", "", 0, 1, float(1.0));
	#include "used_float.fxh"
#endif 



// Diffuse
DECLARE_RGB_COLOR_WITH_DEFAULT(albedo_tint, "Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(albedo_tint_facing, "Facing Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(albedo_tint_glancing, "Glancing Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fresnel_pow, "Fresnel Mask Power", "", 0, 10, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(roughness, "Roughness Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(metallicness, "Metallicness Multiplier", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(cavity_mult, "Cavity Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(emissive, "Emissive Multiplier", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(emissive_tint, "Emissive Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"

#ifdef USE_HOLOGRAM

	DECLARE_FLOAT_WITH_DEFAULT(height_mult, "Parallax Height Multiplier", "", 0, 1, float(0.25));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(detail_1_scale, "Detail1 UV Scale", "", 0, 20, float(2.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(detail_1_offset, "Detail1 Offset", "", -10, 10, float(-1.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(detail_2_scale, "Detail2 UV Scale", "", 0, 20, float(2.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(detail_2_offset, "Detail2 Offset", "", -10, 10, float(-8.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(detail_bias, "Detail Layer Bias", "", 0, 1, float(0.333));
	#include "used_float.fxh"

	DECLARE_RGB_COLOR_WITH_DEFAULT(detail_albedo_tint, "Detail Color Tint", "", float3(1,1,1));
	#include "used_float3.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(detail_albedo_mult, "Detail Albedo Multiplier", "", 0, 5, float(1.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(fade_start, "Detail Fade Start", "", 0, 9999, float(2.00));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(fade_end,	"Detail Fade End", "", 0, 9999, float(5.0));
	#include "used_float.fxh"

#endif

DECLARE_FLOAT_WITH_DEFAULT(reflection_intensity, "Reflection Intensity", "", 0, 10, float(5.0));
#include "used_float.fxh"

#if defined(ALPHA_CLIP)
#define MATERIAL_SHADER_ANNOTATIONS 	<bool is_alpha_clip = true;>
#endif

#if defined(ALPHA_CLIP) && !defined(ALPHA_CLIP_ALBEDO_ONLY)
DECLARE_FLOAT_WITH_DEFAULT(clip_threshold,		"Clipping Threshold", "", 0, 1, float(0.3));
#include "used_float.fxh"
#elif defined(ALPHA_CLIP)
static const float clip_threshold = 240.0f / 255.0f;
#endif


struct s_shader_data {
	s_common_shader_data common;
};

float2 parallax_texcoord(float2 uv, float amount, float2 viewTS, s_pixel_shader_input pixel_shader_input)
{
    viewTS.y = -viewTS.y;
    return uv + viewTS * amount * 0.1;
}

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;
	float2 detail_uv = pixel_shader_input.texcoord.zw;
	float detail = 0;
	shader_data.common.shaderValues.x = 0; 			// roughness
	shader_data.common.shaderValues.y = 1; 			// ao
	shader_data.common.shaderValues.z = 0; 			// metallic

	#ifdef USE_DIRT
	
		float4 cloud = sample2D(cloud_map, transform_texcoord(uv, cloud_map_transform));
		
		float4 dirt_color = sample2DGamma(dirt_color_map, transform_texcoord(detail_uv, dirt_color_map_transform));
		float4 dirt_combo = sample2D(dirt_combo_map, transform_texcoord(detail_uv, dirt_combo_map_transform));
		
		float4 combo = sample2D(combo_map, transform_texcoord(uv, combo_map_transform));

		float blend_mask = 1.0;
		float cloud_map1 = lerp( 1, dirt_color.a, layer1_cloud_influence ) ;
		// height = AO map combo.a 
		
		float cloud_map = lerp( 1, dirt_color.a, layer1_cloud_influence ) ;
		float height = lerp(1, saturate((1-combo.g ) * layer1_height_multiplier), layer1_height_influence);
		
		float scaled_vert_color = shader_data.common.vertexColor.a * 2 -1;
		//blend_mask = lerp(saturate( (1-( 1-height)) / ( 1 - min( 0.99, ( cloud_map  ) ) ) ), 1, saturate(scaled_vert_color)) * saturate(scaled_vert_color + 1);
		blend_mask = lerp(height * cloud_map, 1, saturate(scaled_vert_color))* saturate(scaled_vert_color + 1);
		//blend_mask = height;
	#endif 
	
	
	// Calculate the normal map value
    //{
		// Sample normal maps
    	float2 normal_uv = transform_texcoord(uv, normal_map_transform);
        float3 base_normal = sample_2d_normal_approx(normal_map, normal_uv);
		// Use the base normal map
	
	#ifdef USE_DIRT
		float3 dirt_normal = sample_2d_normal_approx(dirt_normal_map, transform_texcoord(detail_uv, dirt_normal_map_transform));
		base_normal = lerp(base_normal, float3(dirt_normal.rg * blend_mask, dirt_normal.b), blend_mask);
	#endif
		shader_data.common.normal = base_normal;

		// Transform from tangent space to world space
		shader_data.common.normal = mul(shader_data.common.normal, shader_data.common.tangent_frame);
    //}


	
    // offset uvs

	float3 view = shader_data.common.view_dir_distance.xyz;
	float fresnel_mask = pow(saturate(1 - dot(-view, shader_data.common.normal)), fresnel_pow);
	#ifdef USE_HOLOGRAM
	    float height = (1 - base_normal.z) * height_mult;
		
		float3x3 tangent_frame = shader_data.common.tangent_frame;
		#if !defined(cgfx)
			//(aluedke) The tangent frame is currently incorrect for transformations into UV space (the binormal is inverted).  Correct for this.
			tangent_frame[1] = -tangent_frame[1];
		#endif
		float3 viewTS = mul(tangent_frame, view);
		viewTS /= abs(viewTS.z);				// Do the divide to scale the view vector to the length needed to reach 1 unit 'deep'
		float2 uv_offset_1 = parallax_texcoord(detail_uv, height + detail_1_offset, viewTS, pixel_shader_input);
		float2 uv_offset_2 = parallax_texcoord(detail_uv, height + detail_2_offset, viewTS, pixel_shader_input);

		// depth fade mask
		float depth_fade = float_remap(shader_data.common.view_dir_distance.w, fade_start, fade_end, 1, 0);

		// detail
		float detail1 = sample2D(detail_map, detail_1_scale * uv_offset_1);
		float detail2 = sample2D(detail_map, detail_2_scale * uv_offset_2);
		detail = lerp(detail1, detail2, detail_bias);
		
		detail *= 1 - fresnel_mask;
		detail *= depth_fade;
		float detail_mask = sample2DGamma(color_map, uv).a;
		detail *= detail_mask;
	#endif 
	
    {
    	// Sample color map.
	    float2 color_map_uv = transform_texcoord(uv, color_map_transform);
	    shader_data.common.albedo = sample2DGamma(color_map, color_map_uv);

	    // Fresnel color tinting
	    shader_data.common.albedo.rgb *= lerp(albedo_tint_facing.rgb, albedo_tint_glancing.rgb, fresnel_mask);
	    
		#ifdef USE_HOLOGRAM
			// Albedo Detail
			shader_data.common.albedo.rgb += detail * detail_albedo_tint * detail_albedo_mult;
		#endif 
	 
	 	#ifdef USE_DIRT
			shader_data.common.albedo.rgb = lerp(shader_data.common.albedo.rgb, dirt_color, blend_mask);
	 	#endif 
		
        shader_data.common.albedo.a = 1;
	}
	
	#ifdef USE_DIRT
		shader_data.common.shaderValues.x = lerp(roughness * combo.a, dirt_combo.a * dirt_roughness, blend_mask);
		// using blinn specular model
		//shader_data.common.shaderValues.z= lerp(metallicness * combo.r, 0, blend_mask) ; 
		//shader_data.common.shaderValues.y = lerp(lerp(1, combo.g, cavity_mult), lerp(1, dirt_combo.g, dirt_cavity_mult), blend_mask); ; 
		shader_data.common.shaderValues.y = blend_mask;
	#endif 
}

 
 
float4 pixel_lighting(
	        in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data) 
{
	float2 uv = pixel_shader_input.texcoord.xy;
 
    // input from s_shader_data
    float4 albedo         = shader_data.common.albedo ;
    float3 normal         = shader_data.common.normal;
	
	float blended_roughness    = shader_data.common.shaderValues.x;
	//float blended_ao 		   = shader_data.common.shaderValues.y;
	//float blended_metallicness = shader_data.common.shaderValues.z;
	float blend_mask = shader_data.common.shaderValues.y;
	albedo.rgb *= albedo_tint.rgb;
	float3 specular = 0.0f;
	
	

	// Sample specular map
	float2 combo_map_uv	= transform_texcoord(uv, combo_map_transform);
	float4 combo 	= sample2D(combo_map, combo_map_uv);
 
	float rough = roughness * combo.a;
	// using blinn specular model
	float metallic = metallicness * combo.r ; 
	float cavity = lerp(1, combo.g, cavity_mult) ; 

	#ifdef USE_DIRT

		rough = blended_roughness;
		metallic = lerp(metallic, 0, blend_mask) ; 
		cavity = lerp(cavity, 1, blend_mask); 
		
	#endif 
	
	float3 specular_color = lerp(pow(float3(0.04, 0.04, 0.04), 2.2), albedo , metallic); 
	calc_specular_blinnphong(specular, shader_data.common, normal, specular_color, rough);
    float3 diffuse = 0.0f;
	float3 diffuse_reflection_mask = 0.0f;

	calc_diffuse_lambert(diffuse, shader_data.common, normal);
    
	float3 reflection = 0.0f;
	
	// sample reflection
	float3 view = shader_data.common.view_dir_distance.xyz;
		 
	float3 rVec = reflect(view, normal);
	float mip_index = (1-rough) * 7.0f;
	float4 reflectionMap = sampleCUBELOD(reflection_map, rVec, mip_index, false);
	float3 rgb2lum = float3(0.30, 0.59, 0.11);
	float3 fresnel = FresnelSchlickWithRoughness(specular_color, -view, normal, rough);
	reflection =  (reflectionMap.rgb + (reflectionMap.a * reflectionMap.rgb * reflection_intensity)) * saturate(reflection_intensity)  * fresnel ;
  
	//.. Finalize Output Color
    float4 out_color;
	out_color.a   = 1;

	float3 color_map =  lerp(albedo, float3(0,0,0), metallic); 
	
    out_color.rgb =  color_map * diffuse + diffuse.rgb * reflection + specular;
	
	#ifndef USE_DIRT
		float3 selIllum = emissive_tint.rgb * combo.b * emissive;
		out_color.rgb += selIllum;

		// Output self-illum intensity as linear luminance of the added value
		shader_data.common.selfIllumIntensity =  GetLinearColorIntensity(selIllum * cavity);	
	#endif 

	
	out_color.rgb *= cavity;
	
	//out_color.rgb = specular;
	
	return out_color;
}


#include "techniques.fxh"