Shader "Grass/SH_grass_animated_V4"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_ColorTint("ColorTint", Color) = (1,1,1,1)
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5

		_WindFrecuency("Wind Frecuency",Range(0.001,100)) = 1
		_WindStrength("Wind Strength", Range( 0, 2 )) = 0.3
		_WindGustDistance("Distance between gusts",Range(0.001,50)) = .25
		_WindDirection("Wind Direction", vector) = (1,0, 1,0)
    }
    SubShader
    {

		//Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" "IgnoreProjector"="True" }

        LOD 100


        Pass
        {


			//AlphaToMask On

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			//#pragma alphatest:_Cutoff addshadow
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing
			#include "UnityCG.cginc"

			sampler2D _MainTex;
            float4 _MainTex_ST;


			half _WindFrecuency;
			half _WindGustDistance;
			half _WindStrength;
			float3 _WindDirection;
			float _Cutoff;


            struct VertextInput			
            {
                float4 VertexInputPos : POSITION;
                float2 uv : TEXCOORD0;	
                UNITY_VERTEX_INPUT_INSTANCE_ID			
            };

            struct VertexOutput
            {
                float4 VertexOutputPos : SV_POSITION;
                float2 uv : TEXCOORD1;	
                UNITY_VERTEX_INPUT_INSTANCE_ID		
            };
			
            UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
            UNITY_INSTANCING_BUFFER_END(Props)

            VertexOutput vert (VertextInput v)
            {
                VertexOutput o;	
				float4 localSpaceVertex = v.VertexInputPos;
				float4 worldSpaceVertex = mul( unity_ObjectToWorld, localSpaceVertex );
				
				float3 baseWorldPos = mul( unity_ObjectToWorld, float4(0,0,0,1) );
				float offset = dot(baseWorldPos.xz,_WindDirection.xz);
				worldSpaceVertex.x += sin(offset + _Time.x * _WindFrecuency + worldSpaceVertex.x * _WindGustDistance) * v.uv.y * _WindStrength * _WindDirection.x;
				worldSpaceVertex.z += sin(offset + _Time.x * _WindFrecuency + worldSpaceVertex.z * _WindGustDistance) * v.uv.y * _WindStrength * _WindDirection.z;
				
				v.VertexInputPos = mul( unity_WorldToObject, worldSpaceVertex );

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.VertexOutputPos = UnityObjectToClipPos(v.VertexInputPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (VertexOutput i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                fixed4 col = tex2D(_MainTex, i.uv);
				//clip(col.a - _Cutoff);
				if(col.a < _Cutoff) discard;

				return col;               
            }
            ENDCG
        }
		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
