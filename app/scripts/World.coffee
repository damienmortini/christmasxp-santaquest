class World
  constructor: (@canvas) ->
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera 75, @canvas.offsetWidth / @canvas.offsetHeight, .1, 10000
    @camera.position.z = -1000
    @renderer = new THREE.WebGLRenderer
      canvas: @canvas

    @pointer =
      x: 0
      y: 0

    @controls = new THREE.TrackballControls(@camera)

    @initComposer()
    @resize()
    @update()

    window.addEventListener 'resize', @resize
    window.addEventListener 'mousemove', @onPointerMove
    return

  buildShader: =>
    return {
      uniforms: 
        'resolution':
          type: 'v2'
          value: new THREE.Vector2()
        'time':
          type: 'f'
          value: 0
        'pointer':
          type: 'v2'
          value: new THREE.Vector2()
      vertexShader: document.querySelector('#world-shader-vertex').import.body.innerText
      fragmentShader: document.querySelector('#world-shader-fragment').import.body.innerText
    }

  initComposer: =>
    @composer = new THREE.EffectComposer @renderer, new THREE.WebGLRenderTarget() 

    @worldShaderPass = new THREE.ShaderPass @buildShader()
    @composer.addPass(lastPass = @worldShaderPass)

    @renderPass = new THREE.RenderPass @scene, @camera
    # @composer.addPass(lastPass = @renderPass)

    @fxaaShaderPass = new THREE.ShaderPass(THREE.FXAAShader)
    # @composer.addPass(lastPass = @fxaaShaderPass)

    lastPass.renderToScreen = true
    return

  onPointerMove: (e) =>
    @pointer.x = e.x
    @pointer.y = e.y
    return

  resize: =>
    @camera.aspect = @canvas.offsetWidth / @canvas.offsetHeight
    @camera.updateProjectionMatrix()
    devicePixelRatio = window.devicePixelRatio || 1
    width = window.innerWidth * devicePixelRatio
    height = window.innerHeight * devicePixelRatio
    @renderer.setSize width, height
    @fxaaShaderPass.uniforms['resolution'].value.set(1 / width, 1 / height)
    @worldShaderPass.uniforms['resolution'].value.set width, height
    @composer.setSize width, height
    return

  update: =>
    requestAnimationFrame @update
    @worldShaderPass.uniforms['time'].value += .01
    @worldShaderPass.uniforms['pointer'].value.x = @pointer.x
    @controls.update()
    @composer.render()
    return