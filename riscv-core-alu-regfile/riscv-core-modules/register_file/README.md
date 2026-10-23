# Register File

**Goal:** a 32-register, 32-bit-wide register file with 2 read ports and 1 write port, matching what an RV32I single-cycle datapath needs (every instruction can read up to two source registers `rs1`/`rs2` and write one destination register `rd` in the same cycle).

```systemverilog
module reg_file (
  input  logic        clk,
  input  logic        we,       // write enable
  input  logic [4:0]  rs1,      // read address 1
  input  logic [4:0]  rs2,      // read address 2
  input  logic [4:0]  rd,       // write address
  input  logic [31:0] wd,       // write data
  output logic [31:0] rd1,      // read data 1
  output logic [31:0] rd2       // read data 2
);

  logic [31:0] regs [31:0];   // 32 registers, 32 bits each

  // Write port (synchronous). x0 is forced to 0 even if someone writes to it.
  always_ff @(posedge clk) begin
    if (we == 1'b1) begin
      if (rd == 5'b00000)
        regs[rd] <= 32'b0;
      else
        regs[rd] <= wd;
    end
  end

  // Read ports (combinational). x0 is also forced to 0 on the READ side,
  // so an uninitialized/undefined x0 can never be read before any write happens.
  always_comb begin
    rd1 = (rs1 == 0) ? 32'b0 : regs[rs1];
    rd2 = (rs2 == 0) ? 32'b0 : regs[rs2];
  end

endmodule
```

**Concepts practiced:** RISC-V's `x0` (register 0) convention — reads always return 0 and writes to it are discarded by hardware; why that has to be handled on BOTH the write side (forcing `regs[0] <= 0` whenever it's selected as `rd`) and the read side (`rd1`/`rd2` explicitly check for address 0) — relying on the write side alone leaves a gap: before any write ever targets `x0`, its storage is uninitialized/undefined (X in simulation), so a read of `x0` at that point would not reliably return 0; synchronous write (`always_ff`, clock-edge-driven) vs combinational read (`always_comb`, immediate); ternary operator (`condition ? value_if_true : value_if_false`) as a compact alternative to a multi-branch `if-else` — first learned here, then immediately reused to simplify the ALU's SLT case the same session.

**Mistakes caught along the way:**
- Named the internal 32-register array `reg` — a reserved SystemVerilog keyword, not usable as an identifier.
- A resulting name mismatch (referred to the array as `mem` in one place after renaming it).
- `end module` (two words) instead of `endmodule`.
- A real design gap caught via guided reasoning rather than a syntax error: initially only forced `x0=0` on the write side, missing that an unwritten `x0` would read as undefined (X) rather than 0 — fixed by adding the same zero-forcing check on the read side.
- First attempt at the read-side fix used a verbose 4-way `if-else` enumerating every combination of `rs1==0`/`rs2==0` (functionally correct, but unnecessary once it was clear `rd1` and `rd2` are independent of each other) — simplified to two independent ternary expressions after learning the ternary operator.
