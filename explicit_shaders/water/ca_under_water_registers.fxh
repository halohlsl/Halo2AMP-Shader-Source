#if DX_VERSION == 9

VERTEX_CONSTANT(float4, k_vs_ripple_memexport_addr, 130)
VERTEX_CONSTANT(float, k_vs_ripple_pattern_count, 132)

VERTEX_CONSTANT(float4, hidden_from_compiler, 135)

VERTEX_CONSTANT(float, k_vs_ripple_real_frametime_ratio, 133)
VERTEX_CONSTANT(float, k_vs_ripple_particle_index_start, 138)
VERTEX_CONSTANT(float, k_vs_maximum_ripple_particle_number, 139)

VERTEX_CONSTANT(float3, k_vs_camera_position, 131)

SAMPLER_CONSTANT(tex_ripple_pattern, 0)
SAMPLER_CONSTANT(tex_ripple_buffer_height, 1)

PIXEL_CONSTANT(float4, k_ps_camera_position, 219)
PIXEL_CONSTANT(float, k_ps_underwater_murkiness, 220)
PIXEL_CONSTANT(float3, k_ps_underwater_fog_color, 221)

#elif DX_VERSION == 11

CBUFFER_BEGIN(WaterRippleVS)
	CBUFFER_CONST(WaterRippleVS,		float4,			k_vs_ripple_memexport_addr,					k_vs_water_ripple_memexport_addr)
	CBUFFER_CONST(WaterRippleVS,		float,			k_vs_ripple_pattern_count,					k_vs_water_ripple_pattern_count)
	CBUFFER_CONST(WaterRippleVS,		float3,			k_vs_ripple_pattern_count_pad,				k_vs_water_ripple_pattern_count_pad)
	CBUFFER_CONST(WaterRippleVS,		float4,			hidden_from_compiler,						k_vs_water_ripple_hidden_from_compiler)
	CBUFFER_CONST(WaterRippleVS,		float,			k_vs_ripple_real_frametime_ratio,			k_vs_water_ripple_real_frametime_ratio)
	CBUFFER_CONST(WaterRippleVS,		float3,			k_vs_ripple_real_frametime_ratio_pad,		k_vs_water_ripple_real_frametime_ratio_pad)
	CBUFFER_CONST(WaterRippleVS,		float,			k_vs_ripple_particle_index_start,			k_vs_water_ripple_particle_index_start)
	CBUFFER_CONST(WaterRippleVS,		float3,			k_vs_ripple_particle_index_start_pad,		k_vs_water_ripple_particle_index_start_pad)
	CBUFFER_CONST(WaterRippleVS,		float,			k_vs_maximum_ripple_particle_number,		k_vs_water_ripple_maximum_ripple_particle_number)
	CBUFFER_CONST(WaterRippleVS,		float3,			k_vs_maximum_ripple_particle_number_pad,	k_vs_water_ripple_maximum_ripple_particle_number_pad)
	CBUFFER_CONST(WaterRippleVS,		float3,			k_vs_camera_position,						k_vs_water_ripple_camera_position)
	CBUFFER_CONST(WaterRippleVS,		float,			k_vs_camera_position_pad,					k_vs_water_ripple_camera_position_pad)
CBUFFER_END

CBUFFER_BEGIN(WaterRipplePS)
	CBUFFER_CONST(WaterRipplePS,		float4,			k_ps_camera_position,						k_ps_water_ripple_camera_position)
	CBUFFER_CONST(WaterRipplePS,		float,			k_ps_underwater_murkiness,					k_ps_water_ripple_underwater_murkiness)
	CBUFFER_CONST(WaterRipplePS,		float3,			k_ps_underwater_fog_color,					k_ps_water_ripple_underwater_fog_color)
CBUFFER_END

#endif
