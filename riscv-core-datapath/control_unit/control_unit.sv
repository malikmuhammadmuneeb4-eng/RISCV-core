module control_unit(
input logic [6:0]opcode,
input logic [2:0] funct3,
input logic [6:0] funct7,
output logic [3:0] alu_op,
output logic reg_write,
output logic alu_src,
output logic mem_write,
output logic branch,
output logic jump,
output logic [1:0] reg_src
);
always_comb begin
case(opcode)
7'b0110011: begin //R-type
reg_write = 1'b1;
alu_src=1'b0;
mem_write=1'b0;
branch=1'b0;
jump=1'b0;
reg_src=2'b00;
case(funct3)
3'b000:  begin // add / sub
if (funct7 == 7'b0000000)
alu_op = 4'b0000; // add
else
alu_op = 4'b0001; end // sub
3'b111: alu_op = 4'b0010; // and
3'b110: alu_op = 4'b0011; // or
3'b100: alu_op= 4'b0100; // xor
3'b001: alu_op= 4'b0101; // sll
3'b010: alu_op= 4'b0111; // slt
3'b101: begin if (funct7==7'b0000000) // srl / sra
                alu_op=4'b0110; // srl
else alu_op=4'b1000; end // sra
default: alu_op = 4'b0000;
endcase
end

7'b0010011: begin //I-type (addi, andi, ori, xori, slli, slti, srli, srai)
reg_write = 1'b1;
alu_src=1'b1;
mem_write=1'b0;
branch=1'b0;
jump=1'b0;
reg_src=2'b00;
case(funct3)
3'b000:  alu_op = 4'b0000; // addi
3'b111: alu_op = 4'b0010; // andi
3'b110: alu_op = 4'b0011; // ori
3'b100: alu_op= 4'b0100; // xori
3'b001: alu_op= 4'b0101; // slli
3'b010: alu_op= 4'b0111; // slti
3'b101: begin if (funct7==7'b0000000) // srli / srai
                alu_op=4'b0110; // srli
else alu_op=4'b1000; end // srai
default: alu_op = 4'b0000;
endcase
end

7'b0100011: begin // S-type: sw (store word)
reg_write = 1'b0;
alu_src=1'b1;
mem_write=1'b1;
branch=1'b0;
jump=1'b0;
reg_src=2'b00;
alu_op=4'b0000;
end

7'b1100011: // B-type: beq, bne, blt, bge, bltu, bgeu
begin
reg_write = 1'b0;
alu_src=1'b0;
mem_write=1'b0;
branch=1'b1;
jump=1'b0;
reg_src=2'b00;
case(funct3)
3'b000: alu_op=4'b0001; // beq  -> sub, branch taken if result==0
3'b001: alu_op=4'b0001; // bne  -> sub, branch taken if result!=0
3'b100: alu_op=4'b0111; // blt  -> slt (signed)
3'b101: alu_op=4'b0111; // bge  -> slt (signed), taken if result==0
3'b110: alu_op=4'b1001; // bltu -> sltu (unsigned)
3'b111: alu_op=4'b1001; // bgeu -> sltu (unsigned), taken if result==0
default: alu_op=4'b0001;
endcase
end

7'b0110111: // U-type: lui
begin
reg_write = 1'b1;
alu_src=1'b1;
mem_write=1'b0;
branch=1'b0;
jump=1'b0;
reg_src=2'b00;
alu_op=4'b1010; // pass immediate straight through as the result
end

7'b1101111: begin // jal
reg_write = 1'b1;
alu_src=1'b0;
mem_write=1'b0;
branch=1'b0;
jump=1'b1;
reg_src=2'b01; // write back pc+4 (return address)
alu_op=4'b0000;
end

7'b1100111: begin // jalr
reg_write = 1'b1;
alu_src=1'b1;
mem_write=1'b0;
branch=1'b0;
jump=1'b1;
reg_src=2'b01; // write back pc+4 (return address)
alu_op=4'b0000;
end

7'b0000011: begin // I-type load: lw
reg_write = 1'b1;
alu_src=1'b1;
mem_write=1'b0;
branch=1'b0;
jump=1'b0;
reg_src=2'b10; // write back the value read from data memory
alu_op=4'b0000;
end

7'b0010111: begin // auipc -> reg_src=11 selects pc+imm as the write-back value
reg_write=1;
reg_src=2'b11;
mem_write=0;
branch=0;
jump=0;
alu_src=0;
alu_op=4'b0000;
end

default: begin // unknown/uninitialized opcode -> do nothing (no reg write, no mem write, no branch/jump)
reg_write = 1'b0;
alu_src= 1'b0;
mem_write=1'b0;
branch=1'b0;
jump=1'b0;
reg_src=2'b00;
alu_op = 4'b0000;
end
endcase
end
endmodule
