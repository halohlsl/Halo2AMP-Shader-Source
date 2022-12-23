/*
WATER_RIPPLE.fx
Copyright (c) Microsoft Corporation, 2014. all rights reserved.
09/15/2014 13:36 tmauer	
*/

#include "core/core.fxh"
#include "..\..\materials\water\water_registers.fxh"
#include "ca_under_water_registers.fxh"
#include "exposure.fxh"

#if !defined(cgfx)

//	ignore the vertex_type, input vertex type defined locally
struct s_ripple_vertex_input
{
	uint index		:	SV_VertexID;
};

// The following defines the protocol for passing interpolated data between vertex/pixel shaders
struct s_underwater_interpolators
{
	float4 position			:SV_Position;
	float4 position_ss		:TEXCOORD0;
};

static const float2 k_screen_corners[6]= { 
		float2(-1, -1), float2(1, -1), float2(1, 1), float2(-1, -1), float2(1, 1), float2(-1, 1) };

s_underwater_interpolators underwater_vs(s_ripple_vertex_input IN)
{	
	float2 corner= k_screen_corners[IN.index];

	s_underwater_interpolators OUT;
	OUT.position= float4(corner, 0.5, 1);
	OUT.position_ss= OUT.position;
	return OUT;
}

float compute_fog_factor( 
			float murkiness,
			float depth)
{
	return 1.0f - saturate(1.0f / exp(murkiness * depth));	
}

float4 underwater_ps( s_underwater_interpolators INTERPOLATORS ) : SV_Target0
{	
	// calcuate texcoord in screen space
	INTERPOLATORS.position_ss/= INTERPOLATORS.position_ss.w;
	float2 texcoord_ss= INTERPOLATORS.position_ss.xy;
	texcoord_ss= texcoord_ss / 2 + 0.5;
	texcoord_ss.y= 1 - texcoord_ss.y;
	texcoord_ss= k_ps_water_player_view_constant.xy + texcoord_ss*k_ps_water_player_view_constant.zw;

	// get pixel position in world space
	float distance= 0.0f;
	
	float pixel_depth= sample2D(tex_depth_buffer, texcoord_ss).r;		
	float4 pixel_position= float4(INTERPOLATORS.position_ss.xy, pixel_depth, 1.0f);		
	pixel_position= mul(pixel_position, k_ps_water_view_xform_inverse);
	pixel_position.xyz/= pixel_position.w;
	distance= length(k_ps_camera_position - pixel_position.xyz);	

	// get pixel color
	float4 pixel_color= sample2D(tex_ldr_buffer, texcoord_ss);

	// calc under water fog
	float transparence= 0.5f * saturate(1.0f - compute_fog_factor(k_ps_underwater_murkiness, distance));						
	return lerp(apply_exposure(float4(k_ps_underwater_fog_color,1.0f), false), pixel_color, transparence);		//could I just do this with an alpha blend so I do't need to resolve the LDR buffer anymore....
}

#else

struct s_ripple_interpolators
{
	float4 position	:POSITION0;
};

s_ripple_interpolators underwater_vs()
{
	s_ripple_interpolators OUT;
	OUT.position= 0.0f;
	return OUT;
}


float4 underwater_ps(s_ripple_interpolators INTERPOLATORS) :SV_Target0
{
	return float4(0,1,2,3);
}

#endif //!cgfx


BEGIN_TECHNIQUE _default
{
	pass tiny_position
	{
		SET_VERTEX_SHADER(underwater_vs());
		SET_PIXEL_SHADER(underwater_ps());
	}
}

