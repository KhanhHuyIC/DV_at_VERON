module timer_top(
  //---------------------------------------------------------//
  //                INPUT DECLARATION FIELD                  //
  //---------------------------------------------------------//
  // Global signals
  input  logic       i_clk_sys           ,
  input  logic       i_rst_n             ,

  // Clock select input signals
  input  logic       i_clk_phi_2         ,
  input  logic       i_clk_phi_8         ,
  input  logic       i_clk_phi_32        ,
  input  logic       i_clk_phi_64        ,
  input  logic       i_clk_phi_1024      ,
  input  logic       i_clk_phi_8192      ,
  input  logic       i_TMCI0             , // External signal input TMR0
  input  logic       i_TMCI1             , // External signal input TMR1

  // Control logic input signals
  input  logic       i_TMRI_0            , // External signal input TMRI0
  input  logic       i_TMRI_1            , // External signal input TMRI1 
  
  // Timer register input signals
  input  logic       i_wren              , // Write Enable
  input  logic [7:0] i_addr              , // Address
  input  logic [7:0] i_datain            , // Data Input
  input  logic       i_DISEL_n           , // DTC Disable
  input  logic       i_DTC_A             , // DTC A
  input  logic       i_DTC_B             , // DTC B

  // Timer output signals
  output logic       o_TMO_0              , // Timer Output Channel 0
  output logic       o_TMO_1              , // Timer Output Channel 1

  // Timer interrupt output signals
  output logic       o_CMIA0              , // Compare Match A Channel 0
  output logic       o_CMIB0              , // Compare Match B Channel 0
  output logic       o_OVI0               , // Overflow Channel 0
  output logic       o_CMIA1              , // Compare Match A Channel 1
  output logic       o_CMIB1              , // Compare Match B Channel 1
  output logic       o_OVI1               , // Overflow Channel 1
  // Timer ADC request signal
  output logic       o_adc_request        , // ADC Request Signal

  // Bus output signals
  output logic [7:0] o_mux_reg_to_bus_out
);
  
  logic        Overflow_0         ; // Cascaded TCNT signal (e.g., overflow/compare)
  logic        Overflow_1         ; // Cascaded TCNT signal (e.g., overflow/compare)
  logic        Compare_match_A0   ; // Cascaded TCNT signal (e.g., overflow/compare)
  logic        comp_match_A0_final; // Final Compare Match A0 signal
  logic        Compare_match_B0   ; // Cascaded TCNT signal (e.g., overflow/compare)
  logic        comp_match_B0_final; // Final Compare Match B0 signal
  logic        Compare_match_A1   ; // Cascaded TCNT signal (e.g., overflow/compare)
  logic        Compare_match_B1   ; // Cascaded TCNT signal (e.g., overflow/compare)
  logic        tcnt_en_0          ; // Output Enable Pulse for Channel 0
  logic        tcnt_en_1          ; // Output Enable Pulse for Channel 1
  logic        tcnt_clr_0         ; // Clear TCNT for Channel 0
  logic        tcnt_clr_1         ; // Clear TCNT for Channel 1
  logic [7:0]  dataout_TCCR_0     ; // Data Output TCCR 0
  logic [7:0]  dataout_TCCR_1     ; // Data Output TCCR 1
  logic [7:0]  dataout_TCNT_0     ; // Data Output TCNT 0
  logic [7:0]  dataout_TCNT_1     ; // Data Output TCNT 1
  logic [7:0]  dataout_TCR_0      ; // Data Output TCR 0
  logic [7:0]  dataout_TCR_1      ; // Data Output TCR 1
  logic [7:0]  dataout_TCSR_0     ; // Data Output TCSR 0
  logic [7:0]  dataout_TCSR_1     ; // Data Output TCSR 1
  logic [7:0]  dataout_TCORA_0    ; // Data Output TCORA 0
  logic [7:0]  dataout_TCORA_1    ; // Data Output TCORA 1
  logic [7:0]  dataout_TCORB_0    ; // Data Output TCORB 0
  logic [7:0]  dataout_TCORB_1    ; // Data Output TCORB 1

  clock_select Clock_Select_Module(
    // Global signals
    .i_rst_n        (i_rst_n            ),
    .i_clk          (i_clk_sys          ),

    // Input Prescaled clock 
    .i_clk_phi_2    (i_clk_phi_2        ),
    .i_clk_phi_8    (i_clk_phi_8        ),
    .i_clk_phi_32   (i_clk_phi_32       ),
    .i_clk_phi_64   (i_clk_phi_64       ),
    .i_clk_phi_1024 (i_clk_phi_1024     ),
    .i_clk_phi_8192 (i_clk_phi_8192     ),

    // Input external and cascaded clock signals
    .i_TMCI0        (i_TMCI0            ),     // External signal input TMR0
    .i_TMCI1        (i_TMCI1            ),     // External signal input TMR1
    .i_overflow1    (Overflow_1         ),     // Cascaded TCNT signal (e.g., overflow/compare)
    .i_comp_match_A0(Compare_match_A0   ),     // Cascaded TCNT signal (e.g., overflow/compare)

    // Input select lines
    .i_cks_0        (dataout_TCR_0[2:0] ),     // Clock Source Select
    .i_icks_0       (dataout_TCCR_0[1:0]),     // Internal Clock Edge Select
    .i_cks_1        (dataout_TCR_1[2:0] ),     // Clock Source Select
    .i_icks_1       (dataout_TCCR_1[1:0]),     // Internal Clock Edge Select

    // Output Enable Pulses
    .o_TCNT_EN_0    (tcnt_en_0          ),     // Output Enable Pulse for Channel 0
    .o_TCNT_EN_1    (tcnt_en_1          )      // Output Enable Pulse for Channel 1
  );

    control_logic Control_Logic_Module(
    //---------------------------------------------------------//
    //                INPUT DECLARATION FIELD                  //
    //---------------------------------------------------------//
    // Global input 
    .i_clk                   (i_clk_sys        ),
    .i_rst_n                 (i_rst_n          ),
    // TMR 1 input declaration
    .TCORA_1                 (dataout_TCORA_1  ),
    .TCORB_1                 (dataout_TCORB_1  ),
    .Compare_match_A1        (Compare_match_A1 ),
    .Compare_match_B1        (Compare_match_B1 ),
    .i_os0_1                 (dataout_TCSR_1[0]),
    .i_os1_1                 (dataout_TCSR_1[1]),
    .i_os2_1                 (dataout_TCSR_1[2]),
    .i_os3_1                 (dataout_TCSR_1[3]),
    // TMR0 input declaration
    .TCORA_0                 (dataout_TCORA_0  ),
    .TCORB_0                 (dataout_TCORB_0  ),
    .Compare_match_A0        (Compare_match_A0 ),
    .Compare_match_B0        (Compare_match_B0 ),
    .i_os0_0                 (dataout_TCSR_0[0]),
    .i_os1_0                 (dataout_TCSR_0[1]),
    .i_os2_0                 (dataout_TCSR_0[2]),
    .i_os3_0                 (dataout_TCSR_0[3]),
    // 16-bit mode enable input
    .i_cks0_0                (dataout_TCR_0[0] ),
    .i_cks1_0                (dataout_TCR_0[1] ),
    .i_cks2_0                (dataout_TCR_0[2] ),
    // Clear TCNT_1 control signal input
    .i_counter_clock_1       (tcnt_en_1        ),
    .i_tmris_1               (dataout_TCCR_1[3]), 
    .i_cclr0_1               (dataout_TCR_1[3] ),
    .i_cclr1_1               (dataout_TCR_1[4] ),
    .TMRI_1                  (i_TMRI_1         ),
    // Clear TCNT_0 control signal input
    .i_counter_clock_0       (tcnt_en_0        ),
    .i_tmris_0               (dataout_TCCR_0[3]),
    .i_cclr0_0               (dataout_TCR_0[3] ),
    .i_cclr1_0               (dataout_TCR_0[4] ),
    .TMRI_0                  (i_TMRI_0         ),
    // Interrupt control signal input
    .i_cmfa_0                (Compare_match_A0 ),
    .i_cmfb_0                (Compare_match_B0 ),
    .i_ovf_0                 (Overflow_0       ),
    .i_cmfa_1                (Compare_match_A1 ),
    .i_cmfb_1                (Compare_match_B1 ),
    .i_ovf_1                 (Overflow_1       ),
    .i_cmiea_0               (dataout_TCR_0[6] ),
    .i_cmieb_0               (dataout_TCR_0[7] ),
    .i_ovie_0                (dataout_TCR_0[5] ),
    .i_cmiea_1               (dataout_TCR_1[6] ),
    .i_cmieb_1               (dataout_TCR_1[7] ),
    .i_ovie_1                (dataout_TCR_1[5] ),
    // ADC control input request signal
    .i_adte                  (dataout_TCSR_0[4]),
    //---------------------------------------------------------//
    //               OUTPUT DECLARATION FIELD                  //
    //---------------------------------------------------------//
    // Compare match TMR_0 output signal
    .o_compare_match_A0_final(comp_match_A0_final),
    .o_compare_match_B0_final(comp_match_B0_final),
    // Timer output signal 
    .TMO_1                   (o_TMO_1          ),
    .TMO_0                   (o_TMO_0          ),
    // TCTN output control clear sigal
    .o_clr_tcnt_0            (tcnt_clr_0       ),
    .o_clr_tcnt_1            (tcnt_clr_1       ),
    // Interrupt output signal
    .CMIA0                   (o_CMIA0          ),
    .CMIB0                   (o_CMIB0          ),
    .OVI0                    (o_OVI0           ),
    .CMIA1                   (o_CMIA1          ),
    .CMIB1                   (o_CMIB1          ),
    .OVI1                    (o_OVI1           ),
    // ADC output request signal
    .o_adc_request           (o_adc_request    )
  );


  Timer_register Timer_Register_Module(
    ///// From BUS /////
    .i_clk_sys            (i_clk_sys               ),
    .i_rst_n              (i_rst_n                 ),
    .i_wren               (i_wren                  ),
    .i_addr               (i_addr                  ),
    .i_datain             (i_datain                ),
    ///// From DTC module /////
    .i_DISEL_n            (i_DISEL_n               ),
    .i_DTC_A              (i_DTC_A                 ),
    .i_DTC_B              (i_DTC_B                 ),
    ///// From Control Logic Unit /////
    .i_comp_match_A0_final(comp_match_A0_final),
    .i_comp_match_B0_final(comp_match_B0_final),
    .i_CLR_TCNT           ({tcnt_clr_1, tcnt_clr_0}), // Clear TCNT for both channels
    ///// From Clock Select Module /////
    .i_counter_clock      ({tcnt_en_1, tcnt_en_0}  ),
    ///// channel 0 /////
    .o_OVF_0              (Overflow_0              ),
    .o_CMA_0              (Compare_match_A0        ),
    .o_CMB_0              (Compare_match_B0        ),
    .o_dataout_TCCR_0     (dataout_TCCR_0          ),
    .o_dataout_TCNT_0     (dataout_TCNT_0          ),
    .o_dataout_TCR_0      (dataout_TCR_0           ),
    .o_dataout_TCSR_0     (dataout_TCSR_0          ),
    .o_dataout_TCORA_0    (dataout_TCORA_0         ),
    .o_dataout_TCORB_0    (dataout_TCORB_0         ),
    ///// channel 1 /////
    .o_OVF_1              (Overflow_1              ),
    .o_CMA_1              (Compare_match_A1        ),
    .o_CMB_1              (Compare_match_B1        ),
    .o_dataout_TCCR_1     (dataout_TCCR_1          ),
    .o_dataout_TCNT_1     (dataout_TCNT_1          ),
    .o_dataout_TCR_1      (dataout_TCR_1           ),
    .o_dataout_TCSR_1     (dataout_TCSR_1          ),
    .o_dataout_TCORA_1    (dataout_TCORA_1         ),
    .o_dataout_TCORB_1    (dataout_TCORB_1         )
  );

  param_mux #(
    .NUM_INPUTS(16),   // 16 inputs for 12 registers
    .DATAWIDTH (8 ),   // Each register is 8 bits wide
    .SEL_WIDTH (4 )
  ) mux_reg_to_bus (
    .in({
      {8{1'b0}}      , // address 0xF (not used)
      {8{1'b0}}      , // address 0xE (not used) 
      {8{1'b0}}      , // address 0xD (not used)
      {8{1'b0}}      , // address 0xC (not used)
      dataout_TCSR_1 , // address 0xB
      dataout_TCSR_0 , // address 0xA 
      dataout_TCR_1  , // address 0x9
      dataout_TCR_0  , // address 0x8 
      dataout_TCCR_1 , // address 0x7
      dataout_TCCR_0 , // address 0x6
      dataout_TCORB_1, // address 0x5
      dataout_TCORB_0, // address 0x4
      dataout_TCORA_1, // address 0x3
      dataout_TCORA_0, // address 0x2
      dataout_TCNT_1 , // address 0x1
      dataout_TCNT_0  // address 0x0
    }), 
    .sel(i_addr[3:0]         ),
    .y  (o_mux_reg_to_bus_out)
  );

endmodule : timer_top
