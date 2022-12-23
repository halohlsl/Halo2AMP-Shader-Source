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
#include "ca_depth_access.fxh"

// Frame Buffer

//#include "ca_depth_access.fxh"

//.. Artistic Parameters

// Texture Samplers
DECLARE_RGB_COLOR_WITH_DEFAULT(diffuse_color,		"Diffuse Color", "",  float3(1,1,1)) ;
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(diffuse_map_mix, "Diffuse Map Mix", "Diffuse Map Mix", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(diffuse_fade_range,  "Diffuse Fade Range", "", 0, 5, float(0.4));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(water_fade_range,  "Water Fade Range", "", 0, 5, float(0.4));
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

DECLARE_FLOAT_WITH_DEFAULT(foam_spec_blend, "Foam Spec Blend", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(foam_edge_depth_start,		"Foam Edge Depth Start ", "", 0, 1, float(0.1));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(foam_edge_depth_end,			"Foam Edge Depth End", "", 0, 1, float(0.05));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(foam_edge_depth_intensity,	"Foam Edge Depth Intensity", "", 0, 1, float(1.00));
#include "used_float.fxh"



#if (DX_VERSION == 11) && !defined(cgfx)
	SamplerState MeshTextureSampler
	{
		Filter = MIN_MAG_MIP_LINEAR;
		AddressU = Wrap;
		AddressV = Wrap;
	};
#endif 

//Super Hacky spec changes to get rid of extra lights
	void calc_one_specular_blinnphong_initializer(
	inout float3 specular,
	const in s_common_shader_data common,
	const in float3 normal,
	const in float3 specular_color,
	const in float specular_power)
{
	specular = 0.0f;

#if (defined(xenon) || (DX_VERSION == 11)) && !defined(DISABLE_VMF)

	if (common.lighting_mode != LM_PER_PIXEL_FLOATING_SHADOW_SIMPLE && common.lighting_mode != LM_PER_PIXEL_SIMPLE)
	{
		float4 direction_specular_scalar = common.lighting_data.light_direction_specular_scalar[0];
		float3 intensity = common.lighting_data.light_intensity_diffuse_scalar[0].rgb;
		float3 view = normalize(common.view_dir_distance.xyz);
		float3 H[3] = {
			normalize(VMFGetVector(common.lighting_data.vmf_data, 0) - view),
			normalize(VMFGetVector(common.lighting_data.vmf_data, 1) - view),
			normalize(direction_specular_scalar.xyz - view) };

		// Get the cosines of the half-angles
		// The normal is normalized, so the results are the cosines of the half-angles times the magnitude of the half-angles
		float3 NdotH = float3(
			(dot(H[0], normal)),
			(dot(H[1], normal)),
			(dot(H[2], normal)));

		float NdotV = saturate(dot(-view, normal));
			
		float exponent = pow(2048, specular_power);
		float half_exponent = pow(2048, specular_power/2);
		float3 power = float3(exponent, half_exponent, exponent);
		
		float3 L[3] = {normalize(VMFGetVector(common.lighting_data.vmf_data, 0)) ,
					   normalize(VMFGetVector(common.lighting_data.vmf_data, 1)),
					   normalize(direction_specular_scalar.xyz) };
						 
						 
		float3 NdotL = float3(
		saturate(dot(L[0], normal)),
		saturate(dot(L[1], normal)),
		saturate(dot(L[2], normal)));

		// visibility term 
		//float3 alpha = float3(1,1,1) / (sqrt(PI_OVER_FOUR * specular_power + PI_OVER_TWO));
		//float3 visibility_term = (NdotL * ( float3(1,1,1) - alpha) + alpha) * (NdotV * (float3(1,1,1) - alpha) + alpha);

		float3 alpha = specular_power/2 + 0.0001;
		float3 visibility_term = (NdotL/(NdotL * ( 1 - alpha) + alpha)) * (NdotV/(NdotV * (1 - alpha) + alpha));
		
		float3 spec = ((float3(2,2,2) + power )/ float3(8,8,8))  * visibility_term;

		// The result of the exponential cannot be negative, so call the 'no clamp' evaluation to save time
		float3 vmfSpecular =0;
		/*float3 vmfSpecular =
			VMFSpecularCustomEvaluateNoClamp(common.lighting_data.vmf_data, spec.x, 0) * FresnelSchlickWithRoughness(specular_color, L[0].xyz, H[0], specular_power) * saturate(pow(NdotH[0], exponent)) ;
			+ 
			VMFSpecularCustomEvaluateNoClamp(common.lighting_data.vmf_data, spec.y, 1) * FresnelSchlickWithRoughness(specular_color, L[1].xyz, H[1], specular_power) * saturate(pow(NdotH[1], half_exponent));
			*/
		if (common.lighting_data.light_component_count > 0)
		{
			float3 dyn_spec = spec.z * FresnelSchlickWithRoughness(specular_color, L[2].xyz, H[2], specular_power) * saturate(pow(NdotH[2], exponent)) ;
			vmfSpecular += intensity * direction_specular_scalar.w * dyn_spec;
			
			
		}

		specular += vmfSpecular ;
		
	}

#endif
}

void calc_one_specular_blinnphong_inner_loop(
	inout float3 specular,
	const in s_common_shader_data common,
	const in float3 normal,
	const in float3 specular_color,
	const in float specular_power,
	int index)
{
#if (defined(xenon) || (DX_VERSION == 11)) && !defined(DISABLE_VMF)
	if (index > 1)
#else
	if (index < common.lighting_data.light_component_count)
#endif
	{
	
		
		float4 direction_specular_scalar= common.lighting_data.light_direction_specular_scalar[index];
		float3 intensity= common.lighting_data.light_intensity_diffuse_scalar[index].rgb;

		float3 H = normalize(direction_specular_scalar.xyz - common.view_dir_distance.xyz);
		float NdotH = saturate(dot(H, normal));
		float NdotV = saturate(dot(-common.view_dir_distance.xyz, normal));


		float exponent = pow(2048, specular_power);
		float NdotL = saturate(dot(direction_specular_scalar.xyz ,normal));

		float alpha = specular_power/2 + 0.0001;
		float visibility_term = (NdotL/(NdotL * ( 1 - alpha) + alpha)) * (NdotV/(NdotV * (1 - alpha) + alpha));
		
		specular+= ((float3(2,2,2) + exponent) / float3(8,8,8)) * visibility_term * (pow(NdotH, exponent)) * FresnelSchlickWithRoughness(specular_color, direction_specular_scalar.xyz, H, specular_power) * intensity * direction_specular_scalar.w;// * blinnPower * intensity * direction_specular_scalar.w;
	}
}

MAKE_ACCUMULATING_LOOP_3(float3, calc_one_specular_blinnphong, float3, float3, float, MAX_LIGHTING_COMPONENTS);
//end super hack spec changes....

struct s_shader_data {
	s_common_shader_data common;
};

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 uv = pixel_shader_input.texcoord.xy;

	shader_data.common.shaderValues.x = 1.0f; 			// Default specular mask

	float4 flow = sample2D(flow_map, uv);
	float4 combo 	= sample2D(combo_map, uv);
  
	float foam_mask = combo.a;
	float flow_speed = combo.g;

	flow.b = 1;
	flow = flow * 2 - 1;

	flow.rgb *= max_distort;
	flow.rgb *= -1;

	float time = ps_time.x ;
	
	float2 noise_map_uv 	   = transform_texcoord(uv, noise_map_transform);
	float noise = sample2D(noise_map, noise_map_uv ).r;

	float phase = (noise * noise_strength + time ) * water_speed ;
	float phase0Offset = floor(phase);
	float phase0 = (phase - phase0Offset )  ; 
	float phase1Offset = floor(phase  + .5);
	float phase1 = (phase   + .5 - phase1Offset);

	float2 wave_normal_uv 	   = transform_texcoord(uv, wave_normal_map_transform);

	float3 water_detail_map = sample_2d_normal_approx(wave_normal_map, (wave_normal_uv - float2(phase0,phase0) * float2(flow.r , flow.g  ) * flow_speed + float2(phase0Offset*0.137f,phase0Offset*0.856) ) );
	float3 water_detail_map2 = sample_2d_normal_approx(wave_normal_map, (wave_normal_uv - float2(phase1,phase1) * float2(flow.r , flow.g  ) * flow_speed + float2(phase1Offset*0.237f,phase1Offset*0.556) ) );//* float2(flow.r , -flow.g   ) *water_speed;

	float flowLerp =  2 * abs(phase0 - 0.5);

	water_detail_map = lerp(water_detail_map, water_detail_map2, flowLerp) ;

	water_detail_map.xy *= water_detail_intensity * length(float3(flow.r ,flow.g,0));

	//TODO: we can do a better faked reftraction lookup than this. We should be using the normal and view angle to figure it out...
	float waterFade = 1.0;
	float flow_depth = 0;
	float depthRefractAmount = 1.0f;
	float deltaDepthUnrefracted = 1.0f;
	float2 vPos = 0;
    #if (DX_VERSION == 11) && !defined(cgfx)
	{
		vPos = shader_data.common.platform_input.fragment_position.xy * (1/ps_textureSize.xy) ;
		
		//sample the depth buffer to find out how much fog to add to the water.
		float sceneDepth = 0;
		float2 depthTexPosFlat = shader_data.common.platform_input.fragment_position.xy * psDepthConstants.z;
		sampleDepth( depthTexPosFlat , sceneDepth );
		float deltaDepth = sceneDepth - pixel_shader_input.view_vector.w;
		deltaDepthUnrefracted = deltaDepth;
		depthRefractAmount = saturate(deltaDepth / diffuse_fade_range);

		waterFade = saturate(deltaDepth / water_fade_range);
		flow_depth = saturate(deltaDepth / diffuse_fade_range);

		float refactSceneDepth = 0;
		float2 depthTexPos = (shader_data.common.platform_input.fragment_position.xy + ps_textureSize.xy * water_detail_map.rg * diffuse_texcoord_shift) * psDepthConstants.z;
		sampleDepth( depthTexPos , sceneDepth );

		deltaDepth = pixel_shader_input.view_vector.w - sceneDepth;
		flow_depth = saturate(deltaDepth / diffuse_fade_range);
		
		float2 coord = vPos + water_detail_map.rg * diffuse_texcoord_shift;
		flow_depth = all(0.f < coord) && all(coord < 1.f) ? flow_depth : 1.f;
	}
    #else
        flow_depth = 1;
		float deltaDepth = 1.0f;

    #endif 
    
    waterFade *= shader_data.common.vertexColor.a;
    
	//water_detail_map.xy *= waterFade * flow_depth;
	
	float2 macro_normal_uv = uv;
	
	#ifdef MACRO_TRANSFORM
		macro_normal_uv = transform_texcoord(uv , macro_normal_map_transform);
	#endif 
	
	float3 worldNormal = sample_2d_normal_approx(macro_normal_map, macro_normal_uv).rgb;
	//worldNormal.xy *=2 ;
	worldNormal.xy *=  macro_normal_intensity;
	worldNormal +=  water_detail_map - float3(0,0,1) ;
	
	float3 normal = mul(worldNormal, shader_data.common.tangent_frame);
	shader_data.common.normal = normalize(normal);			// Do we need to renormalize?

	float3 color_refraction = float3(0,0,0);
	float3 color_back = diffuse_color;	

	#if (DX_VERSION == 11) && !defined(cgfx)
		color_back = ps_view_albedo.Sample(MeshTextureSampler, vPos) ;

		float2 texcoord_refraction = vPos + water_detail_map.rg * diffuse_texcoord_shift;
		int3 screen_texcoord = int3(vPos, 0);
		color_refraction = ps_view_albedo.Sample(MeshTextureSampler, texcoord_refraction) ;		
		//color_refraction = texcoord_refraction;
	#endif

	shader_data.common.albedo.rgb = lerp(color_refraction, color_back, flow_depth * diffuse_map_mix);

///////////////////////////////////////////////////////////////////////////
	/// Foam
	///////////////////////////////////////////////////////////////////////////


	float4 foam_color = 0.0f;

	// compute foam
	float foam_factor = foam_intensity;
	foam_factor *= min(max(20 /shader_data.common.view_dir_distance.w, 0.0f), 1.0f);

	float2 foam_texture_uv = transform_texcoord(uv , foam_texture_transform);
	float foam_phase = (  noise * noise_strength +time) * foam_speed   ;
	float foam_phase0Offset = floor(foam_phase);
	float foam_phase0 = (foam_phase - foam_phase0Offset )  ;
	float foam_phase1Offset = floor(foam_phase  + .5);
	float foam_phase1 = (foam_phase   + .5 - foam_phase1Offset)   ;

	float foam_flowLerp =  2 * abs(foam_phase0 - 0.5);		
	
	float4 foam = sample2D(foam_texture, (foam_texture_uv -  foam_phase0 * float2(flow.r , flow.g ) * flow_speed + float2(foam_phase0Offset*0.137f,foam_phase0Offset*0.856) ));
	float4 foam2 = sample2D(foam_texture, (foam_texture_uv -  foam_phase1 * float2(flow.r , flow.g ) * flow_speed + float2(foam_phase1Offset*0.237f,foam_phase1Offset*0.556) ) );

	foam = lerp(foam, foam2, foam_flowLerp) ;
	foam_color.rgb  = foam.rgb ; // * foam_colormult;
	foam_color.a = foam.a;
	foam_color.rgb *= foam_intensity;
	foam_color.a *= foam_mask;

	//calc foam depth edge
	float foam_depth_edge = 1.0 - saturate((deltaDepthUnrefracted - foam_edge_depth_end) / (foam_edge_depth_start - foam_edge_depth_end));
	foam_color.a = saturate( foam_color.a + (foam_depth_edge*foam_edge_depth_intensity) );

	// foam - A over B
	shader_data.common.albedo.rgb = lerp(shader_data.common.albedo.rgb, foam_color, foam_color.a);
	shader_data.common.shaderValues.x = foam_color.a;
	shader_data.common.shaderValues.y = waterFade;
	
	//shader_data.common.albedo.rgb = float3(flow.rgb);
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
	float rough= water_roughness;
	float spec_color = water_specular_color;
	calc_one_specular_blinnphong(specular, shader_data.common, normal, spec_color, rough);
    
    specular = lerp(specular, 0, saturate(foam * foam_spec_blend));
    
    
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

	float3 color_map =  albedo;//the albedo color will come through the specular if we are metalic
	
    out_color.rgb =  ( color_map * diffuse.rgb ) + ( diffuse.rgb * reflection ) + (specular*alpha);
	
	return out_color;
}


#include "techniques.fxh"
