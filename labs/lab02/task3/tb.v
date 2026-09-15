// tb.v
// Self-checking testbench for comp2.
// Applies all 16 combinations of A, B and checks:
//   1) Exactly one of GT, LT, EQ is 1 at all times.
//   2) The asserted signal matches the actual relationship between A and B.

module tb;

  reg  [1:0] t_a, t_b;
  wire       t_gt, t_lt, t_eq;

  integer errors;

  comp2 DUT (
    .A  (t_a),
    .B  (t_b),
    .GT (t_gt),
    .LT (t_lt),
    .EQ (t_eq)
  );

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  task check;
    reg expected_gt, expected_lt, expected_eq;
    reg one_hot_ok, value_ok;
    begin
      expected_gt = (t_a >  t_b);
      expected_lt = (t_a <  t_b);
      expected_eq = (t_a == t_b);

      one_hot_ok = (t_gt + t_lt + t_eq) == 1;
      value_ok   = (t_gt == expected_gt) &&
                   (t_lt == expected_lt) &&
                   (t_eq == expected_eq);

      if (!one_hot_ok) begin
        $display("FAIL at t=%0t: A=%b B=%b -> GT=%b LT=%b EQ=%b (not one-hot!)",
                  $time, t_a, t_b, t_gt, t_lt, t_eq);
        errors = errors + 1;
      end
      else if (!value_ok) begin
        $display("FAIL at t=%0t: A=%b B=%b -> GT=%b LT=%b EQ=%b (expected GT=%b LT=%b EQ=%b)",
                  $time, t_a, t_b, t_gt, t_lt, t_eq, expected_gt, expected_lt, expected_eq);
        errors = errors + 1;
      end
    end
  endtask

  integer i, j;
  initial begin
    errors = 0;
    for (i = 0; i < 4; i = i + 1) begin
      for (j = 0; j < 4; j = j + 1) begin
        t_a = i;
        t_b = j;
        #5 check;
      end
    end

    if (errors == 0)
      $display("ALL TESTS PASSED");
    else
      $display("%0d TEST(S) FAILED", errors);

    $finish;
  end

  initial
    $monitor($time, " A=%b B=%b | GT=%b LT=%b EQ=%b", t_a, t_b, t_gt, t_lt, t_eq);

endmodule