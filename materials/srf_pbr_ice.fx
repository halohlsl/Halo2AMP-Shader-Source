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

DECLARE_SAMPLER( macro_normal_map, "Macro Normal Map", "Macro Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

// Texture Samplers
DECLARE_SAMPLER( color_map, "Color Map", "Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( normal_map, "Normal Map", "Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( combo_map, "Combo Map", "Combo Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( clearcoat_normal_map, "Clearcoat Normal Map", "Clearcoat Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
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

DECLARE_FLOAT_WITH_DEFAULT(light_wrap, "Light Wrap", "", 0, 1, float(0.0));
#include "used_float.fxh"

#ifdef USE_PARALLAX
	DECLARE_FLOAT_WITH_DEFAULT(parallax_depth, "Parallax Depth", "", 0, 1, float(0.04));
	#include "used_float.fxh"
	
	DECLARE_FLOAT_WITH_DEFAULT(parallax_strength, "Parallax Strength", "", 0, 1, float(1));
	#include "used_float.fxh"
#endif
 
DECLARE_FLOAT_WITH_DEFAULT(reflection_multiplier, "Reflection Multiplier", "", 0, 1, float(1));
#include "used_float.fxh"

// Clear Coat 

DECLARE_FLOAT_WITH_DEFAULT(clearcoat_roughness, "Clear Coat Roughness Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(clearcoat_specular_color,		"Clear Coat Spec", "", float3(0.04,0.04,0.04));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(clearcoat_normal_scale, "Clear Coat Normal Scale", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(clearcoat_blend, "Clear Coat Blend", "", 0, 1, float(1.0));
#include "used_float.fxh"

// SSS 
DECLARE_FLOAT_WITH_DEFAULT(subsurface_distortion, "Subsurface Distortion", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(subsurface_scale, "Subsurface Scale", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(subsurface_power, "Subsurface Power", "", 0, 10, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(subsurface_wrap, "Subsurface Wrap", "", 0, 10, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(subsurface_ambient, "Subsurface Ambient", "", 0, 1, float(0.1));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(subsurface_color,		"Subsurface Color", "", float3(1,0,0));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(subsurface_blend, "Subsurface Blend", "", 0, 1, float(1.0));
#include "used_float.fxh"

#ifdef USE_UP_FACING



	DECLARE_SAMPLER(up_facing_color_map,		"Up Facing Color Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
	#include "next_texture.fxh"

	DECLARE_SAMPLER(up_facing_combo_map,		"Up Facing Combo Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
	#include "next_texture.fxh"

	DECLARE_SAMPLER(up_facing_normal_map,		"Up Facing Normal Map", "", "shaders/default_bitmaps/bitmaps/default_normal.tif");
	#include "next_texture.fxh"

    #ifdef USE_UP_FACING_DETAIL

        DECLARE_SAMPLER( up_facing_detail_color_map, "Up Facing Detail Color Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
        #include "next_texture.fxh"
        
        DECLARE_SAMPLER( up_facing_detail_normal_map, "Up Facing Detail Normal Map", "", "shaders/default_bitmaps/bitmaps/default_normal.tif");
        #include "next_texture.fxh"
    
    #endif    
    
	DECLARE_RGB_COLOR_WITH_DEFAULT(upface_albedo_tint,		"Upface Color Tint", "", float3(1,1,1));
	#include "used_float3.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(upface_roughness, "Upface Roughness Multiplier", "", 0, 1, float(1.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(upface_metallicness, "Upface Metallicness Multiplier", "", 0, 1, float(0.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(upface_cavity_mult, "Upface Cavity Multiplier", "", 0, 1, float(1.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(up_facing_clearcoat_blend, "Upface Clear Coat Blend", "", 0, 1, float(1.0));
	#include "used_float.fxh"
	
	DECLARE_FLOAT_WITH_DEFAULT(up_facing_subsurface_blend, "Upface Subsurface Blend", "", 0, 1, float(1.0));
	#include "used_float.fxh"
	
	DECLARE_FLOAT_WITH_DEFAULT(mask_bias,		"Mask Bias", "", 0, 1, float(0.5));
	#include "used_float.fxh"
	DECLARE_FLOAT_WITH_DEFAULT(mask_intensity,		"Mask Intensity", "", 0, 5, float(1.0));
	#include "used_float.fxh"
	DECLARE_FLOAT_WITH_DEFAULT(mask_power,		"Mask Power", "", 0, 50, float(4.0));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(mask_normal_map_influence,		"Mask Normal Map Influence", "", 0, 1, float(0.5));
	#include "used_float.fxh"
	DECLARE_FLOAT_WITH_DEFAULT(mask_combo_influence,		"Mask Combo Influence", "", 0, 1, float(1));
	#include "used_float.fxh"

	DECLARE_FLOAT_WITH_DEFAULT(mask_x_direction,		"Mask X Direction", "", -1, 1, float(0.0));
	#include "used_float.fxh"
	DECLARE_FLOAT_WITH_DEFAULT(mask_y_direction,		"Mask Y Direction", "", -1, 1, float(1.0));
	#include "used_float.fxh"
	DECLARE_FLOAT_WITH_DEFAULT(mask_z_direction,		"Mask Z Direction", "", -1, 1, float(0.0));
	#include "used_float.fxh"
#endif 

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

	shader_data.common.shaderValues.x = 0.0f; 			// Subsurface
	shader_data.common.shaderValues.y = 1.0f; 			// Up Mask
	float3 geometry_normal = shader_data.common.normal;
	float up_mask = 0;
	// Sample normal maps
	
	shader_data.alpha = 1;
	
	float2 macro_normal_uv   = transform_texcoord(uv, macro_normal_map_transform);
	float3 macro_normal = sample_2d_normal_approx(macro_normal_map, macro_normal_uv);	
	
	float2 normal_uv   = transform_texcoord(uv, normal_map_transform);
	float3 base_normal = sample_2d_normal_approx(normal_map, normal_uv);
	
	
	base_normal += macro_normal - float3(0,0,-1);
	base_normal = normalize(base_normal);
	// Use the base normal map
	shader_data.common.normal = base_normal;
	
	// Transform from tangent space to world space
	shader_data.common.normal = normalize(mul(shader_data.common.normal, shader_data.common.tangent_frame));
		
	#ifdef USE_UP_FACING
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
			up_mask = saturate(pow(saturate( maskDirection * mask_intensity), mask_power) );
            
            #ifndef VERTEX_ALPHA
                up_mask += shader_data.common.vertexColor.a;
            #endif 
			up_mask = saturate(up_mask);
				
			float2 up_facing_normal_map_uv = transform_texcoord(uv, up_facing_normal_map_transform);
			float3 up_facing_normal = sample_2d_normal_approx(up_facing_normal_map, up_facing_normal_map_uv);
				
			up_facing_normal += macro_normal - float3(0,0,-1);
            
            #ifdef USE_UP_FACING_DETAIL
                float2 up_facing_detail_normal_uv   = transform_texcoord(uv, up_facing_detail_normal_map_transform);
                float3 up_facing_detail_normal = sample_2d_normal_approx(up_facing_detail_normal_map, up_facing_detail_normal_uv) - float3(0,0,1);

                up_facing_normal += up_facing_detail_normal;
            #endif            
            
			up_facing_normal = mul(normalize(up_facing_normal), shader_data.common.tangent_frame);
			shader_data.common.normal = lerp(shader_data.common.normal, up_facing_normal, up_mask);
	#endif
    {// Sample color map.
	    float2 color_map_uv = transform_texcoord(uv, color_map_transform);
	    shader_data.common.albedo = sample2DGamma(color_map, color_map_uv);
	 
		#ifdef USE_UP_FACING
			float2 up_facing_color_uv = transform_texcoord(uv, up_facing_color_map_transform);
            float4 up_facing_color = sample2DGamma(up_facing_color_map, up_facing_color_uv) * float4(upface_albedo_tint,1);
            
            #ifdef USE_UP_FACING_DETAIL
                
                const float DETAIL_MULTIPLIER = 4.59479f;		// 4.59479f == 2 ^ 2.2  (sRGB gamma)
                // Layer in detail color
                float2 up_facing_detail_color_map_uv = transform_texcoord(uv, up_facing_detail_color_map_transform);
                float4 up_facing_color_detail = sample2DGamma(up_facing_detail_color_map, up_facing_detail_color_map_uv);
                up_facing_color_detail.rgb *= DETAIL_MULTIPLIER;

                up_facing_color.rgb *= up_facing_color_detail;
                
            #endif 
			shader_data.common.albedo = lerp(shader_data.common.albedo, up_facing_color, up_mask);
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
	
	#ifdef USE_PARALLAX
	
		float3x3 tangent_frame = shader_data.common.tangent_frame;
		#if !defined(cgfx)
			//(aluedke) The tangent frame is currently incorrect for transformations into UV space (the binormal is inverted).  Correct for this.
			tangent_frame[1] = -tangent_frame[1];
		#endif
		float2 combo_map_uv   = transform_texcoord(uv, combo_map_transform);
		float3 viewTS = mul(tangent_frame, shader_data.common.view_dir_distance.xyz);
		viewTS /= abs(viewTS.z);				// Do the divide to scale the view vector to the length needed to reach 1 unit 'deep'
		float2 offset = parallax_texcoord(uv, (shader_data.common.normal.x + shader_data.common.normal.y) * parallax_strength + parallax_depth, viewTS, pixel_shader_input);
	
		shader_data.common.shaderValues.x 	= sample2D(combo_map, combo_map_uv + offset).b;
		
	#endif

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
	float parallax_subsurface = shader_data.common.shaderValues.x;
	
	
	float2 clearcoat_normal_uv   = transform_texcoord(uv, clearcoat_normal_map_transform);
	float3 clearcoat_normal = sample_2d_normal_approx(clearcoat_normal_map, clearcoat_normal_uv);
		
	float3 spec_normal = normal;
	spec_normal.xy += clearcoat_normal.xy * clearcoat_normal_scale;
	spec_normal = normalize(spec_normal);
	
	albedo.rgb *= albedo_tint.rgb;

	float2 combo_map_uv   = transform_texcoord(uv, combo_map_transform);
	float4 combo 	= sample2D(combo_map, combo_map_uv);

    float4 combo_parallaxed = float4(0,0,1,0);
	
	combo_parallaxed = combo;
	#ifdef USE_PARALLAX
		combo_parallaxed.b = parallax_subsurface;
	#endif
		
    float3 specular = 0.0f;
	float3 clearcoat_specular = 0.0f;
	
	float rough = roughness * combo.a;
	float metallic =  metallicness * combo.r;
	float cavity = lerp(1, combo.g, cavity_mult);
	float clearcoat_multiplier = clearcoat_blend;
	float subsurface_multiplier = subsurface_blend;
	#ifdef USE_UP_FACING
		float2 upfacing_combo_map_uv   = transform_texcoord(uv, up_facing_combo_map_transform);
		float4 upface_combo 	= sample2D(up_facing_combo_map, upfacing_combo_map_uv);
		rough = lerp(rough, upface_roughness * upface_combo.a, up_mask);
		
		metallic =  lerp( metallic ,  upface_metallicness * upface_combo.r , up_mask);
		cavity =   lerp( cavity,  lerp(1, upface_combo.g, upface_cavity_mult) , up_mask);
		clearcoat_multiplier = lerp(clearcoat_multiplier, up_facing_clearcoat_blend, up_mask);
		subsurface_multiplier = lerp(subsurface_multiplier, up_facing_subsurface_blend, up_mask);
		
		
	#endif 

	float3 specular_color = lerp(pow(float3(0.04, 0.04, 0.04), 2.2), albedo , metallic);

	calc_specular_blinnphong(specular, shader_data.common, normal, specular_color, rough);
	
	calc_specular_blinnphong(clearcoat_specular, shader_data.common, spec_normal, clearcoat_specular_color, pow(clearcoat_roughness, 2.2));
	
	float3 subsurface = 0.0f;
	
	calc_subsurface(subsurface, shader_data.common, spec_normal, float3(subsurface_distortion, subsurface_power, subsurface_scale), float2(combo_parallaxed.b, subsurface_wrap));
	
    float3 diffuse = 0.0f;
	float3 diffuse_reflection_mask = 0.0f;

	calc_diffuse_lambert_wrap(diffuse, shader_data.common, normal, light_wrap, 1);
    
	float3 reflection = 0.0f;
	
		// sample reflection
	float3 view = -shader_data.common.view_dir_distance.xyz;
		 
	float3 rVec = reflect(view, normal);
	
	float mip_index = (1-rough) * 7.0f;
	
	float4 reflectionMap = sampleCUBELOD(reflection_map, rVec, mip_index, false);
	
	float3 rgb2lum = float3(0.30, 0.59, 0.11);
	
	float3 fresnel = FresnelSchlickWithRoughness(specular_color, view, normal, rough);
	reflection = reflectionMap.rgb * reflectionMap.a * reflection_multiplier * fresnel;

   float clearcoat_mip_index = (1-clearcoat_roughness) * 7.0f;
   float3 clearcoat_rVec = reflect(view, spec_normal);
   float4 clearcoat_reflection = sampleCUBELOD(reflection_map, clearcoat_rVec, clearcoat_mip_index, false) ;
   clearcoat_reflection.rgb *=  FresnelSchlick(clearcoat_specular_color, -view, spec_normal)  * clearcoat_reflection.a * reflection_multiplier ;
	
	
	//.. Finalize Output Color
    float4 out_color;
	out_color.a   = shader_data.alpha;

	float3 color_map =  lerp(albedo, float3(0,0,0), metallic); 
	
    out_color.rgb =  color_map * diffuse + diffuse.rgb * reflection + specular;
	//out_color.rgb += clearcoat_reflection * diffuse;
	out_color.rgb += clearcoat_specular * clearcoat_multiplier;
	out_color.rgb += (subsurface + subsurface_ambient * combo_parallaxed.b )* subsurface_color * subsurface_multiplier;
	
	out_color.rgb *= cavity;
	return out_color;
}


#include "techniques.fxh"