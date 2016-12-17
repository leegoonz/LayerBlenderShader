Shader "Tianyu Shaders/Ground/TextureBlend/Texture Blender 3 Layered"
{
	Properties
	{


		[Header(DIFFUSE COLOR FETCH)]
	_Layer1Color("Background Color", Color) = (1,1,1,1)
		_Layer1Albedo("Layer1 (RGB)", 2D) = "gray" {}
	[Header(DIFFUSE LAYER FETCH)]
	_Layer2Color("Layer2 Color", Color) = (1,1,1,1)
		_Layer2Albedo("Layer2 (RGB)", 2D) = "gray" {}
	_Layer3Color("Layer3 Color", Color) = (1,1,1,1)
		_Layer3Albedo("Layer3 (RGB)", 2D) = "gray" {}
	_BlendValue("Layer2 Mix Scale (Range)",Range(0.01,1)) = 0.5
		_BlendValue2("Layer3 Mix Scale (Range)",Range(0.01,1)) = 0.5
		[Space][Space][Space][Space][Space]
		[Header(SPECULAR FETCH)]
	_SpecColor("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess("Shininess", Range(0.15, 1)) = 0.2
		[HideInInspector]
	_Layer1Specular("Layer1(R)",2D) = "gray" {}
	_SpecularLayer1Power("Specular Layer1 Power" ,Range(0.1 , 10)) = 5.0
		[Space][Space][Space]

		[HideInInspector]
	_Layer2Specular("Layer2(R)",2D) = "gray" {}
	_SpecularLayer2Power("Specular Layer2 Power" ,Range(0.1 , 10)) = 5.0
		[HideInInspector]
	_BlendValueSpec("Specular Scale (Range)",Range(0.01,1)) = 0.5
		[Space][Space][Space][Space][Space]
		[Header(NORMALMAP FETCH)]
	_BumpMap("Normalmap Layer1", 2D) = "bump" {}
	_bumpScale("Layer1 Normal Scale", Range(1.0,2.0)) = 1.0
		_BumpMap2("Normalmap Layer2", 2D) = "bump" {}
	[Space][Space][Space][Space][Space]
		[Header(PARAMETER FETCH)]
	_ParamTex("Layer 2 mask(R) , Layer3 mask(G) , AlphaBelnding mask (B)", 2D) = "white" {}


	}

		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 400

		CGPROGRAM
#pragma debug
#pragma fragmentoption ARB_precision_hint_fastest 
#pragma surface surf BlinnPhong novertexlights 
#pragma target 3.0
#include "UnityCG.cginc"


		sampler2D_half	_Layer1Albedo;
	sampler2D_half	_Layer2Albedo;
	sampler2D_half	_Layer3Albedo;

	sampler2D_half	_Layer1Specular;
	sampler2D_half	_Layer2Specular;

	fixed _SpecularLayer1Power;
	fixed _SpecularLayer2Power;

	sampler2D_half	_BumpMap;
	sampler2D_half	_BumpMap2;
	sampler2D_half	_ParamTex;

	fixed4 _Layer1Color;
	fixed4 _Layer2Color;
	fixed4 _Layer3Color;
	fixed _Shininess;
	fixed _BlendValue;
	fixed _BlendValue2;
	fixed _BlendValueSpec;
	fixed _bumpScale;

	struct Input
	{
		half2 uv_Layer1Albedo;
		half2 uv_Layer2Albedo;
		half2 uv_Layer3Albedo;
		half2 uv_ParamTex;
		//INTERNAL_DATA
	};



	void surf(Input IN, inout SurfaceOutput o)
	{
		fixed4 layer1tex = tex2D(_Layer1Albedo, IN.uv_Layer1Albedo);
		fixed4 layer2tex = tex2D(_Layer2Albedo, IN.uv_Layer2Albedo);
		fixed4 layer3tex = tex2D(_Layer3Albedo, IN.uv_Layer3Albedo);

		//fixed layer1spec = tex2D(_Layer1Specular, IN.uv_Layer1Albedo);
		//fixed layer1spec = layer1tex.r * _SpecularLayer1Power;
		//fixed layer1spec = pow(layer1tex.r , _SpecularLayer1Power);
		fixed layer1spec = _SpecularLayer1Power * (layer1tex.r * 0.175);
		//fixed layer2spec = tex2D(_Layer2Specular, IN.uv_Layer2Albedo);
		//fixed layer2spec = layer2tex.r * _SpecularLayer2Power;
		//fixed layer2spec = pow(layer2tex.r , _SpecularLayer2Power);
		fixed layer2spec = _SpecularLayer2Power * (layer2tex.r * 0.175);

		fixed4 param_tex = tex2D(_ParamTex, IN.uv_ParamTex);

		fixed4 bump = (tex2D(_BumpMap, IN.uv_Layer1Albedo)) * _bumpScale;
		fixed4 bump2 = tex2D(_BumpMap2, IN.uv_Layer2Albedo);

		fixed layer2Mask = param_tex.r;
		fixed layer3Mask = param_tex.g;


		layer1tex *= (1 - (_BlendValue * layer2Mask));
		layer2tex *= (_BlendValue * layer2Mask);
		fixed3 layerCom = (layer1tex.rgb * _Layer1Color.rgb) + (layer2tex * _Layer2Color).rgb;
		layerCom = layerCom * (1 - (_BlendValue2 * layer3Mask));
		layer3tex = layer3tex * (_BlendValue2 * layer3Mask);

		layer1spec *= (1 - (_BlendValue * 1 * layer2Mask));
		layer2spec *= (_BlendValue * 1 * layer2Mask);




		bump *= (1 - (_BlendValue * layer2Mask));
		bump2 *= (_BlendValue * layer2Mask);
		bump = bump + bump2;

		o.Albedo = layerCom.rgb + (layer3tex * _Layer3Color);
		o.Gloss = layer1spec + layer2spec;
		o.Normal = UnpackNormal(normalize(bump));
		o.Specular = _Shininess;

	}
	ENDCG
	}
		FallBack "Diffuse"
}
