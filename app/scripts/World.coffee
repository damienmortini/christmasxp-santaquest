class World
  constructor: (@canvas) ->
    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera 75, @canvas.offsetWidth / @canvas.offsetHeight, .1, 1000
    @renderer = new THREE.WebGLRenderer
      canvas: @canvas
    @resize()
    @update()

    window.addEventListener 'resize', @resize
    return

  resize: =>
    @camera.aspect = @canvas.offsetWidth / @canvas.offsetHeight
    @camera.updateProjectionMatrix()
    @renderer.setSize @canvas.offsetWidth, @canvas.offsetHeight
    return

  update: =>
    requestAnimationFrame @update
    @renderer.render @scene, @camera
    return