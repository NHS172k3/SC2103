# Lab 2: Memory Primitives - Complete Guide

## Overview

This lab implements a **64 x 8-bit distributed RAM** using Look-Up Tables (LUTs) on the Basys 3 FPGA. You'll learn how to work with memory primitives and control data flow in a real FPGA design.

**Target FPGA:** Artix-7 xc7a35tcpg236-1 (on Basys 3 board)

---

## Background Concepts

### What is Distributed RAM?

FPGAs contain two ways to implement memory:

1. **Block RAM (BRAM):** Dedicated memory blocks built into the FPGA silicon. These are large (typically 18Kb or 36Kb blocks) and efficient for big memories, but there's a fixed number of them on the chip.

2. **Distributed RAM (LUT-based):** Uses the FPGA's Look-Up Tables (LUTs) as small memory cells. Every LUT in an FPGA is essentially a tiny memory that normally stores combinational logic truth tables. But you can repurpose them as actual data storage.

In this lab, we use **distributed RAM**. Why? Because our memory is small (64 x 8 = 512 bits). Using a full Block RAM for just 512 bits would be wasteful when each BRAM block is 18,432 bits. Distributed RAM is the better fit for small memories.

### What is a Look-Up Table (LUT)?

A LUT is the fundamental building block of FPGA logic. In the Artix-7:
- Each LUT has **6 inputs** and **1 output**
- It stores a **64-bit truth table** (2^6 = 64 entries)
- Normally used for combinational logic (e.g., AND, OR, XOR functions)
- But can be configured as a **64x1 RAM** since it's literally a 64-entry memory

To build a 64x8 memory, we need **8 LUTs** (one for each bit of the 8-bit data word). Each LUT handles one bit position across all 64 addresses.

### Why 64 Depth?

The depth of 64 is left as the default because it maps perfectly to the LUT architecture:
- Each Artix-7 LUT has **6 address inputs** -> can address 2^6 = **64 locations**
- So a depth of 64 uses exactly **one LUT per data bit** with zero waste
- If you chose depth 128, you'd need 2 LUTs per bit plus a multiplexer, doubling resources
- 64 is the natural, most efficient depth for a single-LUT distributed memory

### Why 8-bit Data Width?

The data width of 8 is chosen because:
- 8 bits = 1 byte, the fundamental unit of data in computing
- It maps to the 8 slider switches available on the lower half of the Basys 3 board
- It displays nicely as 2 hex digits on the seven-segment display (e.g., `0xA3`)
- It requires exactly **8 LUTs** -- small enough to leave plenty of FPGA resources free

### Why Single Port RAM?

The Distributed Memory Generator offers several modes:
- **ROM (Read-Only Memory):** Data is fixed at synthesis time, cannot be written to at runtime
- **Single Port RAM:** One port for both reading and writing (one address bus shared)
- **Simple Dual Port RAM:** One port for writing, one separate port for reading (two address buses)
- **True Dual Port RAM:** Two independent ports, each capable of both reading and writing

We use **Single Port RAM** because:
- Our design only needs to read OR write at any given time, never both simultaneously
- It uses the fewest resources (one address bus, one data bus)
- The read is **asynchronous** (combinational) -- data appears at the output immediately when you set the address, without waiting for a clock edge
- Simpler control logic -- only `write_en` and `clk` needed for writes

### Why Unregistered Input/Output and No Pipelining?

In the Port Config tab, we verify that inputs and outputs are **unregistered**:
- **Unregistered output** means the read is purely combinational (asynchronous). When you change the address, the output data changes immediately in the same clock cycle, without needing a clock edge. This is the natural behavior of distributed RAM and gives us instant read access.
- **Registered output** would add a flip-flop on the output, meaning data only appears one clock cycle after setting the address. This is useful for higher clock speeds but adds latency we don't need.
- **No pipelining** means no extra register stages in the data path. Pipelining improves maximum clock frequency but adds clock cycles of delay. For our simple design running at a slow clock, we want immediate response.

### Synchronous Write vs Asynchronous Read

This is a fundamental property of FPGA distributed RAM:
- **Write is synchronous:** Data is written on the rising edge of `clk` when `write_en = 1`. This ensures clean, glitch-free writes.
- **Read is asynchronous:** The output (`spo`) continuously reflects whatever is stored at the current address. No clock needed. Change the address and the output updates immediately (after propagation delay).

This differs from Block RAM, where both reads and writes are typically synchronous.

---

## System Architecture

### Block Diagram

```
                                 6
  show_reg ─────────────────────────────────────────────────────┐
                                 ┌──────┐                       │
  d_in ──────/────┬──────────────┤ a    │                       │
            8     │              │      │  spo    mem_d          │
                  │     ┌───/───>│ d    ├───/────┐              │
                  │     │   8    │      │   8    │     ┌──────┐ │
  write_en ───────│─────│───────>│ we   │        ├──1──┤      │ │
                  │     │        │      │        │     │ MUX  ├─/──> d_out
  clk ────────────│─────│───────>│ >    │        │  ┌──┤      │  8
                  │     │        └──────┘        │  │  │      │
                  │     │        Lab2_mem         │  │  └──┬───┘
                  │     │                        │  │     │
                  │     │   ┌────────┐     reg_d │  │     │
                  │     │   │        │           │  │     │
                  └─────│──>│ D    Q ├─────/─────┘──┘     │
                        │   │        │     8              │
  save_data ────────────│──>│ en     │                    │
                        │   │        │                    │
  clk ──────────────────│──>│ >      │                    │
                        │   │        │                    │
  rst ──────────────────│──>│ R      │                    │
                            └────────┘                    │
                            D Flip-Flop                   │
                                                          │
                                    show_reg ─────────────┘
                                    (selects: 1=mem_d, 0=reg_d)
```

### Signal Descriptions

| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `clk` | 1 | Input | System clock (100 MHz from Basys 3 oscillator) |
| `rst` | 1 | Input | Active high synchronous reset -- clears `reg_d` to 0 |
| `d_in` | 8 | Input | Multi-purpose: carries data values OR memory addresses |
| `save_data` | 1 | Input | Enable signal for the D flip-flop -- stores `d_in` into `reg_d` |
| `write_en` | 1 | Input | Write enable for the RAM -- writes `reg_d` into memory at address `d_in[5:0]` |
| `show_reg` | 1 | Input | MUX select: 0 = show register, 1 = show memory output |
| `d_out` | 8 | Output | Selected output (either `reg_d` or `mem_d`) |
| `reg_d` | 8 | Internal | Output of the D flip-flop (staging register) |
| `mem_d` | 8 | Internal | Output of the RAM (`spo` port) -- data at current address |

---

## Task 1: Design the Lab2_top Module

### Learning Objectives

By completing Task 1, you will learn:
- How to use Vivado's IP Catalog to generate memory primitives
- The difference between distributed RAM (LUT-based) and Block RAM
- How to instantiate pre-generated IP cores in your custom Verilog
- How to build a complete memory system with control logic (register + MUX)
- How to interpret synthesis reports to understand resource utilization

### What You Need To Do

Create a Verilog module called `Lab2_top` that wires together three things:
1. A **64x8 distributed RAM** (generated via IP Catalog)
2. A **D flip-flop register** (written as an `always` block)
3. A **2:1 multiplexer** (written as a conditional `assign` statement)

### Step-by-Step Guide

#### Step 1: Create the Module Shell

```verilog
module Lab2_top(
    input clk,
    input rst,
    input write_en,
    input save_data,
    input show_reg,
    input [7:0] d_in,
    output [7:0] d_out
);

    wire [7:0] mem_d;   // output of the RAM (spo)
    reg [7:0] reg_d;    // output of the D flip-flop

    // ... components go here ...

endmodule
```

Note: `reg_d` is declared as `reg` because it is assigned inside an `always` block. `mem_d` is a `wire` because it is driven by the RAM IP output.

#### Step 2: Generate the Distributed RAM IP

This is done in Vivado's IP Catalog (not in code):

**What is the IP Catalog?**
- IP (Intellectual Property) Catalog is a library of pre-built, pre-optimized hardware components
- These are complex functional blocks that would take significant time to design from scratch
- Xilinx provides hundreds of IP cores: memories, DSP functions, communication interfaces, processors, etc.
- Using IP cores saves time, reduces bugs, and ensures optimal performance

**Why use IP instead of writing memory in Verilog?**
- Memory requires precise instantiation of FPGA primitives (RAMD64E, etc.)
- The IP generator handles all the low-level details and optimizations
- It guarantees the memory will synthesize correctly and efficiently
- Writing distributed RAM manually is error-prone and non-portable

**Exploring the IP Catalog (as mentioned in the lab manual):**
Before generating your memory, take a moment to explore the catalog:
- Expand different categories: Math Functions, Signal Processing, Communication Controllers
- Notice the variety: FIFOs, AXI interconnects, floating-point units, video processing blocks
- This gives you a sense of what's available for future projects
- Real FPGA designs often combine custom logic (your Verilog) with IP cores (pre-built blocks)

1. Open **IP Catalog** -> Memories & Storage Elements -> RAMs & ROMs -> **Distributed Memory Generator**
2. Configure:
   - **Component Name:** `Lab2_mem`
   - **Memory Config tab:**
     - Depth: `64` (default -- maps to 6-bit address = one LUT deep)
     - Data Width: `8` (one byte per address, matches our d_in width)
     - Memory Type: `Single Port RAM`
   - **Port Config tab:**
     - Input Options: Unregistered
     - Output Options: Unregistered
     - No pipelining
   - **RST & Initialization tab:** Leave defaults (no reset, no init file)
3. Click OK -> Generate Output Products -> Generate

**Why leave defaults in RST & Initialization tab?**
- **No reset on the memory itself:** Distributed RAM in FPGAs doesn't have a built-in reset. The memory contents are undefined at power-on, and that's acceptable. We reset the *register* (`reg_d`) instead, which is what matters for our initial state.
- **No initialization file:** We're not pre-loading the memory with data. It starts empty (undefined values) and gets filled during operation. If you needed ROM-like behavior (fixed lookup table), you'd provide a `.coe` (coefficient) file here.
- **Why this matters:** Block RAM *can* have initialization, but distributed RAM typically doesn't. This is a fundamental difference between the two memory types.

#### Why These Settings?

| Setting | Value | Reason |
|---------|-------|--------|
| Depth = 64 | 2^6 | Matches LUT architecture perfectly (6-input LUT = 64 entries) |
| Width = 8 | 8 bits | Matches switch count, byte-sized data, 2 hex digits on display |
| Single Port | 1 port | Only need one read/write port; simplest and cheapest |
| Unregistered I/O | No flip-flops | Gives asynchronous (instant) read; keeps design simple |
| No pipeline | 0 stages | No extra latency; we don't need high clock speeds |

#### Step 3: Instantiate the RAM

After generating the IP, find the instantiation template in:
**IP Sources -> Lab2_mem -> Instantiation Template -> Lab2_mem.veo**

The template looks like:
```verilog
Lab2_mem U1 (
    .a(d_in[5:0]),    // 6-bit address from lower bits of d_in
    .d(d_in),         // 8-bit data input -- BUT WAIT, see note below
    .clk(clk),        // clock for synchronous writes
    .we(write_en),    // write enable
    .spo(mem_d)       // 8-bit data output (asynchronous read)
);
```

**IMPORTANT:** Look at Figure 1 carefully. The data input (`d`) to the RAM comes from `reg_d`, NOT directly from `d_in`. The whole point of the register is to stage data before writing it to memory:

```verilog
Lab2_mem U1 (
    .a(d_in[5:0]),    // address comes from switches
    .d(reg_d),        // data comes from the REGISTER, not switches
    .clk(clk),
    .we(write_en),
    .spo(mem_d)       // memory output
);
```

**Why does the RAM data input come from `reg_d` instead of `d_in`?**

This is the heart of the design's workflow. We have only 8 switches (`d_in`), but we need to provide BOTH data AND address:

**The Problem:**
- To write to memory, we need: (1) a data value, (2) an address, (3) write_en signal
- But we only have 8 switches that can only show ONE value at a time
- We can't simultaneously display both the data value AND the target address

**The Solution - Two-Step Process:**
1. **Step 1 - Save data to register:**
   - Set switches to data value (e.g., `0x42`)
   - Press `save_data` button
   - The register captures and HOLDS this value internally
   - Now `reg_d = 0x42` permanently (until we change it)

2. **Step 2 - Write register to memory:**
   - Change switches to address (e.g., `0x05`)
   - Press `write_en` button
   - The memory writes `reg_d` (still `0x42`) to the address on `d_in[5:0]` (now `0x05`)
   - Result: `Memory[5] = 0x42`

**Why this architecture is clever:**
- The register acts as a "staging area" -- it holds data temporarily
- This allows us to reuse the same switches for BOTH purposes at DIFFERENT times (time-multiplexing)
- This is exactly how real computer buses work: address and data share the same wires at different times
- CPUs use this pattern constantly: "load-store architecture" where data moves through registers before reaching memory

**What would happen if we connected `.d(d_in)` directly?**
- When you press `write_en`, the switches would need to show BOTH the data AND the address simultaneously
- Impossible with one set of switches!
- The memory would write whatever garbage is on the switches at that moment (the address, not the data)

#### Why `d_in[5:0]` for Address?

The memory has 64 locations, needing a 6-bit address (2^6 = 64). But `d_in` is 8 bits. We only use the lower 6 bits `[5:0]` for addressing. The upper 2 bits `[7:6]` are ignored by the memory. This means:
- Valid addresses range from `0x00` to `0x3F` (0 to 63)
- Setting switches to `0x41` and `0x01` would access the same address (both have lower 6 bits = `000001`)

#### Step 4: Create the Register (D Flip-Flop)

This is a standard synchronous register with enable and reset:

```verilog
always @(posedge clk) begin
    if (rst)
        reg_d <= 8'b0;       // synchronous reset to zero
    else if (save_data)
        reg_d <= d_in;       // store switch values when save_data pressed
end
```

**Conceptual notes:**
- **Synchronous reset (`if (rst)`):** Reset only happens on the clock edge, not immediately. This is preferred in FPGA designs because it leads to more predictable timing.
- **Enable (`else if (save_data)`):** The register only updates when `save_data = 1`. Otherwise it holds its current value. This is called a "register with enable."
- **Priority:** Reset has higher priority than save. If both `rst` and `save_data` are high, the register resets to 0.
- **Non-blocking assignment (`<=`):** Always use `<=` in sequential (clocked) always blocks. This ensures correct simulation behavior when multiple registers update on the same clock edge.

#### Step 5: Create the Output Multiplexer

```verilog
assign d_out = show_reg ? mem_d : reg_d;
```

This is a **conditional (ternary) assignment**:
- When `show_reg = 1` -> output shows memory data (`mem_d`)
- When `show_reg = 0` -> output shows register data (`reg_d`)

**Why a multiplexer?** We have limited display outputs (just the 7-segment display). The MUX lets us view either the register or memory contents using the same display, toggled by a button press.

**Note on naming:** The signal is called `show_reg` but when it's HIGH (1), it shows the MEMORY, not the register. When it's LOW (0), it shows the register. This naming can be confusing -- think of `show_reg = 0` as the "default" state showing the register.

#### Step 6: Synthesize and Check

After synthesis, examine the utilization report:

**What elements are inferred?**
- **8 LUTs configured as RAM** (RAMD64E or similar) -- the distributed memory
- **8 Flip-Flops (FFs)** -- the `reg_d` register
- **8 LUTs as logic** -- the output multiplexer
- Possibly some buffer LUTs for routing

**Where is the memory?**
- The memory is inside the LUTs themselves, NOT in Block RAM. In the schematic, you'll see it represented as a RAM component, but in hardware, it's using the same LUT resources that normally implement logic gates.

**Why check the schematic?**
- The elaborated design schematic (RTL Analysis -> Open Elaborated Design -> Schematic) should visually match Figure 1 from the manual. If it doesn't, your connections are wrong. This is a quick visual sanity check before simulation.

---

## Task 2: Create the Testbench and Simulate

### Learning Objectives

By completing Task 2, you will learn:
- How to write comprehensive Verilog testbenches for verification
- The importance of simulation before hardware deployment
- How to generate clock signals and apply test stimuli in simulation
- How to observe internal signals (not just outputs) for debugging
- How to interpret waveforms to verify correct design operation
- The fundamental workflow: design → simulate → debug → iterate → deploy

### Why Simulate Before Hardware?

**The Problem with Hardware-First Testing:**
Testing on hardware is slow and painful:
- You need to manually toggle switches and press buttons
- You can't see internal signals (like `reg_d` and `mem_d`)
- Debugging is guesswork - "Why didn't it work? Which part failed?"
- One wrong connection can waste hours of troubleshooting
- Synthesis + implementation + bitstream generation takes 5-10 minutes per iteration
- No record of test results -- you have to manually write down what you see

**The Power of Simulation:**
Simulation gives you:
- **Full visibility** into every signal in the design (wires, regs, internal IPs)
- **Repeatable** test sequences -- run the exact same test 100 times
- **Fast iteration** -- change design, re-simulate in seconds (not minutes)
- **Waveform analysis** -- see exact timing relationships, identify race conditions
- **Automated verification** -- use `$display` or assertions to check correctness automatically
- **Debugging power** -- zoom in to nanosecond precision, see every signal transition

**Professional Practice:**
- In industry, designs are **heavily simulated** before FPGA/ASIC implementation
- Typical workflow: 80% simulation, 20% hardware testing
- Hardware should only verify what simulation already proved correct

### What You Need To Do

Create a Verilog testbench file called `Lab2_top_tb` that:
1. Instantiates your `Lab2_top` module (the Unit Under Test)
2. Generates a clock signal (simulated 100MHz clock)
3. Applies the test conditions from Figure 2 (the test sequence)
4. Verifies the output sequence: `0, 15, A3, 87, 15, 87`
5. Allows observation of internal signals `reg_d` and `mem_d`

### Testbench Structure Explained

#### Module Declaration

```verilog
`timescale 1ns / 1ps

module Lab2_top_tb;
```

**Why `timescale 1ns / 1ps`?**
- First value (`1ns`): The time unit. When you write `#10`, it means 10ns.
- Second value (`1ps`): The precision -- smallest time step the simulator can resolve.
- This is standard for FPGA simulation at 100MHz (10ns clock period).

**Why no ports?** Testbenches are the top-level of simulation. They don't connect to anything above them, so they have no input/output ports.

#### Signal Declarations

```verilog
    // Inputs declared as 'reg' because testbench DRIVES them
    reg clk;
    reg rst;
    reg write_en;
    reg save_data;
    reg show_reg;
    reg [7:0] d_in;

    // Outputs declared as 'wire' because testbench OBSERVES them
    wire [7:0] d_out;
```

**Why `reg` for inputs and `wire` for outputs?**
- In Verilog, anything you assign values to inside `initial` or `always` blocks must be `reg` type
- The testbench drives (assigns) the inputs, so they're `reg`
- The testbench just observes the outputs (driven by the DUT), so they're `wire`
- This does NOT mean they are physical registers -- `reg` is just a Verilog data type for procedural assignment

#### Unit Under Test (UUT) Instantiation

```verilog
    // Instantiate the Unit Under Test (UUT)
    Lab2_top uut (
        .clk(clk),
        .rst(rst),
        .write_en(write_en),
        .save_data(save_data),
        .show_reg(show_reg),
        .d_in(d_in),
        .d_out(d_out)
    );
```

**Why "uut"?** UUT stands for "Unit Under Test" -- standard naming for the module being tested. You could name it anything, but `uut` is convention.

#### Clock Generation

```verilog
    // Clock toggles every 5ns -> period = 10ns -> frequency = 100MHz
    always #5 clk = ~clk;
```

**Why 5ns toggle?**
- Toggle every 5ns means: HIGH for 5ns, LOW for 5ns = 10ns period
- 10ns period = 100MHz, matching the Basys 3 system clock
- The `always` block runs forever, creating a continuous clock

**Why is this after the initial block?** The `always` block for the clock must come after (or alongside) the `initial` block that sets `clk = 0`. If `clk` starts as undefined (`x`), `~clk` would also be `x` and the clock would never start.

#### Initial Block and Test Conditions

```verilog
    initial begin
        // Initialize all inputs
        clk = 0;
        rst = 1;        // Start in reset
        write_en = 0;
        save_data = 0;
        show_reg = 0;
        d_in = 8'h00;

        // Test sequence from Figure 2
        #10 rst = 0;
        #10 d_in = 8'h15;
        #10 save_data = 1;
        #10 save_data = 0; d_in = 8'h01;
        #10 write_en = 1;
        #10 write_en = 0;
        #10 d_in = 8'hA3;
        #10 save_data = 1;
        #10 save_data = 0; d_in = 8'h02;
        #10 write_en = 1;
        #10 write_en = 0;
        #10 d_in = 8'h87;
        #10 save_data = 1;
        #10 save_data = 0;
        #10 d_in = 8'h01;
        #10 show_reg = 1;
        #10 d_in = 8'h01; show_reg = 0;
        #10 $finish();
    end
```

**Understanding `#10`:**
- `#10` is a delay of 10 time units (10ns with our timescale)
- This matches exactly one clock period
- Each test step happens on a clock boundary, giving each operation one full clock cycle

**Why `rst` starts at 1?**
- The register needs to be initialized to a known state (zero)
- Starting with `rst = 1` ensures `reg_d = 0` before we begin testing
- After 10ns we release reset (`rst = 0`) and begin normal operation

**Understanding `$finish()`:**
- This system task tells the simulator to stop
- The waveform window may close automatically -- you need to reopen it manually
- In Vivado: use "Zoom to Fit" to see the complete waveform

### Test Sequence Walkthrough

#### Expected Output Sequence: `0, 15, A3, 87, 15, 87`

```
 Time  | Step | d_in | Controls    | reg_d | mem_d | show_reg | d_out | Notes
-------|------|------|-------------|-------|-------|----------|-------|------------------
  0    | Init | 00   | rst=1       | 00    | ??    |    0     | 00    | <- Output 1: 0
 10    |  1   | 00   | rst=0       | 00    | ??    |    0     | 00    |
 20    |  2   | 15   | (none)      | 00    | ??    |    0     | 00    |
 30    |  3   | 15   | save_data=1 | 00    | ??    |    0     | 00    |
 40    |  4   | 01   | save_data=0 | 15    | ??    |    0     | 15    | <- Output 2: 15
 50    |  5   | 01   | write_en=1  | 15    | ??    |    0     | 15    | Mem[1] = 0x15
 60    |  6   | 01   | write_en=0  | 15    | 15    |    0     | 15    |
 70    |  7   | A3   | (none)      | 15    | ??    |    0     | 15    |
 80    |  8   | A3   | save_data=1 | 15    | ??    |    0     | 15    |
 90    |  9   | 02   | save_data=0 | A3    | ??    |    0     | A3    | <- Output 3: A3
100    | 10   | 02   | write_en=1  | A3    | ??    |    0     | A3    | Mem[2] = 0xA3
110    | 11   | 02   | write_en=0  | A3    | A3    |    0     | A3    |
120    | 12   | 87   | (none)      | A3    | ??    |    0     | A3    |
130    | 13   | 87   | save_data=1 | A3    | ??    |    0     | A3    |
140    | 14   | 87   | save_data=0 | 87    | ??    |    0     | 87    | <- Output 4: 87
150    | 15   | 01   | (none)      | 87    | 15    |    0     | 87    | addr=1, Mem[1]=15
160    | 16   | 01   | show_reg=1  | 87    | 15    |    1     | 15    | <- Output 5: 15
170    | 17   | 01   | show_reg=0  | 87    | 15    |    0     | 87    | <- Output 6: 87
```

#### Understanding the Key Transitions

**Steps 3-4: Save data to register**
- At step 3, `save_data = 1` and `d_in = 0x15`
- On the next clock edge (step 4), the register captures `0x15`
- Simultaneously, `save_data` goes to 0 and `d_in` changes to `0x01`
- `d_out = reg_d = 0x15` (MUX selects register because `show_reg = 0`)

**Steps 5-6: Write register to memory**
- At step 5, `write_en = 1` and `d_in = 0x01` (address 1)
- On the clock edge, `reg_d` (0x15) is written to `Memory[1]`
- At step 6, `write_en` goes back to 0
- The memory now holds `0x15` at address 1

**Steps 15-16-17: The MUX switch (the confusing part!)**

This is the key sequence that demonstrates the multiplexer:

1. **Step 15** (`d_in = 0x01`, no control): Address switches to `0x01`. The memory asynchronously outputs whatever is at address 1 -> `mem_d = 0x15`. But `show_reg = 0`, so `d_out` still shows `reg_d = 0x87`.

2. **Step 16** (`show_reg = 1`): The MUX flips! Now `d_out = mem_d = 0x15`. The register hasn't changed -- it still holds `0x87`. We're just *looking* at memory now.

3. **Step 17** (`show_reg = 0`): The MUX flips back! `d_out = reg_d = 0x87`. Memory still holds `0x15` at address 1 -- nothing was modified. We just changed which value we're *viewing*.

**The Big Idea:** The multiplexer lets you "peek" at memory without changing the register, and switch back to viewing the register without changing memory. It's purely a display selection.

### Viewing Internal Signals in Vivado

After running the simulation:
1. In the **Scope/Object** window, expand `uut` (your Lab2_top instance)
2. Find `reg_d` and `mem_d` in the objects list
3. Right-click -> Add to Waveform
4. Press **Restart** then **Run All** to re-simulate with the new signals visible

This lets you verify that internal signals behave correctly, not just the final output.

**Important:** Do NOT close the simulator window after Task 2. You need it open for the lab assessment.

**Assessment Requirements for Task 2:**
- Keep the simulation window open showing the complete waveform with `reg_d` and `mem_d` visible
- Be able to explain what happens at each step of the test sequence
- Demonstrate understanding of the timing: when reg_d captures data, when memory is written, when the MUX switches
- Show that `d_out` follows the expected sequence: `0, 15, A3, 87, 15, 87`
- Your lab supervisor will verify your understanding during assessment

---

## Task 3: Implement on the FPGA

### Learning Objectives

By completing Task 3, you will learn:
- How to integrate your tested design into an FPGA-specific wrapper
- The purpose and structure of constraints files (XDC) for pin mapping
- How clock dividers enable human-usable interfaces on fast FPGA clocks
- The complete FPGA development workflow: synthesis → implementation → bitstream → programming
- How to operate and verify a hardware design on a physical FPGA board
- The importance of modular design (separating core logic from board-specific interfaces)

### What You Need To Do

Wire your `Lab2_top` module into the provided FPGA wrapper (`Lab2_imp.v`) and configure the physical pin mappings in the constraints file (`Lab2.xdc`) so the design works on the actual Basys 3 board.

### Understanding the Implementation Hierarchy

```
Lab2_imp (top-level for FPGA)
|-- Lab2_top (YOUR design from Task 1)
|   |-- Lab2_mem (distributed RAM IP)
|   |-- (register + mux logic)
|-- clkgen (clock divider: 100MHz -> ~0.37Hz)
|-- seven_seg (7-segment display driver)
```

**Why a separate `Lab2_imp` wrapper?**
- `Lab2_top` is your pure design -- just memory logic
- `Lab2_imp` adds FPGA-specific support modules:
  - Clock divider (buttons need a slow clock to be usable by a human)
  - 7-segment display driver (converts 8-bit binary to display digits)
- This separation keeps your design portable and testable independently
- In Task 2, you tested `Lab2_top` directly without the FPGA-specific modules

### Step 1: Instantiate Lab2_top in Lab2_imp.v

In `Lab2_imp.v`, find the comment:
```verilog
// Instantiate your Lab2_top module here. Connect d_out to tmp_data.
```

Add your instantiation below it:
```verilog
Lab2_top U4 (
    .clk(sClk),        // Use the SLOW clock, not the 100MHz clock!
    .rst(rst),
    .write_en(write_en),
    .save_data(save_data),
    .show_reg(show_reg),
    .d_in(d_in),
    .d_out(tmp_data)    // Output goes to tmp_data wire for 7-seg display
);
```

**Why connect to `sClk` (slow clock) instead of `clk`?**

This is one of the most important conceptual points in the lab:

**The Problem - Human vs. FPGA Time Scales:**
- The raw `clk` signal runs at 100MHz = 100,000,000 clock cycles per second
- One clock period = 10 nanoseconds (10 billionths of a second)
- A human button press lasts approximately 100 milliseconds (0.1 seconds)
- At 100MHz, 100ms = **10 million clock cycles!**

**What would happen with the 100MHz clock?**
- You press and hold `save_data` for 100ms
- Your register would try to capture `d_in` on **10 million consecutive rising edges**
- The memory write would occur **millions of times**
- Result: completely unpredictable behavior, multiple unintended writes

**The Solution - Clock Division:**
- The `clkgen` module divides the 100MHz clock by **2^28 = 268,435,456**
- Output frequency: 100MHz / 268M = **~0.373 Hz**
- Output period: **~2.68 seconds** per full cycle
- Now one clock edge happens roughly every **1.34 seconds**

**How to Use the Slow Clock:**
1. Press and **hold** the button (e.g., `save_data`)
2. Watch LED[7] (which shows the slow clock state)
3. Wait until LED[7] **changes state** (blinks)
4. **Release** the button
5. The rising edge just occurred → your operation was captured **exactly once**

**Why LED[7] shows the slow clock:**
- `sClk` is connected to LED[7] via the XDC constraints
- LED ON = clock HIGH, LED OFF = clock LOW
- When the LED blinks (changes state), you know a clock edge just happened
- This provides visual feedback of when your button press was sampled

**Alternative approaches (not used here):**
- **Button debouncing:** Filter button bounces with logic/delays
- **Edge detection:** Detect button press edges and generate one-cycle pulses
- The slow clock method is simpler but requires patient button holding

**Why `tmp_data`?**
- `tmp_data` is an internal wire in `Lab2_imp` that carries your 8-bit output to the `seven_seg` display module
- The seven-segment driver splits this into two 4-bit hex digits and displays them

### Step 2: Understanding the Provided Modules

#### clkgen.v -- Clock Divider

```verilog
module clkgen(input clk_in, output clk_out);
    reg [27:0] counter = 28'd0;
    always @(posedge clk_in)
        counter <= counter + 1'b1;
    assign clk_out = counter[27];
endmodule
```

**How it works:**
- A 28-bit counter increments every 100MHz clock tick
- `counter[27]` is the MSB, which toggles every 2^27 = 134,217,728 cycles
- This creates a clock with period = 2^28 / 100MHz = **2.68 seconds**
- `sClk` output goes to LED[7] so you can see it blink
- Your `Lab2_top` runs on this slow clock so button presses are captured cleanly

**Why not just debounce the buttons?**
- Button debouncing is another valid approach, but the slow clock method is simpler
- It also provides a visible indicator (LED blink) of when the clock edge occurs
- The tradeoff is that you must hold the button for up to ~2.7 seconds

#### seven_seg.v -- 7-Segment Display Driver

**How it works:**
- Takes an 8-bit input `a` and displays it as two hexadecimal digits
- Uses a 2-bit slow clock (`count[19:18]`) derived from the 100MHz clock to rapidly alternate between the displays
- This multiplexing happens at ~95Hz -- faster than the eye can see -- making both digits appear lit simultaneously
- When `sel = 1` (btnD pressed), displays your bench number instead of the data
- Active-low outputs: `seg_L` and `anode_L` are LOW to turn ON (the Basys 3 uses common-anode 7-segment LEDs)
- Only the two rightmost displays are used; the two leftmost are held OFF (`anode_L[3:2] = 11`)

**Why active-low?**
- The Basys 3's 7-segment displays are common-anode. Each segment turns ON when its cathode is pulled LOW.
- The anode select is also active-low: pulling an anode LOW enables that digit.
- This is a hardware design choice by the board manufacturer, not something you control.

**Updating your bench number:**
At the bottom of `seven_seg.v` (lines 94-95), change:
```verilog
wire [3:0] benchNo_Hi = 4'd9;  // tens digit of your bench number
wire [3:0] benchNo_Lo = 4'd5;  // ones digit of your bench number
```
Replace `9` and `5` with your actual bench number digits. You may also need to add an offset as instructed by your lab supervisor.

### Step 3: Configure XDC Pin Constraints

The XDC (Xilinx Design Constraints) file maps your Verilog signals to physical FPGA pins.

**What is an XDC file?**
- XDC stands for Xilinx Design Constraints
- It tells the FPGA tools which physical pin on the chip each signal in your design connects to
- Without it, the tools wouldn't know which switch controls which signal
- It also sets the I/O voltage standard (LVCMOS33 = 3.3V low-voltage CMOS)

**What is LVCMOS33?**
- Every I/O pin needs to know what voltage level to use
- **LVCMOS** = Low Voltage CMOS logic standard
- **33** = 3.3 volts
- The Basys 3 board uses 3.3V logic on all its I/O banks
- All pins must be set to LVCMOS33 to match the board hardware

Some connections are already made in the provided file. You need to add:

#### Slider Switches (SW7-SW0 -> d_in[7:0])

Uncomment and rename these lines in `Lab2.xdc`:

```tcl
## SW0 -> d_in[0]
set_property PACKAGE_PIN V17 [get_ports {d_in[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {d_in[0]}]

## SW1 -> d_in[1]
set_property PACKAGE_PIN V16 [get_ports {d_in[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {d_in[1]}]

## SW2 -> d_in[2]
set_property PACKAGE_PIN W16 [get_ports {d_in[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {d_in[2]}]

## SW3 -> d_in[3]
set_property PACKAGE_PIN W17 [get_ports {d_in[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {d_in[3]}]

## SW4 -> d_in[4]
set_property PACKAGE_PIN W15 [get_ports {d_in[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {d_in[4]}]

## SW5 -> d_in[5]
set_property PACKAGE_PIN V15 [get_ports {d_in[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {d_in[5]}]

## SW6 -> d_in[6]
set_property PACKAGE_PIN W14 [get_ports {d_in[6]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {d_in[6]}]

## SW7 -> d_in[7]
set_property PACKAGE_PIN W13 [get_ports {d_in[7]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {d_in[7]}]
```

#### Push Buttons (3 horizontal buttons)

```tcl
## btnL -> show_reg
set_property PACKAGE_PIN W19 [get_ports show_reg]
    set_property IOSTANDARD LVCMOS33 [get_ports show_reg]

## btnC -> write_en
set_property PACKAGE_PIN U18 [get_ports write_en]
    set_property IOSTANDARD LVCMOS33 [get_ports write_en]

## btnR -> save_data
set_property PACKAGE_PIN T17 [get_ports save_data]
    set_property IOSTANDARD LVCMOS33 [get_ports save_data]
```

#### Already Configured (don't change these)

| Pin | Signal | Button/Resource |
|-----|--------|-----------------|
| W5  | `clk` | 100MHz oscillator |
| T18 | `rst` | btnU (top push button) |
| U17 | `sel` | btnD (bottom push button) |
| V14 | `sClk` | LED[7] (slow clock indicator) |
| Various | `seg_L[6:0]`, `anode_L[3:0]` | 7-segment display segments and anodes |

### Physical Button Layout

```
                rst (btnU)
                T18
                  |
                  |
   show_reg ---- [ ] ---- save_data
   (btnL)                  (btnR)
   W19                     T17
                  |
                  |
              write_en
              (btnC)
               U18
                  |
                  |
                sel (btnD)
                U17
```

### Step 4: Build and Program

The FPGA build process has three stages:

1. **Synthesize** -- Converts your Verilog RTL code into a netlist of FPGA primitives (LUTs, flip-flops, RAMs). This is like "compiling" your hardware description.

2. **Implement** -- Places those primitives onto specific locations on the physical FPGA chip and routes the wires between them. It uses the XDC file to know which I/O pins to use.

3. **Generate Bitstream** -- Creates the `.bit` file, which is a binary configuration that programs every configurable element on the FPGA. This file is loaded into the FPGA to make it behave as your design.

4. **Open Hardware Manager** -> Connect to target -> Program device with the `.bit` file.

### Operating the Design on Hardware

**Store a value (e.g., 0x42 at address 0x05):**
1. Press btnU (rst) briefly to reset the system
2. Set switches to `0100 0010` (0x42)
3. Press and **hold** btnR (`save_data`) until LED[7] blinks -> release
   - `reg_d` now contains 0x42
   - Display shows `42`
4. Set switches to `0000 0101` (0x05)
5. Press and **hold** btnC (`write_en`) until LED[7] blinks -> release
   - `Memory[5]` now contains 0x42

**Read the value back:**
6. Set switches to `0000 0101` (0x05) -- address 5
7. Press and **hold** btnL (`show_reg`)
   - Display switches from register to memory
   - Display shows `42` (contents of Memory[5])
8. Release btnL
   - Display switches back to register value (0x42)

**Why hold until LED blinks?**
The slow clock runs at ~0.37Hz. Your button press needs to span at least one rising edge of this slow clock to be captured. LED[7] shows the slow clock state -- when it changes (blinks), a clock edge just occurred and your input was sampled.

**Showing your bench number:**
- Press and hold btnD (`sel`) -- the display will show your bench number instead of data
- Release btnD to go back to showing data

### Assessment Requirements for Task 3

For successful lab completion, you must demonstrate:

1. **Simulation from Task 2:**
   - Keep the simulator window open with complete waveform
   - Show `reg_d` and `mem_d` internal signals
   - Be able to explain the test sequence and timing

2. **Hardware Operation:**
   - Successfully store values to memory at different addresses
   - Successfully read values back from memory
   - Demonstrate the MUX functionality (switching between register and memory views)
   - Show your bench number using the `sel` button

3. **Understanding:**
   - Explain why we use a slow clock instead of 100MHz
   - Explain why the register is needed (staging area for data)
   - Explain the two-step process: save to register, then write to memory
   - Explain the difference between distributed RAM and Block RAM
   - Explain why we chose depth=64 and width=8

**What the Lab Supervisor Will Check:**
- Both simulation waveforms (Task 2) AND hardware operation (Task 3) must be shown
- You must demonstrate understanding, not just that "it works"
- Be prepared to answer conceptual questions about your design

---

## Warnings You Can Safely Ignore

| Stage | Warning | Why It's OK |
|-------|---------|-------------|
| IP Generation | Out-of-Context Module Runs | Unconnected ports in the RAM IP that we don't use (dual-port signals, etc.) |
| Synthesis (Task 1) | `[Constraints 18-5210] No constraints selected` | No XDC file yet in Task 1 -- expected |
| Synthesis (Task 3) | `[Timing 38-316] Clock period different` | The IP was synthesized out-of-context with a default clock period |
| Synthesis (Task 3) | `anode_L[3] driven by constant 1` | The upper two 7-seg displays are intentionally unused (held off) |
| Synthesis (Task 3) | `anode_L[2] driven by constant 1` | Same as above |

**Warnings that should NOT appear:**
- Implementation stage: should be zero warnings
- Bitstream stage: should be zero warnings
- If you get warnings at these stages, something is wrong with your constraints or connections

---

## Key Concepts Mastered in This Lab

### 1. Memory Hierarchy in FPGAs

**Two Types of Memory:**
- **Distributed RAM (LUT-based):** Small, fast, flexible. Best for small memories (< 1Kb). Uses logic resources.
- **Block RAM (BRAM):** Large, dedicated blocks. Best for large memories (> 1Kb). Fixed quantity on chip.

**When to use each:**
- Use distributed RAM when: memory is small, you need flexible sizes, you want fast access, you have spare LUTs
- Use Block RAM when: memory is large, you need lots of storage, you want to preserve logic resources

### 2. Time-Multiplexing of Resources

**The Core Concept:**
- Limited I/O resources (8 switches) serve multiple purposes at different times
- Same switches provide DATA (when saving) and ADDRESS (when writing/reading)
- This is how real systems work: multiplexed address/data buses in CPUs, DDR memory, etc.

**Why This Matters:**
- Real-world designs always have resource constraints
- Sharing resources across time (multiplexing) vs. space (parallel buses) is a fundamental trade-off
- Understanding this pattern is key to efficient hardware design

### 3. Synchronous vs. Asynchronous Operations

**Synchronous (clock-dependent):**
- Register captures data on clock edges
- Memory writes happen on clock edges
- Provides clean, predictable behavior
- Immune to glitches and race conditions

**Asynchronous (combinational):**
- Memory reads happen immediately when address changes
- MUX output changes immediately when select changes
- Faster (no clock delay) but more vulnerable to glitches

**Design Pattern:**
- Synchronous operations forstate changes (writes, register updates)
- Asynchronous operations for reads/lookups (when you just need to see data)

### 4. Staging Registers in Digital Design

**The Pattern:**
- Input → Register (staging area) → Processing → Output
- Register "holds" data while other inputs change
- Allows sequential operations on the same I/O pins
- Mimics CPU architectures: Load → Operate → Store

**Real-World Applications:**
- CPU registers: accumulator, index registers, stack pointer
- Pipeline stages in processors: fetch → decode → execute → writeback
- FIFO buffers: staging data between fast and slow components
- DMA controllers: holding addresses while transferring data

### 5. Clock Domain Management

**The Challenge:**
- Human interaction speed: ~100ms (0.1 seconds)
- FPGA clock speed: 10ns (0.00000001 seconds)
- **7 orders of magnitude difference!**

**The Solution:**
- Clock division: create a "human-speed" clock from the FPGA clock
- Visual feedback: LED shows when clock edges occur
- Patient interaction: hold buttons until you see the clock edge

**Alternative Strategies (for future labs):**
- Button debouncing circuits
- Synchronizers for crossing clock domains
- Edge detectors for generating single-cycle pulses
- State machines for protocols

---

## Common Mistakes and How to Avoid Them
### Mistake 1: Not Holding Buttons Until LED Blinks

**Problem:** Pressing and immediately releasing buttons on the FPGA
**Result:** No clock edge occurred during your press → no operation captured
**Solution:** Press, hold, watch LED[7], release after it blinks

### Mistake 2: Forgetting to Add Internal Signals to Simulation Waveform

**Problem:** Only viewing `d_out` in simulation
**Result:** Can't debug when something goes wrong -- no visibility into `reg_d` or `mem_d`
**Solution:** Always add internal signals to waveform: expand `uut` → right-click `reg_d` and `mem_d` → Add to Waveform

### Mistake 3: Closing the Simulator After Task 2

**Problem:** Closing the simulation window
**Result:** Lab supervisor can't verify your Task 2 work → incomplete assessment
**Solution:** Keep simulator open throughout the entire lab session

### Mistake 4: Wrong XDC Pin Mappings

**Problem:** Copy-pasting switch pins but forgetting to change signal names
**Result:** Synthesis succeeds, but switches control wrong signals on hardware
**Solution:** Carefully match each `set_property PACKAGE_PIN` to the correct `{signal_name[bit]}`

### Mistake 5: Not Understanding the Test Sequence

**Problem:** Memorizing "d_out should be 0, 15, A3, 87, 15, 87" without understanding WHY
**Result:** Can't explain what's happening → fails assessment questions
**Solution:** Study the test sequence walkthrough table carefully. Understand each step.

---

## Design Patterns (Continued)

### Pattern 1: Input Time-Multiplexing
The same switches (`d_in`) serve dual purposes at different times:
- **Data input** when pressing `save_data`
- **Address input** when pressing `write_en` or reading memory

This is extremely common in embedded systems with limited I/O pins. Real microcontrollers use similar techniques with multiplexed data/address buses.

### Pattern 2: Register as Staging Area
You can't directly write from switches to memory because the switches must also specify the address. The register solves this:
1. Stage data in register first (switches = data, press save_data)
2. Then write register to memory (switches = address, press write_en)

This mimics real CPU architectures (load-store architecture) where data flows through registers before reaching memory.

### Pattern 3: Synchronous Write, Asynchronous Read
- **Write:** Requires `write_en = 1` AND a clock edge (synchronous). This prevents glitches from corrupting memory.
- **Read:** Happens immediately when the address changes (asynchronous/combinational). No clock edge needed.

This is the natural behavior of distributed RAM in FPGAs. Block RAM, by contrast, has synchronous reads too.

### Pattern 4: Module Hierarchy
The design is split into reusable modules:
- `Lab2_top` -- pure memory logic (portable, testable alone)
- `clkgen` -- clock management (reusable utility)
- `seven_seg` -- display driver (reusable utility)
- `Lab2_imp` -- top-level wrapper that ties everything together for the specific FPGA board

This separation of concerns is standard practice in digital design for managing complexity and enabling reuse.

---

## Quick Reference: Expected Test Outputs

| # | d_out | What happened |
|---|-------|---------------|
| 1 | 0x00 | Reset cleared the register |
| 2 | 0x15 | Saved 0x15 to register, now displaying it |
| 3 | 0xA3 | Saved 0xA3 to register, now displaying it |
| 4 | 0x87 | Saved 0x87 to register, now displaying it |
| 5 | 0x15 | show_reg=1, displaying Memory[1] which holds 0x15 |
| 6 | 0x87 | show_reg=0, back to displaying register which holds 0x87 |

**Memory contents after test:**
- Memory[1] = 0x15
- Memory[2] = 0xA3
- All other addresses = undefined (uninitialized)

---

## File Structure

```
Lab2/
|-- SC2103_lab2.pdf      # Lab manual (reference)
|-- README.md            # This guide
|-- Lab2_top.v           # YOUR main design module (Task 1) -- create this
|-- Lab2_top_tb.v        # YOUR testbench (Task 2) -- create this
|-- Lab2_imp.v           # FPGA top-level wrapper (given -- edit to add instantiation)
|-- Lab2.xdc             # Pin constraints (given -- edit to add switch/button pins)
|-- clkgen.v             # Clock divider (given -- do not modify)
|-- seven_seg.v          # 7-seg display driver (given -- edit bench number only)
```

---

## Tips for Success

1. **Hold buttons until LED[7] blinks** -- the slow clock period is ~2.7 seconds
2. **Reset first** -- always press btnU before starting to clear the register
3. **Check `show_reg` state** -- know whether you're viewing register or memory
4. **Order matters** -- save to register BEFORE writing to memory
5. **Update bench number** -- edit `seven_seg.v` lines 94-95 with your bench number
6. **Keep simulator open** -- you need it for assessment (do NOT close after Task 2)
7. **Add internal signals to waveform** -- add `reg_d` and `mem_d` from the `uut` scope for debugging
8. **Use local drive** -- create the Vivado project on a local drive, NOT a network drive

---

## Debugging Checklist

| Problem | Likely Cause | Solution |
|---------|--------------|----------|
| Display shows wrong value | Wrong `show_reg` state | Toggle btnL |
| Write doesn't work | Didn't hold button long enough | Hold until LED[7] blinks |
| Always shows 0 | Still in reset | Release btnU |
| Can't read memory | Wrong address on switches | Set to correct address |
| Testbench output wrong | Check MUX connection or register logic | View `reg_d` and `mem_d` in waveform |
| Synthesis uses Block RAM | Wrong IP settings | Regenerate IP with "Distributed Memory Generator" |
| `d_out` is always X in sim | Forgot to connect `spo` to `mem_d` | Check RAM instantiation port connections |
| Sim won't start | Clock not initialized | Make sure `clk = 0` in initial block |
| Implementation warnings | Missing XDC constraints | Check all switch and button pins are mapped |

---

## Summary: What You Learned

This lab taught fundamental concepts that apply throughout digital design:

### Technical Skills
✓ Generated and instantiated FPGA IP cores (distributed memory)
✓ Wrote Verilog testbenches with clock generation and test stimuli
✓ Configured XDC constraint files for pin mapping
✓ Synthesized, implemented, and programmed an FPGA design
✓ Used simulation tools to debug before hardware deployment

### Conceptual Understanding
✓ **Memory types:** Distributed RAM vs. Block RAM, when to use each
✓ **Resource multiplexing:** Sharing limited I/O across time
✓ **Staging registers:** Why and how to buffer data between operations
✓ **Clock domains:** Managing human vs. FPGA time scales
✓ **Synchronous vs. asynchronous:** When operations need clocks, when they don't
✓ **IP-based design:** Combining pre-built blocks with custom logic

### Design Workflow
✓ **Modular design:** Separating core logic from board-specific wrappers
✓ **Simulation-first:** Test in simulation before deploying to hardware
✓ **Verification:** Use waveforms and internal signals for debugging Using constraints:** Map abstract signals to physical hardware pins

### Real-World Patterns
✓ **Bus multiplexing:** How CPUs share wires for address and data
✓ **Load-store architecture:** Data flows through registers to memory
✓ **Clock division:** Adapting fast clocks for slow interfaces
✓ **Visual feedback:** Using LEDs to show internal state

---

## Next Steps

After completing this lab, you're ready to:
- Design more complex memory systems (caches, FIFOs, RAMs with different configurations)
- Work with Block RAM for larger memory structures
- Implement state machines that control memory operations
- Build CPU-like architectures with register files and data paths
- Design communication protocols with proper timing and control signals

---

**Remember:** Understanding WHY things work (the concepts) is more valuable than memorizing HOW to do them (the steps). The concepts transfer to every future design. The steps are specific to this lab.

**Good luck with your assessment!**
