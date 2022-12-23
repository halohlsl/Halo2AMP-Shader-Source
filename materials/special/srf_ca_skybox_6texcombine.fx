//
// File:	 srf_ca_skybox_6texcombine.fxh
// Author:	 mahlin
// Date:	 02/07/14
//
// Surface Shader - Constant, no diffuse illumination model- 
//
// 
//
//

// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"


// Texture Samplers
DECLARE_SAMPLER( texture_01_map, "Texture 01", "Texture 01", "shaders/default_bitmaps/bitmaps/default_diff.tif")
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(texture_01_intensity, "Texture 01 Intensity ", "", 0, 100, float(1.0));
#include "used_float.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(texture_01_color,		"Texture 01 Color       ", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_BOOL_WITH_DEFAULT(tex01_uv2, "Tex01 use UV 2", "", false);
#include "next_bool_parameter.fxh"


DECLARE_SAMPLER( texture_02_map, "Texture 02", "Texture 02", "shaders/default_bitmaps/bitmaps/default_diff.tif")
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(texture_02_intensity, "Texture 02 Intensity ", "", 0, 100, float(1.0));
#include "used_float.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(texture_02_color,		"Texture 02 Color       ", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_BOOL_WITH_DEFAULT(tex02_uv2, "Tex02 use UV 2", "", false);
#include "next_bool_parameter.fxh"

DECLARE_SAMPLER( texture_03_map, "Texture 03", "Texture 03", "shaders/default_bitmaps/bitmaps/default_diff.tif")
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(texture_03_intensity, "Texture 03 Intensity ", "", 0, 100, float(1.0));
#include "used_float.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(texture_03_color,		"Texture 03 Color       ", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_BOOL_WITH_DEFAULT(tex03_uv2, "Tex03 use UV 2", "", false);
#include "next_bool_parameter.fxh"

DECLARE_SAMPLER( texture_04_map, "Texture 04", "Texture 04", "shaders/default_bitmaps/bitmaps/default_diff.tif")
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(texture_04_intensity, "Texture 04 Intensity ", "", 0, 100, float(1.0));
#include "used_float.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(texture_04_color,		"Texture 04 Color       ", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_BOOL_WITH_DEFAULT(tex04_uv2, "Tex04 use UV 2", "", false);
#include "next_bool_parameter.fxh"

DECLARE_SAMPLER( texture_05_map, "Texture 05", "Texture 05", "shaders/default_bitmaps/bitmaps/default_diff.tif")
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(texture_05_intensity, "Texture 05 Intensity ", "", 0, 100, float(1.0));
#include "used_float.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(texture_05_color,		"Texture 05 Color       ", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_BOOL_WITH_DEFAULT(tex05_uv2, "Tex05 use UV 2", "", false);
#include "next_bool_parameter.fxh"

DECLARE_SAMPLER( texture_06_map, "Texture 06", "Texture 06", "shaders/default_bitmaps/bitmaps/default_diff.tif")
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(texture_06_intensity, "Texture 06 Intensity ", "", 0, 100, float(1.0));
#include "used_float.fxh"
DECLARE_RGB_COLOR_WITH_DEFAULT(texture_06_color,		"Texture 06 Color       ", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_BOOL_WITH_DEFAULT(tex06_uv2, "Tex06 use UV 2", "", false);
#include "next_bool_parameter.fxh"

DECLARE_SAMPLER(uvOffsetMap, "UV Offset Map", "UV Offset map", "shaders/default_bitmaps/bitmaps/alpha_white.tif")
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(uvOffsetStrength, "UV Offset Strength", "", 0, 1, float(0.1));
#include "used_float.fxh"

DECLARE_BOOL_WITH_DEFAULT(tex01_02_useUVwarp, "Tex01_02 use UV Warp", "", false);
#include "next_bool_parameter.fxh"
DECLARE_BOOL_WITH_DEFAULT(tex03_04_useUVwarp, "Tex03_04 use UV Warp", "", false);
#include "next_bool_parameter.fxh"
DECLARE_BOOL_WITH_DEFAULT(tex05_06_useUVwarp, "Tex05_06 use UV Warp", "", false);
#include "next_bool_parameter.fxh"

///////

DECLARE_FLOAT_WITH_DEFAULT(combined_intensity, "Combined Intensity", "", 0, 100, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(edge_sharpness, "Edge Sharpness", "", 1, 10, float(1.0));
#include "used_float.fxh"

DECLARE_BOOL_WITH_DEFAULT(one_plus_two, "Tex01   +  Tex02", "", false);
#include "next_bool_parameter.fxh"

DECLARE_BOOL_WITH_DEFAULT(three_plus_four, "Tex03   +  Tex04", "", false);
#include "next_bool_parameter.fxh"

DECLARE_BOOL_WITH_DEFAULT(five_plus_six, "Tex05   +  Tex06", "", false);
#include "next_bool_parameter.fxh"

DECLARE_BOOL_WITH_DEFAULT(onetwo_plus_threefour, "Tex01_02  +  Tex03_04", "", false);
#include "next_bool_parameter.fxh"

DECLARE_BOOL_WITH_DEFAULT(onetwothreefour_plus_fivesix, "Tex01_02_03_04  +  Tex05_06", "", false);
#include "next_bool_parameter.fxh"


//...

struct s_shader_data
{
	s_common_shader_data common;
	float  alpha;
};


void pixel_pre_lighting(
		in s_pixel_shader_input pixel_shader_input,
		inout s_shader_data shader_data)

{
#if defined(xenon) || (DX_VERSION == 11)
	float2 warped_uvs = transform_texcoord(pixel_shader_input.texcoord.xy, uvOffsetMap_transform);
	float2 offsetValue = sample2D(uvOffsetMap, warped_uvs).rg;
	
	// Compute the uv offset
	float2 uvOffset = uvOffsetStrength * offsetValue;
	
	#else // PC for speed
	float2 uvOffset = 0.0f;
	
#endif			
	
	float2 uv = pixel_shader_input.texcoord.xy;
	float2 uv2 = pixel_shader_input.texcoord.zw;
	float2 tex01_uv = 0.0f;
	float2 tex02_uv = 0.0f;
	float2 tex03_uv = 0.0f;
	float2 tex04_uv = 0.0f;			
	float2 tex05_uv = 0.0f;
	float2 tex06_uv = 0.0f;

	float2 tex01_02_uvoffset = 0.0f;
	float2 tex03_04_uvoffset = 0.0f;	
	float2 tex05_06_uvoffset = 0.0f;


	
	//Sample texture textures.
	
		STATIC_BRANCH
		if (tex01_uv2)
		{tex01_uv = uv2;}
		else {tex01_uv = uv;}
		
		STATIC_BRANCH
		if (tex01_02_useUVwarp)
		{tex01_02_uvoffset = uvOffset;}
		else {tex01_02_uvoffset = 0.0f;}
	
		float2 texture_01_uv = transform_texcoord(tex01_uv, texture_01_map_transform) + tex01_02_uvoffset;
		float3 texture_01 = sample2DGamma(texture_01_map, texture_01_uv) * texture_01_intensity * texture_01_color;
		
		STATIC_BRANCH
		if (tex02_uv2)
		{tex02_uv = uv2;}
		else {tex02_uv = uv;}		
		
		float2 texture_02_uv = transform_texcoord(tex02_uv, texture_02_map_transform) + tex01_02_uvoffset;
		float3 texture_02 = sample2DGamma(texture_02_map, texture_02_uv) * texture_02_intensity * texture_02_color;
		
		STATIC_BRANCH
		if (tex03_uv2)
		{tex03_uv = uv2;}
		else {tex03_uv = uv;}
		
		STATIC_BRANCH
		if (tex03_04_useUVwarp)
		{tex03_04_uvoffset = uvOffset;}
		else {tex03_04_uvoffset = 0.0f;}		
		
		float2 texture_03_uv = transform_texcoord(tex03_uv, texture_03_map_transform) + tex03_04_uvoffset;
		float3 texture_03 = sample2DGamma(texture_03_map, texture_03_uv) * texture_03_intensity * texture_03_color;
		
		STATIC_BRANCH
		if (tex04_uv2)
		{tex04_uv = uv2;}
		else {tex04_uv = uv;}

		float2 texture_04_uv = transform_texcoord(tex04_uv, texture_04_map_transform) + tex03_04_uvoffset;
		float3 texture_04 = sample2DGamma(texture_04_map, texture_04_uv) * texture_04_intensity * texture_04_color;

		STATIC_BRANCH
		if (tex05_uv2)
		{tex05_uv = uv2;}
		else {tex05_uv = uv;}
		
		STATIC_BRANCH
		if (tex05_06_useUVwarp)
		{tex05_06_uvoffset = uvOffset;}
		else {tex05_06_uvoffset = 0.0f;}
		
		float2 texture_05_uv = transform_texcoord(tex05_uv, texture_05_map_transform) + tex05_06_uvoffset;
		float3 texture_05 = sample2DGamma(texture_05_map, texture_05_uv) * texture_05_intensity * texture_05_color;

		STATIC_BRANCH
		if (tex06_uv2)
		{tex06_uv = uv2;}
		else {tex06_uv = uv;}
		
		float2 texture_06_uv = transform_texcoord(tex06_uv, texture_06_map_transform) + tex05_06_uvoffset;
		float3 texture_06 = sample2DGamma(texture_06_map, texture_06_uv) * texture_06_intensity * texture_06_color;

		
		float3 OnePlusTwo_result = float3(1.0f, 1.0f, 1.0f);
		float3 ThreePlusFour_result = float3(1.0f, 1.0f, 1.0f);
		float3 FivePlusSix_result = float3(1.0f, 1.0f, 1.0f);
		float3 OneTwoThreeFour_combined = float3(1.0f, 1.0f, 1.0f);
		float3 OneTwoThreeFourFiveSix_combined = float3(1.0f, 1.0f, 1.0f);

		///
		STATIC_BRANCH
		if (one_plus_two)
		{OnePlusTwo_result = texture_01 + texture_02;}
		else
		{OnePlusTwo_result = texture_01 * texture_02;}
		
		///
		STATIC_BRANCH
		if (three_plus_four)
		{ThreePlusFour_result = texture_03 + texture_04;}
		else
		{ThreePlusFour_result = texture_03 * texture_04;}
		
		///
		STATIC_BRANCH
		if (five_plus_six)
		{FivePlusSix_result = texture_05 + texture_06;}
		else
		{FivePlusSix_result = texture_05 * texture_06;}
		
		STATIC_BRANCH
		if (onetwo_plus_threefour)
		{OneTwoThreeFour_combined = OnePlusTwo_result + ThreePlusFour_result;}
		else
		{OneTwoThreeFour_combined = OnePlusTwo_result * ThreePlusFour_result;}
		
		///
		STATIC_BRANCH
		if (onetwothreefour_plus_fivesix)
		{OneTwoThreeFourFiveSix_combined = OneTwoThreeFour_combined + FivePlusSix_result;}
		else
		{OneTwoThreeFourFiveSix_combined = OneTwoThreeFour_combined * FivePlusSix_result;}

		
		shader_data.common.albedo.rgb = OneTwoThreeFourFiveSix_combined;



	// Respect vertex alpha
		shader_data.common.albedo *= shader_data.common.vertexColor.a;

}


float4 pixel_lighting(
        in s_pixel_shader_input pixel_shader_input,
	    inout s_shader_data shader_data)
		
{
	float4 albedo = shader_data.common.albedo;
	float4 layer_combine = pow((albedo * combined_intensity), edge_sharpness);


	//.. Finalize Output Color
	float4 out_color = float4(0.0f, 0.0f, 0.0f, shader_data.alpha);
	out_color.rgb = shader_data.common.albedo;
	
	return layer_combine;
};



#include "techniques.fxh"
