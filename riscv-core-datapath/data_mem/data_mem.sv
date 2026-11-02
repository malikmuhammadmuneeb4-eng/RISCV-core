module data_mem(
  input logic clk, mem_write, reset,
  input logic [31:0] addr,
  input logic [31:0] write_data,
  output logic [31:0] read_data
);
  logic [31:0] mem [255:0];
  integer i;
  always_ff @(posedge clk) begin
    if (reset) begin
      for (i = 0; i < 256; i = i + 1)
        mem[i] <= 32'b0;
    end
    else if (mem_write)
      mem[addr[9:2]] <= write_data;
  end
  always_comb begin
    read_data = mem[addr[9:2]];
  end
endmodule
