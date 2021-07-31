import { TimeSlotScheduler } from './TimeSlotScheduler'
import * as THREE from 'three'


export const cfg_1 = [
	{
		name: "f16-1",
		tx: [670, [0, 657]],
		color: "blue"
	},
	{
		name: "f16-2",
		tx: [[768, 1536]],
		color: "orange"
	},
]

const config = {
	platforms: {"f16-1": {name: "f16-1", color: "blue"}},
	schedule: []
}

export class TimeAlloc
	
	def constructor cfg
		#config = parseConfig cfg
		#slotIndex = 0
		#color = new THREE.Color('blue')
		v = new TimeSlotScheduler()

	get activeSlot
		let s = #config.schedule[#slotIndex]
		return s
	
	get colors
		let c = []
		for i in [0...1536]
			let p = #config.schedule[i]?.tx[0]
			if p 
				c.push #config.platforms[p].color
			else
				c.push "black"
		c

	get activeColor
		let p = #config.schedule[#slotIndex]?.tx[0]
		if p
			#color.setColorName #config.platforms[p].color
		else
			#color.setColorName 'white'
		#color
	

		
	def step
		#slotIndex = ++#slotIndex % 1536
		imba.commit!

	def parseConfig cfg
		let c = {platforms: {}, schedule: []}
		for platform of cfg
			c.platforms[platform.name] = platform

			
			for txRange of platform.tx

				if typeof txRange is 'number'
					console.log "ahha"
					if !c.schedule[txRange]
						c.schedule[txRange] = {tx: [], rx: []}
					c.schedule[txRange].tx.push platform.name
					continue
			
				for i in [txRange[0]...txRange[1]]
					if c.schedule[i]
						c.schedule[i].tx.push platform.name
					else
						c.schedule[i] = {tx: [platform.name], rx: []}
		c
				
