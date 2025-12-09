import * as THREE from 'three';
import * as CANNON from 'cannon-es';

// Represents a simulation entity combining visual and physical worlds
export interface ISimulationEntity {
  id: string;
  mesh: THREE.Object3D;
  body: CANNON.Body;
  type: 'static' | 'dynamic' | 'kinematic' | 'sensor';
  // Storage for simulation-specific data (e.g., color, creation time)
  data?: any;
  // Optional update method called every frame (e.g., for custom logic like actuators)
  update?: (dt: number, time: number) => void; 
}

// PLC (Programmable Logic Controller) State
export interface IPLCState {
  inputs: {
    [key: string]: boolean; // e.g., 'sensor_1': true
  };
  outputs: {
    [key: string]: boolean; // e.g., 'pusher_extend': true
  };
  timers: {
    [key: string]: number; // Timer values for logic
  };
}

// Configuration for object generation
export interface BoxConfig {
  width: number;
  height: number;
  depth: number;
  mass: number;
  color: string;
  position: [number, number, number];
}