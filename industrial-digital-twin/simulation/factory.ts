import * as THREE from 'three';
import * as CANNON from 'cannon-es';
import { ISimulationEntity } from '../types';
import { MATERIALS } from '../constants';

export type ProductColor = 'red' | 'white' | 'blue';

/**
 * Creates a standard dynamic box.
 * Width is 75% of conveyor width (1.4 * 0.75 = 1.05).
 */
export const createProductBox = (
  id: string,
  pos: { x: number; y: number; z: number },
  colorType: ProductColor
): ISimulationEntity => {
  // Increased width to 1.05
  const size = { x: 1.05, y: 0.5, z: 0.5 };
  const mass = 5; 

  const colorMap: Record<ProductColor, number> = {
    red: 0xef4444,   // Tailwind Red 500
    white: 0xf8fafc, // Tailwind Slate 50
    blue: 0x3b82f6   // Tailwind Blue 500
  };

  // 1. Visual Mesh
  const geometry = new THREE.BoxGeometry(size.x, size.y, size.z);
  const material = new THREE.MeshStandardMaterial({ 
    color: colorMap[colorType],
    roughness: 0.4,
    metalness: 0.1
  }); 
  const mesh = new THREE.Mesh(geometry, material);
  mesh.castShadow = true;
  mesh.receiveShadow = true;

  // 2. Physics Body
  const shape = new CANNON.Box(new CANNON.Vec3(size.x / 2, size.y / 2, size.z / 2));
  const body = new CANNON.Body({
    mass: mass,
    material: MATERIALS.object,
    position: new CANNON.Vec3(pos.x, pos.y, pos.z),
    fixedRotation: false 
  });
  body.addShape(shape);
  
  // Damping
  body.linearDamping = 0.5;
  body.angularDamping = 0.99; 

  return { 
    id, 
    mesh, 
    body, 
    type: 'dynamic',
    data: { color: colorType }
  };
};

/**
 * Creates a Static Floor.
 */
export const createFloor = (): ISimulationEntity => {
  const geometry = new THREE.PlaneGeometry(60, 60);
  const material = new THREE.MeshStandardMaterial({ 
    color: 0x111827, // Gray 900
    roughness: 0.8,
    side: THREE.DoubleSide
  });
  const mesh = new THREE.Mesh(geometry, material);
  mesh.rotation.x = -Math.PI / 2;
  mesh.receiveShadow = true;

  const shape = new CANNON.Plane();
  const body = new CANNON.Body({
    mass: 0, 
    material: MATERIALS.ground,
  });
  body.addShape(shape);
  body.quaternion.setFromEuler(-Math.PI / 2, 0, 0);

  return { id: 'floor', mesh, body, type: 'static' };
};

/**
 * Creates a Conveyor Belt Segment.
 * Supports dynamic speed updates and custom transport direction.
 */
export const createConveyor = (
  id: string,
  pos: { x: number; y: number; z: number },
  length: number,
  width: number,
  initialSpeed: number,
  direction: CANNON.Vec3 = new CANNON.Vec3(0, 0, 1) // Default moves along +Z
): ISimulationEntity & { setSpeed: (s: number) => void } => {
  const height = 0.2;
  
  const mesh = new THREE.Group();
  mesh.position.set(pos.x, pos.y, pos.z);
  
  // Orient visual mesh based on direction (roughly)
  // If moving in X, rotate 90 deg around Y.
  if (Math.abs(direction.x) > 0.5) {
      mesh.rotation.y = Math.PI / 2;
  }

  const frameGeo = new THREE.BoxGeometry(width, height - 0.05, length);
  const frameMat = new THREE.MeshStandardMaterial({ color: 0x333333 });
  const frame = new THREE.Mesh(frameGeo, frameMat);
  frame.position.y = -0.05;
  frame.receiveShadow = true;
  mesh.add(frame);

  const slatCount = Math.floor(length * 2); 
  const slats: THREE.Mesh[] = [];
  const slatGeo = new THREE.BoxGeometry(width - 0.1, 0.05, 0.4);
  const slatMatA = new THREE.MeshStandardMaterial({ color: 0x222222 });
  const slatMatB = new THREE.MeshStandardMaterial({ color: 0x2a2a2a });

  for (let i = 0; i < slatCount; i++) {
    const slat = new THREE.Mesh(slatGeo, i % 2 === 0 ? slatMatA : slatMatB);
    const zPos = -length/2 + (i / slatCount) * length;
    slat.position.set(0, height/2, zPos);
    slat.receiveShadow = true;
    mesh.add(slat);
    slats.push(slat);
  }

  const shape = new CANNON.Box(new CANNON.Vec3(width / 2, height / 2, length / 2));
  const body = new CANNON.Body({
    mass: 0, 
    material: MATERIALS.conveyor,
    position: new CANNON.Vec3(pos.x, pos.y, pos.z),
  });
  
  // Align physics body
  if (Math.abs(direction.x) > 0.5) {
      body.quaternion.setFromEuler(0, Math.PI / 2, 0);
  }

  body.addShape(shape);

  // State
  let currentSpeed = initialSpeed;

  const update = (dt: number, time: number) => {
    // Animate slats
    // Note: This animation loop wraps Z locally.
    // If we rotated the mesh, Z local is X world, which works out visually.
    if (currentSpeed !== 0) {
        const dist = currentSpeed * time * 0.001;
        slats.forEach((slat, i) => {
          let zBase = -length/2 + (i / slatCount) * length;
          let zCurrent = zBase + dist;
          const relativeZ = (zCurrent + length/2) % length;
          // Handle negative modulo for negative speed
          const wrappedZ = relativeZ < 0 ? relativeZ + length : relativeZ;
          slat.position.z = -length/2 + wrappedZ;
        });
    }
  };

  const setSpeed = (s: number) => {
    currentSpeed = s;
    (body as any).userData.conveyorSpeed = s;
  };

  // Init userData
  (body as any).userData = { 
      conveyorSpeed: currentSpeed,
      transportDir: direction 
  };

  return { id, mesh, body, type: 'static', update, setSpeed };
};

export const createRail = (
  id: string,
  pos: { x: number; y: number; z: number },
  size: { x: number; y: number; z: number }
): ISimulationEntity => {
  const geometry = new THREE.BoxGeometry(size.x, size.y, size.z);
  const material = new THREE.MeshStandardMaterial({ 
    color: 0x64748b, 
    metalness: 0.5,
    roughness: 0.5
  });
  const mesh = new THREE.Mesh(geometry, material);
  mesh.position.set(pos.x, pos.y, pos.z);
  mesh.castShadow = true;
  mesh.receiveShadow = true;

  const shape = new CANNON.Box(new CANNON.Vec3(size.x / 2, size.y / 2, size.z / 2));
  const body = new CANNON.Body({
    mass: 0,
    material: MATERIALS.rail,
    position: new CANNON.Vec3(pos.x, pos.y, pos.z),
  });
  body.addShape(shape);

  return { id, mesh, body, type: 'static' };
};

export const createSensor = (
  id: string,
  pos: { x: number; y: number; z: number },
  colorIndicator: number
): ISimulationEntity => {
  const size = 0.2;

  const geometry = new THREE.BoxGeometry(size * 0.5, 0.2, size * 0.5);
  const material = new THREE.MeshBasicMaterial({ 
    color: colorIndicator, 
    transparent: true, 
    opacity: 0.4
  });
  const mesh = new THREE.Mesh(geometry, material);
  mesh.position.set(pos.x, pos.y, pos.z); 

  const standGeo = new THREE.BoxGeometry(0.05, 1, 0.05);
  const standMat = new THREE.MeshStandardMaterial({ color: 0x333333 });
  const stand = new THREE.Mesh(standGeo, standMat);
  stand.position.set(0.4, 0.5, 0);
  mesh.add(stand);
  
  const lightGeo = new THREE.BoxGeometry(0.15, 0.15, 0.15);
  const lightMat = new THREE.MeshBasicMaterial({ color: 0x333333 }); 
  const light = new THREE.Mesh(lightGeo, lightMat);
  light.name = 'SensorLight'; 
  light.position.set(0, 0.5, 0); 
  stand.add(light);

  const shape = new CANNON.Box(new CANNON.Vec3(size, 0.5, size));
  const body = new CANNON.Body({
    mass: 0,
    isTrigger: true,
    position: new CANNON.Vec3(pos.x, 0.5, pos.z),
  });
  body.addShape(shape);

  return { 
    id, 
    mesh, 
    body, 
    type: 'sensor',
    data: { baseColor: colorIndicator }
  };
};

/**
 * Creates a Swinging Diverter Arm.
 * Uses a kinematic body with a shape offset to simulate a hinge at one end.
 */
export const createDiverter = (
  id: string,
  pivotPos: { x: number; y: number; z: number } 
): ISimulationEntity & { setActive: (active: boolean) => void } => {
  // Increased arm length to cover the belt at 45 degrees
  const armLength = 2.8; 
  const armHeight = 0.3;
  const armThickness = 0.15; 
  const swingSpeed = 5.0; 
  
  // 1. Visual Mesh
  // Create geometry centered at origin
  const geometry = new THREE.BoxGeometry(armThickness, armHeight, armLength);
  // Translate geometry so the origin (0,0,0) is at the hinge end, and arm extends +Z
  geometry.translate(0, 0, armLength / 2);
  
  const material = new THREE.MeshStandardMaterial({ 
    color: 0xf59e0b, 
    roughness: 0.2,
    metalness: 0.5
  });
  const mesh = new THREE.Mesh(geometry, material);
  mesh.castShadow = true;
  // Mesh is placed at pivot position. Geometry handles the arm extension.
  mesh.position.set(pivotPos.x, pivotPos.y, pivotPos.z);
  
  const hingeGeo = new THREE.CylinderGeometry(0.15, 0.15, 0.4);
  const hingeMat = new THREE.MeshStandardMaterial({ color: 0x333333 });
  const hinge = new THREE.Mesh(hingeGeo, hingeMat);
  hinge.position.set(0, 0, 0); 
  mesh.add(hinge);

  // 2. Physics Body
  const shape = new CANNON.Box(new CANNON.Vec3(armThickness / 2, armHeight / 2, armLength / 2));
  const body = new CANNON.Body({
    mass: 0, 
    type: CANNON.Body.KINEMATIC, 
    material: MATERIALS.pusher,
    // Body position is the PIVOT point. It does not move.
    position: new CANNON.Vec3(pivotPos.x, pivotPos.y, pivotPos.z),
  });
  
  // Offset the shape so the Body origin aligns with the end of the Box shape
  // (Matching the visual geometry translation)
  body.addShape(shape, new CANNON.Vec3(0, 0, armLength / 2));

  // State
  let active = false;
  let currentAngle = 0; 
  
  // Angle to swing out (approx 45-50 degrees)
  const targetAngleOpen = Math.PI / 3.5; 
  const targetAngleClosed = 0;

  const update = (dt: number) => {
    const target = active ? targetAngleOpen : targetAngleClosed;
    const diff = target - currentAngle;
    
    if (Math.abs(diff) > 0.01) {
      const step = Math.sign(diff) * swingSpeed * dt;
      if (Math.abs(step) > Math.abs(diff)) {
        currentAngle = target;
      } else {
        currentAngle += step;
      }
    } else {
      currentAngle = target;
    }

    // Update Rotation only. Pivot point (position) remains fixed.
    body.quaternion.setFromAxisAngle(new CANNON.Vec3(0, 1, 0), currentAngle);
    
    // Mesh sync is handled by the main loop, which copies body position/quat to mesh.
    // Since body position is static at pivot, this works perfectly.
  };

  const setActive = (isActive: boolean) => {
    active = isActive;
  };

  return { 
    id, 
    mesh, 
    body, 
    type: 'kinematic', 
    update,
    setActive 
  };
};