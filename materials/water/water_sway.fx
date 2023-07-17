#define ENABLE_DEPTH_INTERPOLATER
#if defined(xenon)
#define ENABLE_VPOS
#endif


#if !defined(DISABLE_WATER_ALPHA_FADE)
#define DO_WATER_ALPHA_FADE
#endif

#if !defined(DISABLE_WATER_REFLECTION)
#define DO_WATER_REFLECTION
#endif

#if !defined(DISABLE_WATER_REFRACTON)
#define DO_WATER_REFRACTION
#endif

#define DO_WATER_FOAM
#define DISABLE_NORMAL
#define DISABLE_TANGENT_FRAME

// Core Includes
#include "core/core.fxh"
#include "core/core_vertex_types.fxh"
#include "deform.fxh"
#include "exposure.fxh"

#include "engine/engine_parameters.fxh"
#include "lighting/lighting.fxh"


#include "fx/fx_functions.fxh"

// GPU ranges
// vs constants: 130 - 139
// ps constants: 213 - 221
// bool constants: 100 - 104
// samplers: 0 - 1

/* water only*/
DECLARE_PARAMETER(sampler2D, tex_ripple_buffer_slope_height_vs, s1);
DECLARE_PARAMETER(sampler2D, tex_ripple_buffer_slope_height_ps, s11);

#define k_is_camera_underwater false
#define k_is_under_screenshot false

// underwater only
DECLARE_PARAMETER(sampler2D, tex_ldr_buffer, s12);

DECLARE_PARAMETER(sampler2D, tex_depth_buffer, s14);
DECLARE_PARAMETER(float4, psDepthConstants, c2);

DECLARE_PARAMETER(float4, k_ps_texture_size_exposure, c14);


// share constants
DECLARE_PARAMETER(float, k_ripple_buffer_radius, c133);
DECLARE_PARAMETER(float2, k_view_dependent_buffer_center_shifting, c134);

DECLARE_PARAMETER(float4x4, k_ps_water_view_xform_inverse, c213);
DECLARE_PARAMETER(float4, k_ps_water_player_view_constant, c218);






/* Water profile contants and textures from tag*/

// displacement maps
DECLARE_SAMPLER(displacement_array, "Wave Displacement Array", "Wave Displacement Array", "rasterizer/water/wave_test7/wave_test7_displ_water.tif");
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(displacement_scalar_x, "wave displacement scalar x", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(displacement_scalar_y, "wave displacement scalar y", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(displacement_translate_u, "displacement translate u", "", 0, 1, float(0.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(displacement_translate_v, "displacement translate v", "", 0, 1, float(0.0));
#include "used_float.fxh"
DECLARE_VERTEX_FLOAT(displacement_height, "", "", 0, 1);
#include "used_vertex_float.fxh"
DECLARE_VERTEX_FLOAT(displacement_time, "", "", 0, 1);
#include "used_vertex_float.fxh"

// secondary displacement maps
DECLARE_FLOAT_WITH_DEFAULT(displacement_aux_scalar_x, "wave displacement scalar x", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(displacement_aux_scalar_y, "wave displacement scalar y", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(displacement_aux_translate_u, "displacement aux translate u", "", 0, 1, float(0.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(displacement_aux_translate_v, "displacement aux translate v", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_VERTEX_FLOAT(displacement_aux_height, "", "", 0, 1);
#include "used_vertex_float.fxh"

DECLARE_VERTEX_FLOAT(displacement_aux_time, "", "", 0, 1);
#include "used_vertex_float.fxh"

DECLARE_FLOAT(max_distort, "Maxium Distortion", "", 0, 1);
#include "used_float.fxh"

DECLARE_FLOAT(water_speed, "Water Speed", "", 0, 1);
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(water_detail_intensity, "Water Detail Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(water_roughness, "Water Roughness", "", 0, 1, float(0.7));
#include "used_float.fxh"

DECLARE_SAMPLER( diffuse_map, "Diffuse Map", "Diffuse Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(diffuse_map_mix, "Diffuse Map Mix", "Diffuse Map Mix", 0, 1, float(0.0));
#include "used_float.fxh"


DECLARE_FLOAT_WITH_DEFAULT(murk_multiplier, "Murk Multiplier", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(murk_color, "Murk Color Near", "", float3(0.5, 0.5, 0.5));
#include "used_float3.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(murk_color_far, "Murk Color Far", "", float3(0.5, 0.5, 0.5));
#include "used_float3.fxh"


DECLARE_FLOAT(slope_scalar, "", "", 0, 1);
#include "used_float.fxh"

DECLARE_VERTEX_FLOAT_WITH_DEFAULT(displacement_scale, "overall displacement scale", "", 0, 1, float(0.2f));
#include "used_vertex_float.fxh"


// wave shape
DECLARE_VERTEX_FLOAT(choppiness_forward, "", "", 0, 1);
#include "used_vertex_float.fxh"

DECLARE_VERTEX_FLOAT(choppiness_backward, "", "", 0, 1);
#include "used_vertex_float.fxh"

DECLARE_VERTEX_FLOAT(choppiness_side, "", "", 0, 1);
#include "used_vertex_float.fxh"

DECLARE_VERTEX_FLOAT(choppiness_height_scale, "", "", 0, 1);
#include "used_vertex_float.fxh"


DECLARE_FLOAT(detail_slope_steepness, "", "", 0, 1);
#include "used_float.fxh"


// water appearance ------------------------------------------------------

// Reflection
DECLARE_FLOAT_WITH_DEFAULT(depth_edge_range,  "Depth Edge Range", "", 0, 5, float(0.4));
#include "used_float.fxh"
DECLARE_SAMPLER_CUBE(reflection_map,  "Reflection Texture", "", "shaders/default_bitmaps/bitmaps/default_cube.tif")
#include "next_texture.fxh"
DECLARE_FLOAT(reflection_intensity, "", "", 0, 1);
#include "used_float.fxh"


DECLARE_FLOAT(shadow_intensity_mark, "", "", 0, 1);
#include "used_float.fxh"


DECLARE_SAMPLER( noise_map, "Noise Map", "Noise Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_FLOAT_WITH_DEFAULT(noise_strength, "Noise Strength", "", 0, 1, float(0.1));
#include "used_float.fxh"

DECLARE_SAMPLER( flow_map, "Flow Map", "Flow Map", "shaders/default_bitmaps/bitmaps/default_diff.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( macro_normal_map, "Macro Normal Map", "Macro Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_SAMPLER( wave_normal_map, "Wave Normal Map", "Wave Normal Map", "shaders/default_bitmaps/bitmaps/default_normal.tif");
#include "next_texture.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(specular_color, "SpecularColor", "", float3(1, 1, 1));
#include "used_float3.fxh"

#if defined(DO_WATER_REFRACTION)

	// Refraction settings
	DECLARE_FLOAT_WITH_DEFAULT(refraction_texcoord_shift,   "Refraction Texcoord Shift",   "", 0, 1, float(0.03));
	#include "used_float.fxh"
	
		DECLARE_FLOAT_WITH_DEFAULT(diffuse_texcoord_shift,   "Diffuse Texcoord Shift",   "", 0, 1, float(0.03));
	#include "used_float.fxh"
	
	DECLARE_FLOAT_WITH_DEFAULT(refraction_extinct_distance, "Refraction Extinct Distance", "", 0, 100, float(30));
	#include "used_float.fxh"

	DECLARE_RGB_COLOR_WITH_DEFAULT(stream_bed_mult, "Stream Bed Tint", "", float3(1, 1, 1));
	#include "used_float3.fxh"
	DECLARE_FLOAT(water_murkiness, "", "", 0, 1);
	#include "used_float.fxh"

	// refraction edge fade
	DECLARE_BOOL_WITH_DEFAULT(do_uv_refraction_fade,    "Do UV Refraction Fade", "", true);
	#include "next_bool_parameter.fxh"
	DECLARE_FLOAT_WITH_DEFAULT(refraction_fade_start_u, "Opacity Refraction Fade Start U","do_uv_refraction_fade", 0, 1, float(0.0));
	#include "used_float.fxh"
	DECLARE_FLOAT_WITH_DEFAULT(refraction_fade_end_u,   "Opacity Refraction Fade End U",  "do_uv_refraction_fade", 0, 1, float(1.0));
	#include "used_float.fxh"


#endif

DECLARE_FLOAT_WITH_DEFAULT(sun_x, "Light 1         X", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(sun_y, "Light 1         Y", "", 0, 1, float(1.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(sun_z, "Light 1         Z", "", 0, 1, float(0.0));
#include "used_float.fxh"

DECLARE_FLOAT_WITH_DEFAULT(sun_intensity, "Light 1      Int", "", 0, 100, float(1.0));
#include "used_float.fxh"

DECLARE_RGB_COLOR_WITH_DEFAULT(sun_color, "Light 1  Color", "", float3(1,1,1));
#include "used_float3.fxh"

// Foam settings
DECLARE_SAMPLER(foam_texture,        "Foam Texture", "Foam Texture", "");
#include "next_texture.fxh"
DECLARE_FLOAT_WITH_DEFAULT(foam_speed,           "Foam Speed", "", 0, 1, float(1.0));
#include "used_float.fxh"
DECLARE_FLOAT_WITH_DEFAULT(foam_intensity,        "Foam Intensity", "", 0, 1, float(1.0));
#include "used_float.fxh"


/// ======================================================================================================


#include "water_tessellation.fxh"

// fresnel approximation
float compute_fresnel(
			float3 incident,
			float3 normal,
			float r0,
			float r1)
{
 	float eye_dot_normal=	saturate(dot(incident, normal));
	eye_dot_normal=			saturate(r1 - eye_dot_normal);
	return saturate(r0 * eye_dot_normal * eye_dot_normal);			//pow(eye_dot_normal, 2.5);
}

float compute_fog_transparency(
			float murkiness,
			float negative_depth)
{
	return saturate(exp2(murkiness * negative_depth));
}


float compute_fog_factor(
			float murkiness,
			float depth)
{
	return 1.0f - compute_fog_transparency(murkiness, -depth);
}


#if defined(xenon)

////////////////////////////////////////////////////////////////////////////////
/// Water pass vertex shaders
////////////////////////////////////////////////////////////////////////////////


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
}


// transform vertex position, normal etc according to wave
s_water_interpolators transform_vertex(
	s_water_render_vertex IN,
	uniform bool tessellated,
	uniform bool interaction)
{
	//	vertex to eye displacement

	float mipmap_level= 0;//max(incident_ws.w / wave_visual_damping_distance, 0.0f);

	// calculate displacement of vertex
	float4 position= IN.position;
	float water_height_relative= 0.0f;
	float max_height_relative= 1.0f;

	float4 original_texcoord= IN.texcoord;
	float2 texcoord_ripple= 0.0f;
	float waterIntensity = IN.normal.w;

	if (tessellated)
	{
		// consider interaction	after displacement
		if (interaction)
		{
			texcoord_ripple= calculate_ripple_coordinate_by_world_position(position.xy);
			float4 ripple_hei= tex2Dlod(tex_ripple_buffer_slope_height_vs, float4(texcoord_ripple.xy, 0, 0));

			float ripple_height= ripple_hei.r*2.0f - 1.0f;

			// low down ripple for shallow water
			ripple_height*= displacement_scale * waterIntensity;

			position+= IN.normal * ripple_height;
		}
	}
	else if (interaction)
	{
		// get ripple texcoord
		texcoord_ripple= calculate_ripple_coordinate_by_world_position(IN.position.xy);
	}

	s_water_interpolators OUT;

	float4 incident_ws;
	incident_ws.xyz= position.xyz - vs_view_camera_position;
	incident_ws.w= dot(vs_view_camera_backward, vs_view_camera_position - position.xyz);
	incident_ws.xyz= normalize(incident_ws.xyz);	
	
	OUT.position    = mul( float4(position.xyz, 1.0), vs_view_view_projection_matrix );
	OUT.texcoord    = float4(original_texcoord.xyz, mipmap_level);
	OUT.normal      = IN.normal;
	OUT.tangent     = IN.tangent;
	OUT.binormal    = IN.binormal;
	OUT.position_ss = OUT.position;
	OUT.incident_ws = incident_ws;
	OUT.position_ws = position;
	OUT.base_tex    = float4(IN.base_tex.xy, water_height_relative, max_height_relative);
	OUT.lm_tex      = float4(IN.lm_tex.xy, texcoord_ripple);

	return OUT;
}




float2 restore_slope(
			float2 slope)
{
	slope-= 0.5f;
	return slope;
}

float2 compute_detail_slope(
			float2 base_texcoord,
			float4 base_texture_xform,
			float slope_time,
			float mipmap_level)
{
	float2 slope_detail= 0.0f;
	/*
	if ( TEST_CATEGORY_OPTION(detail, repeat) )
	{
		float4 wave_detail_xform= base_texture_xform * float4(detail_slope_scale_x, detail_slope_scale_y, 1, 1);
		float4 texcoord_detail= float4(transform_texcoord(base_texcoord, wave_detail_xform),  displacement_time*detail_slope_scale_z, mipmap_level);
		asm{
			tfetch3D slope_detail.xy, texcoord_detail.xyz, wave_slope_array, MagFilter= linear, MinFilter= linear, MipFilter= linear, VolMagFilter= linear, VolMinFilter= linear
		};
		slope_detail= restore_slope(slope_detail);
	}
*/
	return slope_detail;
}



float3 blend_udn(float3 n1, float3 n2)
{
    float3 c = float3(2, 1, 0);
    float3 r;
    r = n2*c.yyz + n1.xyz;
    r =  r*c.xxx -  c.xxy;
    return normalize(r);
}

// shade water surface ---------------------------------------------------------------------------------------------------------
float4 water_shading(
	s_water_interpolators INTERPOLATORS,
	uniform bool refraction,
	uniform bool interaction)
{
	float3 output_color= 0;

	// interaction
	float2 ripple_slope= 0.0f;

	if (interaction)
	{
		float2 texcoord_ripple= INTERPOLATORS.lm_tex.zw;
		float4 ripple;
		asm {tfetch2D ripple, texcoord_ripple, tex_ripple_buffer_slope_height_ps, MagFilter= linear, MinFilter= linear};
		ripple_slope= (ripple.gb - 0.5f) * 6.0f;	// hack
		//ripple_foam_factor= ripple.a;
	}

	float ripple_slope_length = pow(saturate(abs(ripple_slope.r) +  abs(ripple_slope.g)), 3);

	float2 diffuse_map_uv  = transform_texcoord(INTERPOLATORS.texcoord.xy, diffuse_map_transform);
	float waterFade = 	sample2DGamma(diffuse_map, diffuse_map_uv).w;
	
	float3 slope_shading = float3(0,0,0);
	slope_shading.xy = ripple_slope;
	
	slope_shading.z = sqrt(saturate(1.0f + dot(ripple_slope.xy, -ripple_slope.xy)));
	slope_shading = normalize(slope_shading);
	float3x3 tangent_frame_matrix = { INTERPOLATORS.tangent.xyz, INTERPOLATORS.binormal.xyz, INTERPOLATORS.normal.xyz };
	
	
	float2 uv = INTERPOLATORS.texcoord.xy;
	float4 flow = (sample2D(flow_map, uv)) ;
	float foam_mask = flow.b + ripple_slope_length;
	
	flow = flow*2 -1;
	
	flow.rgb = normalize((flow.r*INTERPOLATORS.tangent.xyz) + (flow.g*INTERPOLATORS.binormal.xyz) + (1*INTERPOLATORS.normal.xyz));
	flow.rgb *= max_distort;
	//float max_distort =10;
	

	#if !defined(cgfx)
	float timeValue = ps_time.z;
#else
	float timeValue = frac(ps_time.x/600.0f);
#endif
	float time = ps_time.x;
	float2 noise_map_uv 	   = transform_texcoord(uv, noise_map_transform);
	float noise = sample2D(noise_map, noise_map_uv ).r;
	float phase = (noise * noise_strength + time ) * water_speed ;
	float phase0 = (phase - floor(phase ) )  ;
	float phase1 = (phase   + .5 - floor(phase  + .5))  ;
	
	float2 wave_normal_uv 	   = transform_texcoord(uv, wave_normal_map_transform);
	//float4 water_detail_map = sample2D(wave_normal_map, (wave_normal_uv) - (float2(flow.r , flow.g   ) * phase0 ) * .005);
	//float4 water_detail_map2 = sample2D(wave_normal_map, (wave_normal_uv) - (float2(flow.g , -flow.r  ) * phase1 ) * .005 );

	//float4 water_detail_map = sample2D(wave_normal_map, (wave_normal_uv - phase0 * float2(flow.r , -flow.g   ) *water_speed) );
	float3 water_detail_map = sample_2d_normal_approx(wave_normal_map, (wave_normal_uv + phase0 * float2(flow.r , -flow.g ) ) );
	float3 water_detail_map2 = sample_2d_normal_approx(wave_normal_map, (wave_normal_uv + phase1 * float2(flow.r , -flow.g ) ) );//* float2(flow.r , -flow.g   ) *water_speed;

	float flowLerp =  2 * abs(phase0 - 0.5);
	
	water_detail_map = lerp(water_detail_map, water_detail_map2, flowLerp) * water_detail_intensity * waterFade * length(float3(flow.r ,flow.g,0));
	float3 worldNormal = sample_2d_normal_approx(macro_normal_map, uv).rgb ;
	//worldNormal.xy *=2 ;
	worldNormal.xy +=  water_detail_map.rg ;
	worldNormal.xy += ripple_slope;
	
	
	
	//float2 macro_normal_uv   = transform_texcoord(INTERPOLATORS.texcoord.xy, macro_normal_map_transform);
    //float3 macro_normal = sample_2d_normal_approx(macro_normal_map, macro_normal_uv);
	float3 normal = mul(worldNormal, tangent_frame_matrix);
	normal = normalize(normal);			// Do we need to renormalize?


	///////////////////////////////////////////////////////////////////////////
	/// Alpha map
	///////////////////////////////////////////////////////////////////////////
#if defined(DO_ALPHA_MAP)

	float2 alpha_map_uv = transform_texcoord(INTERPOLATORS.texcoord.xy, alpha_map_transform);
	float4 alpha_map_val = sample2DGamma(alpha_map, alpha_map_uv);

#endif


	///////////////////////////////////////////////////////////////////////////
	/// Fade Effects
	///////////////////////////////////////////////////////////////////////////

	///////////////////////////////////////////////////////////////////////////
	/// Lighting
	///////////////////////////////////////////////////////////////////////////
	float3 lightmap_intensity= 1.0f;


	lightmap_intensity = sample_lightprobe_texture_intensity_only(INTERPOLATORS.lm_tex.xy);


	///////////////////////////////////////////////////////////////////////////
	/// Water Color
	///////////////////////////////////////////////////////////////////////////
	float3 water_color = float3(1,1,1);;
	water_color *= lightmap_intensity;


	///////////////////////////////////////////////////////////////////////////
	/// Refraction
	///////////////////////////////////////////////////////////////////////////
	float3 color_refraction = water_color;
	float3 color_refraction_bed = water_color;

#if defined(DO_WATER_REFRACTION)
	float2 bump = 0.0f;
	if (refraction)
	{
		// calcuate texcoord in screen space
		INTERPOLATORS.position_ss/= INTERPOLATORS.position_ss.w;
		float2 texcoord_ss= INTERPOLATORS.position_ss.xy;
		texcoord_ss= texcoord_ss / 2 + 0.5;
		texcoord_ss.y= 1 - texcoord_ss.y;
		texcoord_ss= k_ps_water_player_view_constant.xy + texcoord_ss*k_ps_water_player_view_constant.zw;

	// modify refraction lookup based on depth - not working

		float2 texcoord_refraction = texcoord_ss + water_detail_map * refraction_texcoord_shift;

		float2 delta = 0.001f;	//###xwan avoid fetch back pixel, it could be considered into k_ps_water_player_view_constant
		texcoord_refraction= clamp(texcoord_refraction,
					   k_ps_water_player_view_constant.xy + delta,
					   k_ps_water_player_view_constant.xy + k_ps_water_player_view_constant.zw - delta);

		// ###xwan this comparision need to some tolerance to avoid dirty boundary of refraction
		color_refraction = Sample2DOffset(tex_ldr_buffer, texcoord_refraction, 0.5, 0.5);
		color_refraction /= ps_view_exposure.r;
		color_refraction_bed = color_refraction;	// store the pure color of under water stuff

	}
#endif


	///////////////////////////////////////////////////////////////////////////
	/// Basic diffuse lighting
	///////////////////////////////////////////////////////////////////////////
	// compute diffuse by n dot l
	float3 sun_dir_ws= normalize(float3(sun_x, sun_y, sun_z));;	//	sun direction
	float n_dot_l= saturate(dot(sun_dir_ws, normal));
	float3 color_diffuse= n_dot_l;
	
			
	float4 diffuse_map_val = sample2DGamma(diffuse_map, diffuse_map_uv + water_detail_map.rg * diffuse_texcoord_shift);
	color_diffuse = lerp(float3(0,0,0), diffuse_map_val, diffuse_map_mix);
	
	

	///////////////////////////////////////////////////////////////////////////
	/// Reflection
	///////////////////////////////////////////////////////////////////////////
	float3 color_reflection = 0;
	
	float3 specular = 0.0f;
#if defined(DO_WATER_REFLECTION)

	float3 reflect_dir = reflect(INTERPOLATORS.incident_ws.xyz, normal);

	// sample environment map
	float4 environment_sample;
	environment_sample = pow(texCUBE(reflection_map, reflect_dir), 2.2);

	float3 H = normalize(sun_dir_ws.xyz - INTERPOLATORS.incident_ws.xyz);
	float NdotH = saturate(dot(H, normal));

	float exponent = pow(2048, water_roughness);
	float NdotL = saturate(dot(sun_dir_ws.xyz ,normal));
	//specular+= specular_mask * blinnPower * intensity * direction_specular_scalar.w;
 
	specular += ((float3(1,1,1) + exponent) / float3(8,8,8)) * (pow(NdotH, exponent)) * NdotL * FresnelSchlick(specular_color, sun_dir_ws.xyz, H) * sun_intensity * sun_color ;// * blinnPower * intensity * direction_specular_scalar.w;

	color_reflection = environment_sample.rgb * reflection_intensity ;

#endif


	///////////////////////////////////////////////////////////////////////////
	/// Fresnel
	///////////////////////////////////////////////////////////////////////////
	// computer fresnel and output color
	float3 fresnel = FresnelSchlick(specular_color, -INTERPOLATORS.incident_ws.xyz , normal);
	// blend in reflection with fresnel
	output_color = (color_reflection * fresnel + specular) * lightmap_intensity;

	INTERPOLATORS.position_ss/= INTERPOLATORS.position_ss.w;
	float2 texcoord_ss= INTERPOLATORS.position_ss.xy;
	texcoord_ss= texcoord_ss / 2 + 0.5;
	texcoord_ss.y= 1 - texcoord_ss.y;
	texcoord_ss= k_ps_water_player_view_constant.xy + texcoord_ss*k_ps_water_player_view_constant.zw;

	//	calculate water depth
	float depth = sample2D(tex_depth_buffer, texcoord_ss).r;
	
	// convert to real depth
	//depth = 1.0f - depth.x;
	//depth = 1.0f / (psDepthConstants.x + depth * psDepthConstants.y);	
	depth = 1.0f / ((psDepthConstants.x + psDepthConstants.y) - psDepthConstants.y * depth.x);
	

	///Depth factor
	float depthEdgeAmount = 0.0;
	float deltaDepth = depth - INTERPOLATORS.incident_ws.w;
	depthEdgeAmount = saturate(deltaDepth / depth_edge_range);
	depthEdgeAmount = depthEdgeAmount * depthEdgeAmount;//we square it to correct the perspective in the general case...
	
	float murk = 1-saturate(depth * murk_multiplier);
	

	
	// add diffuse
	output_color = color_diffuse + output_color;
	//waterFade *= (depthEdgeAmount);
	///////////////////////////////////////////////////////////////////////////
	/// Foam
	///////////////////////////////////////////////////////////////////////////


	float4 foam_color = 0.0f;

	// compute foam
	float foam_factor = foam_intensity;
	foam_factor *= min(max(20 / INTERPOLATORS.incident_ws.w, 0.0f), 1.0f);

	float2 foam_texture_uv = transform_texcoord(INTERPOLATORS.texcoord.xy , foam_texture_transform);
	float foam_phase = (  noise * noise_strength +time) * foam_speed   ;
	float foam_phase0 = (foam_phase - floor(foam_phase ) )  ;
	float foam_phase1 = (foam_phase   + .5 - floor(foam_phase  + .5))   ;

	float foam_flowLerp =  2 * abs(foam_phase0 - 0.5);		
	
	float4 foam = sample2D(foam_texture, (foam_texture_uv +  foam_phase0 * float2(flow.r , -flow.g )));
	float4 foam2 = sample2D(foam_texture, (foam_texture_uv +  foam_phase1 * float2(flow.r , -flow.g )) );

	foam = lerp(foam, foam2, foam_flowLerp) ;
	foam_color.rgb  = foam.rgb ; // * foam_colormult;
	foam_color.a = foam.a;
	foam_color.rgb *= lightmap_intensity;
	foam_color.rgb *= foam_intensity;
	foam_color.a *= foam_mask;

	// foam - A over B
	output_color.rgb = lerp(output_color.rgb, foam_color, foam_color.a);


	//output_color.rgb = lightmap_intensity * float3(1,1,1);
	
	///////////////////////////////////////////////////////////////////////////
	/// Output
	///////////////////////////////////////////////////////////////////////////
	if (refraction)
	{
		// Fade between the water bed color and the 'full effects' color
		output_color = lerp(color_refraction_bed, output_color, waterFade);
		return apply_exposure(float4(output_color, 1), true);
	}
	else
	{
		return apply_exposure(float4(output_color , waterFade), true);
	}
}


// Vertex shaders for the water pass

s_water_interpolators water_vs(
	in s_vertex_type_water_shading input,
	uniform bool tessellated,
	uniform bool interaction)
{
	s_water_render_vertex output = GetWaterVertex(input, tessellated);
	return transform_vertex(output, tessellated, interaction);
}

// Pixel shaders for the water pass

float4 water_ps(
	in const s_water_interpolators INTERPOLATORS,
	uniform bool alphaBlend,
	uniform bool interaction) : COLOR0
{
	return water_shading(INTERPOLATORS, !alphaBlend, interaction);
}


#else

float4 water_vs(
	uniform bool tessellated,
	uniform bool interaction) : POSITION
{
	return 0;
}

// Build vertex shaders for the water pass


float4 water_ps(
	uniform bool alphaBlend,
	uniform bool interaction) : COLOR0
{
	return float4(0,0,1,0);
}


#endif



#if !defined(cgfx)


// Mark this shader as water
#define MATERIAL_SHADER_ANNOTATIONS 	<bool is_water = true;>

#include "techniques_base.fxh"

// Build the techniques

#define MAKE_WATER_TECHNIQUE(tessellation, alpha_blend, interaction)							\
technique																						\
MATERIAL_SHADER_ANNOTATIONS																		\
{																								\
	pass water																					\
	{																							\
		SET_VERTEX_SHADER(water_vs(tessellation, interaction));                                 \
		SET_PIXEL_SHADER(water_ps(alpha_blend, interaction));                                   \
	}																							\
}

// was
//		VertexShader=	compile vs_3_0 water_vs(tessellation, interaction);						
//		PixelShader=	compile ps_3_0 water_ps(alpha_blend, interaction);						


// Tessellated water entrypoints
MAKE_WATER_TECHNIQUE(true, false, false)		// tessellated, refractive, non-interactive
MAKE_WATER_TECHNIQUE(true, true, false)			// tessellated, blended, non-interactive
MAKE_WATER_TECHNIQUE(true, false, true)			// tessellated, refractive, interactive
MAKE_WATER_TECHNIQUE(true, true, true)			// tessellated, blended, interactive

// Non-tessellated entrypoints
MAKE_WATER_TECHNIQUE(false, false, false)		// untessellated, refractive, non-interactive
MAKE_WATER_TECHNIQUE(false, true, false)		// untessellated, blended, non-interactive
MAKE_WATER_TECHNIQUE(false, false, true)		// untessellated, refractive, interactive
MAKE_WATER_TECHNIQUE(false, true, true)			// untessellated, blended, interactive

#else


struct s_shader_data {
	s_common_shader_data common;

};

void pixel_pre_lighting(
            in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float2 diffuse_map_uv  = transform_texcoord(pixel_shader_input.texcoord.xy, diffuse_map_transform);
	float4 diffuse_map_val = sample2DGamma(diffuse_map, diffuse_map_uv);

	shader_data.common.albedo = diffuse_map_val;

	shader_data.common.normal = shader_data.common.tangent_frame[2];
}

float4 pixel_lighting(
	        in s_pixel_shader_input pixel_shader_input,
            inout s_shader_data shader_data)
{
	float3 output_color= 0;

	float3 normal = shader_data.common.normal;


	///////////////////////////////////////////////////////////////////////////
	/// Alpha map
	///////////////////////////////////////////////////////////////////////////
#if defined(DO_ALPHA_MAP)

	float2 alpha_map_uv = transform_texcoord(pixel_shader_input.texcoord.xy, alpha_map_transform);
	float4 alpha_map_val = sample2DGamma(alpha_map, alpha_map_uv);

#endif


	///////////////////////////////////////////////////////////////////////////
	/// Fade Effects
	///////////////////////////////////////////////////////////////////////////
	float waterFade = 1.0f;

#if !defined(DISABLE_VERTEX_COLOR)
	waterFade = shader_data.common.vertexColor.a;
#endif

#if defined(DO_WATER_EDGE_FADE)
	// since our depth is not always great, give an option to find edges with UVs
	// Alpha fade - do this first as we use this for fake water depth
	if (do_uv_edge_fade)
	{
		// normalize with 0 in center, 1 at edge
		float norm_u = 2 * abs(pixel_shader_input.texcoord.x - 0.5);
		waterFade *= (1 - smoothstep(edge_fade_start_u, edge_fade_end_u, norm_u));
	}
#endif


#if defined(DO_WATER_ALPHA_FADE)

	// Use the alpha map to fade effects
	waterFade *= alpha_map_val.a;

#endif


	///////////////////////////////////////////////////////////////////////////
	/// Water Color
	///////////////////////////////////////////////////////////////////////////
	float3 water_color = float3(1,1,1);



	///////////////////////////////////////////////////////////////////////////
	/// Basic diffuse lighting
	///////////////////////////////////////////////////////////////////////////
	// compute diffuse by n dot l
	float3 water_kd= water_diffuse;
	float3 sun_dir_ws= float3(0.0, 0.0, 1.0);	//	sun direction

	float n_dot_l= saturate(dot(sun_dir_ws, normal));
	float3 color_diffuse= water_kd * n_dot_l;

	


	///////////////////////////////////////////////////////////////////////////
	/// Reflection
	///////////////////////////////////////////////////////////////////////////
	float3 color_reflection = 0;

	// calculate reflection direction
	float3 reflectionNormal = normal * reflection_normal_intensity;
	reflectionNormal.z = sqrt(saturate(1.0f + dot(reflectionNormal.xy, -reflectionNormal.xy)));
	reflectionNormal = normalize(mul(reflectionNormal, shader_data.common.tangent_frame));

	float3 reflect_dir = reflect(-shader_data.common.view_dir_distance.xyz, reflectionNormal);

	// sample environment map
	float4 environment_sample;
	environment_sample = texCUBE(reflection_map, reflect_dir);

	color_reflection = environment_sample.rgb * reflection_intensity;


	///////////////////////////////////////////////////////////////////////////
	/// Fresnel
	///////////////////////////////////////////////////////////////////////////
	// computer fresnel and output color
	float3 fresnel = FresnelSchlick(specular_color,  shader_data.common.view_dir_distance.xyz , normal);
	// blend in reflection with fresnel
	output_color = water_color + color_reflection* fresnel;

	// add diffuse
	output_color = output_color + color_diffuse;
	//output_color.rgb = float3(1,0,0);

	return float4(output_color, waterFade);
}


#include "techniques_cgfx.fxh"

#endif

