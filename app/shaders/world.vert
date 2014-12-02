precision mediump float;

#define PI 3.1415926535897932384626433832795

uniform float uCameraFov;
uniform vec2 uResolution;
uniform mat4 uModelViewMatrix;
uniform mat4 uProjectionMatrix;

varying vec3 vEye;
varying vec3 vDir;
varying vec3 vCameraForward;

void main() {

  vec4 vertex = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );

  float fovScaleY = tan((uCameraFov / 180.0) * PI * .5);
  float aspect = uResolution.x / uResolution.y;

  vEye = -( uModelViewMatrix[3].xyz ) * mat3( uModelViewMatrix );
  vDir = vec3(vertex.x * fovScaleY * aspect,vertex.y * fovScaleY,-1.0) * mat3( uModelViewMatrix );
  vCameraForward = vec3( 0.0, 0.0, -1.0) * mat3( uModelViewMatrix );

  gl_Position = vertex;
}