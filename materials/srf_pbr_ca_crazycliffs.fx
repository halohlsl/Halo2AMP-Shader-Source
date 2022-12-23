//
// File:	 srf_pbr_ca_crazycliffs.fx
// Author:	 mahlin
// Date:	 04/17/14
//
// Surface Shader - Variation on the pbr terrain shader. Three color maps are packed into the rgb of a single texture
//					(same thing with cavity maps) and blended with a macro blend map. There is a macro color and a macro properties map 
//					which allows for various effects to be painted across the surface. A 4th layer is used for grass.
//
// Copyright (c) 343 Industries. All rights reserved.
//
// Notes:
//

//#define DISABLE_LIGHTING_TANGENT_FRAME
//#define DISABLE_LIGHTING_VERTEX_COLOR
//#define DISABLE_SHARPEN_FALLOFF

// Core Includes
#include "core/core.fxh"
#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"

//.. Texture Samplers
DECLARE_SAMPLER( blend_map, "Blend Map", "Blend Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(blend_sharpen, "R Blend Sharpen", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(normIntensityMask_sharpen, "Normal Map Intensity Mask Sharpen", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_SAMPLER( uber_color_map, "Uber Color Map", "Uber Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( color_map, "Macro Color Map", "Macro Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( colorcavity_combomap, "Color and Cavity Combo Map", "Color and Cavity Combo Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(layer_0_color,	"Layer 0 Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(layer_1_color,	"Layer 1 Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_SAMPLER( macro_normal_map, "Macro Normal Map", "Macro Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER_NO_TRANSFORM(layer_0_normal_map, "Layer 0 Normal Map", "Layer 0 Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER_NO_TRANSFORM(layer_1_normal_map, "Layer 1 Normal Map", "Layer 1 Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( grass_color_map, "Grass Color Map", "Grass Color Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER_NO_TRANSFORM( grass_normal_map, "Grass Normal Map", "Grass Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(grass_mask_power,		"Grass Mask Power", "", 0, 1, float(4.0));
#include "used_float.fxh"

//DECLARE_SAMPLER_CUBE(reflection_map,  "Reflection Map", "", "shaders/default_bitmaps/bitmaps/default_cube.tif");
//#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(reflection_intensity, "Reflection Intensity", "", 0, 10, float(5.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(reflection_color,	"Reflection Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(rough, "Roughness", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(glancing_power, "Glancing Angle Power", "", 0, 1, float(0.0));
#include "used_float.fxh"


DECLARE_FLOAT_WITH_DEFAULT(metallic, "Metallicness", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(normalmap_intensity, "Normal Map Intensity", "", 0, 10, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(uplight_vector_x, "Uplight X", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(uplight_vector_y, "Uplight Y", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(uplight_vector_z, "Uplight Z", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(uplight_color,	"Uplight Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(uplight_intensity, "Uplight Intensity", "", 0, 10, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(uplight_vector_intensity, "Uplight Vector Intensity", "", 0, 10, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(uplight_vector_power, "Uplight Vector Power", "", 0, 10, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(uplight_usetexturenormal,		"Uplight Use Texture Normal", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(sidelight_vector_x, "Sidelight X", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(sidelight_vector_y, "Sidelight Y", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(sidelight_vector_z, "Sidelight Z", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(sidelight_color,	"Sidelight Color", "", float3(1,1,1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(sidelight_intensity, "Sidelight Intensity", "", 0, 10, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(sidelight_vector_intensity, "Sidelight Vector Intensity", "", 0, 10, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(sidelight_vector_power, "Sidelight Vector Power", "", 0, 10, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(sidelight_usetexturenormal,		"Sidelight Use Texture Normal", "", 0, 1, float(1.0));
#include "used_float.fxh"


struct s_shader_data {
	s_common_shader_data common;
};

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
			
{
	float2 uv = pixel_shader_input.texcoord.xy;
	float3 geometry_normal = shader_data.common.normal;
		
	const float gamma_multiplier = 4.59479f;		// 4.59479f == 2 ^ 2.2  (sRGB gamma)
	
	//Color Maps.....................................................................................
	// sample the blend map 
	    float2 blend_map_uv   = transform_texcoord(uv, blend_map_transform);
        float3 blendValue = sample2D(blend_map, blend_map_uv);
		float layer_blend = pow(blendValue.r, blend_sharpen);
		//float macro_cavity = blendValue.g;
		float normIntensityMask = pow(blendValue.g, normIntensityMask_sharpen);

	// sample the macro color map
	    float2 macroColor_uv   = transform_texcoord(uv, color_map_transform);
        float3 macroColor = sample2DGamma(color_map, macroColor_uv).rgb;
		
	// sample the uber color map
	    float2 uberColor_uv   = transform_texcoord(uv, uber_color_map_transform);
        float3 uberColor = sample2DGamma(uber_color_map, uberColor_uv).rgb;
			
	// sample the colorcavity combo map		
		float2 colorcavitycombo_uv   = transform_texcoord(uv, colorcavity_combomap_transform);
		float4 colorcavitycombo = sample2DGamma(colorcavity_combomap, colorcavitycombo_uv);
			
		float3 color0 = colorcavitycombo.r * gamma_multiplier * layer_0_color;
		float3 color1 = colorcavitycombo.g * gamma_multiplier * layer_1_color;
		float3 cavity0 = colorcavitycombo.b;
		float3 cavity1 = colorcavitycombo.a;
				
	//Combine color maps
		float3 composite_albedo = float3(0,0,0);
		composite_albedo = color0;
		composite_albedo = lerp(composite_albedo, color1 , layer_blend);
		composite_albedo = composite_albedo * macroColor * (uberColor * gamma_multiplier);
		
	//Combine cavity maps
		float3 composite_cavity = float3(0,0,0);
		composite_cavity = cavity0;
		composite_cavity = lerp(composite_cavity, cavity1 , layer_blend);
		//composite_cavity = composite_cavity * macro_cavity;
		
	// sample the grass color map
	    float2 grassColor_uv   = transform_texcoord(uv, grass_color_map_transform);
        float4 grassColor = sample2DGamma(grass_color_map, grassColor_uv);

		
	//Normal Maps....................................................................................
	
	// Sample normal maps
		float3 composite_normal = float3(0,0,1);

        float3 macro_normal = sample_2d_normal_approx(macro_normal_map, macroColor_uv);
		
        float3 layer_0_normal = sample_2d_normal_approx(layer_0_normal_map, colorcavitycombo_uv);
		
        float3 layer_1_normal = sample_2d_normal_approx(layer_1_normal_map, colorcavitycombo_uv);

		float3 grassNormal = sample_2d_normal_approx(grass_normal_map, grassColor_uv);

			
	//Combine layered normal maps and macro normal
		composite_normal = (macro_normal + layer_0_normal) / 2.0;
		composite_normal.z =  sqrt(saturate(1.0f + dot(composite_normal.xy, -composite_normal.xy)));
		composite_normal.xyz = lerp( composite_normal.xyz, layer_1_normal.xyz, layer_blend);

	// Factor in the normal strength mask
		composite_normal.xy = composite_normal.xy * (normIntensityMask * gamma_multiplier) * normalmap_intensity;	
		
		shader_data.common.normal = normalize(composite_normal);
	
	// Projection vectors
	#if defined(cgfx)
		float3 uplight = normalize(float3(uplight_vector_x, uplight_vector_y, uplight_vector_z));
		float3 sidelight = normalize(float3(sidelight_vector_x, sidelight_vector_y, sidelight_vector_z));
		//float3 grass_vector = normalize(float3(grass_vector_x, grass_vector_y, grass_vector_z));
    #else
		float3 uplight = normalize(float3(uplight_vector_z, uplight_vector_x, uplight_vector_y));
		float3 sidelight = normalize(float3(sidelight_vector_z, sidelight_vector_x, sidelight_vector_y));
		//float3 grass_vector = normalize(float3(grass_vector_z, grass_vector_x, grass_vector_y));		
    #endif	

	// Create directional mask for grass that includes texture normal
		float3 maskwithtexnormals = mul(shader_data.common.normal, shader_data.common.tangent_frame);	

	//Use vertex colors to paint out grass mask
		float vertcolor = ((shader_data.common.vertexColor.a * 4) - 2);
		//float vertcolor = shader_data.common.vertexColor.a;
	
	// Create grass projection
		//float masknormal_grass = dot(normalize(grass_vector) , lerp(geometry_normal, maskwithtexnormals, grass_vector_usetexturenormal) ) + maskBias;		
		float grassmask = saturate(pow(saturate(grassColor.a - (1-vertcolor)), max(0.001, 1-grass_mask_power)));

	// Grass projection into normals
		shader_data.common.normal = lerp(shader_data.common.normal, grassNormal, grassmask); 

				
	// Grass projection into albedo
		composite_albedo = lerp(composite_albedo, grassColor, grassmask); 
		
	// Transform from tangent space to world space
		shader_data.common.normal = mul(shader_data.common.normal, shader_data.common.tangent_frame);
					
	// Factor vector lights into albedo 
		uplight = dot(normalize(uplight) , lerp(geometry_normal, maskwithtexnormals, uplight_usetexturenormal));
		uplight = pow(saturate(uplight * uplight_vector_intensity), uplight_vector_power);
		sidelight = dot(normalize(sidelight) , lerp(geometry_normal, maskwithtexnormals, sidelight_usetexturenormal));
		sidelight = pow(saturate(sidelight * sidelight_vector_intensity), sidelight_vector_power);
		
		composite_albedo = lerp(composite_albedo, (composite_albedo * uplight_intensity), uplight);
		composite_albedo = lerp(composite_albedo, (composite_albedo * sidelight_intensity), sidelight);


		
		shader_data.common.albedo.a = 1.0;
		shader_data.common.albedo.rgb = composite_albedo;
		
	// Cache the blend values into the deffered map for the lighting step to use on the combo map.
		shader_data.common.shaderValues.x = composite_cavity;
	
}

	float4 pixel_lighting(
	in s_pixel_shader_input pixel_shader_input,
    inout s_shader_data shader_data) 
			
{
		float2 uv = pixel_shader_input.texcoord.xy;
	
    // input from s_shader_data
		float4 albedo         = shader_data.common.albedo ;
		float3 normal         = shader_data.common.normal;

		float composite_cavity		  = shader_data.common.shaderValues.x;
		
		float roughglance = saturate(pow(rough * composite_cavity.r * shader_data.common.albedo.r, glancing_power));

		float3 composite_combo = float3(composite_cavity.r, roughglance, metallic);
		
		float3 specular = 0.0f;

	// using blinn specular model
	float metallic = composite_combo.b ; 
	float roughness = composite_combo.g;	
	float cavity = composite_combo.r;
	float3 specular_color = lerp(pow(float3(0.04, 0.04, 0.04), 2.2), albedo , metallic);
	calc_specular_blinnphong(specular, shader_data.common, normal, specular_color, roughness);
	
	//calculate the diffuse
	float3 diffuse = 0.0f;
	calc_diffuse_lambert(diffuse, shader_data.common, normal);

	// sample reflection
	float3 reflection = 0.0f;
	float3 view = shader_data.common.view_dir_distance.xyz;
		 
	float3 rVec = reflect(view, normal);
	float mip_index = (1-roughness) * 7.0f;
	//float4 reflectionMap = sampleCUBELOD(reflection_map, rVec, mip_index, false);
	float3 fresnel = FresnelSchlickWithRoughness(specular_color, -view, normal, roughness);
	//reflection = reflectionMap.rgb * reflectionMap.a * reflection_intensity * fresnel;// * max(roughness, specular_color);
	reflection = reflection_color * reflection_intensity * fresnel;// * max(roughness, specular_color);
	
	//darken albedo if we are metalic  
  	albedo.rgb =  lerp(albedo.rgb, float3(0,0,0), metallic);


	//.. Finalize Output Color
    float4 out_color;
	out_color.a   = 1.0;

    out_color.rgb =  (albedo * diffuse)  + specular + (reflection * diffuse);
	out_color.rgb *= cavity;
	
	return out_color;
}


#include "techniques.fxh"
