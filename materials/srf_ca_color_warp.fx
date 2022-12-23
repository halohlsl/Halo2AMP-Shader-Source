//
// File:	 srf_ca_color_warp.fx
// Author:	 v-jcleav
// Date:	 3/1/12
//
// Surface Shader - A simple color shader with self-illumination that warps according to a mask.
//
// Copyright (c) 343 Industries. All rights reserved.
//

#ifdef SOFT_FADE
#define ENABLE_DEPTH_INTERPOLATER
#if defined(xenon)
#define ENABLE_VPOS
#endif
#endif

#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"
#include "ca_depth_access.fxh"

// Texture Samplers
DECLARE_SAMPLER(diffuseMap, "Diffuse Map", "Diffuse Map", "shaders/default_bitmaps/bitmaps/default_diff.tif")
#include "next_texture.fxh"
DECLARE_SAMPLER(alphaMap, "Alpha Map", "Alpha Map", "shaders/default_bitmaps/bitmaps/default_diff.tif")
#include "next_texture.fxh"
DECLARE_SAMPLER(selfIllumMap, "SelfIllum Map", "SelfIllum Map", "shaders/default_bitmaps/bitmaps/default_diff.tif")
#include "next_texture.fxh"
DECLARE_SAMPLER(uvOffsetMap, "UV Offset Map", "UV Offset map", "shaders/default_bitmaps/bitmaps/alpha_white.tif")
#include "next_texture.fxh"

// Shader Parameters
DECLARE_RGB_COLOR_WITH_DEFAULT(diffuseTint, "Diffuse Tint", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(diffuseIntensity, "Diffuse Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(siColor, "SelfIllum Color", "", float3(0,0,0));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(siIntensity, "SelfIllum Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(uvOffsetStrength, "UV Offset Strength", "", 0, 1, float(0.1));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(uvOffsetSpeed, "UV Offset Speed", "", 0, 10, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(uvOffsetFrequency, "UV Offset Frequency", "", 0, 10, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(fresnelIntensity, "Fresnel Intensity", "", 0, 1, float(0.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(fresnelPower, "Fresnel Power", "", 0, 10, float(2.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(fresnelInverse, "Fresnel Inverse", "", 0, 1, float(0.0));
#include "used_float.fxh"

#ifdef SOFT_FADE
DECLARE_FLOAT_WITH_DEFAULT(depth_fade_range,  "Depth Fade Range", "", 0, 5, float(0.4));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(camera_fade_range,  "Camera Fade Range", "", 0.0001, 5, float(0.0001));
#include "used_float.fxh"

#ifdef SOFT_FADE_LOOKUP
DECLARE_SAMPLER(softFadeLookup, "Soft Fade Lookup Map", "Soft Fade Lookup Map", "shaders/default_bitmaps/bitmaps/alpha_white.tif")
#include "next_texture.fxh"
#endif

#endif // SOFT_FADE

#if defined(ALPHA_CLIP)
#define MATERIAL_SHADER_ANNOTATIONS 	<bool is_alpha_clip = true;>
DECLARE_FLOAT_WITH_DEFAULT(clip_threshold,		"Clipping Threshold", "", 0, 1, float(0.001));
#include "used_float.fxh"
#endif // ALPHA_CLIP

struct s_shader_data
{
	s_common_shader_data common;
};

void pixel_pre_lighting(
	in s_pixel_shader_input pixelShaderInput,
	inout s_shader_data shaderData)
{
#if defined(xenon) || (DX_VERSION == 11)

	float2 uv = transform_texcoord(pixelShaderInput.texcoord.xy, uvOffsetMap_transform);
	float2 offsetValue = sample2D(uvOffsetMap, uv).rg;

	// Grab our alpha value from the alpha mask -- no UV distortion applied -- strict mask
	uv = transform_texcoord(pixelShaderInput.texcoord.xy, alphaMap_transform);
	float alphaMapMask = sample2DGamma(alphaMap, uv).r;

	#if defined(ALPHA_CLIP)
	clip(alphaMapMask - clip_threshold);
	#endif
	
	// Compute the uv offset
    float2 uvTimeOffset = uvOffsetFrequency + uvOffsetSpeed * float2(ps_time.x, ps_time.x);
    #ifndef USE_NO_COSINE
        uvTimeOffset = cos(uvTimeOffset);
    #endif 
	float2 uvOffset = uvOffsetStrength * offsetValue * uvTimeOffset;
	
	// Sample from our diffuse/selfIllum maps respecting UV distortion
	uv = transform_texcoord(pixelShaderInput.texcoord.xy, diffuseMap_transform) + uvOffset;
	float4 diffuse = sample2DGamma(diffuseMap, uv) * float4(diffuseTint, 1) * diffuseIntensity;
	uv = transform_texcoord(pixelShaderInput.texcoord.xy, selfIllumMap_transform) + uvOffset;
	float4 selfIllum = sample2DGamma(selfIllumMap, uv) * float4(siColor, 1) * siIntensity;
	
	// Compute fresnel to mask/smooth out the edges
	float fresnel = 0.0f;
	{
		float3 view = -shaderData.common.view_dir_distance.xyz;
		float3 n = normalize( shaderData.common.geometricNormal );
		fresnel = saturate(dot(view, n));
		fresnel = lerp( fresnel, 1.0 - fresnel, fresnelInverse );
		fresnel = lerp( 1.0, pow(fresnel, fresnelPower), fresnelIntensity );
	}

	///Depth factor
	float depthFadeAmount = 1.0;
	float3 dedthColorAmount = float3( 0, 0, 0 );
	#ifdef SOFT_FADE
	#if defined(xenon) || (DX_VERSION == 11)
	{
		float sceneDepth = 0;
		float2 vPos = shaderData.common.platform_input.fragment_position.xy;
		sampleDepth( vPos * psDepthConstants.z, sceneDepth );

		float deltaDepth = sceneDepth - pixelShaderInput.view_vector.w;
		depthFadeAmount = saturate(deltaDepth / depth_fade_range);

		#ifdef SOFT_FADE_LOOKUP
		float2 softFadeLookupUV = transform_texcoord(float2( depthFadeAmount, 0.5 ), softFadeLookup_transform);
		float4 lookup = sample2DGamma(softFadeLookup, softFadeLookupUV);
		dedthColorAmount.rgb = lookup.rgb * (diffuse.rgb + selfIllum.rgb);
		depthFadeAmount = lookup.a;
		#endif

		depthFadeAmount = depthFadeAmount * saturate( (1.0 - ( (camera_fade_range - pixelShaderInput.view_vector.w) / camera_fade_range ) ) );
	}
	#endif
	#endif
	/////
	
	shaderData.common.albedo = (diffuse + float4(selfIllum.rgb, 0)) * fresnel * alphaMapMask * depthFadeAmount + float4( dedthColorAmount.rgb, 0 );
	shaderData.common.selfIllumIntensity = GetLinearColorIntensity(selfIllum) * fresnel * alphaMapMask * depthFadeAmount;
	
#else // PC

	// Just output the masked diffuse on the PC for speed
	float2 uv = transform_texcoord(pixelShaderInput.texcoord.xy, diffuseMap_transform);
	float4 diffuse = sample2DGamma(diffuseMap, uv);
	uv = transform_texcoord(pixelShaderInput.texcoord.xy, alphaMap_transform);
	float alphaMapMask = sample2DGamma(alphaMap, uv).r;
	
	shaderData.common.albedo = diffuse * alphaMapMask;
	
#endif
	
#ifdef VERT_MASK
	// Respect vertex alpha
	shaderData.common.albedo *= shaderData.common.vertexColor.a;
	shaderData.common.selfIllumIntensity *= shaderData.common.vertexColor.a;
#endif
}

float4 pixel_lighting(
	in s_pixel_shader_input pixelShaderInput,
	inout s_shader_data shaderData)
{
	// input from shader_data 
	return shaderData.common.albedo;
}

#include "techniques.fxh"
