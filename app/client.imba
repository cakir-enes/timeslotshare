import { TimeAllocVis } from './timeallocvis'
import * as THREE from 'three';
import * as dat from 'dat.gui'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import gsap from 'gsap'
import './timeallocvis'

global css html
	ff:sans

def resizeRendererToDisplaySize renderer
	
	let canvas = renderer.domElement
	let pixelRatio = window.devicePixelRatio
	let width = canvas.clientWidth * pixelRatio | 0
	let height = canvas.clientHeight * pixelRatio | 0
	let needResize = canvas.width !== width || canvas.height !== height
	if needResize
		renderer.setSize width, height, false
	needResize


def timeslot
	let duration = 7.8ms


tag app
	global css
		html, body 
			m:0 h:100% bg:blue4 p:0

	gui = new dat.GUI!
	
	def dat obj
		
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

	def createCone
		geom =  new THREE.ConeGeometry 0.5, 2, 8
		mat = new THREE.MeshBasicMaterial { wireframe: true, color: 0xFFff00 }
		new THREE.Mesh geom, mat


	def mount
	
		scene = new THREE.Scene!
		camera = new THREE.PerspectiveCamera 75, 2, 0.1
		# camera = new THREE.OrthographicCamera  -10, 10, 10, -10
		renderer = new THREE.WebGLRenderer {canvas: $body, antialias: true}
		# renderer.setSize window.innerWidth, window.innerHeight
		raycaster = new THREE.Raycaster!
		renderer.setClearColor new THREE.Color('#21282a'), 1
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

		plane = (do
			geomx = new THREE.PlaneGeometry 10, 10, 10, 10
			mate = new THREE.MeshBasicMaterial {wireframe: true, color: 0xFFffFF}
			new THREE.Mesh geomx, mate)!
		
		light = (do
			l = new THREE.AmbientLight 0xffffff, 0.0
			l.position.set 0, 0, 2
			l)!
		
		light2 = (do
			l = new THREE.DirectionalLight 0xffffff, 1
			l.position.set 0, 10, 30
			l)!
		
		pointLight = new THREE.PointLight 0xFFFFFF, 1.0		
		spotLight = new THREE.SpotLight 0xFF8080, 1.0, 25.0, Math.PI / 4.0, 0.5, 1.0

		# geom = new THREE.TorusGeometry 12, 3.5, 1536, 20
		radial = 10
		platformCount = 10
		stride = Math.floor(1536 / platformCount)
		tubular = 1536
		geom = new THREE.TorusGeometry 0.5, 0.5, radial, tubular
		# geom = new THREE.WireframeGeometry geom
		mat = new THREE.MeshPhongMaterial { flatShading: true, vertexColors: true }
		spotLight.castShadow = true
		torus = new THREE.Mesh geom, mat
		torus.position.z = 2

		colors = (do
			c = []
			for j in [0 .. radial]
				for i in [0 .. tubular]
					if i < 100
						c.push 1,0,0
					else
						c.push 0, 1, 0
			c)!

		torus.geometry.setAttribute('color', new THREE.BufferAttribute(new Float32Array(colors), 3))

		pointLight.position.set 0, 10, 0
		scene.add light
		# scene.add light2
		# scene.add light2.target 
		scene.add plane
		# cone = createCone!
		# cone.rotateX Math.PI
		# cone.position.setY torus.position.y + cone.geometry.parameters.height * 2.2
		
		# scene.add cone
		scene.add pointLight

		helper = new THREE.PointLightHelper pointLight, 2
		v = new TimeAllocVis gui
		scene.add v.mesh
		v.mesh.rotateX Math.PI / 2

		# self.dat {plane}
		light2.position.set(0, 10, 4)
		
		v.mesh.position.set(0, 0, 0)
		camera.position.set( -10, 10, 6);
		camera.lookAt( 0, 0, 0 );
		window.geom = v.mesh.geometry
		plane.rotateX(Math.PI / 2)
		plane.position.setY -4
		plane.scale.setX 4
		plane.scale.setY 4
		animate = do |now|
			window.requestAnimationFrame animate
			if resizeRendererToDisplaySize(renderer) 
				canvas = renderer.domElement
				camera.aspect = canvas.clientWidth / canvas.clientHeight
				camera.updateProjectionMatrix!

			renderer.render scene, camera
			raycaster.setFromCamera mouse, camera
			intersects = [] || raycaster.intersectObject torus
			v.step now
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
		imba.commit!

	mouse = { x: undefined, y: undefined }
	
	get tx
		if v
			v.#alloc.activeSlot??.tx[0] ?? "EMPTY"
		else
			"NOT READY"
	
	def mouseMoved e
		mouse.x = (e.clientX / window.innerWidth) * 2 - 1
		mouse.y = -(e.clientY / window.innerHeight) * 2 + 1

	<self>
		<div[pos:absolute t:10 l:25% c:white d:flex w:50vw jc:space-between]>
			<div[d:hflex]>
				<h1> tx
				<h1> '@'
				<h1> 1234

		<canvas$body[w:100% h:100% d:block bg:green2] @mousemove=mouseMoved>

imba.mount <app>