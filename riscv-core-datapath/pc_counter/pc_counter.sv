module pc_counter(
  input logic clk, reset,
  input logic [31:0] next_pc,
  output logic [31:0] pc
);
  always_ff @(posedge clk)
  begin
    if (reset==1) pc <= 32'b0;
    else pc <= next_pc;
  end
endmodule
