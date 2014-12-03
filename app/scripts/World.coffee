class World
  constructor: (@canvas) ->
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera 75, @canvas.offsetWidth / @canvas.offsetHeight, 1, 400
    @camera.position.z = -100
    @renderer = new THREE.WebGLRenderer
      canvas: @canvas
      alpha: true
    @renderer.render(@scene, @camera)

    @pointer =
      x: 0
      y: 0

    # @controls = new THREE.FirstPersonControls(@camera)
    @controls = new THREE.TrackballControls(@camera)

    @initComposer()
    @resize()
    @update()

    plane = new THREE.Mesh(new THREE.PlaneGeometry(1000, 1000))
    plane.position.y = -5
    plane.rotation.x = -Math.PI * .5
    # @scene.add plane

    for i in [0...4]
      for j in [0...4]
        geometry = new THREE.BoxGeometry 20, 20, 20
        material = new THREE.MeshNormalMaterial
          color: 0x00ff00

        cube = new THREE.Mesh geometry, material
        cube.position.set(
          i * 40 - 40
          10
          j * 40 - 40
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
        'uCameraFov':
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
        'uModelViewMatrix':
          type: 'm4'
          value: new THREE.Matrix4()
        'uProjectionMatrix':
          type: 'm4'
          value: new THREE.Matrix4()
      vertexShader: document.querySelector('#world-shader-vertex').import.body.innerText
      fragmentShader: [
        document.querySelector('#noise-3d').import.body.innerText
        document.querySelector('#world-shader-fragment').import.body.innerText
      ].join('\n');
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
    )

    @worldShaderPass = new THREE.ShaderPass @createWorldShader()
    @worldShaderPass.needsSwap = false
    # @worldShaderPass.renderToScreen = true
    @worldShaderComposer.addPass @worldShaderPass

    # verticalBlurPass = new THREE.ShaderPass THREE.VerticalBlurShader
    # verticalBlurPass.uniforms['v'].value = .001
    # @worldShaderComposer.addPass verticalBlurPass

    # horizontalBlurPass = new THREE.ShaderPass THREE.HorizontalBlurShader
    # horizontalBlurPass.uniforms['h'].value = .001
    # @worldShaderComposer.addPass horizontalBlurPass

    # copyShaderPass = new THREE.ShaderPass THREE.CopyShader
    # copyShaderPass.renderToScreen = true
    # copyShaderPass.needsSwap = false
    # copyShaderPass.clear = true
    # @worldShaderComposer.addPass copyShaderPass

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

    @mixDepthShaderPass = new THREE.ShaderPass @createMixDepthShader()

    # @mixDepthShaderPass.needsSwap = false
    # @mixDepthShaderPass.renderToScreen = true
    @composer.addPass @mixDepthShaderPass

    # copyShaderPass = new THREE.ShaderPass THREE.CopyShader
    # @composer.addPass copyShaderPass

    # verticalBlurPass = new THREE.ShaderPass THREE.VerticalBlurShader
    # verticalBlurPass.uniforms['v'].value = .01
    # @composer.addPass verticalBlurPass

    # horizontalBlurPass = new THREE.ShaderPass THREE.HorizontalBlurShader
    # horizontalBlurPass.uniforms['h'].value = .01
    # @composer.addPass horizontalBlurPass

    @fxaaShaderPass = new THREE.ShaderPass(THREE.FXAAShader)
    @fxaaShaderPass.renderToScreen = true
    @composer.addPass(@fxaaShaderPass)

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
    width = Math.floor(window.innerWidth * devicePixelRatio)
    height = Math.floor(window.innerHeight * devicePixelRatio)
    @fxaaShaderPass.uniforms['resolution'].value.set 1 / width, 1 / height
    @worldShaderPass.uniforms['uResolution'].value.set width * .5, height * .5
    @renderer.setSize width, height
    @worldShaderComposer.setSize width * .5, height * .5
    @renderComposer.setSize width, height
    @composer.setSize width, height

    @worldShaderPass.uniforms['uCameraAspect'].value = @camera.aspect
    @worldShaderPass.uniforms['uCameraNear'].value = @camera.near
    @worldShaderPass.uniforms['uCameraFar'].value = @camera.far
    @worldShaderPass.uniforms['uCameraFov'].value = @camera.fov
    @worldShaderPass.uniforms['uModelViewMatrix'].value = @camera.matrixWorldInverse
    @worldShaderPass.uniforms['uProjectionMatrix'].value = @camera.projectionMatrix
    @mixDepthShaderPass.uniforms['uTextureAlphaDepth'].value = @worldShaderComposer.renderTarget1
    @mixDepthShaderPass.uniforms['uTexture'].value = @renderComposer.renderTarget2
    @mixDepthShaderPass.uniforms['uTextureDepth'].value = @renderComposer.renderTarget1
    return

  update: =>
    # console.log @worldShaderPass.uniforms['uModelViewMatrix'].value.elements
    # return
    requestAnimationFrame @update
    @worldShaderPass.uniforms['uTime'].value += .01
    @worldShaderPass.uniforms['uPointer'].value.x = @pointer.x
    @controls.update()
    @worldShaderComposer.render()
    @renderComposer.render()
    @composer.render()

    # @renderer.render(@scene, @camera)

    @worldShaderPass.uniforms['uCameraPosition'].value.copy @camera.position
    @worldShaderPass.uniforms['uCameraRotation'].value.copy @camera.rotation
    @worldShaderPass.uniforms['uCameraQuaternion'].value.copy @camera.quaternion



    # console.log @controls.object.rotation, @camera.object.position
    # @worldShaderPass.uniforms['uCameraQuaternion'].value.inverse()

    # console.log @camera.quaternion
    # console.log @worldShaderPass.uniforms['uCameraRotation'].value
    return