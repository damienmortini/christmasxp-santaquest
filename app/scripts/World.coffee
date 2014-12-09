class World

  FREE_MODE = false

  constructor: (@canvas) ->
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera 75, @canvas.offsetWidth / @canvas.offsetHeight, .1, 1000
    @raf = null
    @renderer = new THREE.WebGLRenderer
      canvas: @canvas
      alpha: true
    @pointer =
      x: 0
      y: 0
    @gifts = []

    @deltaTimesSum = 0
    @deltaTimesNumber = 0

    @bike = new Bike()
    @bike.position.y = 10
    @scene.add @bike

    @bikeControls = new BikeControls(@bike, 2)

    if (FREE_MODE)
      @camera.position.z = 50
      @cameraControls = new THREE.TrackballControls(@camera)
    else
      @cameraControls = new CameraControls(@camera, @bike)

    @initComposer()

    @addLights()
    @addObjects()
    @addGifts()

    @progressionHandler = new ProgressionHandler(@gifts, @bike)

    @resize()

    @start()

    window.addEventListener 'resize', @resize
    # window.addEventListener 'mousemove', @onPointerMove
    return

  start: =>
    if @raf?
      return
    @prevTime = Date.now()
    @update()
    return

  stop: =>
    cancelAnimationFrame(@raf)
    @bikeControls.reset()
    @raf = null
    return

  addObjects: =>
    @helper = new THREE.Mesh(new THREE.IcosahedronGeometry(1), new THREE.MeshPhongMaterial())
    @scene.add @helper

    for i in [0...10]
      for j in [0...10]
        geometry = new THREE.BoxGeometry 200, 200, 200
        material = new THREE.MeshPhongMaterial
          color: 0xff0000

        cube = new THREE.Mesh geometry, material
        cube.position.set(
          Math.random() * 10000 - 5000
          100
          Math.random() * 10000 - 5000
        )
        @scene.add cube
    return

  addGifts: =>
    for i in [0...1]
      gift  = new Gift()
      gift.position.set(
        0
        30
        500
      )
      @gifts.push gift
      @scene.add gift
    return

  addLights: =>
    light = new THREE.DirectionalLight(0xffffff, 1)
    light.position.set 1, 1, 0
    @scene.add light

    light = new THREE.AmbientLight(0x333333)
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
    @worldShaderPass.uniforms['uNoiseTexture'].value = THREE.ImageUtils.loadTexture( 'images/tex03.jpg' )
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

    # copyShaderPass = new THREE.ShaderPass THREE.CopyShader
    # copyShaderPass.renderToScreen = true
    # @renderComposer.addPass copyShaderPass

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
    @raf = requestAnimationFrame @update

    time = Date.now()
    dt = (time - @prevTime) / 1000 * 60

    @deltaTimesSum += dt
    @deltaTimesNumber++

    dt = @deltaTimesSum / @deltaTimesNumber

    @progressionHandler.update(dt)
    
    @bikeControls.update(dt)
    @cameraControls.update(dt)

    @helper.position.set(0, 0, 0)
    @helper.position.add @progressionHandler.direction
    @helper.position.multiplyScalar(10)
    @helper.position.add @bike.position

    # render

    @worldShaderPass.uniforms['uTime'].value += dt / 60
    @worldShaderComposer.render()
    @renderComposer.render()
    @composer.render()

    @prevTime = time
    # @renderer.render(@scene, @camera)
    return