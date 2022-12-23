//
// File:	 srf_ca_skybox_si_saturate.fxh
// Author:	 mahlin
// Date:	 03/06/15
//
// Surface Shader - Basic skybox constant with a self-illum channel derived from the base color map and the ability to tune its saturation and option for alpha clip
//


// no sh airporbe lighting needed for constant shader
#define DISABLE_SH

#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"
#include "operations/color.fxh"


// Texture Samplers
DECLARE_SAMPLER( color_texture, "Color Map", "Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif")
#include "next_texture.fxh"

DECLARE_BOOL_WITH_DEFAULT(has_alpha, "Texture has alpha channel?", "", false);
#include "next_bool_parameter.fxh"


// Diffuse
DECLARE_RGB_COLOR_WITH_DEFAULT(albedo_tint,	"Color Tint", "", float3(1,1,1));
#include "used_float3.fxh"
DECLARE_FLOAT_WITH_DEFAULT(albedo_intensity,	"Albedo Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

// Self Illum
DECLARE_FLOAT_WITH_DEFAULT(si_intensity,	"SelfIllum Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(si_power,	"SelfIllum Power", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(si_desaturate,	"SelfIllum Desaturation", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(clip_threshold,		"Clipping Threshold", "", 0, 1, float(0.3));
#include "used_float.fxh"


struct s_shader_data
{
	s_common_shader_data common;
};


void pixel_pre_lighting(
		in s_pixel_shader_input pixel_shader_input,
		inout s_shader_data shader_data)
		
{
	float2 uv    		 = pixel_shader_input.texcoord.xy;

    // Sample color map.
		float2 color_map_uv   = transform_texcoord(uv, color_texture_transform);
		float4 color_map = sample2DGamma(color_texture, color_map_uv);		

	    shader_data.common.albedo.rgb = color_map.rgb;
		
				STATIC_BRANCH
		if (has_alpha)
		{shader_data.common.albedo.a = color_map.a;}
		else {shader_data.common.albedo.a = 1.0f;}

		shader_data.common.albedo.rgb *= albedo_tint.rgb;
	
	
	// Tex kill pixel
		clip(shader_data.common.albedo.a - clip_threshold);

}

	// lighting
		float4 pixel_lighting(
        in s_pixel_shader_input pixel_shader_input,
	    inout s_shader_data shader_data)
{

    // input from s_shader_data
		float4 albedo         = shader_data.common.albedo;

     //.. Finalize Output Color
		float4 out_color = float4(0.0f, 0.0f, 0.0f, 1.0f);		

		float3 self_illum = pow(albedo.rgb, si_power) * si_intensity;
		
		float3 greyscale = color_luminance(self_illum);
				
		self_illum = lerp(self_illum, greyscale, si_desaturate);
		
		out_color.rgb = (albedo.rgb * albedo_tint * albedo_intensity) + self_illum;

		out_color.a   = albedo.a;

		// Output self-illum intensity as linear luminance of the added value
		shader_data.common.selfIllumIntensity = GetLinearColorIntensity(self_illum);


	return out_color;

}


#include "techniques.fxh"
