import * as THREE from 'three';
import { AmbientLight, Camera, Color, DirectionalLight, PerspectiveCamera, PointLight, Renderer, RGBA_ASTC_8x5_Format, Scene, WebGLRenderer } from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';
import { sampleConfig, TimeSlotScheduler } from './TimeSlotScheduler';

const size = { radius: 8, tube: 1, radial: 100, tubular: 1536 }

function resizeRendererToDisplaySize(renderer: Renderer) {
    let canvas = renderer.domElement
    let pixelRatio = window.devicePixelRatio
    let width = canvas.clientWidth * pixelRatio | 0
    let height = canvas.clientHeight * pixelRatio | 0
    let needResize = canvas.width !== width || canvas.height !== height
    if (needResize)
        renderer.setSize(width, height, false)
    return needResize
}

export function schedulerView(canvas: HTMLCanvasElement) {
    const scene = new THREE.Scene()

    const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000)

    const renderer = new THREE.WebGLRenderer({ canvas, antialias: true })
    renderer.setSize(window.innerWidth, window.innerHeight)

    const controls = new OrbitControls(camera, renderer.domElement)

    const geometry = new THREE.TorusGeometry()
    const material = new THREE.MeshBasicMaterial({ color: 0x0000ff, wireframe: true })

    const cube: THREE.Mesh = new THREE.Mesh(geometry, material)
}

export class TimeSlotSchedulerView {
    #colors: Array<Float32Array>
    renderer: WebGLRenderer
    #camera: PerspectiveCamera
    #scene: Scene
    #scheduler: TimeSlotScheduler
    #colorUpdaters = []
    #color = new THREE.Color()



    constructor(canvas) {

        this.#scheduler = new TimeSlotScheduler(sampleConfig)
        let group = new THREE.Group()
        this.#colors = []

        for (let i = 0; i < this.#scheduler.activePlatformNames.length; i++) {
            let mesh = this.buildTorus()
            mesh.position.x = 0
            mesh.position.y = 0
            mesh.position.z = 2 * i
            let colors = this.torusColorAttrib()
            this.#colors.push(colors)
            mesh.geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3))
            this.#colorUpdaters.push(() => { mesh.geometry.attributes.color.needsUpdate = true })
            group.add(mesh)
        }
        this.buildScene(canvas, '#ff0000')
        this.#scene.add(group)

        let geomx = new THREE.PlaneGeometry(100, 100, 100, 100)
        let mate = new THREE.MeshBasicMaterial({ wireframe: true, color: 0xFFffFF })
        let planem = new THREE.Mesh(geomx, mate)
        const hlight = new AmbientLight(0x404040, 1); // let scene = this.#scene 
        this.#scene.add(hlight);

        const light = new PointLight(0xc4c4c4, 1);
        light.position.set(0, 0, 50);
        this.#scene.add(light);
        const light2 = new PointLight(0xc4c4c4, 1);
        light.position.set(0, 0, 10);
        this.#scene.add(planem)
        this.#camera.position.z = 20
        this.animate(new Date().getMilliseconds())
    }

    get activePlatformNames() {
        return this.#scheduler.activePlatformNames
    }

    get activeSlotIndex() {
        return this.#scheduler.activeSlot
    }



    animate = (now: number) => {
        window.requestAnimationFrame(this.animate)
        if (resizeRendererToDisplaySize(this.renderer)) {
            let canvas = this.renderer.domElement
            this.#camera.aspect = canvas.clientWidth / canvas.clientHeight
            this.#camera.updateProjectionMatrix()
            this.#controls.update()
        }
        this.step(now)
        this.renderer.render(this.#scene, this.#camera)
    }
    _prev = 0
    private step(now: number) {
        let dt = now - this._prev
        if (dt > 160) {
            this._prev = now
            for (let i = 0; i < this.#scheduler.networkCount; i++) {
                this.setTubeColors(this.#colors[i], this.stripeColor(this.#scheduler.activeSlot), this.#scheduler.activeSlot)

            }
            this.#scheduler.step()
            for (let i = 0; i < this.#scheduler.networkCount; i++) {
                this.#color.setColorName(this.#scheduler.activeColors[i])
                this.setTubeColors(this.#colors[i], this.#color, this.#scheduler.activeSlot)
            }
            this.#colorUpdaters.forEach(f => f())
        }
        imba.commit()
    }

    #sColor = new Color()
    private stripeColor(i: number): Color {
        let c = i % 2 == 0 ? 'black' : 'gray'
        this.#sColor.setColorName(c)
        return this.#sColor
    }

    #controls: OrbitControls

    private buildScene(canvas: HTMLCanvasElement, clearColor: string) {
        const scene: THREE.Scene = new THREE.Scene()
        const camera: THREE.PerspectiveCamera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000)
        const renderer: THREE.WebGLRenderer = new THREE.WebGLRenderer({ canvas, antialias: true })
        renderer.setSize(window.innerWidth, window.innerHeight)
        const controls = new OrbitControls(camera, renderer.domElement)
        this.#scene = scene
        this.#camera = camera
        this.renderer = renderer
        this.#controls = controls
    }

    private torusColorAttrib() {
        let colors = new Float32Array((size.radial + 1) * (size.tubular + 1) * 3)
        for (let i = 0; i < size.tubular; i++) {
            this.setTubeColors(colors, this.stripeColor(i), i)
        }
        return colors
    }


    private setTubeColors(colors: Float32Array, color: Color, i: number) {
        for (const j of this.tubeIndex(i)) {
            colors.set(color.toArray(), j)
        }
    }

    private tubeIndex(i: number) {
        let idx = []
        for (let j = 0; j < size.radial; j++)
            idx.push(i * 3 + j * size.tubular * 3 + 3 * j)
        return idx
    }

    private buildTorus() {
        let geom = new THREE.TorusGeometry(8, 1, 100, 1536)
        let mat = new THREE.MeshPhongMaterial({ dithering: true, flatShading: true, vertexColors: true })
        // let mat = new THREE.MeshBasicMaterial()
        let mesh = new THREE.Mesh(geom, mat)
        return mesh
    }
}