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
