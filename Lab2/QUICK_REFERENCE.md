# Lab 2 Quick Reference - Last Minute Study Guide

**Print this out or keep it open for quick review before your quiz!**

---

## 🎯 TOP 10 MOST IMPORTANT CONCEPTS

### 1. **Why Distributed RAM?**
- Size: 64×8 = **512 bits** - too small for BRAM (18Kb blocks)
- **1 LUT per data bit** = 8 LUTs total
- **Depth 64** = perfect for 6-input LUT (2^6 = 64)

### 2. **The Staging Register Pattern** ⭐⭐⭐
```
Problem: 8 switches, need BOTH data AND address
Solution: TWO-STEP PROCESS
  Step 1: Set switches to DATA → press save_data → reg_d holds it
  Step 2: Set switches to ADDRESS → press write_en → memory[address] = reg_d
```
**Q: Why connect RAM's .d to reg_d NOT d_in?**
**A: Time-multiplexing! Can't show data and address simultaneously!**

### 3. **Clock Management** ⭐⭐⭐
- System clock: **100 MHz** (10ns period)
- Button press: **~100ms** = **10 MILLION clock cycles!**
- Solution: Divide by **2^28** → **~0.37 Hz** (~2.68s period)
- **LED[7] shows sClk** - blink = clock edge happened
- **MUST use sClk in Lab2_imp**, NOT 100MHz clk!

### 4. **Memory Operations**
- **Reads: ASYNCHRONOUS** (immediate, no clock)
- **Writes: SYNCHRONOUS** (needs clock edge + write_en=1)
- Address: **d_in[5:0]** only (upper 2 bits ignored)

### 5. **The Multiplexer**
```verilog
assign d_out = show_reg ? mem_d : reg_d;
```
- show_reg = **1** → display **MEMORY** (mem_d)
- show_reg = **0** → display **REGISTER** (reg_d)
- Confusing name: "show_reg=1" shows MEMORY!

### 6. **Test Sequence Output**
**Expected: 0, 15, A3, 87, 15, 87**
- Output 1 (0): Reset cleared register
- Output 2 (15): Saved 0x15 to register
- Output 3 (A3): Saved 0xA3 to register
- Output 4 (87): Saved 0x87 to register
- Output 5 (15): show_reg=1, viewing Memory[1]
- Output 6 (87): show_reg=0, back to register

### 7. **Verilog Data Types**
- **reg_d** = `reg` because assigned in `always` block
- **mem_d** = `wire` because driven by IP output
- `reg` type ≠ physical register (just allows procedural assignment)

### 8. **Testbench Rules**
- UUT **inputs** = `reg` (testbench drives them)
- UUT **outputs** = `wire` (testbench observes them)
- Clock: `always #5 clk = ~clk` → 10ns period = 100MHz
- **DON'T CLOSE SIMULATOR** - needed for assessment!

### 9. **Synchronous vs. Asynchronous Reset**
```verilog
// SYNCHRONOUS (this lab)
always @(posedge clk) begin
    if (rst) ...

// ASYNCHRONOUS (NOT used)
always @(posedge clk or posedge rst) begin
    if (rst) ...
```

### 10. **FPGA Build Process**
1. **Synthesize**: Verilog → FPGA primitives (LUTs, FFs)
2. **Implement**: Place & route primitives on chip
3. **Generate Bitstream**: Create .bit file to program FPGA

---

## 📊 KEY NUMBERS TO MEMORIZE

| Item | Value | Why |
|------|-------|-----|
| Memory depth | 64 | 2^6 = LUT size |
| Memory width | 8 bits | 1 byte, matches switches |
| Total memory | 512 bits | 64 × 8 |
| LUTs used | 8 | 1 per data bit |
| Address bits | 6 | [5:0] of d_in |
| Clock freq | 100 MHz | Basys 3 oscillator |
| Clock period | 10 ns | 1/100MHz |
| Division factor | 2^28 | Clock divider |
| Slow clock freq | ~0.37 Hz | 100MHz/2^28 |
| Slow clock period | ~2.68 s | 1/0.37Hz |
| Time difference | 7 orders | 10,000,000× |
| Counter width | 28 bits | For 2^28 division |
| Flip-flops | 8 | For reg_d |

---

## 🔧 CODE SNIPPETS - KNOW THESE!

### Register with Enable
```verilog
always @(posedge clk) begin
    if (rst)
        reg_d <= 8'b0;           // Synchronous reset
    else if (save_data)
        reg_d <= d_in;           // Capture when enabled
end
```

### RAM Instantiation (CORRECT)
```verilog
Lab2_mem U1 (
    .a(d_in[5:0]),      // Address: lower 6 bits
    .d(reg_d),          // ⭐ Data from REGISTER (not d_in)
    .clk(clk),
    .we(write_en),
    .spo(mem_d)         // Output to mem_d wire
);
```

### MUX (Ternary Operator)
```verilog
assign d_out = show_reg ? mem_d : reg_d;
//             condition ? true  : false
```

### Clock Divider
```verilog
reg [27:0] counter;
always @(posedge clk_in)
    counter <= counter + 1;
assign clk_out = counter[27];   // MSB toggles every 2^27
```

### Lab2_imp Instantiation (CORRECT)
```verilog
Lab2_top U1 (
    .clk(sClk),         // ⭐ Slow clock (not clk!)
    .rst(rst),
    .d_out(tmp_data)
    ...
);
```

---

## 🚨 COMMON MISTAKES (High Quiz Probability!)

| ❌ Wrong | ✅ Correct | Why |
|---------|-----------|-----|

| show_reg=1 shows register | show_reg=1 shows **memory** | Naming is backwards |
| Pressing buttons quickly | Hold until LED[7] blinks | Need to catch clock edge |
| Close simulator after Task 2 | Keep it open | Needed for assessment |
| Testbench inputs as `wire` | Testbench inputs as `reg` | Must drive them |
| Blocking `=` in always@(posedge) | Non-blocking `<=` | Sequential logic |

---

## 🎓 XDC FILE ESSENTIALS

```tcl
## Map signal d_in[0] to physical pin V17
set_property PACKAGE_PIN V17 [get_ports {d_in[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {d_in[0]}]
```

- **LVCMOS33** = **3.3V** low-voltage CMOS
- Basys 3 uses **3.3V I/O** standard
- Each switch/button needs **PACKAGE_PIN** + **IOSTANDARD**

### Button Mapping
- **btnU (T18)** → rst (reset - top)
- **btnL (W19)** → show_reg (left)
- **btnC (U18)** → write_en (center)
- **btnR (T17)** → save_data (right)
- **btnD (U17)** → sel (bench number - bottom)

---

## 🧠 CONCEPTUAL QUICKFIRE

**Q: Distributed RAM vs. Block RAM?**
A: Distributed = small/flexible/LUT-based; Block = large/dedicated/fixed blocks

**Q: Why single port RAM?**
A: Only need read OR write at once, simplest, asynchronous read

**Q: Why unregistered I/O?**
A: Asynchronous (instant) read, no extra latency

**Q: What is time-multiplexing?**
A: Sharing resources across time (same switches for data, then address)

**Q: Why can't we reset the memory?**
A: Distributed RAM doesn't have built-in reset; we reset reg_d instead

**Q: Industry simulation practice?**
A: 80% simulation, 20% hardware testing

**Q: What pattern does reg_d represent?**
A: Load-store architecture / staging register

**Q: What happens at 7 orders of magnitude difference?**
A: Human time (100ms) vs. FPGA time (10ns) = button press problem

---

## 📝 ASSESSMENT CHECKLIST

### Task 2 Requirements
✅ Simulation window open with full waveform
✅ `reg_d` and `mem_d` visible
✅ Output: 0, 15, A3, 87, 15, 87
✅ Can explain each step timing

### Task 3 Requirements
✅ Store and retrieve values at different addresses
✅ Demonstrate MUX (toggle show_reg)
✅ Show bench number (press btnD/sel)

### Conceptual Understanding
✅ Why slow clock needed
✅ Why reg_d staging area needed
✅ Two-step write process
✅ Distributed vs. Block RAM
✅ Why depth=64, width=8

---

## 🎯 SYNTHESIS EXPECTATIONS

After synthesis of Lab2_top, expect:
- **8 LUT-RAMs** (RAMD64E) - the distributed memory
- **8 Flip-Flops** - the register (reg_d)
- **~8 LUTs** - the MUX logic
- **NO Block RAM** - should be distributed!

Implementation stage: **ZERO warnings** (if done correctly)

---

## 💡 LAST MINUTE TIPS

1. **The register is KEY** - understand why `.d(reg_d)` not `.d(d_in)`
2. **Clock management matters** - 100MHz vs. sClk usage
3. **Know the numbers** - 2^6=64, 2^28 division, 100MHz, etc.
4. **Read code snippets carefully** - spot the mistakes
5. **Understand concepts, don't just memorize** - quizzes test WHY
6. **Common mistakes are high-yield** - review them!
7. **Test sequence** - know what happens at each step
8. **Timescale and data types** - reg vs. wire, blocking vs. non-blocking

---

## 🔥 IF YOU ONLY HAVE 5 MINUTES

Read these in order:
1. **Why reg_d?** Time-multiplexing for data/address
2. **Why sClk?** 100ms button press = 10M clock cycles
3. **show_reg logic** (1=memory, 0=register)
4. **Test sequence outputs** (0, 15, A3, 87, 15, 87)
5. **Common mistakes** section above

---

## 📚 MEMORY AIDS

**"Register Stages Data"** - The register is a staging area
**"MUX Selects View"** - MUX lets you view register or memory
**"Writes are Synchronous, Reads are Async"** - Memory operation types
**"2-6-8-28"** - 2^6=64 depth, 8 bits wide, 2^28 clock division
**"Slow Shows Sampled"** - Slow clock shows when button was sampled

---

**Good luck on your quiz! Focus on understanding WHY, not just WHAT!** 🎓

Remember: The lablab tests **conceptual understanding**, not just memorization!
