#ifdef GL_ES
precision mediump float;
#endif

// Phong related variables
uniform sampler2D uSampler;
uniform vec3 uKd;
uniform vec3 uKs;
uniform vec3 uLightPos;
uniform vec3 uCameraPos;
uniform vec3 uLightIntensity;

varying highp vec2 vTextureCoord;
varying highp vec3 vFragPos;
varying highp vec3 vNormal;

// Shadow map related variables
#define NUM_SAMPLES 100
#define BLOCKER_SEARCH_NUM_SAMPLES NUM_SAMPLES
#define PCF_NUM_SAMPLES NUM_SAMPLES
#define NUM_RINGS 10

#define EPS 1e-3
#define PI 3.141592653589793
#define PI2 6.283185307179586

uniform sampler2D uShadowMap;

varying vec4 vPositionFromLight;

highp float rand_1to1(highp float x ) { 
  // -1 -1
  return fract(sin(x)*10000.0);
}

highp float rand_2to1(vec2 uv ) { 
  // 0 - 1
	const highp float a = 12.9898, b = 78.233, c = 43758.5453;
	highp float dt = dot( uv.xy, vec2( a,b ) ), sn = mod( dt, PI );
	return fract(sin(sn) * c);
}

float unpack(vec4 rgbaDepth) {
    const vec4 bitShift = vec4(1.0, 1.0/256.0, 1.0/(256.0*256.0), 1.0/(256.0*256.0*256.0));
    return dot(rgbaDepth, bitShift);
}

vec2 poissonDisk[NUM_SAMPLES];

void poissonDiskSamples( const in vec2 randomSeed ) {

  float ANGLE_STEP = PI2 * float( NUM_RINGS ) / float( NUM_SAMPLES );
  float INV_NUM_SAMPLES = 1.0 / float( NUM_SAMPLES );

  float angle = rand_2to1( randomSeed ) * PI2;
  float radius = INV_NUM_SAMPLES;
  float radiusStep = radius;

  for( int i = 0; i < NUM_SAMPLES; i ++ ) {
    poissonDisk[i] = vec2( cos( angle ), sin( angle ) ) * pow( radius, 0.75 );
    radius += radiusStep;
    angle += ANGLE_STEP;
  }
}

void uniformDiskSamples( const in vec2 randomSeed ) {

  float randNum = rand_2to1(randomSeed);
  float sampleX = rand_1to1( randNum ) ;
  float sampleY = rand_1to1( sampleX ) ;

  float angle = sampleX * PI2;
  float radius = sqrt(sampleY);

  for( int i = 0; i < NUM_SAMPLES; i ++ ) {
    poissonDisk[i] = vec2( radius * cos(angle) , radius * sin(angle)  );

    sampleX = rand_1to1( sampleY ) ;
    sampleY = rand_1to1( sampleX ) ;

    angle = sampleX * PI2;
    radius = sqrt(sampleY);
  }
}

float findBlocker( sampler2D shadowMap,  vec2 uv, float zReceiver ) {

	//1.参数设定
  int blockerNum = 0;
  float blockDepthSum = 0.0;
  float shadowMapSize = 2048.0;
  float filterStride = 50.0;

  //2.泊松采样
  poissonDiskSamples(uv);

  //3.计算blocker平均深度
  for(int i=0;i<NUM_SAMPLES;i++){
  
    vec2 sampleCoord = uv + poissonDisk[i] * filterStride/shadowMapSize;
    vec4 depthVec = texture2D(shadowMap,sampleCoord);
    float depth = unpack(depthVec);

    if(zReceiver > depth + EPS){
      blockerNum++;
      blockDepthSum += depth;
    }
  }

  if(blockerNum == 0){
    return 1.0;
  }

  return blockDepthSum/float(blockerNum);
}

float PCF(sampler2D shadowMap, vec4 coords) {
  //1.获取采样点集
  poissonDiskSamples(coords.xy);
  //uniformDiskSamples(coords.xy);

  //2.设定相关初始值
  float shadowMapSize = 2048.0;
  float filterStride = 50.0;
  float currentDepth = coords.z;
  int noShadowCount = 0;

  //3.对每个采样点检测深度并计算平均
  for(int i=0;i<NUM_SAMPLES;i++){
    vec2 sampleCoord = coords.xy + poissonDisk[i]*filterStride/shadowMapSize;
    vec4 closestDepthVec = texture2D(shadowMap,sampleCoord);
    float closestDepth = unpack(closestDepthVec);

    if(currentDepth < closestDepth + EPS)
      noShadowCount++;
  }

  return float(noShadowCount) / float(NUM_SAMPLES);
}

float PCSS(sampler2D shadowMap, vec4 coords){
  // STEP 1: avgblocker depth
  float d_Blocker = findBlocker(shadowMap,coords.xy,coords.z);
  float w_Light = 1.0;
  float d_Receiver = coords.z;

  // STEP 2: penumbra size
  float w_penumbra = w_Light * (d_Receiver - d_Blocker) / d_Blocker;

  // STEP 3: filtering
  // 使用w_penumbra进行PCF
  float shadowMapSize = 2048.0;
  float filterStride = 50.0;
  float currentDepth = coords.z;
  int noShadowCount = 0;
  
  //poissonDiskSamples(coords.xy); 该步已经在findBlocker中实现

  for(int i=0;i<NUM_SAMPLES;i++){
    vec2 sampleCoord = coords.xy + poissonDisk[i]*filterStride/shadowMapSize*w_penumbra;
    vec4 closestDepthVec = texture2D(shadowMap,sampleCoord);
    float closestDepth = unpack(closestDepthVec);

    if(currentDepth < closestDepth + EPS)
      noShadowCount++;
  }

  return float(noShadowCount) / float(NUM_SAMPLES);

}


float useShadowMap(sampler2D shadowMap, vec4 shadowCoord){
  vec4 closestDepthVec = texture2D(shadowMap,shadowCoord.xy);
  float closestDepth = unpack(closestDepthVec);

  float currentDepth = shadowCoord.z;

  return closestDepth + EPS < currentDepth? 0.0 : 1.0;
}

vec3 blinnPhong() {
  vec3 color = texture2D(uSampler, vTextureCoord).rgb;
  color = pow(color, vec3(2.2));

  vec3 ambient = 0.05 * color;

  vec3 lightDir = normalize(uLightPos);
  vec3 normal = normalize(vNormal);
  float diff = max(dot(lightDir, normal), 0.0);
  vec3 light_atten_coff =
      uLightIntensity / pow(length(uLightPos - vFragPos), 2.0);
  vec3 diffuse = diff * light_atten_coff * color;

  vec3 viewDir = normalize(uCameraPos - vFragPos);
  vec3 halfDir = normalize((lightDir + viewDir));
  float spec = pow(max(dot(halfDir, normal), 0.0), 32.0);
  vec3 specular = uKs * light_atten_coff * spec;

  vec3 radiance = (ambient + diffuse + specular);
  vec3 phongColor = pow(radiance, vec3(1.0 / 2.2));
  return phongColor;
}

void main(void) {
  vec3 shadowCoord = vPositionFromLight.xyz/vPositionFromLight.w;
  shadowCoord = shadowCoord * 0.5 + 0.5;

  float visibility;
  //visibility = useShadowMap(uShadowMap, vec4(shadowCoord, 1.0));
  //visibility = PCF(uShadowMap, vec4(shadowCoord, 1.0));
  visibility = PCSS(uShadowMap, vec4(shadowCoord, 1.0));

  vec3 phongColor = blinnPhong();

  gl_FragColor = vec4(phongColor * visibility, 1.0);
  //gl_FragColor = vec4(phongColor, 1.0);
}