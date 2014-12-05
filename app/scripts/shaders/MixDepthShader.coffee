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
    
    @vertexShader = document.querySelector('#mix-depth-shader-vertex').import.body.innerText
    
    @fragmentShader = document.querySelector('#mix-depth-shader-fragment').import.body.innerText
    
    return