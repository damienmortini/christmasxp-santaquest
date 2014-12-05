precision mediump float;

#define PI 3.1415926535897932384626433832795

uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uPointer;
uniform float uCameraAspect;
uniform float uCameraNear;
uniform float uCameraFar;
uniform float uCameraFov;
uniform vec3 uCameraPosition;
uniform vec3 uCameraRotation;
uniform vec4 uCameraQuaternion;

uniform mat4 uModelViewMatrix;
uniform mat4 uProjectionMatrix;

// uniform mat4 modelMatrix;
// uniform mat4 modelViewMatrix;
// uniform mat4 projectionMatrix;
// uniform mat4 viewMatrix;
// uniform mat3 normalMatrix;
// uniform vec3 cameraPosition;

varying vec3 vEye;
varying vec3 vDir;
varying vec3 vCameraForward;

// PRIMITIVES

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float udBox( vec3 p, vec3 b )
{
  return length(max(abs(p)-b,0.0));
}

// UTILS

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float hash1( float n ) { return fract(43758.5453123*sin(n)); }
float hash1( vec2  n ) { return fract(43758.5453123*sin(dot(n,vec2(1.0,113.0)))); }
vec2  hash2( float n ) { return fract(43758.5453123*sin(vec2(n,n+1.0))); }
vec3  hash3( vec2  n ) { return fract(43758.5453123*sin(dot(n,vec2(1.0,113.0))+vec3(0.0,1.0,2.0))); }
vec4  hash4( vec2  n ) { return fract(43758.5453123*sin(dot(n,vec2(1.0,113.0))+vec4(0.0,1.0,2.0,3.0))); }


float smin( float a, float b, float k )
{
  float h = clamp( 0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
  return mix( b, a, h ) - k*h*(1.0-h);
}

// MAIN

struct Hit
{
  float d;
  vec4 color;
};

vec4 sphereMap( in vec3 p) {

  vec3 color = vec3(1.0, 0.0, 0.0);

  float modulo = 10.;
  float noiseRatio = rand(floor(p.xz / modulo)) * 2. - 1.;

  // p.xz += noiseRatio * 40.;

  p.xz = mod(p.xz, modulo) - modulo * .5;

  float radius = noiseRatio;

  float dist = length(p) - radius;

  return vec4(color, dist);
}

vec4 map( in vec3 p) {

  vec4 sphere = sphereMap(p);

  float displacement = sin(p.x * 2.0)*sin(p.y * 2.0)*sin(p.z * 2.0);
  sphere.w += displacement;

  float planeDist = p.y + 0.0;
  vec3 planeCol = vec3(1.0, 1.0, 1.0);

  float blendingRatio = .8;
  float ratio = clamp(.5 + .5 * (sphere.w - planeDist) / blendingRatio, 0., 1.);
  
  float dist = mix(sphere.w, planeDist, ratio) - blendingRatio * ratio * (1. - ratio);
  vec3 color = mix(sphere.rgb, planeCol, ratio) - blendingRatio * ratio * (1. - ratio);

  // return vec4(sphereCol, sphereDist);
  return vec4(color, dist);
}

vec3 calcNormal (in vec3 p) {
  vec2 e = vec2(0.0001, 0.0);
  return normalize(vec3(
    map(p + e.xyy).w - map(p - e.xyy).w,
    map(p + e.yxy).w - map(p - e.yxy).w,
    map(p + e.yyx).w - map(p - e.yyx).w
  ));
}

void main(void)
{
  vec3 rayOrigin = vEye;
  vec3 rayDirection = normalize(vDir);

  vec3 col = vec3(0.0);
  
  float rayMarchingStep = 0.00001;
  float dist = uCameraNear;
  vec4 result;
  
  for(int i = 0; i < 100; i++) {
      if (rayMarchingStep < 0.00001 || rayMarchingStep > uCameraFar) break;
      result = map( rayOrigin + rayDirection * dist);
      rayMarchingStep = result.w;
      dist += rayMarchingStep;
  }
  
  if (dist < uCameraFar) {
      col = result.rgb;
      col += .5 * dot(calcNormal(rayOrigin + rayDirection * dist), normalize(vec3(0.0, 1.0, 0.0)));
  }

  vec3 intersectionPoint = -dist * rayDirection;
  float eyeHitZ = dist * dot(vCameraForward, rayDirection);

  float depth = eyeHitZ;

  depth = smoothstep( uCameraNear, uCameraFar, depth );

  gl_FragColor = vec4(col * (1.0 - depth), 1.0 - depth);
}