class MixDepthShader
  constructor: ->
    @uniforms =
      'uTexture':
        type: 't'
        value: null
      'uTextureDepth':
        type: 't'
        value: null
      'uTextureAlphaDepth':
        type: 't'
        value: null
      'uNoiseTexture':
        type: 't'
        value: THREE.ImageUtils.loadTexture( 'images/tex03.jpg' )
    
    @vertexShader = document.querySelector('#mix-depth-shader-vertex').innerText
    
    @fragmentShader = document.querySelector('#mix-depth-shader-fragment').innerText
    
    return