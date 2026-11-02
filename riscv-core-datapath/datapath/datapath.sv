module datapath(
  input logic clk,
  input logic reset
);

  // ===== Fetch =====
  logic [31:0] pc;
  logic [31:0] next_pc;
  logic [31:0] instr;
  logic [31:0] pc_plus_4;
  assign pc_plus_4 = pc + 32'd4;

  pc_counter PC(.clk(clk), .reset(reset), .next_pc(next_pc), .pc(pc));
  inst_memory ITEM(.addr(pc), .instr(instr));

  // ===== Decode =====
  logic [6:0] opcode;
  logic [4:0] rd;
  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [31:0] imm;
  decoder D0(.instr(instr), .opcode(opcode), .rd(rd), .rs1(rs1), .rs2(rs2), .funct3(funct3), .funct7(funct7), .imm(imm));

  logic [3:0] alu_op;
  logic reg_write;
  logic alu_src;
  logic mem_write;
  logic branch;
  logic jump;
  logic [1:0] reg_src;
  control_unit CONTROL(.opcode(opcode), .funct3(funct3), .funct7(funct7), .alu_op(alu_op), .reg_write(reg_write), .alu_src(alu_src), .mem_write(mem_write), .branch(branch), .jump(jump), .reg_src(reg_src));

  // ===== Register Read =====
  logic [31:0] rd1;
  logic [31:0] rd2;
  logic [31:0] wd;
  reg_file REGISTERS(.clk(clk), .reset(reset), .we(reg_write), .rs1(rs1), .rs2(rs2), .rd(rd), .wd(wd), .rd1(rd1), .rd2(rd2));

  // ===== Execute =====
  logic [31:0] alu_b;
  logic [31:0] alu_result;
  assign alu_b = (alu_src==1) ? imm : rd2;
  alu EXECUTE(.a(rd1), .b(alu_b), .alu_op(alu_op), .result(alu_result));

  // ===== Memory =====
  logic [31:0] mem_read_data;
  data_mem DM0(.clk(clk), .mem_write(mem_write), .reset(reset), .addr(alu_result), .write_data(rd2), .read_data(mem_read_data));

  // ===== PC update =====
  logic [31:0] pc_plus_imm;
  assign pc_plus_imm = pc + imm;

  // ===== Write-back =====
  always_comb begin
    case(reg_src)
      2'b00: wd = alu_result;
      2'b01: wd = pc_plus_4;
      2'b10: wd = mem_read_data;
      2'b11: wd = pc_plus_imm;
      default: wd = alu_result;
    endcase
  end

  always_comb begin
    if (opcode == 7'b1100111)          // jalr
      next_pc = alu_result;
    else if (jump == 1'b1)              // jal
      next_pc = pc_plus_imm;
    else if (branch == 1'b1) begin      // conditional branch
      case(funct3)
        3'b000: next_pc = (alu_result==0) ? pc_plus_imm : pc_plus_4;
        3'b001: next_pc = (alu_result!=0) ? pc_plus_imm : pc_plus_4;
        3'b100: next_pc = (alu_result==1) ? pc_plus_imm : pc_plus_4;
        3'b101: next_pc = (alu_result==0) ? pc_plus_imm : pc_plus_4;
        3'b110: next_pc = (alu_result==1) ? pc_plus_imm : pc_plus_4;
        3'b111: next_pc = (alu_result==0) ? pc_plus_imm : pc_plus_4;
        default: next_pc = pc_plus_4;
      endcase
    end
    else
      next_pc = pc_plus_4;
  end

endmodule
