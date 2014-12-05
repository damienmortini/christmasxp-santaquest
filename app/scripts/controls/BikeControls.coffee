class Controls
  FLAG_LEFT = 1
  FLAG_UP = 2
  FLAG_RIGHT = 4
  FLAG_DOWN = 8
  FLAG_SPACE = 16

  SPEED = 2
  JUMP_INTENSITY = 3
  ROTATION_SPEED = .05

  GRAVITY = -.81

  constructor: (@object, @initialSpeed = 0) ->
    @keyFlags = 0
    @velocity = new THREE.Vector3()
    @movement = new THREE.Vector3()
    @euler = new THREE.Euler()
    @quaternion = new THREE.Quaternion()
    @currentEuler = @euler.clone()
    @currentVelocity = @velocity.clone()

    @speed = 0
    @groundRefY = @object.position.y

    window.addEventListener 'keydown', @onKeyDown
    window.addEventListener 'keyup', @onKeyUp
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
    if (@keyFlags & FLAG_RIGHT)
      @euler.y -= ROTATION_SPEED
    if (@keyFlags & FLAG_LEFT)
      @euler.y += ROTATION_SPEED
    @movement.z = @initialSpeed
    if (@keyFlags & FLAG_UP)
      @movement.z = @initialSpeed + SPEED
    if (@keyFlags & FLAG_DOWN)
      @movement.z = if (@movement.z is SPEED) then 0 else @initialSpeed - SPEED

    @quaternion.setFromEuler(@euler)
    @object.quaternion.slerp(@quaternion, .1)
    @velocity.copy @movement
    @velocity.applyQuaternion(@object.quaternion)

    @velocity.y += GRAVITY

    if (@keyFlags & FLAG_SPACE && @object.position.y is @groundRefY)
      @currentVelocity.y += JUMP_INTENSITY

    @currentVelocity.lerp(@velocity, .1)
    
    @object.position.add @currentVelocity

    if @object.position.y < @groundRefY
      @object.position.y = @groundRefY
    return
