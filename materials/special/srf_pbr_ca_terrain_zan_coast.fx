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

#if !defined(NO_MACRO_NORMAL)
	#define MACRO_NORMAL
#endif

#if !defined(USE_TWO_LAYERS)
	#define USE_THREE_LAYERS
#endif


// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"

//.. Artistic Parameters
DECLARE_SAMPLER( blend_map, "Blend Map", "Blend Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

#ifdef USE_BLEND_ROUGHNESS

	DECLARE_FLOAT_WITH_DEFAULT(macro_roughness_multiplier, "Blend Map Roughness Multiplier", "", 0, 1, float(0.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(macro_darkening_multiplier, "Blend Map Roughness Darkening", "", 0, 1, float(0.0));
	#include "used_float.fxh"	
	
#endif 


#ifdef MACRO_NORMAL
	DECLARE_SAMPLER( macro_normal_map, "Macro Normal Map", "Macro Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
	#include "next_texture.fxh"
#endif 
DECLARE_SAMPLER_CUBE(reflection_map,  "Reflection Map", "", "shaders/default_bitmaps/bitmaps/default_cube.tif")
#include "next_texture.fxh"

#ifdef USE_SPARKLE
	DECLARE_FLOAT_WITH_DEFAULT(sparkle_intensity, "Sparkle Intensity", "", 0, 1, float(1.0));
	#include "used_float.fxh"

#endif 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Layer 0 
DECLARE_SAMPLER( layer0_coMap, "Layer 0 Color Map", "Layer 0 Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(layer0_co_tint,	"Layer 0 Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_SAMPLER( layer_0_normal_map, "Layer 0 Normal Map", "Layer 0 Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(layer_0_norm_mult, "Layer 0 Normal Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

#ifdef MACRO_NORMAL
	DECLARE_FLOAT_WITH_DEFAULT(layer_0_macro_influence, "Layer 0 Macro Normal Influence", "", 0, 1, float(1.0));
	#include "used_float.fxh"
#endif 

DECLARE_SAMPLER( layer_0_combo_map, "Layer 0 Combo Map", "Layer 0 Combo Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(layer_0_roughness, "Layer 0 Roughness Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(layer_0_metallic, "Layer 0 Metallic Multiplier", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(layer_0_cavity, "Layer 0 Cavity Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Layer 1 
DECLARE_SAMPLER( layer1_coMap, "Layer 1 Color Map", "Layer 1 Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(layer1_co_tint,	"Layer 1 Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_SAMPLER( layer_1_normal_map, "Layer 1 Normal Map", "Layer 1 Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(layer_1_norm_mult, "Layer 1 Normal Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

#ifdef MACRO_NORMAL
	DECLARE_FLOAT_WITH_DEFAULT(layer_1_macro_influence, "Layer 1 Macro Normal Influence", "", 0, 1, float(1.0));
	#include "used_float.fxh"
#endif 

DECLARE_SAMPLER( layer_1_combo_map, "Layer 1 Combo Map", "Layer 1 Combo Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(layer_1_roughness, "Layer 1 Roughness Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(layer_1_metallic, "Layer 1 Metallic Multiplier", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(layer_1_cavity, "Layer 1 Cavity Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(layer_1_height_influence, "Layer 1 Height Map Influence", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(layer_1_cloud_influence, "Layer 1 Cloud Map Influence", "", 0, 1, float(0.0));
#include "used_float.fxh"

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Layer 2 

#ifdef USE_THREE_LAYERS
	DECLARE_SAMPLER( layer2_coMap, "Layer 2 Color Map", "Layer 2 Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
	#include "next_texture.fxh"

	DECLARE_RGB_COLOR_WITH_DEFAULT(layer2_co_tint,	"Layer 2 Color Tint", "", float3(1,1,1));
	#include "used_float3.fxh"

	DECLARE_SAMPLER( layer_2_normal_map, "Layer 2 Normal Map", "Layer 2 Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
	#include "next_texture.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(layer_2_norm_mult, "Layer 2 Normal Multiplier", "", 0, 1, float(1.0));
	#include "used_float.fxh"
	
	#ifdef MACRO_NORMAL
		DECLARE_FLOAT_WITH_DEFAULT(layer_2_macro_influence, "Layer 2 Macro Normal Influence", "", 0, 1, float(1.0));
		#include "used_float.fxh"
	#endif 
	
	#ifndef USE_MACRO_COLORMAP
		DECLARE_SAMPLER( layer_2_combo_map, "Layer 2 Combo Map", "Layer 2 Combo Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
		#include "next_texture.fxh"
	#endif 
	
	DECLARE_FLOAT_WITH_DEFAULT(layer_2_roughness, "Layer 2 Roughness Multiplier", "", 0, 1, float(1.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(layer_2_metallic, "Layer 2 Metallic Multiplier", "", 0, 1, float(0.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(layer_2_cavity, "Layer 2 Cavity Multiplier", "", 0, 1, float(1.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(layer_2_height_influence, "Layer 2 Height Map Influence", "", 0, 1, float(1.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(layer_2_cloud_influnece, "Layer 2 Cloud Map Influence", "", 0, 1, float(0.0));
	#include "used_float.fxh"
#endif

#ifdef USE_MACRO_COLORMAP
	DECLARE_SAMPLER( macro_coMap, "Macro Color Map", "Macro Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
	#include "next_texture.fxh"
#endif 

#if defined(ALPHA_CLIP)
	#define MATERIAL_SHADER_ANNOTATIONS 	<bool is_alpha_clip = true;>
	DECLARE_FLOAT_WITH_DEFAULT(clip_threshold,				"Clipping Threshold", "", 0, 1, float(0.3));
	#include "used_float.fxh"
#endif

DECLARE_FLOAT_WITH_DEFAULT(coast_blend, "Coast Blend", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(coast_tint,	"Coast Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(coast_roughness, "Coast Roughness", "", 0, 1, float(1.0));
#include "used_float.fxh"


struct s_shader_data {
	s_common_shader_data common;
};

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;
	float2 uv2;
	
	#ifdef USE_SECOND_UV
		uv2 = pixel_shader_input.texcoord.zw;
	#else
		uv2 = pixel_shader_input.texcoord.xy;
	#endif 

	float blend1;
	float blend2;
	float cloudValue;
	
	// sample the blend map 
	{
	    float2 blend_map_uv   = transform_texcoord(uv2, blend_map_transform);
        float3 blendValue = sample2D(blend_map, blend_map_uv).rgb;
		blend1 = blendValue.r;
		blend2 = blendValue.g;
		cloudValue = blendValue.b;
	}
	

	
	// Calculate the albedo, albedo alpha can influance the blend so normals have to go after
    {
		//sample the color maps
		float3 composite_albedo = float3(0,0,0);
		float2 layer0_coMap_uv = transform_texcoord(uv, layer0_coMap_transform);
		float4 layer_0_color = sample2DGamma(layer0_coMap, layer0_coMap_uv) ;
		layer_0_color.rgb *= layer0_co_tint;
		
		float2 layer1_coMap_uv = transform_texcoord(uv, layer1_coMap_transform);
		float4 layer_1_color = sample2DGamma(layer1_coMap, layer1_coMap_uv) ;
		layer_1_color.rgb *= layer1_co_tint;
		
		#ifdef USE_THREE_LAYERS
			float2 layer2_coMap_uv = transform_texcoord(uv, layer2_coMap_transform);
			float4 layer_2_color = sample2DGamma(layer2_coMap, layer2_coMap_uv) ;
			layer_2_color.rgb *= layer2_co_tint;
		#endif 
		
		#ifdef USE_BLEND_ROUGHNESS
			float blend_rough_map = cloudValue;
			cloudValue = 1;
		#endif 
		
		//change the range on the blend based on the hieght influance, stored in the alpha channel of the layer texture.
		float layer1_mask = 1.0;
		float cloud_map1 = lerp( 1, cloudValue, layer_1_cloud_influence );
		layer1_mask = saturate( (blend1 - ( 1 - layer_1_color.a )) / ( 1 - min( 0.99, ( cloud_map1  ) ) ) );
		blend1 = lerp(blend1, layer1_mask, layer_1_height_influence);

		#ifdef USE_THREE_LAYERS
			float layer2_mask = 1.0;
			float cloud_map2 = lerp( 1, cloudValue, layer_2_cloud_influnece ) ;
			layer2_mask = saturate( (blend2 - ( 1 - layer_2_color.a )) / ( 1 - min( 0.99, ( cloud_map2  ) ) ) );
			blend2 = lerp(blend2, layer2_mask, layer_2_height_influence);
		#endif
		
		composite_albedo = layer_0_color;
		composite_albedo = lerp(composite_albedo, layer_1_color , blend1);
		
		#ifdef USE_THREE_LAYERS
			composite_albedo = lerp(composite_albedo, layer_2_color , blend2);
	    #endif 
		
		#ifdef USE_MACRO_COLORMAP
		const float MACRO_MULTIPLIER = 4.59479f;		// 4.59479f == 2 ^ 2.2  (sRGB gamma)
		
		float2 macro_coMap_uv = transform_texcoord(uv, macro_coMap_transform);
		float4 macro_color = sample2DGamma(macro_coMap, macro_coMap_uv) ;
			macro_color.rgb *= MACRO_MULTIPLIER;
			composite_albedo *= macro_color;
	    #endif 	
		
		
		shader_data.common.albedo.a = 1.0;
		shader_data.common.albedo.rgb = composite_albedo;
		
		
		#ifdef USE_BLEND_ROUGHNESS
			shader_data.common.albedo.rgb = lerp(shader_data.common.albedo.rgb, shader_data.common.albedo.rgb * (1 - macro_darkening_multiplier), blend_rough_map); 
		#endif 
		
		//VERTEX ALPHA
		float vert_alpha = shader_data.common.vertexColor.a;
		shader_data.common.albedo.rgb *= lerp(float3(1.0, 1.0, 1.0), coast_tint, saturate(coast_blend * vert_alpha));
		
	}
	
	{
		// Sample normal maps
		float3 base_normal = float3(0,0,1);
		
		float2 layer_0_normal_map_uv   = transform_texcoord(uv, layer_0_normal_map_transform);
        float3 layer_0_normal = sample_2d_normal_approx(layer_0_normal_map, layer_0_normal_map_uv);
		layer_0_normal.xy *= layer_0_norm_mult;
		
		float2 layer_1_normal_map_uv   = transform_texcoord(uv, layer_1_normal_map_transform);
        float3 layer_1_normal = sample_2d_normal_approx(layer_1_normal_map, layer_1_normal_map_uv);
		layer_1_normal.xy *= layer_1_norm_mult;

		base_normal.xyz = lerp( layer_0_normal.xyz, layer_1_normal.xyz, blend1 );
		
		#ifdef USE_THREE_LAYERS
			float2 layer_2_normal_map_uv   = transform_texcoord(uv, layer_2_normal_map_transform);
			float3 layer_2_normal = sample_2d_normal_approx(layer_2_normal_map, layer_2_normal_map_uv);
			layer_2_normal.xy *= layer_2_norm_mult;
			
			#ifdef USE_ADDITIVE_SECOND_LAYER_NORMAL
				base_normal.xy += layer_2_normal.xy * blend2 ;
			#else
				base_normal.xyz = lerp( base_normal.xyz, layer_2_normal.xyz, blend2 );
			#endif
			
		#endif 

		#ifdef MACRO_NORMAL
			float2 macro_normal_uv   = transform_texcoord(uv2, macro_normal_map_transform);
			float3 macro_normal =  sample_2d_normal_approx(macro_normal_map, macro_normal_uv) - float3(0,0,1);
			
			macro_normal.xy = lerp(macro_normal.xy * layer_0_macro_influence, macro_normal.xy * layer_1_macro_influence, blend1);
			macro_normal.xy = lerp(macro_normal.xy, macro_normal.xy * layer_2_macro_influence, blend2);
			
			base_normal += macro_normal;
		#endif
		
		// Use the base normal map
		shader_data.common.normal = normalize(base_normal);

		// Transform from tangent space to world space
		shader_data.common.normal = mul(shader_data.common.normal, shader_data.common.tangent_frame);
    }

	
	
		// Tex kill pixel for clipping
	#if defined(ALPHA_CLIP)
		clip(shader_data.common.albedo.a - clip_threshold);
//		shader_data.alpha = 1.0f;
//	#else
//		shader_data.alpha = shader_data.common.albedo.a;
	#endif	
	
	//cache the blend values into the deffered map for the lighting step to use on the combo map.
	shader_data.common.shaderValues.x = blend1;
	shader_data.common.shaderValues.y = blend2;
}

float4 pixel_lighting(
	        in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data) 
{
	float2 uv = pixel_shader_input.texcoord.xy;
	
    // input from s_shader_data
    float4 albedo         = shader_data.common.albedo ;
    float3 normal         = shader_data.common.normal;


	float blend1		  = shader_data.common.shaderValues.x;
	float blend2		  = shader_data.common.shaderValues.y;
	#ifdef USE_BLEND_ROUGHNESS
		float2 blend_map_uv   = transform_texcoord(uv, blend_map_transform);
		float blend_rough_map = sample2D(blend_map, blend_map_uv).b ; 
	#endif 
	// Sample the combo maps (r = cavity AO, g = roughness, b = metalic, 

	float4 composite_combo = float4(0,0,0,0);
	float2 layer_0_combo_uv = transform_texcoord(uv, layer_0_combo_map_transform);
	float4 layer_0_combo = sample2D(layer_0_combo_map, layer_0_combo_uv);
	layer_0_combo.r = lerp(1, layer_0_combo.r, layer_0_cavity);
	
	float2 layer_1_combo_uv = transform_texcoord(uv, layer_1_combo_map_transform);
	float4 layer_1_combo = sample2D(layer_1_combo_map, layer_1_combo_uv);
	layer_1_combo.r = lerp(1, layer_1_combo.r, layer_1_cavity);
	
	composite_combo = layer_0_combo * float4(1, layer_0_roughness, layer_0_metallic, 1);
	composite_combo = lerp(composite_combo, layer_1_combo * float4(1, layer_1_roughness, layer_1_metallic, 1) , blend1);

	#ifdef USE_THREE_LAYERS
		#ifndef USE_MACRO_COLORMAP
			float2 layer_2_combo_uv = transform_texcoord(uv, layer_2_combo_map_transform);
			float4 layer_2_combo = sample2D(layer_2_combo_map, layer_2_combo_uv);
		#else
			float4 layer_2_combo = float4(1,layer_2_metallic,layer_2_roughness, 0);
		#endif
		layer_2_combo.r = lerp(1, layer_2_combo.r, layer_2_cavity);
		composite_combo = lerp(composite_combo, layer_2_combo * float4(1, layer_2_roughness, layer_2_metallic, 1), blend2);
	#endif 
		
	float3 specular = 0.0f;

	#ifdef USE_SPARKLE
		float sparkle = layer_0_combo.a * sparkle_intensity;
		
		normal.xy += sparkle.rr;
		normal = normalize(normal);
	#endif 
	

	
	// using blinn specular model
	float metallic = composite_combo.b ; 
	float roughness = composite_combo.g;
	
	#ifdef USE_BLEND_ROUGHNESS
		roughness = saturate(roughness + blend_rough_map * macro_roughness_multiplier);
	#endif
	
	float cavity = composite_combo.r;
	float3 specular_color = lerp(pow(float3(0.04, 0.04, 0.04), 2.2), albedo , metallic);
	#ifdef USE_SPARKLE
		specular_color = saturate(specular_color + sparkle);
		roughness = saturate(roughness + sparkle);
	#endif 
	calc_specular_blinnphong(specular, shader_data.common, normal, specular_color, roughness);
 
	//calculate the diffuse
	float3 diffuse = 0.0f;
	calc_diffuse_lambert(diffuse, shader_data.common, normal);
	
	// sample reflection
	float3 reflection = 0.0f;
	float3 view = shader_data.common.view_dir_distance.xyz;
		 
	float3 rVec = reflect(view, normal);
	float mip_index = (1-roughness) * 7.0f;
	float4 reflectionMap = sampleCUBELOD( reflection_map, rVec, mip_index, false);
	float3 fresnel = FresnelSchlickWithRoughness(specular_color, -view, normal, roughness);
	reflection = reflectionMap.rgb * fresnel;// * max(roughness, specular_color);

	//darken albedo if we are metalic  
  	albedo.rgb =  lerp(albedo.rgb, float3(0,0,0), metallic);

	//.. Finalize Output Color
    float4 out_color;
	out_color.a   = albedo.a ;

    out_color.rgb =  (albedo * diffuse)  + specular + (reflection * diffuse);
	out_color.rgb *= cavity;
	
	return out_color;
}


#include "techniques.fxh"