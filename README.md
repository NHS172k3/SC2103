# SC2103: Digital Systems Design

This repository contains coursework, tutorials, and projects for the SC2103 module at Nanyang Technological University (NTU), taken in Year 2 Semester 2, 2026.

## Course Overview

SC2103 introduces students to the fundamental concepts of computer systems, includin digital logic design, and basic hardware description languages like Verilog.

### Prerequisites

- SC1003: Introduction to Computing or equivalent programming knowledge
- Basic understanding of digital logic and circuits

### Learning Objectives

By the end of this module, students should be able to:

- Understand the basic components and architecture of a computer system
- Write and debug assembly language programs
- Design and simulate digital circuits using Verilog
- Analyze the performance and trade-offs in computer system design
- Apply concepts of computer organization to real-world problems

### Module Structure

The repository is organized by tutorials and assignments:

- **tut1/**: Introduction to tools and basic concepts
- **tut2/**: Digital design with Verilog (e.g., adder implementations)
- **tut3/**: Advanced topics (to be added)
- Other directories for assignments and projects

## Tools and Setup

### Required Software

- **Icarus Verilog (iverilog)**: For compiling and simulating Verilog code
- **GTKWave**: For viewing simulation waveforms
- **Text Editor**: VS Code or any editor with Verilog support

### Installation

1. Download and install Icarus Verilog from [http://iverilog.icarus.com/](http://iverilog.icarus.com/)
2. Download and install GTKWave from [http://gtkwave.sourceforge.net/](http://gtkwave.sourceforge.net/) OR automatically install gtkwave during installation of Icarus Verilog

### Running Simulations

For Verilog files (e.g., in `tut2/`):

1. Compile the design and testbench:

   ```
   iverilog -o output_file testbench.v design.v
   ```

2. Run the simulation:

   ```
   vvp output_file
   ```

3. View waveforms (if `$dumpfile` is used in the testbench):
   ```
   gtkwave output_file.vcd
   ```

## Assignments and Grading

- Tutorials: Weekly exercises to reinforce concepts
- Assignments: Larger projects applying module knowledge
- Final Project: Comprehensive system design

## Resources

- NTU SC2103 Course Website
- Textbook: "Computer Organization and Design" by Patterson and Hennessy
- Online References: Verilog tutorials, Assembly language guides

## Contact

For questions related to the coursework, consult the module lecturer or TAs.

---

_Note: This README is based on the standard SC2103 module structure. Specific details may vary by semester._
