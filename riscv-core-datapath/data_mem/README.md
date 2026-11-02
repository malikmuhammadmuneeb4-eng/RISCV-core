# Data Memory

**Goal:** the memory that `lw`/`sw` read and write — one write port (synchronous, gated by `mem_write`) and one read port (combinational), 256 words (1KB), same addressing scheme as `inst_memory`. Unlike `inst_memory`, this one is reset-clearable, since its contents are genuinely part of a run's mutable state.

```systemverilog
module data_mem(
  input  logic        clk, mem_write, reset,
  input  logic [31:0] addr,
  input  logic [31:0] write_data,
  output logic [31:0] read_data
);
  logic [31:0] mem [255:0];
  integer i;
  always_ff @(posedge clk) begin
    if (reset) begin
      for (i = 0; i < 256; i = i + 1)
        mem[i] <= 32'b0;
    end
    else if (mem_write)
      mem[addr[9:2]] <= write_data;
  end
  always_comb begin
    read_data = mem[addr[9:2]];
  end
endmodule
```

**Concepts practiced:** same `addr[9:2]` word-indexing fix as `inst_memory`, applied here too since it's the same byte-addressed-PC-vs-word-indexed-array mismatch; read port is `always_comb` (same cycle, no latency) while the write port is `always_ff` (takes effect on the next clock edge) — matching the single-cycle design's assumption that a `lw` can read the value a prior `sw` just wrote, as long as they're not literally the same cycle; `reset` here was a deliberate design choice (not required by the RV32I spec) added specifically to make simulation debugging easier — a known all-zero starting state instead of every byte starting undefined (X), so a test failure is more likely to be a real bug than a leftover-garbage artifact; the `for`-loop-inside-`always_ff` pattern for clearing an entire array one word at a time (first use of a `for` loop in this project) as the practical workaround for "a register array can't be assigned a single scalar value directly."

**Mistakes caught along the way:**
- Missing comma in the port list between `reset` and the next `input`.
- An early draft explicitly wrote `else mem[addr[9:2]] <= mem[addr[9:2]];` for the "don't write" case — pointed out as unnecessary (not wrong, just redundant): omitting the `else` branch entirely already holds the previous value in `always_ff`, since a register that isn't assigned on a given clock edge simply keeps its value.
