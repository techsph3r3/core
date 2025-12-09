import * as CANNON from 'cannon-es';

// Physics World Settings
export const GRAVITY = -9.82;
export const TIME_STEP = 1 / 60;

// Material Definitions
// These keys link visual meshes to physics materials
export const MATERIALS = {
  ground: new CANNON.Material('ground'),
  object: new CANNON.Material('object'),
  conveyor: new CANNON.Material('conveyor'),
  pusher: new CANNON.Material('pusher'),
  rail: new CANNON.Material('rail'),
};

// Contact Materials (Friction/Restitution definitions)
export const CONTACT_MATERIALS = [
  // Object on Ground
  new CANNON.ContactMaterial(MATERIALS.ground, MATERIALS.object, {
    friction: 0.5,
    restitution: 0.2,
  }),
  // Object on Object
  new CANNON.ContactMaterial(MATERIALS.object, MATERIALS.object, {
    friction: 0.4,
    restitution: 0.1,
  }),
  // Object on Conveyor (High friction to ensure grip)
  new CANNON.ContactMaterial(MATERIALS.conveyor, MATERIALS.object, {
    friction: 0.9,
    restitution: 0.0,
  }),
  // Object on Pusher (Low friction to slide off easily)
  new CANNON.ContactMaterial(MATERIALS.pusher, MATERIALS.object, {
    friction: 0.1,
    restitution: 0.5,
  }),
  // Object on Rail (Zero friction to prevent jamming)
  new CANNON.ContactMaterial(MATERIALS.rail, MATERIALS.object, {
    friction: 0.0,
    restitution: 0.1,
  }),
];