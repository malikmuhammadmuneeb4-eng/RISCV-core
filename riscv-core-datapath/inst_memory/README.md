# Instruction Memory

**Goal:** a read-only, purely combinational instruction memory — given the current `pc` as `addr`, return the 32-bit instruction stored there. 256 words (1KB), enough for small hand-assembled test programs.

```systemverilog
module inst_memory(
  input  logic [31:0] addr,
  output logic [31:0] instr
);
  logic [31:0] mem [255:0];
  always_comb begin
    instr = mem[addr[9:2]];
  end
endmodule
```

**Concepts practiced:** byte-addressed vs. word-addressed memory — `pc` always increments by `4` (RV32I instructions are 4 bytes, and RISC-V memory addresses are byte addresses), but the backing array `mem` is indexed word-by-word (`mem[0]`, `mem[1]`, `mem[2]`, ...), so a plain `mem[addr]` would waste 3 out of every 4 array slots and break as soon as `addr` exceeded the array's word-count; `addr[9:2]` fixes this by dropping the low 2 bits of `addr` (which are always `00` for a word-aligned address — that's exactly what "divide by 4" means in binary) before using the remaining bits as the array index, so `addr=0,4,8,12,...` maps to `mem[0],mem[1],mem[2],mem[3],...`; the index width (`[9:2]`, 8 bits) comes directly from the array size — `256 = 2^8` locations needs exactly 8 index bits, and bits `9` down to `2` inclusive is 8 bits.

**No `reset` here, intentionally:** unlike `pc_counter` and `data_mem`, this module has no `clk`/`reset` at all — the program loaded into `mem` is meant to persist for the whole simulation (it's not something the processor itself ever writes to), so there's nothing for a reset to usefully clear. In the `datapath` testbench, `mem` is preloaded once via a hierarchical path (`uut.ITEM.mem[0] = ...`) before releasing reset.

**Mistakes caught along the way:**
- Missing semicolon after the `logic [31:0] mem [255:0];` array declaration.
- First working version indexed with plain `mem[addr]` instead of `mem[addr[9:2]]` — functionally almost worked (reads at `addr=0` were fine) but wasted most of the array and would have broken on any program longer than ~64 words; fixed after tracing through `addr=0/4/8/12` in binary to see why only every 4th slot was ever actually used.
