module control_logic(
  //---------------------------------------------------------//
  //                INPUT DECLARATION FIELD                  //
  //---------------------------------------------------------//
  // Global input 
  input  logic       i_clk                   ,
  input  logic       i_rst_n                 ,
  // TMR 1 input declaration
  input  logic [7:0] TCORA_1                 ,
  input  logic [7:0] TCORB_1                 ,
  input  logic       Compare_match_A1        ,
  input  logic       Compare_match_B1        ,
  input  logic       i_os0_1                 ,
  input  logic       i_os1_1                 ,
  input  logic       i_os2_1                 ,
  input  logic       i_os3_1                 ,
  // TMR0 input declaration
  input  logic [7:0] TCORA_0                 ,
  input  logic [7:0] TCORB_0                 ,
  input  logic       Compare_match_A0        ,
  input  logic       Compare_match_B0        ,
  input  logic       i_os0_0                 ,
  input  logic       i_os1_0                 ,
  input  logic       i_os2_0                 ,
  input  logic       i_os3_0                 ,
  // 16-bit mode enable input
  input  logic       i_cks0_0                ,
  input  logic       i_cks1_0                ,
  input  logic       i_cks2_0                ,
  // Clear TCNT_1 control signal input
  input  logic       i_counter_clock_1       ,
  input  logic       i_tmris_1               ,
  input  logic       i_cclr0_1               ,
  input  logic       i_cclr1_1               ,
  input  logic       TMRI_1                  ,
  // Clear TCNT_0 control signal input
  input  logic       i_counter_clock_0       ,
  input  logic       i_tmris_0               ,
  input  logic       i_cclr0_0               ,
  input  logic       i_cclr1_0               ,
  input  logic       TMRI_0                  ,
  // Interrupt control signal input
  input  logic       i_cmfa_0                ,
  input  logic       i_cmfb_0                ,
  input  logic       i_ovf_0                 ,
  input  logic       i_cmfa_1                ,
  input  logic       i_cmfb_1                ,
  input  logic       i_ovf_1                 ,
  input  logic       i_cmiea_0               ,
  input  logic       i_cmieb_0               ,
  input  logic       i_ovie_0                ,
  input  logic       i_cmiea_1               ,
  input  logic       i_cmieb_1               ,
  input  logic       i_ovie_1                ,
  // ADC control input request signal 
  input  logic       i_adte                  ,
  //---------------------------------------------------------//
  //               OUTPUT DECLARATION FIELD                  //
  //---------------------------------------------------------//
  // Compare match TMR_0 output signal
  output logic       o_compare_match_A0_final,
  output logic       o_compare_match_B0_final,
  // Timer output signal 
  output logic       TMO_1                   ,
  output logic       TMO_0                   ,
  // TCTN output control clear sigal
  output logic       o_clr_tcnt_0            ,
  output logic       o_clr_tcnt_1            ,
  // Interrupt output signal
  output logic       CMIA0                   ,
  output logic       CMIB0                   ,
  output logic       OVI0                    ,
  output logic       CMIA1                   ,
  output logic       CMIB1                   ,
  output logic       OVI1                    ,
  // ADC output request signal
  output logic       o_adc_request
);

  //---------------------------------------------------------//
  //            INTERIM LOGIC DECLARATION FIELD              //
  //---------------------------------------------------------//
  // 16-bit mode interim logic
  logic mode_16_en            ;
  logic cmfa_m16              ;
  logic cmfb_m16              ;
  // TMO_0 interim logic
  logic compare_match_A0_final;
  logic compare_match_B0_final;
  logic mux_A_0_res           ;
  logic mux_B_0_res           ;
  logic pri_mux_sel0_0        ;
  logic pri_mux_sel0_1        ;
  logic pri_mux_0_res         ;
  logic tmo_0_dff_en          ;
  logic tmo_0_final           ;
  // TMO_1 interim logic
  logic mux_A_1_res           ;
  logic mux_B_1_res           ;
  logic pri_mux_sel1_0        ;
  logic pri_mux_sel1_1        ;
  logic pri_mux_1_res         ;
  logic tmo_1_final           ;
  // Clear TNCT_0 interim logic
  logic clr_tcnt_0_temp       ;
  logic pos_det_0             ;
  logic neg_det_0             ;
  logic both_det_0            ;
  logic high_det_0            ;
  logic low_det_0             ;
  logic compare_pri_a_b_out   ;
  // Clear TNCT_1 interim logic
  logic clr_tcnt_1_temp       ;
  logic pos_det_1             ;
  logic neg_det_1             ;
  logic both_det_1            ;
  logic high_det_1            ;
  logic low_det_1             ;

  //---------------------------------------------------------//
  //      16-bit MODE ENABLE COMBINATIONAL LOGICS FIELD      //
  //---------------------------------------------------------//
  // 16-bit mode enable
  assign mode_16_en = i_cks2_0 & (!i_cks1_0) & (!i_cks0_0);
  assign cmfa_m16   = Compare_match_A0 & Compare_match_A1 ;
  assign cmfb_m16   = Compare_match_B0 & Compare_match_B1 ;

  // Mux for choosing the final Compare_Match_A0 signal between 2 different modes
  param_mux #(
    .NUM_INPUTS(2),
    .SEL_WIDTH (1)
  ) Compare_match_A0_select_mux (
    // .in  ({Compare_match_A0, cmfa_m16}),
    .in  ({cmfa_m16, Compare_match_A0}),
    .sel (mode_16_en                  ),
    .y   (compare_match_A0_final      )
  );
  assign o_compare_match_A0_final = compare_match_A0_final;

  // Mux for choosing the final Compare_Match_B0 signal between 2 different modes
  param_mux #(
    .NUM_INPUTS(2),
    .SEL_WIDTH (1)
  ) Compare_match_B0_select_mux (
    // .in  ({Compare_match_B0, cmfb_m16}),
    .in  ({cmfb_m16, Compare_match_B0}),
    .sel (mode_16_en                  ),
    .y   (compare_match_B0_final      )
  );
  assign o_compare_match_B0_final = compare_match_B0_final;

  //---------------------------------------------------------//
  //               TIMER_0 OUTPUT SINGAL FIELD               //
  //---------------------------------------------------------//
  // Mux A for choosing TMO_0
  param_mux #(
    .NUM_INPUTS(4),
    .SEL_WIDTH (2)
  ) mux_A_0 (
    // .in  ({TMO_0, 1'b0, 1'b1, !TMO_0}),
    .in  ({!TMO_0, 1'b1, 1'b0, TMO_0}),
    .sel ({i_os1_0, i_os0_0         }),
    .y   (mux_A_0_res                )
  );

  // Mux B for choosing TMO_0
  param_mux #(
    .NUM_INPUTS(4),
    .SEL_WIDTH (2)
  ) mux_B_0 (
    .in  ({!TMO_0, 1'b1, 1'b0, TMO_0}),
    .sel ({i_os3_0, i_os2_0         }),
    .y   (mux_B_0_res                )
  );

  // Priority Encoder for TMO_0
  priority_encoder priority_encoder_0(
    .i_os0(i_os0_0       ),
    .i_os1(i_os1_0       ),
    .i_os2(i_os2_0       ),
    .i_os3(i_os3_0       ),
    .o_y0 (pri_mux_sel0_0),
    .o_y1 (pri_mux_sel0_1)
  );

  // Priority Mux for choosing TMO_0 when both compare matches toggle
  param_mux #(
    .NUM_INPUTS(4),
    .SEL_WIDTH (2)
  ) priority_mux_0 (
    .in  ({!TMO_0, 1'b1, 1'b0, TMO_0     }),  
    .sel ({pri_mux_sel0_1, pri_mux_sel0_0}),
    .y   (pri_mux_0_res                   )
  );

  // Final result Mux for choosing final TMO_0
  param_mux #(
    .NUM_INPUTS(4),
    .SEL_WIDTH (2)
  ) final_result_mux_tmo_0 (
    .in  ({pri_mux_0_res, mux_B_0_res, mux_A_0_res, TMO_0}),
    .sel ({compare_match_B0_final, compare_match_A0_final}),
    .y   (tmo_0_final                                     )
  );

  assign tmo_0_dff_en = i_counter_clock_0 | ((cmfa_m16 | cmfb_m16) & mode_16_en);
  // D_FF for TMO_0 output
  param_d_ff #(
    .DATA_WIDTH(1),
    .SET_VALUE('0)
  ) tmo_0_dff(
    .i_clk  (i_clk       ),
    .i_rst_n(i_rst_n     ),
    .i_en   (tmo_0_dff_en),
    .d      (tmo_0_final ),
    .q      (TMO_0       )   
  );

  //---------------------------------------------------------//
  //               TIMER_1 OUTPUT SINGAL FIELD               //
  //---------------------------------------------------------//
  // Mux A for choosing TMO_1
  param_mux #(
    .NUM_INPUTS(4),
    .SEL_WIDTH (2)
  ) mux_A_1 (
    .in  ({!TMO_1, 1'b1, 1'b0, TMO_1}),
    .sel ({i_os1_1, i_os0_1         }),
    .y   (mux_A_1_res                )
  );

  // Mux B for choosing TMO_1
  param_mux #(
    .NUM_INPUTS(4),
    .SEL_WIDTH (2)
  ) mux_B_1 (
    .in  ({!TMO_1, 1'b1, 1'b0, TMO_1}),
    .sel ({i_os3_1, i_os2_1         }),
    .y   (mux_B_1_res                )
  );

  // Priority Encoder for TMO_1
  priority_encoder priority_encoder_1(
    .i_os0(i_os0_1       ),
    .i_os1(i_os1_1       ),
    .i_os2(i_os2_1       ),
    .i_os3(i_os3_1       ),
    .o_y0 (pri_mux_sel1_0),
    .o_y1 (pri_mux_sel1_1)
  );

  // Priority Mux for choosing TMO_1 when both compare matches toggle
  param_mux #(
    .NUM_INPUTS(4),
    .SEL_WIDTH (2)
  ) priority_mux_1 (
    .in  ({!TMO_1, 1'b1, 1'b0, TMO_1     }),
    .sel ({pri_mux_sel1_1, pri_mux_sel1_0}),
    .y   (pri_mux_1_res                   )
  );

  // Final result Mux for choosing final TMO_1
  param_mux #(
    .NUM_INPUTS(4),
    .SEL_WIDTH (2)
  ) final_result_mux_tmo_1 (
    .in  ({pri_mux_1_res, mux_B_1_res, mux_A_1_res, TMO_1}),
    .sel ({Compare_match_B1, Compare_match_A1            }),
    .y   (tmo_1_final                                     )
  );

  // D_FF for TMO_1 output
  param_d_ff #(
    .DATA_WIDTH(1) ,
    .SET_VALUE ('0)
  ) tmo_1_dff(
    .i_clk  (i_clk            ),
    .i_rst_n(i_rst_n          ),
    .i_en   (i_counter_clock_1),     
    .d      (tmo_1_final      ),
    .q      (TMO_1            )     
  );

  //---------------------------------------------------------//
  //                TIMER_0 CLEAR SINGAL FIELD               //
  //---------------------------------------------------------//
  // Posedge detect for TMR_0
  posedge_detector posedge_detector_TMR0(
    .i_rst_n         (i_rst_n  ),   
    .i_clk           (i_clk    ),   
    .i_sig_in        (TMRI_0   ),   
    .o_posedge_detect(pos_det_0)    
  );

  // Negedge detect for TMR_0
  negedge_detector negedge_detector_TMR0(
    .i_rst_n         (i_rst_n  ),   
    .i_clk           (i_clk    ),   
    .i_sig_in        (TMRI_0   ),   
    .o_negedge_detect(neg_det_0)    
  );

  // Both edges detect for TMR_0
  assign both_det_0 = pos_det_0 | neg_det_0;

  // High level detect for TMR_0
  high_level_detector high_level_detector_TMR0(
    .i_rst_n      (i_rst_n   ),
    .i_clk        (i_clk     ),
    .i_sig_in     (TMRI_0    ),
    .o_high_detect(high_det_0)
  );

  // High level detect for TMR_0
  low_level_detector low_level_detector_TMR0(
    .i_rst_n     (i_rst_n  ),
    .i_clk       (i_clk    ),
    .i_sig_in    (TMRI_0   ),
    .o_low_detect(low_det_0)
  );

  // Mux for choosing clear condition for TCNT_0
  param_mux #(
    .NUM_INPUTS(8),
    .SEL_WIDTH (3)
  ) clear_tcnt_0_mux_temp (
    .in  ({high_det_0, low_det_0, neg_det_0, both_det_0, pos_det_0, Compare_match_B0, Compare_match_A0, 1'b0}),
    .sel ({i_tmris_0, i_cclr1_0 , i_cclr0_0                                                                 }),
    .y   (clr_tcnt_0_temp                                                                                    )
  );

  assign clear_tcnt_0_mux_sel = (mode_16_en & (!i_tmris_0)) & (i_cclr0_0 ^ i_cclr1_0);

  comparator priority_a_or_b_tcor(
    .i_tcora_0   (TCORA_0            ), // TCORA_0 value
    .i_tcora_1   (TCORA_1            ), // TCORA_1 value
    .i_tcorb_0   (TCORB_0            ), // TCORB_0 value
    .i_tcorb_1   (TCORB_1            ), // TCORB_1 value
    .o_final_comp(compare_pri_a_b_out)  // Compare result
  );

  param_mux #(
    .NUM_INPUTS(4),
    .SEL_WIDTH (2)
  ) clear_tcnt_0_mux (
    .in  ({cmfa_m16, cmfb_m16, clr_tcnt_0_temp, clr_tcnt_0_temp}),
    .sel ({clear_tcnt_0_mux_sel, compare_pri_a_b_out           }),
    .y   (o_clr_tcnt_0                                          )
  );

  //---------------------------------------------------------//
  //                TIMER_1 CLEAR SINGAL FIELD               //
  //---------------------------------------------------------//
  // Posedge detect for TMR_1
  posedge_detector posedge_detector_TMR1(
    .i_rst_n         (i_rst_n  ),   
    .i_clk           (i_clk    ),   
    .i_sig_in        (TMRI_1   ),   
    .o_posedge_detect(pos_det_1)    
  );

  // Negedge detect for TMR_1
  negedge_detector negedge_detector_TMR1(
    .i_rst_n         (i_rst_n  ),   
    .i_clk           (i_clk    ),   
    .i_sig_in        (TMRI_1   ),   
    .o_negedge_detect(neg_det_1)    
  );

  // Both edges detect for TMR_1
  assign both_det_1 = pos_det_1 | neg_det_1;

  // High level detect for TMR_1
  high_level_detector high_level_detector_TMR1(
    .i_rst_n      (i_rst_n   ),
    .i_clk        (i_clk     ),
    .i_sig_in     (TMRI_1    ),
    .o_high_detect(high_det_1)
  );

  // High level detect for TMR_1
  low_level_detector low_level_detector_TMR1(
    .i_rst_n     (i_rst_n  ),
    .i_clk       (i_clk    ),
    .i_sig_in    (TMRI_1   ),
    .o_low_detect(low_det_1)
  );

  // Mux for choosing clear condition for TCNT_1
  param_mux #(
    .NUM_INPUTS(8),
    .SEL_WIDTH (3)
  ) clear_tcnt_1_mux_temp (
    .in  ({high_det_1, low_det_1, neg_det_1, both_det_1, pos_det_1, Compare_match_B1, Compare_match_A1, 1'b0}),
    .sel ({i_tmris_1, i_cclr1_1 , i_cclr0_1                                                                 }),
    .y   (clr_tcnt_1_temp                                                                                    )
  );

  param_mux #(
    .NUM_INPUTS(2),
    .SEL_WIDTH (1)
  ) clear_tcnt_1_mux (
    .in  ({o_clr_tcnt_0, clr_tcnt_1_temp}),
    .sel (mode_16_en                     ),
    .y   (o_clr_tcnt_1                   )
  );

  //---------------------------------------------------------//
  //             INTERRUPT OUTPUT SINGAL FIELD               //
  //---------------------------------------------------------//
  assign CMIA0 = i_cmfa_0 & i_cmiea_0;
  assign CMIB0 = i_cmfb_0 & i_cmieb_0;
  assign OVI0  = i_ovf_0  & i_ovie_0 ;
  assign CMIA1 = i_cmfa_1 & i_cmiea_1;
  assign CMIB1 = i_cmfb_1 & i_cmieb_1;
  assign OVI1  = i_ovf_1  & i_ovie_1 ;

  //---------------------------------------------------------//
  //                ADC OUTPUT SINGAL FIELD                  //
  //---------------------------------------------------------//
  assign o_adc_request = i_adte & i_cmfa_0;

endmodule : control_logic
