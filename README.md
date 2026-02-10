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
- **Lab2/**: FPGA Lab with Memory Primitives
- **Quiz App**: Interactive practice tool with 100 questions (see below)
- Other directories for assignments and projects

## 🎯 Lab 2 Quiz Application

An interactive quiz app with **100 practice questions** for Lab 2: Memory Primitives & FPGA Implementation.

### ✨ Features

- ✅ **100 comprehensive questions** across 9 topics
- ✅ **Two study modes**: Full Practice (100Q) or Targeted Practice (by section)
- ✅ **Google Sign-In** for leaderboard
- ✅ **Keyboard shortcuts** (1-4 for answers, Enter for next)
- ✅ **Profile photos** on leaderboard from your Google account
- 🔒 **Secure**: API keys in `.gitignore`, won't be committed

### 🚀 Quick Start

**1. Just Practice (No Setup)**
```bash
Open: index.html
```
Quiz works immediately! Leaderboard requires Google Sign-In.

**2. Enable Leaderboard (5-7 min)**
```bash
# Step 1: Set up Firebase
# Follow: FIREBASE_SETUP.md (enable Google Sign-In)

# Step 2: Copy config template
Copy-Item firebase-config.template.js firebase-config.js

# Step 3: Add your Firebase credentials to firebase-config.js

# Step 4: Open index.html and sign in with Google!
```

### 📚 Question Breakdown

| Section | Questions | Topics |
|---------|:---------:|--------|
| **A** | 15 | Memory Architecture (Distributed RAM, LUTs) |
| **B** | 15 | Design Architecture (reg_d, MUX, time-mux) |
| **C** | 10 | Clock Management (divider, timing) |
| **D** | 10 | Testbench & Simulation |
| **E** | 10 | FPGA Implementation (synthesis, XDC) |
| **F** | 15 | Code Analysis (Verilog snippets) |
| **G** | 10 | Conceptual Questions |
| **H** | 10 | Common Mistakes & Debugging |
| **I** | 5  | Synthesis Reports |
| **Total** | **100** | Complete Lab 2 coverage |

### 🎮 How to Use

1. **Sign In** (top right) - Click "Sign in with Google"
2. **Choose Mode** - Full Practice or pick a section
3. **Answer Questions** - Click options or press 1-4 keys
4. **Submit Score** - Save to leaderboard with your Google account
5. **Track Progress** - See your rank and profile photo!

### 🔐 Security & Privacy

- ✅ Google Sign-In required for leaderboard
- ✅ Only stores: Display name, email, photo URL, scores
- ✅ API credentials in `firebase-config.js` (in `.gitignore`)
- ✅ Safe to push to GitHub - credentials stay private!

### 📖 Documentation

- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Complete setup guide with Google Sign-In
- **This README** - Quick reference for the quiz

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
