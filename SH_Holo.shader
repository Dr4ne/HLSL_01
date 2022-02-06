Shader "Toon/SH_Holo"
{
    Properties
    {
        _TintColor("Tint Color", Color) = (1,1,1,1)
        _Texture01 ("Texture", 2D) = "white" {}
        _Texture02 ("Texture", 2D) = "white" {}
        _HatchSpeedX ("Holo Hatch Speed X", float) = 1
        _HatchSpeedY ("Holo Hatch Speed Y", float) = 1
        _HatchSize ("Holo Hatch UV Size", float) = 1
        _HatchStrength ("Holo Hatch Strength", range(0,1)) = 1
        _HoloShakeSpeed ("Holo shake speed", float) = 1
        _HoloShakeAmp ("Holo shake Amplitude", float) = 1
        _HoloDist("Holo Distance", Float) = 1
        _HoloAmount("Holo Amount", Float) = 1
        _Alpha ("Holo Transparency", range(0,1)) = 1


    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            float4 _TintColor;
            sampler2D _Texture01;
            float4 _Texture01_ST;
            sampler2D _Texture02;
            float4 _Texture02_ST;
            float _HatchSpeedX;
            float _HatchSpeedY;
            float _HatchSize;
            float _HatchStrength;
            float _HoloShakeSpeed;
            float _HoloShakeAmp;
            float _HoloDist;
            float _HoloAmount;
            float _Alpha;
            
            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct VertexOutput
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertex.x += sin(_Time.y * _HoloShakeSpeed + o.vertex.x * _HoloShakeAmp) * _HoloDist * _HoloAmount;
                o.uv = TRANSFORM_TEX(v.uv, _Texture01);
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target
            {
                //hatch
                _HatchSize = _HatchSize / 1000;
                float4 cSUv = (i.vertex * _HatchSize);
                cSUv.y += -_Time * _HatchSpeedY;
                cSUv.x += -_Time * _HatchSpeedX;
                fixed4 hatch = tex2D(_Texture02, cSUv).z;
               
                //Albedo + tint
                fixed4 col = tex2D(_Texture01, i.uv).z + _TintColor;

                fixed4 final = col += hatch * _HatchStrength;
                final.a = _Alpha;

                return col;
            }
            ENDCG
        }
    }
}
