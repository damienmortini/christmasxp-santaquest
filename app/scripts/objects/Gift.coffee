class Gift extends THREE.Object3D
  constructor: ->
    super()

    @opened = false

    loader = new THREE.JSONLoader()
    loader.load '../models/gift2.json', (geometry, materials) =>
      mesh = new THREE.Mesh(geometry, new THREE.MeshFaceMaterial(materials))
      mesh.scale.set(15, 15, 15)
      @add mesh
      return
    
    null

  open: =>
    @visible = false
    @opened = true
    return