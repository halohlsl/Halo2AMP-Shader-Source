#include "fx/particle_core.fxh"

DECLARE_SAMPLER_2D_ARRAY(basemap, "Base Texture", "Base Texture", "shaders/default_bitmaps/bitmaps/gray_50_percent.tif");
#include "next_texture.fxh"

#if DX_VERSION == 11
// convert normalized 3d texture z coordinate to texture array coordinate
void Convert3DTextureCoordToTextureArraySmooth(in texture_sampler_2d_array t, in float3 uvw, out float3 lowUVW, out float3 highUVW, out float blend )
{
	uint width, height, elements;
	t.t.GetDimensions(width, height, elements);
	float index = uvw.z * elements;
	blend = frac(index);//I have a small convern that floating point error could lead this to loop before the round operation in the texture sample does...
	lowUVW = float3( uvw.xy, (index) - 0.5);
	highUVW = float3( uvw.xy, (index) + 0.5);
}
#endif

// do the color shuffle
float4 pixel_compute_color(
	in s_particle_interpolated_values particle_values,
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
		float3 lowUVW = 0;
		float3 highUVW = 0;
		float blend = 0;
		Convert3DTextureCoordToTextureArraySmooth(basemap, texcoord, lowUVW, highUVW, blend);

		float4 colorLow = sample3DGamma(basemap, lowUVW);
		float4 colorHigh = sample3DGamma(basemap, highUVW);

		color = lerp( colorLow, colorHigh, blend );
#else
			//the old version used 3D textures instead of texture arrays and blended for free... sigh...
		color = sample3DGamma(basemap, texcoord);
#endif		
		
	}
	else
	{
		// old-school
		color= sample3DGamma(basemap, float3(transform_texcoord(particle_values.texcoord_sprite0 + sphereWarp, basemap_transform), 0.0));	
	}

	return color;
}

#include "fx/particle_techniques.fxh"