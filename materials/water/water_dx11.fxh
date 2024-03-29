
#include "../../explicit_shaders/water/water_tess_dx11.fxh"
#include "postprocessing/postprocess_textures.fxh"

// The following defines the protocol for passing interpolated data between the vertex shader
// and the pixel shader.
struct s_water_interpolators
{
	float4 position		:SV_Position0;
	float2 texcoord		:TEXCOORD0;
	float4 normal		:TEXCOORD1;
	float3 tangent 		:TEXCOORD2;
	float4 wave_slopeArray_xform : TEXCOORD3;
	float4 displacementArray_xform : TEXCOORD4;
	float4 incident_ws	:TEXCOORD5;		//	view incident direction in world space, incident_ws.w store the distannce between eye and current vertex
	float4 position_ws  :TEXCOORD6;
	float4 base_tex		:TEXCOORD7;
	float3 time_pt 		: TEXCOORD8; // x = displacement_time, y = slope_time. z = slope_scalar
};

float3 restore_displacement(
			float3 displacement,
			float height)
{
	displacement= displacement*2.0f - 1.0f;
	displacement*= height;
	return displacement;
}

float3 apply_choppiness(
			float3 displacement,
			float chop_forward,
			float chop_backward,
			float chop_side)
{
	displacement.y*= chop_side;	//	backward choppiness
	displacement.x*= (displacement.x<0) ? chop_forward : chop_backward; //forward scale, y backword scale
	return displacement;
}
/*
float2 calculate_ripple_coordinate_by_world_position(
			float2 position)
{
	float2 texcoord_ripple= (position - vs_view_camera_position.xy) / k_ripple_buffer_radius;
	float len= length(texcoord_ripple);
	texcoord_ripple*= rsqrt(len);

	texcoord_ripple+= k_view_dependent_buffer_center_shifting;
	texcoord_ripple= texcoord_ripple*0.5f + 0.5f;
	texcoord_ripple= saturate(texcoord_ripple);
	return texcoord_ripple;
}*/
float2 restore_slope(
			float2 slope)
{
	slope-= 0.5f;
	return slope;
}


//#include "water_dx11_vanilla.fxh"
#include "water_dx11_shading.fxh"

// rendering buffers/textures 
// vertexInputTriangles == outputVertices after the compute shader has spat them out
STRUCTURED_BUFFER( 	vertexInputTriangles, 	k_vertexInputTrangles, s_water_render_vertex_out, USER_TEXTURE )
#include "next_texture_only.fxh"

//------------------------
// VERTEX
//------------------------
s_water_interpolators water_vs( 
	const uint vertexID : SV_VertexID,
	uniform bool interaction )
{

	s_water_render_vertex_out inp = vertexInputTriangles[ vertexID ];

	float4 incident_ws;
	incident_ws.xyz= vs_view_camera_position - inp.position.xyz;
	incident_ws.w= length(incident_ws.xyz);
	incident_ws.xyz= normalize(incident_ws.xyz);

	float3 position= inp.position; // world space
	const float4 displacement_array_xform     = float4(displacement_scalar_x, displacement_scalar_y, displacement_translate_u, displacement_translate_v);
	const float4 wave_slope_array_xform       = float4(slope_scalar_x, slope_scalar_y, slope_translate_u, slope_translate_v);


	float waterIntensity = 1.0f - inp.wscl;
	// apply global shape control
	float3 displacement     = 0.0f;
	{
		float3 displacement_aux = 0.0f;
		const float4 displacement_aux_array_xform = float4(displacement_aux_scalar_x, displacement_aux_scalar_y, displacement_aux_translate_u, displacement_aux_translate_v);

		//	re-assemble constants
		float3 texcoord     = float3( transform_texcoord(inp.texcoord.xy, displacement_array_xform),  displacement_time );
		float3 texcoord_aux = float3( transform_texcoord(inp.texcoord.xy, displacement_aux_array_xform),  displacement_aux_time );
		//float4 texcoord_aux = float4(transform_texcoord(inp.texcoord.xy, wave_slope_array_xform),  slope_time, mipmap_level);

		displacement     = sample3DLOD(displacement_array, texcoord.xyz, 0, false).xyz;
		displacement_aux = sample3DLOD(displacement_array, texcoord_aux.xyz, 0, false).xyz;

		// restore displacement
		displacement     = restore_displacement(displacement, displacement_height);
		displacement_aux = restore_displacement(displacement_aux, displacement_aux_height);
		displacement     = displacement + displacement_aux;
		displacement     = apply_choppiness( displacement,
						     choppiness_forward * waterIntensity,
						     choppiness_backward * waterIntensity,
						     choppiness_side * waterIntensity);

		// apply global height control
		displacement.z *= choppiness_height_scale;
	}

	// preserve the height
	//water_height_relative= displacement.z;

	// apply vertex displacement
	position.xyz +=
	  inp.tangent  * displacement.x +
	  cross(inp.normal.xyz, inp.tangent.xyz) * displacement.y +
	  inp.normal   * displacement.z;

		// consider interaction	after displacement
/*		if (interaction)
		{
			texcoord_ripple= calculate_ripple_coordinate_by_world_position(position.xy);
			float4 ripple_hei= sample2DLOD(tex_ripple_buffer_slope_height_vs, texcoord_ripple.xy, 0, false);

			float ripple_height= ripple_hei.r*2.0f - 1.0f;

			// low down ripple for shallow water
			ripple_height*= displacement_scale * waterIntensity;

			position+= IN.normal * ripple_height;
		}*/

	s_water_interpolators outp;
	outp.position = mul( float4(position,1), vs_view_view_projection_matrix ); // to NDC space
	outp.texcoord = inp.texcoord;
	outp.normal.xyz	= inp.normal;	// world space normal
	outp.normal.w   = 1.0f - inp.wscl; //1- water scale in w
	outp.tangent	= inp.tangent;
	outp.incident_ws= incident_ws;		//	view incident direction in world space, incident_ws.w store the distannce between eye and current vertex
	outp.position_ws = float4(position,inp.wscl); // water scale in w
	// pack the light map texture coord in with the base
	// ones due to how many interpolators we have
	outp.base_tex.xy	= inp.btexcoord;
	outp.base_tex.zw	= inp.lmtex;
	outp.time_pt.x = displacement_time;
	outp.time_pt.y = slope_time;
	outp.time_pt.z = slope_scalar;
	outp.wave_slopeArray_xform = wave_slope_array_xform;
	outp.displacementArray_xform = displacement_array_xform;

	return outp;
}


// Pixel shaders for the water pass

float4 water_ps(
	s_water_interpolators inp,
	uniform bool alphaBlend,
	uniform bool interaction) : SV_Target0
{
	float4 colour = water_shading(inp, true, true );

	return colour;
}

// Mark this shader as water
#define MATERIAL_SHADER_ANNOTATIONS 	<bool is_water = true;>

#include "techniques_base.fxh"

// Build the techniques
	
#define MAKE_WATER_TECHNIQUE(alpha_blend, interaction)								\
BEGIN_TECHNIQUE																		\
MATERIAL_SHADER_ANNOTATIONS															\
{																					\
	pass water																		\
	{																				\
		SET_VERTEX_SHADER(water_vs(interaction));									\
		SET_PIXEL_SHADER(water_ps(alpha_blend, interaction));						\
	}																				\
}


// Tessellated water entrypoints
MAKE_WATER_TECHNIQUE(false, false)			// refractive, non-interactive
MAKE_WATER_TECHNIQUE(true, false)			// blended, non-interactive
MAKE_WATER_TECHNIQUE(false, true)			// refractive, interactive
MAKE_WATER_TECHNIQUE(true, true)			// blended, interactive
