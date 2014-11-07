class World
  constructor: (@canvas) ->
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera 75, @canvas.offsetWidth / @canvas.offsetHeight, .1, 10000
    @camera.position.z = -1000
    @renderer = new THREE.WebGLRenderer
      canvas: @canvas

    @controls = new THREE.TrackballControls(@camera)

    # @initComposer()
    @resize()
    @update()

    window.addEventListener 'resize', @resize
    return

  initComposer: =>
    parameters = { minFilter: THREE.LinearFilter, magFilter: THREE.LinearFilter, format: THREE.RGBFormat, stencilBuffer: false }
    devicePixelRatio = window.devicePixelRatio || 1

    @composer = new THREE.EffectComposer @renderer, new THREE.WebGLRenderTarget(window.innerWidth * devicePixelRatio, window.innerHeight * devicePixelRatio, parameters) 
    
    renderPass = new THREE.RenderPass @scene, @camera

    shaderPass = new THREE.ShaderPass WorldShader
    # shaderPass.uniforms[ 'tDiffuse2' ].value = @composer1.renderTarget2
    @composer.addPass shaderPass

    # renderPass = new THREE.RenderPass @scene, @camera
    # @composer.addPass renderPass

    shaderPass = new THREE.ShaderPass(THREE.FXAAShader)
    shaderPass.uniforms['resolution'].value.set(1 / (window.innerWidth * devicePixelRatio), 1 / (window.innerHeight * devicePixelRatio))
    shaderPass.renderToScreen = true
    @composer.addPass shaderPass
    null

  resize: =>
    @camera.aspect = @canvas.offsetWidth / @canvas.offsetHeight
    @camera.updateProjectionMatrix()
    @renderer.setSize @canvas.offsetWidth, @canvas.offsetHeight
    return

  update: =>
    requestAnimationFrame @update
    @controls.update()
    @renderer.render @scene, @camera
    return