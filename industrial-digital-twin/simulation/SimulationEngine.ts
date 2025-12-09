import * as THREE from 'three';
import * as CANNON from 'cannon-es';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import { CONTACT_MATERIALS, GRAVITY, TIME_STEP } from '../constants';
import { ISimulationEntity, IPLCState } from '../types';
import { createFloor, createConveyor, createSensor, createDiverter, createProductBox, createRail, ProductColor } from './factory';

export class SimulationEngine {
  // Three.js
  public scene: THREE.Scene;
  public camera: THREE.PerspectiveCamera;
  public renderer: THREE.WebGLRenderer | null = null;
  public controls: OrbitControls | null = null;

  // Cannon.js
  public world: CANNON.World;
  
  // State
  public entities: Map<string, ISimulationEntity> = new Map();
  public isRunning: boolean = false;
  public initFailed: boolean = false;
  private animationId: number = 0;
  private container: HTMLElement;
  
  // Logic
  public plcState: IPLCState = {
    inputs: { 
      'sensor_red': false, 'sensor_white': false, 'sensor_blue': false,
      'sensor_side_red': false, 'sensor_side_white': false, 'sensor_side_blue': false
    },
    outputs: { 
      'pusher_red': false, 'pusher_white': false, 'pusher_blue': false,
      'belt_side_red': false, 'belt_side_white': false, 'belt_side_blue': false
    },
    timers: { 
      'timer_red': 0, 'timer_white': 0, 'timer_blue': 0,
      'timer_off_red': 0, 'timer_off_white': 0, 'timer_off_blue': 0 
    },
  };
  
  private onStateUpdate: ((state: IPLCState) => void) | null = null;

  constructor(container: HTMLElement, onStateUpdate: (state: IPLCState) => void) {
    this.container = container;
    this.onStateUpdate = onStateUpdate;

    // 1. Initialize Three.js
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x1a1a1a);
    this.scene.fog = new THREE.Fog(0x1a1a1a, 15, 60);

    this.camera = new THREE.PerspectiveCamera(45, container.clientWidth / container.clientHeight, 0.1, 100);
    this.camera.position.set(20, 20, 20); 
    this.camera.lookAt(0, 0, 0);

    // Renderer Initialization with Fallback for Older Macs
    try {
      // Attempt 1: High Quality (Antialias, Alpha)
      this.renderer = new THREE.WebGLRenderer({ 
        antialias: true, 
        alpha: true,
        powerPreference: 'high-performance'
      });
    } catch (e) {
      console.warn("High-performance WebGL failed. Attempting fallback configuration...", e);
      try {
        // Attempt 2: Low Spec / "Safe Mode"
        // - No antialias
        // - No alpha channel
        // - Medium precision floats
        // - Do not fail if performance is bad (allow software rendering if needed)
        this.renderer = new THREE.WebGLRenderer({ 
          antialias: false, 
          alpha: false,
          precision: 'mediump',
          powerPreference: 'default',
          failIfMajorPerformanceCaveat: false 
        });
      } catch (e2) {
        console.error("All WebGL Renderer attempts failed:", e2);
        this.initFailed = true;
      }
    }

    if (this.renderer) {
      this.renderer.shadowMap.enabled = true;
      this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
      this.renderer.setSize(container.clientWidth, container.clientHeight);
      container.appendChild(this.renderer.domElement);
      
      this.controls = new OrbitControls(this.camera, this.renderer.domElement);
      this.controls.enableDamping = true;
      this.controls.maxPolarAngle = Math.PI / 2 - 0.1; 
    }

    const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
    this.scene.add(ambientLight);

    const dirLight = new THREE.DirectionalLight(0xffffff, 1.2);
    dirLight.position.set(5, 15, 5);
    dirLight.castShadow = true;
    dirLight.shadow.mapSize.set(2048, 2048);
    this.scene.add(dirLight);

    // 2. Initialize Cannon.js
    this.world = new CANNON.World();
    this.world.gravity.set(0, GRAVITY, 0);
    this.world.broadphase = new CANNON.NaiveBroadphase();
    CONTACT_MATERIALS.forEach(cm => this.world.addContactMaterial(cm));

    // 3. Populate
    this.buildScene();

    window.addEventListener('resize', this.onResize);
  }

  private buildScene() {
    this.addEntity(createFloor());

    const beltLength = 40; 
    const beltWidth = 1.4;
    const beltSpeed = 2.5;
    
    // Main Belt
    this.addEntity(createConveyor('conveyor_main', { x: 0, y: 0.2, z: 0 }, beltLength, beltWidth, beltSpeed));

    // Stations Configuration
    // Spaced out by 8 units
    // zSens: Main Sensor (Upstream)
    // pivotZ: Diverter Pivot (Downstream). Moved +1.0 unit downstream to avoid blocking chute.
    // takeoutZ: Center of Side Conveyor
    const stations = [
      { color: 'red', zSens: -12, pivotZ: -7, takeoutZ: -6.5 },
      { color: 'white', zSens: -2, pivotZ: 3, takeoutZ: 3.5 },
      { color: 'blue', zSens: 8, pivotZ: 13, takeoutZ: 13.5 }
    ];

    // Rails
    // Main belt width is 1.4, so edge is at 0.7.
    // Placing rails at 0.75 ensures they are tight against the belt frame, minimizing gaps.
    const rx = 0.75; 
    
    const startZ = -beltLength / 2;
    const endZ = beltLength / 2;
    const sideBeltWidth = 1.5;
    const gap = sideBeltWidth + 0.5; // Gap in right rail

    // Left Rail (Continuous) - Diverter pivots on this rail
    this.addEntity(createRail('rail_left_full', { x: -rx, y: 0.4, z: 0 }, { x: 0.1, y: 0.4, z: beltLength }));

    // Right Rail (Needs gaps for side belts)
    let rz = startZ;
    stations.forEach(st => {
        const gapStart = st.takeoutZ - gap/2;
        const gapEnd = st.takeoutZ + gap/2;
        
        if (gapStart > rz) {
            const len = gapStart - rz;
            const c = rz + len/2;
            this.addEntity(createRail(`rail_r_${c}`, { x: rx, y: 0.4, z: c }, { x: 0.1, y: 0.4, z: len }));
        }
        rz = gapEnd;
    });
    if (rz < endZ) {
        const len = endZ - rz;
        const c = rz + len/2;
        this.addEntity(createRail(`rail_r_end`, { x: rx, y: 0.4, z: c }, { x: 0.1, y: 0.4, z: len }));
    }

    // Hardware
    const colorHex = { red: 0xef4444, white: 0xffffff, blue: 0x3b82f6 };

    stations.forEach(st => {
       const c = st.color as ProductColor;
       
       // 1. Main Sensor
       this.addEntity(createSensor(`sensor_${c}`, { x: 0, y: 0.2, z: st.zSens }, colorHex[c]));
       
       // 2. Diverter Arm (Pivot on Left Rail)
       // Pivot attached directly to the left rail position
       this.addEntity(createDiverter(`pusher_${c}`, { x: -rx, y: 0.4, z: st.pivotZ }));
       
       // 2b. Static Pivot Post (Visual anchor)
       this.createPivotPost(st.color + "_pivot", { x: -rx, y: 0.4, z: st.pivotZ });

       // 3. Side Conveyor (Moves in +X direction)
       // Position: Starts near right rail (0.75) and extends out.
       // Length 6 units to move "a few feet" and drop off.
       const sideBeltLen = 6;
       const sideBeltX = 0.75 + (sideBeltLen / 2); // Center of side belt
       this.addEntity(createConveyor(
         `conveyor_side_${c}`, 
         { x: sideBeltX, y: 0.2, z: st.takeoutZ }, 
         sideBeltLen, 
         sideBeltWidth, 
         0, // Speed starts at 0
         new CANNON.Vec3(1, 0, 0) // Direction +X
       ));

       // 4. Side Sensor (At the start of the side belt)
       // Approx where the box lands: X ~ 1.5
       this.addEntity(createSensor(`sensor_side_${c}`, { x: 1.8, y: 0.2, z: st.takeoutZ }, colorHex[c]));
    });
  }

  private createPivotPost(id: string, pos: {x:number, y:number, z:number}) {
    const geo = new THREE.CylinderGeometry(0.12, 0.12, 0.5);
    const mat = new THREE.MeshStandardMaterial({ color: 0x444444 });
    const mesh = new THREE.Mesh(geo, mat);
    mesh.position.set(pos.x, pos.y, pos.z);
    mesh.castShadow = true;
    this.scene.add(mesh);
    // No physics needed for the visual hinge cover, or could be static
  }

  public addEntity(entity: ISimulationEntity) {
    this.entities.set(entity.id, entity);
    this.scene.add(entity.mesh);
    this.world.addBody(entity.body);
  }

  public removeEntity(id: string) {
    const entity = this.entities.get(id);
    if (entity) {
      this.scene.remove(entity.mesh);
      this.world.removeBody(entity.body);
      this.entities.delete(id);
    }
  }

  public spawnBox() {
    if (this.initFailed) return;
    const id = `box_${Date.now()}`;
    const colors: ProductColor[] = ['red', 'white', 'blue'];
    const randomColor = colors[Math.floor(Math.random() * colors.length)];
    // Spawn at beginning
    const box = createProductBox(id, { x: 0, y: 1.5, z: -18 }, randomColor);
    this.addEntity(box);
  }

  public start() {
    if (!this.isRunning && !this.initFailed) {
      this.isRunning = true;
      this.loop();
    }
  }

  public stop() {
    this.isRunning = false;
    cancelAnimationFrame(this.animationId);
  }

  private loop = () => {
    if (!this.isRunning) return;
    this.animationId = requestAnimationFrame(this.loop);
    
    // 1. Logic
    this.runPLCLogic(TIME_STEP);

    // 2. Physics & Kinematics
    this.updateKinematics(TIME_STEP);
    this.world.step(TIME_STEP);

    // 3. Sync
    this.entities.forEach(entity => {
      entity.mesh.position.copy(entity.body.position as unknown as THREE.Vector3);
      entity.mesh.quaternion.copy(entity.body.quaternion as unknown as THREE.Quaternion);
      
      if (entity.body.position.y < -5) {
        this.removeEntity(entity.id);
      }
    });

    if (this.controls) this.controls.update();
    if (this.renderer) this.renderer.render(this.scene, this.camera);
    
    if (this.onStateUpdate) {
      this.onStateUpdate({ ...this.plcState });
    }
  };

  private runPLCLogic(dt: number) {
    const stations = [
      { 
        color: 'red', 
        mainSensor: 'sensor_red', diverter: 'pusher_red', timer: 'timer_red',
        sideSensor: 'sensor_side_red', sideBelt: 'belt_side_red', offTimer: 'timer_off_red'
      },
      { 
        color: 'white', 
        mainSensor: 'sensor_white', diverter: 'pusher_white', timer: 'timer_white',
        sideSensor: 'sensor_side_white', sideBelt: 'belt_side_white', offTimer: 'timer_off_white'
      },
      { 
        color: 'blue', 
        mainSensor: 'sensor_blue', diverter: 'pusher_blue', timer: 'timer_blue',
        sideSensor: 'sensor_side_blue', sideBelt: 'belt_side_blue', offTimer: 'timer_off_blue'
      },
    ];

    stations.forEach(st => {
      // --- MAIN LINE LOGIC ---
      const sensorEntity = this.entities.get(st.mainSensor);
      let detected = false;
      
      // Update Sensor
      if (sensorEntity) {
        const sensorBodyPos = sensorEntity.body.position;
        const light = sensorEntity.mesh.getObjectByName('SensorLight') as THREE.Mesh;
        if (light) (light.material as THREE.MeshBasicMaterial).color.setHex(0x333333);

        for (const [key, entity] of this.entities) {
          if (entity.type === 'dynamic') {
            const dx = entity.body.position.x - sensorBodyPos.x;
            const dz = entity.body.position.z - sensorBodyPos.z;
            const dist = Math.sqrt(dx*dx + dz*dz);
            if (dist < 0.2 && entity.data?.color === st.color) {
              detected = true;
              if (light) (light.material as THREE.MeshBasicMaterial).color.setHex(0x00ff00);
              break;
            }
          }
        }
      }
      this.plcState.inputs[st.mainSensor] = detected;

      // Timer Logic for Diverter
      if (detected && this.plcState.timers[st.timer] === 0) {
        this.plcState.timers[st.timer] = 0.01;
      }

      if (this.plcState.timers[st.timer] > 0) {
        this.plcState.timers[st.timer] += dt;
        const t = this.plcState.timers[st.timer];

        // Travel time calculation (Dist 5.0 / Speed 2.5 = 2.0s)
        const openStart = 1.7; // Adjusted for increased distance
        const closeTime = 5.5; 

        if (t > openStart && t < closeTime) {
          this.plcState.outputs[st.diverter] = true; 
        } else if (t >= closeTime) {
          this.plcState.outputs[st.diverter] = false; 
          this.plcState.timers[st.timer] = 0;
        }
      } else {
        this.plcState.outputs[st.diverter] = false;
      }
      
      // Apply Diverter State
      const diverter = this.entities.get(st.diverter);
      if (diverter && 'setActive' in diverter) {
        (diverter as any).setActive(this.plcState.outputs[st.diverter]);
      }

      // --- SIDE LINE LOGIC ---
      const sideSensorEntity = this.entities.get(st.sideSensor);
      let sideDetected = false;
      
      if (sideSensorEntity) {
        const sPos = sideSensorEntity.body.position;
        const light = sideSensorEntity.mesh.getObjectByName('SensorLight') as THREE.Mesh;
        if (light) (light.material as THREE.MeshBasicMaterial).color.setHex(0x333333);

        for (const [key, entity] of this.entities) {
           if (entity.type === 'dynamic') {
             const dx = entity.body.position.x - sPos.x;
             const dz = entity.body.position.z - sPos.z;
             if (Math.sqrt(dx*dx + dz*dz) < 0.5) { // Wider detection radius
                sideDetected = true;
                if (light) (light.material as THREE.MeshBasicMaterial).color.setHex(0xffff00);
                break;
             }
           }
        }
      }
      this.plcState.inputs[st.sideSensor] = sideDetected;

      // Side Belt Activation Logic
      // Activate belt if:
      // 1. Sensor detects a box (standard takeaway)
      // 2. Diverter is active (anticipating box arrival) - PREVENTS STALLING
      if (sideDetected || this.plcState.outputs[st.diverter]) {
        this.plcState.timers[st.offTimer] = 2.5;
      }

      // If timer is active, run belt
      if (this.plcState.timers[st.offTimer] > 0) {
        this.plcState.outputs[st.sideBelt] = true;
        this.plcState.timers[st.offTimer] -= dt;
      } else {
        this.plcState.outputs[st.sideBelt] = false;
        this.plcState.timers[st.offTimer] = 0;
      }

      // Apply Side Belt Speed
      const sideConveyor = this.entities.get(`conveyor_side_${st.color}`);
      if (sideConveyor && 'setSpeed' in sideConveyor) {
        const speed = this.plcState.outputs[st.sideBelt] ? 3.0 : 0;
        (sideConveyor as any).setSpeed(speed);
      }
    });
  }

  private updateKinematics(dt: number) {
    const time = performance.now();

    this.entities.forEach(entity => {
      if (entity.update) entity.update(dt, time);
    });

    // Generalized Conveyor Logic
    this.world.contacts.forEach(c => {
      const bi = c.bi;
      const bj = c.bj;

      let conveyorBody, boxBody;
      if ((bi.material as any)?.name === 'conveyor') { conveyorBody = bi; boxBody = bj; }
      else if ((bj.material as any)?.name === 'conveyor') { conveyorBody = bj; boxBody = bi; }

      if (conveyorBody && boxBody && boxBody.mass > 0) {
        const speed = (conveyorBody as any).userData.conveyorSpeed || 0;
        const dir = (conveyorBody as any).userData.transportDir as CANNON.Vec3 || new CANNON.Vec3(0,0,1);
        
        // We only apply force if belt is moving
        if (Math.abs(speed) > 0.01) {
            // Target Velocity Vector
            const tvX = dir.x * speed;
            const tvZ = dir.z * speed;

            // Interpolate current velocity towards target velocity
            // We apply different factors for transport vs non-transport axis
            
            if (Math.abs(dir.z) > 0.5) { // Main belt (Moving Z)
                 const isBeingPushedX = Math.abs(boxBody.velocity.x) > 0.5;
                 
                 // Relaxed lateral friction/damping:
                 // Previously we damped X heavily (* 0.9). 
                 // Now we allow more X movement (* 0.98) so the diverter doesn't fight the belt.
                 
                 if (!isBeingPushedX) {
                     // Standard running: Control Z, slight X damping
                     boxBody.velocity.z = boxBody.velocity.z * 0.8 + tvZ * 0.2;
                     boxBody.velocity.x = boxBody.velocity.x * 0.98; 
                 } else {
                     // Diverting: Let X slide easily
                     boxBody.velocity.z = boxBody.velocity.z * 0.9 + tvZ * 0.1;
                     // Virtually no X damping here to allow divert
                 }
            } else { // Side belt (Moving X)
                 // Strong X control
                 boxBody.velocity.x = boxBody.velocity.x * 0.8 + tvX * 0.2;
                 boxBody.velocity.z = boxBody.velocity.z * 0.9; // Kill Z momentum
            }
            
            // Stabilize rotation
            boxBody.angularVelocity.set(0, 0, 0);
            boxBody.quaternion.setFromEuler(0, 0, 0);
        }
      }
    });
  }

  private onResize = () => {
    if (!this.renderer || !this.camera) return;
    const width = this.container.clientWidth;
    const height = this.container.clientHeight;
    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height);
  };

  public dispose() {
    this.stop();
    window.removeEventListener('resize', this.onResize);
    if (this.renderer) {
      this.renderer.dispose();
      if (this.renderer.domElement && this.renderer.domElement.parentNode === this.container) {
        this.container.removeChild(this.renderer.domElement);
      }
    }
  }
}