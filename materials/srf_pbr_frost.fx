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


DECLARE_SAMPLER_CUBE(reflection_map,  "Reflection Map", "", "shaders/default_bitmaps/bitmaps/default_cube.tif")
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(reflection_intensity, "Reflection Intensity", "", 0, 10, float(5.0));
#include "used_float.fxh"

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

DECLARE_FLOAT_WITH_DEFAULT(parallax_normal_strength, "Parallax Normal Influence", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(parallax_depth, "Parallax Depth", "", 0, 1, float(1.0));
#include "used_float.fxh"

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
	
	DECLARE_SAMPLER( layer_2_combo_map, "Layer 2 Combo Map", "Layer 2 Combo Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
	#include "next_texture.fxh"

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

struct s_shader_data {
	s_common_shader_data common;
};

float2 parallax_texcoord(float2 uv, float amount, float2 viewTS, s_pixel_shader_input pixel_shader_input)
{
    viewTS.y = -viewTS.y;
    return uv + viewTS * amount * 0.1;
}

float3x3 compute_alt_tangent_frame(float3 normal, float3 viewDir, float2 texUV, float3x3 primaryTangentFrame)
{
	float3 dviewX = ddx(viewDir);
	float3 dviewY = ddy(viewDir);
	float2 duvX = ddx(texUV);
	float2 duvY = ddy(texUV);

	float3x3 viewMat = float3x3(dviewX, dviewY, cross(dviewX, dviewY));
	float2x3 inverseViewMat = float2x3( cross( viewMat[1], viewMat[2] ), cross( viewMat[2], viewMat[0] ) );
	float3 tangent = mul(float2(duvX.x, duvY.x), inverseViewMat);
	float3 binormal = mul(float2(duvX.y, duvY.y), inverseViewMat);
	
	// there're object with broken secondary UV and thus altTangentFrame
	if (length(tangent) < 1e-6 || length(binormal) < 1e-6) {
		return primaryTangentFrame;
	}
	
	return float3x3(normalize(tangent), normalize(binormal), normal);
}

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;
	float2 uv2 = pixel_shader_input.texcoord.zw;

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
	
	float2 layer_1_normal_map_uv   = transform_texcoord(uv2, layer_1_normal_map_transform);
	float3 layer_1_normal = sample_2d_normal_approx(layer_1_normal_map, layer_1_normal_map_uv);
	layer_1_normal.xy *= layer_1_norm_mult;
	

	//sample the color maps
	float3 composite_albedo = float3(0,0,0);
	float2 layer0_coMap_uv = transform_texcoord(uv, layer0_coMap_transform);
	float4 layer_0_color = sample2DGamma(layer0_coMap, layer0_coMap_uv) ;
	layer_0_color.rgb *= layer0_co_tint;
	
	float2 layer1_coMap_uv = transform_texcoord(uv2, layer1_coMap_transform);
	
		
	float3x3 tangent_frame = shader_data.common.tangent_frame;
	#if !defined(cgfx)
		//(aluedke) The tangent frame is currently incorrect for transformations into UV space (the binormal is inverted).  Correct for this.
		tangent_frame[1] = -tangent_frame[1];
	#endif
	
	float3 viewTS = mul(tangent_frame, shader_data.common.view_dir_distance.xyz);
	viewTS /= abs(viewTS.z);				// Do the divide to scale the view vector to the length needed to reach 1 unit 'deep'
	float2 layer_1_color_uv = parallax_texcoord(layer1_coMap_uv, saturate(layer_1_normal.x + layer_1_normal.y) * parallax_normal_strength + parallax_depth, viewTS, pixel_shader_input);
	
	// alpha doesn't need parallax
	float layer_1_alpha = sample2DGamma(layer1_coMap, layer1_coMap_uv).a ;
	float4 layer_1_color = sample2DGamma(layer1_coMap, layer_1_color_uv) ;
	layer_1_color.rgb *= layer1_co_tint;
	layer_1_color.a = layer_1_alpha;
	
	#ifdef USE_THREE_LAYERS
		float2 layer2_coMap_uv = transform_texcoord(uv2, layer2_coMap_transform);
		float4 layer_2_color = sample2DGamma(layer2_coMap, layer2_coMap_uv) ;
		layer_2_color.rgb *= layer2_co_tint;
	#endif 
	
	
	//change the range on the blend based on the hieght influance, stored in the alpha channel of the layer texture.
	float layer1_mask = 1.0;
	float cloud_map1 = lerp( 1, cloudValue, layer_1_cloud_influence );
	layer1_mask = saturate( (blend1 - ( 1 - layer_1_color.a )) / ( 1 - min( 0.99, ( cloud_map1 * shader_data.common.vertexColor.a ) ) ) );
	blend1 = lerp(blend1, layer1_mask, layer_1_height_influence);

	#ifdef USE_THREE_LAYERS
		float layer2_mask = 1.0;
		float cloud_map2 = lerp( 1, cloudValue, layer_2_cloud_influnece ) ;
		layer2_mask = saturate( (blend2 - ( 1 - layer_2_color.a )) / ( 1 - min( 0.99, ( cloud_map2 * shader_data.common.vertexColor.a ) ) ) );
		blend2 = lerp(blend2, layer2_mask, layer_2_height_influence);
	#endif
	
	composite_albedo = layer_0_color;
	composite_albedo = lerp(composite_albedo, layer_1_color , blend1);
	
	#ifdef USE_THREE_LAYERS
		composite_albedo = lerp(composite_albedo, layer_2_color , blend2);
	#endif 
	
	shader_data.common.albedo.a = 1.0;
	shader_data.common.albedo.rgb = composite_albedo;

	// Sample normal maps
	float3 base_normal = float3(0,0,1);
	
	float2 layer_0_normal_map_uv   = transform_texcoord(uv, layer_0_normal_map_transform);
	float3 layer_0_normal = sample_2d_normal_approx(layer_0_normal_map, layer_0_normal_map_uv);
	layer_0_normal.xy *= layer_0_norm_mult;

	layer_0_normal = mul(layer_0_normal, shader_data.common.tangent_frame);

	//because we are using the 2nd set of uvs the tangent space and binormal are wrong 
	float3x3 altTangentFrame = compute_alt_tangent_frame(
		shader_data.common.normal,
		shader_data.common.view_dir_distance.xyz,
		uv2,
		shader_data.common.tangent_frame);//gaa this is expensive....
	layer_1_normal = mul(layer_1_normal, altTangentFrame);
	
	base_normal.xyz = lerp( layer_0_normal.xyz, layer_1_normal.xyz, blend1 );
	
	#ifdef USE_THREE_LAYERS
		float2 layer_2_normal_map_uv   = transform_texcoord(uv2, layer_2_normal_map_transform);
		float3 layer_2_normal = sample_2d_normal_approx(layer_2_normal_map, layer_2_normal_map_uv);
		layer_2_normal.xy *= layer_2_norm_mult;
		layer_2_normal = mul(layer_2_normal, altTangentFrame);
		
		#ifdef USE_ADDITIVE_SECOND_LAYER_NORMAL
			base_normal.xy += layer_2_normal.xy * blend2 ;
		#else
			base_normal.xyz = lerp( base_normal.xyz, layer_2_normal.xyz, blend2 );
		#endif
		
	#endif 

	
	// Use the base normal map
	shader_data.common.normal = normalize(base_normal); //this is already in world space, we needed to do the tangent space conversion earlier.

	float4 composite_combo = float4(0,0,0,0);

	float2 layer_0_combo_uv = transform_texcoord(uv, layer_0_combo_map_transform);
	float4 layer_0_combo = sample2D(layer_0_combo_map, layer_0_combo_uv);
	layer_0_combo.g = lerp(1, layer_0_combo.g, layer_0_cavity);
	
	float2 layer_1_combo_uv = transform_texcoord(uv2, layer_1_combo_map_transform);
	float4 layer_1_combo = sample2D(layer_1_combo_map, layer_1_combo_uv);
	layer_1_combo.g = lerp(1, layer_1_combo.g, layer_1_cavity);
	
	composite_combo = layer_0_combo * float4( layer_0_metallic, 1, 1, layer_0_roughness);
	composite_combo = lerp(composite_combo, layer_1_combo * float4(layer_1_metallic, 1, 1, layer_1_roughness) , blend1);

	#ifdef USE_THREE_LAYERS

		float2 layer_2_combo_uv = transform_texcoord(uv2, layer_2_combo_map_transform);
		float4 layer_2_combo = sample2D(layer_2_combo_map, layer_2_combo_uv);
		layer_2_combo.g = lerp(1, layer_2_combo.g, layer_2_cavity);
		composite_combo = lerp(composite_combo, layer_2_combo * float4(layer_2_metallic, 1, 1, layer_2_roughness), blend2);
	#endif 
	

	//cache the blend values into the deffered map for the lighting step to use on the combo map.
	shader_data.common.shaderValues.x = composite_combo.a;
	shader_data.common.shaderValues.y = composite_combo.r;
	shader_data.common.shaderValues.z = composite_combo.g;
	//shader_data.common.albedo.a = composite_combo.r;
	
}

float4 pixel_lighting(
	        in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data) 
{
	float2 uv = pixel_shader_input.texcoord.xy;
	
    // input from s_shader_data
    float4 albedo         = shader_data.common.albedo ;
    float3 normal         = shader_data.common.normal;
		
	float3 specular = 0.0f;

	float metallic = shader_data.common.shaderValues.y ; 
	float roughness = shader_data.common.shaderValues.x;
	float cavity = shader_data.common.shaderValues.z;

	#if !defined(cgfx)
	
		float3 combo_to_degamma = pow(float3(metallic, roughness, cavity), 2.2);
		metallic = combo_to_degamma.r;
		roughness = combo_to_degamma.g;
		cavity = combo_to_degamma.b;
	
	#endif 
	
	float3 specular_color = lerp(pow(float3(0.04, 0.04, 0.04), 2.2), albedo , metallic);
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
	reflection = reflectionMap.rgb * reflectionMap.a * reflection_intensity * fresnel;// * max(roughness, specular_color);

	//darken albedo if we are metalic  
  	albedo.rgb =  lerp(albedo.rgb, float3(0,0,0), metallic);

	//.. Finalize Output Color
    float4 out_color;
	out_color.a   = 1.0;

    out_color.rgb =  (albedo * diffuse)  + specular + (reflection * diffuse);
	out_color.rgb *= cavity;
	
	return out_color;
}


#include "techniques.fxh"