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

#ifdef USE_MACRO_COLORMAP
    DECLARE_SAMPLER( macro_color_map, "Macro Color Map", "Macro Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
    #include "next_texture.fxh"    
#endif 

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

#ifdef USE_ANIMATION 
    #ifdef USE_NEW_ANIMATION
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_frequency_x,	"Foliage Animation Frequency X", "", 0, 1, float(360.0));
        #include "used_vertex_float.fxh"
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_intensity_x,	"Foliage Animation Intensity X", "", 0, 1, float(0.04));
        #include "used_vertex_float.fxh"
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_offset_x,	"Foliage Animation Offset X", "", 0, 1, float(0.0));
        #include "used_vertex_float.fxh"
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_speed_x,	"Foliage Animation Speed X", "", 0, 1, float(0.0));
        #include "used_vertex_float.fxh"
        
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_frequency_y,	"Foliage Animation Frequency Y", "", 0, 1, float(360.0));
        #include "used_vertex_float.fxh"
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_intensity_y,	"Foliage Animation Intensity Y", "", 0, 1, float(0.04));
        #include "used_vertex_float.fxh"
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_offset_y,	"Foliage Animation Offset Y", "", 0, 1, float(0.0));
        #include "used_vertex_float.fxh"      
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_speed_y,	"Foliage Animation Speed Y", "", 0, 1, float(0.0));
        #include "used_vertex_float.fxh"
        
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_frequency_z,	"Foliage Animation Frequency Z", "", 0, 1, float(360.0));
        #include "used_vertex_float.fxh"
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_intensity_z,	"Foliage Animation Intensity Z", "", 0, 1, float(0.04));
        #include "used_vertex_float.fxh"
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_offset_z,	"Foliage Animation Offset Z", "", 0, 1, float(0.0));
        #include "used_vertex_float.fxh"     
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_speed_z,	"Foliage Animation Speed Z", "", 0, 1, float(0.0));
        #include "used_vertex_float.fxh"        

        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(fake_time,	"Fake Time", "", 0, 1000, float(0.0));
        #include "used_vertex_float.fxh"
    #else
        // a couple parameters for vertex animation
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_frequency,	"Foliage Animation Frequency", "", 0, 1, float(360.0));
        #include "used_vertex_float.fxh"
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_intensity,	"Foliage Animation Intensity", "", 0, 1, float(0.04));
        #include "used_vertex_float.fxh"
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_offset_x,	"Foliage Animation Offset X", "", 0, 1, float(0.0));
        #include "used_vertex_float.fxh"
        DECLARE_VERTEX_FLOAT_WITH_DEFAULT(animation_offset_y,	"Foliage Animation Offset Y", "", 0, 1, float(0.0));
        #include "used_vertex_float.fxh"
    #endif     
#endif 

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


#ifdef USE_ANIMATION
    #if defined(xenon) || defined(cgfx) || (DX_VERSION == 11)
        #ifdef USE_NEW_ANIMATION
        

            float3 GetVibrationOffset(in float3 position, float4 color)
            {
            
                #if !defined(cgfx)
                    float anim_time = vs_time.z;
                #else
                    float anim_time = frac(vs_time.x/600.0f);
                #endif
                float3 vibrationCoeff;
                float distance_x = (position.x);
                float distance_y = (position.y);
                float distance_z = (position.z);

                float id = position.x + animation_offset_x ;
                vibrationCoeff.x = (sin((distance_y + anim_time * animation_speed_x + animation_offset_x) * animation_frequency_x) ) * animation_intensity_x  ;//PeriodicVibration(id / 0.53);

                id = position.y + animation_offset_y ;
                vibrationCoeff.z = (sin((distance_y + anim_time * animation_speed_z + animation_offset_z) * animation_frequency_z) ) * animation_intensity_z ; //PeriodicVibration(id / 1.1173);

                vibrationCoeff.y = (sin((distance_z + anim_time * animation_speed_y + animation_offset_y) * animation_frequency_y) ) * animation_intensity_y;
                //float2 direction = frac(id.xx / float2(0.727, 0.371)) - 0.5;
        //
                return  color.a * vibrationCoeff.xyz ;
            }

            #define custom_deformer(vertex, vertexColor, local_to_world)			\
            {																		\
                vertex.position.xyz += GetVibrationOffset(vertex.position.xyz, vertexColor);\
            }
           
        #else
           

            float PeriodicVibration(in float animationOffset)
            {
            #if !defined(cgfx)
                float vibrationBase = 2.0 * abs(frac(animationOffset + animation_frequency * vs_time.z) - 0.5);
            #else
                float vibrationBase = 2.0 * abs(frac(animationOffset + animation_frequency * frac(vs_time.x/600.0f)) - 0.5);
            #endif
                return sin((0.5f - vibrationBase) * 3.14159265f);
            }

            float3 GetVibrationOffset(in float2 texture_coord, float animationOffset, float4 color)
            {
                float2 vibrationCoeff;
                float distance = frac(texture_coord.x);

                float id = texture_coord.x + animation_offset_x - distance + animationOffset;
                vibrationCoeff.x = PeriodicVibration(id / 0.53);

                id = texture_coord.y + animation_offset_y - distance + animationOffset;
                vibrationCoeff.y = PeriodicVibration(id / 1.1173);

                float2 direction = frac(id.xx / float2(0.727, 0.371)) - 0.5;

                return distance * animation_intensity * color.a * vibrationCoeff.xxy * float3(direction.xy, 0.3f);
            }

            #define custom_deformer(vertex, vertexColor, local_to_world)			\
            {																		\
                float animationOffset = dot(float3(1,1,1), vertex.position.xyz);	\
                vertex.position.xyz += GetVibrationOffset(vertex.texcoord.xy, animationOffset, vertexColor);\
            }

        #endif
        
    #endif
#endif	


void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;
    float2 uv2 = pixel_shader_input.texcoord.zw;

	shader_data.common.shaderValues.x = 1.0f; 			// Default specular mask

	// Calculate the normal map value
    {
		// Sample normal maps
    	float2 normal_uv   = transform_texcoord(uv, normal_map_transform);
        float3 base_normal = sample_2d_normal_approx(normal_map, normal_uv);
		// Use the base normal map
		shader_data.common.normal = base_normal;

		// Transform from tangent space to world space
		shader_data.common.normal = mul(shader_data.common.normal, shader_data.common.tangent_frame);
    }

    {// Sample color map.
	    float2 color_map_uv = transform_texcoord(uv, color_map_transform);
	    shader_data.common.albedo = sample2DGamma(color_map, color_map_uv);
	 
        const float MACRO_MULTIPLIER = 4.59479f;		// 4.59479f == 2 ^ 2.2  (sRGB gamma)
		#ifdef USE_MACRO_COLORMAP
            float2 macro_coMap_uv = transform_texcoord(uv2, macro_color_map_transform);
            float4 macro_color = sample2DGamma(macro_color_map, macro_coMap_uv) ;
            macro_color.rgb *= MACRO_MULTIPLIER;
            shader_data.common.albedo *= macro_color;
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
	combo.a = combo.a;
 
    float3 specular = 0.0f;
	float rough = roughness * combo.r;
	// using blinn specular model
	float metallic = metallicness ; 
	float3 specular_color = lerp(float3(0.08, 0.08, 0.08), albedo , metallic);
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
