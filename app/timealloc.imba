
export const cfg_1 = [
	{
		name: "f16-1",
		tx: [[0, 768]],
		rx: [[768, 1536]],
		color: "blue"
	},
	{
		name: "f16-2",
		tx: [[768, 1536]],
		rx: [[0, 768]],
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
			
		

	
	def step
		#slotIndex = ++#slotIndex % 1536

	def parseConfig cfg
		let c = {platforms: {}, schedule: []}
		for platform of cfg
			c.platforms[platform.name] =  platform

			for txRange of platform.tx
				for i in [txRange[0]...txRange[1]]
					if c.schedule[i]
						c.schedule[i].tx.push platform.name
					else
						c.schedule[i] = {tx: [platform.name], rx: []}
						
			for rxRange of platform.rx
				for i in [rxRange[0]...rxRange[1]]
					if c.schedule[i]
						c.schedule[i].rx.push platform.name
					else
						c.schedule[i] = {rx: [platform.name], tx: []}
		c
				
