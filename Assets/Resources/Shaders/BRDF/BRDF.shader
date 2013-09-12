// BRDF Based Bobile Shader
// -Normal Mapping
// -Lookup Table for complex lighting


Shader "Dongwon/BRDF/Bumped Specular" 
{

	Properties 
	{
		_HalfLambert ("HalfLambert", Range (0.0, 1.0)) = 5.0
		_MainCol ("Base Color", Color) = (1, 1, 1)
		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125
		_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
		_BumpMap ("Normalmap", 2D) = "bump" {}
		_BRDF ("BRDF", 2D) = "white" {}
		_LUT ("LUT", 2D) = "white" {}
	}
	
	
	SubShader 
	{ 
		Tags { "RenderType"="Opaque" }
		LOD 250
		
	CGPROGRAM
	#pragma surface surf MobileBRDF exclude_path:prepass nolightmap noforwardadd halfasview
	
	sampler2D _MainTex;
	sampler2D _BumpMap;
	sampler2D _BRDF;
	sampler2D _LUT;
	fixed _Shininess;
	fixed4 _MainCol;
	float _HalfLambert;
	
	inline fixed4 LightingMobileBRDF (SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten)
	{
		fixed3 light = (_LightColor0.rgb * atten * 2);
		fixed nl = dot(s.Normal, lightDir);
		fixed ne = max (0, dot(s.Normal, viewDir));
		
		//Simple Specular Vector
		fixed3 h = normalize ( lightDir + viewDir );
		fixed nh = max (0, dot (s.Normal, h)); 
		
		fixed diff = pow((nl * 0.5 + 0.5), _HalfLambert) * light;
		//fixed diff = (nl * 0.5 + 0.5) * light;
		fixed3 BRDF = tex2D (_BRDF, fixed2(ne, diff)).rgb;
		fixed3 BRDFComp = (s.Albedo * _MainCol.rgb * BRDF); 
		
		fixed3 LUT = tex2D (_LUT, fixed2(nh, diff)).rgb;
		fixed3 spec = pow (nh, _Shininess * 128) * _MainCol.a * s.Alpha;
		
		fixed4 c;
		c.rgb = (BRDFComp * LUT + (LUT * spec)) * light;
		//( (BRDFComp) + (LUT * spec) ) ;
		c.a = 0.0;
		return c;
	}
		
	
	struct Input 
	{
		float2 uv_MainTex;
		float3 viewDir;
	};
	
	
	void surf (Input IN, inout SurfaceOutput o) {
		fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
		o.Albedo = tex.rgb;
		o.Alpha = tex.a;
		//.Normal = UnpackNormal (tex2D(_BumpMap, IN.uv_MainTex));
	}
	
	ENDCG
	
	}

	FallBack "Mobile/VertexLit"
}