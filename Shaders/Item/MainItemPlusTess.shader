﻿Shader "xukmi/MainItemPlusTess"
{
	Properties
	{
		_AnotherRamp ("Another Ramp(LineR)", 2D) = "white" {}
		_MainTex ("MainTex", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "bump" {}
		_NormalMapDetail ("Normal Map Detail", 2D) = "bump" {}
		_DetailMask ("Detail Mask", 2D) = "black" {}
		_LineMask ("Line Mask", 2D) = "black" {}
		_EmissionMask ("Emission Mask", 2D) = "black" {}
		[Gamma]_EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
		_EmissionIntensity("Emission Intensity", Float) = 1
		_EmissionMaskMode("Emission Mask Mode", Float) = 0
		[Gamma]_ShadowColor ("Shadow Color", Vector) = (0.628,0.628,0.628,1)
		_ShadowHSV ("Shadow HSV", Vector) = (0, 0, 0, 0)
		[Gamma]_SpecularColor ("Specular Color", Color) = (1,1,1,1)
		_SpecularPower ("Specular Power", Range(0, 1)) = 0
		_SpeclarHeight ("Speclar Height", Range(0, 1)) = 0.98
		_rimpower ("Rim Width", Range(0, 1)) = 0.5
		_rimV ("Rim Strength", Range(0, 1)) = 0.5
		_ShadowExtend ("Shadow Extend", Range(0, 1)) = 1
		_ShadowExtendAnother ("Shadow Extend Another", Range(0, 1)) = 1
		[MaterialToggle] _AnotherRampFull ("Another Ramp Full", Float) = 0
		[MaterialToggle] _DetailBLineG ("DetailB LineG", Float) = 0
		[MaterialToggle] _DetailRLineR ("DetailR LineR", Float) = 0
		[MaterialToggle] _notusetexspecular ("not use tex specular", Float) = 0
		_LineWidthS ("LineWidthS", Float) = 1
		_Clock ("Clock(xy/piv)(z/ang)(w/spd)", Vector) = (0,0,0,0)
		_ColorMask ("Color Mask", 2D) = "black" {}
		[Gamma]_Color ("Color", Color) = (1,0,0,1)
		[Gamma]_Color2 ("Color2", Color) = (0.1172419,0,1,1)
		[Gamma]_Color3 ("Color3", Color) = (0.5,0.5,0.5,1)
		[Gamma]_CustomAmbient("Custom Ambient", Color) = (0.666666666, 0.666666666, 0.666666666, 1)
		_NormalMapScale ("NormalMapScale", Float) = 1
		_DetailNormalMapScale ("Detail Normal Scale", Float) = 1
		[MaterialToggle] _UseRampForLights ("Use Ramp For Light", Float) = 1
		[MaterialToggle] _UseRampForSpecular ("Use Ramp For Specular", Float) = 0
		[MaterialToggle] _UseLightColorSpecular ("Use Light Color Specular", Float) = 1
		[MaterialToggle] _UseDetailRAsSpecularMap ("Use DetailR as Specular Map", Float) = 0
		_Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
		[Enum(Off,0,Front,1,Back,2)] _CullOption ("Cull Option", Range(0, 2)) = 0
		[Enum(Off,0,On,1)]_AlphaOptionCutoff ("Cutoff On", Float) = 1.0
		[Enum(Off,0,On,1)]_OutlineOn ("Outline On", Float) = 1.0
		[Gamma]_OutlineColor ("Outline Color", Color) = (0, 0, 0, 0)
		_Reflective("Reflective", Range(0, 1)) = 0.75
		[Gamma]_ReflectCol("Reflection Color", Color) = (1, 1, 1, 1)
		_ReflectiveBlend("Reflective Blend", Range(0, 1)) = 0.05
		_ReflectiveMulOrAdd("Mul Or Add", Range(0, 1)) = 1
		_UseKKMetal("Use KK Metal", Range(0, 1)) = 1
		_UseMatCapReflection("Use Mat Cap", Range(0, 1)) = 1
 		_ReflectionMapCap("Mat Cap", 2D) = "black" {}
		_UseKKPRim ("Use KKP Rim", Range(0 ,1)) = 0
		[Gamma]_KKPRimColor ("Body Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_KKPRimSoft ("Body Rim Softness", Float) = 1.5
		_KKPRimIntensity ("Body Rim Intensity", Float) = 0.75
		_KKPRimAsDiffuse ("Body Rim As Diffuse", Range(0, 1)) = 0.0
		_KKPRimRotateX("Body Rim Rotate X", Float) = 0.0
		_KKPRimRotateY("Body Rim Rotate Y", Float) = 0.0
		
		_TessTex ("Tess Tex", 2D) = "white" {}
		_TessMax("Tess Max", Range(1, 25)) = 4
		_TessMin("Tess Min", Range(1, 25)) = 1
		_TessBias("Tess Distance Bias", Range(1, 100)) = 75
		_TessSmooth("Tess Smooth", Range(0, 1)) = 0
		_Tolerance("Tolerance", Range(0.0, 0.05)) = 0.0005
		_DisplaceTex("DisplacementTex", 2D) = "gray" {}
		_DisplaceMultiplier("DisplaceMultiplier", float) = 0
		_DisplaceNormalMultiplier("DisplaceNormalMultiplier", float) = 1
		_DisplaceFull("Displace Full", Range(-1, 1)) = 0

		_ShrinkVal("ShrinkVal", Range(0, 1)) = 1
		_ShrinkVerticalAdjust("Vertical Pos", Range(-1, 1)) = 0
		_ClockDisp ("W is for displacement multiplier for animation", Vector) = (0,0,0,1)
		
		_ReflectColMix ("Reflection Color Mix Amount", Range(0,1)) = 1
		_ReflectRotation ("Matcap Rotation", Range(0, 360)) = 0
		_ReflectMapDetail ("Reflect Body Mask/Map", 2D) = "white" {}
		_DisablePointLights ("Disable Point Lights", Range(0,1)) = 0.0
		_DisableShadowedMatcap ("Disable Shadowed Matcap", Range(0,1)) = 0.0
		[MaterialToggle] _AdjustBackfaceNormals ("Adjust Backface Normals", Float) = 0.0
		[Enum(Off,0,On,1)]_ReflectiveOverlayed ("Reflections Overlayed", Float) = 0.0
		_rimReflectMode ("Rimlight Placement", Float) = 0.0
		
		_SpecularNormalScale ("Specular Normal Map Relative Scale", Float) = 1
		_SpecularDetailNormalScale ("Specular Detail Normal Map Relative Scale", Float) = 1
	}
	SubShader
	{
		LOD 600
		Tags { "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" }
		//Outline
		Pass
		{
			Name "Outline"
			LOD 600
			Tags {"Queue" = "AlphaTest" "RenderType" = "TransparentCutout" "ShadowSupport" = "true" }
			Cull Front

			CGPROGRAM
			#pragma target 5.0

			#pragma vertex TessVert
			#pragma fragment outlineFrag
			#pragma hull hull
			#pragma domain domain
			#pragma only_renderers d3d11 glcore gles gles3 metal d3d11_9x xboxone ps4 psp2 n3ds wiiu 
			
			#define ITEM_SHADER
			#define TESS_MID

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#include "KKPItemInput.cginc"
			#include "KKPItemDiffuse.cginc"
			#include "../KKPDisplace.cginc"
			
			Varyings vert (VertexData v)
			{
				float4 vertex = v.vertex;
				float3 normal = v.normal;
				DisplacementValues(v, vertex, normal);
				v.vertex = vertex;
				v.normal = normal;

				Varyings o;
				o.posWS = mul(unity_ObjectToWorld, v.vertex);
				float3 viewDir = _WorldSpaceCameraPos.xyz - o.posWS.xyz;
				float viewVal = dot(viewDir, viewDir);
				viewVal = sqrt(viewVal);
				viewVal = viewVal * 0.0999999866 + 0.300000012;
				float lineVal = _linewidthG * 0.00499999989;
				viewVal *= lineVal;
				float2 detailMaskUV = v.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw;
				float4 detailMask = SAMPLE_TEX2D_LOD(_DetailMask, float4(detailMaskUV, 0, 0), 0);
				float detailB = 1 - detailMask.b;
				viewVal *= detailB * _LineWidthS;
				float3 invertSquare;
				float3 x;
				float3 y;
				float3 z;
				x.x = unity_WorldToObject[0].x;
				x.y = unity_WorldToObject[1].x;
				x.z = unity_WorldToObject[2].x;
				float xLen = rsqrt(dot(x, x));
				y.x = unity_WorldToObject[0].y;
				y.y = unity_WorldToObject[1].y;
				y.z = unity_WorldToObject[2].y;
				float yLen = rsqrt(dot(y, y));
				z.x = unity_WorldToObject[0].z;
				z.y = unity_WorldToObject[1].z;
				z.z = unity_WorldToObject[2].z;
				float zLen = rsqrt(dot(z, z));
				float3 view = viewVal / float3(xLen, yLen,zLen);
				view = v.normal * view + v.vertex;
				o.posCS = UnityObjectToClipPos(view);
				//Big brain place offscreen
				if(!_OutlineOn)
					o.posCS = float4(2,2,2,1);
				o.uv0 = v.uv0;
				1;
				return o;
			}

			#include "KKPItemTess.cginc"

			fixed4 outlineFrag (Varyings i) : SV_Target
			{
				//Clips based on alpha texture
				float4 mainTex = SAMPLE_TEX2D(_MainTex, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw);
				AlphaClip(i.uv0,  _OutlineOn ? mainTex.a : 0);

				float3 worldLightPos = normalize(_WorldSpaceLightPos0.xyz);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS);
				float3 halfDir = normalize(viewDir + worldLightPos);

				float4 colorMask = SAMPLE_TEX2D(_ColorMask, i.uv0 * + _ColorMask_ST.xy + _ColorMask_ST.zw);
				float3 color;
				color = colorMask.r * (_Color.rgb - 1) + 1;
				color = colorMask.g * (_Color2.rgb - color) + color;
				color = colorMask.b * (_Color3.rgb - color) + color;
				float3 diffuse = mainTex * color;


				//Apparently can rotate?
				float time = _TimeEditor.y + _Time.y;
				time *= _Clock.z * _Clock.w;
				float sinTime = sin(time);
				float cosTime = cos(time);
				float3 rotVal = float3(-sinTime, cosTime, sinTime);
				float2 detailUVAdjust = i.uv0 - _Clock.xy;
				float2 rotatedDetailUV;
				rotatedDetailUV.x = dot(detailUVAdjust, rotVal.yz); 
				rotatedDetailUV.y = dot(detailUVAdjust, rotVal.xy);
				rotatedDetailUV += _Clock.xy;
				rotatedDetailUV = rotatedDetailUV * _LineMask_ST.xy + _LineMask_ST.zw;
				float4 lineMaskRot = SAMPLE_TEX2D_SAMPLER(_LineMask, _DetailMask, rotatedDetailUV);

				diffuse = lineMaskRot.b * -diffuse + diffuse;
				float3 shadingAdjustment = ShadeAdjustItem(diffuse);

				float2 detailUV = i.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw;
				float4 detailMask = SAMPLE_TEX2D(_DetailMask, detailUV);
				
				float specularMap = _UseDetailRAsSpecularMap ? detailMask.r : 1;
				_SpecularPower *= specularMap;

				float2 lineMaskUV = i.uv0 * _LineMask_ST.xy + _LineMask_ST.zw;
				float4 lineMask = SAMPLE_TEX2D_SAMPLER(_LineMask, _DetailMask, lineMaskUV);
				lineMask.r = _DetailRLineR * (detailMask.r - lineMask.r) + lineMask.r;

				float3 diffuseShaded = shadingAdjustment * 0.899999976 - 0.5;
				diffuseShaded = -diffuseShaded * 2 + 1;
				float4 ambientShadow = 1 - _ambientshadowG.wxyz;
				float3 ambientShadowIntensity = -ambientShadow.x * ambientShadow.yzw + 1;
				float ambientShadowAdjust = _ambientshadowG.w * 0.5 + 0.5;
				float ambientShadowAdjustDoubled = ambientShadowAdjust + ambientShadowAdjust;
				bool ambientShadowAdjustShow = 0.5 < ambientShadowAdjust;
				ambientShadow.rgb = ambientShadowAdjustDoubled * _ambientshadowG.rgb;
				float3 finalAmbientShadow = ambientShadowAdjustShow ? ambientShadowIntensity : ambientShadow.rgb;
				finalAmbientShadow = saturate(finalAmbientShadow);
				float3 invertFinalAmbientShadow = 1 - finalAmbientShadow;

				bool3 compTest = 0.555555582 < shadingAdjustment;
				shadingAdjustment *= finalAmbientShadow;
				shadingAdjustment *= 1.79999995;
				diffuseShaded = -diffuseShaded * invertFinalAmbientShadow + 1;
				{
					float3 hlslcc_movcTemp = shadingAdjustment;
					hlslcc_movcTemp.x = (compTest.x) ? diffuseShaded.x : shadingAdjustment.x;
					hlslcc_movcTemp.y = (compTest.y) ? diffuseShaded.y : shadingAdjustment.y;
					hlslcc_movcTemp.z = (compTest.z) ? diffuseShaded.z : shadingAdjustment.z;
					shadingAdjustment = saturate(hlslcc_movcTemp);
				}
				float shadowExtendAnother = 1 - _ShadowExtendAnother;
				float kkMetal = _AnotherRampFull * (1 - lineMask.r) + lineMask.r;

				shadowExtendAnother -= kkMetal;
				shadowExtendAnother += 1;
				shadowExtendAnother = saturate(shadowExtendAnother) * 0.670000017 + 0.330000013;
				float3 shadowExtendShaded = shadowExtendAnother * shadingAdjustment;

				diffuse = diffuse * _LineColorG;				
				float3 lineCol = -diffuse * shadowExtendShaded + 1;
				diffuse *= shadowExtendShaded;

				float lineAlpha = _LineColorG.w - 0.5;
				lineAlpha = -lineAlpha * 2.0 + 1.0;
				lineCol = -lineAlpha * lineCol + 1;
				lineAlpha = _LineColorG.w *2;
				diffuse *= lineAlpha;
				diffuse = 0.5 < _LineColorG.w ? lineCol : diffuse;

				float3 finalDiffuse = lerp(diffuse, _OutlineColor.rgb, _OutlineColor.a);
				return float4(finalDiffuse, 1);
			}

			ENDCG
		}

		//Main Pass
		Pass
		{
			Name "Forward"
			LOD 600
			Tags { "LightMode" = "ForwardBase" "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" "ShadowSupport" = "true" }
			Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
			Cull [_CullOption]

			CGPROGRAM
			#pragma target 5.0

			#pragma vertex TessVert
			#pragma fragment frag
			#pragma hull hull
			#pragma domain domain
			#pragma only_renderers d3d11 glcore gles gles3 metal d3d11_9x xboxone ps4 psp2 n3ds wiiu 
			#pragma multi_compile _ VERTEXLIGHT_ON
			#pragma multi_compile _ SHADOWS_SCREEN
			
			#define ITEM_SHADER
			
			//Unity Includes
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			#define KKP_EXPENSIVE_RAMP

			#include "KKPItemInput.cginc"
			#include "KKPItemDiffuse.cginc"
			#include "KKPItemNormals.cginc"
			#include "../KKPDisplace.cginc"
			#include "../KKPCoom.cginc"
			#include "../KKPVertexLights.cginc"
			#include "../KKPVertexLightsSpecular.cginc"
			#include "../KKPEmission.cginc"
			#include "../KKPReflect.cginc"

			Varyings vert (VertexData v)
			{
				Varyings o;
				
				float4 vertex = v.vertex;
				float3 normal = v.normal;
				DisplacementValues(v, vertex, normal);
				v.vertex = vertex;
				v.normal = normal;
				
				o.posWS = mul(unity_ObjectToWorld, v.vertex);
				o.posCS = mul(UNITY_MATRIX_VP, o.posWS);
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
			
			#include "KKPItemTess.cginc"

			#include "KKPItemItemFrag.cginc"
			
			ENDCG
		}
		
		//ShadowCaster
		Pass
		{
			Name "ShadowCaster"
			LOD 600
			Tags { "LightMode" = "ShadowCaster" "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" "ShadowSupport" = "true" }
			Offset 1, 1
			Cull Off

			CGPROGRAM
			#pragma target 5.0
			#pragma vertex TessVert
			#pragma fragment shadowFrag
			#pragma hull hull
			#pragma domain domain
			#pragma multi_compile_shadowcaster
			#pragma only_renderers d3d11 glcore gles gles3 metal d3d11_9x xboxone ps4 psp2 n3ds wiiu 
			
			#define SHADOW_CASTER_PASS
			#define ITEM_SHADER
			#define TESS_LOW

			#include "UnityCG.cginc"

			#include "KKPItemInput.cginc"
			#include "../KKPDisplace.cginc"

            struct v2f { 
				float2 uv0 : TEXCOORD1;
                V2F_SHADOW_CASTER;
            };

            v2f vert(VertexData v)
            {
                v2f o;
				
				float4 vertex = v.vertex;
				float3 normal = v.normal;
				DisplacementValues(v, vertex, normal);
				v.vertex = vertex;
				v.normal = normal;
				
				o.uv0 = v.uv0;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }
			
			#include "KKPItemTess.cginc"

            float4 shadowFrag(v2f i) : SV_Target
            {
				float2 alphaUV = i.uv0 * _AlphaMask_ST.xy + _AlphaMask_ST.zw;
				float4 alphaMask = SAMPLE_TEX2D(_AlphaMask, alphaUV);
				float2 alphaVal = -float2(_alpha_a, _alpha_b) + float2(1.0f, 1.0f);
				float mainTexAlpha = SAMPLE_TEX2D(_MainTex, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw).a;
				alphaVal = max(alphaVal, alphaMask.xy);
				alphaVal = min(alphaVal.y, alphaVal.x);
				alphaVal *= mainTexAlpha;
				alphaVal.x -= 0.5f;
				float clipVal = alphaVal.x < 0.0f;
				if(clipVal * int(0xffffffffu) != 0)
					discard;

                SHADOW_CASTER_FRAGMENT(i)
            }
			ENDCG
		}
	}
	Fallback "Unlit/Texture"
}
