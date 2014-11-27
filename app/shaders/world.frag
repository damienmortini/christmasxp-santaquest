precision highp float;

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

uniform mat4 modelMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
// uniform mat4 viewMatrix;
uniform mat3 normalMatrix;
// uniform vec3 cameraPosition;

float map( in vec3 p) {
  vec3 firstSpherePosition = vec3(0.0, -1., 2.0);
  vec3 q = p;
  q.xz = mod(p.xz + firstSpherePosition.xz, 10.0) - 5.0;
  q.y = length(p.y + firstSpherePosition.y);
  // float dSphere = length( q ) - .5 - 1.;
  float dSphere = length( q ) - .5 - 1. - cos(uTime);

  float dPlane = p.y + 1.0;

  float blendingRatio = .8;
  float ratio = clamp(.5 + .5 * (dSphere - dPlane) / blendingRatio, 0., 1.);
  
  float dist = mix(dSphere, dPlane, ratio) - blendingRatio * ratio * (1. - ratio);

  return dist;
}

vec3 calcNormal (in vec3 p) {
  vec2 e = vec2(0.0001, 0.0);
  return normalize(vec3(
    map(p + e.xyy) - map(p - e.xyy),
    map(p + e.yxy) - map(p - e.yxy),
    map(p + e.yyx) - map(p - e.yyx)
  ));
}

vec3 applyQuaternion ( in vec3 v, vec4 q ) {
  float x = v.x;
  float y = v.y;
  float z = v.z;

  float qx = q.x;
  float qy = q.y;
  float qz = q.z;
  float qw = q.w;

  // calculate quat * vector

  float ix =  qw * x + qy * z - qz * y;
  float iy =  qw * y + qz * x - qx * z;
  float iz =  qw * z + qx * y - qy * x;
  float iw = - qx * x - qy * y - qz * z;

  // calculate result * inverse quat

  v.x = ix * qw + iw * - qx + iy * - qz - iz * - qy;
  v.y = iy * qw + iw * - qy + iz * - qx - ix * - qz;
  v.z = iz * qw + iw * - qz + ix * - qy - iy * - qx;

  return v;
}

void main(void)
{
  vec2 uv = gl_FragCoord.xy / uResolution.xy;
  vec2 p = -1.0 + 2.0 * uv;
  float fovHorizontal = uCameraFov * uCameraAspect;
  vec2 fovAngle = vec2((fovHorizontal / 180.0) * PI, (uCameraFov / 180.0) * PI);
  vec3 rayDirection = vec3(0.0);
  rayDirection.x = sin(p.x * fovAngle.x * .5);
  rayDirection.z = -cos(p.x * fovAngle.x * .5);
  rayDirection.y = sin(p.y * fovAngle.y * .5);
  rayDirection.x *= cos(p.y * fovAngle.y * .5);
  rayDirection.z *= cos(p.y * fovAngle.y * .5);

  // float ditanceRatio = 1.0 + (1.0 - dot(vec3(0.0, 0.0, 1.0), rayDirection));

  // rayDirection *= ditanceRatio;

  // vec3 ro = vec3(0., 0., 0.);
  vec3 rayOrigin = uCameraPosition;
  // vec3 rayDirection = normalize( vec3( p, -1 ));
  rayDirection = applyQuaternion(rayDirection, uCameraQuaternion);

  // rayDirection = normalize(rayDirection);

  vec3 col = vec3(0.0);
  
  float rayMarchingStep = 0.00001;
  float dist = uCameraNear;
  
  for(int i = 0; i < 100; i++) {
      if (rayMarchingStep < 0.00001 || rayMarchingStep > uCameraFar) break;
      rayMarchingStep = map( rayOrigin + rayDirection * dist);
      dist += rayMarchingStep;
  }
  
  if (dist < uCameraFar) {
      // col = vec3(1.0 - t / uCameraFar);
      col = calcNormal(rayOrigin + rayDirection * dist) * vec3(1.0 - dist / uCameraFar);
  }

  // float a = (uCameraFar+uCameraNear)/(uCameraFar-uCameraNear);
  // float b = 2.0*uCameraFar*uCameraNear/(uCameraFar-uCameraNear);
  // float depth = dist / uCameraFar;

  vec3 cameraForward = applyQuaternion(vec3(0, 0, 1), uCameraQuaternion);
  float eyeHitZ = -dist * dot( cameraForward, rayDirection);
  float depth = eyeHitZ / uCameraFar;

  // float depth = /z;

  // float eyeHitZ = -dist * dot( cameraForward, rayDirection);
  // eyeHitZ /= uCameraFar;
  // float depth = ((uCameraFar+uCameraNear) + (2.0*uCameraFar*uCameraNear)/eyeHitZ)/(uCameraFar-uCameraNear);

  // float a = (uCameraFar + uCameraNear) / (uCameraFar - uCameraNear);
  // float b = 2.0 * uCameraFar * uCameraNear / (uCameraFar - uCameraNear);
  // float ndcDepth = a + b / eyeHitZ;

  // float depth = ((gl_DepthRange.diff * ndcDepth) + gl_DepthRange.near + gl_DepthRange.far) / 2.0;


  // float depth = eyeHitZ / uCameraFar;

  // depth *= .1;

  // float zc = ( projectionMatrix * vec4( intersectionPoint, 1.0 ) ).z;
  // float wc = ( projectionMatrix * vec4( intersectionPoint, 1.0 ) ).w;
  // float depth = zc/wc;
  // gl_FragDepth = zc/wc;
    
  // gl_FragColor = vec4(vec3(col), 1.);
  gl_FragColor = vec4(col, 1. - depth);
}