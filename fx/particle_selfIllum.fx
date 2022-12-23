#include "fx/particle_core.fxh"

DECLARE_SAMPLER_2D_ARRAY(basemap, "Base Texture", "Base Texture", "shaders/default_bitmaps/bitmaps/gray_50_percent.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER_2D_ARRAY(self_illum_map, "Self Illum Texture", "Self Illum Texture", "shaders/default_bitmaps/bitmaps/color_black.tif");
#include "next_texture.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(self_illum_tint_color,			"Self Illum Tint Color", "", float3(1, 1, 1));
#include "used_float3.fxh"

DECLARE_FLOAT_WITH_DEFAULT(self_illum_intensity, "Self Illum Intensity", "", 0.0, 1, float(1.0));
#include "used_float.fxh"

// do the color shuffle
float4 pixel_compute_color(
	inout s_particle_interpolated_values particle_values,
	in float2 sphereWarp,
	in float depthFade)
{
	float4 color;
	[branch]
	if (psNewSchoolFrameIndex)
	{
		// this means we're using new-school tex arrays instead of laid-out sprite sheets
		float3 texcoord = float3(transform_texcoord(particle_values.texcoord_billboard + sphereWarp, basemap_transform), particle_values.texcoord_sprite0.x);
#if DX_VERSION == 11
		texcoord = Convert3DTextureCoordToTextureArray(basemap, texcoord);
#endif		
		color = sample3DGamma(basemap, texcoord);
		
		float3 texcoordAdd = float3(transform_texcoord(particle_values.texcoord_billboard + sphereWarp, self_illum_map_transform), particle_values.texcoord_sprite0.x);
#if DX_VERSION == 11
		texcoordAdd = Convert3DTextureCoordToTextureArray(self_illum_map, texcoordAdd);
#endif	
		particle_values.colorAdd.rgb += sample3DGamma(self_illum_map, texcoordAdd).r * color.rgb * self_illum_tint_color.rgb * self_illum_intensity;	
	}
	else
	{
		// old-school
		color= sample3DGamma(basemap, float3(transform_texcoord(particle_values.texcoord_sprite0 + sphereWarp, basemap_transform), 0.0));	
		float3 texcoordAdd = float3(transform_texcoord(particle_values.texcoord_sprite0 + sphereWarp, self_illum_map_transform), 0.0);
		particle_values.colorAdd += sample3DGamma(self_illum_map, texcoordAdd ).r * color.rgb * self_illum_tint_color.rgb * self_illum_intensity;	
	}

	return color;
}

#include "fx/particle_techniques.fxh"