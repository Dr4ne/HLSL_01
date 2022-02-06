// Standard shader with triplanar mapping
// https://github.com/keijiro/StandardTriplanar

Shader "Tri/SH_Triplanar_02"
{
    Properties
    {
		_DiffuseMap ("Map 01 ", 2D)  = "black" {}
		_RockMap ("Map 02", 2D) = "black" {}
		_TextureScale ("Texture Scale",float) = 1
		_TriplanarBlendSharpness ("Blend Sharpness",float) = 1
		_ShadowMultiplier ("Lambert shading multiplier", float) = 5
		_blendBias ("Bias", Vector) = (0,0,0,0)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
		Tags {"LightMode"="ForwardBase"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma shader_feature _NORMALMAP
			#pragma shader_feature _OCCLUSIONMAP
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc" 
			//#include "AutoLight.cginc"
			//#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

            sampler2D _DiffuseMap;
			sampler2D _RockMap;
            float4 _MainTex_ST;		
			float _TextureScale;
			float _TriplanarBlendSharpness;
			float _ShadowMultiplier;
			float4 _blendBias;

            struct VertexInput
            {
                float4 vertex : POSITION;
				float4 normal : NORMAL;
                float2 uv : TEXCOORD0;	
				//SHADOW_COORDS(1)
				
            };

            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
				float4 worldPos : TEXCOORD1;
				float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
				fixed4 diff : COLOR0;
            };


            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex );
				o.normal = v.normal;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.diff = _LightColor0;
				//TRANSFER_SHADOW(o)
				
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target
            {
				float3 worldPos = i.worldPos;
				//float3 worldNormal = mul(unity_ObjectToWorld,  i.normal);
				float3 worldNormal = UnityObjectToWorldNormal(i.normal);

				//fixed shadow = SHADOW_ATTENUATION(i);
				// standard diffuse (Lambert) lighting
				half nl = max(.4, dot(worldNormal, _WorldSpaceLightPos0.xyz));
				// factor in the light color
                i.diff = (nl * _ShadowMultiplier) * _LightColor0; // * shadow;
			

				// Find our UVs for each axis based on world position of the fragment.
				half2 yUV = worldPos.xz / _TextureScale;
				half2 xUV = worldPos.zy / _TextureScale;
				half2 zUV = worldPos.xy / _TextureScale;
				// Now do texture samples from our diffuse map with each of the 3 UV set's we've just made.
				half4 yDiff = tex2D (_RockMap, yUV);
				half4 xDiff = tex2D (_DiffuseMap, xUV);
				half4 zDiff = tex2D (_DiffuseMap, zUV);
				// Get the absolute value of the world normal.
				// Put the blend weights to the power of BlendSharpness, the higher the value, 
			    // the sharper the transition between the planar maps will be.
				worldNormal = normalize(worldNormal + _blendBias.xyz);
				half3 blendWeights = pow(abs(worldNormal), _TriplanarBlendSharpness);
				// Divide our blend mask by the sum of it's components, this will make x+y+z=1
				blendWeights = blendWeights / (blendWeights.x + blendWeights.y + blendWeights.z);
				// Finally, blend together all three samples based on the blend mask.

				

				fixed4 col = (xDiff * blendWeights.x + yDiff * blendWeights.y + zDiff * blendWeights.z);
				//col = col *= (i.diff * _ShadowMultiplier);
				col = col *= i.diff ;
				//col.xyz = blendWeights;
                return col;
            }
            ENDCG
        }
		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
