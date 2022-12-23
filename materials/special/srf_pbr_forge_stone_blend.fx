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



DECLARE_SAMPLER_CUBE(reflection_map,  "Reflection Map", "", "shaders/default_bitmaps/bitmaps/default_cube.tif")
#include "next_texture.fxh"

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

DECLARE_SAMPLER( team_color_map, "Team Color Map", "", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

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
#ifdef cgfx
    DECLARE_RGB_COLOR_WITH_DEFAULT(fake_team_color,	"Team Color", "", float3(1,1,1));
    #include "used_float3.fxh"
#endif 

#if defined(ALPHA_CLIP)
	#define MATERIAL_SHADER_ANNOTATIONS 	<bool is_alpha_clip = true;>
	DECLARE_FLOAT_WITH_DEFAULT(clip_threshold,				"Clipping Threshold", "", 0, 1, float(0.3));
	#include "used_float.fxh"
#endif


struct s_shader_data {
	s_common_shader_data common;
};

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;
    float2 uv2 = pixel_shader_input.texcoord.zw;
	float blend1;
	
    
    float2 team_color_uv = transform_texcoord(uv2, team_color_map_transform);
	float4 team_color = sample2DGamma(team_color_map, team_color_uv) ;
    
	float2 layer1_coMap_uv = transform_texcoord(uv, layer1_coMap_transform);
	float4 layer_1_color = sample2DGamma(layer1_coMap, layer1_coMap_uv) ;
	layer_1_color.rgb *= layer1_co_tint;	
	
	float layer1_mask = saturate( (shader_data.common.vertexColor.a - ( 1 - layer_1_color.a )) / ( 1 - min( 0.99, ( shader_data.common.vertexColor.a ) ) ) );
	blend1 = lerp(shader_data.common.vertexColor.a, layer1_mask, layer_1_height_influence);
	
	// Calculate the albedo, albedo alpha can influance the blend so normals have to go after
    {
		//sample the color maps
		float3 composite_albedo = float3(0,0,0);
		float2 layer0_coMap_uv = transform_texcoord(uv, layer0_coMap_transform);
		float4 layer_0_color = sample2DGamma(layer0_coMap, layer0_coMap_uv) ;
		layer_0_color.rgb *= layer0_co_tint;
		
		//change the range on the blend based on the hieght influance, stored in the alpha channel of the layer texture.

		composite_albedo = lerp(layer_0_color, layer_1_color , blend1);
		
		shader_data.common.albedo.a = 1.0;
		float4 primary_cc = ps_material_object_parameters[0];
        #ifdef cgfx
            primary_cc.rgb = fake_team_color.rgb;
        #endif 
        composite_albedo.rgb = lerp(  lerp(composite_albedo.rgb, primary_cc.rgb, team_color.a), composite_albedo.rgb , floor((primary_cc.r + primary_cc.g + primary_cc.b)/3));
        shader_data.common.albedo.rgb = composite_albedo;
        
		
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

	float3 specular = 0.0f;

	// using blinn specular model
	float metallic = composite_combo.b ; 
	float roughness = composite_combo.g;
	
	float cavity = composite_combo.r;
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