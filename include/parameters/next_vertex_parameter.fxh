#if !defined(USER_VERTEX_PARAMETERS_DEFINED)
#define USER_VERTEX_PARAMETERS_DEFINED
#if DX_VERSION == 9
float4 user_vertex_parameter_240 : register(c240);
float4 user_vertex_parameter_241 : register(c241);
float4 user_vertex_parameter_242 : register(c242);
float4 user_vertex_parameter_243 : register(c243);
#elif DX_VERSION == 11
cbuffer UserParametersVS : register(b13)
{
	float4 user_vertex_parameter_240;
	float4 user_vertex_parameter_241;
	float4 user_vertex_parameter_242;
	float4 user_vertex_parameter_243;

	float4 user_vertex_parameter_244;
	float4 user_vertex_parameter_245;
	float4 user_vertex_parameter_246;
	float4 user_vertex_parameter_247;

};
#endif
#endif // !defined(USER_VERTEX_PARAMETERS_DEFINED)

#if defined(cgfx)

#define USER_VERTEX_PARAMETER_NEXT		241
#define USER_VERTEX_PARAMETER_CURRENT	240

#else // defined(cgfx)

#if !defined(USER_VERTEX_PARAMETER_SIZE)

#if defined(USER_VERTEX_PARAMETER_CURRENT)
#undef USER_VERTEX_PARAMETER_CURRENT
#undef USER_VERTEX_PARAMETER_NEXT
#endif // defined(USER_VERTEX_PARAMETER_CURRENT)
#define USER_VERTEX_PARAMETER_NEXT		241
#define USER_VERTEX_PARAMETER_CURRENT	240

#else // !defined(USER_VERTEX_PARAMETER_SIZE)

#if !defined(USER_VERTEX_PARAMETER_CURRENT)
#define USER_VERTEX_PARAMETER_NEXT		241
#define USER_VERTEX_PARAMETER_CURRENT	240
#elif USER_VERTEX_PARAMETER_CURRENT ==	240
#undef USER_VERTEX_PARAMETER_CURRENT
#undef USER_VERTEX_PARAMETER_NEXT
#define USER_VERTEX_PARAMETER_NEXT		242
#define USER_VERTEX_PARAMETER_CURRENT	241
#elif USER_VERTEX_PARAMETER_CURRENT ==	241
#undef USER_VERTEX_PARAMETER_CURRENT
#undef USER_VERTEX_PARAMETER_NEXT
#define USER_VERTEX_PARAMETER_NEXT		243
#define USER_VERTEX_PARAMETER_CURRENT	242
#elif USER_VERTEX_PARAMETER_CURRENT ==	242
#undef USER_VERTEX_PARAMETER_CURRENT
#undef USER_VERTEX_PARAMETER_NEXT
#define USER_VERTEX_PARAMETER_NEXT		244
#define USER_VERTEX_PARAMETER_CURRENT	243
#elif USER_VERTEX_PARAMETER_CURRENT ==	243
#undef USER_VERTEX_PARAMETER_CURRENT
#undef USER_VERTEX_PARAMETER_NEXT
#define USER_VERTEX_PARAMETER_NEXT		245
#define USER_VERTEX_PARAMETER_CURRENT	244
#elif USER_VERTEX_PARAMETER_CURRENT ==	244
#undef USER_VERTEX_PARAMETER_CURRENT
#undef USER_VERTEX_PARAMETER_NEXT
#define USER_VERTEX_PARAMETER_NEXT		246
#define USER_VERTEX_PARAMETER_CURRENT	245
#elif USER_VERTEX_PARAMETER_CURRENT ==	245
#undef USER_VERTEX_PARAMETER_CURRENT
#undef USER_VERTEX_PARAMETER_NEXT
#define USER_VERTEX_PARAMETER_NEXT		247
#define USER_VERTEX_PARAMETER_CURRENT	246
#elif USER_VERTEX_PARAMETER_CURRENT ==	246
#undef USER_VERTEX_PARAMETER_CURRENT
#undef USER_VERTEX_PARAMETER_NEXT
#define USER_VERTEX_PARAMETER_NEXT		248
#define USER_VERTEX_PARAMETER_CURRENT	247
#else
#error Too many user parameters
#endif

#endif // !defined(USER_VERTEX_PARAMETER_SIZE)

#undef USER_VERTEX_PARAMETER_CURRENT_HELPER
#undef USER_VERTEX_PARAMETER_CURRENT_REGISTER
#undef USER_VERTEX_PARAMETER_CURRENT_NAME
#undef USER_VERTEX_PARAMETER_NEXT_HELPER
#undef USER_VERTEX_PARAMETER_NEXT_REGISTER
#undef USER_VERTEX_PARAMETER_NEXT_NAME
#undef USER_VERTEX_PARAMETER_OFFSET

#endif // defined(cgfx)

#if DX_VERSION == 9

// Set up the register for the current parameter
#define USER_VERTEX_PARAMETER_CURRENT_HELPER(c)			BOOST_JOIN(c, USER_VERTEX_PARAMETER_CURRENT)
#define USER_VERTEX_PARAMETER_CURRENT_REGISTER			USER_VERTEX_PARAMETER_CURRENT_HELPER(user_vertex_parameter_)
#define USER_VERTEX_PARAMETER_CURRENT_NAME(name)		BOOST_JOIN(USER_VERTEX_PARAMETER_CURRENT_REGISTER, _##name) : register(USER_VERTEX_PARAMETER_CURRENT_HELPER(c))

// Set up the register for the next parameter (in case we need it)
#define USER_VERTEX_PARAMETER_NEXT_HELPER(c)			BOOST_JOIN(c, USER_VERTEX_PARAMETER_NEXT)
#define USER_VERTEX_PARAMETER_NEXT_REGISTER				USER_VERTEX_PARAMETER_NEXT_HELPER(user_vertex_parameter_)
#define USER_VERTEX_PARAMETER_NEXT_NAME(name)			BOOST_JOIN(USER_VERTEX_PARAMETER_NEXT_REGISTER, _##name) : register(USER_VERTEX_PARAMETER_NEXT_HELPER(c))

#elif DX_VERSION == 11

#define USER_VERTEX_PARAMETER_CURRENT_REGISTER			BOOST_JOIN(user_vertex_parameter_, USER_VERTEX_PARAMETER_CURRENT)
#define USER_VERTEX_PARAMETER_NEXT_REGISTER				BOOST_JOIN(user_vertex_parameter_, USER_VERTEX_PARAMETER_NEXT)

#endif

// Reset the offset to 0
#define USER_VERTEX_PARAMETER_OFFSET 0

#include "init_next_vertex_parameter.fxh"