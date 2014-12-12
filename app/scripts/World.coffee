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

    @deltaTimesSum = 0
    @deltaTimesNumber = 0

    @onChangeLevel = new signals.Signal()

    @quality = .5

    # @soundsMatrix = new SoundsMatrix()
    @soundsMatrix = new SoundsMatrix(true)

    @soundsMatrix.loadSound 'HO_BeatE128-17', .2, false

    @soundsMatrix.loadSound 'HO_FilPiano128E-02'
    @soundsMatrix.loadSound 'HO_Chi Lead128E-04'
    @soundsMatrix.loadSound 'HO_BrokeBass128B-05'
    @soundsMatrix.loadSound 'HO_MesBass128C-05'

    @soundsMatrix.loadSound 'HO_Chi Lead128E-01'

    @bike = new Bike()
    @bike.position.y = 10
    @camera.position.y = 10
    @scene.add @bike

    @bikeControls = new BikeControls(@bike, 4)

    if (FREE_MODE)
      @camera.position.z = 50
      @cameraControls = new THREE.TrackballControls(@camera)
    else
      @cameraControls = new CameraControls(@camera, @bike)

    @initComposer()

    @addLights()
    @addObjects()
    
    @progressionHandler = new ProgressionHandler(@addGifts(), @bike, @soundsMatrix)
    @progressionHandler.onChangeLevel.add @onProgressionChangeLevel

    @resize()

    window.addEventListener 'resize', @resize
    # window.addEventListener 'mousemove', @onPointerMove
    return

  start: =>
    if @raf?
      return
    @prevTime = Date.now()
    @soundsMatrix.setSoundAt @soundsMatrix.sounds[0].id, [0, 16, 32, 48]
    @update()
    return

  stop: =>
    cancelAnimationFrame(@raf)
    @bikeControls.reset()
    @raf = null
    return

  addObjects: =>
    @helperPositionTarget = new THREE.Vector3()
    @helper = new THREE.Mesh(new THREE.IcosahedronGeometry(10, 1), new THREE.MeshPhongMaterial(
      emissive: 0xcccccc
    ))
    @scene.add @helper

    # for i in [0...10]
    #   for j in [0...10]
    #     geometry = new THREE.BoxGeometry 200, 200, 200
    #     material = new THREE.MeshPhongMaterial
    #       color: 0xff0000

    #     cube = new THREE.Mesh geometry, material
    #     cube.position.set(
    #       Math.random() * 10000 - 5000
    #       100
    #       Math.random() * 10000 - 5000
    #     )
    #     @scene.add cube
    return

  addGifts: =>
    gifts = []
    for i in [0...@soundsMatrix.analysers.length]
      gift  = new Gift()
      gift.position.set(
        Math.random() * 8000 - 4000
        30
        Math.random() * 8000 - 4000
      )
      gifts.push gift
      @scene.add gift
    gifts[0].position.x = 0
    gifts[0].position.z = 2000
    return gifts

  addLights: =>
    light = new THREE.DirectionalLight(0xffffff, 2)
    light.position.set 1, 1, 0
    @scene.add light

    light = new THREE.AmbientLight(0x333333)
    @scene.add light

    @light = new THREE.PointLight(0xffcccc, 3)
    @scene.add @light

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

  onProgressionChangeLevel: (level) =>

    @onChangeLevel.dispatch(level)
    if level >= @soundsMatrix.sounds.length - 1
      if level is @soundsMatrix.sounds.length - 1
        @soundsMatrix.volumeFade(.01)
      else
        @soundsMatrix.volumeFade(1)
      return
    for i in [0...@soundsMatrix.sounds.length]
      @soundsMatrix.removeSoundAt @soundsMatrix.sounds[i].id, [0, 16, 32, 48]
    for i in [0...level + 1]
      @soundsMatrix.setSoundAt @soundsMatrix.sounds[i].id, [0, 16, 32, 48]

    return

  onPointerMove: (e) =>
    @pointer.x = e.x
    @pointer.y = e.y
    return

  resize: (e, @quality = .5) =>
    console.log @quality
    @camera.aspect = @canvas.offsetWidth / @canvas.offsetHeight
    @camera.updateProjectionMatrix()
    devicePixelRatio = window.devicePixelRatio || 1
    width = Math.floor(window.innerWidth)
    height = Math.floor(window.innerHeight)
    @fxaaShaderPass.uniforms['resolution'].value.set 1 / (width * devicePixelRatio), 1 / (height * devicePixelRatio)
    @worldShaderPass.uniforms['uResolution'].value.set width * @quality, height * @quality
    @renderer.setSize width, height
    @worldShaderComposer.setSize width * @quality, height * @quality
    @renderComposer.setSize width, height
    @composer.setSize width * devicePixelRatio, height * devicePixelRatio

    @worldShaderPass.uniforms['uNear'].value = 20
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
    deltaTime = (time - @prevTime) / 1000 * 60

    @deltaTimesSum += deltaTime
    @deltaTimesNumber++

    smoothDeltaTime = @deltaTimesSum / @deltaTimesNumber

    @soundsMatrix.update()
    @progressionHandler.update(smoothDeltaTime)
    @bikeControls.update(smoothDeltaTime)
    @cameraControls.update(smoothDeltaTime)
    @bike.update(smoothDeltaTime)

    @helperPositionTarget.set(0, 0, 0)
    @helperPositionTarget.add @progressionHandler.direction
    @helperPositionTarget.multiplyScalar(500)
    @helperPositionTarget.add @bike.position
    @helperPositionTarget.y += 10

    @helper.position.lerp @helperPositionTarget, .05

    @light.position.copy @helper.position


    for byteFrequencyData, i in @soundsMatrix.byteFrequenciesData
      sound = 0
      for value in byteFrequencyData
        sound += value
      sound /= 256 * byteFrequencyData.length
      @worldShaderPass.uniforms['uSounds'].value[i] = sound
    
    # render

    @worldShaderPass.uniforms['uTime'].value += deltaTime
    @worldShaderPass.uniforms['uProgress'].value = @progressionHandler.progress
    @worldShaderPass.uniforms['uDirectionHotness'].value += (@progressionHandler.hotness - @worldShaderPass.uniforms['uDirectionHotness'].value) * .1
    @worldShaderPass.uniforms['uLightPosition'].value.copy @helper.position
    @worldShaderComposer.render()
    @renderComposer.render()
    @composer.render()

    @prevTime = time
    # @renderer.render(@scene, @camera)
    return