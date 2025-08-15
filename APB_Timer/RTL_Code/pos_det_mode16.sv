module pos_det_mode16(
  input  logic i_rst_n         ,   // Active-low reset
  input  logic i_clk           ,   // System clock
  input  logic i_sig_in        ,   // Input signal to detect rising edge on
  output logic o_posedge_detect    // Output: High for 1 cycle on rising edge of i_sig_in
);

  // Internal signals for edge detection
  logic tempQ1     ;                 // First stage: stores i_sig_in
  // logic rising_temp;                 // Holds result of rising edge detection

  // Detect rising edge of i_sig_in: (Q1 high && Q2 low)
  // assign rising_temp = i_sig_in & (!tempQ1);
  assign o_posedge_detect = i_sig_in & (!tempQ1);

  // First flip-flop: captures i_sig_in on i_clk
  param_d_ff # ( 
    .DATA_WIDTH(1),
    .SET_VALUE('0)  
  ) reg_hold_Q1 (
    .i_clk   (i_clk   ),
    .i_rst_n (i_rst_n ),
    .i_en    (1'b1    ),
    .d       (i_sig_in),
    .q       (tempQ1  )
  );

  // // Second flip-flop: output one-cycle pulse if rising edge detected
  // param_d_ff # ( 
  //   .DATA_WIDTH(1),
  //   .SET_VALUE('0)
  // ) reg_delay_Q3 (
  //   .i_clk   (i_clk           ),
  //   .i_rst_n (i_rst_n         ),
  //   .i_en    (1'b1            ),
  //   .d       (rising_temp     ),
  //   .q       (o_posedge_detect)
  // );

endmodule : pos_det_mode16
