class Tree extends THREE.Object3D
  constructor: ->
    super()

    loader = new THREE.JSONLoader()
    loader.load '../models/Tree.json', (geometry) =>
      mesh = new THREE.Mesh(geometry, new THREE.MeshPhongMaterial(
        color: 0xffffff
      ))
      @add mesh
      return
    
    null