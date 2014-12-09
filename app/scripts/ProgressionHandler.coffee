class ProgressionHandler
  constructor: (@gifts, @object) ->
    @soundsMatrix = new SoundsMatrix(true)
    @soundsMatrix.loadSound 'chimney1'
    @soundsMatrix.loadSound 'chimney2'
    @soundsMatrix.loadSound 'chimney3'
    @soundsMatrix.loadSound 'chimney4'
    @soundsMatrix.loadSound 'chimney5'

    @direction = new THREE.Vector3()
    @objectDirection = new THREE.Vector3()

    @hotness = 0
    @level = 0

    # dir = new THREE.Vector3(0, 0, 1)
    # origin = new THREE.Vector3(0, 0, 0)
    # length = 10
    # hex = 0xff0000
    # @arrowHelper = new THREE.Object3D()
    # arrow = new THREE.ArrowHelper(dir, origin, length, hex)
    # @arrowHelper.add arrow

    # @soundsMatrix.toggleSoundAt 'chimney2', [0, 16, 32, 48]
    # @soundsMatrix.toggleSoundAt 'chimney3', [0, 16, 32, 48]
    # @soundsMatrix.toggleSoundAt 'chimney4', [0, 16, 32, 48]
    return

  gotoNextLevel: =>
    @level++
    @soundsMatrix.toggleSoundAt "chimney#{@level}", [0, 16, 32, 48]
    return

  update: =>
    @soundsMatrix.update()

    if !@gifts.length
      return

    @direction.subVectors(@gifts[0].position, @object.position).normalize()
    @objectDirection.set(0, 0, 1).applyQuaternion(@object.quaternion)
    @hotness = (@direction.dot(@objectDirection) + 1) / 2

    for gift in @gifts
      if @object.position.distanceTo(gift.position) < 40
        gift.open()
        @gifts.splice(@gifts.indexOf(gift), 1)
        @gotoNextLevel()
        break
        
    return