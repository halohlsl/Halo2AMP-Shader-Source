#if !defined(__PLAYER_EMBLEM_FXH)
#define __PLAYER_EMBLEM_FXH

/*
player_emblem.fxh
Copyright (c) Microsoft Corporation, 2009. All rights reserved.
Monday August 31, 2009, 12:01pm ctchou

	player emblems have 3 layers	(background, middground, foreground)
		each successive layer composites on top of the previous layer
		each layer consists of a single channel alpha-map tinted by a color
		the alpha map is composed of a blend of two shapes
			the blend is: saturate(shape1 * scale1 + shape2 * scale2)
			using positive and negative scales, this allows overlay, subtraction or alpha blend between the two shapes in a layer
			each shape can apply a 2x2 matrix to allow arbitrarily flip, rotate, scale and skew		// (if we limit to flip/rotate only, we can save alot of gradient operations)
			each shape is stored as an atlased vector-map texture that supports high-precision antialiasing
				each color channel of the vector-map can store a separate shape.  the shapes in each layer can source from any color channel (instead of being linked to a particular color channel as before)
*/


// ---------- headers

#include "core/core.fxh"
#include "core/core_vertex_types.fxh"

#include "player_emblem_registers.fxh"
/*
// ---------- constants

#include "hlsl_registers.fx"
#define	SHADER_CONSTANT(	hlsl_type,	hlsl_name,	code_name,	register_start,	register_count,	scope, register_bank, stage)		hlsl_type hlsl_name stage##_REGISTER(register_bank##register_start);
	#include "hlsl_constant_declaration_defaults.fx"
	#include "explicit/emblem_registers.fx"
	#include "hlsl_constant_declaration_defaults_end.fx"
#undef SHADER_CONSTANT
#undef VERTEX_REGISTER
#undef PIXEL_REGISTER
*/


float sample_element(
	texture_sampler_2d		emblem_sampler,
	float2					texcoord,
	float3x2				transform,
	float4					params,
	float					gradient_magnitude)
{
	float2	emblem_texcoord=	mul(float3(texcoord.xy, 1.0f), transform);

	float	vector_distance=	sample2D(emblem_sampler, emblem_texcoord).g + params.z;

	float	scale=	max(params.y / gradient_magnitude, 1.0f);		// scales smaller than 1.0 result in '100% transparent' areas appearing as semi-opaque

	float	vector_alpha= saturate((vector_distance - 0.5f) * min(scale, params.x) + 0.5f);

	return	vector_alpha;
}


float4 calc_emblem(
	in float2 texcoord,
	uniform bool multilayered)
{
	float gradient_magnitude;
	{
#if !defined(xenon)
		gradient_magnitude= 0.001f;
#else	// !defined(xenon)
		float4 gradients;
		asm {
			getGradients gradients, texcoord, foreground1_sampler
		};
		gradient_magnitude= sqrt(dot(gradients.xyzw, gradients.xyzw));
#endif	// !defined(xenon)
	}

	float4 result=	float4(0.0f, 0.0f, 0.0f, 1.0f);

	if (multilayered)
	{
		{
			[isolate]
			float back0=	sample_element(	background0_sampler,	texcoord,	background_xform[0],	background_params[0],	gradient_magnitude);
			float back1=	sample_element(	background1_sampler,	texcoord,	background_xform[1],	background_params[1],	gradient_magnitude);
			float back=		saturate(back0 * background_params[0].w + back1 * background_params[1].w) * background_color.a;

			result		*=	(1-back);
			result.rgb	+=	back * background_color.rgb;
		}

		{
			[isolate]
			float mid0=		sample_element(	midground0_sampler,		texcoord,	midground_xform[0],		midground_params[0],	gradient_magnitude);
			float mid1=		sample_element(	midground1_sampler,		texcoord,	midground_xform[1],		midground_params[1],	gradient_magnitude);
			float mid=		saturate(mid0 * midground_params[0].w +	mid1 * midground_params[1].w) * midground_color.a;

			result		*=	(1-mid);
			result.rgb	+=	mid * midground_color.rgb;
		}
	}

	{
		[isolate]
		float fore0=	sample_element(	foreground0_sampler,	texcoord,	foreground_xform[0],	foreground_params[0],	gradient_magnitude);
		float fore1=	sample_element(	foreground1_sampler,	texcoord,	foreground_xform[1],	foreground_params[1],	gradient_magnitude);
		float fore=		saturate(fore0 * foreground_params[0].w +	fore1 * foreground_params[1].w) * foreground_color.a;

		result		*=	(1-fore);
		result.rgb	+=	fore * foreground_color.rgb;
	}



	return result;
}



#endif //__PLAYER_EMBLEM_FXH
