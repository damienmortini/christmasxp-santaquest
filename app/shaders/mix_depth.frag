precision mediump float;

uniform sampler2D texture;
uniform sampler2D textureDepth;
uniform sampler2D textureAlphaDepth;

varying vec2 vUv;

void main() {
  vec4 color = texture2D( texture, vUv ) + texture2D( textureDepth, vUv ) + texture2D( textureAlphaDepth, vUv );
  // vec4 color = texture2D( test0, vUv );
  gl_FragColor = vec4(color.xyz, 1.);
}