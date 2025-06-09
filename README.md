# ALU Design in Verilog – Sharath Kumar U K 

## 📘 Project Overview

This project implements a configurable and efficient **Arithmetic Logic Unit (ALU)** using **Verilog HDL**, capable of performing a broad range of arithmetic and logical operations. 
It is designed with both **combinational** and **sequential logic** to support single- and multi-cycle operations such as multiplication with pipeline behavior.

---

## 🎯 Objectives

- Design a modular and parameterized ALU in Verilog.
- Support arithmetic (ADD, SUB, INC, DEC, CMP) and logical (AND, OR, XOR, NOT, SHIFTS) operations.
- Handle **signed/unsigned** computations and generate status flags (carry, overflow, comparison).
- Include multi-cycle operation support with internal pipelining.
- Validate design through an automated **testbench** using **stimulus and response packet files**.
- Analyze functional correctness and corner cases via waveform and test results.

---

## 🧱 Architecture

The ALU is controlled via:
- **MODE**: Selects arithmetic (`1`) or logical (`0`) operations.
- **CMD**: 4-bit operation code.
- **INP_VALID**: Indicates if operands are valid (00 = invalid, 01/10 = unary, 11 = binary ops).

### ✅ Supported Output Signals:
- `RES`: Operation result.
- `COUT`: Carry-out (unsigned overflow).
- `OFLOW`: Signed overflow.
- `G`, `L`, `E`: Comparison flags.
- `ERR`: Error signal for invalid conditions.

### ⏱ Timing:
- Most operations are combinational (single-cycle).
- Some commands like multiplication are **multi-cycle**, using internal registers to simulate pipelined behavior.

---

## 🧪 Testbench Structure

The testbench consists of:
- `stimulus.txt`: Input packet file (57 bits).
- `result.txt`: Output comparison file (80 bits).
- `Scoreboard`, `Monitor`, `Result Generator`: For automated pass/fail checks.

Each test packet includes:
- Inputs: operands, CMD, MODE, INP_VALID.
- Expected: output result, flags.
- Actual outputs are compared to expected using the scoreboard.

---

## 📊 Results

- Correct execution of all arithmetic and logical operations.
- Pipelined behavior confirmed through waveform analysis.
- Flags and error handling validated for all cases.
- Fully synthesizable and tested in a Verilog simulation environment.

---

## 🚀 Future Improvements

- Add signed multiplication, division, modulo, and floating-point ops.
- Introduce deeper pipelining for high-frequency designs.
- Improve exception and error handling.
- Expand instruction set (bit count, conditional ops, etc.).
- Integrate with complete CPU pipelines.

---

## 📂 File Structure
.
# --> Design Code Folder

 1.ALU_design file (.v)
 2.Define file

# --> Design Document Folder

 1.ALU Design Document PDF
 2.Testcases file (Stimulus)

# --> Test Bench Floder

 1.Normal Test Bench file (.v)
 2.Test Bench with driver/monitor (.v)
 3.Stimulus file (.txt)

# -->README.md 

  This file


