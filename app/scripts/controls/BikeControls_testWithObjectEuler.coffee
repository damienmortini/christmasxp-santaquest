class BikeControls
  FLAG_LEFT = 1
  FLAG_UP = 2
  FLAG_RIGHT = 4
  FLAG_DOWN = 8
  FLAG_SPACE = 16

  SPEED = 2
  DIRECTION_ROTATION_SPEED = new THREE.Vector3(1, 1, 1)
  OBJECT_ROTATION_SPEED = new THREE.Vector3(1, 1, 1)
  
  UP = new THREE.Vector3(0, 1, 0)
  FORWARD = new THREE.Vector3(0, 0, 1)
  RIGHT = new THREE.Vector3(1, 0, 0)

  GRAVITY = -.81

  constructor: (@object, @initialSpeed = 0) ->
    @keyFlags = 0
    @velocity = new THREE.Vector3()
    @movement = new THREE.Vector3()
    @directionEuler = new THREE.Euler()
    @objectEuler = new THREE.Euler()
    @directionQuaternion = new THREE.Quaternion()
    @objectQuaternion = new THREE.Quaternion()
    @currentVelocity = @velocity.clone()

    @speed = 0
    @groundRefY = @object.position.y

    window.addEventListener 'keydown', @onKeyDown
    window.addEventListener 'keyup', @onKeyUp
    return

  reset: =>
    @keyFlags = 0
    return

  onKeyDown: (e) =>
    switch e.keyCode
      when 32
        @keyFlags |= FLAG_SPACE
      when 37
        @keyFlags |= FLAG_LEFT
      when 38
        @keyFlags |= FLAG_UP
      when 39
        @keyFlags |= FLAG_RIGHT
      when 40
        @keyFlags |= FLAG_DOWN
    return

  onKeyUp: (e) =>
    switch e.keyCode
      when 32
        @keyFlags &= (31 - FLAG_SPACE)
      when 37
        @keyFlags &= (31 - FLAG_LEFT)
      when 38
        @keyFlags &= (31 - FLAG_UP)
      when 39
        @keyFlags &= (31 - FLAG_RIGHT)
      when 40
        @keyFlags &= (31 - FLAG_DOWN)
    return

  update: =>
    @objectEuler.set 0, 0, 0
    # horizontal
    if (@keyFlags & FLAG_RIGHT)
      @directionEuler.y -= DIRECTION_ROTATION_SPEED.y
      # @objectEuler.z = OBJECT_ROTATION_SPEED.z
      # @objectEuler.y = -OBJECT_ROTATION_SPEED.y
    if (@keyFlags & FLAG_LEFT)
      @directionEuler.y += DIRECTION_ROTATION_SPEED.y
      @objectEuler.z = -OBJECT_ROTATION_SPEED.z
      @objectEuler.y = OBJECT_ROTATION_SPEED.y
    # if !(@keyFlags & FLAG_RIGHT) and !(@keyFlags & FLAG_LEFT)
    #   @objectEuler.z = 0

    # speed
    @velocity.set 0, 0, @initialSpeed
    if (@keyFlags & FLAG_UP)
      @velocity.z += SPEED
    if (@keyFlags & FLAG_DOWN)
      @velocity.z -= SPEED

    # vertical
    # if (@keyFlags & FLAG_SPACE)
    #   @directionEuler.x -= DIRECTION_ROTATION_SPEED.x
    # else if @object.position.y is @groundRefY
    #   @directionEuler.x = 0
    # else
    #   @directionEuler.x = DIRECTION_ROTATION_SPEED.x

    # direction
    @directionQuaternion.setFromEuler(@directionEuler)
    # @velocity.applyQuaternion(@directionQuaternion)
    @velocity.y += GRAVITY

    # object
    @objectEuler
    @objectQuaternion.setFromEuler(@objectEuler)
    # @objectQuaternion.multiply @directionQuaternion
    @object.quaternion.slerp(@objectQuaternion, .1)

    @currentVelocity.lerp(@velocity, .1)
    # @object.position.add @currentVelocity

    if @object.position.y < @groundRefY
      @object.position.y = @groundRefY

    return
