class World
  constructor: (@canvas) ->
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera 75, @canvas.offsetWidth / @canvas.offsetHeight, .1, 400
    @camera.position.y = 2
    @renderer = new THREE.WebGLRenderer
      canvas: @canvas
      alpha: true
    @pointer =
      x: 0
      y: 0
    
    @controls = new Controls(@camera)

    # @camera.position.z = 50
    # @controls = new THREE.TrackballControls(@camera)

    @initComposer()

    @addLights()
    @addObjects()

    @resize()
    @update()

    window.addEventListener 'resize', @resize
    window.addEventListener 'mousemove', @onPointerMove
    return

  addObjects: =>
    plane = new THREE.Mesh(new THREE.PlaneGeometry(1000, 1000))
    plane.position.y = -5
    plane.rotation.x = -Math.PI * .5
    @scene.add plane

    for i in [0...40]
      for j in [0...40]
        geometry = new THREE.BoxGeometry 5, 5, 5
        material = new THREE.MeshNormalMaterial
          color: 0x00ff00

        cube = new THREE.Mesh geometry, material
        cube.position.set(
          i * 40 - 40
          10
          j * 40 - 40
        )
        @scene.add cube
    return

  addLights: =>
    light = new THREE.DirectionalLight(0xffffff, 0.5)
    light.position.set 0, 1, 0
    @scene.add light
    return

  initComposer: =>
    @worldShaderComposer = new THREE.EffectComposer @renderer, new THREE.WebGLRenderTarget(1, 1,
      minFilter: THREE.LinearFilter
      magFilter: THREE.LinearFilter
      format: THREE.RGBAFormat
    )

    @worldShaderPass = new THREE.ShaderPass new WorldShader()
    @worldShaderPass.needsSwap = false
    @worldShaderComposer.addPass @worldShaderPass

    @renderComposer = new THREE.EffectComposer @renderer, new THREE.WebGLRenderTarget(1, 1,
      minFilter: THREE.LinearFilter
      magFilter: THREE.LinearFilter
      format: THREE.RGBFormat
    )
    renderPass = new THREE.RenderPass @scene, @camera
    renderPass.needsSwap = true
    @renderComposer.addPass renderPass

    renderPass = new THREE.RenderPass @scene, @camera, new THREE.MeshDepthMaterial()
    renderPass.needsSwap = false
    @renderComposer.addPass renderPass

    copyShaderPass = new THREE.ShaderPass THREE.CopyShader
    copyShaderPass.renderToScreen = true
    @renderComposer.addPass copyShaderPass

    @composer = new THREE.EffectComposer @renderer, new THREE.WebGLRenderTarget(1, 1,
      minFilter: THREE.LinearFilter
      magFilter: THREE.LinearFilter
      format: THREE.RGBFormat
      stencilBuffer: false
    )

    @mixDepthShaderPass = new THREE.ShaderPass new MixDepthShader()
    @composer.addPass @mixDepthShaderPass

    @fxaaShaderPass = new THREE.ShaderPass(THREE.FXAAShader)
    @fxaaShaderPass.renderToScreen = true
    @composer.addPass(@fxaaShaderPass)

    return

  onPointerMove: (e) =>
    @pointer.x = e.x
    @pointer.y = e.y
    return

  resize: =>
    @camera.aspect = @canvas.offsetWidth / @canvas.offsetHeight
    @camera.updateProjectionMatrix()
    devicePixelRatio = window.devicePixelRatio || 1
    width = Math.floor(window.innerWidth * devicePixelRatio)
    height = Math.floor(window.innerHeight * devicePixelRatio)
    @fxaaShaderPass.uniforms['resolution'].value.set 1 / width, 1 / height
    @worldShaderPass.uniforms['uResolution'].value.set width * .5, height * .5
    @renderer.setSize width, height
    @worldShaderComposer.setSize width * .5, height * .5
    @renderComposer.setSize width, height
    @composer.setSize width, height

    @worldShaderPass.uniforms['uNear'].value = @camera.near
    @worldShaderPass.uniforms['uFar'].value = @camera.far
    @worldShaderPass.uniforms['uFov'].value = @camera.fov
    @worldShaderPass.uniforms['uModelViewMatrix'].value = @camera.matrixWorldInverse
    @worldShaderPass.uniforms['uProjectionMatrix'].value = @camera.projectionMatrix
    @mixDepthShaderPass.uniforms['uTextureAlphaDepth'].value = @worldShaderComposer.renderTarget1
    @mixDepthShaderPass.uniforms['uTexture'].value = @renderComposer.renderTarget2
    @mixDepthShaderPass.uniforms['uTextureDepth'].value = @renderComposer.renderTarget1
    return

  update: =>
    requestAnimationFrame @update

    @worldShaderPass.uniforms['uTime'].value += .01
    @controls.update()
    @worldShaderComposer.render()
    @renderComposer.render()
    @composer.render()

    # @renderer.render(@scene, @camera)
    return