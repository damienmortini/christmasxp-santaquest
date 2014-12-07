class CameraControls
  constructor: (@camera, @object) ->
    @offsetQuaternion = new THREE.Quaternion()
    @offsetQuaternion.setFromEuler(new THREE.Euler(0, Math.PI, 0))
    @tempQuaternion = new THREE.Quaternion()

    @offsetAxis = new THREE.Vector3(0, 4, 10)

    @tempOffsetAxis = new THREE.Vector3()
    @tempPosition = new THREE.Vector3()
    return

  update: (dt) =>
    @tempQuaternion.copy @object.quaternion
    @tempQuaternion.multiply @offsetQuaternion
    @camera.quaternion.slerp @tempQuaternion, .1 * dt

    @tempOffsetAxis.copy @offsetAxis
    @tempOffsetAxis.applyQuaternion(@camera.quaternion)
    @tempPosition.copy @object.position
    @tempPosition.add @tempOffsetAxis
    @camera.position.lerp @tempPosition, .2 * dt
    return