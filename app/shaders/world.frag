precision highp float;

#define PI 3.1415926535897932384626433832795

uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uPointer;
uniform float uCameraAspect;
uniform float uCameraNear;
uniform float uCameraFar;
uniform vec3 uCameraPosition;
uniform vec3 uCameraRotation;
uniform float uCameraFov;
uniform vec4 uCameraQuaternion;

float map( in vec3 p) {
  vec3 firstSpherePosition = vec3(0.0, -1., 2.0);
  vec3 q = p;
  q.xz = mod(p.xz + firstSpherePosition.xz, 10.0) - 5.0;
  q.y = length(p.y + firstSpherePosition.y);
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
  p.x *= uCameraAspect;

  // vec3 ro = vec3(0., 0., 0.);
  vec3 ro = uCameraPosition;
  vec3 rd = normalize( vec3( p, -1 ));
  rd = applyQuaternion(rd, uCameraQuaternion);

  vec3 col = vec3(0.0);
  
  float tmax = uCameraFar;
  float h = 1.0;
  float t = uCameraNear;
  
  for(int i = 0; i < 100; i++) {
      if (h < 0.00001 || h > tmax) break;
      h = map( ro + rd * t);
      t += h;
  }
  
  if (t < tmax) {
      // col = vec3(1.0 - t / tmax);
      col = calcNormal(ro + rd * t) * vec3(1.0 - t / tmax);
  }
    
  gl_FragColor = vec4(col, vec3(1.0 - t / tmax));
}