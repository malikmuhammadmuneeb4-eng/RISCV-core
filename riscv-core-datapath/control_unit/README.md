# Control Unit

**Goal:** a purely combinational module that looks at `opcode`/`funct3`/`funct7` and generates every control signal the rest of the datapath needs: `alu_op` (which ALU operation to run), `reg_write` (write the register file this cycle?), `alu_src` (ALU's second operand: register `rd2` or the decoded `imm`?), `mem_write` (write to data memory this cycle?), `branch`/`jump` (does this instruction change the PC outside the normal `pc+4`?), and `reg_src` (which of 4 values gets written back to the register file: ALU result / `pc+4` / memory read data / `pc+imm`).

Covers all 8 RV32I instruction formats this core implements: R-type, I-type (arithmetic), I-type (load), S-type (store), B-type (branch), U-type (`lui`), U-type (`auipc`), and J-type (`jal`) / I-type (`jalr`).

```systemverilog
module control_unit(
  input  logic [6:0] opcode,
  input  logic [2:0] funct3,
  input  logic [6:0] funct7,
  output logic [3:0] alu_op,
  output logic       reg_write,
  output logic       alu_src,
  output logic       mem_write,
  output logic       branch,
  output logic       jump,
  output logic [1:0] reg_src
);
  always_comb begin
    case(opcode)
      7'b0110011: begin // R-type — alu_op picked from funct3/funct7
        reg_write=1'b1; alu_src=1'b0; mem_write=1'b0; branch=1'b0; jump=1'b0; reg_src=2'b00;
        // ... funct3/funct7 -> alu_op (add/sub/and/or/xor/sll/srl/sra/slt)
      end
      7'b0010011: begin // I-type (addi/andi/ori/xori/slli/slti/srli/srai)
        reg_write=1'b1; alu_src=1'b1; mem_write=1'b0; branch=1'b0; jump=1'b0; reg_src=2'b00;
      end
      7'b0100011: begin // S-type (sw)
        reg_write=1'b0; alu_src=1'b1; mem_write=1'b1; branch=1'b0; jump=1'b0; reg_src=2'b00; alu_op=4'b0000;
      end
      7'b1100011: begin // B-type (beq/bne/blt/bge/bltu/bgeu)
        reg_write=1'b0; alu_src=1'b0; mem_write=1'b0; branch=1'b1; jump=1'b0; reg_src=2'b00;
        // ... funct3 -> alu_op (SUB for beq/bne, SLT for blt/bge, BLTU for bltu/bgeu)
      end
      7'b0110111: begin // U-type (lui)
        reg_write=1'b1; alu_src=1'b1; mem_write=1'b0; branch=1'b0; jump=1'b0; reg_src=2'b00; alu_op=4'b1010; // PASS_B
      end
      7'b1101111: begin // J-type (jal)
        reg_write=1'b1; alu_src=1'b0; mem_write=1'b0; branch=1'b0; jump=1'b1; reg_src=2'b01; alu_op=4'b0000;
      end
      7'b1100111: begin // I-type (jalr)
        reg_write=1'b1; alu_src=1'b1; mem_write=1'b0; branch=1'b0; jump=1'b1; reg_src=2'b01; alu_op=4'b0000;
      end
      7'b0000011: begin // I-type (lw)
        reg_write=1'b1; alu_src=1'b1; mem_write=1'b0; branch=1'b0; jump=1'b0; reg_src=2'b10; alu_op=4'b0000;
      end
      7'b0010111: begin // U-type (auipc)
        reg_write=1; alu_src=0; mem_write=0; branch=0; jump=0; reg_src=2'b11; alu_op=4'b0000;
      end
      default: begin
        reg_write=1'b0; alu_src=1'b0; mem_write=1'b0; branch=1'b0; jump=1'b0; reg_src=2'b00; alu_op=4'b0000;
      end
    endcase
  end
endmodule
```

(full `funct3`/`funct7` sub-cases for R-type/I-type/B-type are in the actual source file — trimmed here for length)

**Concepts practiced:** the difference between "this instruction is a branch" (`branch=1`) and "this branch is actually taken" — `branch` only flags the instruction *type*; whether the PC actually jumps is decided later in `datapath` by interpreting `alu_result` against `funct3` (`beq`/`bne` check `result==0`/`!=0` from a SUB, `blt`/`bge` check `result==1`/`0` from SLT, `bltu`/`bgeu` the same from the new BLTU op); why `jal`/`jalr` ("jump **and link**") need `reg_write=1` even though they're jumps — the "link" part writes the return address (`pc+4`) to `rd`, which is exactly what makes `jal ra, func` / `jalr x0, 0(ra)` work as a call/return pair, and why `jal x0, label` (discarding the return address into `x0`) is a real, intentional idiom rather than "nothing is written"; `reg_src` widened from 1 bit to 2 bits mid-build, twice — first to fit 3 write-back sources (ALU result / `pc+4` / memory data) once `lw` was added, then a 4th slot (`pc+imm`, for `auipc`) was free in the same 2-bit encoding without needing to widen again; `jalr`'s target (`rs1+imm`, register-relative) is computed by the *existing* ALU (`alu_src=1`, `alu_op=ADD`) — no new hardware needed — while `jal`'s target (`pc+imm`, PC-relative) needs a dedicated adder in `datapath` since the ALU has no PC input.

**Mistakes caught along the way:**
- I-type `addi` initially copied the R-type `add`/`sub` funct7-check pattern (checking `funct7` to decide add vs. sub) — there is no `subi` instruction in RV32I, so this check is meaningless for I-type and was removed.
- Tried referencing a nonexistent `imm` input to detect I-type shift amounts/types — corrected to use the already-available `funct7` input directly (the decoder extracts `funct7=instr[31:25]` unconditionally, so it's already meaningful for I-type shift instructions too, without needing `imm`).
- S-type `alu_op` initially set to `SLL` instead of `ADD`, from momentarily treating a load/store offset as a multiply/shift rather than a plain base+offset addition.
- B-type `alu_src` initially set to `1` (confusing "the immediate is used somewhere in this instruction" with "the immediate feeds the ALU's `b` input") — branches compare two *registers*, so `alu_src=0`; the immediate is used entirely separately, by the PC-target adder in `datapath`.
- B-type was initially missing `bge`/`bltu`/`bgeu` cases and a `default` — `bltu`/`bgeu` specifically required a new ALU op (`BLTU`) since the existing `SLT` is hard-wired signed.
- `jal`/`jalr` both initially had `reg_write=0` ("nothing is written to a register") — fixed after working through why "jump **and link**" means a return address write is the whole point of the instruction.
- `default` case was found, twice, to have accidentally copied `jump=1`/`reg_src=2'b01` from the J-type branch above it instead of the correct all-zero/all-don't-care defaults, and was at one point missing a `branch` assignment entirely — both caught by review before being wired into `datapath`.
