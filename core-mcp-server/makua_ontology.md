# MAKAU ONTOLOGY — COMPLETE VERSION

## LAYER 1 — PHYSICAL WORLD
- **Environment**: real-world domain (energy, water, seismic, robotics, automotive, smart home)
- **PhysicalProcess**: mechanical, thermal, chemical, seismic, flow, electrical, vibrational systems
- **PhysicalComponent**: pumps, motors, pipes, beams, sensors, soil, gears, structures

## LAYER 2 — CPS ARCHITECTURE
- **Sensor**: micro:bit, ESP32/M5Stack, phone sensors, industrial sensors
- **Actuator**: motors, servos, relays, valves
- **Controller**: PLC logic, embedded controllers, microcontrollers, PID loops
- **Gateway**: Raspberry Pi (edge device), Tailscale-enabled mesh identity node
- **Network**: wired, wireless, BLE, WiFi, LoRa, Tailscale mesh, VLANs, segmentation zones
- **DataStream**: telemetry, time-series data, seismic signals, environmental readings

## LAYER 3 — SIMULATION & DIGITAL TWINS
- **OfflineSimulation**: safe sandboxed model (browser)
- **DigitalTwin**: time synchronized real-time twin, physics-driven (Unity/Godot/WebGPU/Javascript/WASM)
- **3DModel**: mesh, textures, physics rig (thermodynamics, electric/circuit, mechanical, fluid dynamics, etc)

## LAYER 4 — PEDAGOGY, SECURITY & CIE
- **LearningPathway**: Level 0–7 progression
- **ConceptModule**: atomic instructional concepts
- **Lab**: hands-on activities (simulation, sensors, gateway, cyber range)
- **Assessment**: quizzes, labs, red/blue team events
- **SecureByDesignPrinciple**: least privilege, zero trust, segmentation, secure defaults, signed firmware, safe failure
- **Threat**: STRIDE, ICS attack patterns, physical-world threat interactions
- **SecurityControl**: ISA/IEC 62443 & NIST 800-82 mapped controls
- **CyberRangeEnvironment**: dockerized ICS/OT simulations with HMIs, historians, PLCs, MQTT, Modbus, noVNC, Kali, Caldera
- **SIEMIntegration**: Malcolm or equivalent
- **CIE Principle**: integration of safety engineering + cyber engineering; design decisions informed by physical consequences

## LAYER 5 — LEARNER ADAPTATION
- **LearnerProfile**: age group (10–14, 15–18, university, professional), skill level, goals
- **AdaptationSettings**: tone (kid-friendly → professional), vocabulary, explanation depth
- **LocalizationProfile**: language, units, voice style, accessibility preferences

> **RULE**: Adapt tone/complexity slightly, but NEVER change the Level 0–7 pathway or security content.

## LAYER 6 — BUSINESS & SUSTAINABILITY
- **ProductOffering**: Free, Pro, Enterprise
- **PricingModel**: subscription, seat-licensing, usage limits
- **CostStructure**: hosting, cyber range compute, SIEM pipelines, GPU cost, support
- **RevenueModel**: ARR, margins, enterprise contracts
- **UserSegment**: homeschool, K-12, university, professional, enterprise, government
- **SustainabilityProfile**: burn rate, runway, growth rate
- **PartnerOrganization**: schools, universities, gov labs, research partners
- **VCInvestmentProfile**: stage, capital, strategic requirements
- **GrowthStrategy**: roadmap, hardware kits, international expansion

---

# MAKAU CURRICULUM — LEVEL 0 THROUGH LEVEL 7

## LEVEL 0 — ENVIRONMENT
Learn physical environment WITHOUT technology.
**Focus**: natural processes, safety, constraints, physics intuition.

## LEVEL 1 — TECHNOLOGY INTRODUCTION
Add CPS elements: sensors, actuators, controllers, data flow, networks.

## LEVEL 2 — OFFLINE SIMULATION
Explore simplified models in browser-based sandboxes.

## LEVEL 3 — LIVE INTERNET DATA
Pull in open-data sensors (earthquake, weather, IoT feeds).

## LEVEL 4 — BRING-YOUR-OWN SENSORS
Hands-on with micro:bit, ESP32/M5Stack, phone sensors.

## LEVEL 5 — GATEWAY & EDGE COMPUTING
Use Raspberry Pi, MQTT, APIs; identity-based networking (Tailscale-ready).

## LEVEL 6 — DIGITAL TWIN + 3D/VR
Physics-enabled digital environments; live sensor synchronization; XR.

## LEVEL 7 — SECURE-BY-DESIGN + CIE
Apply ISA/IEC 62443, NIST 800-82, MITRE ICS ATT&CK, DOE CIE.
Develop full threat models, secure architectures, and realistic cyber range operations.

---

# CORE FOUNDATIONAL PRINCIPLES

1. **Cyber-Informed Engineering (CIE) IS REQUIRED**
   - Every design choice must consider physical consequences
   - Every control must map back to system safety and mission-critical function
   - Every digital twin must highlight physical impacts
   - Every lab from Level 3 onward must include safety + cyber interactions

2. **Secure-by-Design IS NOT OPTIONAL**
   - Identity-based networking (Tailscale, certs, mTLS)
   - Segmentation & zones (ISA/IEC 62443)
   - Data integrity & provenance verification
   - Safety-security co-engineering

3. **Age-appropriate tone BUT identical structure**
   - junior high and high school: simpler language
   - University: technical clarity
   - Professionals: precise engineering + securi **ARVRScene**: WebXR or Meta Quest immersive environment
- **TwinSync**: mapping real sensor → simulated objectty depth

4. **Global accessibility**
   - Localization and voice profiles must be respected in all responses
