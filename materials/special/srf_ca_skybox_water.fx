
// File:	 srf_ca_skybox_halo.fx
// Author:	 lkruel
// Date:	 12/09/13
//
// Surface Shader - Skybox Water Shader
// Built in lighting and fog based on exposed vector parameters. 
//
// Notes:
//

#define DISABLE_LIGHTING_TANGENT_FRAME
#define DISABLE_LIGHTING_VERTEX_COLOR
#define DISABLE_SHARPEN_FALLOFF

#define MATERIAL_SHADER_ANNOTATIONS 	<bool is_alpha_clip = true;>
static const float clip_threshold = 254.5f / 255.0f;

//static const float clip_threshold = 220.0f / 255.0f;


// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"


//.. Artistic Parameters

// Texture Samplers


DECLARE_SAMPLER( waves01_normal_map, "Waves 1 Normal Map", "Waves 1 Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( waves02_normal_map, "Waves 2 Normal Map", "Waves 2 Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( waves03_normal_map, "Waves 3 Normal Map", "Waves 3 Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( color_map, "Water Color Map", "Water Color Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( noise_map, "Edge Noise Map", "Edge Noise Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER_CUBE(reflection_map,  "Reflection Map", "", "shaders/default_bitmaps/bitmaps/default_cube.tif")
#include "next_texture.fxh"


// Diffuse
DECLARE_RGB_COLOR_WITH_DEFAULT(water_tint,		"Water Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(water_roughness, "Water Roughness", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(reflection_strength, "Reflection Multiplier", "", 0, 10, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(wave_strength, "Wave Strength", "", 0, 2, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(reflection_color,		"Reflection Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(noise_intensity, "Noise Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(edge_intensity, "Edge Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"




//Rotation
DECLARE_FLOAT_WITH_DEFAULT(rotation_01, "Waves 1 Rotation", "Waves 1 Rotation", 0, 3.14, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(rotation_02, "Waves 2 Rotation", "Waves 2 Rotation", 0, 3.14, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(rotation_03, "Waves 3 Rotation", "Waves 3 Rotation", 0, 3.14, float(0.0));
#include "used_float.fxh"


#ifdef cgfx
	//Fake lighting
	DECLARE_BOOL_WITH_DEFAULT(divider_01, "===========================", "", false);
#endif 

DECLARE_FLOAT_WITH_DEFAULT(light_1_x, "Light 1         X", "", -1, 1, float(0.6));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_y, "Light 1         Y", "", -1, 1, float(0.2));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_z, "Light 1         Z", "", -1, 1, float(0.2));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_intensity, "Light 1      Int", "", 0, 100, float(2.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(light_1_color, "Light 1  Color", "", float3(1,.937,.831));
#include "used_float3.fxh"

#ifdef cgfx
	DECLARE_BOOL_WITH_DEFAULT(divider_03, "===========================", "", false);
#endif 

DECLARE_RGB_COLOR_WITH_DEFAULT(ambient_color, "Ambient Color", "", float3(0,0,0));
#include "used_float3.fxh"

#ifdef cgfx
	DECLARE_BOOL_WITH_DEFAULT(divider_04, "===========================", "", false);
#endif
 
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
	float2 uv2 = pixel_shader_input.texcoord.zw;

	//Texture Rotation
	float rot_center_u = .5;
	float rot_center_v = .5;
	float2 rot01_uv = uv;
	float2 rot02_uv = uv;
	float2 rot03_uv = uv;
	//offest to origin
	rot01_uv = float2(rot01_uv.x - rot_center_u, rot01_uv.y - rot_center_v);
	rot02_uv = float2(rot02_uv.x - rot_center_u, rot02_uv.y - rot_center_v);
	rot01_uv = float2(rot03_uv.x - rot_center_u, rot03_uv.y - rot_center_v);
	//apply rotation
	rot01_uv = float2( rot01_uv.x*cos(rotation_01) - rot01_uv.y*sin(rotation_01) , rot01_uv.x*sin(rotation_01) + rot01_uv.y*cos(rotation_01) );
	rot02_uv = float2( rot02_uv.x*cos(rotation_02) - rot02_uv.y*sin(rotation_02) , rot02_uv.x*sin(rotation_02) + rot02_uv.y*cos(rotation_02) );
	rot03_uv = float2( rot03_uv.x*cos(rotation_03) - rot03_uv.y*sin(rotation_03) , rot03_uv.x*sin(rotation_03) + rot03_uv.y*cos(rotation_03) );
	//offset to original position
	rot01_uv = float2(rot01_uv.x + rot_center_u, rot01_uv.y + rot_center_v);
	rot02_uv = float2(rot02_uv.x + rot_center_u, rot02_uv.y + rot_center_v);
	rot03_uv = float2(rot03_uv.x + rot_center_u, rot03_uv.y + rot_center_v);


	// Sample waves01 normal map
	float2 waves01_normal_uv   = transform_texcoord(rot01_uv, waves01_normal_map_transform);
	float3 waves01_normal = sample_2d_normal_approx(waves01_normal_map, waves01_normal_uv);
	
	// Sample waves02 normal map
	float2 waves02_normal_uv   = transform_texcoord(rot02_uv, waves02_normal_map_transform);
	float3 waves02_normal = sample_2d_normal_approx(waves02_normal_map, waves02_normal_uv);
	
	// Sample waves03 normal map
	float2 waves03_normal_uv   = transform_texcoord(rot03_uv, waves03_normal_map_transform);
	float3 waves03_normal = sample_2d_normal_approx(waves03_normal_map, waves03_normal_uv);
	
	// Sample edge noise map
	float2 noise_map_uv   = transform_texcoord(uv, noise_map_transform);
	float3 edge_noise = saturate(pow(sample2D(noise_map, noise_map_uv), noise_intensity));

	shader_data.common.normal = waves01_normal;
	shader_data.common.normal.xy += waves02_normal.xy;
	shader_data.common.normal.xy += waves03_normal.xy;
	
	shader_data.common.normal.xy = shader_data.common.normal.xy * (wave_strength * .0833);
	
	// Transform from tangent space to world space
	shader_data.common.normal = mul(normalize(shader_data.common.normal), shader_data.common.tangent_frame);

	// Sample water color map and alpha
	float2 color_map_uv = transform_texcoord(uv2, color_map_transform);
	float4 water_albedo = sample2DGamma(color_map, color_map_uv);
	
	// Combine edge noise and alpha mask
	float alpha_noise = 1.0f;
	float noise_lerp = 1.0f;
	alpha_noise = saturate(pow(1.00001-water_albedo.a, 1-(edge_intensity +1)) - (edge_noise));

	
	shader_data.common.albedo.rgb = water_albedo * water_tint;
	shader_data.common.shaderValues.x = water_albedo.a;
	shader_data.common.shaderValues.y = alpha_noise;
	
	// Snip snip
	clip(shader_data.common.shaderValues.y - clip_threshold);
}		
		
		
float4 pixel_lighting(
	in s_pixel_shader_input pixel_shader_input,
	inout s_shader_data shader_data) 
{
 
		// input from s_shader_data
    float4 albedo         = shader_data.common.albedo ;
    float3 normal         = shader_data.common.normal;
	
	float water_mask = shader_data.common.shaderValues.x;
	float alpha_noise = shader_data.common.shaderValues.y;
    float3 specular = 0.0f;
	float rough = water_roughness;
	float3 specular_color = float3(0.04, 0.04, 0.04);
	
	float3 light_1 = normalize(float3(light_1_x, light_1_y, light_1_z));
	
	float3 H = normalize(light_1.xyz - shader_data.common.view_dir_distance.xyz);
	float NdotH = saturate(dot(H, normal));

	float exponent = pow(512, rough);
	float NdotL = saturate(dot(light_1.xyz ,normal));

	specular = (float3(1,1,1) + exponent / float3(8,8,8)) * (pow(NdotH, exponent)) * NdotL * FresnelSchlick(specular_color, light_1.xyz, H) * light_1_color * light_1_intensity * water_mask;
	
    float3 diffuse = 0.0f;
	float3 diffuse_reflection_mask = 0.0f;
		
	float lambert_1 = saturate(dot(normal, light_1));
	diffuse = (lambert_1 * light_1_color * light_1_intensity);
	
	// sample reflection
	float3 reflection = 0.0f;
	float3 view = shader_data.common.view_dir_distance.xyz;
	float3 rVec = reflect(view, normal);
	
	float mip_index = (1-rough) * 1.0f;
	float4 reflectionMap = pow(sampleCUBELOD(reflection_map, rVec, mip_index, false), 1);
	float3 reflectionColor = reflectionMap.rgb * reflection_color;
	
	float3 fresnel = FresnelSchlickWithRoughness(specular_color, -view, normal, rough);
	reflection = reflectionColor * fresnel * reflection_strength * water_mask;

	float4 out_color = float4(0.0f, 0.0f, 0.0f, 1.0f);
	out_color.rgb = shader_data.common.albedo.rgb;
	out_color.a = saturate(alpha_noise);
		
	///..Fake Fog
	float depthFade = 1.0f;
	float depth_fade = float_remap(shader_data.common.view_dir_distance.w, fog_start, fog_end, 1, 0);
	float depth_height = float_remap(shader_data.common.position.z, fog_bottom, fog_top, 0, 1);
	float depth_y = (float_remap(shader_data.common.position.y, fog_y_multiplier_start, fog_y_multiplier_end, 0, 1)) + (float_remap(shader_data.common.position.y, 1-fog_y_multiplier_start, 1-fog_y_multiplier_end, 0, 1));
	
	float3 final_fog_value = saturate(1-depth_fade + depth_y * 1-depth_height);

	
	#if defined(cgfx)
		final_fog_value *= 0.0f;
	#endif
	
	//.. Finalize Output Color
	
	float3 color_map =  albedo; 
	diffuse +=  ambient_color.rgb;
	
	out_color.rgb =  lerp((color_map * diffuse + reflection + specular), fog_color, final_fog_value);

	return out_color;
}
#include "techniques.fxh"
