# RISCV-core

A single-cycle RV32I RISC-V processor, built up module by module in SystemVerilog — each piece designed and verified from scratch as part of self-directed digital design/verification practice.

This repo tracks the build incrementally: every module ships with its own RTL, a self-checking testbench, and a short README explaining the design and the bugs caught along the way. The companion repo, [Verilog-portfolio](https://github.com/malikmuhammadmuneeb4-eng/Verilog-portfolio), has the foundational practice work (combinational/sequential circuits, verification methodology drills) that led into this build.

## Roadmap

| # | Module | Status |
|---|--------|--------|
| 1 | ALU | Done |
| 2 | Register File | Done |
| 3 | Instruction Decoder | Done |
| 4 | Control Unit | Done |
| 5 | PC Register | Done |
| 6 | Instruction Memory | Done |
| 7 | Data Memory | Done |
| 8 | Single-Cycle Datapath (full integration) | Done — simulated and verified |
| 9 | Branch/Jump Handling | Done (`beq`/`bne`/`blt`/`bge`/`bltu`/`bgeu`, `jal`, `jalr`) |
| 10 | Load/Store (Memory Interface) | Done (`lw`/`sw`) |

Target reached: a working single-cycle RV32I core (`riscv-core-datapath/datapath/`) that runs small hand-assembled programs — arithmetic, loads/stores, taken branches, and `jal`/`jalr` call/return — verified against hand-traced expected register and memory values. Covers R-type, I-type, S-type, B-type, U-type (`lui`/`auipc`), and J-type/`jalr`.

## Structure

```
riscv-core-alu-regfile/
  alu/              — ALU (11 ops: add/sub/and/or/xor/sll/srl/slt/sra/bltu/pass_b)
  register_file/    — 32x32-bit register file, 2 read ports + 1 write port

riscv-core-datapath/
  decoder/          — splits a raw instruction into opcode/rd/rs1/rs2/funct3/funct7/imm
  control_unit/     — opcode/funct3/funct7 -> every control signal in the datapath
  pc_counter/       — the program counter register
  inst_memory/      — read-only instruction memory
  data_mem/         — lw/sw data memory
  datapath/         — full single-cycle core (wires all of the above together) + testbench + diagram
```

## Why this exists

Built as part of a self-study path from Digital Logic → SystemVerilog/Verification → Computer Architecture, aimed at a Jr. Design Verification / Jr. Hardware Design role. Each module is designed and coded by hand, then verified with a self-checking testbench before moving to the next piece.
