module inst_memory(
  input logic [31:0] addr,
  output logic [31:0] instr
);
  logic [31:0] mem [255:0];
  always_comb begin
    instr = mem[addr[9:2]];
  end
endmodule
