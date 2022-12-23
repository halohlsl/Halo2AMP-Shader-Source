#if !defined(__CA_DEPTH_ACCESS_FXH)
#define __CA_DEPTH_ACCESS_FXH

#include "depth_fade_registers.fxh"

#if defined(xenon) || (DX_VERSION == 11)
	void sampleDepth(in float2 uv, inout float depth)
	{
		float4 s;
#if defined(xenon)
		asm
		{
			tfetch2D s, uv, depthSampler, UnnormalizedTextureCoords=true
		};
#else
		int3 intScreenCoords = int3(uv, 0);
		s = psDepthSampler.t.Load(intScreenCoords);
#endif
		// convert to real depth
		depth = 1.0f - s.x;
		depth = 1.0f / (psDepthConstants.x + depth * psDepthConstants.y);	
	}
#endif

#endif //__CA_DEPTH_ACCESS_FXH
