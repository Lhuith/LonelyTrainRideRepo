﻿Shader"Eugene/ShaderDemos/Basic/13_AnisotropicReflection"
{
Properties
{
		_Color("Color_Tint", Color) = (1.0,1.0,1.0,1.0)
		_SpecColor("Specular Color", Color) = (1.0,1.0,1.0,1.0)
		_AniX("Anisotropic X", Range(0.0, 2.0)) = 1.0
		_AniY("Anisotropic Y", Range(0.0, 2.0)) = 1.0
		_Shininess("Shininess", Float) = 1.0
	
}
	SubShader
	{
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			//user defined verables
			uniform fixed4 _Color;
			uniform fixed4 _SpecColor;
			uniform fixed _AniX;
			uniform fixed _AniY;
			uniform half _Shininess;
			
			//unity defined verables
			uniform half4 _LightColor0;
			
			//Base Input structs
			
			struct vertexInput{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
				half4 tangent : TANGENT;
			};
			
			struct vertexOutput{
				half4 pos : SV_POSITION;
				fixed3 normalDir : TEXCOORD0;
				fixed4 lightDir : TEXCOORD1;
				fixed3 viewDir : TEXCOORD2;
				fixed3 tangentDir : TEXCOORD3;
			};
			
			//vertex function
			vertexOutput vert(vertexInput v)
			{
					vertexOutput o;
					
					//Normal Direction
					o.normalDir = normalize(mul(half4(v.normal, 0.0), unity_WorldToObject).xyz);
					//tangent Direction
					o.tangentDir = normalize(mul(unity_ObjectToWorld, half4(v.tangent.xyz, 0.0)).xyz);
					//Unity transform Position
					o.pos = UnityObjectToClipPos(v.vertex);
					
					//world Position
					half4 posWorld = mul(unity_ObjectToWorld, v.vertex);
					//view Direction
					o.viewDir = normalize(_WorldSpaceCameraPos.xyz - posWorld.xyz);
					//light Direction
					half3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - posWorld.xyz;
					o.lightDir = fixed4(
					normalize(lerp(_WorldSpaceLightPos0.xyz, fragmentToLightSource, _WorldSpaceLightPos0.w)),
					lerp(1.0, 1.0/length(fragmentToLightSource), _WorldSpaceLightPos0.w)
					);
					
					return o;
			
			}
			//fragment function
			fixed4 frag(vertexOutput i) : COLOR
			{

			
			//Lighting
			fixed3 h = normalize(i.lightDir.xyz + i.viewDir);
			fixed3 binormalDir = cross(i.normalDir, i.tangentDir);
			
			//dotProduct
			fixed nDotL = dot(i.normalDir, i.lightDir.xyz);
			fixed nDotH = dot(i.normalDir, h);
			fixed nDotV = dot(i.normalDir, i.viewDir);
			fixed tDotHX = dot(i.tangentDir, h)/ _AniX;
			fixed bDotHY = dot(binormalDir, h)/ _AniY;
			//Diffuse Reflection
			fixed3 diffuseReflection = i.lightDir.w * _LightColor0.xyz * saturate(nDotL);
			//Specular Reflection
			fixed3 specularReflection = diffuseReflection * exp(-(tDotHX * tDotHX + bDotHY * bDotHY)) * _Shininess;
			fixed3 lightFinal =specularReflection + diffuseReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;
			
			return fixed4(lightFinal * _Color.xyz, 1.0);
			}
			ENDCG
		}
}
//Fallback "Diffuse"
}





















