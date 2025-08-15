module clock_select (
  input  logic       i_rst_n        ,
  input  logic       i_clk          ,

  // Prescaled clock inputs
  input  logic       i_clk_phi_2    ,
  input  logic       i_clk_phi_8    ,
  input  logic       i_clk_phi_32   ,
  input  logic       i_clk_phi_64   ,
  input  logic       i_clk_phi_1024 ,
  input  logic       i_clk_phi_8192 ,

  // External and cascaded clock signals
  input  logic       i_TMCI0        ,     // External signal input TMR0
  input  logic       i_TMCI1        ,     // External signal input TMR1
  input  logic       i_overflow1    ,     // Cascaded TCNT signal (e.g., overflow/compare)
  input  logic       i_comp_match_A0,     // Cascaded TCNT signal (e.g., overflow/compare)

  // Select lines
  input  logic [2:0] i_cks_0        ,     // Clock Source Select TMR0
  input  logic [1:0] i_icks_0       ,     // Internal Clock Edge Select TMR0
  input  logic [2:0] i_cks_1        ,     // Clock Source Select TMR1
  input  logic [1:0] i_icks_1       ,     // Internal Clock Edge Select TMR1
  output logic       o_TCNT_EN_0    ,     // Output Enable Pulse for Channel 0
  output logic       o_TCNT_EN_1           // Output Enable Pulse for Channel 1
);

  logic comp_match_A0_final;

  clk_sel_channel clk_sel_channel0 (
    .i_rst_n          (i_rst_n       ),
    .i_clk            (i_clk         ),
    .i_clk_phi_2      (i_clk_phi_2   ),
    .i_clk_phi_8      (i_clk_phi_8   ),
    .i_clk_phi_32     (i_clk_phi_32  ),
    .i_clk_phi_64     (i_clk_phi_64  ),
    .i_clk_phi_1024   (i_clk_phi_1024),
    .i_clk_phi_8192   (i_clk_phi_8192),
    .i_TMCI           (i_TMCI0       ),
    .i_cascaded_signal(i_overflow1   ),
    .i_cks            (i_cks_0       ),
    .i_icks           (i_icks_0      ),
    .o_TCNT_EN        (o_TCNT_EN_0   )
  );

  // Posedge detect for Compare match A0
  pos_det_mode16 posedge_detector_CMFA_0(
    .i_rst_n         (i_rst_n            ),   
    .i_clk           (i_clk              ),   
    .i_sig_in        (i_comp_match_A0    ),   
    .o_posedge_detect(comp_match_A0_final)    
  );

  clk_sel_channel clk_sel_channel1 (
    .i_rst_n          (i_rst_n            ),
    .i_clk            (i_clk              ),
    .i_clk_phi_2      (i_clk_phi_2        ),
    .i_clk_phi_8      (i_clk_phi_8        ),
    .i_clk_phi_32     (i_clk_phi_32       ),
    .i_clk_phi_64     (i_clk_phi_64       ),
    .i_clk_phi_1024   (i_clk_phi_1024     ),
    .i_clk_phi_8192   (i_clk_phi_8192     ),
    .i_TMCI           (i_TMCI1            ),
    .i_cascaded_signal(comp_match_A0_final),
    .i_cks            (i_cks_1            ),
    .i_icks           (i_icks_1           ),
    .o_TCNT_EN        (o_TCNT_EN_1        )
  );

endmodule : clock_select
