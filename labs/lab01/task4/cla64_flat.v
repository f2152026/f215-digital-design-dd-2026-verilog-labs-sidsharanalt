// cla64_flat.v
// A flat, unblocked 64-bit carry-lookahead adder: every carry is computed
// directly (two-level, no rippling), exactly like cla4.v, just scaled to
// 64 bits. Add delays throughout (same convention as cla4.v) so it can be
// fairly compared against rca64.v and cla64_blocked.v.

module cla64_flat(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  wire [63:0] p, g;
  wire [64:1] c;   // c[1]..c[64] are the 64 carries; think of cin as c[0]

  // ---------------------------------------------------------------------
  // Step 1: generate/propagate signals -- WORKED EXAMPLE
  //
  // This part is genuinely uniform across all 64 bits (same operation at
  // every position), so a generate-for loop is the right tool here.
  // `genvar` is a compile-time-only loop variable -- it does not exist as
  // a real signal in the final circuit, it just controls how many times
  // the loop body is elaborated.
  // ---------------------------------------------------------------------
  genvar i;
  generate
    for (i = 0; i < 64; i = i + 1) begin : gen_pg
      xor #(2) (p[i], a[i], b[i]);
      and #(2) (g[i], a[i], b[i]);
    end
  endgenerate

    genvar k, j;
  generate
    for (k = 1; k <= 64; k = k + 1) begin : gen_carry
      wire [k:0] terms;
      for (j = 0; j < k; j = j + 1) begin : gen_term
        if (j == k-1)
          assign terms[j] = g[j];
        else
          assign terms[j] = (&p[k-1:j+1]) & g[j];
      end
      assign terms[k] = (&p[k-1:0]) & cin;
      assign #(2) c[k] = |terms;
    end
  endgenerate

  assign cout = c[64];

  // Step 3: sum bits
  assign #(2) sum = p ^ {c[63:1], cin};

endmodule


