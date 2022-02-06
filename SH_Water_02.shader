Shader "Water/SH_Water_02"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Normal01 ("Normal 01", 2D) = "bump" {}
		_Normal02 ("Normal 02", 2D) = "bump" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_WaterFogColor ("Water Fog Color", Color) = (0, 0, 0, 0)
		_WaterFogDensity ("Water Fog Density", Range(0, 2)) = 0.1
		_Alpha ("Water Transparency", float) = 1
		_Norm01WX ("Normal 01 Wind X", float) = 1
		_Norm01WY ("Normal 01 Wind Y", float) = 1
		_Norm02WX ("Normal 02 Wind X", float) = 1
		_Norm02WY ("Normal 02 Wind Y", float) = 1
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200


		GrabPass {"_WaterBackground"}

        CGPROGRAM

        #pragma surface surf Standard alpha // fullforwardshadows
        #pragma target 3.0

		#include "LookingThroughWater.cginc"

        sampler2D _MainTex;
		sampler2D _Normal01;
		sampler2D _Normal02;
		half _Glossiness;
        half _Metallic;
		half _Alpha;
        fixed4 _Color;

		float _Norm01WX;
		float _Norm01WY;
		float _Norm02WX;
		float _Norm02WY;

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_Normal01;
			float2 uv_Normal02;
			float4 screenPos;
        };


        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            //o.Albedo = c.rgb;
			o.Albedo = ColorBelowWater(IN.screenPos);
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
			
			IN.uv_Normal01.x += _Time * _Norm01WX;
			IN.uv_Normal01.y += _Time * _Norm01WY;
			IN.uv_Normal02.x += _Time * _Norm02WX;
			IN.uv_Normal02.y += _Time * _Norm02WY;

			float3 n1 = tex2D(_Normal01, IN.uv_Normal01).xyz*2 - 1;
			float3 n2 = tex2D(_Normal02, IN.uv_Normal02).xyz*2 - 1;

			float3 r = normalize(float3(n1.xy + n2.xy, n1.z));
			o.Normal = r;

            o.Alpha = _Alpha;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
