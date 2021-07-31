import { cfg_1, TimeAlloc } from './timealloc'
import type { Color } from '@types/three'
import * as THREE from 'three';
	
	
	



const vertexShader = '
varying vec2 vUv;

void main() {
	vUv = uv;

	vec4 mvp = modelViewMatrix * vec4(position, 1.0);
	gl_Position = projectionMatrix * mvp;
}
'

let fragmentShader = '
uniform vec3 colorA;
uniform vec3 colorB;
varying vec2 vUv;

void main() {
	float val = clamp(round(sin(1536. / 2. * vUv.x * 3.14156)), 0.0, 1.0);
	gl_FragColor = vec4(mix(colorA, colorB, val), 1.0);
	
}
'

fragmentShader = '
uniform vec3 colorA;
uniform vec3 colorB;
varying vec2 vUv;

void main() {
	float val = floor(fract(vUv.x * 6. / 2.) + 0.5);
	gl_FragColor = vec4(mix(colorA, colorB, val), 1.0);
	
}
'

# fragmentShader = '
# uniform vec3 colorA;
# uniform vec3 colorB;
# varying vec2 vUv;

# void main() {
# 	float scaledT = fract(vUv.x * 1536. / 2.);

#     float frac1 = clamp(scaledT / 0.5, 0.0, 1.0);
#     float frac2 = clamp((scaledT - 0.5) / 0.5, 0.0, 1.0);

#     frac1 = frac1 * (1.0 - frac2);
#     frac1 = frac1 * frac1 * (3.0 - (2.0 * frac1));

#     vec3 finalColor = mix(colorA, colorB, frac1);
#     finalColor = finalColor;

#     gl_FragColor = vec4(finalColor, 1.0);
# }
# '


export class TimeAllocVis

	prop platforms
	size = {
			radius: 8,
			tube: 1,
			radial: 100,
			tubular: 1536
		}

	def constructor gui
		
		platforms = [
			{ id: "taramali", slots: [[1, 10], [12, 20]], color: 'red' }
		]

		geom = new THREE.TorusGeometry size.radius, size.tube, size.radial, size.tubular
		# geom = geom.toNonIndexed()
		mat = new THREE.MeshPhongMaterial { dithering: true, flatShading: true,  vertexColors: true }
		# mat = new THREE.MeshBasicMaterial { flatShading: true,  vertexColors: true }
		# mat = new THREE.PointsMaterial { transparent: false, size: 0.0001, vertexColors: true }
		
		uniforms = {
			colorA: { type:'vec3', value: new THREE.Color('blue')},
			colorB: { type:'vec3', value: new THREE.Color('orange')}
		}
		# mat = new THREE.ShaderMaterial {uniforms, fragmentShader: fragmentShader, vertexShader: vertexShader}

		# mesh = new THREE.Points geom, mat
		mesh = new THREE.Mesh geom, mat
		mesh.position.z = 2
		

		gui.add(size, 'radius', 1, 5).onChange do createTorus!
		gui.add(size, 'tube', 0.1, 2.5).onChange do createTorus!
		gui.add(size, 'radial', 2, 500).onChange do 
			fillColors!
			createTorus!

		#color = new THREE.Color!
		
		fillColors!	
		createTorus!
		# mesh.scale.setScalar 1.5

		#alloc = new TimeAlloc cfg_1 
		

		#currentSlot = 0
		# mesh.rotateX Math.PI / 2

	def fillColors
		#colors = new Float32Array((size.radial + 1) * (size.tubular + 1) * 3)
		# color.setColorName('blue')
		black = new THREE.Color('black')
		gray = new THREE.Color('gray')
		# setTubesColor 0, size.tubular, #color
		for i in [0 .. size.tubular]
			setTubeColor i, i % 2 == 0 ? black : gray

	def createTorus
		mesh.geometry.dispose!
		mesh.geometry = new THREE.TorusGeometry size.radius, size.tube, size.radial, size.tubular
		mesh.geometry.setAttribute('color', new THREE.BufferAttribute(#colors, 3))
		
	
	def setTubesColor from, to,  color\Color
		for i in [from .. to]
			setTubeColor i, color
	
	def setTubeColor i\number, color\Color
		for ind in tubeIndexes(i)
			#colors.set(color.toArray!, ind)
			

	def tubeIndexes i
		idx = []
		for j in [0 .. size.radial]
			idx.push i * 3 + j * size.tubular * 3 + 3 * j
		idx
	

	def activeSlotRad n
		THREE.MathUtils.degToRad(90) + THREE.MathUtils.degToRad(360 / 1536) * n
		
	active = 0
	def step now
		# color.setHSL 0.2, 0.6, 1
		# setTubesColor 0, 1, #color
		# mesh.rotation.x += 0.01;
		if (now * 0.001) %  2 > 0
			setTubeColor #alloc.#slotIndex, new THREE.Color(#alloc.#slotIndex % 2 == 0 ? 'black' : 'gray')
			#alloc.step!
			setTubeColor #alloc.#slotIndex, #alloc.activeColor
			mesh.geometry.attributes.color.needsUpdate = true

		# mesh.rotation.z = activeSlotRad #alloc.#slotIndex
		
