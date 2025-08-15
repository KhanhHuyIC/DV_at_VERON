module Timer_register (
  ///// From BUS /////
  input  logic       i_clk_sys            ,
  input  logic       i_rst_n              ,
  input  logic       i_wren               ,
  input  logic [7:0] i_addr               , // Address 4 bit
  input  logic [7:0] i_datain             ,
  ///// From DTC module /////
  input  logic       i_DISEL_n            ,
  input  logic       i_DTC_A              ,
  input  logic       i_DTC_B              ,
  ///// From Control Logic Unit /////
  input  logic       i_comp_match_A0_final,
  input  logic       i_comp_match_B0_final,
  input  logic [1:0] i_CLR_TCNT           ,
  input  logic [1:0] i_counter_clock      ,  ///// channel 0 /////
  output logic       o_OVF_0              ,
  output logic       o_CMA_0              ,
  output logic       o_CMB_0              ,
  output logic [7:0] o_dataout_TCCR_0     ,
  output logic [7:0] o_dataout_TCNT_0     ,
  output logic [7:0] o_dataout_TCR_0      ,
  output logic [7:0] o_dataout_TCSR_0     ,
  output logic [7:0] o_dataout_TCORA_0    ,
  output logic [7:0] o_dataout_TCORB_0    ,
  ///// channel 1 /////
  output logic       o_OVF_1              ,
  output logic       o_CMA_1              ,
  output logic       o_CMB_1              ,
  output logic [7:0] o_dataout_TCCR_1     ,
  output logic [7:0] o_dataout_TCNT_1     ,
  output logic [7:0] o_dataout_TCR_1      ,
  output logic [7:0] o_dataout_TCSR_1     ,
  output logic [7:0] o_dataout_TCORA_1    ,
  output logic [7:0] o_dataout_TCORB_1
);

  // ===== Channel 0 Register Map =====
  localparam ADDR_TCNT_0  = 4'h0;
  localparam ADDR_TCNT_1  = 4'h1;
  localparam ADDR_TCORA_0 = 4'h2;
  localparam ADDR_TCORA_1 = 4'h3;
  localparam ADDR_TCORB_0 = 4'h4;
  localparam ADDR_TCORB_1 = 4'h5;
  localparam ADDR_TCCR_0  = 4'h6;
  localparam ADDR_TCCR_1  = 4'h7;
  localparam ADDR_TCR_0   = 4'h8;
  localparam ADDR_TCR_1   = 4'h9;
  localparam ADDR_TCSR_0  = 4'hA;
  localparam ADDR_TCSR_1  = 4'hB;

  ///// TCNT REGISTERS: ADDRESS 0x0 and 0x1 /////
  //// This register works as an increment counter which can load immediate value.
  //// The register is cleared by two method: 1. through negedge reset 2. through stop function.
  //// The counter overflow trigger Overflow by comparing previous data and current data.
  //// Prev data: 8'hFF, current data: 8'h00 ==> OVF toggle.
  //// Initialize with 8'h00.
  TCNT TCNT_0 (
    .i_clk_sys     (i_clk_sys                       ),
    .i_rst_n       (i_rst_n                         ),
    .i_clr         (i_CLR_TCNT[0]                   ),
    .i_wren        (i_wren & (i_addr == ADDR_TCNT_0)),
    .counter_clock (i_counter_clock[0]              ),
    .i_datain      (i_datain                        ),
    .o_OVF         (o_OVF_0                         ),
    .o_count       (o_dataout_TCNT_0                )
  );

  TCNT TCNT_1 (
    .i_clk_sys     (i_clk_sys                       ),
    .i_rst_n       (i_rst_n                         ),
    .i_clr         (i_CLR_TCNT[1]                   ),
    .i_wren        (i_wren & (i_addr == ADDR_TCNT_1)),
    .counter_clock (i_counter_clock[1]              ),
    .i_datain      (i_datain                        ),
    .o_OVF         (o_OVF_1                         ),
    .o_count       (o_dataout_TCNT_1                )
  );

  ///// TCOR REGISTERS: ADDRESS 0x2, 0x3, 0x4 and 0x5 /////
  //// This register uses to hold value to compare with TCNT to toggle compare flag.
  //// Initialize with and after reset: 8'hFF.
  TCOR TCORA_0 (
    .i_clk_sys  (i_clk_sys                        ),
    .i_rst_n    (i_rst_n                          ),
    .i_wren     (i_wren & (i_addr == ADDR_TCORA_0)),
    .i_datain   (i_datain                         ),
    .o_dataout  (o_dataout_TCORA_0                )
  );

  TCOR TCORA_1 (
    .i_clk_sys  (i_clk_sys                        ),
    .i_rst_n    (i_rst_n                          ),
    .i_wren     (i_wren & (i_addr == ADDR_TCORA_1)),
    .i_datain   (i_datain                         ),
    .o_dataout  (o_dataout_TCORA_1                )
  );

  TCOR TCORB_0 (
    .i_clk_sys  (i_clk_sys                        ),
    .i_rst_n    (i_rst_n                          ),
    .i_wren     (i_wren & (i_addr == ADDR_TCORB_0)),
    .i_datain   (i_datain                         ),
    .o_dataout  (o_dataout_TCORB_0                )
  );

  TCOR TCORB_1 (
    .i_clk_sys  (i_clk_sys                        ),
    .i_rst_n    (i_rst_n                          ),
    .i_wren     (i_wren & (i_addr == ADDR_TCORB_1)),
    .i_datain   (i_datain                         ),
    .o_dataout  (o_dataout_TCORB_1                )
  );

  ///// COMPARE MODULE /////
  //// Compare data from TCNT and TCOR registers to toggle compare match signal.
  //// Disable the output if other registers are written to  
  COMP COMPA_0 (
    .i_wren        (i_wren           ),
    .i_data_comp_A (o_dataout_TCNT_0 ),
    .i_data_comp_B (o_dataout_TCORA_0),
    .o_data_comp   (o_CMA_0          )
  );

  COMP COMPA_1 (
    .i_wren        (i_wren           ),
    .i_data_comp_A (o_dataout_TCNT_1 ),
    .i_data_comp_B (o_dataout_TCORA_1),
    .o_data_comp   (o_CMA_1          )
  );

  COMP COMPB_0 (
    .i_wren        (i_wren           ),
    .i_data_comp_A (o_dataout_TCNT_0 ),
    .i_data_comp_B (o_dataout_TCORB_0),
    .o_data_comp   (o_CMB_0          )
  );

  COMP COMPB_1 (
    .i_wren        (i_wren           ),
    .i_data_comp_A (o_dataout_TCNT_1 ),
    .i_data_comp_B (o_dataout_TCORB_1),
    .o_data_comp   (o_CMB_1          )
  );

  ///// TCCR REGISTERS: ADDRESS 0x6 and 0x7 /////
  //// TCCR selects the TCNT internal clock source and controls the external reset input.
  //// Bit 7,6,5,4 and 2 is reserved (CAN'T write to these bits, READABLE)
  TCCR TCCR_0 (
    .i_clk_sys  (i_clk_sys                       ),
    .i_rst_n    (i_rst_n                         ),
    .i_wren     (i_wren & (i_addr == ADDR_TCCR_0)),
    .i_datain   ({i_datain[3],i_datain[1:0]}     ),
    .o_dataout  (o_dataout_TCCR_0                )
  );

  TCCR TCCR_1 (
    .i_clk_sys  (i_clk_sys                       ),
    .i_rst_n    (i_rst_n                         ),
    .i_wren     (i_wren & (i_addr == ADDR_TCCR_1)),
    .i_datain   ({i_datain[3],i_datain[1:0]}     ),
    .o_dataout  (o_dataout_TCCR_1                )
  );

  ///// TCR REGISTERS: ADDRESS 0x8 and 0x9 /////
  ////TCR selects the clock source and the time at which TCNT is cleared, and controls interrupts.
  TCR TCR_0 (
    .i_clk_sys  (i_clk_sys                      ),
    .i_rst_n    (i_rst_n                        ),
    .i_wren     (i_wren & (i_addr == ADDR_TCR_0)),
    .i_datain   (i_datain                       ),
    .o_dataout  (o_dataout_TCR_0                )
  );

  TCR TCR_1 (
    .i_clk_sys  (i_clk_sys                      ),
    .i_rst_n    (i_rst_n                        ),
    .i_wren     (i_wren & (i_addr == ADDR_TCR_1)),
    .i_datain   (i_datain                       ),
    .o_dataout  (o_dataout_TCR_1                )
  );

  ///// TCSR REGISTERS: ADDRESS 0xA and 0xB /////
  ////TCSR displays status flags, and controls compare match output.
  TCSR TCSR_0 (
    .i_clk_sys   (i_clk_sys                       ),
    .i_rst_n     (i_rst_n                         ),
    .i_wren      (i_wren & (i_addr == ADDR_TCSR_0)),
    .i_overflow  (o_OVF_0                         ),
    .i_CMA       (i_comp_match_A0_final           ),
    .i_CMB       (i_comp_match_B0_final           ),
    .i_DISEL_n   (i_DISEL_n                       ),
    .i_DTC_A     (i_DTC_A                         ),
    .i_DTC_B     (i_DTC_B                         ),
    .i_datain    (i_datain                        ),
    .o_dataout   (o_dataout_TCSR_0                )
  );

  TCSR TCSR_1 (
    .i_clk_sys   (i_clk_sys                       ),
    .i_rst_n     (i_rst_n                         ),
    .i_wren      (i_wren & (i_addr == ADDR_TCSR_1)),
    .i_overflow  (o_OVF_1                         ),
    .i_CMA       (o_CMA_1                         ),
    .i_CMB       (o_CMB_1                         ),
    .i_DISEL_n   (i_DISEL_n                       ),
    .i_DTC_A     (i_DTC_A                         ),
    .i_DTC_B     (i_DTC_B                         ),
    .i_datain    (i_datain                        ),
    .o_dataout   (o_dataout_TCSR_1                )
  );

endmodule: Timer_register
