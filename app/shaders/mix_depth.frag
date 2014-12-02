precision highp float;

uniform sampler2D uTexture;
uniform sampler2D uTextureDepth;
uniform sampler2D uTextureAlphaDepth;

varying vec2 vUv;

void main() {
  vec4 texelTexture = texture2D( uTexture, vUv );
  vec4 texelTextureDepth = texture2D( uTextureDepth, vUv );
  vec4 texelTextureAlphaDepth = texture2D( uTextureAlphaDepth, vUv );

  vec3 color = vec3(0, 0, 0);

  if(texelTextureDepth.r > texelTextureAlphaDepth.a) {
    color = vec3(texelTextureDepth.rgb);
    color = texelTexture.rgb;
  }
  else {
    color = vec3(texelTextureAlphaDepth.a);
    color = texelTextureAlphaDepth.rgb;
  }

  // color = vec3(texelTextureAlphaDepth.a);
  // vec4 color = texture2D( test0, vUv );
  // gl_FragColor = vec4(vec3(texelTextureDepth.r), 1.);
  gl_FragColor = vec4(color, 1.);
}