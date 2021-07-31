
export const sampleConfig = {
    "Platform_1": [
        { network: 0, slots: "A-2-11", color: "blue" },
        { network: 0, slots: "B-5-9", color: "yellow" },
    ],
    "Platform_2": [
        { network: 1, slots: "B-40-9", color: "blue" },
    ]
}

export type IConfig = typeof sampleConfig

export type ISchedule = Array<{ platform: string, color: string }>

export class TimeSlotScheduler {
    activeSlot: number
    activePlatformNames: Array<string>
    activeColors: Array<string>
    #sched: Array<ISchedule>
    networkCount: number


    constructor(config: IConfig) {
        this.activeSlot = -1
        this.#sched = this.parse(config)
        this.networkCount = this.#sched.length
        this.step()
    }

    step() {
        this.activeSlot = (this.activeSlot + 1) % 1536
        this.activePlatformNames = this.#sched.map(sched => sched[this.activeSlot]?.platform ?? 'NA')
        this.activeColors = this.#sched.map(sched => sched[this.activeSlot]?.color ?? 'pink')
    }

    private parse(conf: IConfig): Array<ISchedule> {
        return Object.entries(conf).reduce((sched, [platform, cfg]) => {
            cfg.forEach(({ network, slots, color }) => {
                let allocs = sched[network] || []
                let slotIdxs = this.toSlotRange(slots)
                for (let i of slotIdxs) {
                    allocs[i] = { platform, color }
                }
                sched[network] = allocs
            })
            return sched
        }, [])
    }

    private toSlotRange(slot: string) {
        let [_x, _y, _z] = slot.split('-')
        let [x, y, z] = [_x, parseInt(_y), parseInt(_z)]
        let factor = x == 'A' ? 2 : (x == 'B' ? 1 : 0)
        let slots = []
        for (let n = 0; n < 32; n++) {
            let num = (y + 2 * (15 - z) * n) + 1
            let slot = num - factor
            if (slot > 1536) {
                break
            }
            slots.push(slot)
        }
        return slots
    }
}