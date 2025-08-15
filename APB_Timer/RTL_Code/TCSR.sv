module TCSR (
  input  logic       i_clk_sys ,  // clock system
  input  logic       i_rst_n   ,  // negedge rst
  input  logic       i_wren    ,
  input  logic       i_overflow,  // from control unit
  input  logic       i_CMA     ,  // compare match A signal
  input  logic       i_CMB     ,  // compare match B signal
  input  logic       i_DISEL_n ,  // bit DISEL from DTC (active 0)
  input  logic       i_DTC_A   ,  // signal from DTC that active when DTC toggle by CMIA of timer_0
  input  logic       i_DTC_B   ,  // signal from DTC that active when DTC toggle by CMIB of timer_0
  input  logic [7:0] i_datain  ,  // data from bus
  output logic [7:0] o_dataout        
);

  // internal signal declaration
  logic       CMFB_i   ; 
  logic       CMFA_i   ;
  logic       OVF_i    ; 
  logic       MUX_sel_1; 
  logic       MUX_sel_2;
  logic [3:0] OS_i     ;

  // internal logic
  assign OS_i       = i_datain[3:0]                                              ;
  assign MUX_sel_1  = !(i_DISEL_n | i_DTC_A) & !(i_datain[6] & i_wren)           ;
  assign MUX_sel_2  = !(i_DISEL_n | i_DTC_B) & !(i_datain[7] & i_wren)           ;
  assign OVF_i      = (~(i_datain[5]&i_wren))? (o_dataout[5] | i_overflow) : 1'b0;
  assign CMFA_i     = (MUX_sel_1)?   (o_dataout[6] | i_CMA)      : 1'b0          ;
  assign CMFB_i     = (MUX_sel_2)?   (o_dataout[7] | i_CMB)      : 1'b0          ;   

  //register declaration
  param_d_ff #(
    .DATA_WIDTH(1 ),
    .SET_VALUE ('0)
  ) reg_OS_0 (
    .i_clk   (i_clk_sys   ),
    .i_rst_n (i_rst_n     ),
    .i_en    (i_wren      ),
    .d       (OS_i[0]     ),
    .q       (o_dataout[0])
  );

  param_d_ff #(
    .DATA_WIDTH(1 ),
    .SET_VALUE ('0)
  ) reg_OS_1 (
    .i_clk   (i_clk_sys   ),
    .i_rst_n (i_rst_n     ),
    .i_en    (i_wren      ),
    .d       (OS_i[1]     ),
    .q       (o_dataout[1])
  );

  param_d_ff #(
    .DATA_WIDTH(1 ),
    .SET_VALUE ('0)
  ) reg_OS_2 (
    .i_clk   (i_clk_sys   ),
    .i_rst_n (i_rst_n     ),
    .i_en    (i_wren      ),
    .d       (OS_i[2]     ),
    .q       (o_dataout[2] )
  );

  param_d_ff #(
    .DATA_WIDTH(1 ),
    .SET_VALUE ('0)
  ) reg_OS_3 (
    .i_clk   (i_clk_sys   ),
    .i_rst_n (i_rst_n     ),
    .i_en    (i_wren      ),
    .d       (OS_i[3]     ),
    .q       (o_dataout[3])
  );

  param_d_ff #(
    .DATA_WIDTH(1 ),
    .SET_VALUE ('0)
  ) reg_ATDE (
    .i_clk   (i_clk_sys   ),
    .i_rst_n (i_rst_n     ),
    .i_en    (i_wren      ),
    .d       (i_datain[4] ),
    .q       (o_dataout[4])
  );

  param_d_ff #(
    .DATA_WIDTH(1 ),
    .SET_VALUE ('0)
  ) reg_OVF (
    .i_clk   (i_clk_sys   ),
    .i_rst_n (i_rst_n     ),
    .i_en    (1'b1        ),
    .d       (OVF_i       ),
    .q       (o_dataout[5])
  );

  param_d_ff #(
    .DATA_WIDTH(1 ),
    .SET_VALUE ('0)
  ) reg_CMFA (
    .i_clk   (i_clk_sys   ),
    .i_rst_n (i_rst_n     ),
    .i_en    (1'b1        ),
    .d       (CMFA_i      ),
    .q       (o_dataout[6])
  );

  param_d_ff #(
    .DATA_WIDTH(1 ),
    .SET_VALUE ('0)
  ) reg_CMFB (
    .i_clk   (i_clk_sys   ),
    .i_rst_n (i_rst_n     ),
    .i_en    (1'b1        ),
    .d       (CMFB_i      ),
    .q       (o_dataout[7])
  );


endmodule: TCSR
