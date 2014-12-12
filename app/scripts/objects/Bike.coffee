class Bike extends THREE.Object3D
  constructor: ->
    super()

    loader = new THREE.JSONLoader()
    loader.load 'models/bike.json', (geometry, materials) =>
      mesh = new THREE.Mesh(geometry, new THREE.MeshFaceMaterial(materials))
      @add mesh
      loader.load 'models/santa.json', (geometry, materials) =>
        @santa = new THREE.Mesh(geometry, new THREE.MeshFaceMaterial(materials))
        @add @santa
        return
      return
    null

  update: ->
    if @santa
      # console.log @rotation.z
      @santa.rotation.z += -@santa.rotation.z * .2
      @santa.quaternion.slerp @quaternion, .2
      @santa.rotation.x = 0
      @santa.rotation.y = 0
      if Math.abs(@santa.rotation.z) > .5
        @santa.rotation.z = if (@santa.rotation.z < 0) then -.5 else .5
    return