﻿#ifndef KKP_SKIN_REFLECT
#define KKP_SKIN_REFLECT
			sampler2D _ReflectMap;
			float4 _ReflectMap_ST;
			sampler2D _ReflectionMapCap;
			float4 _ReflectionMapCap_ST;
			float _Roughness;
			float _ReflectionVal;
			float _UseMatCapReflection;
			float _ReflBlendVal;
			float _ReflBlendSrc;
			float _ReflBlendDst;
			float4 _ReflectCol;
			float _ReflectColAlphaOpt;
			float _ReflectColColorOpt;
			
			float _ReflectRotation;
			sampler2D _ReflectMask;

			float2 rotateUV(float2 uv, float2 pivot, float rotation) {
			    float cosa = cos(rotation);
			    float sina = sin(rotation);
			    uv -= pivot;
			    return float2(
			        cosa * uv.x - sina * uv.y,
			        cosa * uv.y + sina * uv.x 
			    ) + pivot;
			}
			
			fixed4 reflectfrag (Varyings i) : SV_Target
			{
				//Clips based on alpha texture
				AlphaClip(i.uv0, 1);

				float3 worldLightPos = normalize(_WorldSpaceLightPos0.xyz);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS);

				//Normals from texture
				float3 normal = GetNormal(i);

				// Cum
				float liquidFinalMask;
				float3 liquidNormal;
				GetCumVals(i.uv0, liquidFinalMask, liquidNormal);
				
				//Combines normals from cum then adjusts to WS from TS
				float3 finalCombinedNormal = lerp(normal, liquidNormal, liquidFinalMask); 
				normal = NormalAdjust(i, finalCombinedNormal);
				//Detailmask channels:
				//Red 	: Specular
				//Green : Drawn shadows
				//Blue 	:  Something with rim light
				//Alpha : Specular Intensity, Black = Nails White = body
				float2 detailMaskUV = i.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw;
				float4 detailMask = tex2D(_DetailMask, detailMaskUV);

				detailMask.xyz = 1 - detailMask.ywz;

				float2 lineMaskUV = i.uv0 * _LineMask_ST.xy + _LineMask_ST.zw;
				float4 lineMask = tex2D(_LineMask, lineMaskUV);
				lineMask.xz = -lineMask.zx * _DetailNormalMapScale + 1;

				//Lighting begins here

				//Because of how Koikatsu lighting works, the ForwardAdd pass method isn't going to look right with Koikatsu's shading
				//It's are limited to 4 pointlights + 1 directional light because we're using Unity's vertex lights which is capped at 4 + the Forward Light pass
				KKVertexLight vertexLights[4];
			#ifdef VERTEXLIGHT_ON
				GetVertexLightsTwo(vertexLights, i.posWS, _DisablePointLights);
			#endif
				float4 vertexLighting = 0.0;
				float vertexLightRamp = 1.0;
			#ifdef VERTEXLIGHT_ON
				vertexLighting = GetVertexLighting(vertexLights, normal);
				float2 vertexLightRampUV = vertexLighting.a * _RampG_ST.xy + _RampG_ST.zw;
				vertexLightRamp = tex2D(_RampG, vertexLightRampUV).x;
				float3 rampLighting = GetRampLighting(vertexLights, normal, vertexLightRamp);
				vertexLighting.rgb = _UseRampForLights ? rampLighting : vertexLighting.rgb;
			#endif

				//Shadows used as a map for the darker shade
				float shadowExtend = _ShadowExtend * -1.20000005 + 1.0;
				float drawnShadows = min(detailMask.x, lineMask.x);
				float matcapAttenuation = GetShadowAttenuation(i, vertexLighting.a, normal, worldLightPos, viewDir);
				shadowExtend = drawnShadows * (1 - shadowExtend) + shadowExtend;
				matcapAttenuation = 1 - (1-matcapAttenuation*shadowExtend)*_DisableShadowedMatcap;
			
				//Three lines commented due to adding matcap attenuation code
				//AlphaClip(i.uv0, 1);
				//float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS);
				//float3 normal = GetNormal(i);
				//normal = NormalAdjust(i, normal);
				float reflectMap = tex2D(_ReflectMap, (i.uv0 *_ReflectMap_ST.xy) + _ReflectMap_ST.zw).r;


				float3 reflectionDir = reflect(-viewDir, normal);
				float roughness = 1 - (_Roughness);
				roughness *= 1.7 - 0.7 * roughness;
				float4 envSample = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
				float3 env = DecodeHDR(envSample, unity_SpecCube0_HDR);

				float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, normal);
				float2 matcapUV = viewNormal.xy * 0.5 * _ReflectionMapCap_ST.xy + 0.5 + _ReflectionMapCap_ST.zw;
				matcapUV = rotateUV(matcapUV, float2(0.5, 0.5), radians(_ReflectRotation));
				float reflectMask = tex2D(_ReflectMask, i.uv0).r;
				
				float4 matcap = tex2D(_ReflectionMapCap, matcapUV);
				matcap = pow(matcap, 0.454545);
				float3 matcapRGBcolored = lerp(matcap.rgb * _ReflectCol.rgb, lerp(matcap.rgb, _ReflectCol, 0.5), _ReflectColColorOpt);
				float3 matcapRGBalphacolored = lerp(lerp(1, matcapRGBcolored, _ReflectCol.a), lerp(matcap.rgb, matcapRGBcolored, _ReflectCol.a), _ReflectColAlphaOpt);
				env = lerp(env, matcapRGBalphacolored, _UseMatCapReflection * reflectMask);

				float reflectMulOrAdd = 1.0;
				float src = floor(_ReflBlendSrc);
				float dst = floor(_ReflBlendDst);
				//Add
				if(src == 1.0 && dst == 1.0){
					reflectMulOrAdd = 0.0;
				}
				//Mul
				else if(src == 2.0 && dst == 0.0){
					reflectMulOrAdd = 1.0;
				}
				else if(dst == 10.0 && (src == 5.0 || src == 1.0)){
					reflectMulOrAdd = 0.0;
				}
				else {
					reflectMulOrAdd = _ReflBlendVal;
				}
				
				env *= reflectMap * matcapAttenuation * matcap.a;

				float3 reflCol = lerp(env, reflectMulOrAdd, 1-_ReflectionVal * matcapAttenuation * matcap.a * reflectMap);
			
				return float4(max(reflCol, 1E-06), _ReflectionVal*reflectMap);
			}

#endif