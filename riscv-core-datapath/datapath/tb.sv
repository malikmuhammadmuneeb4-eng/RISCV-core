module tb;
reg clk,reset;

datapath uut(.clk(clk), .reset(reset));

initial clk=0;
always #5 clk=~clk;

reg [31:0] expected_x10,expected_x5, expected_x6, expected_x7, expected_mem0, expected_x8, expected_x9, expected_x1, expected_x11,expected_x14,expected_x0, expected_mem6;
reg signed [31:0] expected_x12, expected_x13;
initial begin
reset=1;
uut.ITEM.mem[0]  = 32'h00000517;  // auipc x10,0
uut.ITEM.mem[1]  = 32'h00050513;  // addi x10,x10,0
uut.ITEM.mem[2]  = 32'h00a00293;  // addi x5,x0,10
uut.ITEM.mem[3]  = 32'h01400313;  // addi x6,x0,20
uut.ITEM.mem[4]  = 32'h006283b3;  // add x7,x5,x6
uut.ITEM.mem[5]  = 32'h00752023;  // sw x7,0(x10)
uut.ITEM.mem[6]  = 32'h00052403;  // lw x8,0(x10)
uut.ITEM.mem[7]  = 32'h00838463;  // beq x7,x8,8
uut.ITEM.mem[8]  = 32'h06300493;  // addi x9,x0,99
uut.ITEM.mem[9]  = 32'h008000ef;  // jal x1,8
uut.ITEM.mem[10] = 32'h03700513;  // addi x10,x0,55
uut.ITEM.mem[11] = 32'h04d00593;  // addi x11,x0,77

expected_x10=32'b0;
expected_x5=32'b0;
expected_x6=32'b0;
expected_x7=32'b0;
expected_mem0=32'b0;
expected_x8=32'b0;
expected_x9=32'b0;
expected_x1=32'b0;
expected_x11=32'b0;

@(posedge clk);
#1;
if (expected_x10==uut.REGISTERS.regs[10] && expected_x5==uut.REGISTERS.regs[5] && expected_x6==uut.REGISTERS.regs[6] && expected_x7==uut.REGISTERS.regs[7] && expected_mem0==uut.DM0.mem[0] && expected_x8==uut.REGISTERS.regs[8] && expected_x9==uut.REGISTERS.regs[9] && expected_x1==uut.REGISTERS.regs[1] && expected_x11==uut.REGISTERS.regs[11])
  $display("PASS: reset successful x10=%0d x5=%0d x6=%0d x7=%0d mem0=%0d x8=%0d x9=%0d x1=%0d x11=%0d",uut.REGISTERS.regs[10],uut.REGISTERS.regs[5],uut.REGISTERS.regs[6],uut.REGISTERS.regs[7],uut.DM0.mem[0],uut.REGISTERS.regs[8],uut.REGISTERS.regs[9],uut.REGISTERS.regs[1],uut.REGISTERS.regs[11]);
else
  $display("FAIL: reset failed x10=%0d x5=%0d x6=%0d x7=%0d mem0=%0d x8=%0d x9=%0d x1=%0d x11=%0d",uut.REGISTERS.regs[10],uut.REGISTERS.regs[5],uut.REGISTERS.regs[6],uut.REGISTERS.regs[7],uut.DM0.mem[0],uut.REGISTERS.regs[8],uut.REGISTERS.regs[9],uut.REGISTERS.regs[1],uut.REGISTERS.regs[11]);

reset=0;
expected_x10=32'd0;
expected_x5=32'd10;
expected_x6=32'd20;
expected_x7=32'd30;
expected_mem0=32'd30;
expected_x8=32'd30;
expected_x9=32'd0;
expected_x1=32'd40;
expected_x11=32'd77;

repeat(10) begin
  @(posedge clk);
  #1;
end

if (uut.REGISTERS.regs[10] == expected_x10)
  $display("PASS: x10 = %0d", uut.REGISTERS.regs[10]);
else
  $display("FAIL: x10 = %0d, expected %0d", uut.REGISTERS.regs[10], expected_x10);

if (uut.REGISTERS.regs[5] == expected_x5)
  $display("PASS: x5 = %0d", uut.REGISTERS.regs[5]);
else
  $display("FAIL: x5 = %0d, expected %0d", uut.REGISTERS.regs[5], expected_x5);

if (uut.REGISTERS.regs[6] == expected_x6)
  $display("PASS: x6 = %0d", uut.REGISTERS.regs[6]);
else
  $display("FAIL: x6 = %0d, expected %0d", uut.REGISTERS.regs[6], expected_x6);

if (uut.REGISTERS.regs[7] == expected_x7)
  $display("PASS: x7 = %0d", uut.REGISTERS.regs[7]);
else
  $display("FAIL: x7 = %0d, expected %0d", uut.REGISTERS.regs[7], expected_x7);

if (uut.DM0.mem[0] == expected_mem0)
  $display("PASS: mem0 = %0d", uut.DM0.mem[0]);
else
  $display("FAIL: mem0 = %0d, expected %0d", uut.DM0.mem[0], expected_mem0);

if (uut.REGISTERS.regs[8] == expected_x8)
  $display("PASS: x8 = %0d", uut.REGISTERS.regs[8]);
else
  $display("FAIL: x8 = %0d, expected %0d", uut.REGISTERS.regs[8], expected_x8);

if (uut.REGISTERS.regs[9] == expected_x9)
  $display("PASS: x9 = %0d", uut.REGISTERS.regs[9]);
else
  $display("FAIL: x9 = %0d, expected %0d", uut.REGISTERS.regs[9], expected_x9);

if (uut.REGISTERS.regs[1] == expected_x1)
  $display("PASS: x1 = %0d", uut.REGISTERS.regs[1]);
else
  $display("FAIL: x1 = %0d, expected %0d", uut.REGISTERS.regs[1], expected_x1);

if (uut.REGISTERS.regs[11] == expected_x11)
  $display("PASS: x11 = %0d", uut.REGISTERS.regs[11]);
else
  $display("FAIL: x11 = %0d, expected %0d", uut.REGISTERS.regs[11], expected_x11);


uut.ITEM.mem[12]= 32'h00758463;  //beq  x11,x7,8
uut.ITEM.mem[13]= 32'h00a58593;  //addi x11,x11,10
uut.ITEM.mem[14]= 32'h00629463; //bne  x5,x6,8
uut.ITEM.mem[15]= 32'h00a28293;  //addi x5,x5,10
uut.ITEM.mem[16]= 32'h00529463; //bne  x5,x5,8
uut.ITEM.mem[17]= 32'h01428293; //addi x5,x5,20
expected_x10=32'd0;
expected_x5=32'd30;
expected_x6=32'd20;
expected_x7=32'd30;
expected_mem0=32'd30;
expected_x8=32'd30;
expected_x9=32'd0;
expected_x1=32'd40;
expected_x11=32'd87;

repeat(5) begin
  @(posedge clk);
  #1;
end
if (uut.REGISTERS.regs[10] == expected_x10)
  $display("PASS: x10 = %0d", uut.REGISTERS.regs[10]);
else
  $display("FAIL: x10 = %0d, expected %0d", uut.REGISTERS.regs[10], expected_x10);

if (uut.REGISTERS.regs[5] == expected_x5)
  $display("PASS: x5 = %0d", uut.REGISTERS.regs[5]);
else
  $display("FAIL: x5 = %0d, expected %0d", uut.REGISTERS.regs[5], expected_x5);

if (uut.REGISTERS.regs[6] == expected_x6)
  $display("PASS: x6 = %0d", uut.REGISTERS.regs[6]);
else
  $display("FAIL: x6 = %0d, expected %0d", uut.REGISTERS.regs[6], expected_x6);

if (uut.REGISTERS.regs[7] == expected_x7)
  $display("PASS: x7 = %0d", uut.REGISTERS.regs[7]);
else
  $display("FAIL: x7 = %0d, expected %0d", uut.REGISTERS.regs[7], expected_x7);

if (uut.DM0.mem[0] == expected_mem0)
  $display("PASS: mem0 = %0d", uut.DM0.mem[0]);
else
  $display("FAIL: mem0 = %0d, expected %0d", uut.DM0.mem[0], expected_mem0);

if (uut.REGISTERS.regs[8] == expected_x8)
  $display("PASS: x8 = %0d", uut.REGISTERS.regs[8]);
else
  $display("FAIL: x8 = %0d, expected %0d", uut.REGISTERS.regs[8], expected_x8);

if (uut.REGISTERS.regs[9] == expected_x9)
  $display("PASS: x9 = %0d", uut.REGISTERS.regs[9]);
else
  $display("FAIL: x9 = %0d, expected %0d", uut.REGISTERS.regs[9], expected_x9);

if (uut.REGISTERS.regs[1] == expected_x1)
  $display("PASS: x1 = %0d", uut.REGISTERS.regs[1]);
else
  $display("FAIL: x1 = %0d, expected %0d", uut.REGISTERS.regs[1], expected_x1);

if (uut.REGISTERS.regs[11] == expected_x11)
  $display("PASS: x11 = %0d", uut.REGISTERS.regs[11]);
else
  $display("FAIL: x11 = %0d, expected %0d", uut.REGISTERS.regs[11], expected_x11);

uut.ITEM.mem[18]=  32'hff400613; //addi x12,x0,-12
uut.ITEM.mem[19]= 32'hffb00693; //addi x13,x0,-5
uut.ITEM.mem[20]= 32'h00d64463; //blt  x12,x13,8
uut.ITEM.mem[21]= 32'h00168693; //addi x13,x13,1
uut.ITEM.mem[22]= 32'h00c2c463; //blt  x5,x12,8
uut.ITEM.mem[23]= 32'h00a28293; //addi x5,x5,10
uut.ITEM.mem[24]= 32'h00d65463; //bge  x12,x13,8
uut.ITEM.mem[25]= 32'h00a28293; // addi x5,x5,10
uut.ITEM.mem[26]= 32'h00c5d463; //bge  x11,x12,8
uut.ITEM.mem[27]= 32'h00a28293; //addi x5,x5,10
uut.ITEM.mem[28]= 32'h0055e463; //bltu x11,x5,8
uut.ITEM.mem[29]= 32'h00a28293; // addi x5,x5,10
uut.ITEM.mem[30]= 32'h00546463; // bltu x8,x5,8
uut.ITEM.mem[31]= 32'h00a28293; //addi x5,x5,10
uut.ITEM.mem[32]= 32'h00b2f463; //bgeu x5,x11,8
uut.ITEM.mem[33]= 32'h00a28293; //addi x5,x5,10
uut.ITEM.mem[34]= 32'h0062f463; //bgeu x5,x6,8
uut.ITEM.mem[35]= 32'h01428293; //addi x5,x5,20
uut.ITEM.mem[36]= 32'h00000713; //addi x14,x0,0
expected_x10=32'd0;
expected_x5=32'd70;
expected_x6=32'd20;
expected_x7=32'd30;
expected_mem0=32'd30;
expected_x8=32'd30;
expected_x9=32'd0;
expected_x1=32'd40;
expected_x11=32'd87;
expected_x12=-12;
expected_x13=-5;
expected_x14=32'd0;
repeat(15) begin
    @(posedge clk);
    #1;
end
if (uut.REGISTERS.regs[10] == expected_x10)
  $display("PASS: x10 = %0d", uut.REGISTERS.regs[10]);
else
  $display("FAIL: x10 = %0d, expected %0d", uut.REGISTERS.regs[10], expected_x10);

if (uut.REGISTERS.regs[5] == expected_x5)
  $display("PASS: x5 = %0d", uut.REGISTERS.regs[5]);
else
  $display("FAIL: x5 = %0d, expected %0d", uut.REGISTERS.regs[5], expected_x5);

if (uut.REGISTERS.regs[6] == expected_x6)
  $display("PASS: x6 = %0d", uut.REGISTERS.regs[6]);
else
  $display("FAIL: x6 = %0d, expected %0d", uut.REGISTERS.regs[6], expected_x6);

if (uut.REGISTERS.regs[7] == expected_x7)
  $display("PASS: x7 = %0d", uut.REGISTERS.regs[7]);
else
  $display("FAIL: x7 = %0d, expected %0d", uut.REGISTERS.regs[7], expected_x7);

if (uut.DM0.mem[0] == expected_mem0)
  $display("PASS: mem0 = %0d", uut.DM0.mem[0]);
else
  $display("FAIL: mem0 = %0d, expected %0d", uut.DM0.mem[0], expected_mem0);

if (uut.REGISTERS.regs[8] == expected_x8)
  $display("PASS: x8 = %0d", uut.REGISTERS.regs[8]);
else
  $display("FAIL: x8 = %0d, expected %0d", uut.REGISTERS.regs[8], expected_x8);

if (uut.REGISTERS.regs[9] == expected_x9)
  $display("PASS: x9 = %0d", uut.REGISTERS.regs[9]);
else
  $display("FAIL: x9 = %0d, expected %0d", uut.REGISTERS.regs[9], expected_x9);

if (uut.REGISTERS.regs[1] == expected_x1)
  $display("PASS: x1 = %0d", uut.REGISTERS.regs[1]);
else
  $display("FAIL: x1 = %0d, expected %0d", uut.REGISTERS.regs[1], expected_x1);

if (uut.REGISTERS.regs[11] == expected_x11)
  $display("PASS: x11 = %0d", uut.REGISTERS.regs[11]);
else
  $display("FAIL: x11 = %0d, expected %0d", uut.REGISTERS.regs[11], expected_x11);

if (uut.REGISTERS.regs[12] == expected_x12)
  $display("PASS: x12 = %0d",$signed(uut.REGISTERS.regs[12]));
else
  $display("FAIL: x12 = %0d, expected %0d", $signed(uut.REGISTERS.regs[12]), expected_x12);

if (uut.REGISTERS.regs[13] == expected_x13)
  $display("PASS: x13 = %0d", $signed(uut.REGISTERS.regs[13]));
else
  $display("FAIL: x13 = %0d, expected %0d",  $signed(uut.REGISTERS.regs[13]), expected_x13);

if (uut.REGISTERS.regs[14] == expected_x14)
  $display("PASS: x14 = %0d", uut.REGISTERS.regs[14]);
else
  $display("FAIL: x14 = %0d, expected %0d", uut.REGISTERS.regs[14], expected_x14);

uut.ITEM.mem[37]= 32'h00c00013; //addi x0,x0,12
uut.ITEM.mem[38]= 32'h00070463; // beq  x14,x0,8
uut.ITEM.mem[39]= 32'h00a28293; //addi x5,x5,10
uut.ITEM.mem[40]= 32'h00032223; //sw   x0,4(x6)
expected_x10=32'd0;
expected_x5=32'd70;
expected_x6=32'd20;
expected_x7=32'd30;
expected_mem0=32'd30;
expected_x8=32'd30;
expected_x9=32'd0;
expected_x1=32'd40;
expected_x11=32'd87;
expected_x12=-12;
expected_x13=-5;
expected_x14=32'd0;
expected_x0=32'b0;
expected_mem6=32'b0;
repeat(3) begin
    @(posedge clk);
    #1;
end
if (uut.REGISTERS.regs[10] == expected_x10)
  $display("PASS: x10 = %0d", uut.REGISTERS.regs[10]);
else
  $display("FAIL: x10 = %0d, expected %0d", uut.REGISTERS.regs[10], expected_x10);

if (uut.REGISTERS.regs[5] == expected_x5)
  $display("PASS: x5 = %0d", uut.REGISTERS.regs[5]);
else
  $display("FAIL: x5 = %0d, expected %0d", uut.REGISTERS.regs[5], expected_x5);

if (uut.REGISTERS.regs[6] == expected_x6)
  $display("PASS: x6 = %0d", uut.REGISTERS.regs[6]);
else
  $display("FAIL: x6 = %0d, expected %0d", uut.REGISTERS.regs[6], expected_x6);

if (uut.REGISTERS.regs[7] == expected_x7)
  $display("PASS: x7 = %0d", uut.REGISTERS.regs[7]);
else
  $display("FAIL: x7 = %0d, expected %0d", uut.REGISTERS.regs[7], expected_x7);

if (uut.DM0.mem[0] == expected_mem0)
  $display("PASS: mem0 = %0d", uut.DM0.mem[0]);
else
  $display("FAIL: mem0 = %0d, expected %0d", uut.DM0.mem[0], expected_mem0);

if (uut.REGISTERS.regs[8] == expected_x8)
  $display("PASS: x8 = %0d", uut.REGISTERS.regs[8]);
else
  $display("FAIL: x8 = %0d, expected %0d", uut.REGISTERS.regs[8], expected_x8);

if (uut.REGISTERS.regs[9] == expected_x9)
  $display("PASS: x9 = %0d", uut.REGISTERS.regs[9]);
else
  $display("FAIL: x9 = %0d, expected %0d", uut.REGISTERS.regs[9], expected_x9);

if (uut.REGISTERS.regs[1] == expected_x1)
  $display("PASS: x1 = %0d", uut.REGISTERS.regs[1]);
else
  $display("FAIL: x1 = %0d, expected %0d", uut.REGISTERS.regs[1], expected_x1);

if (uut.REGISTERS.regs[11] == expected_x11)
  $display("PASS: x11 = %0d", uut.REGISTERS.regs[11]);
else
  $display("FAIL: x11 = %0d, expected %0d", uut.REGISTERS.regs[11], expected_x11);

if (uut.REGISTERS.regs[12] == expected_x12)
  $display("PASS: x12 = %0d",$signed(uut.REGISTERS.regs[12]));
else
  $display("FAIL: x12 = %0d, expected %0d", $signed(uut.REGISTERS.regs[12]), expected_x12);

if (uut.REGISTERS.regs[13] == expected_x13)
  $display("PASS: x13 = %0d", $signed(uut.REGISTERS.regs[13]));
else
  $display("FAIL: x13 = %0d, expected %0d",  $signed(uut.REGISTERS.regs[13]), expected_x13);

if (uut.REGISTERS.regs[14] == expected_x14)
  $display("PASS: x14 = %0d", uut.REGISTERS.regs[14]);
else
  $display("FAIL: x14 = %0d, expected %0d", uut.REGISTERS.regs[14], expected_x14);

if (uut.DM0.mem[6] == expected_mem6)
  $display("PASS: mem6 = %0d", uut.DM0.mem[6]);
else
  $display("FAIL: mem6 = %0d, expected %0d", uut.DM0.mem[6], expected_mem6);

if (uut.REGISTERS.regs[0] == expected_x0)
  $display("PASS: x0 = %0d", uut.REGISTERS.regs[0]);
else
  $display("FAIL: x0 = %0d, expected %0d", uut.REGISTERS.regs[0], expected_x0);

$finish;
end

endmodule
