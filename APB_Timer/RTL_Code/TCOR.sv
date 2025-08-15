module TCOR (
  input  logic       i_clk_sys,  // clock system
  input  logic       i_rst_n  ,  // negedge rst
  input  logic       i_wren   ,
  input  logic [7:0] i_datain ,
  output logic [7:0] o_dataout
);

  param_d_ff #(
    .DATA_WIDTH(8   ),
    .SET_VALUE ('hFF)
  ) reg_store (
    .i_clk   (i_clk_sys),
    .i_rst_n (i_rst_n  ),
    .i_en    (i_wren   ),
    .d       (i_datain ),
    .q       (o_dataout)
  );

endmodule: TCOR
