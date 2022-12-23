//
// File:	 srf_water_io_relic.fx
// Author:	 mahlin
// Date:	 03/09/54
//
// Surface Shader - Based on Luiz's water shader, modified for Sway Relic- includes vertex offset, new foam and edge blend techniques. No lighting or specular.
//
// Copyright (c) 343 Industries. All rights reserved.
//
// Notes:
//


#define ENABLE_DEPTH_INTERPOLATER
#if defined(xenon)
#define ENABLE_VPOS
#endif

#define DISABLE_SH
//#define DISABLE_LIGHTING_TANGENT_FRAME
// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"
#include "ca_depth_access.fxh"

// Frame Buffer

//#include "ca_depth_access.fxh"

//.. Artistic Parameters

// Texture Samplers
DECLARE_RGB_COLOR_WITH_DEFAULT(diffuse_color,		"Diffuse Color", "",  float3(1,1,1)) ;
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(diffuse_fade_range,  "Diffuse Fade Range", "", 0, 5, float(0.4));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(water_fade_range,  "Water Fade Range", "", 0, 5, float(0.4));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(water_fade_sharpness,  "Water Fade Sharpness", "", 0, 5, float(0.4));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(water_fade_intensity,  "Water Fade Intensity", "", 0, 5, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fadenoise_intensity,  "Fade Noise Intensity", "", 0, 5, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(diffuse_texcoord_shift,   "Diffuse Texcoord Shift",   "", 0, 1, float(0.03));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(water_shadow_intensity,  "Water Shadow Intensity", "", 0, 5, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(foam_shadow_intensity,  "Water Shadow Intensity", "", 0, 5, float(1.0));
#include "used_float.fxh"

DECLARE_SAMPLER( macro_normal_map, "Macro Normal Map", "", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( macro_normal_map_2, "Macro Normal Map 2", "", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(macro_normal_intensity, "Macro Normal Strength", "", 0, 1, float(1.0)) ;
#include "used_float.fxh"

DECLARE_SAMPLER( noise_map, "Noise Map", "Noise Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( noise_map_2, "Noise Map 2", "Noise Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(noise_strength, "Noise Strength", "", 0, 1, float(0.1)) ;
#include "used_float.fxh"

DECLARE_SAMPLER(flow_map, "Flow Map", "", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER(combo_map, "Combo Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(max_distort, "Maxium Distortion", "", 0, 1, float(0.3));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(water_speed, "Water Speed", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_SAMPLER( wave_normal_map, "Wave Normal Map", "", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(water_detail_intensity, "Water Detail Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"


DECLARE_SAMPLER_CUBE(reflection_map,  "Reflection Map", "", "shaders/default_bitmaps/bitmaps/default_cube.tif")
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(reflection_intensity, "Reflection Intensity", "", 0, 10, float(5));
#include "used_float.fxh"
// Diffuse


DECLARE_FLOAT_WITH_DEFAULT(water_roughness, "Water Roughness", "", 0, 1, float(0.7)) ;
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(water_specular_color, "Water Specular Color", "", float3(1, 1, 1)) ;
#include "used_float3.fxh"


// Foam settings
DECLARE_SAMPLER(foam_texture,        "Foam Texture", "Foam Texture", "");
#include "next_texture.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(foam_tint,		"Foam Tint", "",  float3(1,1,1)) ;
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(foam_speed,           "Foam Speed", "", 0, 1, float(1.0)) ;
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(foam_intensity,        "Foam Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(foam_spec_blend, "Foam Spec Blend", "", 0, 1, float(0.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(bubbles_intensity,        "Bubbles Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

// a couple parameters for vertex animation

DECLARE_VERTEX_FLOAT_WITH_DEFAULT(wave_x_warp_frequency,	"Wave X Warp Frequency", "", 0, 1, float(0.0));
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(wave_x_warp,	"Wave X Warp", "", 0, 1, float(0.0));
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(wave_x_frequency,	"Wave X Frequency", "", 0, 1, float(360.0));
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(wave_x_speed,	"Wave X Speed", "", 0, 1, float(360.0));
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(wave_x_scale,	"Wave X Scale ", "", 0, 1, float(1.0));
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(wave_y_frequency,	"Wave Y Frequency", "", 0, 1, float(360.0));
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(wave_y_speed,	"Wave Y Speed", "", 0, 1, float(360.0));
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT_WITH_DEFAULT(wave_y_scale,	"Wave Y Scale ", "", 0, 1, float(1.0));
#include "used_vertex_float.fxh"



#if (DX_VERSION == 11) && !defined(cgfx)
	SamplerState MeshTextureSampler
	{
		Filter = MIN_MAG_MIP_LINEAR;
		AddressU = Wrap;
		AddressV = Wrap;
	};
#endif 


struct s_shader_data {
	s_common_shader_data common;
};

#if defined(xenon) || defined(cgfx) || (DX_VERSION == 11)

#define custom_deformer(vertex, vertexColor, local_to_world)			\
{																		\
	float wave_x_warp_amt = sin(vertex.position.y * wave_x_warp_frequency) * wave_x_warp; \
	float wave_x = sin(((vertex.position.x + wave_x_warp_amt)* wave_x_frequency) + (frac(vs_time.x/600.0f) * wave_x_speed)) + 1.0; \
	wave_x *= wave_x_scale; \
	float wave_y = (cos(vertex.position.x * wave_y_frequency) * cos((vertex.position.y * wave_y_frequency) + sin(frac(vs_time.x/600.0f)) * wave_y_speed)) + 1.0; \
	wave_y *= wave_y_scale; \
	float wave = wave_y * wave_x; \
	vertex.position.z += wave * vertexColor.a; \
}

#endif

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;
	float2 uv2 = pixel_shader_input.texcoord.zw;

	shader_data.common.shaderValues.x = 1.0f; 			// Default specular mask

	float4 flow = sample2D(flow_map, uv2);
	float4 combo 	= sample2D(combo_map, uv2);
  
	float foam_mask = combo.a;
	float force_depth = combo.g;
	float border_alpha = combo.r;
	float water_shadow = combo.b;
	
	flow.b = 1;
	flow = flow * 2 - 1;

	float4 bubbleflow = flow;
	flow.rgb *= max_distort;
	bubbleflow.rbg *= (max_distort * .5);
	flow.rgb *= -1;
	bubbleflow.rgb *= -1;
	
	float time = ps_time.x ;
	
	float2 noise_map_uv 	   = transform_texcoord(uv, noise_map_transform);
	float4 noise = sample2D(noise_map, noise_map_uv );
	
	float2 noise_map_2_uv 	   = transform_texcoord(uv, noise_map_2_transform);
	float4 noise2 = sample2D(noise_map_2, noise_map_2_uv );
	
	float noise_red = noise.r;
	
	float edge_noise = noise.g * noise2.g;
	
	float bubble_mask = noise.b * noise2.b;
	
	float bubbles = noise.a * noise2.a;
	
	//edge_noise = saturate(pow(edge_noise, fadenoise_sharpness) * fadenoise_intensity);
	edge_noise = saturate(edge_noise * fadenoise_intensity);		
	
	float phase = (noise_red * noise_strength + time ) * water_speed ;
	float phase0Offset = floor(phase);
	float phase0 = (phase - phase0Offset )  ; 
	float phase1Offset = floor(phase  + .5);
	float phase1 = (phase   + .5 - phase1Offset);

	float2 wave_normal_uv 	   = transform_texcoord(uv, wave_normal_map_transform);

	float3 water_detail_map = sample_2d_normal_approx(wave_normal_map, (wave_normal_uv - float2(phase0,phase0) * float2(flow.r , flow.g  ) + float2(phase0Offset*0.137f,phase0Offset*0.856) ) );
	float3 water_detail_map2 = sample_2d_normal_approx(wave_normal_map, (wave_normal_uv - float2(phase1,phase1) * float2(flow.r , flow.g  ) + float2(phase1Offset*0.237f,phase1Offset*0.556) ) );//* float2(flow.r , -flow.g   ) *water_speed;

	float flowLerp =  2 * abs(phase0 - 0.5);

	water_detail_map = lerp(water_detail_map, water_detail_map2, flowLerp) ;

	water_detail_map.xy *= water_detail_intensity * length(float3(flow.r ,flow.g,0));

	//TODO: we can do a better faked reftraction lookup than this. We should be using the normal and view angle to figure it out...
	float waterFade = 1.0;
	float flow_depth = 0;
	float depthRefractAmount = 1.0f;
	float deltaDepthUnrefracted = 1.0f;
    #if (DX_VERSION == 11) && !defined(cgfx)
	{
		
		//sample the depth buffer to find out how much fog to add to the water.
		float sceneDepth = 0;
		float2 depthTexPosFlat = shader_data.common.platform_input.fragment_position.xy * psDepthConstants.z;
		sampleDepth( depthTexPosFlat , sceneDepth );
		float deltaDepth = sceneDepth - pixel_shader_input.view_vector.w;
		deltaDepthUnrefracted = deltaDepth;
		depthRefractAmount = saturate(deltaDepth / diffuse_fade_range);

		waterFade = saturate(deltaDepth / water_fade_range) * (1-flow_depth);
		flow_depth = saturate(deltaDepth / diffuse_fade_range);

		//TODO: do not assume a texture res of 1920x1080.....
		float refactSceneDepth = 0;
		float2 depthTexPos = (shader_data.common.platform_input.fragment_position.xy + (float2(1920.0f, 1080.0f) * water_detail_map.rg * diffuse_texcoord_shift * depthRefractAmount) ) * psDepthConstants.z;
		sampleDepth( depthTexPos , sceneDepth );

		deltaDepth = sceneDepth - pixel_shader_input.view_vector.w;
		float altFlowDepth = saturate(deltaDepth / diffuse_fade_range);
		flow_depth = lerp(flow_depth, altFlowDepth, altFlowDepth );
	}
    #else
        flow_depth = 1;
		float deltaDepth = 1.0f;

    #endif 

	waterFade *= saturate(waterFade + edge_noise);
	
	waterFade = saturate(pow(waterFade, water_fade_sharpness) * water_fade_intensity);
	
	//waterFade = saturate(waterFade * water_fade_intensity);
    
	water_detail_map.xy *= waterFade * flow_depth;
	
	float2 macro_normal_uv = transform_texcoord(uv , macro_normal_map_transform);
	float3 macro_normal = sample_2d_normal_approx(macro_normal_map, macro_normal_uv).rgb;

	float2 macro_normal_2_uv = transform_texcoord(uv , macro_normal_map_2_transform);
	float3 macro_normal_2 = sample_2d_normal_approx(macro_normal_map_2, macro_normal_2_uv).rgb;		

	macro_normal +=  macro_normal_2 - float3(0,0,1) ;	
	macro_normal.xy *=  macro_normal_intensity;
	macro_normal +=  water_detail_map - float3(0,0,1) ;
	
	float3 normal = mul(macro_normal, shader_data.common.tangent_frame);
	
	shader_data.common.normal = normalize(normal);			// Do we need to renormalize?

	float2 vPos = 0;
	float3 color_refraction = float3(0,0,0);
	

	#if (DX_VERSION == 11) && !defined(cgfx)
		vPos = shader_data.common.platform_input.fragment_position.xy  * (1/ps_textureSize.xy) ;
		float2 texcoord_refraction = vPos+ macro_normal.rg * diffuse_texcoord_shift; 
		int3 screen_texcoord = int3(vPos, 0);
		color_refraction = ps_view_albedo.Sample(MeshTextureSampler, texcoord_refraction) ;		
		//color_refraction = texcoord_refraction;
	#endif

	shader_data.common.albedo.rgb = lerp(color_refraction, diffuse_color, saturate(flow_depth + force_depth));


///////////////////////////////////////////////////////////////////////////
	/// Foam
	///////////////////////////////////////////////////////////////////////////


	float4 foam_color = 0.0f;

	// compute foam
	float foam_factor = foam_intensity;
	foam_factor *= min(max(20 /shader_data.common.view_dir_distance.w, 0.0f), 1.0f);

	float2 foam_texture_uv = transform_texcoord(uv , foam_texture_transform);
	float foam_phase = (  noise_red * noise_strength +time) * foam_speed   ;
	float foam_phase0Offset = floor(foam_phase);
	float foam_phase0 = (foam_phase - foam_phase0Offset )  ;
	float foam_phase1Offset = floor(foam_phase  + .5);
	float foam_phase1 = (foam_phase   + .5 - foam_phase1Offset)   ;

	float foam_flowLerp =  2 * abs(foam_phase0 - 0.5);		
	//float bubbles_flowLerp =  1 * abs(foam_phase0 - 0.5);	
	
	float3 foam1 = sample2D(foam_texture, (foam_texture_uv -  foam_phase0 * float2(flow.r , flow.g ) + float2(foam_phase0Offset*0.137f,foam_phase0Offset*0.856) ));
	float3 foam2 = sample2D(foam_texture, (foam_texture_uv -  foam_phase1 * float2(flow.r , flow.g ) + float2(foam_phase1Offset*0.237f,foam_phase1Offset*0.556) ) );

	float3 foam = lerp(foam1.rgb, foam2.rgb, foam_flowLerp) ;

	
	foam_color.rgb  = foam.rgb ; // * foam_colormult;
	
	foam_color.rgb *= foam_tint;

	foam_color.rgb *= foam_intensity * waterFade;
	foam_color.rgb = lerp(foam_color.rgb, (foam_color.rgb * foam_shadow_intensity), water_shadow);
	foam_color.a = foam_mask * waterFade * (foam_color.r * foam_intensity);

	bubbles = saturate(bubbles * bubbles_intensity);
	bubbles *= bubble_mask * foam_color.a * bubbles_intensity;

	shader_data.common.albedo.rgb = lerp(shader_data.common.albedo.rgb, foam_color, foam_color.a) + bubbles;
	shader_data.common.albedo.rgb = lerp(shader_data.common.albedo.rgb, (shader_data.common.albedo.rgb * water_shadow_intensity), water_shadow);
	shader_data.common.shaderValues.x = foam_color.a;
	//shader_data.common.shaderValues.y = waterFade * shader_data.common.vertexColor.a;
	shader_data.common.shaderValues.y = waterFade * border_alpha;	
	//shader_data.common.albedo.rgb = bubbles;

}

 
 
float4 pixel_lighting(
	        in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data) 
{
	float2 uv = pixel_shader_input.texcoord.xy;
	float alpha = shader_data.common.shaderValues.y;
	float foam = shader_data.common.shaderValues.x;
    // input from s_shader_data
    float4 albedo         = shader_data.common.albedo;
    float3 normal         = shader_data.common.normal;
	
  
    //float3 specular = 0.0f;
	//float rough= water_roughness;
	float spec_color = water_specular_color;
	
//////	


	float rough = water_roughness;
    
	//calculate diffuse
	float3 diffuse = 0.0f;
	calc_diffuse_lambert(diffuse, shader_data.common, normal); 
	
	// sample reflection
	float3 view = shader_data.common.view_dir_distance.xyz;
		 
	float3 rVec = reflect(view, normal);
	float mip_index = (1-rough) * 7.0f;
	float4 reflectionMap = sampleCUBELOD(reflection_map, rVec, mip_index, false);
	float3 fresnel = FresnelSchlick(water_specular_color, -view, normal);
	float3 reflection = reflectionMap.rgb * reflection_intensity * reflectionMap.a * fresnel;
    reflection = lerp(reflection, 0, saturate(foam * foam_spec_blend));
	//.. Finalize Output Color
    float4 out_color;
	out_color.a   = alpha;
	//out_color.a   = 1.0f;
	
	float3 color_map =  albedo;//the albedo color will come through the specular if we are metalic
	

	out_color.rgb =  ( color_map * diffuse.rgb ) + ( diffuse.rgb * reflection );
	
	return out_color;
}


#include "techniques.fxh"