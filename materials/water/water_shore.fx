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

#define DISABLE_LIGHTING_TANGENT_FRAME
// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"

// Frame Buffer

//#include "ca_depth_access.fxh"

//.. Artistic Parameters

// Texture Samplers
DECLARE_SAMPLER( color_map, "Color Map", "Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( churn_foam_map, "Churn Foam Map", "", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( crest_foam_normal_map, "Crest Foam Normal Map", "", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( crest_foam_map, "Crest Foam Map", "", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(crest_foam_x_offset, "Crest Foam X Offset", "", 0, 1, float(0.0));
#include "used_float.fxh"



DECLARE_FLOAT_WITH_DEFAULT(crest_foam_y_offset, "Crest Foam Y Offset", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(crest_power, "Crest Power", "", 0, 10, float(1.0)) ;
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(crest_power_2, "Crest Power 2", "", 0, 10, float(1.0)) ;
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(foam_size, "Foam Size", "", 0, 1, float(0.1));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(foam_location, "Foam Pos", "", 0, 1, float(0.5));
#include "used_float.fxh"


DECLARE_FLOAT_WITH_DEFAULT(diffuse_map_mix, "Diffuse Map Mix", "Diffuse Map Mix", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(diffuse_texcoord_shift,   "Diffuse Texcoord Shift",   "", 0, 1, float(0.03));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(albedo_tint,		"Color Tint", "",  float3(1,1,1)) ;
#include "used_float3.fxh"

DECLARE_SAMPLER( macro_normal_map, "Macro Normal Map", "", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(macro_normal_intensity, "Macro Normal Strength", "", 0, 1, float(1.0)) ;
#include "used_float.fxh"

DECLARE_SAMPLER( noise_map, "Noise Map", "Noise Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
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

// Sun Settings 
DECLARE_FLOAT_WITH_DEFAULT(sun_x, "Light 1         X", "", 0, 1, float(0.0)) ;
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(sun_y, "Light 1         Y", "", 0, 1, float(1.0)) ;
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(sun_z, "Light 1         Z", "", 0, 1, float(0.0)) ;
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(sun_intensity, "Light 1      Int", "", 0, 100, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(sun_color, "Light 1  Color", "", float3(1,1,1)) ;
#include "used_float3.fxh"

// Foam settings
DECLARE_SAMPLER(foam_texture,        "Foam Texture", "Foam Texture", "");
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(foam_speed,           "Foam Speed", "", 0, 1, float(1.0)) ;
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(foam_intensity,        "Foam Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

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

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;

	shader_data.common.shaderValues.x = 1.0f; 			// Default specular mask

	
	
	float2 crest_foam_map_uv  = transform_texcoord(uv, crest_foam_map_transform);

	float4 crest_foam = sample2DGamma(crest_foam_map, (crest_foam_map_uv ) ) ;
	float4 crest_foam_2 = sample2DGamma(crest_foam_map, float2(-1, 1) * (crest_foam_map_uv - float2(crest_foam_x_offset, crest_foam_y_offset))  ) ;//* float2(flow.r , -flow.g   ) *water_speed;

	
	
	
	float3 water_detail_map = sample_2d_normal_approx(crest_foam_normal_map,crest_foam_map_uv);
	float3 water_detail_map_2 = sample_2d_normal_approx(crest_foam_normal_map, float2(-1, 1) * (crest_foam_map_uv - float2(crest_foam_x_offset, crest_foam_y_offset)) );
	
	water_detail_map += water_detail_map_2 - float3(0,0,1);
	
	float3 normal = mul(water_detail_map, shader_data.common.tangent_frame);
	shader_data.common.normal = normalize(normal);			// Do we need to renormalize?
	
	crest_foam.rgb = max(crest_foam.rgb, crest_foam_2.rgb);
	crest_foam.a = pow(crest_foam.a, crest_power);
	crest_foam_2.a = pow(crest_foam_2.a, crest_power_2);
	
	crest_foam.a = max(crest_foam.a, crest_foam_2.a);

	shader_data.common.albedo.rgb = crest_foam.rgb;
	shader_data.common.albedo.a = crest_foam.a ;
	
	
	
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
	
  
    float3 specular = 0.0f;
	float rough = lerp(water_roughness, 0, foam);
	float spec_color = lerp(water_specular_color, 0.04, foam);
	calc_specular_blinnphong(specular, shader_data.common, normal, spec_color, rough);
    
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
   
	//.. Finalize Output Color
    float4 out_color;
	out_color.a   = albedo.a;

	float3 color_map =  albedo;//the albedo color will come through the specular if we are metalic
	
    out_color.rgb =  ( color_map * diffuse.rgb ) + ( diffuse.rgb * reflection ) + specular;

	return out_color;
}


#include "techniques.fxh"