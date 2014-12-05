class Bear extends THREE.Object3D
  constructor: (@mesh) ->
    super()

    @add mesh

    # @mesh.material.vertexColors = THREE.FaceColors
    # @mesh.material.morphTargets = true

    @mesh.scale.set .1, .1, .1

    console.log @mesh.material.morphTargets
    # @mesh.material.morphNormals = true
    # @mesh.material.transparent = true
    # @mesh.material.blending = THREE.AdditiveBlending

    # for face in @mesh.geometry.faces
    #   face.color.r = Math.random() * .8 + .2
    #   face.color.g = Math.random() * .8 + .2
    #   face.color.b = Math.random() * .8 + .2



    @animation = new THREE.MorphAnimation( @mesh )
    @animation.play()
    
    @mesh.geometry.faces

    null

  update: =>
    # console.log @animation
    @animation.update( .1 );
    # if @isRunning
    #   if @position.z > 0
    #     @rotation.y += @angleOffset * @speed
    #   @position.z += Math.cos(@rotation.y) * @speed * .2
    #   @position.x += Math.sin(@rotation.y) * @speed * .2
    #   if @position.distanceTo(World.scene.camera.position) > 60
    #     @reset()
    return