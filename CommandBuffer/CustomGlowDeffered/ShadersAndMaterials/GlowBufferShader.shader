Shader "Unlit/GlowBufferShader"
{
    Properties
    {
        _Color ("Bloom Color", Color) = (1,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
                float linearDepth : TEXCOORD2;
            };

            uniform fixed4 _Color;
            uniform sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.linearDepth = COMPUTE_DEPTH_01;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                float linearCameraDetph = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenUV));

                float diff = saturate(i.linearDepth - linearCameraDetph);
                clip(0.001 - diff);

                return _Color;
            }
            ENDCG
        }
    }
}
