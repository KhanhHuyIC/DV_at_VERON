module TCNT (
  input  logic       i_clk_sys    ,  // clock system
  input  logic       i_rst_n      ,  // negedge rst
  input  logic       i_clr        ,  // clear by stop module
  input  logic       i_wren       ,  // signal to switch between data form bus or counter
  input  logic       counter_clock,  // signal to enable to counter up 
  input  logic [7:0] i_datain     ,  // data load to register
  output logic       o_OVF        ,  // overflow flag 
  output logic [7:0] o_count   
);

  //internal signal declare
  logic [7:0] counter_temp;
  logic [7:0] to_FF       ;
  logic [7:0] pre_overflow;

  //data to flipflop
  assign counter_temp = (counter_clock) ? o_count + 1'b1 : o_count          ;
  assign to_FF        = (i_clr) ? 8'h00 : (i_wren)?  i_datain : counter_temp;

  //flipflop
  param_d_ff #(
    .DATA_WIDTH(8),
    .SET_VALUE('0)
  ) reg_count (
    .i_clk  (i_clk_sys),
    .i_rst_n(i_rst_n  ),
    .i_en   (1'b1     ),
    .d      (to_FF    ),
    .q      (o_count  )
  );

  //overflow flag
  assign o_OVF = (&pre_overflow) & (~|o_count);

  param_d_ff #(
    .DATA_WIDTH(8),
    .SET_VALUE('0)
  ) reg_overflow (
    .i_clk   (i_clk_sys   ),
    .i_rst_n (i_rst_n     ),
    .i_en    (1'b1        ),
    .d       (o_count     ),
    .q       (pre_overflow)
  );

endmodule: TCNT
