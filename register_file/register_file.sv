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
