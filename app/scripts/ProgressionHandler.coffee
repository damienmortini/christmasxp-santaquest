class ProgressionHandler
  constructor: (@gifts, @object, @soundsMatrix) ->

    @onChangeLevel = new signals.Signal()

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
    if 49 <= e.keyCode <= 53
      @gotoLevel(e.keyCode - 48)
    else if e.keyCode is 69
      @gotoLevel(@level + 1)
    return

  gotoLevel: (level) =>
    @level = level
    @onChangeLevel.dispatch(level)
    return

  update: =>
    @progress += (@level - @progress) * .1

    if @grabbedGift
      @grabbedGift.scale.x += (.1 - @grabbedGift.scale.x) * .8
      @grabbedGift.scale.y += (.1 - @grabbedGift.scale.y) * .8
      @grabbedGift.scale.z += (.1 - @grabbedGift.scale.z) * .8
      @grabbedGift.position.lerp @object.position, .5
      @grabbedGift.position.y += 3
      @grabbedGift.rotation.x += .08
      @grabbedGift.rotation.y += .06
      @grabbedGift.rotation.z += .1
      if @soundsMatrix.playbackPosition % 16 is 15
        @grabbedGift.open()
        @grabbedGift = null
        @gotoLevel(@level + 1)
      return


    if !@gifts.length
      return

    @direction.subVectors(@gifts[0].position, @object.position).normalize()
    @objectDirection.set(0, 0, 1).applyQuaternion(@object.quaternion)
    @hotness = (@direction.dot(@objectDirection) + 1) / 2

    for gift in @gifts
      gift.rotation.x += .02
      gift.rotation.y += .04
      gift.rotation.z += .06
      if @object.position.distanceTo(gift.position) < 100
        @gifts.splice(@gifts.indexOf(gift), 1)
        @grabbedGift = gift
        break

    return