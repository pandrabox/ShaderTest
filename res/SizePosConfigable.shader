Shader "Pan/SizePosConfigableJackShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SizeX ("Size X", Range(0,1)) = 1
        _SizeY ("Size Y", Range(0,1)) = 1
        _PosX ("Position X", Range(0, 1)) = 0.5
        _PosY ("Position Y", Range(0, 1)) = 0.5
        _ConstraintMode ("Constraint Mode", Int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Overlay+1026" }
        Pass
        {
            Cull Off
            ZWrite Off
            ZTest Always
            
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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            sampler2D _MainTex;
            float _SizeX, _SizeY;
            float _PosX, _PosY;
            int _ConstraintMode;
            float _ScreenAspect;
            
            // 追加: _MainTex_TexelSizeを手動で計算
            float2 _MainTex_TexelSize;

            v2f vert(appdata v)
            {
                v2f o;
                
                // テクスチャのアスペクト比を計算
                float aspect = _SizeX / _SizeY;
                _ScreenAspect = _ScreenParams.x / _ScreenParams.y;

                // モード0: 画面いっぱいにテクスチャを表示（アスペクト比が崩れる）
                if (_ConstraintMode == 0)
                {
                    o.vertex = float4((v.uv.x * 2 * _SizeX - 1) + (_PosX - 0.5) * 2 + (1 - _SizeX),
                                      (-v.uv.y * 2 * _SizeY + 1) + (_PosY - 0.5) * 2 - (1 - _SizeY),
                                      0, 1);
                }
                // モード1: テクスチャアスペクト比を維持する（xをスクリーンに固定）
                else if (_ConstraintMode == 1)
                {
                    // アスペクト比を保持するために_sizeX と _SizeY を調整
                    float aspectRatio = _MainTex_TexelSize.x / _MainTex_TexelSize.y;
                        _SizeY = _ScreenAspect * aspectRatio;

                    o.vertex = float4((v.uv.x * 2 * _SizeX - 1) + (_PosX - 0.5) * 2 + (1 - _SizeX),
                                      (-v.uv.y * 2 * _SizeY + 1) + (_PosY - 0.5) * 2 - (1 - _SizeY),
                                      0, 1);
                }

                // UVは変更せず、そのまま使用
                o.uv = v.uv;

                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}
