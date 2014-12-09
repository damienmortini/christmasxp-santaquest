precision highp float;

#define PI 3.1415926535897932384626433832795

uniform vec2 uResolution;
uniform float uNear;
uniform float uFar;
uniform float uFov;
uniform float uTime;
uniform mat4 uModelViewMatrix;
uniform mat4 uProjectionMatrix;
uniform sampler2D uNoiseTexture;

varying vec2 vUv;


// STRUCTURES

struct Voxel
{
  float dist;
  vec4 color;
};

// PRIMITIVES

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float udRoundBox( vec3 p, vec3 b )
{
  return length(max(abs(p)-b,0.0));
}

float udRoundBox( vec3 p, vec3 b, float r )
{
  return length(max(abs(p)-b,0.0))-r;
}

// NOISES

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec2 random2f( vec2 seed )
{
  float rnd1 = mod(fract(sin(dot(seed, vec2(14.9898,78.233))) * 43758.5453), 1.0);
  float rnd2 = mod(fract(sin(dot(seed+vec2(rnd1), vec2(14.9898,78.233))) * 43758.5453), 1.0);
  return vec2(rnd1, rnd2);
}

float hash1( float n ) { return fract(43758.5453123*sin(n)); }
float hash1( vec2  n ) { return fract(43758.5453123*sin(dot(n,vec2(1.0,113.0)))); }
vec2  hash2( float n ) { return fract(43758.5453123*sin(vec2(n,n+1.0))); }
vec2  hash2( vec2  n ) { n = vec2( dot(n,vec2(127.1,311.7)), dot(n,vec2(269.5,183.3)) ); return fract(sin(n)*43758.5453); }
vec3  hash3( vec2  n ) { return fract(43758.5453123*sin(dot(n,vec2(1.0,113.0))+vec3(0.0,1.0,2.0))); }
vec4  hash4( vec2  n ) { return fract(43758.5453123*sin(dot(n,vec2(1.0,113.0))+vec4(0.0,1.0,2.0,3.0))); }

float noise( in float x )
{
    float p = floor(x);
    float f = fract(x);

    f = f*f*(3.0-2.0*f);

    return mix( hash1(p+0.0), hash1(p+1.0),f);
}

float noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*157.0;

    return mix(mix( hash1(n+  0.0), hash1(n+  1.0),f.x),
               mix( hash1(n+157.0), hash1(n+158.0),f.x),f.y);
}

float cheapNoise( vec3 p) {
  return sin(p.x * 2.0)*sin(p.y * 2.0)*sin(p.z * 2.0);
}

const mat2 m2 = mat2( 0.80, -0.60, 0.60, 0.80 );

float fbm( vec2 p )
{
    float f = 0.0;

    f += 0.5000*noise( p ); p = m2*p*2.02;
    f += 0.2500*noise( p ); p = m2*p*2.03;
    f += 0.1250*noise( p ); p = m2*p*2.01;
    f += 0.0625*noise( p );

    return f/0.9375;
}

// UTILS

Voxel smin( Voxel voxel1, Voxel voxel2 )
{
  float blendRatio = 10.;
  float ratio = clamp(.5 + .5 * (voxel2.dist - voxel1.dist) / blendRatio, 0., 1.);
  
  float dist = mix(voxel2.dist, voxel1.dist, ratio) - blendRatio * ratio * (1. - ratio);
  vec4 color = mix(voxel2.color, voxel1.color, ratio);

  return Voxel(dist, color);
}

Voxel min( Voxel voxel1, Voxel voxel2 )
{
  if(voxel1.dist - voxel2.dist < 0.) {
    return voxel1;
  }
  else {
    return voxel2;
  }
}

float maxcomp( in vec3 v ) { return max( max( v.x, v.y ), v.z ); }

vec4 getTexture(sampler2D texture, vec2 position, float scale) {
  return texture2D(uNoiseTexture, fract(position / scale));
}

// MAIN

Voxel spheres( vec3 p, float modulo, float radius, vec2 offset, float duration ) {

  vec4 color = vec4(1.0, 0.0, 0.0, 1.0);

  // p.xz += offset;

  vec2 pos = floor(p.xz / modulo);

  // vec2 noiseRatio = hash2(pos);
  // vec4 texel = getTexture(uNoiseTexture, pos, 512.);
  // float noiseRatio = texel.r;

  vec3 q = p;

  // float elevationRatio = mod(uTime, duration) / duration;

  // duration = noiseRatio.x + noiseRatio.y;

  q.xz = mod(q.xz, modulo) - modulo * .5;
  // q.xz += (noiseRatio * .5 - .25) * modulo;
  // q.y += radius * 2. - 200. * elevationRatio;

  // radius *= (1. - elevationRatio) * noiseRatio.x;

  float dist = length(q) - radius;
  // float dist = length(q) - 5.;

  // float displacement = getTexture(uNoiseTexture, q.xz, 1000.).g;
  // dist += displacement * 5.;

  return Voxel( dist, color );
}

Voxel ground( vec3 p, vec4 tex ) {

  vec4 color = vec4(1.0, 1.0, 1.0, 1.0);

  // color = tex;
  // color *= vec4(.5, 1., .5, 1.);
  
  float displacement = (tex.r + tex.g + tex.b) / 3.;
  // float displacement = sin(p.x * .01) * sin(p.z * .01);
  float dist = p.y;
  // dist += - displacement * 10.;

  return Voxel(dist, color);
}

Voxel mapNormalRayMarching( vec3 p) {

  vec4 noiseTex = getTexture(uNoiseTexture, p.xz, 500.);
  // vec4 noiseTex = texture2D(uNoiseTexture, fract(p.xz / vec2(1000., 1000.)));

  Voxel voxel = ground(p, noiseTex);

  // voxel = smin(spheres(p, 100., 20., vec2(160.0), 1.), voxel);

  // voxel = min(groundmapNormalRayMarching(p), voxel);

  return voxel;
  // return voxel(length(p), vec4(1., 0., 0., .0));
}

Voxel mapGrid( vec3 p) {

  // vec4 noiseTex = getTexture(uNoiseTexture, p.xz, 500.);

  // Voxel voxel = Voxel(p.y + 5., vec4(hash1(p.x + p.y * 56.) * 50.));
  // 
  // Voxel voxel = Voxel(udRoundBox(p, vec3(50., 1., 50.), 0.), vec4(1.));
  // Voxel voxel = Voxel(sdSphere(p + vec3(0., 20., 0.), 20.), vec4(1.));
  Voxel voxel = Voxel(sdBox(p, vec3(250., 5., 250.)), vec4(1.));

  // Voxel voxel = Voxel(length(max(abs(p + vec3(0., - 8., 0.))-vec3(250., 1., 250.),0.0)), vec4(hash1(p.x + p.y * 56.) * 50.));
  voxel = smin(Voxel(sdSphere(p, 40.), vec4(hash1(p.x + p.y * 56.) * 50.)), voxel);

  // voxel = smin(, voxel);
  
  // vec4 noiseTex = texture2D(uNoiseTexture, fract(p.xz / vec2(1000., 1000.)));



  // voxel = min(groundmapNormalRayMarching(p), voxel);

  return voxel;
  // return voxel(length(p), vec4(1., 0., 0., .0));
}

vec3 calcNormalRayMarching ( vec3 p ) {
  vec2 e = vec2(1., 0.0);
  return normalize(vec3(
    mapNormalRayMarching(p + e.xyy).dist - mapNormalRayMarching(p - e.xyy).dist,
    mapNormalRayMarching(p + e.yxy).dist - mapNormalRayMarching(p - e.yxy).dist,
    mapNormalRayMarching(p + e.yyx).dist - mapNormalRayMarching(p - e.yyx).dist
  ));
}

vec3 calcNormalGridRayMarching ( vec3 p ) {
  vec2 e = vec2(1., 0.0);
  return normalize(vec3(
    mapGrid(p + e.xyy).dist - mapGrid(p - e.xyy).dist,
    mapGrid(p + e.yxy).dist - mapGrid(p - e.yxy).dist,
    mapGrid(p + e.yyx).dist - mapGrid(p - e.yyx).dist
  ));
}

Voxel trace( vec3 ro, vec3 rd)
{

  ro += uNear*rd;

  float cellSize = 500.;

  // ro = vec3(0., 0., 0.);

  Voxel voxel = Voxel( uFar, vec4(vec3(.5), 1.) );

  vec2 pos = floor(ro.xz);
  pos -= mod(pos, cellSize);
  vec3 rdi = 1.0/rd;
  vec3 rda = abs(rdi);
  vec2 rds = sign(rd.xz);
  vec2 dis = (pos-ro.xz+ 0.5 * cellSize + rds*0.5 * cellSize) * rdi.xz;
  
  // vec3 res = vec3( -1.0 );

  // traverse regular grid (in 2D)
  vec2 mm = vec2(0.0);
  for( int i=0; i<10; i++ ) 
  {        

    vec2 pr = pos+0.5-ro.xz;
    vec2 mini = (pr-0.5*rds)*rdi.xz;
    float s = max( mini.x, mini.y );
    if( (uNear+s)>uFar ) break;

    // intersect box
    vec3  ce = vec3( pos.x + 0.5 * cellSize, 2., pos.y+0.5 * cellSize );
    vec3  rb = vec3(0.3,2.,0.3);
    vec3  ra = rb + 0.12;
    vec3  rc = ro - ce;
    rc.y += hash1(pos) * 50.;
    float tN = maxcomp( -rdi*rc - rda*cellSize );
    float tF = maxcomp( -rdi*rc + rda*cellSize );
    if( tN < tF )//&& tF > 0.0 )
    {
      // raymarch
      float s = tN;
      float h = 1.0;
      for( float j=0.; j<32.; j++ )
      {
        h = mapGrid( rc+s*rd ).dist;
        s += h;
        if( s>tF ) break;
      }

      if( h < (.0001*s*2.0) )
      {
        vec3 nor = calcNormalGridRayMarching( rc+s*rd );
        // voxel.color.r = 1.;
        if (s < voxel.dist) { // TEST ADDED
          voxel.dist = s;
          voxel.color.rgb = nor;
          // break;
        }
      }
    }
        
    // step to next cell    
    mm = step( dis.xy, dis.yx ); 
    dis += mm*rda.xz * cellSize;
    pos += mm*rds * cellSize;
  }

  voxel.dist += uNear;

  // voxel.dist += .1;
     
  // vec2 cellPos = floor( rayOrigin.xz );
  // cellPos -= mod(cellPos, cellSize);
  // vec3 rayDirectionComp = 1.0/rayDirection;
  // vec3 rayDirectionCompAbs = abs(rayDirectionComp); 
  // vec2 rayDirectionSign = sign(rayDirection.xz);
  // vec2 cellDist = (cellPos - rayOrigin.xz + 0.5 * cellSize + rayDirectionSign * 0.5 * cellSize) * rayDirectionComp.xz;
  
  // Voxel voxel = Voxel( -1., vec4(0.) );
  // vec2 mm = vec2(0.0);
  // for( int i=0; i<40; i++ )
  // {
  //   vec3 center = vec3( cellPos.x + cellSize * .5, 0., cellPos.y + cellSize * .5);
  //   vec3 rayCenterOrigin = rayOrigin - center;

  //   // float tN = maxcomp( -rayDirectionComp * rayCenterOrigin - rayDirectionCompAbs * cellSize );
  //   // float tF = maxcomp( -rayDirectionComp * rayCenterOrigin + rayDirectionCompAbs * cellSize );
  //   // if( tN < tF ) {
  //     float dist = uNear;
  //     float rayMarchingStep = 1.;
  //     for( int j=0; j < 64; j++ )
  //     {
  //       voxel = mapGrid( rayCenterOrigin + dist * rayDirection);
  //       rayMarchingStep = voxel.dist;
  //       dist += rayMarchingStep;
  //       if (rayMarchingStep > uFar) break;
  //     }
  //     if( rayMarchingStep < .0001 * dist * 2.0 )
  //     {
  //       voxel = Voxel(dist, vec4(.5));
  //       break;
  //     }

  //   // }

  //   // step to next cell    
  //   vec2 mm = step( cellDist.xy, cellDist.yx ); 
  //   cellDist += mm * rayDirectionCompAbs.xz * cellSize;
  //   cellPos += mm * rayDirectionSign * cellSize;
  // }




  // classic raymarching

  // voxel = Voxel(uFar, vec4(0.0));

  // float rayMarchingStep = 0.00001;
  // float dist = uNear;

  // for(int i = 0; i < 64; i++) {
  //     if (rayMarchingStep < 0.00001 || rayMarchingStep > uFar) break;
  //     voxel = mapNormalRayMarching( ro + rd * dist);
  //     rayMarchingStep = voxel.dist;
  //     dist += rayMarchingStep;
  //     voxel.dist = dist;
  // }
  
  // if (dist < uFar) {
  //     voxel.color *= .75 + dot(calcNormalRayMarching(ro + rd * dist), vec3(0.0, 1.0, 0.0)) * .25;
  // }

  // voxel.color = vec4(1., 0., 0., 1.);
  return voxel;
  // return min(voxel, voxel2);
}

void main()
{
  float fovScaleY = tan((uFov / 180.0) * PI * .5);
  float aspect = uResolution.x / uResolution.y;

  vec2 position = ( gl_FragCoord.xy / uResolution.xy );
  position = position * 2. - 1.;

  vec3 vEye = -( uModelViewMatrix[3].xyz ) * mat3( uModelViewMatrix );
  vec3 vDir = vec3(position.x * fovScaleY * aspect, position.y * fovScaleY,-1.0) * mat3( uModelViewMatrix );
  vec3 vCameraForward = vec3( 0.0, 0.0, -1.0) * mat3( uModelViewMatrix );

  vec3 rayOrigin = vEye;
  vec3 rayDirection = normalize(vDir);
  
  Voxel voxel = trace(rayOrigin, rayDirection);

  // if( res.y > -0.5 )
  // {
    // float t = voxel.dist;
    // vec3 pos = rayOrigin + t * rayDirection;
    // vec3 nor = calcNormalGridRayMarching( pos, t );
      // material 
    // voxel.color.rgb = nor;
     //  col = 0.5 + 0.5*cos( 6.2831*res.y + vec3(0.0, 0.4, 0.8) );
     //  vec3 ff = texcube( iChannel1, 0.1*vec3(pos.x,4.0*res.z-pos.y,pos.z), nor ).xyz;
     //  col *= ff.x;

     //  // lighting
     // col = doLighting( col, ff.x, pos, nor, rd );
     // col *= 1.0 - smoothstep( 20.0, 40.0, t );
  // }

  // voxel = trace(vec3(.20, 5., 0.), rayDirection);
  // voxel = trace(rayOrigin, rayDirection);
  
  // voxel.color = vec4(vec3(voxel.dist / uFar), 1.);

  // float eyeHitZ = dist * dot(vCameraForward, rayDirection);
  float eyeHitZ = voxel.dist * dot(vCameraForward, rayDirection);

  float depth = eyeHitZ * 1.;

  depth = smoothstep( uNear, uFar, depth );

  gl_FragColor = vec4(voxel.color.rgb, 1.0 - depth);
  // gl_FragColor = vec4(voxel.color.rgb, 1.0);

}