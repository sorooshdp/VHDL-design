
# VHDL Design Repository

A collection of VHDL modules and a Maze Game implementation demonstrating various digital design concepts.

## Core Components

### 1. Basic Digital Circuits
- **3-to-8 Decoder**  
  Implements a 3-input to 8-output decoder with enable control.
- **Custom Circuit with XOR/AND**  
  Combines decoder outputs with logic gates for the final output.
- **Shift Register**  
  Supports various operations: store, shift left/right, and rotate left/right.

### 2. Memory Elements
- **Dual Port RAM**  
  Features an 8-bit data width with separate read/write ports.
- **FIFO**  
  A 64-byte circular buffer with dedicated read/write pointers.
- **Queue**  
  A generic FIFO implementation with configurable width and depth, including push/pop control.

### 3. Arithmetic Modules
- **16-bit Arithmetic Unit**  
  Supports addition (with carry), subtraction (with borrow), and overflow detection. Comes with a comprehensive testbench.

### 4. State Machines
- **Sequence Generator**  
  Produces a repeating sequence: 0 → 3 → 7 → 7 → 11 → 11 → 15 → 0.
- **Special Counter**  
  Implements a non-linear state sequence counter.

### 5. I/O Modules
- **Serial-to-Parallel Converter**  
  Converts serial input into an 8-bit parallel output with pattern matching.
- **VGA Controller**  
  Manages video output (640x480 resolution) for the Maze Game.

## Maze Game Project

A complete FPGA-based maze navigation game with VGA output.

### Features:
- Procedurally generated mazes using a DFS algorithm.
- Player movement with collision detection.
- Power-up system (including Ghost mode, Shrink, and Speed boost).
- Lives system and countdown timer.
- Seven-segment display interface.
- VGA output controller.

### Key Files:
- `game.vhd`: Main game logic.
- `vga.vhd`: VGA controller implementation.
- `UCF.ucf`: Pin constraints for the FPGA board.

> **Note:** The Maze Game is designed to run on a **Spartan 6 FPGA board**.

## Simulation

Testbenches are provided for:
- Arithmetic Module
- 3-to-8 Decoder
- Delay Examples
- Sequence Generator
- Serial-to-Parallel Converter

Example simulation command (ModelSim):
```bash
vcom arithmetic_module.vhd arithmetic_module_TB.vhd
vsim work.arithmetic_module_tb
run -all
```

## Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/sorooshdp-vhdl-design.git
   ```
2. **Compile using a VHDL simulator** (ModelSim or GHD).
3. **For the Maze Game:**
   - Use FPGA synthesis tools (Xilinx ISE/Vivado).
   - Connect the VGA output and input buttons as specified in the UCF file.

## Dependencies

- VHDL 93 compliant simulator.
- FPGA synthesis tools for the Maze Game.
- A VGA-compatible display for the game project.


## License

[MIT License](LICENSE)

