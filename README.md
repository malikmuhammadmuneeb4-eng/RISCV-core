# RISCV-core

A single-cycle RV32I RISC-V processor, built up module by module in SystemVerilog — each piece designed and verified from scratch as part of self-directed digital design/verification practice.

This repo tracks the build incrementally: every module ships with its own RTL, a self-checking testbench, and a short README explaining the design and the bugs caught along the way. The companion repo, [Verilog-portfolio](https://github.com/malikmuhammadmuneeb4-eng/Verilog-portfolio), has the foundational practice work (combinational/sequential circuits, verification methodology drills) that led into this build.

## Roadmap

| # | Module | Status |
|---|--------|--------|
| 1 | ALU | Done |
| 2 | Register File | Done |
| 3 | Instruction Decoder | Not started |
| 4 | Single-Cycle Datapath | Not started |
| 5 | Control Unit | Not started |
| 6 | Full Processor Integration | Not started |
| 7 | Branch/Jump Handling | Not started |
| 8 | Load/Store (Memory Interface) | Not started |

Target: a working single-cycle RV32I core that can run small hand-assembled programs (arithmetic, branches, loads/stores — the kind of exercises in the Verilog-portfolio repo's RISC-V assembly practice).

## Why this exists

Built as part of a self-study path from Digital Logic → SystemVerilog/Verification → Computer Architecture, aimed at a Jr. Design Verification / Jr. Hardware Design role. Each module is designed and coded by hand, then verified with a self-checking testbench before moving to the next piece.
