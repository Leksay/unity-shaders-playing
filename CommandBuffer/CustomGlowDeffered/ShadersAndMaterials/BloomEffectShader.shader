Shader "Leksay/BloomEffectShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius ("Radius", Float) = 0.25
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Blend One OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform sampler2D _GlowMap;
            uniform float4 _GlowMap_TexelSize;
            uniform half4 _GlowMap_HDR;

            uniform float _Radius;

            float4 guassianBlur(sampler2D map, float2 uv, float texelX, float texelY, float2 dir)
            {
                float4 sum = 0;

                float blurX = _Radius * texelX;
                float blurY = _Radius * texelY;

                sum += tex2D(map, float2(uv.x - 4 * blurX * dir.x, uv.y - 4 * blurY * dir.y)) * 0.0162162162;
                sum += tex2D(map, float2(uv.x - 3 * blurX * dir.x, uv.y - 3 * blurY * dir.y)) * 0.0540540541;
                sum += tex2D(map, float2(uv.x - 2 * blurX * dir.x, uv.y - 2 * blurY * dir.y)) * 0.1216216216;
                sum += tex2D(map, float2(uv.x - 1 * blurX * dir.x, uv.y - 1 * blurY * dir.y)) * 0.1945945946;

                sum += tex2D(map, float2(uv.x * blurX * dir.x, uv.y * blurY * dir.y)) * 0.2270270270;

                sum += tex2D(map, float2(uv.x + 1 * blurX * dir.x, uv.y + 1 * blurY * dir.y)) * 0.1945945946;
                sum += tex2D(map, float2(uv.x + 2 * blurX * dir.x, uv.y + 2 * blurY * dir.y)) * 0.1216216216;
                sum += tex2D(map, float2(uv.x + 3 * blurX * dir.x, uv.y + 3 * blurY * dir.y)) * 0.0540540541;
                sum += tex2D(map, float2(uv.x + 4 * blurX * dir.x, uv.y + 4 * blurY * dir.y)) * 0.0162162162;

                return float4(sum.rgb, 1.0);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 blurX = guassianBlur(_GlowMap, i.uv, _GlowMap_TexelSize.x, _GlowMap_TexelSize.y, float2(0.5, 0));
                blurX += guassianBlur(_GlowMap, i.uv, _GlowMap_TexelSize.x, _GlowMap_TexelSize.y, float2(0.7, 0)) / 2;
                blurX += guassianBlur(_GlowMap, i.uv, _GlowMap_TexelSize.x, _GlowMap_TexelSize.y, float2(1, 0)) / 3;

                fixed4 blurY = guassianBlur(_GlowMap, i.uv, _GlowMap_TexelSize.x, _GlowMap_TexelSize.y, float2(0, 0.5));
                blurY += guassianBlur(_GlowMap, i.uv, _GlowMap_TexelSize.x, _GlowMap_TexelSize.y, float2(0, 0.7)) / 2;
                blurY += guassianBlur(_GlowMap, i.uv, _GlowMap_TexelSize.x, _GlowMap_TexelSize.y, float2(0, 1)) / 3;

                half3 hdrBlur = DecodeHDR(blurX, _GlowMap_HDR) + DecodeHDR(blurY, _GlowMap_HDR);
                hdrBlur *= unity_ColorSpaceDouble.rgb;

                hdrBlur *= tex2D(_GlowMap, i.uv).a == 0 ? 1 : 0;

                return fixed4(col.rgb + hdrBlur, 1);
            }
            ENDCG
        }
    }
}
