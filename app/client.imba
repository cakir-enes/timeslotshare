import * as THREE from 'three';
import * as dat from 'dat.gui'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import gsap from 'gsap'

global css html
	ff:sans

def resizeRendererToDisplaySize renderer
	
	let canvas = renderer.domElement
	let pixelRatio = window.devicePixelRatio
	let width = canvas.clientWidth * pixelRatio | 0
	let height = canvas.clientHeight * pixelRatio | 0
	let needResize = canvas.width !== width || canvas.height !== height
	if needResize
		console.log "RESIZE"
		renderer.setSize width, height, false
	needResize

tag app
	global css 
		html, body 
			m:0 h:100% bg:blue4


	def dat obj
		gui = new dat.GUI!
		world = {
			plane: {
				width: 10,
				height: 10,
				widthSegments: 10,
				heightSegments: 10
			}
		}
		def refreshPlane
			obj.plane.geometry.dispose!
			obj.plane.geometry = new THREE.TorusGeometry world.plane.width, world.plane.height, world.plane.widthSegments, world.plane.heightSegments
			arr = obj.plane.geometry.attributes.position.array
			for _, i in arr by 3
				[x, y, z] = [arr[i], arr[i+1], arr[i+2]]
				arr[i + 2] = z + Math.random!
			colors = (do
				c = []
				for i in [0 .. plane.geometry.attributes.position.count]
					c.push(0, 0.19, 0.4)
				c)!
			plane.geometry.setAttribute('color', new THREE.BufferAttribute(new Float32Array(colors), 3))


		gui.add(world.plane, 'width', 1, 20).onChange refreshPlane
		gui.add(world.plane, 'height', 1, 10).onChange refreshPlane
		gui.add(world.plane, 'heightSegments', 1, 100).onChange refreshPlane
		gui.add(world.plane, 'widthSegments', 1, 100).onChange refreshPlane
			

	def mount
	
		scene = new THREE.Scene!
		camera = new THREE.PerspectiveCamera 75, 2, 0.1
		renderer = new THREE.WebGLRenderer {canvas: $body}
		# renderer.setSize window.innerWidth, window.innerHeight
		raycaster = new THREE.Raycaster!

		new OrbitControls camera, renderer.domElement
		# $body.appendChild renderer.domElement

		# geom = new THREE.BoxGeometry 1, 1, 1
		# material = new THREE.MeshBasicMaterial { color: 0x00ff00 }
		# cube = new THREE.Mesh geom, material
		
		cube = (do 
			geom = new THREE.BoxGeometry 1, 1, 1
			material = new THREE.MeshBasicMaterial { color: 0x00ff00 }
			new THREE.Mesh geom, material)!
		
		line = (do
			material = new THREE.LineBasicMaterial {color: 0x0000ff}
			points = []
			points.push new THREE.Vector3 -10, 0, 0
			points.push new THREE.Vector3 0, 10, 0
			points.push new THREE.Vector3 10, 0, 0
			
			geom = new THREE.BufferGeometry().setFromPoints points
			new THREE.Line geom, material)!

		# plane = (do
		# 	geom = new THREE.TorusGeometry 12, 3.5, 1, 10
		# 	mat = new THREE.MeshPhongMaterial {   flatShading: true, vertexColors: true}
		# 	new THREE.Mesh geom, mat)!
		
		light = (do
			l = new THREE.DirectionalLight 0xffffff, 1
			l.position.set 0, 0, 1
			l)!
		
		light2 = (do
			l = new THREE.DirectionalLight 0xffffff, 1
			l.position.set 0, 0, -1
			l)!
		
		# geom = new THREE.TorusGeometry 12, 3.5, 1536, 20
		radial = 10
		platformCount = 200
		tubular = Math.floor(1536 / platformCount)
		geom = new THREE.TorusGeometry 12, 3.5, radial, tubular
		mat = new THREE.MeshPhongMaterial { flatShading: true, vertexColors: true }

		torus = new THREE.Mesh geom, mat

		# arr = torus.geometry.attributes.position.array
		# for _, i in arr by 3
		# 	[x, y, z] = [arr[i], arr[i+1], arr[i+2]]
		# 	arr[i + 2] = z + Math.random!
		
		
		colors = (do
			c = []
			console.log geom
			for j in [0 .. radial]
				for i in [0 .. tubular]
					if i < 10
						c.push 1,0,0
					else
						c.push 0, 1, 0
						
			# for i in [0 .. torus.geometry.attributes.position.count]
			# 	if i < 1537
			# 		c.push 1, 0, 0
			# 	else
			# 		c.push 0, 1, 0
			console.log c.length, " ", torus.geometry.attributes.position.count * 3 
			c)!

		torus.geometry.setAttribute('color', new THREE.BufferAttribute(new Float32Array(colors), 3))

		scene.add light
		scene.add light2
		# scene.add plane
		scene.add torus

		# self.dat {plane}

		camera.position.z = 30
		# camera.position.set( 0, 0, 5 );
		# camera.lookAt( 0, 0, 0 );

		animate = do
			window.requestAnimationFrame animate
			if resizeRendererToDisplaySize(renderer) 
				console.log "RENDEER"
				canvas = renderer.domElement
				camera.aspect = canvas.clientWidth / canvas.clientHeight
				camera.updateProjectionMatrix!

			renderer.render scene, camera
			raycaster.setFromCamera mouse, camera
			intersects = [] || raycaster.intersectObject torus

			if intersects.length > 0
				{ color }  = intersects[0].object.geometry.attributes
				
				changeColor = do |{r, g, b}|
					
					{ face } = intersects[0]
					if !face
						return
					color.setX(face.a, r)
					color.setY(face.a, g)
					color.setZ(face.a, b)
					
					color.setX(face.b, r)
					color.setY(face.b, g)
					color.setZ(face.b, b)
					
					color.setX(face.c, r)
					color.setY(face.c, g)
					color.setZ(face.c, b)
					color.needsUpdate = true

				
				initialColor = { r: 0, g: .19, b: .4}
				hoverColor = { r: 0.1, g: 0.5, b: 1}
				
				gsap.to hoverColor, Object.assign({ onUpdate: do changeColor hoverColor}, initialColor)
				

		animate!

	mouse = { x: undefined, y: undefined }
	
	
	
	def mouseMoved e
		mouse.x = (e.clientX / window.innerWidth) * 2 - 1
		mouse.y = -(e.clientY / window.innerHeight) * 2 + 1

	<self>
		<canvas$body[w:100% h:100% d:block bg:green2] @mousemove=mouseMoved>

imba.mount <app>