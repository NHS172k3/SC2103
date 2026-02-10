# Lab 2 Speed Quiz - 20 Critical Questions (15 minutes)

**Instructions:** Answer these 20 high-yield questions. These represent the most commonly tested concepts. If you can ace this, you're well-prepared!

---

## ⚡ THE CRITICAL 20

### 1. Why does the RAM's data input (`.d`) connect to `reg_d` instead of `d_in`?

**Answer:** To enable time-multiplexing. With only 8 switches, we need to provide BOTH data and address at different times. The register acts as a staging area - first we save data to `reg_d`, then we change the switches to show the address and write `reg_d` to memory.

---

### 2. What would happen if we used the 100 MHz clock directly in `Lab2_imp` instead of `sClk`?

**Answer:** A button press (~100ms) would span 10 million clock cycles at 100MHz, causing millions of unintended write operations and completely unpredictable behavior.

---

### 3. What is WRONG with this code?
```verilog
Lab2_mem U1 (
    .a(d_in[5:0]),
    .d(d_in),        // <-- Issue here
    .clk(clk),
    .we(write_en),
    .spo(mem_d)
);
```

**Answer:** Should be `.d(reg_d)` instead of `.d(d_in)`. The data input must come from the register to allow the two-step write process (stage data, then write to address).

---

### 4. When `show_reg = 1`, what does `d_out` display?

**Answer:** Memory contents (`mem_d`). The naming is confusing - when `show_reg` is HIGH, it shows MEMORY, not register.

---

### 5. Why is the memory depth set to 64 and not some other number?

**Answer:** 64 = 2^6, which perfectly matches the 6-input LUT architecture of the Artix-7 FPGA. Each LUT can store 64x1 bits. Using depth 64 requires exactly 1 LUT per data bit with zero waste.

---

### 6. How many LUTs are needed to implement a 64x8 distributed RAM?

**Answer:** 8 LUTs - one LUT per data bit. Each LUT stores one bit across all 64 addresses.

---

### 7. Explain the complete two-step process to write 0x42 to memory address 0x05.

**Answer:**
Step 1: Set switches to `0x42`, press and hold `save_data` until LED[7] blinks → `reg_d` now holds `0x42`
Step 2: Set switches to `0x05`, press and hold `write_en` until LED[7] blinks → `Memory[0x05] = 0x42`

---

### 8. What is the expected output sequence in the testbench?

**Answer:** 0, 15, A3, 87, 15, 87
- 0: Reset
- 15: Saved to register
- A3: Saved to register
- 87: Saved to register
- 15: Viewing Memory[1]
- 87: Back to viewing register

---

### 9. Why is memory READ asynchronous but WRITE synchronous?

**Answer:**
- **Read is asynchronous** (combinational) - data appears immediately when address changes, no clock needed
- **Write is synchronous** - requires clock edge with `write_en=1` to ensure clean, glitch-free writes

---

### 10. What does the clock divider module do?

**Answer:** Divides the 100 MHz clock by 2^28 (268,435,456) to create a ~0.37 Hz (~2.68 second period) slow clock that allows human button presses to be captured as single clock edges.

---

### 11. Why is LED[7] connected to the slow clock?

**Answer:** To provide visual feedback. When LED[7] changes state (blinks), you know a clock edge just occurred and your button press was sampled.

---

### 12. Why is `reg_d` declared as `reg` type?

**Answer:** Because it's assigned inside an `always` block. In Verilog, anything assigned in procedural blocks (`always`, `initial`) must be `reg` type. This doesn't necessarily mean it's a physical register - it's a language requirement.

---

### 13. What is WRONG with this instantiation in `Lab2_imp.v`?
```verilog
Lab2_top U1 (
    .clk(clk),       // <-- Issue here
    .rst(rst),
    ...
);
```

**Answer:** Should be `.clk(sClk)` not `.clk(clk)`. Must use the slow clock for human interaction, not the 100MHz system clock.

---

### 14. In a testbench, should the UUT's inputs be declared as `reg` or `wire`?

**Answer:** `reg` - because the testbench drives (assigns values to) these signals in `initial` or `always` blocks.

---

### 15. What does this code do?
```verilog
always @(posedge clk) begin
    if (rst)
        reg_d <= 8'b0;
    else if (save_data)
        reg_d <= d_in;
end
```

**Answer:** Creates a synchronous register with:
- Synchronous reset (clears to 0 on clock edge when `rst=1`)
- Enable signal (captures `d_in` on clock edge when `save_data=1`)
- Holds value otherwise

---

### 16. Why is distributed RAM preferred over Block RAM for this lab?

**Answer:** The memory size is only 512 bits (64×8). Block RAM blocks are 18Kb or larger - using BRAM for 512 bits would waste 97% of the block. Distributed RAM is efficient for small memories.

---

### 17. What does the XDC file do?

**Answer:** Maps abstract signal names in your Verilog design to physical pins on the FPGA chip. It also sets I/O standards (LVCMOS33 = 3.3V).

---

### 18. After synthesis of `Lab2_top`, what resources should be used?

**Answer:**
- 8 LUT-RAMs (RAMD64E) for the distributed memory
- 8 flip-flops for `reg_d`
- ~8 LUTs for the MUX logic
- NO Block RAM (should be distributed!)

---

### 19. Why can't you press and immediately release buttons on the FPGA hardware?

**Answer:** The slow clock has a ~2.68 second period. If you press and release quickly, the button might not be pressed during a rising clock edge, so the operation won't be captured. You must hold until LED[7] blinks.

---

### 20. What is the purpose of the `Lab2_imp` wrapper module?

**Answer:** To separate core logic (`Lab2_top`) from FPGA-specific support modules:
- `clkgen`: Clock divider for human interaction
- `seven_seg`: 7-segment display driver for output

This makes `Lab2_top` portable, testable independently, and reusable.

---

## 🎯 SCORING

- **18-20 correct:** Excellent! You're ready!
- **15-17 correct:** Good! Review missed questions
- **12-14 correct:** Needs work - review key concepts
- **Below 12:** Significant gaps - study the README thoroughly

---

## 🔥 KEY TAKEAWAYS

If you understand these concepts, you'll do well:

1. **The staging register pattern** - WHY we use `reg_d`
2. **Clock management** - WHY we need the slow clock
3. **Memory architecture** - Distributed vs. Block RAM
4. **The two-step write process** - How time-multiplexing works
5. **Synchronous vs. asynchronous operations** - Writes vs. reads
6. **Code correctness** - Common mistakes to avoid

---

## 📌 BEFORE YOUR QUIZ

Review these specific items:
1. Why `.d(reg_d)` not `.d(d_in)` in RAM instantiation
2. Why `.clk(sClk)` not `.clk(clk)` in Lab2_imp
3. The math: 2^6=64, 2^28 division, 100MHz → 0.37Hz
4. Test sequence outputs: 0, 15, A3, 87, 15, 87
5. `reg` vs `wire` in testbenches
6. Synchronous reset (inside `always @(posedge clk)`)
7. show_reg=1 shows memory, not register!

**Remember:** Quizzes test UNDERSTANDING, not just memorization. Focus on WHY!

Good luck! 🎓
