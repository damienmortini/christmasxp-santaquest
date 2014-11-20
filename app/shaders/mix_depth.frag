precision mediump float;

uniform sampler2D uTexture;
uniform sampler2D uTextureDepth;
uniform sampler2D uTextureAlphaDepth;

varying vec2 vUv;

void main() {
  vec4 color = texture2D( uTexture, vUv ) + texture2D( uTextureDepth, vUv ) + texture2D( uTextureAlphaDepth, vUv );
  // vec4 color = texture2D( test0, vUv );
  gl_FragColor = vec4(color.xyz, 1.);
}