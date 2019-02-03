float4x4 WorldViewMatrix      : WORLDVIEW;
float4x4 ProjMatrix           : PROJECTION;
float4x4 WorldMatrix          : WORLD;
float4x4 ViewMatrix               : VIEW;
float4x4 WVP                  :WORLDVIEWPROJECTION;
float3   LightDirection    : DIRECTION < string Object = "Light"; >;

float4 MaterialDiffuse  : DIFFUSE  < string Object = "Geometry"; >;
float3 MaterialAmbient  : AMBIENT  < string Object = "Geometry"; >;
float3 MaterialEmmisive : EMISSIVE < string Object = "Geometry"; >;
float3 MaterialSpecular : SPECULAR < string Object = "Geometry"; >;
float  SpecularPower    : SPECULARPOWER < string Object = "Geometry"; >;
float3 MaterialToon     : TOONCOLOR;
float3 EdgeColor        : EDGECOLOR;
float3 LightDiffuse     : DIFFUSE   < string Object = "Light"; >;
float3 LightAmbient     : AMBIENT   < string Object = "Light"; >;
float3 LightSpecular    : SPECULAR  < string Object = "Light"; >;
float4 GroundShadowColor : GROUNDSHADOWCOLOR;
float3 CameraPosition    : POSITION  < string Object = "Camera"; >;

texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

bool use_texture; 
bool use_toon;
bool use_SphereMap;

sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);


texture2D HighLight : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1,1};
    int MipLevels = 0;
    string Format = "D3DFMT_A16B16G16R16F" ;
    
>;
sampler2D HighLightView = sampler_state {
    texture = <HighLight>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Point;
    AddressU  = Border;
    AddressV = Border;
};

texture ObjectSphereMap: MATERIALSPHEREMAP;
sampler ObjSphareSampler = sampler_state {
    texture = <ObjectSphereMap>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

struct VS_OUTPUT1
{
    float4 Pos        : POSITION ;    
    float2 Tex        : TEXCOORD1 ;   
    float3 Normal     : TEXCOORD2 ;   
    float3 Eye        : TEXCOORD3 ; 
	float3 SpTex      : TEXCOORD4 ;
};

struct VS_OUTPUT2
{
    float4 Pos1        : POSITION ;   	
};


VS_OUTPUT1 Basic_VS( float4 Pos : POSITION , float3 Normal : NORMAL, float2 Tex : TEXCOORD0 , float3 SpTex      : TEXCOORD4 )
{
    float4 Pos0 = Pos;
    Pos = mul(Pos,WVP);
    float3 Eye = CameraPosition - mul( Pos0, WorldMatrix );
    Normal = normalize( mul( Normal, WorldMatrix ) );
	float2 NormalWV = mul( Normal , (float3x3)ViewMatrix );
	SpTex.x = NormalWV.x *0.5 +0.5;
	SpTex.y = NormalWV.y*-0.5 +0.5;
    VS_OUTPUT1 Out = { Pos, Tex, Normal, Eye , SpTex };
    return Out;
}


float4 Basic_PS( float2 Tex : TEXCOORD1, float3 Normal : TEXCOORD2, float3 Eye : TEXCOORD3 , float3 SpTex      : TEXCOORD4 ) : COLOR0
{
float4 Color = 1;
 float4 BasicColor=tex2D(ObjTexSampler,Tex);
 BasicColor.rgb = 1;
 if (BasicColor.a==0) BasicColor = 0;
	return BasicColor;
}


technique MainTec < string MMDPass = "object";> {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS();
        PixelShader  = compile ps_3_0 Basic_PS();
    }
}
technique MainTec_ss < string MMDPass = "object_ss";> {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS();
        PixelShader  = compile ps_3_0 Basic_PS();
    }
}
