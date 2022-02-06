Shader "Water/SM_Water_01"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
						
            sampler2D _MainTex;
            float4 _MainTex_ST;
			float waterTranslation;
			float reflectRefractScale;

			matrix worldMatrix;
			matrix viewMatrix;
			matrix projectionMatrix;
			matrix reflectionMatrix;

			SamplerState SampleType
			{
			Filter = MIN_MAG_MIP_LINEAR;
			AddressU = Wrap;
			AddressV = Wrap;
			};


            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct VertexOutput
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float4 reflectionPosition : TEXCOORD1;
				float4 refractionPosition : TEXCOORD2;
            };




            VertexOutput vert (VertexInput v)
            {
                VertexOutput output;
				matrix reflectProjectWorld;
				matrix viewProjectWorld;
								
				v.vertex.w = 1.0f; // Change the position vector to be 4 units for proper matrix calculations.

				worldMatrix = unity_ObjectToWorld;
				viewMatrix = UNITY_MATRIX_V;
				projectionMatrix = UNITY_MATRIX_P;

				output.vertex = mul(v.vertex, worldMatrix);
				output.vertex = mul(output.vertex, viewMatrix);
				output.vertex = mul(output.vertex, projectionMatrix);
				
				reflectProjectWorld = mul(reflectionMatrix, projectionMatrix);
				reflectProjectWorld = mul(worldMatrix, reflectProjectWorld);
				output.reflectionPosition = mul(v.vertex, reflectProjectWorld);


				viewProjectWorld = mul(viewMatrix, projectionMatrix);
				viewProjectWorld = mul(worldMatrix, viewProjectWorld);
				output.refractionPosition = mul(v.vertex, viewProjectWorld);



                output.vertex = UnityObjectToClipPos(v.vertex);
				output.uv = v.uv;
                return output;
            }

            fixed4 frag (VertexOutput i) : SV_Target
			{

                fixed4 col = tex2D(_MainTex, i.uv);

                return col;
            }
            ENDCG
        }
    }
}
