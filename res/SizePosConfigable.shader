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
            float4 _MainTex_ST;
            int _ConstraintMode;
            float4 _MainTex_TexelSize;

            v2f vert(appdata v)
            {
                v2f o;
                o.uv = v.uv;
                
                float imgWidth = _MainTex_TexelSize.z; //TexelはPixelの逆数で、x,yは幅・高さの逆数、z,wには幅・高さが入っている
                float imgHeight = _MainTex_TexelSize.w;
                float aspectRatio = imgWidth / imgHeight; //アスペクト比とは横/高さのこと。1を超えるなら横長
                float screenAspect = _ScreenParams.x / _ScreenParams.y; //_ScreenParams.xとはスクリーン（カメラ）のピクセル数

                o.vertex = float4(v.uv.x , v.uv.y, 0, 1);
                
                // そのまま表示　この時のサイズは画面1/4
                if (_ConstraintMode == 0) return o;

                // 反転を修正　サイズそのまま
                o.vertex = float4(o.vertex.x, -o.vertex.y, 0, 1);
                if (_ConstraintMode == 1) return o;

                //完全中央に移動　サイズそのまま
                o.vertex = float4(o.vertex.x - 0.5, o.vertex.y + 0.5, 0, 1);
                if (_ConstraintMode == 2) return o;

                //画面いっぱいに広げる　サイズは元々1/4なので縦横を２倍
                o.vertex = float4(o.vertex.x * 2, o.vertex.y * 2, 0, 1);
                if (_ConstraintMode == 3) return o;
                
                // スクリーンのピクセル数で割って1px*1pxにする。その状態だと見えないので画像のピクセル数を掛けて画像サイズそのままにする
                // これは即ち画像をピクセル数等寸大で表示するということ
                float xSize,ySize;
                xSize = imgWidth/_ScreenParams.x;
                ySize = imgHeight/_ScreenParams.y;
                o.vertex = float4(o.vertex.x * xSize , o.vertex.y * ySize, 0, 1);
                if (_ConstraintMode == 4) return o;

                // 2種類の変形をするので一旦保存する
                float4 originalsize = float4(o.vertex.x , o.vertex.y, 0, 1);

                // 横幅をスクリーンに合うようにする
                float size;
                size = 1/xSize;
                o.vertex = float4(originalsize.x * size , originalsize.y * size, 0, 1);
                if (_ConstraintMode == 5) return o;

                
                // 縦幅をスクリーンに合うようにする
                size = 1/ySize/20;
                o.vertex = float4(originalsize.x * size , originalsize.y * size, 0, 1);
                if (_ConstraintMode == 6) return o;

                
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
