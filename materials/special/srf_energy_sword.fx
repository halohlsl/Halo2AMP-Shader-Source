//
// File:	 srf_water_io.fx
// Author:	 lkruel
// Date:	 03/13/14
//
// Surface Shader - Standard Blinn
//
// Copyright (c) 343 Industries. All rights reserved.
//
// Notes:
//


#define ENABLE_DEPTH_INTERPOLATER
#if defined(xenon)
#define ENABLE_VPOS
#endif


// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"

// Frame Buffer
DECLARE_PARAMETER(sampler2D, tex_ldr_buffer, s12);

// Depth Buffer
DECLARE_PARAMETER(sampler2D, tex_depth_buffer, s14);
DECLARE_PARAMETER(float4, psDepthConstants, c2);


//.. Artistic Parameters

// Texture Samplers
DECLARE_SAMPLER( color_map, "Color Map", "Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( detail_map, "Detail Map", "", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(detail_power, "Detail Power", "", 0, 1, float(2));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(detail_intensity, "Detail Intensity", "", 0, 1, float(2));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(frost_edge_intensity, "Frost Edge Intensity", "", 0, 1, float(0.7)) ;
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(frost_energy_intensity, "Frost Energy Intensity", "", 0, 1, float(0.7)) ;
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(frost_tint,		"Frost Tint", "",  float3(1,1,1)) ;
#include "used_float3.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(core_tint,		"Core Tint", "",  float3(1,1,1)) ;
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(core_power,   "Core Power",   "", 0, 1, float(3));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(core_intensity,   "Core Intensity",   "", 0, 1, float(3));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(fog_tint,	"Fog Tint", "",  float3(1,1,1)) ;
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_intensity, "Fog Intensity", "", 0, 1, float(2));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_speed, "Fog Speed", "", 0, 1, float(0.1));
#include "used_float.fxh"

DECLARE_SAMPLER( fog_map, "Fog Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER(flow_map, "Flow Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(max_distort, "Maxium Distortion", "", 0, 1, float(0.3));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(flow_speed, "Flow Speed", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(detail_speed, "Detail Speed", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(alpha_strength, "Alpha Strength", "", 0, 1, float(2));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(activate_slider, "Activate Slider", "", 0, 1, float(1.0)) ;
#include "used_float.fxh"


struct s_shader_data {
	s_common_shader_data common;
};

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;

	shader_data.common.shaderValues.x = 1.0f; 			// Default specular mask

	float2 color_map_uv  = transform_texcoord(uv, color_map_transform);
	
	float4 flow = sample2D(flow_map, uv);
	float flow_speed_map = flow.b;
	float frost = flow.a;
	
	flow = flow * 2 - 1;

	flow.rgb *= max_distort;
	flow.rgb *= flow_speed_map;

	
	float time = ps_time.x ;

	float phase = time *  flow_speed ;
	float phase0 = (phase - floor(phase ) )  ;
	float phase1 = (phase   + .5 - floor(phase  + .5)) ;
		
	float3 core = sample2DGamma(color_map, (color_map_uv - float2(phase0,phase0) * flow.rg  ) );
	float3 core2 = sample2DGamma(color_map,  (color_map_uv - float2(phase1,phase1) * flow.rg ) );

	float flowLerp =  2 * abs(phase0 - 0.5) ;
	
	core = lerp(core, core2, flowLerp) ;
	
	float2 detail_map_uv 	   = transform_texcoord(uv, detail_map_transform);
	float3 detail = sample2DGamma(detail_map, detail_map_uv + float2(time * -detail_speed, 0) );

	float2 fog_uv 	   = transform_texcoord(uv + float2(time * -fog_speed, 0), fog_map_transform);
	float4 fog = sample2DGamma(fog_map, fog_uv);
	
	shader_data.common.albedo.rgb = core.rgb * core_tint + (frost * frost_energy_intensity * (core.rrr ) + frost * frost_edge_intensity) * frost_tint;
	shader_data.common.albedo.rgb += pow(core.rgb , core_power) * core_intensity;
	shader_data.common.albedo.rgb += fog.r * fog_intensity * fog_tint;
	shader_data.common.albedo.rgb += pow(detail , detail_power) * detail_intensity;
	
}

 
 
float4 pixel_lighting(
	        in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data) 
{
	float2 uv = pixel_shader_input.texcoord.xy;
	
    float4 albedo         = shader_data.common.albedo;
    
	//.. Finalize Output Color
    float4 out_color;

	out_color.rgb = albedo;
	float3 rgb2lum = float3(0.30, 0.59, 0.11);
	out_color.a = saturate(dot(rgb2lum, albedo) * alpha_strength); 
    out_color.a = lerp(((1-uv.x) - (1-activate_slider * dot(rgb2lum, albedo))  ) , out_color.a, saturate(activate_slider * 2 -1));
    out_color.a = saturate(out_color.a);
    //out_color.a = 1;
	return out_color;
}


#include "techniques.fxh"