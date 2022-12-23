//
// File:	 srf_ca_skybox_halo.fx
// Author:	 lkruel
// Date:	 12/09/13
//
// Surface Shader - Skybox Halo Shader
// Built in lighting based on exposed vector parameters. 
//
// Notes:
//


// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"


//.. Artistic Parameters

// Texture Samplers
DECLARE_SAMPLER( color_combo_map, "Color Combo Map", "Color Combo Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( macro_normal_map, "Macro Normal Map", "Macro Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( mix_map, "Blend Map", "Blend Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( tree_color_map, "Tree Color Map", "Tree Color Map", "shaders/default_bitmaps/bitmaps/color_white.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( tree_normal_map, "Tree Normal Map", "Tree Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( modulate_map, "Modulate Map", "Modulate Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"


	// Diffuse
DECLARE_RGB_COLOR_WITH_DEFAULT(bottom_color,		"Bottom Color", "", float3(1,0,0));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(bottom_intensity, "Bottom Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(middle_color,		"Mid Color", "", float3(0,1,0));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(middle_intensity, "Mid Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(middle_opacity, "Mid Opacity", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(mid_sharpness, "Mid Sharpness", "", 1, 10, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(snow_color, "Snow Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(snow_sharpness, "Snow Sharpness", "", 1, 10, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(snow_intensity, "Snow Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(tree_tint,		"Tree Tint", "", float3(0,0,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(tree_opacity, "Tree Opacity", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(tree_intensity, "Tree Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(tree_mask_intensity, "Tree Mask Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(modulate_color,		"Modulate Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(modulate_sharpness, "Modulate Sharpness", "", 1, 10, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(modulate_intensity, "Modulate Intensity", "", 0, 10, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(detail_intensity, "Detail Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"



//Fake lighting

#ifdef cgfx
	DECLARE_BOOL_WITH_DEFAULT(divider_01, "===========================", "", false);
#endif 	

DECLARE_FLOAT_WITH_DEFAULT(light_1_x, "Light 1         X", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_y, "Light 1         Y", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_z, "Light 1         Z", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_intensity, "Light 1      Int", "", 0, 100, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(light_1_color, "Light 1  Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_1_wrap, "Light 1  Wrap", "", 0, 1, float(0.0));
#include "used_float3.fxh"

#ifdef cgfx
	DECLARE_BOOL_WITH_DEFAULT(divider_02, "===========================", "", false);
#endif 

DECLARE_FLOAT_WITH_DEFAULT(light_2_x, "Light 2         X", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_y, "Light 2         Y", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_z, "Light 2         Z", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_intensity, "Light 2      Int", "", 0, 100, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(light_2_color, "Light 2  Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(light_2_wrap, "Light 2  Wrap", "", 0, 1, float(0.0));
#include "used_float3.fxh"

#ifdef cgfx
	DECLARE_BOOL_WITH_DEFAULT(divider_03, "===========================", "", false);
#endif 

DECLARE_RGB_COLOR_WITH_DEFAULT(ambient_color, "Ambient Color", "", float3(0,0,0));
#include "used_float3.fxh"

#ifdef cgfx
DECLARE_BOOL_WITH_DEFAULT(divider_04, "===========================", "", false);
#endif 

DECLARE_FLOAT_WITH_DEFAULT(fog_start,	"Fog Start", "", 0, 9999, float(0.00));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_end,		"Fog End", "", 0, 9999, float(4000.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_bottom,		"Fog Bottom ", "", -1000000, 1000000, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_top,		"Fog Top ", "", -1000000, 1000000, float(500.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_y_multiplier_start,		"Fog Y Multiplier Start", "", -1000000, 1000000, float(500.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(fog_y_multiplier_end,		"Fog Y Multiplier End", "", -1000000, 1000000, float(2000.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(fog_color, "Fog Color", "", float3(1,1,1));
#include "used_float3.fxh"



struct s_shader_data {
	s_common_shader_data common;
};

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
			
			
{
		float2 uv = pixel_shader_input.texcoord.xy;
		
		///.. Sample texture maps
	    float2 color_combo_map_uv = transform_texcoord(uv, color_combo_map_transform);
	    float4 color_combo = sample2D(color_combo_map, color_combo_map_uv);

    	float2 macro_normal_uv   = transform_texcoord(uv, macro_normal_map_transform);
        float3 macro_normal = sample_2d_normal_approx(macro_normal_map, macro_normal_uv);		

		float2 layer_blend_uv   = transform_texcoord(uv, mix_map_transform);
		float4 layer_blend = sample2D(mix_map, layer_blend_uv);

		float2 trees_uv = transform_texcoord(uv, tree_color_map_transform);
		float4 trees = sample2D(tree_color_map, trees_uv);			

    	float2 tree_normal_uv   = transform_texcoord(uv, tree_normal_map_transform);
        float3 tree_normal = sample_2d_normal_approx(tree_normal_map, tree_normal_uv);
		
	    float2 modulate_map_uv = transform_texcoord(uv, modulate_map_transform);
	    float4 modulate = sample2DGamma(modulate_map, modulate_map_uv);


		///.. Derive blend masks
		// Get snowmask from layer_blend.b
		float snow_mask = saturate(pow(layer_blend.b, snow_sharpness));
					
		// Get treemask from trees.r
		float tree_mask = saturate(pow(saturate(trees.a - (1-layer_blend.r)), 1-tree_mask_intensity));

		// Get detail normal mask from modulate_map
		float3 detail_mask = detail_intensity * pow(modulate, 2);
		

		///.. Create layers
		float3 bottom_layer = color_combo.g * bottom_color * bottom_intensity;
		
		float3 mid_layer = color_combo.r * middle_color * middle_intensity;
		float3 mid_amount = middle_opacity * saturate(pow((layer_blend.g * mid_sharpness), mid_sharpness));
		
		float3 tree_color = trees * tree_tint * tree_intensity;
		float3 tree_amount = tree_opacity * tree_mask;
		
		float3 modulate_amount = pow(modulate, modulate_sharpness) * modulate_intensity * modulate_color;
		
		
		///.. Combine layers
		//Lerp mid_layer onto of bottom_layer 
		shader_data.common.albedo.rgb = lerp(bottom_layer, mid_layer, mid_amount) ;

		//Add in snow layer
		shader_data.common.albedo.rgb += saturate(shader_data.common.albedo.rgb + (snow_mask * snow_color * snow_intensity));
		
		//Lerp tree_layer 
		shader_data.common.albedo.rgb = lerp(shader_data.common.albedo, tree_color, tree_amount);
		
		//Multiply in modulate_map minus snow
		shader_data.common.albedo.rgb += saturate(modulate_amount * (1-snow_mask)) * shader_data.common.albedo;

			
		///.. Combine normal maps
		// Lerp macronormal and tree normal using treesmask
		shader_data.common.normal = lerp(macro_normal, tree_normal, tree_amount);

		//Add detail_normal to macro_normal
		shader_data.common.normal += tree_normal * detail_mask; 
		
		// Transform from tangent space to world space
		shader_data.common.normal = mul(shader_data.common.normal, shader_data.common.tangent_frame);

}

 
float4 pixel_lighting(
	        in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data) 
			
			
{
	float2 uv = pixel_shader_input.texcoord.xy;
 
	///..input from s_shader_data
    float4 albedo         = shader_data.common.albedo;
    float3 normal         = shader_data.common.normal;

	///..Fake lighting vectors
	float3 light_1 = normalize(float3(light_1_x, light_1_y, light_1_z));
	float3 light_2 = normalize(float3(light_2_x, light_2_y, light_2_z));

    float3 diffuse = 0.0f;
	
	///..Half Lambert 
	float wrap_1 = 1-light_1_wrap;
	float wrap_2 = 1-light_2_wrap;
	float lambert_1 = saturate(dot(normal, light_1)  * wrap_1 + (1-wrap_1)) ;
	float lambert_2 = saturate(dot(normal, light_2)  * wrap_2 + (1-wrap_2)) ;
	diffuse = (lambert_1 * light_1_color * light_1_intensity) + (lambert_2 * light_2_color * light_2_intensity) + ambient_color.rgb;
	
	
	///..Fake Fog
	float depthFade = 1.0f;
	float depth_fade = float_remap(shader_data.common.view_dir_distance.w, fog_start, fog_end, 1, 0);
	float depth_height = float_remap(shader_data.common.position.z, fog_bottom, fog_top, 0, 1);
	float depth_y = (float_remap(shader_data.common.position.y, fog_y_multiplier_start, fog_y_multiplier_end, 0, 1)) + (float_remap(shader_data.common.position.y, 1-fog_y_multiplier_start, 1-fog_y_multiplier_end, 0, 1));
	
	float3 final_fog_value = saturate(1-depth_fade + depth_y * 1-depth_height);

	
	#if defined(cgfx)
		final_fog_value *= 0.0f;
	#endif
	
	
	///.. Finalize Output Color

	float4 out_color = float4(0.0f, 0.0f, 0.0f, 1.0);
	//out_color.rgb = (shader_data.common.albedo.rgb * diffuse) + final_fog_value;
	out_color.rgb = lerp((shader_data.common.albedo.rgb * diffuse), fog_color, final_fog_value);

	
	return out_color;
}


#include "techniques.fxh"