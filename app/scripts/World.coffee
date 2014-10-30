class World
  constructor: (@canvas) ->
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera 75, @canvas.offsetWidth / @canvas.offsetHeight, .1, 10000
    @camera.position.z = -1000
    @renderer = new THREE.WebGLRenderer
      canvas: @canvas

    @controls = new THREE.TrackballControls(@camera)

    @resize()
    @update()

    @path = new Path()
    @scene.add @path

    window.addEventListener 'resize', @resize
    return

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