﻿Shader "xukmi/EyeWPlus"
{
	Properties
	{
		[Gamma]_Color ("Color", Vector) = (0.5,0.5,0.5,1)
		_MainTex ("MainTex", 2D) = "white" {}
		[Gamma]_shadowcolor ("shadowcolor", Vector) = (0.6298235,0.6403289,0.747,1)
		_Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
		_EmissionMask ("Emission Mask", 2D) = "black" {}
		[Gamma]_EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
		_EmissionIntensity("Emission Intensity", Float) = 1
		_EmissionMaskMode("Emission Mask Mode", Float) = 0
		[Gamma]_CustomAmbient("Custom Ambient", Color) = (0.666666666, 0.666666666, 0.666666666, 1)
		[MaterialToggle] _UseRampForLights ("Use Ramp For Light", Float) = 1

		_ReflectMap ("Reflect Body Map", 2D) = "white" {}
		_Roughness ("Roughness", Range(0, 1)) = 0.75
		_ReflectionVal ("ReflectionVal", Range(0, 1)) = 1.0
		[Gamma]_ReflectCol("Reflection Color", Color) = (1, 1, 1, 1)
		_ReflectionMapCap ("Matcap", 2D) = "white" {}
		_UseMatCapReflection ("Use Matcap or Env", Range(0, 1)) = 1.0
		_ReflBlendSrc ("Reflect Blend Src", Float) = 2.0
		_ReflBlendDst ("Reflect Blend Dst", Float) = 0.0
		_ReflBlendVal ("Reflect Blend Val", Range(0, 1)) = 1.0
		_ReflectColMix ("Reflection Color Mix Amount", Range(0,1)) = 1
		_ReflectRotation ("Matcap Rotation", Range(0, 360)) = 0
		_ReflectMask ("Reflect Body Mask", 2D) = "white" {}
		_DisableShadowedMatcap ("Disable Shadowed Matcap", Range(0,1)) = 0.0

		_DisablePointLights ("Disable Point Lights", Range(0,1)) = 0.0
		_ShadowHSV ("Shadow HSV", Vector) = (0, 0, 0, 0)
	}
	SubShader
	{
		LOD 600
		Tags { "IGNOREPROJECTOR" = "true" "QUEUE" = "Transparent-1" "RenderType" = "Transparent" }

		//Main Pass
		Pass {
			Name "Forward"
			LOD 600
			Tags { "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "Transparent-1" "RenderType" = "Transparent" "SHADOWSUPPORT" = "true" }
			ZWrite Off

			Stencil {
				Ref 2
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma only_renderers d3d11 glcore gles gles3 metal d3d11_9x xboxone ps4 psp2 n3ds wiiu
			#pragma multi_compile _ VERTEXLIGHT_ON

			#define KKP_EXPENSIVE_RAMP

			//Unity Includes
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"


			#include "KKPEyeInput.cginc"
			#include "KKPEyeDiffuse.cginc"
			#include "../KKPVertexLights.cginc"
			#include "../KKPEmission.cginc"

			Varyings vert (VertexData v)
			{
				Varyings o;
				o.posWS = mul(unity_ObjectToWorld, v.vertex);
				o.posCS = mul(UNITY_MATRIX_VP, o.posWS);
				o.normalWS = UnityObjectToWorldNormal(v.normal);
				o.uv0 = v.uv0;
				1;
				return o;
			}

			#include "KKPEyeWPlusFrag.cginc"

			ENDCG
		}

		//Reflection Pass
		Pass {
			Name "Reflect"
			LOD 600
			Tags { "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "Transparent-1" "RenderType" = "Transparent" "SHADOWSUPPORT" = "true" }
			Blend [_ReflBlendSrc] [_ReflBlendDst]
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment reflectfrag
			#pragma only_renderers d3d11 glcore gles gles3 metal d3d11_9x xboxone ps4 psp2 n3ds wiiu

			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile _ SHADOWS_SCREEN

			#define KKP_EXPENSIVE_RAMP

			//Unity Includes
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			#include "KKPEyeInput.cginc"
			#include "KKPEyeDiffuse.cginc"
			#include "../KKPVertexLights.cginc"

			#include "KKPEyeReflect.cginc"

			Varyings vert (VertexData v)
			{
				Varyings o;
				o.posWS = mul(unity_ObjectToWorld, v.vertex);
				o.posCS = UnityObjectToClipPos(v.vertex);
				o.normalWS = UnityObjectToWorldNormal(v.normal);
				o.tanWS = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
				float3 biTan = cross(o.tanWS, o.normalWS);
				o.bitanWS = normalize(biTan);
				o.uv0 = v.uv0;

                #ifdef SHADOWS_SCREEN
                    float4 projPos = o.posCS;
                    projPos.y *= _ProjectionParams.x;
                    float4 projbiTan;
                    projbiTan.xyz = biTan;
                    projbiTan.xzw = projPos.xwy * 0.5;
                    o.shadowCoordinate.zw = projPos.zw;
                    o.shadowCoordinate.xy = projbiTan.zz + projbiTan.xw;
                #endif
				return o;
			}
			ENDCG
		}

		//ShadowCaster
		Pass {
			Name "ShadowCaster"
			LOD 600
			Tags { "IGNOREPROJECTOR" = "true" "IgnoerProjector" = "true" "LIGHTMODE" = "SHADOWCASTER" "QUEUE" = "Transparent-1" "RenderType" = "Transparent" "SHADOWSUPPORT" = "true" }
			Offset 1, 1
			Cull Back

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#pragma only_renderers d3d11 glcore gles gles3 metal d3d11_9x xboxone ps4 psp2 n3ds wiiu

			#include "UnityCG.cginc"

			#include "KKPEyeInput.cginc"

            struct v2f {
				float2 uv0 : TEXCOORD1;
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
				o.uv0 = v.texcoord;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {

				float4 mainTex = SAMPLE_TEX2D(_MainTex, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw);
				float alphaVal = mainTex.a;
				float clipVal = (alphaVal.x - 0.5) < 0.0f;
				if(clipVal * int(0xffffffffu) != 0)
					discard;

                SHADOW_CASTER_FRAGMENT(i)
            }
			ENDCG
		}
	}
	Fallback "Diffuse"
}
