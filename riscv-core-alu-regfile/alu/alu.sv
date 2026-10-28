module alu (
  input  logic [31:0] a,        // operand 1
  input  logic [31:0] b,        // operand 2
  input  logic [3:0]  alu_op,   // operation selector
  output logic [31:0] result    // output
);

  always_comb begin
    case (alu_op)
      4'b0000: result = a + b;                                   // ADD
      4'b0001: result = a - b;                                   // SUB
      4'b0010: result = a & b;                                   // AND
      4'b0011: result = a | b;                                   // OR
      4'b0100: result = a ^ b;                                   // XOR
      4'b0101: result = a << b[4:0];                             // SLL (shift left logical)
      4'b0110: result = a >> b[4:0];                             // SRL (shift right logical)
      4'b0111: result = ($signed(a) < $signed(b)) ? 1'b1 : 1'b0; // SLT (set less than, signed)
      4'b1000: result = $signed(a) >>> b[4:0];                   // SRA (shift right arithmetic)
      4'b1001: result = (a < b) ? 1'b1 : 1'b0;                   // BLTU (Branch if Less Than, Unsigned)
      4'b1010: result = b;                                       // Pass_b
      default: result = 32'b0;
    endcase
  end

endmodule
