# Instruction Decoder

**Goal:** a purely combinational module that takes a raw 32-bit RV32I instruction and splits it into the fields every downstream module needs — `opcode`, `rd`, `rs1`, `rs2`, `funct3`, `funct7`, and a single sign-extended 32-bit `imm` (immediate), regardless of which of the 6 RISC-V instruction formats (R/I/S/B/U/J) the instruction actually is.

```systemverilog
module decoder(
  input  logic [31:0] instr,
  output logic [6:0]  opcode,
  output logic [4:0]  rd,
  output logic [4:0]  rs1,
  output logic [4:0]  rs2,
  output logic [2:0]  funct3,
  output logic [6:0]  funct7,
  output logic [31:0] imm
);
  always_comb begin
    opcode = instr[6:0];
    rd     = instr[11:7];
    funct3 = instr[14:12];
    rs1    = instr[19:15];
    rs2    = instr[24:20];
    funct7 = instr[31:25];
    case(opcode)
      7'b0010011: imm={{20{instr[31]}},instr[31:20]};                    // I-type (addi etc)
      7'b0100011: imm={{20{instr[31]}},instr[31:25],instr[11:7]};        // S-type
      7'b1100011: imm={{19{instr[31]}},instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
      7'b0110111: imm={instr[31:12],{12'b0}};                            // U-type (lui)
      7'b1101111: imm={{11{instr[31]}},instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type (jal)
      7'b0000011: imm={{20{instr[31]}},instr[31:20]};                    // I-type (load)
      7'b1100111: imm={{20{instr[31]}},instr[31:20]};                    // I-type (jalr)
      7'b0010111: imm={instr[31:12],{12'b0}};                            // U-type (auipc)
      default: imm=0;                                                    // R-type
    endcase
  end
endmodule
```

**Concepts practiced:** fixed-position fields (`opcode`, `rd`, `rs1`, `rs2`, `funct3`, `funct7`) always sit at the same bit positions no matter the instruction format, so they can be extracted unconditionally — only `imm` needs a `case` on `opcode`, because each format scatters/sign-extends it differently; sign extension via replication (`{{20{instr[31]}}, ...}`) rather than zero-padding, so a negative 12-bit offset stays negative as a 32-bit value; the RV32I immediate encodings are deliberately non-contiguous (bits are placed to share wiring with other fields, not for software readability) — B-type and J-type scatter the immediate bits across the instruction (`imm[12|10:5]`/`imm[11|4:1]` for B-type, `imm[20|10:1|11|19:12]` for J-type) rather than storing it as one contiguous field like I-type/S-type do; both B-type and J-type immediates always have an implicit `imm[0]=0` (branch/jump targets are always even, 2-byte aligned), so that bit is never stored in the instruction at all — it's hard-coded as `1'b0` in the concatenation.

**Mistakes caught along the way:**
- First version of the B-type and J-type `imm` cases used a shortcut: treated them like S-type (same field layout, not the real scattered RISC-V encoding). This "worked" in isolation but would have silently computed wrong branch/jump offsets for any real `beq`/`jal` the moment the `datapath` actually ran one — caught only once the full datapath was simulated end-to-end with real `beq`/`jal` instructions and their decoded offsets didn't line up with the hand-worked-out expected targets.
- Fixed by rebuilding both cases field-by-field against the real RV32I format tables, including getting the concatenation **order** right (`imm[12]` then `imm[11]` then `imm[10:5]` then `imm[4:1]` then the hard-coded `imm[0]=0` for B-type) and recounting the sign-extension width each time a field was added/reordered (adding the explicit `1'b0` bit for `imm[0]` means one fewer sign-extension bit is needed to keep the total at 32).
- `lw` (opcode `0000011`), `jalr` (opcode `1100111`), and `auipc` (opcode `0010111`) were missing `imm` cases entirely at first — each fell through to `default` and got `imm=0`, which is wrong for all three (silently breaks loads, `jalr` targets, and `auipc`-based addressing). Caught the same way, by the testbench.
