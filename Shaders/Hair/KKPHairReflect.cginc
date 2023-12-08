﻿#ifndef KKP_HAIR_REFLECT
#define KKP_HAIR_REFLECT
			sampler2D _ReflectMap;
			float4 _ReflectMap_ST;
			sampler2D _ReflectionMapCap;
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
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.posWS);
				float3 worldLight = normalize(_WorldSpaceLightPos0.xyz); //Directional light

				float2 normalUV = i.uv0 * _NormalMap_ST.xy + _NormalMap_ST.zw;
				float3 normalMatcap = UnpackScaleNormal(tex2D(_NormalMap, normalUV), _NormalMapScale);

				float3 binormal = CreateBinormal(i.normalWS, i.tanWS.xyz, i.tanWS.w);
				normalMatcap = normalize(
					normalMatcap.x * i.tanWS +
					normalMatcap.y * binormal +
					normalMatcap.z * i.normalWS
				);
				float3 adjustedNormal = normalize(normalMatcap);

				
				float fresnel = max(0.0, dot(viewDir, adjustedNormal));
				float anotherRamp = tex2D(_AnotherRamp, fresnel * _AnotherRamp_ST.xy + _AnotherRamp_ST.zw).x;
				
				KKVertexLight vertexLights[4];
			#ifdef VERTEXLIGHT_ON
				GetVertexLightsTwo(vertexLights, i.posWS, _DisablePointLights);	
			#endif
				float4 vertexLighting = 0.0;
				float vertexLightRamp = 1.0;
			#ifdef VERTEXLIGHT_ON
				vertexLighting = GetVertexLighting(vertexLights, adjustedNormal);
				float2 vertexLightRampUV = vertexLighting.a * _RampG_ST.xy + _RampG_ST.zw;
				vertexLightRamp = tex2D(_RampG, vertexLightRampUV).x;
				float3 rampLighting = GetRampLighting(vertexLights, adjustedNormal, vertexLightRamp);
				vertexLighting.rgb = _UseRampForLights ? rampLighting : vertexLighting.rgb;
			#endif

				float lambert = saturate(dot(worldLight, adjustedNormal)) + vertexLighting.a;
				float ramp = tex2D(_RampG, lambert * _RampG_ST.xy + _RampG_ST.zw).x;
				float shadowAttenuation = saturate(min(ramp, anotherRamp));
				#ifdef SHADOWS_SCREEN
					float2 shadowMapUV = i.shadowCoordinate.xy / i.shadowCoordinate.ww;
					float4 shadowMap = tex2D(_ShadowMapTexture, shadowMapUV);
					shadowAttenuation *= shadowMap;
				#endif
				
				float4 detailMask = tex2D(_DetailMask, i.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw);
				float2 invertDetailGB = 1 - detailMask.gb;
				float matcapAttenuation = shadowAttenuation * invertDetailGB.x;
				matcapAttenuation = 1 - (1 - matcapAttenuation)*_DisableShadowedMatcap;
			
				//Some lines commented due to adding matcap attenuation code
				AlphaClip(i.uv0, 1);
				//float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS);
				float3 normal = GetNormal(i);
				normal = NormalAdjust(i, normal);
				float reflectMap = tex2D(_ReflectMap, (i.uv0 *_ReflectMap_ST.xy) + _ReflectMap_ST.zw).r;


				float3 reflectionDir = reflect(-viewDir, normal);
				float roughness = 1 - (_Roughness);
				roughness *= 1.7 - 0.7 * roughness;
				float4 envSample = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
				float3 env = DecodeHDR(envSample, unity_SpecCube0_HDR);

				float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, normal);
				float2 matcapUV = rotateUV(viewNormal.xy * 0.5 + 0.5, float2(0.5, 0.5), radians(_ReflectRotation));
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
			
				return float4(reflCol, _ReflectionVal*reflectMap);
			}

#endif