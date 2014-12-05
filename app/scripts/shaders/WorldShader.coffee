class WorldShader
  constructor: ->
    @uniforms =
      'uResolution':
        type: 'v2'
        value: new THREE.Vector2()
      'uNear':
        type: 'f'
        value: 0
      'uFar':
        type: 'f'
        value: 0
      'uFov':
        type: 'f'
        value: 0
      'uTime':
        type: 'f'
        value: 0
      'uModelViewMatrix':
        type: 'm4'
        value: new THREE.Matrix4()
      'uProjectionMatrix':
        type: 'm4'
        value: new THREE.Matrix4()

    @vertexShader = document.querySelector('#world-shader-vertex').import.body.innerText

    @fragmentShader = [
      document.querySelector('#noise-3d').import.body.innerText
      document.querySelector('#world-shader-fragment').import.body.innerText
    ].join('\n')

    return