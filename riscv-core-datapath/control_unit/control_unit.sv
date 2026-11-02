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
3'b000:  begin
if (funct7 == 7'b0000000)
alu_op = 4'b0000;
else
alu_op = 4'b0001; end
3'b111: alu_op = 4'b0010;
3'b110: alu_op = 4'b0011;
3'b100: alu_op= 4'b0100;
3'b001: alu_op= 4'b0101;
3'b010: alu_op= 4'b0111;
3'b101: begin if (funct7==7'b0000000)
                alu_op=4'b0110;
else alu_op=4'b1000; end
default: alu_op = 4'b0000;
endcase
end

7'b0010011: begin //I-type
reg_write = 1'b1;
alu_src=1'b1;
mem_write=1'b0;
branch=1'b0;
jump=1'b0;
reg_src=2'b00;
case(funct3)
3'b000:  alu_op = 4'b0000;
3'b111: alu_op = 4'b0010;
3'b110: alu_op = 4'b0011;
3'b100: alu_op= 4'b0100;
3'b001: alu_op= 4'b0101;
3'b010: alu_op= 4'b0111;
3'b101: begin if (funct7==7'b0000000)
                alu_op=4'b0110;
else alu_op=4'b1000; end
default: alu_op = 4'b0000;
endcase
end

7'b0100011: begin
reg_write = 1'b0;
alu_src=1'b1;
mem_write=1'b1;
branch=1'b0;
jump=1'b0;
reg_src=2'b00;
alu_op=4'b0000;
end

7'b1100011:
begin
reg_write = 1'b0;
alu_src=1'b0;
mem_write=1'b0;
branch=1'b1;
jump=1'b0;
reg_src=2'b00;
case(funct3)
3'b000: alu_op=4'b0001;
3'b001: alu_op=4'b0001;
3'b100: alu_op=4'b0111;
3'b101: alu_op=4'b0111;
3'b110: alu_op=4'b1001;
3'b111: alu_op=4'b1001;
default: alu_op=4'b0001;
endcase
end

7'b0110111:
begin
reg_write = 1'b1;
alu_src=1'b1;
mem_write=1'b0;
branch=1'b0;
jump=1'b0;
reg_src=2'b00;
alu_op=4'b1010;
end

7'b1101111: begin
reg_write = 1'b1;
alu_src=1'b0;
mem_write=1'b0;
branch=1'b0;
jump=1'b1;
reg_src=2'b01;
alu_op=4'b0000;
end

7'b1100111: begin
reg_write = 1'b1;
alu_src=1'b1;
mem_write=1'b0;
branch=1'b0;
jump=1'b1;
reg_src=2'b01;
alu_op=4'b0000;
end

7'b0000011: begin
reg_write = 1'b1;
alu_src=1'b1;
mem_write=1'b0;
branch=1'b0;
jump=1'b0;
reg_src=2'b10;
alu_op=4'b0000;
end

7'b0010111: begin // auipc
reg_write=1;
reg_src=2'b11;
mem_write=0;
branch=0;
jump=0;
alu_src=0;
alu_op=4'b0000;
end

default: begin
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
