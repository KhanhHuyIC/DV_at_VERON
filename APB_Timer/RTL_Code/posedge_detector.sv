module posedge_detector(
  input  logic i_rst_n         ,   // Active-low reset
  input  logic i_clk           ,   // System clock
  input  logic i_sig_in        ,   // Input signal to detect rising edge on
  output logic o_posedge_detect    // Output: High for 1 cycle on rising edge of i_sig_in
);

  // Internal signals for edge detection
  logic tempQ1     ;                 // First stage: stores i_sig_in
  logic tempQ2     ;                 // Second stage: delayed tempQ1
  logic rising_temp;                 // Holds result of rising edge detection

  // Detect rising edge of i_sig_in: (Q1 high && Q2 low)
  assign rising_temp = tempQ1 & (!tempQ2);

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

  // Second flip-flop: delays tempQ1 to compare with Q1
  param_d_ff # ( 
    .DATA_WIDTH(1),
    .SET_VALUE('0)
  ) reg_main_Q2 (
    .i_clk   (i_clk  ),
    .i_rst_n (i_rst_n),
    .i_en    (1'b1   ),
    .d       (tempQ1 ),
    .q       (tempQ2 )
  );

  // Third flip-flop: output one-cycle pulse if rising edge detected
  param_d_ff # ( 
    .DATA_WIDTH(1),
    .SET_VALUE('0)
  ) reg_delay_Q3 (
    .i_clk   (i_clk           ),
    .i_rst_n (i_rst_n         ),
    .i_en    (1'b1            ),
    .d       (rising_temp     ),
    .q       (o_posedge_detect)
  );

endmodule : posedge_detector
