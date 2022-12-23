//
// File:	 srf_pbr_height_blend.fx
// Author:	 lkruel
// Date:	 04/08/14
//
// Surface Shader - Height Blended PBR Shader
//
// Notes:
// 		Blends 2 PBR Materials based on normal based mask 
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


// Diffuse
DECLARE_RGB_COLOR_WITH_DEFAULT(albedo_tint,		"Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(roughness, "Roughness Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(metallicness, "Metallicness Multiplier", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(cavity_mult, "Cavity Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"
 
DECLARE_FLOAT_WITH_DEFAULT(reflection_multiplier, "Reflection Multiplier", "", 0, 1, float(1));
#include "used_float.fxh"
DECLARE_SAMPLER(up_facing_color_map,		"Up Facing Color Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER(up_facing_combo_map,		"Up Facing Combo Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER(up_facing_normal_map,		"Up Facing Normal Map", "", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(upface_albedo_tint,		"Upface Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(upface_roughness, "Upface Roughness Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(upface_metallicness, "Upface Metallicness Multiplier", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(upface_cavity_mult, "Upface Cavity Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"



DECLARE_FLOAT_WITH_DEFAULT(mask_bias,		"Mask Bias", "", 0, 1, float(0.5));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(mask_intensity,		"Mask Intensity", "", 0, 5, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(mask_power,		"Mask Power", "", 0, 50, float(4.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(mask_normal_map_influence,		"Mask Normal Map Influence", "", 0, 1, float(0.5));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(mask_height_influence,		"Mask Height Influence", "", 0, 1, float(1));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(mask_x_direction,		"Mask X Direction", "", -1, 1, float(0.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(mask_y_direction,		"Mask Y Direction", "", -1, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(mask_z_direction,		"Mask Z Direction", "", -1, 1, float(0.0));
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

	shader_data.common.shaderValues.y = 1.0f; 			// Up Mask
	
	float2 color_map_uv = transform_texcoord(uv, color_map_transform);
	shader_data.common.albedo = sample2DGamma(color_map, color_map_uv);
	shader_data.common.albedo.rgb *= albedo_tint.rgb;
	
	float2 up_facing_color_uv = transform_texcoord(uv, up_facing_color_map_transform);
	float4 up_facing_albedo = sample2DGamma(up_facing_color_map, up_facing_color_uv);
	
	float3 geometry_normal = shader_data.common.normal;
	
	float up_mask = 0;
	
	float2 normal_uv   = transform_texcoord(uv, normal_map_transform);
	float3 base_normal = sample_2d_normal_approx(normal_map, normal_uv);
	
	// Use the base normal map
	shader_data.common.normal = base_normal;
	
	// Transform from tangent space to world space
	shader_data.common.normal = normalize(mul(shader_data.common.normal, shader_data.common.tangent_frame));
		

	float maskBias = mask_bias;
	
	#if defined(xenon) 
		float3 maskDirectionVector = float3(mask_z_direction, mask_x_direction, mask_y_direction);
	#elif defined(pc)
		float3 maskDirectionVector = float3(mask_z_direction, mask_x_direction, mask_y_direction);
	#else
		float3 maskDirectionVector = float3(mask_x_direction, mask_y_direction, mask_z_direction);
	#endif
	
	
	
	float maskDirection = dot ( normalize( maskDirectionVector ) , lerp(geometry_normal, shader_data.common.normal, mask_normal_map_influence) ) + maskBias;
	up_mask = saturate(pow(saturate( maskDirection * mask_intensity), mask_power) );
	#ifdef USE_VERT_COLOR
		up_mask = saturate(up_mask + (shader_data.common.vertexColor.a * 2 -1));
	#endif 
	
	
	//float height = saturate( (up_mask - ( 1 - saturate(up_facing_albedo.a * mask_height_multiplier) )) / ( 1 - min( 0.99, ( up_mask ) ) ) );
	float height = saturate((up_mask-( 1- saturate(up_facing_albedo.a)) ) / ( 1 - min( 0.99, ( up_mask ) ) ) );
	up_mask = lerp(up_mask, height, mask_height_influence);
	
	float2 up_facing_normal_map_uv = transform_texcoord(uv, up_facing_normal_map_transform);
	float3 up_facing_normal = sample_2d_normal_approx(up_facing_normal_map, up_facing_normal_map_uv);
		
	up_facing_normal = mul(normalize(up_facing_normal), shader_data.common.tangent_frame);
	shader_data.common.normal = lerp(shader_data.common.normal, up_facing_normal, up_mask);
	

	shader_data.common.albedo = lerp(shader_data.common.albedo, up_facing_albedo * float4(upface_albedo_tint,1), up_mask);
	
	shader_data.common.shaderValues.y = up_mask;
}

 
float4 pixel_lighting(
						in s_pixel_shader_input pixel_shader_input,
						inout s_shader_data shader_data) 
{
	float2 uv = pixel_shader_input.texcoord.xy;
 
    // input from s_shader_data
    float4 albedo         = shader_data.common.albedo ;
    float3 normal         = shader_data.common.normal;

	float up_mask = shader_data.common.shaderValues.y;
	
	float2 combo_map_uv   = transform_texcoord(uv, combo_map_transform);
	float4 combo 	= sample2D(combo_map, combo_map_uv);

    float3 specular = 0.0f;
	
	float rough = roughness * combo.a;
	float metallic =  metallicness * combo.r;

	float cavity = lerp(1, combo.g, cavity_mult);
	
	float2 upfacing_combo_map_uv   = transform_texcoord(uv, up_facing_combo_map_transform);
	float4 upface_combo 	= sample2D(up_facing_combo_map, upfacing_combo_map_uv);
	rough = lerp(rough, upface_roughness * upface_combo.a, up_mask);
	
	metallic =  lerp( metallic ,  upface_metallicness * upface_combo.r , up_mask);
	cavity =   lerp( cavity,  lerp(1, upface_combo.g, upface_cavity_mult) , up_mask);
	
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
	float3 fresnel = FresnelSchlickWithRoughness(specular_color, -view, normal, rough);

	reflection = reflectionMap.rgb * reflectionMap.a * reflection_multiplier * fresnel;

	//.. Finalize Output Color
    float4 out_color;
	out_color.a   = 1;

	float3 color_map =  lerp(albedo, float3(0,0,0), metallic); 
	
    out_color.rgb =  color_map * diffuse + diffuse.rgb * reflection + specular;
	out_color.rgb *= cavity;
	
	return out_color;
}


#include "techniques.fxh"