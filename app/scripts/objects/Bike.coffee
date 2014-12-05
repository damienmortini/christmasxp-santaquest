class Bike extends THREE.Object3D
  constructor: (@mesh) ->
    super()

    @isLoaded = false
    @prevTime = 0
    @mesh = null
    @animation = null

    @loader = new THREE.JSONLoader()
    @loader.load '../models/bike.js', (geometry) =>
      geometry.computeMorphNormals()

      @mesh = new THREE.MorphAnimMesh(geometry, new THREE.MeshPhongMaterial(
        color: 0xdd8888
        morphTargets: true
      ))
      # @mesh.scale.set .5, .5, .5
      @add @mesh
      @isLoaded = true
      # @animation = new THREE.MorphAnimation(@mesh)
      # @animation.play()
      @prevTime = Date.now()
      return
    
    null

  update: =>
    if !@isLoaded
      return

    time = Date.now()
    @mesh.updateAnimation( time - @prevTime )
    @prevTime = time
    return