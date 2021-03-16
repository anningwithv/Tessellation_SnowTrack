    Shader "SnowTrackShader" 
    {
        Properties {
            _Tess ("Tessellation", Range(1,32)) = 4
            _SnowTex ("Snow Tex", 2D) = "white" {}
            _SnowColor("Snow Color", Color) = (1,1,1,1)
            _GroundTex ("Ground Tex", 2D) = "white" {}
            _GroundColor("Ground Color", Color) = (1,1,1,1)
            _SplatMap ("Splat Map", 2D) = "black" {}
            _Displacement ("Displacement", Range(0, 1.0)) = 0.3
        }
        SubShader {
            Tags { "RenderType"="Opaque" }
            LOD 300
            
            CGPROGRAM
            #pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp tessellate:tessDistance nolightmap
            #pragma target 4.6
            #include "Tessellation.cginc"

			float _Tess;
			sampler2D _SplatMap;
			float _Displacement;
			sampler2D _SnowTex;
			fixed4 _SnowColor;
			sampler2D _GroundTex;
			fixed4 _GroundColor;

            struct appdata {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };


            float4 tessDistance (appdata v0, appdata v1, appdata v2) {
                float minDist = 10.0;
                float maxDist = 25.0;
                return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
            }

            void disp (inout appdata v)
            {
                float d = tex2Dlod(_SplatMap, float4(v.texcoord.xy,0,0)).r * _Displacement;
                v.vertex.xyz -= v.normal * d;
                v.vertex.xyz += v.normal * _Displacement;//将mesh上移，这个物体才会陷在雪地里
            }

            struct Input {
                float2 uv_SnowTex;
                float2 uv_GroundTex;
                float2 uv_SplatMap;
            };

            void surf (Input IN, inout SurfaceOutput o) 
            {
                half4 snow = tex2D (_SnowTex, IN.uv_SnowTex) * _SnowColor;
                half4 ground = tex2D (_GroundTex, IN.uv_GroundTex) * _GroundColor;
                half amount = tex2Dlod(_SplatMap, float4(IN.uv_SplatMap,0,0)).r;
                half4 c = lerp(snow, ground, amount);

                o.Albedo = c.rgb;
                o.Specular = 0.2;
                o.Gloss = 1.0;
            }
            ENDCG
        }
        FallBack "Diffuse"
    }