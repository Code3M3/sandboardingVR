// referencing: https://www.youtube.com/watch?v=mNyZKyVfPeU&list=PLEwYhelKHmigkbFMrVnz4MbmmFzhL2qL4
// referencing: https://www.youtube.com/watch?v=Ww1GbfnBH_Q

Shader "Custom/DotGridShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0

        _Width("Width", float) = 8
        _Height("Height", float) = 8

        _SphereSize("Sphere Size", float) = .08

        _DotColor("Dot Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        float _Width;
        float _Height;

        float _SphereSize;
        fixed4 _DotColor;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

            void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // Dived UV space into grid
            float2 position = IN.uv_MainTex;
            position *= float2(_Width, _Height);
            position = ceil(position);
            position /= float2(_Width, _Height);

            // Divide cell into 0-1 UV micro-space, each cell becomes it's own 0-1 space
            position -= IN.uv_MainTex.xy;
            position *= float2(_Width, _Height);

            // Circle
            float2 circlePosition = float2(0.5, 0.5);
            circlePosition -= position;
            float distance = length(circlePosition);

            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            if (_SphereSize - distance > 0) {
                o.Albedo = _DotColor;
            }
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
