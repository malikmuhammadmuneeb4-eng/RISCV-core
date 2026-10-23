# ALU (Arithmetic Logic Unit)

**Goal:** a combinational ALU supporting the core RV32I integer computational operations, driven by a 4-bit `alu_op` selector.

```systemverilog
module alu (
  input  logic [31:0] a,
  input  logic [31:0] b,
  input  logic [3:0]  alu_op,
  output logic [31:0] result
);

  always_comb begin
    case (alu_op)
      4'b0000: result = a + b;                                   // ADD
      4'b0001: result = a - b;                                   // SUB
      4'b0010: result = a & b;                                   // AND
      4'b0011: result = a | b;                                   // OR
      4'b0100: result = a ^ b;                                   // XOR
      4'b0101: result = a << b[4:0];                             // SLL
      4'b0110: result = a >> b[4:0];                             // SRL
      4'b0111: result = ($signed(a) < $signed(b)) ? 1'b1 : 1'b0; // SLT
      4'b1000: result = $signed(a) >>> b[4:0];                   // SRA
      default: result = 32'b0;
    endcase
  end

endmodule
```

**Why 4-bit `alu_op` and not 3-bit:** 9 distinct operations are implemented (ADD through SRA). 3 bits only cover 8 combinations (0-7), and the SRA code (`4'b1000` = 8) doesn't fit in that range, so 4 bits are required.

**Concepts practiced:** shift operators (`<<`, `>>`, `>>>`) vs the multiply operator (`*`) — shifting is not implemented as multiplication in hardware even though it's conceptually a power-of-2 multiply; signed vs unsigned comparison — `logic` is unsigned by default, so a plain `a < b` on two's-complement negative numbers gives the wrong (unsigned) answer, fixed with `$signed()` casts applied only at the comparison/shift site rather than declaring the ports themselves `signed` (which would also wrongly affect the bitwise/add/sub operations); the distinction between SRL (logical shift, zero-fills, intentionally destroys the sign bit) and SRA (arithmetic shift, sign-preserving); and that "is this value signed or unsigned" is never something hardware can determine by inspecting the bits themselves — it's a choice made by which instruction/opcode is selected, not a property of the data.

**Mistakes caught along the way:**
- Used `*` instead of `<<`/`>>` for SLL/SRL (confusing the conceptual multiply-by-power-of-2 meaning of a shift with how it's actually written in hardware description).
- Wrong shift-amount bit range for SRL (`b[31:28]` instead of `b[4:0]`).
- Missing `()` around the `if` condition for SLT (`if a<b` instead of `if (a<b)`).
- Tried to runtime-detect whether a number was "signed" via `if (a == $signed(a))` before applying SRA — corrected: signedness isn't inherent to the bits, so there's nothing to detect; the ALU is simply told which operation to run via `alu_op`.
