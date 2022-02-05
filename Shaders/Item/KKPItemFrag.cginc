#ifndef KKP_ITEMFRAG_INC
#define KKP_ITEMFRAG_INC

			fixed4 frag (Varyings i, int faceDir : VFACE) : SV_Target{
				//Clips based on alpha texture
				float4 mainTex = tex2D(_MainTex, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw);
				AlphaClip(i.uv0, mainTex.a);

				float3 worldLightPos = normalize(_WorldSpaceLightPos0.xyz);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS);
				float3 halfDir = normalize(viewDir + worldLightPos);

				float3 diffuse = _AdjustGamma ? pow(mainTex.rgb, 0.454545) : mainTex.rgb;
				float3 shadingAdjustment = ShadeAdjust(diffuse);
				float3 normal = GetNormal(i);

				float liquidFinalMask;
				float3 liquidNormal;
				GetCumVals(i.uv0, liquidFinalMask, liquidNormal);

				normal = lerp(normal, liquidNormal, liquidFinalMask);
				normal = NormalAdjust(i, normal, faceDir);



				KKVertexLight vertexLights[4];
			#ifdef VERTEXLIGHT_ON
				GetVertexLights(vertexLights, i.posWS);	
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

				float lambert = saturate(dot(worldLightPos, normal));

				float3 cumCol = (lambert + 0.5 + vertexLighting.a) * float3(0.149999976, 0.199999988, 0.300000012) + float3(0.850000024, 0.800000012, 0.699999988);



				float specular = dot(halfDir, normal);
				float fresnel = 1 - max(dot(viewDir, normal), 0.0);


				#ifdef SHADOWS_SCREEN
					float2 shadowMapUV = i.shadowCoordinate.xy / i.shadowCoordinate.ww;
					float4 shadowMap = tex2D(_ShadowMapTexture, shadowMapUV);
					float shadowAttenuation = saturate(shadowMap.x * 2.0 - 1.0);
					lambert *= shadowAttenuation;
				#endif

				float lightRamp = max(lambert, vertexLighting.a);

				float2 rampUV = saturate(lightRamp) * _RampG_ST.xy + _RampG_ST.zw;
				float ramp = tex2D(_RampG, rampUV);
				
				float anotherRampSpecularVertex = 0.0;
			#ifdef VERTEXLIGHT_ON
				[unroll]
				for(int j = 0; j < 4; j++){
					KKVertexLight light = vertexLights[j];
					float3 halfVector = normalize(viewDir + light.dir) * saturate(MaxGrayscale(light.col));
					anotherRampSpecularVertex = max(anotherRampSpecularVertex, dot(halfVector, normal));
				}
			#endif

				float2 anotherRampUV = abs(max(specular, anotherRampSpecularVertex)) * _AnotherRamp_ST.xy + _AnotherRamp_ST.zw;
				float anotherRamp = tex2D(_AnotherRamp, anotherRampUV);
				float finalRamp = anotherRamp - ramp;



				specular = log2(max(specular, 0.0));

				float2 detailUV = i.uv0 * _DetailMask_ST.xy + _DetailMask_ST.zw;
				float4 detailMask = tex2D(_DetailMask, detailUV);
				float2 lineMaskUV = i.uv0 * _LineMask_ST.xy + _LineMask_ST.zw;
				float4 lineMask = tex2D(_LineMask, lineMaskUV);
				lineMask.r = _DetailRLineR * (detailMask.r - lineMask.r) + lineMask.r;

				lineMask.r = _AnotherRampFull * (1 - lineMask.r) + lineMask.r;

				float kkMetalMap = lineMask.r;
				lineMask.r *= _UseKKMetal;

				finalRamp = lineMask.r * finalRamp + ramp;
				
				float shadowExtend = _ShadowExtend * -1.20000005 + 1.0;

				lineMask.rb = 1 - lineMask.rb;
				float4 detailMaskAdjust = 1 - detailMask.yxwz;

				float specularNail = max(detailMask.w, _SpecularPowerNail);
				float drawnShadow = min(lineMask.b, detailMaskAdjust.x);
				drawnShadow = drawnShadow * (1 - shadowExtend) + shadowExtend;
				finalRamp *= drawnShadow;

				float specularHeight = _SpeclarHeight  - 1.0;
				specularHeight *= 0.800000012;
				float2 detailSpecularOffset;
				detailSpecularOffset.x = dot(i.tanWS, viewDir);
				detailSpecularOffset.y = dot(i.bitanWS, viewDir);
				float2 detailMaskUV2 = specularHeight * detailSpecularOffset + i.uv0;
				detailMaskUV2 = detailMaskUV2 * _DetailMask_ST.xy + _DetailMask_ST.zw;
				float drawnSpecular = tex2D(_DetailMask, detailMaskUV2).x;
				float drawnSpecularSquared = min(drawnSpecular * drawnSpecular, 1.0);
				drawnSpecular = drawnSpecular - drawnSpecularSquared;
				drawnSpecular = saturate(drawnSpecular);
				drawnSpecular = min(drawnSpecular, _SpecularPower);
				drawnSpecular = min(drawnSpecular, finalRamp);
				float specularIntensity = dot(_SpecularColor.xyz, float3(0.300000012, 0.589999974, 0.109999999)); //???
				drawnSpecular = min(drawnSpecular, specularIntensity);

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
				lineMask.x = max(lineMask.x, shadowExtendAnother);
				float3 shaded = saturate(lineMask.x * shadingAdjustment);

				float3 remappedShading = shaded * 2 - 2;
				remappedShading = drawnSpecular * remappedShading + 1;
				
				float meshSpecular = _SpecularPower * 256;
				meshSpecular *= specular;
				specular *= 256;
				specular = exp2(specular);



				float specularVertex = 0.0;
				float3 specularVertexCol = 0.0;
			#ifdef VERTEXLIGHT_ON
				specularVertex = GetVertexSpecularDiffuse(vertexLights, normal, viewDir, _SpecularPower, specularVertexCol);
			#endif

				
				specular = min(specular, 1);
				meshSpecular = exp2(meshSpecular);
			#ifdef KKP_EXPENSIVE_RAMP
				float2 lightRampUV = meshSpecular * _RampG_ST.xy + _RampG_ST.zw;
				meshSpecular = tex2D(_RampG, lightRampUV) * _UseRampForSpecular + meshSpecular * (1 - _UseRampForSpecular);
			#endif
				meshSpecular += specularVertex;

				meshSpecular *= _SpecularPower * _SpecularColor.w;
				meshSpecular = saturate(meshSpecular);

				float specularPower = max(detailMaskAdjust.z, _SpecularPower);
				drawnSpecularSquared = min(drawnSpecularSquared, specularPower);
				specularNail = min(specularNail, drawnSpecularSquared);
				float finalDrawnSpecular = meshSpecular * detailMaskAdjust.y * _notusetexspecular + specularNail;
				
				drawnSpecularSquared = meshSpecular * _notusetexspecular;
				

				float3 specularDiffuse = _SpecularColor.xyz * drawnSpecularSquared + diffuse + specularVertexCol;
				float3 specularColor = (finalDrawnSpecular * _SpecularColor.xyz);

				specularColor = diffuse * remappedShading + specularColor;

				diffuse *= shaded;
				float3 finalSpecularColor = specularDiffuse - specularColor;
				float3 mergedSpecularDiffuse = saturate(_notusetexspecular * finalSpecularColor + specularColor);
				float3 shadedSpecular = mergedSpecularDiffuse * shaded;
				mergedSpecularDiffuse = -mergedSpecularDiffuse * shaded + mergedSpecularDiffuse;
				mergedSpecularDiffuse = finalRamp * mergedSpecularDiffuse + shadedSpecular;
				float3 liquidDiffuse =  liquidFinalMask * float3(0.300000012, 0.402941108, 0.557352901) + float3(0.5, 0.397058904, 0.242647097);
				liquidDiffuse = liquidDiffuse * cumCol + meshSpecular;


				float fresnelAdjust = saturate(fresnel * 2 - 0.800000012);
				fresnel = log2(fresnel);
				float3 fresnelLiquid = saturate(liquidDiffuse + fresnelAdjust);
				fresnelLiquid -= mergedSpecularDiffuse;
				mergedSpecularDiffuse = liquidFinalMask * fresnelLiquid + mergedSpecularDiffuse;
				float rimPow = _rimpower * 9 + 1;
				rimPow *= fresnel;
				rimPow = exp2(rimPow);
				float rimMask = detailMaskAdjust.w * 2.77777791 + -1.77777803;
				rimPow *= rimMask;
				rimPow = min(max(rimPow, 0.0), 0.60000024);
				float3 rimCol = rimPow * _SpecularColor.xyz;
				rimCol *= _rimV;
				float3 diffuseSpecRim = saturate(rimCol * detailMaskAdjust.x + mergedSpecularDiffuse);

				float drawnLines = 1 - detailMaskAdjust.w;
				drawnLines = drawnLines - lineMask.y;
				drawnLines = _DetailBLineG * drawnLines + lineMask.y;

				float3 lightCol =  (_LightColor0.xyz + vertexLighting.rgb * vertexLightRamp) * float3(0.600000024, 0.600000024, 0.600000024) + _CustomAmbient.rgb;
				float3 ambientCol = max(lightCol, _ambientshadowG.xyz);
				diffuseSpecRim = diffuseSpecRim * ambientCol;
			
				float3 invertRemapDiffuse = -diffuse * 0.5 + 1;

				diffuse *= 0.5;
				float lineAlpha = _LineColorG.w - 0.5;
				lineAlpha = -lineAlpha * 2.0 + 1.0;
				invertRemapDiffuse = -lineAlpha * invertRemapDiffuse + 1;
				lineAlpha = _LineColorG.w *2;
				diffuse *= lineAlpha;
				diffuse = 0.5 < _LineColorG.w ? invertRemapDiffuse : diffuse;
				diffuse = saturate(diffuse);
				diffuse *= lightCol;
				
				float3 finalDiffuse = drawnShadow * (1 - shaded) + shaded;
				finalDiffuse = diffuseSpecRim * finalDiffuse - diffuse;

				float lineWidth = 1 - _linewidthG;
				lineWidth = lineWidth * 0.889999986 + 0.00999999978;
				lineWidth = log2(lineWidth);
				lineWidth *= drawnLines;
				lineWidth = exp2(lineWidth);

				finalDiffuse = lineWidth * finalDiffuse + diffuse;
				finalDiffuse = GetBlendReflections(finalDiffuse, normal, viewDir, kkMetalMap);

				float4 emission = GetEmission(i.uv0);
				finalDiffuse = finalDiffuse * (1 - emission.a) + (emission.a*emission.rgb);

                float alpha = 1;
            #ifdef ALPHA_SHADER
                alpha = mainTex.a * _Alpha;
            #endif
				return float4(finalDiffuse, alpha );
			}
#endif