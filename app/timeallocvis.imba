import { cfg_1, TimeAlloc } from '../../../../../Users/enescakir/proj/imbo/app/timealloc'
import type { Color } from '@types/three'
import * as THREE from 'three';

export class TimeAllocVis

	prop platforms
	size = {
			radius: 3,
			tube: 0.3,
			radial: 30,
			tubular: 1536
		}

	def constructor gui
		
		platforms = [
			{ id: "taramali", slots: [[1, 10], [12, 20]], color: 'red' }
		]

		geom = new THREE.TorusGeometry size.radius, size.tube, size.radial, size.tubular
		# mat = new THREE.MeshPhongMaterial { flatShading: true, vertexColors: true }
		mat = new THREE.PointsMaterial { transparent: true, size: 0.0001, vertexColors: true }
		
		mesh = new THREE.Points geom, mat
		mesh.position.z = 2
		

		gui.add(size, 'radius', 1, 5).onChange do createTorus!
		gui.add(size, 'tube', 0.1, 2.5).onChange do createTorus!
		gui.add(size, 'radial', 2, 500).onChange do 
			fillColors!
			createTorus!

		#color = new THREE.Color!
		
		fillColors!	
		createTorus!

		#alloc = new TimeAlloc cfg_1 
		console.log #alloc.colors
		for color, i of #alloc.colors
			#color.setColorName color
			setTubeColor i, #color


		#currentSlot = 0

	def fillColors
		#colors = new Float32Array((size.radial + 1) * (size.tubular + 1) * 3)
		#color.setColorName('blue')
		setTubesColor 0, size.tubular, #color

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
		#color.setHSL 0.2, 0.6, 1
		setTubesColor 0, 1, #color
		# mesh.rotation.x += 0.01;
		if (now * 0.001) %  2 > 0
			#alloc.step!

		mesh.rotation.z = activeSlotRad #alloc.#slotIndex
		mesh.geometry.attributes.color.needsUpdate = true
		
