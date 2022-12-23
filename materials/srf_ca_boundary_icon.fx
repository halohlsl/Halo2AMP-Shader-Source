//
// File:	 srf_ca_boundary.fx
// Author:	 v-tomau
// Date:	 3/13/12
//
// Surface Shader - Boundary shader that supports team color for our game modes
//
// Copyright (c) 343 Industries. All rights reserved.
//

#define ENABLE_DEPTH_INTERPOLATER
#if defined(xenon)
#define ENABLE_VPOS
#endif

#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"
#include "ca_depth_access.fxh"


DECLARE_SAMPLER( icon_map,								"Icon Map", "", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"
DECLARE_SAMPLER( icon_detail_map,						"Icon Detail Map", "", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"
DECLARE_SAMPLER( icon_detail_add_map,					"Icon Detail Add Map", "", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(icon_tint,				"Icon Tint", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(icon_intensity,				"Icon Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(icon_detail_intensity,		"Icon Detail Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(icon_detail_add_intensity,	"Icon Detail Add Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_SAMPLER( overlay_map,							"Overlay Map", "", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"
DECLARE_SAMPLER( overlay_detail_map,					"Overlay Detail Map", "", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(overlay_tint,			"Overlay Tint", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(overlay_intensity,			"Overlay Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(overlay_team_color_influence, "Overlay Team Color Influence", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(overlay_icon_alpha_fade,		"Overlay Icon Alpha Fade", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_SAMPLER( edge_self_illum_palette_map,			"Edge Palette Map", "", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(edge_v_coordinate,			"Edge Palette V Coord", "", 0, 1, float(0.5));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(edge_depth_highlight_range,	"Edge Depth Range", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(edge_top_size,				"Edge Top Size", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(edge_color_size,				"Edge Color Size", "", 0, 1, float(0.1));
#include "used_float.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(edge_tint,				"Edge Tint", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(edge_pow,					"Edge Power", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(edge_intensity,				"Edge Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_SAMPLER( edge_noise_a_map,						"Edge Noise A Map", "", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"
DECLARE_SAMPLER( edge_noise_b_map,						"Edge Noise B Map", "", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(edge_noise_intensity,		"Edge Noise Intensity", "", 0, 5, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(edge_team_color_influence,	"Edge Team Color Influence", "", 0, 5, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(intensity_fresnel_intensity,	"Intensity Fresnel Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(intensity_fresnel_power,		"Intensity Fresnel Power", "", 0, 10, float(3.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(intensity_fresnel_inv,		"Intensity Fresnel Invert", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(distance_fade_near_distance,		"Fade Distance Near", "", 0, 50, float(10.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(distance_fade_near,		"Fade Distance Near Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(distance_fade_far_distance,		"Fade Distance Far", "", 0, 50, float(40.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(distance_fade_far,		"Fade Distance Far Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

//ps_perimiterInfo {% from bottom of center of shape, perimiter height, 0, 0}
#define ps_perimiterInfo	ps_material_generic_parameters[0]

struct s_shader_data
{
	s_common_shader_data common;
};

float3 calcEdgeBoundry( float2 uv, float2 scaledUV, s_shader_data shaderData, float3 view_vec_w, out float edgeKillIntensity )
{
	float noise_a=	sample2D(edge_noise_a_map, transform_texcoord(scaledUV, edge_noise_a_map_transform)).r;
	float noise_b=	sample2D(edge_noise_b_map, transform_texcoord(scaledUV, edge_noise_b_map_transform)).r;
	float noise = (edge_noise_intensity * abs(noise_a-noise_b) );

	float sceneDepth = 0;
#if defined(xenon) || (DX_VERSION == 11)
	float2 vPos = 0;
	vPos = shaderData.common.platform_input.fragment_position.xy;
	sampleDepth( vPos * psDepthConstants.z, sceneDepth );
#endif

	float deltaDepth = sceneDepth - view_vec_w;
	float depthEdgeAmount = 1.0 - saturate(deltaDepth / edge_depth_highlight_range);

	float bottomUVEdgeAmount = 1.0 - saturate( ( uv.y * ps_perimiterInfo.y ) / edge_top_size );

	float topUVEdgeAmount = 1.0 - saturate( ((1.0 - uv.y) * ps_perimiterInfo.y)  / edge_top_size );

	float edgeLookup = saturate( sqrt( (depthEdgeAmount * depthEdgeAmount) + (bottomUVEdgeAmount * bottomUVEdgeAmount)  + (topUVEdgeAmount * topUVEdgeAmount) ) );
	
	float2 lookup_uv = float2( saturate( edgeLookup + noise ), edge_v_coordinate );
		
	float3 edgeColor = saturate( pow( sample2D(edge_self_illum_palette_map,  transform_texcoord(lookup_uv, edge_self_illum_palette_map_transform) ) * edge_tint * edge_intensity, edge_pow ) );

	float3 teamColor = ps_material_object_parameters[0];
	edgeColor = lerp( edgeColor, edgeColor * teamColor, edge_team_color_influence );

	edgeKillIntensity = saturate((1.0- edgeLookup) / edge_color_size);

	return edgeColor;
}

float3 calcOverlayColor( float2 scaledUV, float iconAlpha )
{
	float4 overlay=			sample2D(overlay_map,   transform_texcoord(scaledUV, overlay_map_transform));
	float4 overlay_detail=	sample2D(overlay_detail_map, transform_texcoord(scaledUV, overlay_detail_map_transform));

	float3 teamColor = ps_material_object_parameters[0];

	const float DETAIL_MULTIPLIER = 4.59479f;		// 4.59479f == 2 ^ 2.2  (sRGB gamma)
	float3 overlay_color=	overlay.rgb * overlay_detail.rgb * DETAIL_MULTIPLIER * overlay_tint.rgb * overlay_intensity * lerp( float3(1,1,1), teamColor, overlay_team_color_influence ) * lerp( 1.0, iconAlpha, overlay_icon_alpha_fade);

	return overlay_color;
}

float3 calcIconColor( float2 scaledUV, out float iconAlpha )
{
	float4 icon=				sample2D(icon_map,   transform_texcoord(scaledUV, icon_map_transform));
	float4 icon_detail=			sample2D(icon_detail_map,   transform_texcoord(scaledUV, icon_detail_map_transform));
	float4 icon_detail_add=		sample2D(icon_detail_add_map,   transform_texcoord(scaledUV, icon_detail_add_map_transform));
	iconAlpha = icon.a;

	float3 teamColor = ps_material_object_parameters[0];
	float3 teamColorSecondary = ps_material_object_parameters[1];

	float3 color = ((icon.r * teamColor) * icon_tint + icon.g * teamColorSecondary * (icon_tint * 0.7)) * (icon_intensity * icon.a);
	color = lerp( color, color * icon_detail, icon_detail_intensity );
	color = lerp( color, color + (icon.aaa * icon_detail_add), icon_detail_add_intensity );
	return color;
}

float compute_fresnel( s_shader_data shaderData )
{
	float intensityFresnel = 0.0f;
	// Compute fresnel to modulate reflection
	float  vdotn = saturate(dot(-shaderData.common.view_dir_distance.xyz, shaderData.common.normal));
	intensityFresnel = vdotn + intensity_fresnel_inv - 2 * intensity_fresnel_inv * vdotn;	// equivalent to lerp(vdotn, 1 - vdotn, fresnel_inv);
	intensityFresnel = 1.0 - saturate( pow(saturate(intensityFresnel), intensity_fresnel_power) * intensity_fresnel_intensity );

	return intensityFresnel;
}

float calc_distanceFade( float3 view_vec_w )
{
	float t = saturate( (view_vec_w - distance_fade_near_distance) / ( distance_fade_far_distance - distance_fade_near_distance) );
	return lerp( distance_fade_near, distance_fade_far, t );
}

void pixel_pre_lighting(
		in s_pixel_shader_input pixelShaderInput,
		inout s_shader_data shaderData)
{
}

float4 pixel_lighting(
        in s_pixel_shader_input pixelShaderInput,
	    inout s_shader_data shaderData
		)
{
	float2 uv = pixelShaderInput.texcoord.xy;
	float2 scaledUV = float2( uv.x, (1.0-uv.y) * ps_perimiterInfo.y);
	scaledUV.y = (ps_perimiterInfo.y - scaledUV.y) - (ps_perimiterInfo.x*ps_perimiterInfo.y);

	float3 color = 0;

	//This will be broken into five controllable parts; the edge boundary, the ovelay fill, the team icon, the frensnel, the distance Fade

	float edgeKillIntensity = 1.0f;
	float3 edgeBoundryColor = calcEdgeBoundry(uv, scaledUV, shaderData, pixelShaderInput.view_vector.w, edgeKillIntensity);

	float iconAlpha =  1.0f;
	float3 iconColor = calcIconColor(scaledUV, iconAlpha);

	float3 overlayColor = calcOverlayColor(scaledUV, iconAlpha);

	float intensityFresnel = compute_fresnel( shaderData );

	float distanceFade = calc_distanceFade(pixelShaderInput.view_vector.w);

	color =  (overlayColor + iconColor + edgeBoundryColor ) * edgeKillIntensity * intensityFresnel * distanceFade;

	return float4( color, 1.0f );
}

#ifndef USE_TRUE_UV
#define vs_perimiterInfo	vs_material_generic_parameters[0]

void CustomVertexCode(inout float2 uv)
{
	float repeatScale = floor(vs_perimiterInfo.x) + 1; 
	uv.x = uv.x * repeatScale;
}

#define custom_deformer(vertex, vertexColor, localToWorld) CustomVertexCode(vertex.texcoord)
#endif

#include "techniques.fxh"
