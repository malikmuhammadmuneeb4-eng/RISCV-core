# PC Register (Program Counter)

**Goal:** the one piece of state that drives instruction fetch — a 32-bit register holding the address of the current instruction, updated every clock edge to whatever `next_pc` the rest of the datapath computes, and resettable to `0`.

```systemverilog
module pc_counter(
  input  logic        clk, reset,
  input  logic [31:0] next_pc,
  output logic [31:0] pc
);
  always_ff @(posedge clk)
  begin
    if (reset==1) pc <= 32'b0;
    else pc <= next_pc;
  end
endmodule
```

**Concepts practiced:** `always_ff` (not `always_comb`) is the right choice here specifically because PC is *state* that must hold its value between clock edges — it's not computing something from current inputs, it's remembering the last thing it was told; `pc_counter` itself has no adder and no idea what "`+4`" means — it's a dumb register that just latches whatever `next_pc` it's given. The actual "what's the next address" decision (default `pc+4`, or a branch/jump target, or an `jalr` target) lives entirely outside this module, in `datapath`'s PC-update logic — `pc_counter` just stores the result.

**Mistakes caught along the way:**
- Output port `pc` was initially declared without a width (`logic pc` instead of `logic [31:0] pc`), silently truncating it to 1 bit.
