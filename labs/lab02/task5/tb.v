// tb.v
// Self-checking testbench for alu.v

module tb;

  reg  [3:0] t_a, t_b;
  reg        t_op;
  wire [3:0] t_result;

  integer errors;
  integer total;
  reg [3:0] exp_result;

  alu DUT (
    .a      (t_a),
    .b      (t_b),
    .op     (t_op),
    .result (t_result)
  );

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, tb);
    end
  end

  task check;
    begin
      total = total + 1;
      exp_result = t_op ? (t_a - t_b) : (t_a + t_b);
      #1; // let the DUT settle before checking
      if (t_result !== exp_result) begin
        $display("FAIL at t=%0t: a=%b b=%b op=%b -> got result=%b, expected=%b",
                  $time, t_a, t_b, t_op, t_result, exp_result);
        errors = errors + 1;
      end else begin
        $display("PASS at t=%0t: a=%b b=%b op=%b -> result=%b",
                  $time, t_a, t_b, t_op, t_result);
      end
    end
  endtask

  initial begin
    errors = 0;
    total  = 0;

    // 1) Same operand pair, switch op -- exposes sensitivity-list bug
    t_a = 4'd5; t_b = 4'd3; t_op = 0; #5 check;
    t_op = 1;               #5 check;
    t_op = 0;               #5 check;

    // 2) Subtraction with a few different operand pairs -- exposes
    //    the blocking/non-blocking bug
    t_a = 4'd9; t_b = 4'd4; t_op = 1; #5 check;
    t_a = 4'd7; t_b = 4'd7; t_op = 1; #5 check;
    t_a = 4'd2; t_b = 4'd6; t_op = 1; #5 check;

    // 3) Addition and subtraction with changing operands
    t_a = 4'd1; t_b = 4'd1; t_op = 0; #5 check;
    t_a = 4'd8; t_b = 4'd2; t_op = 0; #5 check;
    t_a = 4'd3; t_b = 4'd9; t_op = 1; #5 check;

    $display("%0d / %0d tests passed", total - errors, total);
    $finish;
  end

endmodule