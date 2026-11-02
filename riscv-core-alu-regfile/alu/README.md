# ALU (Arithmetic Logic Unit)

**Goal:** a combinational ALU supporting the core RV32I integer computational operations, driven by a 4-bit `alu_op` selector.

```systemverilog
module alu (
  input  logic [31:0] a,        // operand 1
  input  logic [31:0] b,        // operand 2
  input  logic [3:0]  alu_op,   // operation selector
  output logic [31:0] result    // output
);

  always_comb begin
    case (alu_op)
      4'b0000: result = a + b;                                   // ADD
      4'b0001: result = a - b;                                   // SUB
      4'b0010: result = a & b;                                   // AND
      4'b0011: result = a | b;                                   // OR
      4'b0100: result = a ^ b;                                   // XOR
      4'b0101: result = a << b[4:0];                             // SLL (shift left logical)
      4'b0110: result = a >> b[4:0];                             // SRL (shift right logical)
      4'b0111: result = ($signed(a) < $signed(b)) ? 1'b1 : 1'b0; // SLT (set less than, signed)
      4'b1000: result = $signed(a) >>> b[4:0];                   // SRA (shift right arithmetic)
      4'b1001: result = (a < b) ? 1'b1 : 1'b0;                   // BLTU (set less than, unsigned)
      4'b1010: result = b;                                       // PASS_B (passthrough, for lui/auipc)
      default: result = 32'b0;
    endcase
  end

endmodule
```

**Why 4-bit `alu_op` and not 3-bit:** 11 distinct operations are implemented. 3 bits only cover 8 combinations (0-7); even the original 9 ops (ADD through SRA) already didn't fit, so 4 bits are required.

**Why `BLTU` and `PASS_B` were added later:** both came from building out the `control_unit`/`datapath` (in `riscv-core-datapath/`), not from the original ALU design pass.
- `bltu`/`bgeu` (unsigned branch instructions) need an unsigned less-than comparison. The existing `SLT` op is hard-wired to `$signed()` comparison for the signed branches (`blt`/`bge`), so reusing it for the unsigned case would give wrong answers for operands with the high bit set — a dedicated `BLTU` op (plain `a < b`, no signed cast) was added instead of trying to make one op serve both.
- `lui` loads a 20-bit immediate directly into a register — it doesn't combine two register values or do any arithmetic. But `lui` still goes through the same datapath as every other instruction, including the ALU. `PASS_B` lets the ALU act as a simple wire for this one case: ignore `a` (which holds garbage for `lui`, since there's no `rs1` register) and output `b` unchanged (which carries the immediate, routed in through the `alu_src` mux).

**Concepts practiced:** shift operators (`<<`, `>>`, `>>>`) vs the multiply operator (`*`) — shifting is not implemented as multiplication in hardware even though it's conceptually a power-of-2 multiply; signed vs unsigned comparison — `logic` is unsigned by default, so a plain `a < b` on two's-complement negative numbers gives the wrong (unsigned) answer, fixed with `$signed()` casts applied only at the comparison/shift site rather than declaring the ports themselves `signed` (which would also wrongly affect the bitwise/add/sub operations); the distinction between SRL (logical shift, zero-fills, intentionally destroys the sign bit) and SRA (arithmetic shift, sign-preserving); and that "is this value signed or unsigned" is never something hardware can determine by inspecting the bits themselves — it's a choice made by which instruction/opcode is selected, not a property of the data.

**Mistakes caught along the way:**
- Used `*` instead of `<<`/`>>` for SLL/SRL (confusing the conceptual multiply-by-power-of-2 meaning of a shift with how it's actually written in hardware description).
- Wrong shift-amount bit range for SRL (`b[31:28]` instead of `b[4:0]`).
- Missing `()` around the `if` condition for SLT (`if a<b` instead of `if (a<b)`).
- Tried to runtime-detect whether a number was "signed" via `if (a == $signed(a))` before applying SRA — corrected: signedness isn't inherent to the bits, so there's nothing to detect; the ALU is simply told which operation to run via `alu_op`.
