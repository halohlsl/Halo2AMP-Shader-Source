
// File:	 srf_ca_skybox_diffuse_only.fx
// Author:	 lkruel
// Date:	 12/09/13
//
// Surface Shader - Generic Skybox Shader with fake lighting
// Built in lighting and fog based on exposed vector parameters. 
//
// Notes:
//

#define DISABLE_LIGHTING_TANGENT_FRAME
#define DISABLE_LIGHTING_VERTEX_COLOR
#define DISABLE_SHARPEN_FALLOFF


// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"


//.. Artistic Parameters

// Texture Samplers

DECLARE_SAMPLER( normal_map, "Normal Map", "", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( color_map, "Albedo Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( combo_map, "Combo Map", "", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER_CUBE(reflection_map,  "Reflection Map", "", "shaders/default_bitmaps/bitmaps/default_cube.tif")
#include "next_texture.fxh"

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

//Fake lighting
DECLARE_BOOL_WITH_DEFAULT(divider_01, "===========================", "", false);
	

DECLARE_FLOAT_WITH_DEFAULT(light_1_x, "Light 1         X", "", -1, 1, float(0.6));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_y, "Light 1         Y", "", -1, 1, float(0.2));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_z, "Light 1         Z", "", -1, 1, float(0.2));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_intensity, "Light 1      Int", "", 0, 100, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(light_1_color, "Light 1  Color", "", float3(1,.937,.831));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_wrap, "Light 1  Wrap", "", 0, 1, float(0.0));
#include "used_float3.fxh"


DECLARE_FLOAT_WITH_DEFAULT(light_2_x, "Light 2         X", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_y, "Light 2         Y", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_z, "Light 2         Z", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_intensity, "Light 2      Int", "", 0, 100, float(0.5));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(light_2_color, "Light 2  Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_wrap, "Light 2  Wrap", "", 0, 1, float(0.0));
#include "used_float3.fxh"



DECLARE_BOOL_WITH_DEFAULT(divider_03, "===========================", "", false);

DECLARE_RGB_COLOR_WITH_DEFAULT(ambient_color, "Ambient Color", "", float3(0,0,0));
#include "used_float3.fxh"


DECLARE_BOOL_WITH_DEFAULT(divider_04, "===========================", "", false);

DECLARE_FLOAT_WITH_DEFAULT(fog_start,	"Fog Start", "", 0, 9999, float(1000.00));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_end,		"Fog End  ", "", 0, 9999, float(4000.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_bottom,		"Fog Bottom ", "", -1000000, 1000000, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_top,		"Fog Top ", "", -1000000, 1000000, float(2000.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_y_multiplier_start,		"Fog Y Multiplier Start", "", -1000000, 1000000, float(500.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_y_multiplier_end,		"Fog Y Multiplier End", "", -1000000, 1000000, float(2000.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(fog_color, "Fog Color", "", float3(.514,.722,.757));
#include "used_float3.fxh"

///

struct s_shader_data {
	s_common_shader_data common;
    //float  alpha;
};

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
			
{
	float2 uv = pixel_shader_input.texcoord.xy;

	shader_data.common.shaderValues.x = 1.0f; 			// Default specular mask
   	float2 normal_uv   = transform_texcoord(uv, normal_map_transform);
    float3 normal = sample_2d_normal_approx(normal_map, normal_uv);
		
	// Transform from tangent space to world space
	shader_data.common.normal = mul(normalize(normal), shader_data.common.tangent_frame);
		
	// Sample water color map and alpha
	float2 color_map_uv = transform_texcoord(uv, color_map_transform);
	float4 albedo = sample2DGamma(color_map, color_map_uv);
	
	shader_data.common.albedo.rgb = albedo.rgb * albedo_tint;
	
}		
		
		
float4 pixel_lighting(
	in s_pixel_shader_input pixel_shader_input,
	inout s_shader_data shader_data) 
{
 	float2 uv = pixel_shader_input.texcoord.xy;
		// input from s_shader_data
    float4 albedo         = shader_data.common.albedo ;
    float3 normal         = shader_data.common.normal;
	
	// Sample combo map, r = metalicness, g = cavity multiplier (fake AO), b = Self Illume map, a = roughness
	float2 combo_map_uv	= transform_texcoord(uv, combo_map_transform);
	float4 combo 	= sample2D(combo_map, combo_map_uv);
	
	float3 specular = 0.0f;

	float rough = roughness * combo.a;
	// using blinn specular model
	float metallic = metallicness * combo.r; 
	float3 specular_color = lerp(pow(float3(0.04, 0.04, 0.04), 2.2), albedo , metallic);
	
	float3 light_1 = normalize(float3(light_1_x, light_1_y, light_1_z));
	float3 light_2 = normalize(float3(light_2_x, light_2_y, light_2_z));
	
    float3 diffuse = 0.0f;

	///..Half Lambert 
	float wrap_1 = 1-light_1_wrap;
	float wrap_2 = 1-light_2_wrap;
	float lambert_1 = saturate(dot(normal, light_1)  * wrap_1 + (1-wrap_1)) ;
	float lambert_2 = saturate(dot(normal, light_2)  * wrap_2 + (1-wrap_2)) ;
	diffuse = (lambert_1 * light_1_color * light_1_intensity) + (lambert_2 * light_2_color * light_2_intensity);

	
	float3 H = normalize(light_1.xyz - shader_data.common.view_dir_distance.xyz);
	float NdotH = saturate(dot(H, normal));

	float exponent = pow(512, rough);
	float NdotL = saturate(dot(light_1.xyz ,normal));

	specular = (float3(1,1,1) + exponent / float3(8,8,8)) * (pow(NdotH, exponent)) * NdotL * FresnelSchlick(specular_color, light_1.xyz, H) * light_1_color * light_1_intensity;
	
	// sample reflection
	float3 view = shader_data.common.view_dir_distance.xyz;
		 
	float3 rVec = reflect(view, normal);
	float mip_index = (1-rough) * 7.0f;
	float4 reflectionMap = sampleCUBELOD(reflection_map, rVec, mip_index, false);
	float3 fresnel = FresnelSchlick(specular_color, -view, normal);
	float3 reflection = reflectionMap.rgb * reflectionMap.a * reflection_intensity * fresnel;	
	
	float4 out_color = float4(0.0f, 0.0f, 0.0f, 1.0f);
	out_color.rgb = shader_data.common.albedo.rgb ;
	
	//..Fake Fog
	float depthFade = 1.0f;
	float depth_fade = float_remap(shader_data.common.view_dir_distance.w, fog_start, fog_end, 1, 0);
	float depth_height = float_remap(shader_data.common.position.z, fog_bottom, fog_top, 0, 1);
	float3 final_fog_value = saturate(1-depth_fade * 1-depth_height);

	
	#if defined(cgfx)
	final_fog_value *= 0.0f;
	#endif
	
		//.. Finalize Output Color
	//out_color.a   = shader_data.alpha;
	float3 color_map =  albedo; 
	diffuse +=  ambient_color.rgb;
	out_color.rgb =  lerp((color_map * diffuse) + specular + (diffuse * reflection), fog_color, final_fog_value);
	return out_color;
}


#include "techniques.fxh"
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	