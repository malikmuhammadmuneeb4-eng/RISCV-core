# RISCV-core — update instructions

This zip has the first two completed modules for the RISCV-core repo: **ALU** and **Register File**.

## Folder structure to use in the repo

```
RISCV-core/
  alu/
    alu.sv
    README.md
  register_file/
    register_file.sv
    README.md
```

Copy the `alu/` and `register_file/` folders from this zip straight into the root of the RISCV-core repo (same level as the existing root README.md).

## Update the root README.md's roadmap table

Change these two rows from "Not started" to "Done":

```
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
```

That's it — commit both new folders plus the README.md change together.
