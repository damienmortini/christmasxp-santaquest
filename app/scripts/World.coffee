class World
  constructor: (@canvas) ->
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera 75, @canvas.offsetWidth / @canvas.offsetHeight, .1, 200
    @camera.position.z = -100
    @renderer = new THREE.WebGLRenderer
      canvas: @canvas
      alpha: true
    @renderer.render(@scene, @camera)

    @pointer =
      x: 0
      y: 0

    @controls = new THREE.TrackballControls(@camera)

    @initComposer()
    @resize()
    @update()

    for i in [0...20]
      geometry = new THREE.BoxGeometry 20, 20, 20
      material = new THREE.MeshNormalMaterial
        color: 0x00ff00
      cube = new THREE.Mesh geometry, material
      cube.position.set(
        Math.random() * 100 - 50
        Math.random() * 100 - 50
        Math.random() * 100 - 50
      )
      @scene.add cube

    window.addEventListener 'resize', @resize
    window.addEventListener 'mousemove', @onPointerMove
    return

  createWorldShader: ->
    return {
      uniforms:
        'uCameraAspect':
          type: 'f'
          value: 0
        'uCameraNear':
          type: 'f'
          value: 0
        'uCameraFar':
          type: 'f'
          value: 0
        'uCameraRotation':
          type: 'v3'
          value: new THREE.Vector3()
        'uCameraQuaternion':
          type: 'v4'
          value: new THREE.Quaternion()
        'uCameraPosition':
          type: 'v3'
          value: new THREE.Vector3()
        'uResolution':
          type: 'v2'
          value: new THREE.Vector2()
        'uTime':
          type: 'f'
          value: 0
        'uPointer':
          type: 'v2'
          value: new THREE.Vector2()
      vertexShader: document.querySelector('#world-shader-vertex').import.body.innerText
      fragmentShader: document.querySelector('#world-shader-fragment').import.body.innerText
    }

  createMixDepthShader: ->
    return {
      uniforms:
        'uTexture':
          type: 't'
          value: null
        'uTextureDepth':
          type: 't'
          value: null
        'uTextureAlphaDepth':
          type: 't'
          value: null
      vertexShader: document.querySelector('#mix-depth-shader-vertex').import.body.innerText
      fragmentShader: document.querySelector('#mix-depth-shader-fragment').import.body.innerText
    }

  initComposer: =>

    @worldShaderComposer = new THREE.EffectComposer @renderer, new THREE.WebGLRenderTarget(1, 1,
      minFilter: THREE.LinearFilter
      magFilter: THREE.LinearFilter
      format: THREE.RGBAFormat
      stencilBuffer: false
    )

    @worldShaderPass = new THREE.ShaderPass @createWorldShader()
    @worldShaderPass.needsSwap = false
    # @worldShaderPass.renderToScreen = true
    @worldShaderComposer.addPass @worldShaderPass

    # copyShaderPass = new THREE.ShaderPass THREE.CopyShader
    # copyShaderPass.renderToScreen = true
    # copyShaderPass.needsSwap = false
    # copyShaderPass.clear = true
    # @worldShaderComposer.addPass copyShaderPass

    @renderComposer = new THREE.EffectComposer @renderer, new THREE.WebGLRenderTarget(1, 1,
      minFilter: THREE.LinearFilter
      magFilter: THREE.LinearFilter
      format: THREE.RGBFormat
      stencilBuffer: false
    )
    renderPass = new THREE.RenderPass @scene, @camera
    renderPass.needsSwap = true
    # renderPass.clear = false
    @renderComposer.addPass renderPass

    renderPass = new THREE.RenderPass @scene, @camera, new THREE.MeshDepthMaterial()
    # renderPass.clear = false
    renderPass.needsSwap = false
    @renderComposer.addPass renderPass

    @composer = new THREE.EffectComposer @renderer, new THREE.WebGLRenderTarget(1, 1,
      minFilter: THREE.LinearFilter
      magFilter: THREE.LinearFilter
      format: THREE.RGBFormat
      stencilBuffer: false
    )

    @mixDepthShaderPass = new THREE.ShaderPass @createMixDepthShader()

    @mixDepthShaderPass.needsSwap = false
    @mixDepthShaderPass.renderToScreen = true
    @composer.addPass @mixDepthShaderPass

    # copyShaderPass = new THREE.ShaderPass THREE.CopyShader
    # @composer.addPass copyShaderPass

    # @fxaaShaderPass = new THREE.ShaderPass(THREE.FXAAShader)
    # @fxaaShaderPass.renderToScreen = true
    # @composer.addPass(@fxaaShaderPass)

    # @fxaaShaderPass.uniforms['resolution'].value.set 512, 512

    return

  onPointerMove: (e) =>
    @pointer.x = e.x
    @pointer.y = e.y
    return

  resize: =>
    @camera.aspect = @canvas.offsetWidth / @canvas.offsetHeight
    @camera.updateProjectionMatrix()
    devicePixelRatio = window.devicePixelRatio || 1
    width = Math.floor(window.innerWidth * devicePixelRatio * .5)
    height = Math.floor(window.innerHeight * devicePixelRatio * .5)
    # @fxaaShaderPass.uniforms['resolution'].value.set 1 / width, 1 / height
    @worldShaderPass.uniforms['uResolution'].value.set width, height
    @renderer.setSize width, height
    @worldShaderComposer.setSize width, height
    @renderComposer.setSize width, height
    @composer.setSize width, height

    @worldShaderPass.uniforms['uCameraAspect'].value = @camera.aspect
    @worldShaderPass.uniforms['uCameraNear'].value = @camera.near
    @worldShaderPass.uniforms['uCameraFar'].value = @camera.far
    @mixDepthShaderPass.uniforms['uTextureAlphaDepth'].value = @worldShaderComposer.renderTarget1
    @mixDepthShaderPass.uniforms['uTexture'].value = @renderComposer.renderTarget2
    @mixDepthShaderPass.uniforms['uTextureDepth'].value = @renderComposer.renderTarget1
    return

  update: =>
    requestAnimationFrame @update
    @worldShaderPass.uniforms['uTime'].value += .01
    @worldShaderPass.uniforms['uPointer'].value.x = @pointer.x
    @controls.update()
    @worldShaderComposer.render()
    @renderComposer.render()
    @composer.render()

    @worldShaderPass.uniforms['uCameraPosition'].value.copy @camera.position
    @worldShaderPass.uniforms['uCameraRotation'].value.copy @camera.rotation
    @worldShaderPass.uniforms['uCameraQuaternion'].value.copy @camera.quaternion
    # @worldShaderPass.uniforms['uCameraQuaternion'].value.inverse()

    # console.log @camera.quaternion
    # console.log @worldShaderPass.uniforms['uCameraRotation'].value
    return