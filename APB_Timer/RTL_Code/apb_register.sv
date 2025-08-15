module apb_register #(
  parameter WIDTH = 8  // Register width (default = 8 bits)
)(
  input  logic              clk  ,   // Clock signal
  input  logic              rst_n,   // Active-low asynchronous reset
  input  logic              en   ,   // Write enable
  input  logic [WIDTH-1:0]  d    ,   // Data input
  output logic [WIDTH-1:0]  q        // Data output
);

  // Register with asynchronous reset and write enable
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= '0;  // Reset register to 0
    end else if (en) begin
      q <= d ;  // Update register when enabled
    end
  end

endmodule : apb_register
