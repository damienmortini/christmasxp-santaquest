class Path extends THREE.Object3D

	PLANE_LENGTH = 1000

	constructor: ->

		super()

		@pipes = []

		lastPosition = new THREE.Vector3()

		@totalLength = Math.PI * 2 * 10

		@_refObject = new THREE.Object3D()
		@_vTemp = new THREE.Vector3()

		geometry = new THREE.PlaneGeometry(1, PLANE_LENGTH, 1, PLANE_LENGTH)

		tempObject = new THREE.Object3D()
		v = new THREE.Vector3()
		for i in [0...geometry.vertices.length * .5]
			vertice1 = geometry.vertices[i * 2]
			vertice2 = geometry.vertices[i * 2 + 1]

			progress = (@totalLength / PLANE_LENGTH) * i

			v.x = -100
			@setObjectOnPath tempObject, progress, v
			vertice1.x = tempObject.position.x
			vertice1.y = tempObject.position.y
			vertice1.z = tempObject.position.z

			v.x = 100
			@setObjectOnPath tempObject, progress, v
			vertice2.x = tempObject.position.x
			vertice2.y = tempObject.position.y
			vertice2.z = tempObject.position.z

		geometry.computeFaceNormals()
		geometry.computeVertexNormals

		plane = new THREE.Mesh geometry, new THREE.MeshNormalMaterial(
			side: THREE.DoubleSide
		)

		@add plane

		plane2 = plane.clone()
		plane2.position.z = @getObjectOnPath(@totalLength).position.z
		@add plane2

		null

	getObjectOnPath: (progress) =>
		object3d = new THREE.Object3D()
		@setObjectOnPath(object3d, progress)
		return object3d

	setObjectOnPath: (object3d, progress, vOffset) =>
		@computeFormula progress, object3d.position
		@computeFormula progress + 0.00001, @_vTemp
		object3d.lookAt @_vTemp

		if vOffset?
			@_vTemp.copy vOffset
		else
			@_vTemp.set 0, 0, 0

		@_vTemp.applyQuaternion(object3d.quaternion)
		object3d.position.add(@_vTemp)

		null

	computeFormula: (progress, v) =>
		v.x = (Math.cos(progress) + Math.sin(progress * .1) * 10) * Math.cos(progress * .5) * .5
		v.y = (Math.cos((progress + 100)) + Math.sin((progress + 100) * .1) * 10) * Math.cos((progress + 100) * .5) * .5
		v.z = progress
		v.multiplyScalar 500
		null

