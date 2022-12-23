#if !defined(__LIGHTING_SPECULAR_MODELS_FXH)
#define __LIGHTING_SPECULAR_MODELS_FXH

#include "core/core_types.fxh"
#include "lighting/vmf.fxh"


////////////////////////////////////////////////////////////////////////////////
// Blinn specular model (half-angle)

#define PI_OVER_FOUR 0.7853975
#define PI_OVER_TWO 1.570795

void calc_specular_blinn_initializer(
	inout float3 specular,
	const in s_common_shader_data common,
	const in float3 normal,
	const in float specular_mask,
	const in float specular_power)
{
	specular = 0.0f;

#if (defined(xenon) || (DX_VERSION == 11)) && !defined(DISABLE_VMF)

	if (common.lighting_mode != LM_PER_PIXEL_FLOATING_SHADOW_SIMPLE && common.lighting_mode != LM_PER_PIXEL_SIMPLE)
	{
		float4 direction_specular_scalar = common.lighting_data.light_direction_specular_scalar[0];
		float3 intensity = common.lighting_data.light_intensity_diffuse_scalar[0].rgb;

		float3 H[3] = {
			(VMFGetVector(common.lighting_data.vmf_data, 0) - common.view_dir_distance.xyz),
			(VMFGetVector(common.lighting_data.vmf_data, 1) - common.view_dir_distance.xyz),
			(direction_specular_scalar.xyz - common.view_dir_distance.xyz) };

		// Get the cosines of the half-angles
		// The normal is normalized, so the results are the cosines of the half-angles times the magnitude of the half-angles
		float3 NdotH = float3(
			dot(H[0], normal),
			dot(H[1], normal),
			dot(H[2], normal));

		// Do some work in logarithmic space
		// log2 of NdotH * ||H|| values
		float3 blinnPower = log2(max(0, NdotH));

		// log2 of ||H||^2 values
		float3 rescale = log2(float3(dot(H[0], H[0]), dot(H[1], H[1]), dot(H[2], H[2])));

		// (NdotH * ||H|| / sqrt(||H||^2)) ^ specPower, divided by PI
		blinnPower = (blinnPower - 0.5 * rescale) * specular_power - log2(pi);

		// Back to linear space
		blinnPower = exp2(blinnPower);

		// The result of the exponential cannot be negative, so call the 'no clamp' evaluation to save time
		float3 vmfSpecular =
			VMFSpecularCustomEvaluateNoClamp(common.lighting_data.vmf_data, blinnPower.x, 0) +
			VMFSpecularCustomEvaluateNoClamp(common.lighting_data.vmf_data, blinnPower.y, 1);

		if (common.lighting_data.light_component_count > 0)
		{
			vmfSpecular += intensity * direction_specular_scalar.w * blinnPower.z;
		}

		specular += vmfSpecular * specular_mask;		// divide by pi is baked into power
	}

#endif
}

void calc_specular_blinn_inner_loop(
	inout float3 specular,
	const in s_common_shader_data common,
	const in float3 normal,
	const in float specular_mask,
	const in float specular_power,
	int index)
{
#if (defined(xenon) || (DX_VERSION == 11)) && !defined(DISABLE_VMF)
	if (index > 1)
#else
	if (index < common.lighting_data.light_component_count)
#endif
	{
		float4 direction_specular_scalar= common.lighting_data.light_direction_specular_scalar[index];
		float3 intensity= common.lighting_data.light_intensity_diffuse_scalar[index].rgb;

		float3 H = normalize(direction_specular_scalar.xyz - common.view_dir_distance.xyz);
		float NdotH = saturate(dot(H, normal));

		float blinnPower = log2(NdotH);
		blinnPower = blinnPower * specular_power - log2(pi);
		blinnPower = exp2(blinnPower);

		specular+= specular_mask * blinnPower * intensity * direction_specular_scalar.w;
	}
}

MAKE_ACCUMULATING_LOOP_3(float3, calc_specular_blinn, float3, float, float, MAX_LIGHTING_COMPONENTS);



////////////////////////////////////////////////////////////////////////////////
// Blinn Phong specular model (half-angle)
float3 FresnelSchlick(float3 SpecularColor, float3 E,float3 H)
{
	return SpecularColor + (1.0 - SpecularColor) * pow(1.0 - saturate(dot(E, H)), 5.0);
}
float3 FresnelSchlickWithRoughness(float3 SpecularColor, float3 E, float3 N, float Gloss)
{
    return SpecularColor + (max(Gloss, SpecularColor) - SpecularColor) * pow(1 - saturate(dot(E, N)), 5);
}
void calc_specular_blinnphong_initializer(
	inout float3 specular,
	const in s_common_shader_data common,
	const in float3 normal,
	const in float3 specular_color,
	const in float specular_power)
{
	specular = 0.0f;

#if (defined(xenon) || (DX_VERSION == 11)) && !defined(DISABLE_VMF)

	if (common.lighting_mode != LM_PER_PIXEL_FLOATING_SHADOW_SIMPLE && common.lighting_mode != LM_PER_PIXEL_SIMPLE)
	{
		float4 direction_specular_scalar = common.lighting_data.light_direction_specular_scalar[0];
		float3 intensity = common.lighting_data.light_intensity_diffuse_scalar[0].rgb;
		float3 view = normalize(common.view_dir_distance.xyz);
		float3 H[3] = {
			normalize(VMFGetVector(common.lighting_data.vmf_data, 0) - view),
			normalize(VMFGetVector(common.lighting_data.vmf_data, 1) - view),
			normalize(direction_specular_scalar.xyz - view) };

		// Get the cosines of the half-angles
		// The normal is normalized, so the results are the cosines of the half-angles times the magnitude of the half-angles
		float3 NdotH = float3(
			saturate(dot(H[0], normal)),
			saturate(dot(H[1], normal)),
			saturate(dot(H[2], normal)));

		float NdotV = saturate(dot(-view, normal));
			
		float exponent = pow(2048, specular_power);
		float half_exponent = pow(2048, specular_power/2);
		float3 power = float3(exponent, half_exponent, exponent);
		
		float3 L[3] = {normalize(VMFGetVector(common.lighting_data.vmf_data, 0)) ,
					   normalize(VMFGetVector(common.lighting_data.vmf_data, 1)),
					   normalize(direction_specular_scalar.xyz) };
						 
						 
		float3 NdotL = float3(
		saturate(dot(L[0], normal)),
		saturate(dot(L[1], normal)),
		saturate(dot(L[2], normal)));

		// visibility term 
		//float3 alpha = float3(1,1,1) / (sqrt(PI_OVER_FOUR * specular_power + PI_OVER_TWO));
		//float3 visibility_term = (NdotL * ( float3(1,1,1) - alpha) + alpha) * (NdotV * (float3(1,1,1) - alpha) + alpha);

		float3 alpha = specular_power/2 + 0.0001;
		float3 visibility_term = (NdotL/(NdotL * ( 1 - alpha) + alpha)) * (NdotV/(NdotV * (1 - alpha) + alpha));
		
		float3 spec = ((float3(2,2,2) + power )/ float3(8,8,8))  * visibility_term;

		// The result of the exponential cannot be negative, so call the 'no clamp' evaluation to save time
		float3 vmfSpecular =
			VMFSpecularCustomEvaluateNoClamp(common.lighting_data.vmf_data, spec.x, 0) * FresnelSchlickWithRoughness(specular_color, L[0].xyz, H[0], specular_power) * saturate(pow(NdotH[0], exponent)) ;
			+ 
			VMFSpecularCustomEvaluateNoClamp(common.lighting_data.vmf_data, spec.y, 1) * FresnelSchlickWithRoughness(specular_color, L[1].xyz, H[1], specular_power) * saturate(pow(NdotH[1], half_exponent));

		if (common.lighting_data.light_component_count > 0)
		{
			float3 dyn_spec = spec.z * FresnelSchlickWithRoughness(specular_color, L[2].xyz, H[2], specular_power) * saturate(pow(NdotH[2], exponent)) ;
			vmfSpecular += intensity * direction_specular_scalar.w * dyn_spec;
			
			
		}

		specular += vmfSpecular ;
		
	}

#endif
}

void calc_specular_blinnphong_inner_loop(
	inout float3 specular,
	const in s_common_shader_data common,
	const in float3 normal,
	const in float3 specular_color,
	const in float specular_power,
	int index)
{
#if (defined(xenon) || (DX_VERSION == 11)) && !defined(DISABLE_VMF)
	if (index > 1)
#else
	if (index < common.lighting_data.light_component_count)
#endif
	{
	
		
		float4 direction_specular_scalar= common.lighting_data.light_direction_specular_scalar[index];
		float3 intensity= common.lighting_data.light_intensity_diffuse_scalar[index].rgb;

		float3 H = normalize(direction_specular_scalar.xyz - common.view_dir_distance.xyz);
		float NdotH = saturate(dot(H, normal));
		float NdotV = saturate(dot(-common.view_dir_distance.xyz, normal));


		float exponent = pow(2048, specular_power);
		float NdotL = saturate(dot(direction_specular_scalar.xyz ,normal));

		float alpha = specular_power/2 + 0.0001;
		float visibility_term = (NdotL/(NdotL * ( 1 - alpha) + alpha)) * (NdotV/(NdotV * (1 - alpha) + alpha));
		
		specular+= ((float3(2,2,2) + exponent) / float3(8,8,8)) * visibility_term * (pow(NdotH, exponent)) * FresnelSchlickWithRoughness(specular_color, direction_specular_scalar.xyz, H, specular_power) * intensity * direction_specular_scalar.w;// * blinnPower * intensity * direction_specular_scalar.w;
	}
}

MAKE_ACCUMULATING_LOOP_3(float3, calc_specular_blinnphong, float3, float3, float, MAX_LIGHTING_COMPONENTS);

////////////////////////////////////////////////////////////////////////////////
// Subsurface Scattering 

void calc_subsurface_initializer(
	inout float3 subsurface,
	const in s_common_shader_data common,
	const in float3 normal,
	const in float3 distortion_power_scale,
	const in float2 thickness_warp
	)
{
	subsurface = 0.0f;

#if (defined(xenon) || (DX_VERSION == 11)) && !defined(DISABLE_VMF)

	if (common.lighting_mode != LM_PER_PIXEL_FLOATING_SHADOW_SIMPLE && common.lighting_mode != LM_PER_PIXEL_SIMPLE)
	{
		float4 direction_specular_scalar = common.lighting_data.light_direction_specular_scalar[0];
		float3 intensity = common.lighting_data.light_intensity_diffuse_scalar[0].rgb;

		float distortion = distortion_power_scale.x;
		float power = distortion_power_scale.y;
		float scale = distortion_power_scale.z;
		
		float3 vLTLight = direction_specular_scalar.xyz + normal * distortion;
		float fLTDot = saturate(pow(saturate(dot(common.view_dir_distance.xyz, vLTLight) + thickness_warp.y) , power)) * scale;
		subsurface += intensity * (fLTDot) * thickness_warp.x;
		
		float3 vLTLight2 = VMFGetVector(common.lighting_data.vmf_data, 0) + normal * distortion;
		float fLTDot2 = saturate(pow(saturate(dot(common.view_dir_distance.xyz, vLTLight2) + thickness_warp.y) , power)) * scale;
		subsurface += common.lighting_data.vmf_data.coefficients[0 * 2 + 1].rgb  * (fLTDot2) * thickness_warp.x;
		
		float3 vLTLight3 = VMFGetVector(common.lighting_data.vmf_data, 1) + normal * distortion;
		float fLTDot3 = saturate(pow(saturate(dot(common.view_dir_distance.xyz, vLTLight3) + thickness_warp.y) , power)) * scale;
		subsurface += common.lighting_data.vmf_data.coefficients[1 * 2 + 1].rgb  * (fLTDot3 ) * thickness_warp.x;
		

		
	}

#endif


}

void calc_subsurface_inner_loop(
	inout float3 subsurface,
	const in s_common_shader_data common,
	const in float3 normal,
	const in float3 distortion_power_scale,
	const in float2 thickness_warp,
	int index)
{
//subsurface = 0.0f;

#if (defined(xenon) || (DX_VERSION == 11)) && !defined(DISABLE_VMF)
	if (index > 1)
#else
	if (index < common.lighting_data.light_component_count)
#endif
	{
		float4 direction_specular_scalar= common.lighting_data.light_direction_specular_scalar[index];
		float3 intensity= common.lighting_data.light_intensity_diffuse_scalar[index].rgb;

		float distortion = distortion_power_scale.x;
		float power = distortion_power_scale.y;
		float scale = distortion_power_scale.z;
		
		float3 vLTLight = direction_specular_scalar.xyz + normal * distortion;
		float fLTDot = saturate(pow(saturate(dot(common.view_dir_distance.xyz, vLTLight) + thickness_warp.y), power)) * scale;
		subsurface += intensity * (fLTDot) * thickness_warp.x;
		
	}

}

MAKE_ACCUMULATING_LOOP_3(float3, calc_subsurface, float3, float3, float2,  MAX_LIGHTING_COMPONENTS);


////////////////////////////////////////////////////////////////////////////////
// Phong specular model

void calc_specular_phong_initializer(
	inout float3 specular,
	const in s_common_shader_data common,
	const in float3 normal,
	const in float specular_mask,
	const in float specular_power)
{
	specular = 0.0f;

#if (defined(xenon) || (DX_VERSION == 11)) && !defined(DISABLE_VMF)
	if (common.lighting_mode != LM_PER_PIXEL_FLOATING_SHADOW_SIMPLE && common.lighting_mode != LM_PER_PIXEL_SIMPLE)
	{
		specular += VMFSpecularPhong(common.lighting_data.vmf_data, normal, common.view_dir_distance.xyz, specular_mask, specular_power);
	}
#endif
}

// helper function for accumulating diffuse contribution
void calc_specular_phong_inner_loop(
	inout float3 specular,
	const in s_common_shader_data common,
	const in float3 normal,
	const in float specular_mask,
	const in float specular_power,
	int index)
{
	if (index < common.lighting_data.light_component_count)
	{
		float4 direction_specular_scalar = common.lighting_data.light_direction_specular_scalar[index];
		float3 intensity = common.lighting_data.light_intensity_diffuse_scalar[index].rgb;

		float3 R = reflect(-direction_specular_scalar.xyz, normal);
		float VdotR = saturate(dot(R, -common.view_dir_distance.xyz));

		float phongPower = log2(VdotR);
		phongPower = phongPower * specular_power - log2(pi);
		phongPower = exp2(phongPower);

		specular += specular_mask * phongPower * intensity * direction_specular_scalar.w;
	}
}

MAKE_ACCUMULATING_LOOP_3(float3, calc_specular_phong, float3, float, float, MAX_LIGHTING_COMPONENTS);




void calc_specular_ward_initializer(
	inout float3 specular,
	const in s_common_shader_data common,
	const in float3 normal,
	const in float specular_mask,
	in float2 aniso_roughness)
{
	specular = 0.0f;

#if (defined(xenon) || (DX_VERSION == 11)) && !defined(DISABLE_VMF)
	if (common.lighting_mode != LM_PER_PIXEL_FLOATING_SHADOW_SIMPLE && common.lighting_mode != LM_PER_PIXEL_SIMPLE)
	{
		specular += VMFSpecularWard(common, normal, specular_mask, aniso_roughness);
	}
#endif
}

//	float3


// helper function for accumulating diffuse contribution
void calc_specular_ward_inner_loop(
	inout float3 specular,
	const in s_common_shader_data common,
	const in float3 normal,
	const in float specular_mask,
	in float2 aniso_roughness,
	int index)
{
	if (index < common.lighting_data.light_component_count)
	{
		aniso_roughness += float2(1e-5f, 1e-5f );

		float4 direction_specular_scalar = common.lighting_data.light_direction_specular_scalar[index];
		float3 intensity = common.lighting_data.light_intensity_diffuse_scalar[index].rgb;

		float3 N	= normal;
		float3 L	= direction_specular_scalar.xyz;
		float3 V	= common.view_dir_distance.xyz;
		float3 H	= (L - V);					// No need to normalize, since we can divide by equal proportions later

		float VdotN = dot(V, N);
		float LdotN = dot(L, N);
		float HdotN = dot(H, N);

#if defined(ANISOTROPIC_WARD)

		float3 B	= normalize(cross(N, common.tangent_frame[0]));
		float3 T	= cross(B, N);
	    float HdotT = dot(H, T);
	    float HdotB = dot(H, B);

		 // Evaluate the specular exponent
		float betaA	= HdotT / aniso_roughness.x;
		float betaB	= HdotB / aniso_roughness.y;
		float beta	= -((betaA * betaA + betaB * betaB) / (HdotN * HdotN));

		// Evaluate the specular denominator
		float s_den	= sqrt(abs(LdotN * VdotN)) * aniso_roughness.x * aniso_roughness.y;

#else

		// Evaluate the specular exponent
		float rho	= (dot(H, H) - (HdotN * HdotN)) / (HdotN * HdotN);
		float beta	= -(rho) / (aniso_roughness.x * aniso_roughness.x);

		// Evaluate the specular denominator
		float s_den	= sqrt(abs(LdotN * VdotN)) * aniso_roughness.x * aniso_roughness.x;

#endif

#if defined(cgfx)
		s_den		= 1.0 / max(s_den, 1e-5f);
#else
		s_den		= 1.0 / s_den;
#endif

		// Effectively a divide by 4 * pi
		beta -= log(4.0 * pi + pi);

		specular	+= max((float3)0, exp(beta) * s_den * LdotN) * intensity * specular_mask * direction_specular_scalar.w;
	}
}

MAKE_ACCUMULATING_LOOP_3(float3, calc_specular_ward, float3, float, float2, MAX_LIGHTING_COMPONENTS);




////////////////////////////////////////////////////////////////////////////////
// hair specular model

float HairSpecular(const in float3 surface_direction,  const in float3 view, const in float3 light_direction, float power)
{
	float3 H =  normalize(light_direction-view);
	float HdotT = dot(H, surface_direction);
	float sinTH = sqrt(1.0 - HdotT * HdotT);
	float dirAtten = 1;//smoothstep(-1.0, 0.0, HdotT);	
	return dirAtten * pow(sinTH, power);
}

void calc_specular_hair_initializer(
	inout float3 specular,
	const in s_common_shader_data common,
	const in float3 direction,
	const in float specular_mask,
	const in float specular_power)
{
	specular = 0.0f;

	#if (defined(xenon) || (DX_VERSION == 11))
		if (common.lighting_mode != LM_PER_PIXEL_FLOATING_SHADOW_SIMPLE && common.lighting_mode != LM_PER_PIXEL_SIMPLE)
		{
			float4 direction_specular_scalar = common.lighting_data.light_direction_specular_scalar[0];
			float3 vmfSpecular = 0.0f;
			
			// removing vmf lighing unless requested by shader			
			#if defined (HAIR_SPECULAR_DIRECT)
				float specular_vmf_direct = HairSpecular(direction, common.view_dir_distance.xyz, VMFGetVector(common.lighting_data.vmf_data, 0), specular_power);
				vmfSpecular = VMFSpecularCustomEvaluate(common.lighting_data.vmf_data, specular_vmf_direct, 0);
			#endif
			
			#if defined (HAIR_SPECULAR_INDIRECT)
				float specular_vmf_indirect = HairSpecular(direction, common.view_dir_distance.xyz, VMFGetVector(common.lighting_data.vmf_data, 1), specular_power);
				vmfSpecular += VMFSpecularCustomEvaluate(common.lighting_data.vmf_data, specular_vmf_indirect, 1);
			#endif
			
			specular += vmfSpecular * specular_mask * direction_specular_scalar.w;		
		}
	#endif
}



void calc_specular_hair_inner_loop(
	inout float3 specular,
	const in s_common_shader_data common,
	const in float3 direction,	// the vector used to calc the asio look. Currently srf_char_hair passes in the binormal.
	const in float specular_mask,
	const in float specular_power,
	int index)
{
	float4  direction_specular_scalar = common.lighting_data.light_direction_specular_scalar[index];
	float3 intensity = common.lighting_data.light_intensity_diffuse_scalar[index].rgb;	

	float3 specular_result = HairSpecular(direction, common.view_dir_distance.xyz, direction_specular_scalar.xyz, specular_power);
	
	specular += specular_mask * intensity * direction_specular_scalar.w * specular_result;
}

MAKE_ACCUMULATING_LOOP_3(float3, calc_specular_hair, float3, float, float, MAX_LIGHTING_COMPONENTS);




#endif