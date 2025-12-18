"""
PLC I/O Bridge - WebSocket to Modbus Bridge for Digital Twin

This module provides a WebSocket server that acts as a "virtual wiring" connection
between a 3D digital twin and an OpenPLC controller. It simulates physical I/O
connections (like 4-20mA sensors and relay outputs) over the network.

Architecture:
    3D Digital Twin (Browser)
           |
           | WebSocket (ws://host:8080/ws/plc-io)
           v
    PLC I/O Bridge (this module)
           |
           | Modbus TCP via CORE Network (docker exec -> vcmd)
           v
    OpenPLC Runtime (10.0.0.10 inside CORE)

The bridge:
1. Receives sensor states from the 3D twin (e.g., color detection)
2. Writes those values to PLC input registers via Modbus (through CORE network)
3. Reads PLC output registers (e.g., diverter commands)
4. Sends output states back to the 3D twin

This makes the digital twin appear as "wired field devices" to the PLC.

CORE Network Integration:
The bridge executes Modbus operations INSIDE the CORE network using:
  docker exec core-novnc vcmd -c /tmp/pycore.{session}/{node} -- python3 -c "..."
This ensures the Modbus traffic flows through the virtual network and is visible
in Wireshark captures.
"""

import json
import subprocess
import threading
import time
from typing import Dict, Optional, Set, Callable, Tuple
from dataclasses import dataclass, field

# Modbus client for communication with OpenPLC
try:
    from pymodbus.client import ModbusTcpClient
    from pymodbus.exceptions import ModbusException
    MODBUS_AVAILABLE = True
except ImportError:
    MODBUS_AVAILABLE = False
    print("Warning: pymodbus not available - PLC I/O bridge will be simulated")


@dataclass
class PLCIOConfig:
    """Configuration for PLC I/O mapping"""
    plc_ip: str = "10.0.0.10"
    plc_port: int = 502
    poll_interval_ms: int = 100
    unit_id: int = 1

    # Input coils (written by 3D twin, read by PLC as inputs)
    # These simulate physical sensors connected to the PLC
    input_coil_start: int = 0
    input_coil_count: int = 8

    # Output coils (written by PLC, read by 3D twin)
    # These simulate physical actuators controlled by the PLC
    # Now includes 8 debug coils (QX1.0-QX1.7) for I/O verification
    output_coil_start: int = 0
    output_coil_count: int = 16

    # Holding registers (read/write)
    holding_register_start: int = 0
    holding_register_count: int = 16

    # CORE Network Integration - execute Modbus through CORE network
    use_core_network: bool = True
    docker_host: str = "core-novnc"  # Container running CORE
    core_session: int = 1  # CORE session ID
    source_node: str = "eng-ws"  # Node to execute Modbus from (Docker container with pymodbus)
    source_is_docker: bool = True  # Whether source_node is a Docker container (vs vcmd node)


@dataclass
class IOState:
    """Current state of PLC I/O"""
    # Inputs from 3D twin to PLC
    inputs: Dict[str, bool] = field(default_factory=dict)

    # Outputs from PLC to 3D twin
    outputs: Dict[str, bool] = field(default_factory=dict)

    # Holding registers (counters, setpoints, etc.)
    registers: Dict[str, int] = field(default_factory=dict)

    # Force states - allows external override of PLC outputs
    # Values: 0=normal, 1=force ON, 2=force OFF
    # WARNING: This simulates a real ICS vulnerability (CWE-284)
    forces: Dict[str, int] = field(default_factory=dict)

    # Track which outputs are currently being forced
    forced_outputs: Dict[str, bool] = field(default_factory=dict)

    # Connection status
    connected: bool = False
    last_update: float = 0


class PLCIOBridge:
    """
    WebSocket-to-Modbus bridge for connecting a 3D digital twin to OpenPLC.

    The bridge acts like physical wiring between field devices and the PLC:
    - Sensor signals (from 3D twin) -> PLC discrete inputs
    - PLC discrete outputs -> Actuator commands (to 3D twin)
    - Holding registers for counters and setpoints
    """

    # I/O mapping for the sorting facility
    # Maps friendly names to Modbus addresses
    #
    # OpenPLC Modbus Address Mapping:
    # - Coils (QX): address 0+ (byte*8 + bit)
    # - Discrete Inputs (IX): address 0+ (READ ONLY in standard Modbus!)
    # - Holding Registers (MW): address 1024+ (MW0 = 1024, MW100 = 1124)
    #
    # For digital twin, we use the sorting_twin.st program which reads
    # sensor inputs from MW100-MW107 (Modbus 1124-1131) instead of IX
    # This allows the digital twin to write sensor states via standard Modbus
    IO_MAP = {
        # Inputs (from 3D twin to PLC) - written to HOLDING REGISTERS
        # The PLC program (sorting_twin.st) reads these as MW100-MW111
        # and converts them to internal BOOL variables
        # Modbus address = 1024 + MW_number
        'inputs': {
            'sensor_red': 1124,      # MW100 - Color sensor detected RED package
            'sensor_white': 1125,    # MW101 - Color sensor detected WHITE package
            'sensor_blue': 1126,     # MW102 - Color sensor detected BLUE package
            'package_present': 1127, # MW103 - Package at sensor position
            'estop': 1128,           # MW104 - Emergency stop (simulated)
            'start_button': 1129,    # MW105 - Start pushbutton
            'stop_button': 1130,     # MW106 - Stop pushbutton
            'reset_button': 1131,    # MW107 - Reset/acknowledge button
            'exit_red': 1132,        # MW108 - Exit sensor RED (package left side belt)
            'exit_white': 1133,      # MW109 - Exit sensor WHITE
            'exit_blue': 1134,       # MW110 - Exit sensor BLUE
            'debug_mode': 1135,      # MW111 - Debug mode (1=forced diverter test)
        },
        # Outputs (from PLC to 3D twin) - PLC writes coils, bridge reads
        'outputs': {
            'conveyor_run': 0,    # Conveyor motor running
            'diverter_red': 1,    # Red package diverter active
            'diverter_white': 2,  # White package diverter active
            'diverter_blue': 3,   # Blue package diverter active
            'alarm': 4,           # Alarm indicator
            'run_light': 5,       # System running indicator
            'fault_light': 6,     # Fault indicator
            'ready_light': 7,     # Ready indicator
            # DEBUG PASSTHROUGH COILS - mirror inputs for I/O verification
            'debug_sensor_red': 8,    # QX1.0 - mirrors sensor_red input
            'debug_sensor_white': 9,  # QX1.1 - mirrors sensor_white input
            'debug_sensor_blue': 10,  # QX1.2 - mirrors sensor_blue input
            'debug_start_btn': 11,    # QX1.3 - mirrors start_button input
            'debug_stop_btn': 12,     # QX1.4 - mirrors stop_button input
            'debug_reset_btn': 13,    # QX1.5 - mirrors reset_button input
            'debug_clock_pulse': 14,  # QX1.6 - shift register clock pulse
            'debug_forced_mode': 15,  # QX1.7 - forced diverter test mode active
        },
        # Holding registers for counters and setpoints (read-only for twin)
        'registers': {
            'count_red': 1024,       # MW0 - Red package count
            'count_white': 1025,     # MW1 - White package count
            'count_blue': 1026,      # MW2 - Blue package count
            'count_total': 1027,     # MW3 - Total package count
            'conveyor_speed': 1028,  # MW4 - Current conveyor speed (0-100%)
            'cmd_speed': 1034,       # MW10 - Commanded speed setpoint
        },
        # Force registers - allows override of PLC outputs (DANGEROUS!)
        # Values: 0=normal PLC control, 1=force ON, 2=force OFF
        # These demonstrate CWE-284 (Improper Access Control) vulnerabilities
        'forces': {
            'force_conveyor': 1136,      # MW112 - Force conveyor motor
            'force_alarm': 1137,         # MW113 - Force alarm state
            'force_diverter_red': 1138,  # MW114 - Force red diverter
            'force_diverter_white': 1139,# MW115 - Force white diverter
            'force_diverter_blue': 1140, # MW116 - Force blue diverter
        }
    }

    def __init__(self, config: Optional[PLCIOConfig] = None):
        self.config = config or PLCIOConfig()
        self.state = IOState()
        self.running = False
        self.poll_thread: Optional[threading.Thread] = None
        self.websocket_clients: Set = set()
        self.client: Optional[ModbusTcpClient] = None
        self._lock = threading.Lock()

        # Callbacks for state changes
        self.on_output_change: Optional[Callable[[Dict], None]] = None
        self.on_register_change: Optional[Callable[[Dict], None]] = None

        # Button hold timers - ensure buttons stay ON long enough for PLC to detect
        self._button_hold_until = {}  # {button_name: time.time() when to release}

        # Forced outputs - override PLC output values
        # {output_name: forced_value (True/False)} - only contains actively forced outputs
        self._forced_outputs: Dict[str, bool] = {}

    def _execute_in_core(self, python_code: str, timeout: int = 5) -> Tuple[bool, str]:
        """
        Execute Python code inside a CORE node's network namespace.
        This allows Modbus TCP traffic to flow through the virtual network.

        For Docker nodes: docker exec {docker_host} docker exec {source_node} python3 -c '...'
        For vcmd nodes: docker exec {docker_host} vcmd -c /tmp/pycore.{session}/{node} -- python3 -c '...'
        """
        if not self.config.use_core_network:
            return False, "CORE network not configured"

        # Escape the Python code for shell execution
        escaped_code = python_code.replace("'", "'\"'\"'")

        if self.config.source_is_docker:
            # Docker container inside CORE - use docker exec
            full_cmd = f"docker exec {self.config.docker_host} docker exec {self.config.source_node} python3 -c '{escaped_code}'"
        else:
            # Regular vcmd node - use vcmd
            vcmd_path = f"/tmp/pycore.{self.config.core_session}/{self.config.source_node}"
            full_cmd = f"docker exec {self.config.docker_host} vcmd -c {vcmd_path} -- python3 -c '{escaped_code}'"

        try:
            result = subprocess.run(
                full_cmd,
                shell=True,
                capture_output=True,
                text=True,
                timeout=timeout
            )
            success = result.returncode == 0
            output = result.stdout if success else result.stderr
            return success, output.strip()
        except subprocess.TimeoutExpired:
            return False, "Command timed out"
        except Exception as e:
            return False, str(e)

    def _modbus_read_coils_via_core(self, address: int, count: int) -> Optional[list]:
        """Read coils from PLC via CORE network using pymodbus"""
        # Note: Different pymodbus versions use different parameter names (slave vs unit vs none)
        python_code = f'''
from pymodbus.client import ModbusTcpClient
import json
client = ModbusTcpClient("{self.config.plc_ip}", port={self.config.plc_port}, timeout=2)
if client.connect():
    result = client.read_coils(address={address}, count={count})
    client.close()
    if not result.isError():
        print(json.dumps(list(result.bits[:{count}])))
    else:
        print("ERROR:" + str(result))
else:
    print("ERROR:connection_failed")
'''
        success, output = self._execute_in_core(python_code)
        if success and not output.startswith("ERROR"):
            try:
                return json.loads(output)
            except:
                pass
        return None

    def _modbus_read_registers_via_core(self, address: int, count: int) -> Optional[list]:
        """Read holding registers from PLC via CORE network"""
        python_code = f'''
from pymodbus.client import ModbusTcpClient
import json
client = ModbusTcpClient("{self.config.plc_ip}", port={self.config.plc_port}, timeout=2)
if client.connect():
    result = client.read_holding_registers(address={address}, count={count})
    client.close()
    if not result.isError():
        print(json.dumps(list(result.registers)))
    else:
        print("ERROR:" + str(result))
else:
    print("ERROR:connection_failed")
'''
        success, output = self._execute_in_core(python_code)
        if success and not output.startswith("ERROR"):
            try:
                return json.loads(output)
            except:
                pass
        return None

    def _modbus_write_coils_via_core(self, address: int, values: list) -> bool:
        """Write coils to PLC via CORE network"""
        # Convert Python booleans to Python-compatible string representation
        values_str = "[" + ", ".join("True" if v else "False" for v in values) + "]"
        python_code = f'''
from pymodbus.client import ModbusTcpClient
client = ModbusTcpClient("{self.config.plc_ip}", port={self.config.plc_port}, timeout=2)
if client.connect():
    result = client.write_coils(address={address}, values={values_str})
    client.close()
    if not result.isError():
        print("OK")
    else:
        print("ERROR:" + str(result))
else:
    print("ERROR:connection_failed")
'''
        success, output = self._execute_in_core(python_code)
        return success and output == "OK"

    def _modbus_write_registers_via_core(self, address: int, values: list) -> bool:
        """Write multiple holding registers to PLC via CORE network"""
        # Values should be list of integers
        values_str = "[" + ", ".join(str(v) for v in values) + "]"
        # Add retry logic for connection failures
        python_code = f'''
from pymodbus.client import ModbusTcpClient
import time
for attempt in range(3):
    client = ModbusTcpClient("{self.config.plc_ip}", port={self.config.plc_port}, timeout=2)
    if client.connect():
        result = client.write_registers(address={address}, values={values_str})
        client.close()
        if not result.isError():
            print("OK")
        else:
            print("ERROR:" + str(result))
        break
    else:
        if attempt < 2:
            time.sleep(0.05)  # Brief retry delay
        else:
            print("ERROR:connection_failed")
'''
        success, output = self._execute_in_core(python_code)
        if not success or output != "OK":
            print(f"[MODBUS] Write registers result: success={success}, output='{output}'", flush=True)
        return success and output == "OK"

    def _modbus_write_single_coil_via_core(self, address: int, value: bool) -> bool:
        """Write a single coil to PLC via CORE network (for forcing outputs)"""
        value_str = "True" if value else "False"
        python_code = f'''
from pymodbus.client import ModbusTcpClient
client = ModbusTcpClient("{self.config.plc_ip}", port={self.config.plc_port}, timeout=2)
if client.connect():
    result = client.write_coil(address={address}, value={value_str})
    client.close()
    if not result.isError():
        print("OK")
    else:
        print("ERROR:" + str(result))
else:
    print("ERROR:connection_failed")
'''
        success, output = self._execute_in_core(python_code)
        return success and output == "OK"

    def _set_debug_mode(self, enabled: bool) -> bool:
        """Enable or disable PLC debug mode (allows external forcing of outputs)."""
        debug_addr = self.IO_MAP['inputs'].get('debug_mode', 1135)
        value = 1 if enabled else 0

        # Also update the input state so regular poll writes maintain the value
        with self._lock:
            self.state.inputs['debug_mode'] = enabled

        if self.config.use_core_network:
            success = self._modbus_write_registers_via_core(debug_addr, [value])
        else:
            success = False
        if success:
            print(f"[FORCE] Debug mode {'ENABLED' if enabled else 'DISABLED'}", flush=True)
        return success

    def force_output(self, name: str, value: bool) -> bool:
        """
        Force a PLC output to a specific value.

        This overrides the PLC logic by directly writing to the output coil.
        The forced value will be continuously written until released.
        Automatically enables PLC debug mode to prevent PLC from overwriting.

        Args:
            name: Output name (e.g., 'conveyor_run', 'diverter_red')
            value: Value to force (True/False)

        Returns:
            True if force was successful
        """
        if name not in self.IO_MAP['outputs']:
            print(f"[FORCE] Unknown output: {name}", flush=True)
            return False

        address = self.IO_MAP['outputs'][name]

        # Enable debug mode if this is the first forced output
        with self._lock:
            was_empty = len(self._forced_outputs) == 0
        if was_empty:
            self._set_debug_mode(True)

        # Write the forced value to PLC
        if self.config.use_core_network:
            success = self._modbus_write_single_coil_via_core(address, value)
        else:
            # Direct Modbus connection
            if self.client and self.state.connected:
                try:
                    result = self.client.write_coil(address=address, value=value, slave=self.config.unit_id)
                    success = not result.isError()
                except Exception as e:
                    print(f"[FORCE] Modbus write error: {e}", flush=True)
                    success = False
            else:
                success = False

        if success:
            with self._lock:
                self._forced_outputs[name] = value
                self.state.outputs[name] = value  # Update local state
            print(f"[FORCE] Output {name} forced to {value} (addr={address})", flush=True)
        else:
            print(f"[FORCE] Failed to force {name}", flush=True)

        return success

    def release_force(self, name: str) -> bool:
        """
        Release a forced output, allowing PLC logic to control it again.
        Automatically disables PLC debug mode when all forces are released.

        Args:
            name: Output name to release

        Returns:
            True if release was successful
        """
        with self._lock:
            if name in self._forced_outputs:
                del self._forced_outputs[name]
                is_empty = len(self._forced_outputs) == 0
                print(f"[FORCE] Released force on {name}", flush=True)
            else:
                print(f"[FORCE] {name} was not forced", flush=True)
                return False

        # Disable debug mode if no more forced outputs
        if is_empty:
            self._set_debug_mode(False)

        return True

    def get_forced_outputs(self) -> Dict[str, bool]:
        """Get dictionary of currently forced outputs"""
        with self._lock:
            return dict(self._forced_outputs)

    def _write_forced_outputs(self):
        """Write all forced output values to PLC (called each poll cycle)"""
        with self._lock:
            forced_copy = dict(self._forced_outputs)

        for name, value in forced_copy.items():
            address = self.IO_MAP['outputs'].get(name)
            if address is not None:
                if self.config.use_core_network:
                    self._modbus_write_single_coil_via_core(address, value)
                elif self.client and self.state.connected:
                    try:
                        self.client.write_coil(address=address, value=value, slave=self.config.unit_id)
                    except Exception as e:
                        print(f"[FORCE] Error maintaining force on {name}: {e}", flush=True)

    def start(self):
        """Start the bridge (connect to PLC and begin polling)"""
        if self.running:
            return

        self.running = True

        # For CORE network mode, test connectivity via vcmd
        if self.config.use_core_network:
            self._connect_plc_via_core()
        elif MODBUS_AVAILABLE:
            self._connect_plc()

        # Start polling thread
        self.poll_thread = threading.Thread(target=self._poll_loop, daemon=True)
        self.poll_thread.start()

        mode = "CORE network" if self.config.use_core_network else "direct"
        print(f"PLC I/O Bridge started - PLC at {self.config.plc_ip}:{self.config.plc_port} ({mode})", flush=True)

    def stop(self):
        """Stop the bridge"""
        self.running = False

        if self.poll_thread:
            self.poll_thread.join(timeout=2)

        if self.client:
            self.client.close()
            self.client = None

        self.state.connected = False
        print("PLC I/O Bridge stopped")

    def _connect_plc_via_core(self):
        """Test connection to OpenPLC via CORE network"""
        print(f"Testing PLC connection via CORE network (node: {self.config.source_node})...", flush=True)

        # Test read to verify connectivity
        result = self._modbus_read_coils_via_core(0, 1)
        if result is not None:
            self.state.connected = True
            print(f"Connected to OpenPLC at {self.config.plc_ip}:{self.config.plc_port} via CORE", flush=True)
        else:
            self.state.connected = False
            print(f"Failed to connect to OpenPLC via CORE - waiting for PLC to start", flush=True)

    def _connect_plc(self):
        """Establish connection to OpenPLC via Modbus TCP (direct, non-CORE)"""
        if not MODBUS_AVAILABLE:
            return

        try:
            self.client = ModbusTcpClient(
                host=self.config.plc_ip,
                port=self.config.plc_port,
                timeout=3
            )

            if self.client.connect():
                self.state.connected = True
                print(f"Connected to OpenPLC at {self.config.plc_ip}:{self.config.plc_port}")
            else:
                self.state.connected = False
                print(f"Failed to connect to OpenPLC")

        except Exception as e:
            self.state.connected = False
            print(f"Error connecting to PLC: {e}")

    def _poll_loop(self):
        """Main polling loop - reads PLC outputs and sends to connected clients"""
        reconnect_delay = 5
        last_reconnect = 0

        while self.running:
            try:
                # Attempt reconnection if disconnected
                if not self.state.connected:
                    now = time.time()
                    if now - last_reconnect > reconnect_delay:
                        if self.config.use_core_network:
                            self._connect_plc_via_core()
                        elif MODBUS_AVAILABLE:
                            self._connect_plc()
                        last_reconnect = now

                # Auto-release buttons after hold time expires (thread-safe)
                now = time.time()
                with self._lock:
                    buttons_to_remove = []
                    for btn_name, hold_until in list(self._button_hold_until.items()):
                        if now >= hold_until:
                            # Timer expired - release button if still held
                            if self.state.inputs.get(btn_name, False):
                                self.state.inputs[btn_name] = False
                                print(f"[BRIDGE] Button {btn_name} auto-released after hold", flush=True)
                            # Remove from hold dict since timer has expired
                            buttons_to_remove.append(btn_name)
                    # Clean up expired button timers
                    for btn_name in buttons_to_remove:
                        del self._button_hold_until[btn_name]

                if self.state.connected:
                    if self.config.use_core_network:
                        # Use CORE network methods
                        self._read_plc_outputs_via_core()
                        self._read_plc_registers_via_core()
                        self._write_plc_inputs_via_core()
                        # Write forced outputs (overrides PLC logic)
                        if self._forced_outputs:
                            self._write_forced_outputs()
                    elif self.client:
                        # Use direct Modbus connection
                        self._read_plc_outputs()
                        self._read_plc_registers()
                        self._write_plc_inputs()
                        # Write forced outputs (overrides PLC logic)
                        if self._forced_outputs:
                            self._write_forced_outputs()

                self.state.last_update = time.time()

                # Broadcast state to all connected WebSocket clients
                self._broadcast_state()

            except Exception as e:
                print(f"Poll loop error: {e}")
                self.state.connected = False

            time.sleep(self.config.poll_interval_ms / 1000.0)

    def _read_plc_outputs(self):
        """Read discrete outputs from PLC (actuator states)"""
        if not self.client:
            return

        try:
            result = self.client.read_coils(
                address=self.config.output_coil_start,
                count=self.config.output_coil_count,
                slave=self.config.unit_id
            )

            if not result.isError():
                with self._lock:
                    for name, addr in self.IO_MAP['outputs'].items():
                        if addr < len(result.bits):
                            old_val = self.state.outputs.get(name)
                            new_val = result.bits[addr]
                            self.state.outputs[name] = new_val

                            if old_val != new_val and self.on_output_change:
                                self.on_output_change({name: new_val})

        except Exception as e:
            print(f"Error reading PLC outputs: {e}")

    def _read_plc_registers(self):
        """Read holding registers from PLC (counters, speeds, etc.)"""
        if not self.client:
            return

        try:
            result = self.client.read_holding_registers(
                address=self.config.holding_register_start,
                count=self.config.holding_register_count,
                slave=self.config.unit_id
            )

            if not result.isError():
                with self._lock:
                    for name, addr in self.IO_MAP['registers'].items():
                        if addr < len(result.registers):
                            old_val = self.state.registers.get(name)
                            new_val = result.registers[addr]
                            self.state.registers[name] = new_val

                            if old_val != new_val and self.on_register_change:
                                self.on_register_change({name: new_val})

        except Exception as e:
            print(f"Error reading PLC registers: {e}")

    def _write_plc_inputs(self):
        """Write discrete inputs to PLC (sensor states from 3D twin)"""
        if not self.client:
            return

        try:
            # Build coil values list from current input state
            coil_values = [False] * self.config.input_coil_count

            with self._lock:
                for name, addr in self.IO_MAP['inputs'].items():
                    if addr < len(coil_values) and name in self.state.inputs:
                        coil_values[addr] = self.state.inputs[name]

            # Write multiple coils
            # Note: We write to discrete inputs which OpenPLC reads
            # This simulates sensors connected to PLC input terminals
            result = self.client.write_coils(
                address=self.config.input_coil_start,
                values=coil_values,
                slave=self.config.unit_id
            )

            if result.isError():
                print(f"Error writing PLC inputs: {result}")

        except Exception as e:
            print(f"Error writing PLC inputs: {e}")

    def _read_plc_outputs_via_core(self):
        """Read discrete outputs from PLC via CORE network"""
        try:
            result = self._modbus_read_coils_via_core(
                self.config.output_coil_start,
                self.config.output_coil_count
            )

            if result is not None:
                with self._lock:
                    for name, addr in self.IO_MAP['outputs'].items():
                        if addr < len(result):
                            old_val = self.state.outputs.get(name)
                            new_val = result[addr]
                            self.state.outputs[name] = new_val

                            if old_val != new_val and self.on_output_change:
                                self.on_output_change({name: new_val})

                    # DEBUG: Log when debug passthrough coils confirm sensor signals
                    debug_red = self.state.outputs.get('debug_sensor_red', False)
                    debug_white = self.state.outputs.get('debug_sensor_white', False)
                    debug_blue = self.state.outputs.get('debug_sensor_blue', False)
                    diverter_red = self.state.outputs.get('diverter_red', False)
                    diverter_white = self.state.outputs.get('diverter_white', False)
                    diverter_blue = self.state.outputs.get('diverter_blue', False)

                    if debug_red or debug_white or debug_blue:
                        print(f"[PLC->BRIDGE] DEBUG COILS: red={debug_red} white={debug_white} blue={debug_blue}", flush=True)
                    if diverter_red or diverter_white or diverter_blue:
                        print(f"[PLC->BRIDGE] DIVERTERS: red={diverter_red} white={diverter_white} blue={diverter_blue}", flush=True)
            else:
                # Connection lost
                self.state.connected = False

        except Exception as e:
            print(f"Error reading PLC outputs via CORE: {e}")
            self.state.connected = False

    def _read_plc_registers_via_core(self):
        """Read holding registers from PLC via CORE network.

        Registers are at Modbus addresses 1024+ (MW0 = 1024, MW1 = 1025, etc.)
        We read starting from address 1024 and map to our register names.
        """
        try:
            # Read registers starting at 1024 (MW0)
            # We need at least 11 registers for count_red(0) through cmd_speed(10)
            result = self._modbus_read_registers_via_core(1024, 16)

            if result is not None:
                with self._lock:
                    for name, addr in self.IO_MAP['registers'].items():
                        # addr is the full Modbus address (1024+), convert to offset
                        offset = addr - 1024
                        if 0 <= offset < len(result):
                            old_val = self.state.registers.get(name)
                            new_val = result[offset]
                            self.state.registers[name] = new_val

                            if old_val != new_val and self.on_register_change:
                                self.on_register_change({name: new_val})

        except Exception as e:
            print(f"Error reading PLC registers via CORE: {e}")

    def _write_plc_inputs_via_core(self):
        """Write sensor inputs to PLC via CORE network using holding registers.

        The sorting_twin.st program reads sensor inputs from MW100-MW107
        (Modbus addresses 1124-1131). Each register holds 0 or 1.
        """
        try:
            # Build a list of register values (0 or 1) for each input
            # Inputs are mapped to addresses 1124-1131 (MW100-MW107)
            # We need to write them as individual registers

            with self._lock:
                # Get all input values, sorted by address
                input_items = sorted(self.IO_MAP['inputs'].items(), key=lambda x: x[1])

                if not input_items:
                    return

                # Find the base address (should be 1124 for MW100)
                base_addr = input_items[0][1]

                # Build register values array
                register_values = []
                for name, addr in input_items:
                    value = 1 if self.state.inputs.get(name, False) else 0
                    register_values.append(value)

                # DEBUG: Log button states when any button is active
                start_btn = self.state.inputs.get('start_button', False)
                stop_btn = self.state.inputs.get('stop_button', False)
                reset_btn = self.state.inputs.get('reset_button', False)

                # DEBUG: Log sensor states when any color sensor is active
                sensor_red = self.state.inputs.get('sensor_red', False)
                sensor_white = self.state.inputs.get('sensor_white', False)
                sensor_blue = self.state.inputs.get('sensor_blue', False)
                exit_red = self.state.inputs.get('exit_red', False)
                exit_white = self.state.inputs.get('exit_white', False)
                exit_blue = self.state.inputs.get('exit_blue', False)

                if start_btn or stop_btn or reset_btn:
                    print(f"[BRIDGE->PLC] BUTTONS: start={start_btn} stop={stop_btn} reset={reset_btn}", flush=True)
                if sensor_red or sensor_white or sensor_blue or exit_red or exit_white or exit_blue:
                    print(f"[BRIDGE->PLC] SENSORS: red={sensor_red} white={sensor_white} blue={sensor_blue} | EXITS: red={exit_red} white={exit_white} blue={exit_blue}", flush=True)

            # Write all registers in one Modbus call
            # DEBUG: Show full register values occasionally
            if start_btn or stop_btn or reset_btn or sensor_red or sensor_white or sensor_blue:
                print(f"[BRIDGE] Writing registers starting at {base_addr}: {register_values}", flush=True)

            success = self._modbus_write_registers_via_core(base_addr, register_values)

            if not success:
                print(f"[BRIDGE] ERROR: Failed to write inputs to PLC", flush=True)

        except Exception as e:
            print(f"Error writing PLC inputs via CORE: {e}")

    def set_input(self, name: str, value: bool):
        """Set an input value (from 3D twin sensor)"""
        with self._lock:
            self.state.inputs[name] = value

    def set_register(self, name: str, value: int):
        """Set a holding register value"""
        if not self.client or not self.state.connected:
            return

        addr = self.IO_MAP['registers'].get(name)
        if addr is not None:
            try:
                self.client.write_register(
                    address=addr,
                    value=value,
                    slave=self.config.unit_id
                )
                with self._lock:
                    self.state.registers[name] = value
            except Exception as e:
                print(f"Error writing register {name}: {e}")

    def set_force(self, name: str, value: int):
        """Set a force override on a PLC output.

        This writes to force registers that the PLC program reads.
        The PLC logic then respects the force value instead of normal control.

        Args:
            name: Force register name (e.g., 'force_conveyor', 'force_alarm')
            value: 0=normal (no force), 1=force ON, 2=force OFF

        Security Note: This simulates CWE-284 (Improper Access Control).
        In a real system, unauthorized force access could:
        - Override safety interlocks
        - Disable alarms during emergencies
        - Cause equipment damage or personnel injury
        """
        addr = self.IO_MAP.get('forces', {}).get(name)
        if addr is None:
            print(f"[FORCE] Unknown force register: {name}", flush=True)
            return False

        # Validate value
        if value not in [0, 1, 2]:
            print(f"[FORCE] Invalid value {value} for {name} (must be 0, 1, or 2)", flush=True)
            return False

        # Write force to PLC via CORE network
        success = self._modbus_write_registers_via_core(addr, [value])

        if success:
            with self._lock:
                self.state.forces[name] = value
                # Track what's being forced for UI display
                if value == 0:
                    if name in self.state.forced_outputs:
                        del self.state.forced_outputs[name]
                else:
                    self.state.forced_outputs[name] = (value == 1)

            force_str = {0: 'NORMAL', 1: 'FORCE ON', 2: 'FORCE OFF'}[value]
            print(f"[FORCE] {name} = {force_str} (wrote {value} to MW{addr-1024})", flush=True)
            return True
        else:
            print(f"[FORCE] Failed to write {name}", flush=True)
            return False

    def clear_all_forces(self):
        """Clear all force overrides, returning to normal PLC control."""
        forces = self.IO_MAP.get('forces', {})
        for name in forces:
            self.set_force(name, 0)
        print("[FORCE] All forces cleared", flush=True)

    def get_state(self) -> Dict:
        """Get current I/O state as dict"""
        with self._lock:
            return {
                'connected': self.state.connected,
                'inputs': dict(self.state.inputs),
                'outputs': dict(self.state.outputs),
                'registers': dict(self.state.registers),
                'forces': dict(self.state.forces),
                'forced_outputs': dict(self.state.forced_outputs),
                'timestamp': self.state.last_update
            }

    def _broadcast_state(self):
        """Send current state to all connected WebSocket clients"""
        if not self.websocket_clients:
            return

        state = self.get_state()
        message = json.dumps({
            'type': 'plc_state',
            'data': state
        })

        # Send to all connected clients
        disconnected = set()
        for ws in self.websocket_clients:
            try:
                ws.send(message)
            except Exception:
                disconnected.add(ws)

        # Remove disconnected clients
        self.websocket_clients -= disconnected

    def handle_websocket(self, ws):
        """
        Handle a WebSocket connection from a 3D twin client.

        Protocol:
        - Client sends: {"type": "sensor", "name": "sensor_red", "value": true}
        - Server sends: {"type": "plc_state", "data": {...}}
        """
        self.websocket_clients.add(ws)
        print(f"3D Twin connected (total clients: {len(self.websocket_clients)})")

        # Send initial state
        try:
            ws.send(json.dumps({
                'type': 'plc_state',
                'data': self.get_state()
            }))
        except Exception as e:
            print(f"Error sending initial state: {e}")

        try:
            while True:
                message = ws.receive()
                if message is None:
                    break

                try:
                    data = json.loads(message)
                    msg_type = data.get('type')

                    if msg_type == 'sensor':
                        # 3D twin is reporting a sensor state
                        name = data.get('name')
                        value = data.get('value', False)
                        if name:
                            # Log button presses for debugging
                            if 'button' in name:
                                print(f"[BRIDGE] Button {name} = {value}", flush=True)

                            # For buttons and estop, implement minimum hold time (150ms)
                            # This ensures PLC edge detection sees the rising edge
                            # Estop is treated as momentary (auto-releases after hold)
                            if 'button' in name or name == 'estop':
                                if value:
                                    # Button/estop pressed - set state and write to PLC
                                    with self._lock:
                                        # Clear conflicting buttons (start/stop are mutually exclusive)
                                        if name == 'start_button':
                                            self.state.inputs['stop_button'] = False
                                            if 'stop_button' in self._button_hold_until:
                                                del self._button_hold_until['stop_button']
                                        elif name == 'stop_button':
                                            self.state.inputs['start_button'] = False
                                            if 'start_button' in self._button_hold_until:
                                                del self._button_hold_until['start_button']
                                        self.state.inputs[name] = True
                                    # Write to PLC (this takes time via subprocess)
                                    self._write_plc_inputs_via_core()
                                    # Set hold timer AFTER write completes
                                    with self._lock:
                                        self._button_hold_until[name] = time.time() + 0.2  # 200ms hold
                                    print(f"[BRIDGE] {name} = True (hold for 200ms)", flush=True)
                                else:
                                    # Button released - only clear if hold time expired
                                    with self._lock:
                                        hold_until = self._button_hold_until.get(name, 0)
                                        if time.time() >= hold_until:
                                            self.state.inputs[name] = False
                                        # else: ignore the release, hold timer will clear it
                            else:
                                # Non-button sensors - immediate update AND write to PLC
                                self.set_input(name, bool(value))
                                # CRITICAL: Write immediately to PLC so sensor pulse isn't missed
                                # Sensors may only be active for one message cycle
                                if self.config.use_core_network:
                                    self._write_plc_inputs_via_core()
                                else:
                                    self._write_plc_inputs()
                                # Log sensor events for debugging
                                if 'sensor' in name or 'exit' in name:
                                    print(f"[BRIDGE] Sensor {name} = {value} (written immediately)", flush=True)

                    elif msg_type == 'register':
                        # 3D twin is setting a register value
                        name = data.get('name')
                        value = data.get('value', 0)
                        if name:
                            self.set_register(name, int(value))

                    elif msg_type == 'get_state':
                        # Client requesting current state
                        ws.send(json.dumps({
                            'type': 'plc_state',
                            'data': self.get_state()
                        }))

                    elif msg_type == 'get_io_map':
                        # Client requesting I/O mapping info
                        ws.send(json.dumps({
                            'type': 'io_map',
                            'data': self.IO_MAP
                        }))

                    elif msg_type == 'force':
                        # Force override on PLC output (DANGEROUS - simulates attack)
                        # Values: 0=normal, 1=force ON, 2=force OFF
                        name = data.get('name')
                        value = data.get('value', 0)
                        if name:
                            success = self.set_force(name, int(value))
                            ws.send(json.dumps({
                                'type': 'force_result',
                                'name': name,
                                'value': value,
                                'success': success
                            }))

                    elif msg_type == 'clear_forces':
                        # Clear all force overrides
                        self.clear_all_forces()
                        ws.send(json.dumps({
                            'type': 'forces_cleared',
                            'success': True
                        }))

                except json.JSONDecodeError:
                    print(f"Invalid JSON from client: {message}")

        except Exception as e:
            print(f"WebSocket error: {e}")
        finally:
            self.websocket_clients.discard(ws)
            print(f"3D Twin disconnected (remaining clients: {len(self.websocket_clients)})")


# Global bridge instance (created when ICS topology is deployed)
_bridge_instance: Optional[PLCIOBridge] = None


def get_bridge() -> Optional[PLCIOBridge]:
    """Get the current bridge instance"""
    return _bridge_instance


def start_bridge(plc_ip: str = "10.0.0.10", plc_port: int = 502) -> PLCIOBridge:
    """Start the PLC I/O bridge for the ICS sorting facility"""
    global _bridge_instance

    # Stop existing bridge if running
    if _bridge_instance:
        _bridge_instance.stop()

    config = PLCIOConfig(
        plc_ip=plc_ip,
        plc_port=plc_port,
        poll_interval_ms=100
    )

    _bridge_instance = PLCIOBridge(config)
    _bridge_instance.start()

    return _bridge_instance


def stop_bridge():
    """Stop the PLC I/O bridge"""
    global _bridge_instance

    if _bridge_instance:
        _bridge_instance.stop()
        _bridge_instance = None
        print("PLC I/O Bridge stopped")
