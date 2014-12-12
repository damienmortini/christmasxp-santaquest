class Gift extends THREE.Object3D
  constructor: ->
    super()

    @opened = false

    loader = new THREE.JSONLoader()
    loader.load 'models/gift2.json', (geometry, materials) =>
      mesh = new THREE.Mesh(geometry, new THREE.MeshFaceMaterial(materials))
      mesh.scale.set(15, 15, 15)
      @add mesh
      return
    
    null

  open: =>
    TweenLite.to @scale, .5, {x: .2, y:.2, z:.2}
    TweenLite.to @scale, .2, {x: 20, y:20, z:20, delay: 1}
    # TweenLite.to @position, 1, {x: @position.x + Math.random() * 500 - 250, z: @position.z + Math.random() * 500 - 250}
    @opened = true
    return