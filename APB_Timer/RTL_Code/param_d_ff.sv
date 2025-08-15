module param_d_ff #(
  parameter int    DATA_WIDTH = 32                ,
  parameter logic [DATA_WIDTH-1:0] SET_VALUE  = '1  // Optional parameter to set initial value on reset
)(
  input  logic                     i_clk  ,  // Clock input (positive edge triggered)
  input  logic                     i_rst_n,  // Asynchronous active-low reset
  input  logic                     i_en   ,  // Enable signal to allow updating the register
  input  logic [DATA_WIDTH - 1: 0] d      ,  // Data input
  output logic [DATA_WIDTH - 1: 0] q         // Data output (registered value)
);

  always_ff @(posedge i_clk or negedge i_rst_n) begin : param_d_ff_seq
    if(!i_rst_n) begin
      q <= SET_VALUE;  // Clear output on reset
    end else begin
      if(i_en) begin
        q <= d;        // Load input data when enabled
      end else begin
        q <= q;        // Hold previous value when not enabled
      end
    end
  end

endmodule : param_d_ff
