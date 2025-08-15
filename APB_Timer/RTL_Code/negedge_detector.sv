module negedge_detector (
  input  logic i_rst_n         ,   // Active-low reset
  input  logic i_clk           ,   // System clock
  input  logic i_sig_in        ,   // Input signal to detect falling edge on
  output logic o_negedge_detect    // Output: Low for 1 cycle on falling edge of i_sig_in
);

  // Internal signals for edge detection
  logic tempQ1      ;                 // First stage: stores i_sig_in
  logic tempQ2      ;                 // Second stage: delayed tempQ1
  logic falling_temp;                 // Holds result of falling edge detection

  // Detect falling edge of i_sig_in: (Q1 low && Q2 high)
  assign falling_temp = (!tempQ1) & tempQ2;

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

  // Third flip-flop: output one-cycle pulse if falling edge detected
  param_d_ff # ( 
    .DATA_WIDTH(1),
    .SET_VALUE('0)
  ) reg_delay_Q3 (
    .i_clk   (i_clk           ),
    .i_rst_n (i_rst_n         ),
    .i_en    (1'b1            ),
    .d       (falling_temp    ),
    .q       (o_negedge_detect)
  );

endmodule : negedge_detector
