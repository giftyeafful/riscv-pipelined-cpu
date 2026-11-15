# 5-Stage Pipelined RISC-V CPU

A 32-bit RISC-V processor designed in SystemVerilog, functionally verified through simulation, and implemented for an AMD Artix-7 FPGA using Vivado 2026.1.

Project Overview

This project implements a five-stage pipelined RISC-V CPU, demonstrating key concepts in computer architecture, digital logic design, and hardware verification.

The processor uses pipelining to overlap instruction execution across five stages. It incorporates data forwarding and hazard detection to manage instruction dependencies and control-flow changes.

The project was developed using SystemVerilog and evaluated through functional simulation, FPGA synthesis, placement and routing, and timing analysis.

Processor Architecture

The CPU implements the following five pipeline stages:

| Stage | Name | Function |
|---|---|---|
| IF | Instruction Fetch | Fetches instructions from instruction memory |
| ID | Instruction Decode | Decodes instructions and reads registers |
| EX | Execute | Performs ALU operations and evaluates branches |
| MEM | Memory Access | Handles data memory reads and writes |
| WB | Write Back | Writes results to the register file |

Main Hardware Components

- Program Counter
- Instruction Memory
- Control Unit
- Register File
- Immediate Generator
- ALU and ALU Control
- Data Memory
- Pipeline Registers (IF/ID, ID/EX, EX/MEM, MEM/WB)
- Forwarding Unit
- Hazard Detection Unit

Pipeline Hazard Handling

The design includes:

- Data forwarding to reduce stalls caused by register dependencies.
- Load-use hazard detection and pipeline stalling.
- Branch and jump handling to manage control hazards.

Tools and Technologies

| Tool | Purpose |
|---|---|
| SystemVerilog | RTL design and testbenches |
| AMD Vivado 2026.1 | Simulation, synthesis, and FPGA implementation |
| Verilator | RTL simulation and testing |
| Artix-7 XC7A35T | Target FPGA device |

Functional Verification

The processor was tested using SystemVerilog testbenches.

The integration test successfully verified the following instruction behaviors:

| Test | Result |
|---|---|
| ADDI | PASS |
| ADD | PASS |
| Store Word (SW) | PASS |
| Load Word (LW) | PASS |
| JAL link behavior | PASS |
| JALR link behavior | PASS |
| Branch/jump path | PASS |
| Final register update | PASS |

**Integration test result:**

```text
PIPELINED CPU INTEGRATION PASSED!
```

Additional tests were performed for forwarding, load-use hazards, branch/jump handling, and pipeline performance.

These tests validate the implemented scenarios rather than the complete RISC-V instruction set.

FPGA Synthesis and Implementation

The design was synthesized and implemented using AMD Vivado 2026.1 for the Artix-7 XC7A35T FPGA.

Post-Implementation Resource Utilization

| FPGA Resource | Used | Available | Utilization |
|---|---:|---:|---:|
| Slice LUTs | 663 | 20,800 | 3.19% |
| Slice Registers | 431 | 41,600 | 1.04% |
| Occupied Slices | 219 | 8,150 | 2.69% |
| Bonded I/O | 75 | 106 | 70.75% |
| BUFGCTRL | 1 | 32 | 3.13% |

Of the 663 implemented LUTs, 491 are used for logic and 172 for memory.

Timing Analysis

A 10 ns clock period was specified, corresponding to a 100 MHz target clock frequency.

| Timing Metric | Result |
|---|---:|
| Clock Target | 100 MHz |
| Worst Negative Slack (WNS) | +1.095 ns |
| Total Negative Slack (TNS) | 0.000 ns |
| Worst Hold Slack (WHS) | +0.096 ns |
| Failing Timing Endpoints | 0 |

Result: The implemented design met its specified clock timing constraints.

Project Documentation

The complete technical report, including Vivado screenshots, verification results, resource utilization, and timing analysis, is available here:

[View RISC-V CPU Project Report](reports/RISC_V_Pipelined_CPU_Project_Report.pdf)

Limitations

- The processor was verified through simulation and FPGA implementation tools, but was not deployed to a physical FPGA board.
- Physical pin assignments, I/O standards, and configuration voltage settings have not been finalized.
- Functional verification covers the implemented test scenarios, not the entire RISC-V ISA.
- Additional verification and hardware testing would be required before physical deployment.

Future Improvements

- Integrate an instruction or data cache controller.
- Expand instruction coverage and automated verification.
- Add more comprehensive pipeline performance benchmarks.
- Implement a UART-based debugging interface.
- Deploy and test the processor on a physical FPGA development board.

Author

Gifty Esi Afful

M.S. Computer Engineering  
The City College of New York (CCNY)
[GitHub](https://github.com/giftyeafful)
