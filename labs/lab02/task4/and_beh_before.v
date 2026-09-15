// and_beh_before.v
// Behavioral, delay placed BEFORE the assignment.
module and_beh_before(
  input  a,
  input  b,
  output reg y
);
  always @(*) begin
    #3 y = a & b;
  end
endmodule