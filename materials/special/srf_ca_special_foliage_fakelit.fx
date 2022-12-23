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
#define MATERIAL_SHADER_ANNOTATIONS 	<bool is_alpha_clip = true;>

// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"

// Texture Samplers
DECLARE_SAMPLER( color_map, "Color Map", "Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( tint_map, "Tint Map", "Tint Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"    

DECLARE_SAMPLER( normal_map, "Normal Map", "Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"


// Diffuse
		
DECLARE_FLOAT_WITH_DEFAULT(clip_threshold,		"Clipping Threshold", "", 0, 1, float(0.3));
#include "used_float.fxh"

/*
DECLARE_RGB_COLOR_WITH_DEFAULT(albedo_tint,		"Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(macro_red,		"Macro Red", "", float3(1,0,0));
#include "used_float3.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(macro_green,		"Macro Green", "", float3(0,1,0));
#include "used_float3.fxh"
*/

//Fake lighting

DECLARE_FLOAT_WITH_DEFAULT(light_1_x, "Light 1         X", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_y, "Light 1         Y", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_z, "Light 1         Z", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_intensity, "Light 1      Int", "", 0, 100, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(light_1_color, "Light 1  Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_wrap, "Light 1  Wrap", "", 0, 1, float(0.0));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_x, "Light 2         X", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_y, "Light 2         Y", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_z, "Light 2         Z", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_intensity, "Light 2      Int", "", 0, 100, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(light_2_color, "Light 2  Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_wrap, "Light 2  Wrap", "", 0, 1, float(0.0));
#include "used_float3.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(ambient_color, "Ambient Color", "", float3(0,0,0));
#include "used_float3.fxh"

//Animation Parameters
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


struct s_shader_data {
	s_common_shader_data common;
    float  alpha;
};

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

        float2 tint_map_uv = transform_texcoord(uv2, tint_map_transform);
        float4 color_tint = sample2D(tint_map, tint_map_uv) ;
		

        //color_tint.rgb *= MACRO_MULTIPLIER;
        shader_data.common.albedo *= color_tint * 2.0f;

	/*	
        shader_data.common.albedo = lerp(shader_data.common.albedo, shader_data.common.albedo * float4(macro_red.rgb, 0), color_tint.r);
		shader_data.common.albedo += shader_data.common.albedo * float4(macro_red.rgb, 0) * color_tint.r;
		shader_data.common.albedo += shader_data.common.albedo * float4(macro_green.rgb, 0) * color_tint.g;
		shader_data.common.albedo *= color_tint.b * 2.0f;
	*/
	
        float2 alpha_uv		= uv;
		shader_data.alpha	= sample2DGamma(color_map, alpha_uv).a;

        clip(shader_data.alpha - clip_threshold);

	}
}



float4 pixel_lighting(
	        in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data) 
	
	
{
float2 uv = pixel_shader_input.texcoord.xy;
 
	///..input from s_shader_data
    float4 albedo         = shader_data.common.albedo;
    float3 normal         = shader_data.common.normal;

	///..Fake lighting vectors
	#if defined(cgfx)
		float3 light_1 = normalize(float3(light_1_x, light_1_y, light_1_z));
		float3 light_2 = normalize(float3(light_2_x, light_2_y, light_2_z));	
	#else
		float3 light_1 = normalize(float3(light_1_z, light_1_x, light_1_y));
		float3 light_2 = normalize(float3(light_2_z, light_2_x, light_2_y));
    #endif	


    float3 diffuse = 0.0f;
	
	///..Half Lambert 
	float wrap_1 = 1-light_1_wrap;
	float wrap_2 = 1-light_2_wrap;
	float lambert_1 = saturate(dot(normal, light_1)  * wrap_1 + (1-wrap_1)) ;
	float lambert_2 = saturate(dot(normal, light_2)  * wrap_2 + (1-wrap_2)) ;
	diffuse = (lambert_1 * light_1_color * light_1_intensity) + (lambert_2 * light_2_color * light_2_intensity) + ambient_color.rgb;
	
	//albedo.rgb *= albedo_tint.rgb;

	///.. Finalize Output Color

    float4 out_color;
	out_color.a   = shader_data.alpha;

	float3 color_map =  albedo; 
	
    out_color.rgb =  color_map * diffuse;

	return out_color;
}


#include "techniques.fxh"
