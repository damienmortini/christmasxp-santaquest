class ProgressionHandler
  constructor: (@gifts, @object) ->
    @soundsMatrix = new SoundsMatrix(true)
    @soundsMatrix.loadSound 'chimney1'
    @soundsMatrix.loadSound 'chimney2'
    @soundsMatrix.loadSound 'chimney3'
    @soundsMatrix.loadSound 'chimney4'
    @soundsMatrix.loadSound 'chimney5'
    @soundsMatrix.loadSound 'chimney6'

    @direction = new THREE.Vector3()
    @objectDirection = new THREE.Vector3()

    @hotness = 0
    @level = 0
    @progress = 0

    @grabbedGift = null

    # dir = new THREE.Vector3(0, 0, 1)
    # origin = new THREE.Vector3(0, 0, 0)
    # length = 10
    # hex = 0xff0000
    # @arrowHelper = new THREE.Object3D()
    # arrow = new THREE.ArrowHelper(dir, origin, length, hex)
    # @arrowHelper.add arrow

    # @soundsMatrix.toggleSoundAt 'chimney6', [0, 16, 32, 48]
    # @soundsMatrix.toggleSoundAt 'chimney3', [0, 16, 32, 48]
    # @soundsMatrix.toggleSoundAt 'chimney4', [0, 16, 32, 48]

    window.addEventListener 'keydown', @onKeyDown

    return

  onKeyDown: (e) =>
    console.log e.keyCode
    if 49 <= e.keyCode <= 53
      @gotoLevel(e.keyCode - 48)
    else if e.keyCode is 69
      @gotoLevel(@level + 1)
    return

  gotoLevel: (level) =>
    @soundsMatrix.toggleSoundAt "chimney#{level}", [0, 16, 32, 48]
    @level = level
    return

  update: =>
    @soundsMatrix.update()

    if @grabbedGift
      @grabbedGift.scale.x += (.1 - @grabbedGift.scale.x) * .8
      @grabbedGift.scale.y += (.1 - @grabbedGift.scale.y) * .8
      @grabbedGift.scale.z += (.1 - @grabbedGift.scale.z) * .8
      @grabbedGift.position.lerp @object.position, .8
      @grabbedGift.position.y += 5
      @grabbedGift.rotation.x += .08
      @grabbedGift.rotation.y += .06
      @grabbedGift.rotation.z += .1
      if @soundsMatrix.playbackPosition % 16 is 15
        @grabbedGift.open()
        @grabbedGift = null
        @gotoLevel(@level + 1)

    @progress += (@level - @progress) * .1

    if !@gifts.length
      return

    @direction.subVectors(@gifts[0].position, @object.position).normalize()
    @objectDirection.set(0, 0, 1).applyQuaternion(@object.quaternion)
    @hotness = (@direction.dot(@objectDirection) + 1) / 2

    for gift in @gifts
      if @object.position.distanceTo(gift.position) < 100
        @gifts.splice(@gifts.indexOf(gift), 1)
        @grabbedGift = gift
        break

    return