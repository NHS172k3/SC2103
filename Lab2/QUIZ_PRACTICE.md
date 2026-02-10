# Lab 2 Quiz Practice: Memory Primitives

**Time allocation:** ~30-45 minutes for full quiz
**Topics covered:** Distributed RAM, design patterns, timing, Verilog implementation

---

## Section A: Memory Architecture (15 questions)

### Q1. What type of memory is used in Lab 2?
A) Block RAM (BRAM)
B) Distributed RAM (LUT-based)
C) Flash memory
D) DRAM

### Q2. Why is distributed RAM preferred over Block RAM for this lab?
A) Distributed RAM is faster
B) The memory size (512 bits) is too small to efficiently use BRAM
C) Block RAM doesn't exist on Artix-7 FPGAs
D) Distributed RAM has built-in reset functionality

### Q3. How many LUTs are required to implement a 64×8 distributed RAM?
A) 1 LUT
B) 8 LUTs
C) 64 LUTs
D) 512 LUTs

### Q4. Why is the memory depth set to 64 in this lab?
A) It's the maximum depth supported
B) It matches perfectly with a 6-input LUT architecture (2^6 = 64)
C) 64 is the standard depth for all FPGAs
D) It's required by the Basys 3 board

### Q5. What does each LUT in the distributed RAM store?
A) All 64 addresses
B) One bit across all 64 addresses
C) One complete 8-bit word
D) The control logic

### Q6. The memory address port is 6 bits wide because:
A) We only have 6 switches available
B) 2^6 = 64, matching the memory depth
C) The FPGA requires 6-bit addresses
D) It's a standard in Verilog

### Q7. What happens to d_in[7:6] when addressing memory?
A) They are used for error checking
B) They control the write enable
C) They are ignored (only d_in[5:0] is used for address)
D) They select the memory bank

### Q8. Which statement about the memory's read operation is TRUE?
A) Reads are synchronous (require clock edge)
B) Reads are asynchronous (combinational, immediate)
C) Reads require a read enable signal
D) Reads take 2 clock cycles

### Q9. Which statement about the memory's write operation is TRUE?
A) Writes are asynchronous
B) Writes occur immediately when data changes
C) Writes are synchronous (occur on clock edge when write_en=1)
D) Writes don't require a clock

### Q10. Can distributed RAM be initialized with data at synthesis time?
A) Yes, always
B) No, never
C) Yes, but it's typically not done; Block RAM is better for initialization
D) Only on certain FPGA families

### Q11. In the IP Configuration, why are inputs/outputs set as "unregistered"?
A) To save power
B) To allow asynchronous reads and keep the design simple
C) Because the FPGA doesn't have enough registers
D) It's a requirement for distributed RAM

### Q12. What would happen if we used a depth of 128 instead of 64?
A) It would fail to synthesize
B) It would require 2 LUTs per bit plus multiplexers, doubling resources
C) It would be more efficient
D) Nothing would change

### Q13. The memory output port 'spo' stands for:
A) Special Purpose Output
B) Single Port Output
C) Synchronous Pipelined Output
D) Serial Port Output

### Q14. Which memory type typically has synchronous reads?
A) Distributed RAM
B) Block RAM
C) Both
D) Neither

### Q15. The total memory capacity in this lab is:
A) 64 bits
B) 512 bits (64 × 8)
C) 8 bits
D) 1 Kbit

---

## Section B: Design Architecture (15 questions)

### Q16. What is the purpose of the register (reg_d) in this design?
A) To store the memory output
B) To act as a staging area for data before writing to memory
C) To clock the system
D) To display data on the 7-segment display

### Q17. Why does the RAM's data input connect to reg_d instead of d_in?
A) It's a mistake in the design
B) To allow time-multiplexing: save data to register, then change switches to address
C) reg_d is faster than d_in
D) The IP core requires it

### Q18. What is the correct two-step process to write to memory?
A) Set address, press write_en
B) Set data, press write_en
C) Set data and press save_data, then set address and press write_en
D) Press write_en, then set data

### Q19. The multiplexer (MUX) in the design:
A) Selects between clock sources
B) Selects between displaying register contents or memory contents
C) Selects which memory address to read
D) Selects between different data inputs

### Q20. When show_reg = 1, d_out displays:
A) The register contents (reg_d)
B) The memory contents (mem_d)
C) The input switches (d_in)
D) Zero

### Q21. When show_reg = 0, d_out displays:
A) The register contents (reg_d)
B) The memory contents (mem_d)
C) The input switches (d_in)
D) The previous value

### Q22. The naming of 'show_reg' can be confusing because:
A) When it's 1, it shows memory, not register
B) When it's 0, it shows register (the default state)
C) Both A and B
D) Neither A nor B

### Q23. What architectural pattern does the register usage represent?
A) State machine
B) Load-store architecture / staging area
C) Pipeline
D) Cache memory

### Q24. How many internal signals are declared in Lab2_top?
A) None
B) One (mem_d)
C) Two (reg_d and mem_d)
D) Three

### Q25. Why is reg_d declared as 'reg' type?
A) It will be a physical register
B) It's assigned inside an 'always' block
C) It needs to be fast
D) Verilog requires it for 8-bit signals

### Q26. Why is mem_d declared as 'wire' type?
A) It's driven by the RAM IP output
B) It changes frequently
C) It's faster than 'reg'
D) It's an input

### Q27. The reset signal in this design is:
A) Asynchronous (immediate)
B) Synchronous (occurs on clock edge)
C) Not needed
D) Active low

### Q28. What does the reset do?
A) Clears the memory
B) Clears reg_d to 0
C) Resets both memory and register
D) Resets the entire FPGA

### Q29. The design pattern of using d_in for both data and address is called:
A) Multiplexing
B) Time-division multiplexing
C) Demultiplexing
D) Address/data bus sharing

### Q30. In the always block, why do we use <= instead of =?
A) It's faster
B) Non-blocking assignment is required for sequential (clocked) logic
C) Blocking assignment would cause errors
D) Both B and C

---

## Section C: Clock Management (10 questions)

### Q31. What is the frequency of the Basys 3 system clock?
A) 10 MHz
B) 50 MHz
C) 100 MHz
D) 1 GHz

### Q32. Why can't we use the 100 MHz clock directly for button inputs?
A) It's too slow
B) A button press (~100ms) would span 10 million clock cycles
C) The FPGA can't handle it
D) It would damage the hardware

### Q33. The clock divider (clkgen) divides the clock by:
A) 2^8
B) 2^16
C) 2^28
D) 2^32

### Q34. What is the approximate frequency of the slow clock (sClk)?
A) ~0.37 Hz
B) ~10 Hz
C) ~1 kHz
D) ~50 MHz

### Q35. The period of the slow clock is approximately:
A) 10 ns
B) 100 ms
C) ~2.68 seconds
D) 10 seconds

### Q36. How does the clock divider work?
A) Using a PLL
B) Using a 28-bit counter; output is the MSB which toggles every 2^27 cycles
C) Using multiple flip-flops in series
D) Using the FPGA's built-in clock divider

### Q37. Why is LED[7] connected to sClk?
A) To show the system is powered
B) To provide visual feedback of when clock edges occur
C) To indicate errors
D) To show the reset state

### Q38. When operating the FPGA, you should press a button:
A) Quickly and release
B) Hold until LED[7] blinks, then release
C) Hold for exactly 1 second
D) Press multiple times rapidly

### Q39. What is the time scale difference between human button press and FPGA clock?
A) 1,000× (3 orders of magnitude)
B) 1,000,000× (6 orders of magnitude)
C) 10,000,000× (7 orders of magnitude)
D) 1,000,000,000× (9 orders of magnitude)

### Q40. Which clock is used in Lab2_top when integrated into Lab2_imp?
A) clk (100 MHz)
B) sClk (slow clock)
C) An external clock
D) No clock

---

## Section D: Testbench and Simulation (10 questions)

### Q41. In a testbench, inputs to the UUT (Unit Under Test) are declared as:
A) wire
B) reg
C) integer
D) parameter

### Q42. In a testbench, outputs from the UUT are declared as:
A) wire
B) reg
C) integer
D) parameter

### Q43. The timescale `1ns / 1ps` means:
A) Time unit = 1ns, precision = 1ps
B) Time unit = 1ps, precision = 1ns
C) Simulation runs at 1ns per second
D) Delays are in picoseconds

### Q44. To create a 100 MHz clock in simulation, the clock should toggle every:
A) 5 ns
B) 10 ns
C) 100 ns
D) 1 μs

### Q45. The expected output sequence in the testbench is:
A) 0, 15, A3, 87, 15, 87
B) 15, A3, 87, 15, 87, 0
C) 0, 0, 15, A3, 87, 15
D) 87, A3, 15, 0, 0, 0

### Q46. Why do we need to add reg_d and mem_d to the waveform?
A) It's required by Vivado
B) To see internal signals for debugging
C) To make the simulation faster
D) They are outputs

### Q47. When should you close the simulator window?
A) Immediately after simulation completes
B) After verifying the output
C) Never during the lab session (needed for assessment)
D) After Task 3

### Q48. The $finish() command:
A) Pauses the simulation
B) Stops the simulation
C) Restarts the simulation
D) Saves the waveform

### Q49. In the test sequence, when is Memory[1] written?
A) At time 40ns
B) At time 50ns (when write_en=1, address=0x01, reg_d=0x15)
C) At time 60ns
D) Never

### Q50. What value is in Memory[2] after the test sequence?
A) 0x15
B) 0xA3
C) 0x87
D) Undefined

---

## Section E: FPGA Implementation (10 questions)

### Q51. What is the purpose of the Lab2_imp.v wrapper?
A) To test the design
B) To add FPGA-specific modules (clock divider, 7-segment driver)
C) To replace Lab2_top
D) To generate the bitstream

### Q52. Which module displays data on the 7-segment display?
A) clkgen
B) seven_seg
C) Lab2_top
D) Lab2_mem

### Q53. The XDC file is used to:
A) Configure the memory
B) Map signals to physical FPGA pins
C) Set up the clock
D) Define module parameters

### Q54. LVCMOS33 means:
A) 33 MHz clock
B) 3.3V low-voltage CMOS logic standard
C) 33 logic cells
D) 33-pin package

### Q55. The three stages of FPGA build process are:
A) Compile, Link, Load
B) Synthesize, Implement, Generate Bitstream
C) Design, Simulate, Program
D) Edit, Build, Deploy

### Q56. What does synthesis do?
A) Converts Verilog to FPGA primitives (LUTs, FFs, etc.)
B) Places components on the chip
C) Generates the .bit file
D) Programs the FPGA

### Q57. What does implementation do?
A) Converts Verilog to primitives
B) Places primitives and routes wires between them
C) Generates the .bit file
D) Simulates the design

### Q58. The button btnU (top button) is connected to:
A) write_en
B) save_data
C) rst (reset)
D) show_reg

### Q59. The button btnR (right button) is connected to:
A) write_en
B) save_data
C) rst
D) show_reg

### Q60. The button btnL (left button) is connected to:
A) write_en
B) save_data
C) rst
D) show_reg

---

## Section F: Code Analysis (15 questions)

### Q61. What is WRONG with this code?
```verilog
Lab2_mem U1 (
    .a(d_in[5:0]),
    .d(d_in),        // <-- This line
    .clk(clk),
    .we(write_en),
    .spo(mem_d)
);
```
A) Nothing, it's correct
B) Should be .d(reg_d) to allow staging
C) Should be .d(mem_d)
D) Should be .d(d_out)

### Q62. What is WRONG with this code?
```verilog
Lab2_top U1 (
    .clk(clk),       // <-- This line (in Lab2_imp.v)
    .rst(rst),
    ...
);
```
A) Nothing, it's correct
B) Should use sClk (slow clock) for human interaction
C) Should use an external clock
D) Should not have a clock

### Q63. What does this code do?
```verilog
always @(posedge clk) begin
    if (rst)
        reg_d <= 8'b0;
    else if (save_data)
        reg_d <= d_in;
end
```
A) Asynchronous register with reset
B) Synchronous register with reset and enable
C) Combinational logic
D) Memory controller

### Q64. What is the output of this expression when show_reg=1?
```verilog
assign d_out = show_reg ? mem_d : reg_d;
```
A) reg_d
B) mem_d
C) d_in
D) 0

### Q65. What type of assignment is this?
```verilog
assign d_out = show_reg ? mem_d : reg_d;
```
A) Blocking assignment
B) Non-blocking assignment
C) Continuous assignment (ternary operator)
D) Procedural assignment

### Q66. In this instantiation, what does .a(d_in[5:0]) mean?
```verilog
Lab2_mem U1 (
    .a(d_in[5:0]),
    ...
);
```
A) Port 'a' connects to bits [5:0] of d_in
B) Port 'a' is 5 bits wide
C) d_in is shifted by 5
D) Only bit 5 is connected

### Q67. What is the issue with this testbench code?
```verilog
initial begin
    #10 d_in = 8'h15;
    #10 save_data = 1;
    #10 save_data = 0; d_in = 8'h01;
    #10 write_en = 1;
end
```
A) Nothing, it's correct
B) Missing clock initialization
C) Missing reset de-assertion
D) Both B and C

### Q68. How many bits is this signal?
```verilog
wire [7:0] mem_d;
```
A) 7 bits
B) 8 bits
C) 9 bits
D) 1 bit

### Q69. This XDC constraint does what?
```tcl
set_property PACKAGE_PIN V17 [get_ports {d_in[0]}]
```
A) Sets d_in[0] to pin V17
B) Maps physical pin V17 to signal d_in[0]
C) Creates a new port
D) Sets the voltage to 17V

### Q70. What synthesizes from this code?
```verilog
reg [27:0] counter;
always @(posedge clk_in)
    counter <= counter + 1;
```
A) A 28-bit adder
B) A 28-bit counter (28 flip-flops + increment logic)
C) A 28-bit register
D) A clock multiplier

### Q71. What is the difference between these two?
```verilog
// Version A
always @(posedge clk)
    if (rst) reg_d <= 0;

// Version B
always @(posedge clk or posedge rst)
    if (rst) reg_d <= 0;
```
A) No difference
B) A is synchronous reset, B is asynchronous reset
C) B is synchronous reset, A is asynchronous reset
D) Both are asynchronous

### Q72. What infers a flip-flop in Verilog?
A) always @(*)
B) always @(posedge clk)
C) assign statement
D) wire declaration

### Q73. What infers combinational logic in Verilog?
A) always @(*) or assign
B) always @(posedge clk)
C) reg declaration
D) Only assign statements

### Q74. In the seven_seg module, why are outputs active-low?
A) It's a Verilog requirement
B) The Basys 3 uses common-anode 7-segment displays
C) It's faster
D) To save power

### Q75. What does this generate?
```verilog
always #5 clk = ~clk;
```
A) A 5 Hz clock
B) A 10 Hz clock
C) A clock that toggles every 5 time units (10 time unit period)
D) A one-time pulse

---

## Section G: Conceptual Questions (10 questions)

### Q76. The main advantage of simulation before hardware testing is:
A) It's faster
B) Full visibility into all signals, repeatable tests, fast iteration
C) It's required by Vivado
D) Hardware doesn't work without it

### Q77. Time-multiplexing means:
A) Using multiple clocks
B) Sharing resources across time (same switches for data and address)
C) Running operations in parallel
D) Dividing the clock frequency

### Q78. The load-store architecture pattern means:
A) Data moves through registers before reaching memory
B) Memory has both load and store ports
C) Registers are faster than memory
D) All operations use memory

### Q79. What is the industry practice for simulation vs. hardware testing?
A) 50% simulation, 50% hardware
B) 20% simulation, 80% hardware
C) 80% simulation, 20% hardware
D) No simulation needed

### Q80. Synchronous operations are preferred for:
A) Fast responses
B) State changes (writes, register updates) to avoid glitches
C) Reading data
D) Combinational logic

### Q81. Asynchronous operations are preferred for:
A) Writing data
B) State changes
C) Reads/lookups when you need immediate response
D) Reset signals

### Q82. Why is modular design important (Lab2_top separate from Lab2_imp)?
A) Easier to test and debug
B) Core logic is portable and reusable
C) Separates board-specific code from design logic
D) All of the above

### Q83. What real-world system uses address/data bus multiplexing?
A) CPUs and DDR memory
B) USB cables
C) Power supplies
D) Keyboards

### Q84. The staging register pattern is used in:
A) CPU register files
B) Pipeline stages
C) FIFO buffers
D) All of the above

### Q85. Why don't we initialize the distributed RAM?
A) Distributed RAM typically doesn't support initialization
B) We want random data
C) Block RAM is better for initialization
D) Both A and C

---

## Section H: Common Mistakes & Debugging (10 questions)

### Q86. If the display always shows 0, the most likely cause is:
A) Wrong MUX connection
B) Still in reset (rst not released)
C) Wrong clock
D) Bad memory

### Q87. If button presses don't work on the FPGA, you should:
A) Press faster
B) Hold the button until LED[7] blinks
C) Reset the board
D) Regenerate the bitstream

### Q88. If d_out is always 'X' in simulation, check:
A) Clock initialization
B) RAM instantiation (spo connected to mem_d?)
C) Testbench syntax
D) FPGA programming

### Q89. If synthesis uses Block RAM instead of distributed RAM:
A) Change the data width
B) Regenerate IP with "Distributed Memory Generator"
C) Use a different FPGA
D) Modify the constraints

### Q90. Why must you keep the simulator open after Task 2?
A) To save memory
B) Lab supervisor needs to verify your Task 2 work during assessment
C) It keeps the license active
D) The FPGA won't work otherwise

### Q91. If switches don't control anything on hardware:
A) Check XDC pin mappings
B) Check if bitstream was loaded
C) Check if constraints were applied
D) All of the above

### Q92. If the testbench output is wrong, you should:
A) Reprogram the FPGA
B) View internal signals (reg_d, mem_d) in waveform to debug
C) Change the test sequence
D) Skip simulation

### Q93. The most common mistake in Lab2_top.v is:
A) Wrong clock frequency
B) Connecting RAM data input to d_in instead of reg_d
C) Missing the MUX
D) Wrong timescale

### Q94. The most common mistake in Lab2_imp.v is:
A) Wrong instance name
B) Using 100MHz clock instead of sClk
C) Missing modules
D) Wrong port order

### Q95. If memory writes don't persist:
A) Check that write_en is pulsed during a clock edge
B) Check that reg_d has the correct data
C) Check show_reg isn't stuck at 0 when trying to view memory
D) All of the above

---

## Section I: Synthesis Reports (5 questions)

### Q96. After synthesis of Lab2_top, you should see:
A) Only combinational logic
B) 8 LUT-RAMs, 8 flip-flops, and ~8 LUTs for the MUX
C) Block RAM
D) No resources used

### Q97. The 8 flip-flops inferred are for:
A) The memory
B) The register (reg_d)
C) The clock divider
D) The MUX

### Q98. The LUT-RAMs (RAMD64E) are:
A) The distributed memory
B) The register
C) The MUX
D) The clock divider

### Q99. What should the implementation stage have?
A) Many warnings
B) Zero warnings (if done correctly)
C) Errors are acceptable
D) Critical warnings only

### Q100. Where is the distributed memory physically located?
A) In dedicated Block RAM
B) Inside LUTs (same resources used for logic)
C) In external DRAM
D) In a separate memory chip

---

# ANSWERS

## Section A: Memory Architecture
1. B - Distributed RAM (LUT-based)
2. B - The memory size (512 bits) is too small to efficiently use BRAM
3. B - 8 LUTs (one per data bit)
4. B - It matches perfectly with a 6-input LUT architecture (2^6 = 64)
5. B - One bit across all 64 addresses
6. B - 2^6 = 64, matching the memory depth
7. C - They are ignored (only d_in[5:0] is used for address)
8. B - Reads are asynchronous (combinational, immediate)
9. C - Writes are synchronous (occur on clock edge when write_en=1)
10. C - Yes, but it's typically not done; Block RAM is better for initialization
11. B - To allow asynchronous reads and keep the design simple
12. B - It would require 2 LUTs per bit plus multiplexers, doubling resources
13. B - Single Port Output
14. B - Block RAM
15. B - 512 bits (64 × 8)

## Section B: Design Architecture
16. B - To act as a staging area for data before writing to memory
17. B - To allow time-multiplexing: save data to register, then change switches to address
18. C - Set data and press save_data, then set address and press write_en
19. B - Selects between displaying register contents or memory contents
20. B - The memory contents (mem_d)
21. A - The register contents (reg_d)
22. C - Both A and B
23. B - Load-store architecture / staging area
24. C - Two (reg_d and mem_d)
25. B - It's assigned inside an 'always' block
26. A - It's driven by the RAM IP output
27. B - Synchronous (occurs on clock edge)
28. B - Clears reg_d to 0
29. B - Time-division multiplexing
30. D - Both B and C

## Section C: Clock Management
31. C - 100 MHz
32. B - A button press (~100ms) would span 10 million clock cycles
33. C - 2^28
34. A - ~0.37 Hz
35. C - ~2.68 seconds
36. B - Using a 28-bit counter; output is the MSB which toggles every 2^27 cycles
37. B - To provide visual feedback of when clock edges occur
38. B - Hold until LED[7] blinks, then release
39. C - 10,000,000× (7 orders of magnitude)
40. B - sClk (slow clock)

## Section D: Testbench and Simulation
41. B - reg
42. A - wire
43. A - Time unit = 1ns, precision = 1ps
44. A - 5 ns (toggle every 5ns = 10ns period = 100MHz)
45. A - 0, 15, A3, 87, 15, 87
46. B - To see internal signals for debugging
47. C - Never during the lab session (needed for assessment)
48. B - Stops the simulation
49. B - At time 50ns (when write_en=1, address=0x01, reg_d=0x15)
50. B - 0xA3

## Section E: FPGA Implementation
51. B - To add FPGA-specific modules (clock divider, 7-segment driver)
52. B - seven_seg
53. B - Map signals to physical FPGA pins
54. B - 3.3V low-voltage CMOS logic standard
55. B - Synthesize, Implement, Generate Bitstream
56. A - Converts Verilog to FPGA primitives (LUTs, FFs, etc.)
57. B - Places primitives and routes wires between them
58. C - rst (reset)
59. B - save_data
60. D - show_reg

## Section F: Code Analysis
61. B - Should be .d(reg_d) to allow staging
62. B - Should use sClk (slow clock) for human interaction
63. B - Synchronous register with reset and enable
64. B - mem_d
65. C - Continuous assignment (ternary operator)
66. A - Port 'a' connects to bits [5:0] of d_in
67. D - Both B and C (missing clock init and reset de-assertion)
68. B - 8 bits ([7:0] means bits 7 down to 0 = 8 bits)
69. B - Maps physical pin V17 to signal d_in[0]
70. B - A 28-bit counter (28 flip-flops + increment logic)
71. B - A is synchronous reset, B is asynchronous reset
72. B - always @(posedge clk)
73. A - always @(*) or assign
74. B - The Basys 3 uses common-anode 7-segment displays
75. C - A clock that toggles every 5 time units (10 time unit period)

## Section G: Conceptual Questions
76. B - Full visibility into all signals, repeatable tests, fast iteration
77. B - Sharing resources across time (same switches for data and address)
78. A - Data moves through registers before reaching memory
79. C - 80% simulation, 20% hardware
80. B - State changes (writes, register updates) to avoid glitches
81. C - Reads/lookups when you need immediate response
82. D - All of the above
83. A - CPUs and DDR memory
84. D - All of the above
85. D - Both A and C

## Section H: Common Mistakes & Debugging
86. B - Still in reset (rst not released)
87. B - Hold the button until LED[7] blinks
88. B - RAM instantiation (spo connected to mem_d?)
89. B - Regenerate IP with "Distributed Memory Generator"
90. B - Lab supervisor needs to verify your Task 2 work during assessment
91. D - All of the above
92. B - View internal signals (reg_d, mem_d) in waveform to debug
93. B - Connecting RAM data input to d_in instead of reg_d
94. B - Using 100MHz clock instead of sClk
95. D - All of the above

## Section I: Synthesis Reports
96. B - 8 LUT-RAMs, 8 flip-flops, and ~8 LUTs for the MUX
97. B - The register (reg_d)
98. A - The distributed memory
99. B - Zero warnings (if done correctly)
100. B - Inside LUTs (same resources used for logic)

---

# SCORING GUIDE

- 90-100: Excellent mastery - Ready for quiz!
- 80-89: Good understanding - Review weak areas
- 70-79: Needs more study - Focus on sections you missed
- Below 70: Significant gaps - Re-read README thoroughly

# STUDY TIPS

1. **Memory concepts** (Q1-15): Understand WHY distributed RAM is chosen, not just that it is
2. **Design patterns** (Q16-30): The staging register is THE KEY concept
3. **Clock management** (Q31-40): Know the math: 100MHz → 2^28 division → ~0.37Hz
4. **Code analysis** (Q61-75): Practice reading code snippets
5. **Common mistakes** (Q86-95): These are high-yield for quizzes!

Focus on **conceptual understanding** over memorization!
