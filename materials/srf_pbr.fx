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

#if !defined(ALPHA_CLIP)
	#define DISABLE_LIGHTING_TANGENT_FRAME
	#define DISABLE_LIGHTING_VERTEX_COLOR

	#define DISABLE_SHARPEN_FALLOFF
#endif


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

#ifdef USE_GRIME
DECLARE_SAMPLER( grime_map, "Grime Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(grime_multiplier, "Grime Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

#endif 

#ifdef USE_DECAL
    DECLARE_SAMPLER( decal_map, "Decal Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
    #include "next_texture.fxh"
#endif 

#ifdef USE_SELFILLUM_NOISE
    DECLARE_SAMPLER( self_illum_noise_map, "Self Illum Noise Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
    #include "next_texture.fxh"
#endif 

DECLARE_SAMPLER_CUBE(reflection_map,  "Reflection Map", "", "shaders/default_bitmaps/bitmaps/default_cube.tif")
#include "next_texture.fxh"

#ifdef TINTABLE_VERSION

	DECLARE_SAMPLER( tint_map, "Tint Map", "Tint Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
	#include "next_texture.fxh"

	DECLARE_RGB_COLOR_WITH_DEFAULT(base_color,	"Base Color", "", float3(1,1,1));
	#include "used_float3.fxh"

	// Diffuse Primary and Secondary Change Colors
	#if defined(cgfx) || defined(ARMOR_PREVIS)
		DECLARE_RGB_COLOR_WITH_DEFAULT(tmp_primary_cc,	"Test Primary Color", "", float3(1,1,1));
		#include "used_float3.fxh"
		DECLARE_RGB_COLOR_WITH_DEFAULT(tmp_secondary_cc,	"Test Secondary Color", "", float3(1,1,1));
		#include "used_float3.fxh"
	#endif

#endif 
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

DECLARE_FLOAT_WITH_DEFAULT(reflection_intensity, "Reflection Intensity", "", 0, 10, float(5.0));
#include "used_float.fxh"

#if defined(ALPHA_CLIP)
#define MATERIAL_SHADER_ANNOTATIONS 	<bool is_alpha_clip = true;>
#endif

#if defined(HEIGHT_MASK)
    DECLARE_FLOAT_WITH_DEFAULT(height_influence, "Height Map Influence", "", 0, 1, float(1.0));
    #include "used_float.fxh"
    DECLARE_FLOAT_WITH_DEFAULT(threshold_softness, "Height Map Threshold Softness", "", 0.01, 1, float(0.1));
    #include "used_float.fxh"
#endif


DECLARE_FLOAT_WITH_DEFAULT(spec_coeff, "Specular Coefficient", "", 0.01, 1, float(0.04));
#include "used_float.fxh"

///
#if defined(ALPHA_CLIP) 
DECLARE_FLOAT_WITH_DEFAULT(clip_threshold,		"Clipping Threshold", "", 0, 1, float(0.3));
#include "used_float.fxh"

#if defined(ALPHA_CLIP_ALBEDO_ONLY)
DECLARE_FLOAT_WITH_DEFAULT(alpha_threshold,		"Clipping Threshold", "", 0, 1, float(0.3));
#include "used_float.fxh"

#endif
#endif

#if defined( USE_WORLDSPACE )

DECLARE_SAMPLER(world_color_texture,		"World Space Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(world_texture_blend,		"World Space Map Blend", "", 0, 1, float(1));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(world_texture_intensity,		"World Space Map Intensity", "", 0, 1, float(1));
#include "used_float.fxh"

#endif //#if defined( USE_WORLDSPACE )

struct s_shader_data {
	s_common_shader_data common;
};

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
		
		#ifdef USE_GRIME
			float2 grime_map_uv = transform_texcoord(uv2, grime_map_transform);
			float4 grime = sample2DGamma(grime_map, grime_map_uv);
			shader_data.common.albedo.rgb = lerp( shader_data.common.albedo.rgb, shader_data.common.albedo.rgb * grime.rgb, grime_multiplier);
			shader_data.common.shaderValues.x = grime.r;
		#endif 
		
		#if defined( USE_WORLDSPACE )
		{
			const float MACRO_MULTIPLIER = 4.59479f;		// 4.59479f == 2 ^ 2.2  (sRGB gamma)		
			float2 world_color_texture_yz_uv = transform_texcoord(shader_data.common.position.yz, world_color_texture_transform);
			float3 world_color_yz = sample2DGamma(world_color_texture, world_color_texture_yz_uv);
			
			float2 world_color_texture_xz_uv = transform_texcoord(shader_data.common.position.xz , world_color_texture_transform);
			float3 world_color_xz = sample2DGamma(world_color_texture, world_color_texture_xz_uv);
			
			#if defined(xenon) || (DX_VERSION == 11)
				float3 world_color = lerp(world_color_yz, world_color_xz, saturate(abs(pow(dot(shader_data.common.normal, float3(0,1,0)), 5))));
				world_color *= MACRO_MULTIPLIER * world_texture_intensity;
				world_color = lerp(1, world_color, world_texture_blend);
				
				shader_data.common.albedo.rgb = lerp(shader_data.common.albedo.rgb, shader_data.common.albedo.rgb * world_color.rgb , shader_data.common.vertexColor.a);
			#endif 
		}
		#endif 
		
		#ifdef USE_DECAL
			float2 decal_map_uv = transform_texcoord(uv2, decal_map_transform);
			float4 decal = sample2DGamma(decal_map, decal_map_uv);
		
			shader_data.common.albedo.rgb = lerp(shader_data.common.albedo.rgb , decal.rgb, decal.a);
		
		#endif 
		
		
		#ifdef TINTABLE_VERSION
		
			float4 control_map = sample2DGamma(tint_map, color_map_uv);
			// determine surface color
			// primary change color engine mappings, using temp values in maya for prototyping
			float4 primary_cc = 1.0;
			float3 secondary_cc = 1.0f;

			#if defined(cgfx)  || defined(ARMOR_PREVIS)
				primary_cc   = float4(tmp_primary_cc, 1.0);
				secondary_cc = float4(tmp_secondary_cc,1.0);
			#else
				primary_cc   = ps_material_object_parameters[0];
				secondary_cc = ps_material_object_parameters[1];
			#endif

			float3 surface_colors[3] = {base_color.rgb,
										secondary_cc.rgb,
										primary_cc.rgb};
			float3 surface_color;
			
			surface_color = primary_cc * control_map.r;
			surface_color += secondary_cc * control_map.g;
			surface_color += base_color * control_map.b;
			
			// output color
			shader_data.common.albedo.rgb = lerp(shader_data.common.albedo.rgb, surface_color, control_map.a);
		#endif 
		
		shader_data.common.albedo.rgb *= albedo_tint.rgb;
	 
	 float alpha;
#if defined(FIXED_ALPHA)
        float2 alpha_uv		= uv;
		alpha	= sample2DGamma(color_map, alpha_uv).a;
#else
        alpha	= shader_data.common.albedo.a;
#endif


	#if defined(HEIGHT_MASK)
		//shader_data.common.albedo.a is the height_mask
		alpha = saturate( (shader_data.common.vertexColor.a - ( 1 - shader_data.common.albedo.a )) / max(0.001, threshold_softness)  );
		alpha = lerp( shader_data.common.vertexColor.a, alpha, height_influence );
	#endif

#if defined(VERTEX_ALPHA)
		alpha *= shader_data.common.vertexColor.a;
#endif

        #if defined(ALPHA_CLIP) && defined(ALPHA_CLIP_ALBEDO_ONLY)
                // Tex kill non-opaque pixels in albedo pass; tex kill opaque pixels in all other passes
                if (shader_data.common.shaderPass != SP_SINGLE_PASS_LIGHTING)
                {
                    // Clip anything that is less than the alpha threshold in the alpha
                    clip(alpha - alpha_threshold);
                }
                else
                {
                    // Reverse the order, so anything larger than the near-white threshold is clipped
                    clip(alpha_threshold - alpha);
					//still clip the low end
					clip(alpha - clip_threshold);

					//renormalize the alpha space so we get a better control.
					alpha = alpha / alpha_threshold;
                }
        #elif defined(ALPHA_CLIP)
                // Tex kill pixel
                clip(alpha - clip_threshold);
        #endif

        #ifdef USE_SELFILLUM_NOISE
            float2 self_illum_noise_uv = transform_texcoord(uv2, self_illum_noise_map_transform);
            float4 self_illum_noise = sample2D(self_illum_noise_map, self_illum_noise_uv);
             
            shader_data.common.shaderValues.x = self_illum_noise.r * shader_data.common.vertexColor.a;
        #endif 
        
        shader_data.common.shaderValues.y = alpha;
	}
}

 
 
float4 pixel_lighting(
	        in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data) 
{
	float2 uv = pixel_shader_input.texcoord.xy;
	float alpha = shader_data.common.shaderValues.y;
 
    // input from s_shader_data
    float4 albedo         = shader_data.common.albedo;
    float3 normal         = shader_data.common.normal;
	
	// Sample combo map, r = metalicness, g = cavity multiplier (fake AO), b = Self Illume map, a = roughness
	float2 combo_map_uv	= transform_texcoord(uv, combo_map_transform);
	float4 combo 	= sample2D(combo_map, combo_map_uv);
    
     float3 specular = 0.0f;
	 #ifdef USE_TERRAIN_COMBO
	 	float rough = saturate(roughness * combo.g);
		float metallic = metallicness * combo.b; 
		float cavity_ao = lerp(1, combo.r, cavity_mult);
		float3 selIllum = float3(0,0,0);	
	 #else
	 
	 	float rough = saturate(roughness * combo.a);
		float metallic = metallicness * combo.r; 
		float cavity_ao = lerp(1, combo.g, cavity_mult);
		float3 selIllum = albedo.rgb * combo.b * emissive;		
	 #endif 
	 
    #ifdef USE_SELFILLUM_NOISE
        selIllum *= shader_data.common.shaderValues.x;
    #endif 

    #ifdef USE_GRIME
        float grime = shader_data.common.shaderValues.x ;
        rough = lerp(rough, rough * grime, grime_multiplier);
    #endif 
	// using blinn specular model
	float3 specular_color = lerp(pow(float3(spec_coeff, spec_coeff, spec_coeff), 2.2), albedo, metallic);
	
	calc_specular_blinnphong(specular, shader_data.common, normal, specular_color, rough);
    
	//calculate diffuse
	float3 diffuse = 0.0f;
	calc_diffuse_lambert(diffuse, shader_data.common, normal); 
	
	// sample reflection
	float3 view = shader_data.common.view_dir_distance.xyz;
		 
	float3 rVec = reflect(view, normal);
	float mip_index = (1-rough) * 7.0f;
	float4 reflectionMap = sampleCUBELOD(reflection_map, rVec, mip_index, false);
	float gloss = 1.f - rough;
	float3 fresnel = FresnelSchlickWithRoughness(specular_color, -view, normal, gloss);
	float3 reflection =  (reflectionMap.rgb + (reflectionMap.a * reflectionMap.rgb * reflection_intensity)) * saturate(reflection_intensity)  * fresnel;

	//.. Finalize Output Color
    float4 out_color;
	out_color.a   = alpha;

	float3 color_map =  albedo * (1- metallic);//the albedo color will come through the specular if we are metalic
	 
	out_color.rgb = ( color_map * diffuse.rgb ) + ( diffuse.rgb * reflection ) + specular;

	//add self alumination

	out_color.rgb += selIllum;
 
	//Cavity AO

	out_color.rgb *= cavity_ao;
	//out_color.rgb = metallic;
	// Output self-illum intensity as linear luminance of the added value
	shader_data.common.selfIllumIntensity =  GetLinearColorIntensity(selIllum * cavity_ao);	
	
	//boost tint color based on distance
	#ifdef TINTABLE_VERSION
		float4 primary_cc = 1.0;

		#if defined(cgfx)  || defined(ARMOR_PREVIS)
			primary_cc   = float4(tmp_primary_cc, 1.0);
		#else
			primary_cc   = ps_material_object_parameters[0];
		#endif
		out_color.rgb = lerp(out_color.rgb  ,  out_color.rgb +  pow(saturate(dot(normal, float3(0,0,1))),3) * reflectionMap.rgb * reflectionMap.a * 5, pow(saturate((shader_data.common.view_dir_distance.w ) / 25), 2));
	#endif 
	return out_color;
}


#include "techniques.fxh"
