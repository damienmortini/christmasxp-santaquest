precision mediump float;

#define PI 3.1415926535897932384626433832795

uniform float time;
uniform vec2 resolution;
uniform vec2 pointer;

float map( in vec3 p) {
  vec3 firstSpherePosition = vec3(0.0, .6, 2.0);
  vec3 q = p;
  q.xz = mod(p.xz + firstSpherePosition.xz, 4.0) - 2.0;
  q.y = length(p.y + firstSpherePosition.y);
  float dSphere = length( q ) - .35 + cos(time) * .15;

  float dPlane = p.y + 1.0;

  float blendingRatio = .3;
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

void main(void)
{
  vec2 uv = gl_FragCoord.xy / resolution.xy;
  vec2 p = -1.0 + 2.0 * uv;
  p.x *= resolution.x / resolution.y;

  vec3 ro = vec3(0.0, 0.0, 0.0);
  vec3 rd = normalize( vec3( p, 1.0 ));
  float rotation = 0.0;
  rotation = (pointer.x / resolution.x) * PI;
  vec3 direction = vec3(cos(rotation + PI * .5), 0.0, sin(rotation + PI * .5));
  rd = normalize(direction + vec3( cos(rotation) * p.x, p.y, sin(rotation) * p.x ));

  vec3 col = vec3(.8);
  
  float tmax = 100.0;
  float h = 1.0;
  float t = 0.0;
  
  for(int i = 0; i < 100; i++) {
      if (h < 0.00001 || h > tmax) break;
      h = map( ro + rd * t);
      t += h;
  }
  
  if (t < tmax) {
      col = calcNormal(ro + rd * t);
  }
    
  gl_FragColor = vec4(col, 1.0);
}