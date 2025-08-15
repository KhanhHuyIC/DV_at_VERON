module TCCR (
  input  logic        i_clk_sys ,  // clock system
  input  logic        i_rst_n   ,  // negedge rst
  input  logic        i_wren    ,
  input  logic [2:0]  i_datain  ,
  output logic [7:0]  o_dataout       
);

  logic [7:0] data_i_TCCR;
  assign data_i_TCCR = {{4{1'b0}}, i_datain[2], 1'b0, i_datain[1:0]};

  param_d_ff #(
    .DATA_WIDTH(8),
    .SET_VALUE('0)
  ) reg_store (
    .i_clk   (i_clk_sys   ),
    .i_rst_n (i_rst_n     ),
    .i_en    (i_wren      ),
    .d       (data_i_TCCR ),
    .q       (o_dataout   )
  );

endmodule: TCCR
