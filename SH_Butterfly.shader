Shader "Unlit/SM_Butterfly"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_wingsSpeed ("Wings Speed", Range( 0, 500 )) = 100
    }
    SubShader
    {
        Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" "IgnoreProjector"="True" }
		//Tags { "RenderType"="Opaque" }
        LOD 100
		Cull Off

        Pass
        {
			AlphaToMask On

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing

			sampler2D _MainTex;
            float4 _MainTex_ST;
			float _wingsSpeed;

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
				float4 localSpaceVertex = v.vertex;
				//if(localSpaceVertex.x != 0.5)
				//{
				//	localSpaceVertex.y += sin(_Time.x * _wingsHeight);
				//}
				float x = abs(v.uv.x * 2.0f - 1.0f);
				//localSpaceVertex.y += sin(_Time.x * _wingsSpeed) * abs(localSpaceVertex.x);
				localSpaceVertex.y += sin(_Time.x * _wingsSpeed) * x * 0.01f;
				localSpaceVertex.y += cos(_Time.x * _wingsSpeed) * (1.0f - x) * 0.01f;


				//float2 mapping = v.uv.xy * 2 - 1;
				//o.uv = mapping;

				o.uv = v.uv;
                UNITY_SETUP_INSTANCE_ID(v);
                o.vertex = UnityObjectToClipPos(localSpaceVertex);
              
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
				//float4 col = abs(float4(i.uv.xy,0,1));
                return col;
            }
            ENDCG
        }
    }
}
