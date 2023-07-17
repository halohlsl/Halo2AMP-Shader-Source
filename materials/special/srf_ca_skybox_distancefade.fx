//
// File:	 srf_env_distanceFade.fx
// Author:	 mahlin
// Date:	 08/6/14
//
// Derived from srf_env_distanceFade.fx - this version works as an additive rather than alpha blend and multiplies three color maps and vert colors 
//
// Copyright (c) 343 Industries. All rights reserved.
//
//
//#define DISABLE_NORMAL
#define ENABLE_DEPTH_INTERPOLATER

#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"
#include "depth_fade.fxh"


DECLARE_SAMPLER( color_map_one, "Color Map 1", "Color Map 1", "shaders/default_bitmaps/bitmaps/default_diff.tif")
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(map_one_intensity,	"Color Map 1 Intensity", "", 0, 1, float(1.00));
#include "used_float.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(map_one_color,	"Map One Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_SAMPLER( color_map_two, "Color Map 2", "Color Map 2", "shaders/default_bitmaps/bitmaps/default_diff.tif")
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(map_two_intensity,	"Color Map 2 Intensity", "", 0, 1, float(1.00));
#include "used_float.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(map_two_color,	"Map Two Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_SAMPLER( color_map_three, "Color Map 3", "Color Map 3", "shaders/default_bitmaps/bitmaps/default_diff.tif")
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(map_three_intensity,	"Color Map 3 Intensity", "", 0, 1, float(1.00));
#include "used_float.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(map_three_color,	"Map Three Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fade_start,	"Fade Start", "", 0, 9999, float(200.00));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(fade_end,		"Fade End", "", 0, 9999, float(500.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fresnel_fade_exp,"Fresnel Fade Exponent", "", 0.0, 20.0, float(20.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(fresnel_intensity,"Fresnel Fade Intensity", "", 1.0, 20.0, float(1.0));
#include "used_float.fxh"



struct s_shader_data
{
	s_common_shader_data common;

    //float alpha;
};

void pixel_pre_lighting(
		in s_pixel_shader_input pixel_shader_input,
		inout s_shader_data shader_data)

{
	//shader_data.alpha = 1.0;
	float2 uv    		= pixel_shader_input.texcoord.xy;

		
	// Sample color maps.	
		float2 color_map_one_uv 	   = transform_texcoord(uv, color_map_one_transform);
	    float3 map_one = sample2DGamma(color_map_one, color_map_one_uv) * map_one_intensity * map_one_color;

		float2 color_map_two_uv 	   = transform_texcoord(uv, color_map_two_transform);
	    float3 map_two = sample2DGamma(color_map_two, color_map_two_uv) * map_two_intensity * map_two_color;		

		float2 color_map_three_uv 	   = transform_texcoord(uv, color_map_three_transform);
	    float3 map_three = sample2DGamma(color_map_three, color_map_three_uv) * map_three_intensity * map_three_color;	

		shader_data.common.albedo.rgb = map_one * map_two * map_three;
		
		shader_data.common.albedo.rgb *= shader_data.common.vertexColor.a;

		float3 view = -shader_data.common.view_dir_distance.xyz;
		float vdotn = saturate(dot(view, shader_data.common.geometricNormal));
		shader_data.common.albedo.rgb *= min(max((pow(vdotn, fresnel_fade_exp) * fresnel_intensity),0.0),1.0);

}


float4 pixel_lighting(
        in s_pixel_shader_input pixel_shader_input,
	    inout s_shader_data shader_data)
{
    float depthFade = 1.0f;

	float4 out_color = float4(0.0f, 0.0f, 0.0f, 1.0f);
	out_color.rgb = shader_data.common.albedo.rgb;
	
	#if defined(cgfx)
	depthFade = 1.0f;
    #else
	float2 vPos = shader_data.common.platform_input.fragment_position.xy;
	depthFade = ComputeDepthFade(vPos * psDepthConstants.z, pixel_shader_input.view_vector.w); // stored depth in the view_vector w
    #endif
	
	float fade = (shader_data.common.view_dir_distance.w-fade_start)/(fade_end-fade_start);
	out_color.rgb *= saturate(max(lerp(0.0, 1.0, fade)* depthFade, 0.0));
	return out_color;
}

#include "techniques.fxh"
