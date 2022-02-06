Shader "Toon/SH_Toon_Custom_02"
{
    Properties
    {
        _Text01 ("Texture 01", 2D) = "white" {}
        _Text02 ("Texture 02", 2D) = "white" {}

        _LUT ("LUT", 2D) = "white" {}
		[HDR]
		_AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)
		[HDR]
		_SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
		_Glossiness("Glossiness", Float) = 32
		_HatchIntensity("Hatch Intensity", float) = 1

		[HDR]
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimAmount("Rim Amount", Range(0, 1)) = 0.716
		_RimThreshold("Rim Threshold", Range(0, 1)) = 0.1

		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineWidth ("Outline Width", Range(0, 0.1)) = 0.03
    }
		
    SubShader
    {
        Tags { "RenderType"="Opaque" }
		Tags { "LightMode" = "ForwardBase" }
		Tags { "PassFlags" = "OnlyDirectional" }

        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#include "Lighting.cginc"
			
            sampler2D _Text01;
            sampler2D _Text02;
            float4 _Text01_ST;
            float4 _Text02_ST;

            sampler2D _LUT;
			float4 _AmbientColor;
			float _Glossiness;
			float4 _SpecularColor;
			float _HatchIntensity;

			float4 _RimColor;
			float _RimAmount;
			float _RimThreshold;

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float2 uv02 : TEXCOORD2;
				float3 normal : NORMAL;
            };

            struct VertexOutput
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 worldNormal : NORMAL;
				float3 viewDir : TEXCOORD1;
				float2 uv02 : TEXCOORD2;
            };


            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = WorldSpaceViewDir(v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _Text01);
                o.uv02 = TRANSFORM_TEX(v.uv02, _Text02);
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target
            {
				float3 normal = normalize(i.worldNormal);

				//Lambert
				float Lambert = dot(_WorldSpaceLightPos0, normal);
				float lightIntensity = smoothstep(0, 0.01, Lambert);
				float4 light = lightIntensity * _LightColor0;

				//Blinn-Phong
				float3 viewDir = normalize(i.viewDir);
				float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
				float NdotH = dot(normal, halfVector);
				float specularIntensity = pow(NdotH * lightIntensity, _Glossiness * _Glossiness);
				float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
				float4 specular = specularIntensitySmooth * _SpecularColor;

				//rim
				float4 rimDot = 1 - dot(viewDir, normal);
				float rimIntensity = rimDot * pow(Lambert, _RimThreshold);
				rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
				float4 rim = rimIntensity * _RimColor;				

                fixed4 col = tex2D(_Text01, i.uv);
				float hatch = lerp(tex2D(_Text02, i.vertex.xy * 0.008).x  * _HatchIntensity, 1.0, lightIntensity);
                fixed4 LUTShade = tex2D(_LUT, float2(Lambert*0.5+0.5,0.5));
				
				return col  * (_AmbientColor + LUTShade + specular + rim ) * hatch;
            }
            ENDCG
        }
		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
		Pass 
		{

			Cull Front

			CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

			half _OutlineWidth;
			half4 _OutlineColor;

			float4 vert(float4 position : POSITION, float3 normal : NORMAL) : SV_POSITION 
			{
				position.xyz += normal * _OutlineWidth;
				return UnityObjectToClipPos(position);
			}

			half4 frag() : SV_TARGET
			{
				return _OutlineColor;
			}
			ENDCG
        }
    }
}
