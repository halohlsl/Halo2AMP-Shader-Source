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

#if !defined(VERT_ROUGHNESS) && !defined(VERT_MOSS)
	#define VERT_DETAIL
#endif

// Texture Samplers
DECLARE_SAMPLER( color_map, "Color Map", "Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(color_multiplier,		"Color Multiplier", "", 0, 1, float(1));
#include "used_float.fxh"

DECLARE_SAMPLER( normal_map, "Normal Map", "Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(normal_intensity, "Normal Multiplier", "", 0, 5, float(1.0));
#include "used_float.fxh"

DECLARE_SAMPLER( combo_map, "Combo Map", "Combo Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"


// Details ------------------------------------------------------------------------------------------------------------------------
DECLARE_BOOL_WITH_DEFAULT(detail_normals, "Detail Normals Enabled", "", true);
#include "next_bool_parameter.fxh"

DECLARE_SAMPLER(ao_detail_map,		"Detail AO Map", "detail_normals", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER(normal_detail_map,		"Detail Normal Map", "detail_normals", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"


// Second Details ------------------------------------------------------------------------------------------------------------------
DECLARE_BOOL_WITH_DEFAULT(detail_normals_2, "Second Detail Normals Enabled", "detail_normals", true);
#include "next_bool_parameter.fxh"

DECLARE_SAMPLER(ao_detail_2_map,		"Second Detail AO Map", "detail_normals_2", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER(normal_detail_2_map,		"Second Detail Normal Map", "detail_normals_2", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(detail_blend_intensity,		"Detail Blend Intensity", "", 0, 1, float(1));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(detail_blend_power,		"Detail Blend Power", "", 0, 1, float(1));
#include "used_float.fxh"
// World Space Projection ----------------------------------------------------------------------------------------------------------

DECLARE_BOOL_WITH_DEFAULT(use_worldspace, "World Space Diffuse Enabled", "", true);
#include "next_bool_parameter.fxh"

DECLARE_SAMPLER(world_color_texture,		"World Space Map", "use_worldspace", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(world_texture_blend,		"World Space Map Blend", "use_worldspace", 0, 1, float(1));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(world_texture_intensity,		"World Space Map Intensity", "use_worldspace", 0, 1, float(1));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(world_mask_min,		"World Space Mask Min", "use_worldspace", 0, 1, float(1));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(world_mask_max,		"World Space Mask Max", "use_worldspace", 0, 1, float(1));
#include "used_float.fxh"



// Grime ---------------------------------------------------------------------------------------------------------------------------
DECLARE_BOOL_WITH_DEFAULT(use_grime_layer, "Grime Enabled", "", true);
#include "next_bool_parameter.fxh"

DECLARE_SAMPLER(grime_map,		"Grime Map", "use_grime_layer", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(grime_intensity,		"Grime Intensity", "use_grime_layer", 0, 1, float(1));
#include "used_float.fxh"

// Moss Snow -------------------------------------------------------------------------------------------------------------------------


DECLARE_BOOL_WITH_DEFAULT(use_upfacing_layer, "Up Facing Enabled", "", true);
#include "next_bool_parameter.fxh"

DECLARE_SAMPLER(up_facing_color_map,		"Up Facing Color Map", "use_upfacing_layer", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER(up_facing_normal_map,		"Up Facing Normal Map", "use_upfacing_layer", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(upfacing_roughness,		"Up Facing Roughness", "use_upfacing_layer", 0, 1, float(0.5));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(mask_bias,		"Mask Bias", "use_upfacing_layer", 0, 1, float(0.5));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(mask_intensity,		"Mask Intensity", "use_upfacing_layer", 0, 5, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(mask_power,		"Mask Power", "use_upfacing_layer", 0, 50, float(4.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(mask_normal_map_influence,		"Mask Normal Map Influence", "use_upfacing_layer", 0, 1, float(0.5));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(mask_combo_influence,		"Mask Combo Influence", "use_upfacing_layer", 0, 1, float(1));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(mask_x_direction,		"Mask X Direction", "use_upfacing_layer", -1, 1, float(0.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(mask_y_direction,		"Mask Y Direction", "use_upfacing_layer", -1, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(mask_z_direction,		"Mask Z Direction", "use_upfacing_layer", -1, 1, float(0.0));
#include "used_float.fxh"


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


struct s_shader_data 
{
	s_common_shader_data common;
    float  alpha;
	float4 combo_map;
};

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;
	float2 uv2 = pixel_shader_input.texcoord.zw;
	
	float3 geometry_normal = shader_data.common.normal;

	float2 combo_map_uv = transform_texcoord(uv, combo_map_transform);
	shader_data.combo_map = sample2D(combo_map, combo_map_uv);
	float up_mask = 0;
	// Calculate the normal map value
    
	// Sample normal maps
	float2 normal_uv   = transform_texcoord(uv, normal_map_transform);
	float3 base_normal = sample_2d_normal_approx(normal_map, normal_uv);
	// Use the base normal map
	base_normal.xy *= normal_intensity;
	float3 macro_normal = normalize(base_normal);
	float detail_cavity = 1;
	float detail_lerp = 1;

	STATIC_BRANCH
	if (detail_normals)
	{
		// Composite detail normal map onto the base normal map
		float2 detail_uv = transform_texcoord(uv2, normal_detail_map_transform);
		float3 detail_normal = sample_2d_normal_approx(normal_detail_map, detail_uv);
				
		STATIC_BRANCH
		if (detail_normals_2)
		{
			detail_lerp = saturate(pow(shader_data.combo_map.g, detail_blend_power) * detail_blend_intensity);
			#ifdef VERT_DETAIL
				detail_lerp *= 1-shader_data.common.vertexColor.a;
			#endif 
		
			float2 detail_2_uv = transform_texcoord(uv2, normal_detail_2_map_transform);
			float3 detail_2_normal = sample_2d_normal_approx(normal_detail_2_map, detail_2_uv);
			base_normal.xy += lerp(detail_2_normal.xy, detail_normal.xy, detail_lerp);			
		}else
		{
			base_normal.xy += detail_normal.xy;
		}
		base_normal = normalize(base_normal);
	}
	
	shader_data.common.normal = base_normal;

	// Transform from tangent space to world space
	shader_data.common.normal = mul(shader_data.common.normal, shader_data.common.tangent_frame);

	STATIC_BRANCH
	if (use_upfacing_layer)
	{
		float maskBias = mask_bias;
			// Create directional mask for snow using base normals
			//maskNormal = mul(maskNormal, shader_data.common.tangent_frame);
		#if defined(xenon) 
			float3 maskDirectionVector = float3(mask_z_direction, mask_x_direction, mask_y_direction);
		#elif defined(pc)
			float3 maskDirectionVector = float3(mask_z_direction, mask_x_direction, mask_y_direction);
		#else
			float3 maskDirectionVector = float3(mask_x_direction, mask_y_direction, mask_z_direction);
		#endif
		#if defined(VERTEX_MASK)
			//Use vertex alpha to modify bias
			maskBias += ((shader_data.common.vertexColor.a * 4) - 2);
		#endif
			float maskDirection = dot ( normalize( maskDirectionVector ) , lerp(geometry_normal, shader_data.common.normal, mask_normal_map_influence) ) + maskBias;
			up_mask = pow(saturate((  (lerp( maskDirection,maskDirection*(shader_data.combo_map.b),mask_combo_influence)) ) * mask_intensity), mask_power) ;
				
			#ifdef VERT_MOSS
				up_mask *= shader_data.common.vertexColor.a;
			#endif 
				
			float2 up_facing_normal_map_uv = transform_texcoord(uv2, up_facing_normal_map_transform);
			float3 up_facing_normal = sample_2d_normal_approx(up_facing_normal_map, up_facing_normal_map_uv);
				
			macro_normal.xy += up_facing_normal.xy;
			macro_normal = mul(normalize(macro_normal), shader_data.common.tangent_frame);
			shader_data.common.normal = lerp(shader_data.common.normal, macro_normal, up_mask);
	}

	//find the detail cavity map, need to be done AFTER up_mask due to a dependancy.
	STATIC_BRANCH
	if (detail_normals)
	{
		float2 ao_detail_map_uv = transform_texcoord(uv2, ao_detail_map_transform);
		float ao_detail = sample2D(ao_detail_map, ao_detail_map_uv).r;

		if (detail_normals_2)
		{
			float2 ao_detail_2_map_uv = transform_texcoord(uv2, ao_detail_2_map_transform);
			float ao_detail_2 = sample2D(ao_detail_2_map, ao_detail_2_map_uv).r;
			detail_cavity  *= lerp(ao_detail_2, ao_detail, detail_lerp);					
		}else
		{
			detail_cavity  *= lerp(ao_detail, 1, up_mask);
		}		
	}

    {// Sample color map.
	    float2 color_map_uv = transform_texcoord(uv, color_map_transform);
	    shader_data.common.albedo = sample2DGamma(color_map, color_map_uv) * color_multiplier;
	 
		STATIC_BRANCH
		if (use_worldspace)
		{
			float2 world_color_texture_yz_uv = transform_texcoord(shader_data.common.position.yz, world_color_texture_transform);
			float3 world_color_yz = sample2DGamma(world_color_texture, world_color_texture_yz_uv);
			
			float2 world_color_texture_xz_uv = transform_texcoord(shader_data.common.position.xz , world_color_texture_transform);
			float3 world_color_xz = sample2DGamma(world_color_texture, world_color_texture_xz_uv);
			
			#if defined(xenon) || (DX_VERSION == 11)
				float3 world_color = lerp(world_color_yz, world_color_xz, saturate(abs(pow(dot(shader_data.common.normal, float3(0,1,0)), 5))));
				float clamped_values = lerp(world_mask_min, world_mask_max, shader_data.combo_map.g);
				world_color = lerp(world_color * world_texture_intensity, 1, clamped_values);
				
				shader_data.common.albedo.rgb = lerp(shader_data.common.albedo.rgb, shader_data.common.albedo.rgb * world_color.rgb , world_texture_blend);
			#endif 
		}
		
		STATIC_BRANCH
		if (use_grime_layer)
		{
			float2 grime_map_uv = transform_texcoord(uv2, grime_map_transform);
			shader_data.common.albedo += sample2DGamma(grime_map, grime_map_uv) * grime_intensity;
		}

		STATIC_BRANCH
		if (use_upfacing_layer)
		{
				float2 up_facing_color_uv = transform_texcoord(uv2, up_facing_color_map_transform);
				shader_data.common.albedo = lerp(shader_data.common.albedo, sample2DGamma(up_facing_color_map, up_facing_color_uv) , up_mask);
		}
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
		shader_data.common.shaderValues.x = detail_cavity;
		shader_data.common.shaderValues.y = up_mask;
	}
}

float4 pixel_lighting(
	        in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data) 
{
	float2 uv = pixel_shader_input.texcoord.xy;
	float2 uv2 = pixel_shader_input.texcoord.zw;

	float detail_cavity = shader_data.common.shaderValues.x;
	float up_mask = shader_data.common.shaderValues.y;
 
    // input from s_shader_data
    float4 albedo         = shader_data.common.albedo;
    float3 normal         = shader_data.common.normal;
	
	albedo.rgb *= albedo_tint.rgb;

	
	
	float4 combo 	= shader_data.combo_map;
 
    float3 specular = 0.0f;
	float rough = roughness * combo.a;
	
	#ifdef VERT_ROUGHNESS
		rough = saturate(rough + shader_data.common.vertexColor.a);
	#endif 
	rough = lerp(rough, upfacing_roughness * albedo.r, up_mask);
	// using blinn specular model
	float metallic = metallicness * combo.r ; 
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
	float4 reflectionMap = pow(sampleCUBELOD(reflection_map, rVec, mip_index, false), 1);
	float3 rgb2lum = float3(0.30, 0.59, 0.11);
	
	float3 fresnel = FresnelSchlickWithRoughness(specular_color, -view, normal, rough);
	
	reflection =  (reflectionMap.rgb + (reflectionMap.a * reflectionMap.rgb * reflection_multiplier)) * saturate(reflection_multiplier)  * fresnel;
  
	//.. Finalize Output Color
    float4 out_color;
	out_color.a   = shader_data.alpha;

	float3 color_map =  lerp(albedo, float3(0,0,0), metallic); 
	
    out_color.rgb =  color_map * diffuse + diffuse.rgb * reflection + specular;
	
	float cavity = lerp(1, combo.g, cavity_mult);
	
	cavity *= detail_cavity;
	
	out_color.rgb *= cavity;
	
	//out_color.rgb = float3(shader_data.common.position.xyz);
	return out_color;
}


#include "techniques.fxh"
