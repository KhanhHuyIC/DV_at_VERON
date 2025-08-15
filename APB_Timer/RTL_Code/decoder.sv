module decoder #(
  parameter N = 2                  // Width of input
) (
  input  logic [N-1:0]      in ,    // N-bit input
  input  logic              en ,    // Enable
  output logic [(1<<N)-1:0] out     // 2^N-bit output
);

  always_comb begin
    out = '0;  // default all outputs low
    if (en) begin
      out[in] = 1'b1;
    end
  end

endmodule : decoder
