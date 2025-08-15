module apb_slave_timer #(
  parameter ADDR_WIDTH = 8             ,
  parameter DATA_WIDTH = 8             ,
  parameter STRB_WIDTH = DATA_WIDTH / 8,
  parameter DEPTH      = 16            ,
  parameter WAIT_CYCLE = 2
)(
  // Input declaration
  input  logic                    PCLK          ,    // APB clock signal
  input  logic                    PRESETn       ,    // Active-low reset signal
  input  logic                    PSEL          ,    // Slave select signal
  input  logic                    PENABLE       ,    // Enable signal for APB transaction (n cycle)
  input  logic                    PWRITE        ,    // Write enable signal (1: Write, 0: Read)
  input  logic [ADDR_WIDTH-1:0]   PADDR         ,    // Address sent to slave
  input  logic [DATA_WIDTH-1:0]   PWDATA        ,    // Data sent to slave for write
  input  logic [STRB_WIDTH-1:0]   PSTRB         ,    // Write strobe bit from master for PWDATA
  input  logic                    PSTRBCHK      ,    // Parity bit from master for PSTRB
  input  logic [ADDR_WIDTH/8-1:0] PADDRCHK      ,    // Parity bit from master for PADDR
  input  logic [DATA_WIDTH/8-1:0] PWDATACHK     ,    // Parity bit from master for PWDATA
  input  logic                    i_clk_phi_2   ,    // Clock signal for timer module
  input  logic                    i_clk_phi_8   ,    // Clock signal for timer module
  input  logic                    i_clk_phi_32  ,    // Clock signal for timer module
  input  logic                    i_clk_phi_64  ,    // Clock signal for timer module
  input  logic                    i_clk_phi_1024,    // Clock signal for timer module
  input  logic                    i_clk_phi_8192,    // Clock signal for timer module
  input  logic                    i_TMCI0       ,    // Timer match condition input 0
  input  logic                    i_TMCI1       ,    // Timer match condition input 1
  input  logic                    i_TMRI_0      ,    // Timer match reset input 0
  input  logic                    i_TMRI_1      ,    // Timer match reset input 1
  // input  logic                    disel_n       ,    // Disable signal for timer module
  // input  logic                    dtc_a         ,    // Data transfer control A
  // input  logic                    dtc_b         ,    // Data transfer control B
  // output from timer_top
  output logic                    o_TMO_0       ,    // Timer match output 0
  output logic                    o_TMO_1       ,    // Timer match output 1
  output logic                    o_CMIA0       ,    // Compare match input A 0
  output logic                    o_CMIB0       ,    // Compare match input B 0
  output logic                    o_OVI0        ,    // Overflow input 0 
  output logic                    o_CMIA1       ,    // Compare match input A 1
  output logic                    o_CMIB1       ,    // Compare match input B 1
  output logic                    o_OVI1        ,    // Overflow input 1
  output logic                    o_adc_request ,    // ADC request signal
  output logic                    PREADY        ,    // Slave ready signal
  output logic                    PSLVERR       ,    // Slave error signal
  output logic [DATA_WIDTH-1:0]   PRDATA        ,    // Read data from slave
  output logic [DATA_WIDTH/8-1:0] PRDATACHK          // Parity bit from slave for PRDATA
);

  // Internal signals
  genvar                   i                       ;
  // Parity internal logics for parity check from master to slave
  logic [DATA_WIDTH/8-1:0] paddr_parity_bit        ;
  logic [DATA_WIDTH/8-1:0] paddr_parity_reg        ;
  logic [DATA_WIDTH/8-1:0] paddr_parity_internal   ;
  logic [DATA_WIDTH/8-1:0] pwdata_parity_bit       ;
  logic                    pwdata_parity_en_reg    ; 
  logic [DATA_WIDTH/8-1:0] pwdata_parity_reg       ;
  logic [DATA_WIDTH/8-1:0] pwdata_parity_internal  ;
  logic                    pstrb_parity_bit        ;
  logic                    pstrb_parity_reg        ;
  logic                    pstrb_parity_internal   ;


  // Internal logics for apb slave
  logic                    paritychk_bit           ;
  logic                    psel_reg                ;
  logic                    access                  ;
  logic                    timer_en                ;
  logic [STRB_WIDTH-1:0]   pstrb_byte_mask         ;
  logic [WAIT_CYCLE-1:0]   wait_counter            ;
  logic [DATA_WIDTH-1:0]   pwdata_reg              ;
  logic [DATA_WIDTH-1:0]   pwdata_hold             ;
  logic                    addr_error              ;
  logic                    addr_error_hold         ;
  logic                    access_timing_error     ;
  logic                    access_timing_error_hold;
  logic [DATA_WIDTH/8-1:0] PARITYCHK               ;
  logic                    pslverr_logic           ;
  logic                    pslverr_hold            ;
  logic [DATA_WIDTH-1:0]   prdata_reg              ;

  // Parity internal logics for parity check from slave to master
  logic [DATA_WIDTH/8-1:0] prdata_parity_bit       ;
  logic                    prdata_parity_en_reg    ;
  logic [DATA_WIDTH/8-1:0] PRDATACHK_reg           ;
   
  //============================================================
  //              MASTER TO SLAVE PARITY CHECK                 
  //============================================================

  // APB slave parity check from source to slave for PADDR
  generate
    for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin : gen_paddr_parity
      assign paddr_parity_bit[i] = ^PADDR[i*8 +: 8];
    end
  endgenerate

  param_d_ff #(
    .DATA_WIDTH(DATA_WIDTH/8),
    .SET_VALUE('0) // Reset value for parity check
  ) apb_paddr_parity_check_register (
    .i_clk  (PCLK            ),
    .i_rst_n(PRESETn         ),
    .i_en   (PSEL            ), // Enable condition = (PSEL == 1'b1)
    .d      (paddr_parity_bit),
    .q      (paddr_parity_reg)
  );

  generate 
    for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin : gen_paddr_parity_internal
      assign paddr_parity_internal[i] = paddr_parity_reg[i] ^ PADDRCHK[i];
    end
  endgenerate

  // APB slave parity check from source to slave for PWDATA
  generate
    for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin : gen_pwdata_parity
      assign pwdata_parity_bit[i] = ^PWDATA[i*8 +: 8];
    end
  endgenerate

  assign pwdata_parity_en_reg = PSEL & PWRITE;
  param_d_ff #(
    .DATA_WIDTH(DATA_WIDTH/8),
    .SET_VALUE('0) // Reset value for parity check
  ) apb_pwdata_parity_check_register (
    .i_clk  (PCLK                ),
    .i_rst_n(PRESETn             ),
    .i_en   (pwdata_parity_en_reg), // Enable condition = PSEL & PWRITE
    .d      (pwdata_parity_bit   ),
    .q      (pwdata_parity_reg   )
  );
  generate 
    for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin : gen_pwdata_parity_internal
      assign pwdata_parity_internal[i] = pwdata_parity_reg[i] ^ PWDATACHK[i];
    end
  endgenerate

  // APB slave parity check from source to slave for PSTRB
  param_d_ff #(
    .DATA_WIDTH(DATA_WIDTH/8),
    .SET_VALUE('0) // Reset value for parity check
  ) apb_pstrb_parity_check_register (
    .i_clk  (PCLK                ),
    .i_rst_n(PRESETn             ),
    .i_en   (pwdata_parity_en_reg), // Enable condition = PSEL & PWRITE
    .d      (pstrb_parity_bit    ),        
    .q      (pstrb_parity_reg    )
  );
  assign pstrb_parity_bit      = ^PSTRB                     ;
  assign pstrb_parity_internal = pstrb_parity_reg ^ PSTRBCHK;

  //============================================================
  //       APB SLAVE COMBINATIONAL AND SEQUENTIAL LOGICS       
  //============================================================
  // Byte_masking logic to select between read data and write data based on byte mask
  assign pstrb_byte_mask = PSTRB & {4{PWRITE}} & {4{!pstrb_parity_internal}}; // Apply PWRITE to PSTRB for byte masking
  apb_master_byte_masking #(
    .DATA_WIDTH(DATA_WIDTH),              
    .STRB_WIDTH(STRB_WIDTH)
  ) byte_masking_block(
    .pstrb_byte_mask(pstrb_byte_mask),
    .apb_write_data (PWDATA         ),
    .PRDATA         (prdata_reg     ),
    .PWDATA         (pwdata_hold    )
  );

  // Wait n state using shift register for delay n clock cycle
  assign access = PSEL & PENABLE;
  wait_state_shift_reg #(
    .WAIT_CYCLE(WAIT_CYCLE)
  ) wait_logic (
    .PCLK         (PCLK        ),
    .PRESETn      (PRESETn     ),
    .PENABLE      (PENABLE     ),
    .access       (access      ),
    .wait_counter (wait_counter),
    .PREADY       (PREADY      )
  );

  // Register to reduce long timing path for PWDATA
  param_d_ff #(
    .DATA_WIDTH(DATA_WIDTH),
    .SET_VALUE('0) // Reset value for PWDATA
  ) pwdata_register (
    .i_clk  (PCLK       ),
    .i_rst_n(PRESETn    ),
    .i_en   (1'b1       ), 
    .d      (pwdata_hold),   
    .q      (pwdata_reg )
  );

  // RAM block to store data for read/write access
  generate
    for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin : gen_parity_check
      assign PARITYCHK[i] = paddr_parity_internal[i] | pwdata_parity_internal[i] | pstrb_parity_internal;
    end
  endgenerate
  
  // Parity check for PADDR and PWDATA
  assign paritychk_bit = |PARITYCHK                        ;
  assign timer_en      = PWRITE & access & (!paritychk_bit);

  timer_top ip_timer (
  .i_clk_sys           (PCLK          ),
  .i_rst_n             (PRESETn       ),
  .i_clk_phi_2         (i_clk_phi_2   ),
  .i_clk_phi_8         (i_clk_phi_8   ),
  .i_clk_phi_32        (i_clk_phi_32  ),
  .i_clk_phi_64        (i_clk_phi_64  ),
  .i_clk_phi_1024      (i_clk_phi_1024),
  .i_clk_phi_8192      (i_clk_phi_8192),
  .i_TMCI0             (i_TMCI0       ),
  .i_TMCI1             (i_TMCI1       ),
  .i_TMRI_0            (i_TMRI_0      ),
  .i_TMRI_1            (i_TMRI_1      ),
  .i_wren              (timer_en      ),
  .i_addr              (PADDR         ),
  .i_datain            (pwdata_reg    ),
  .i_DISEL_n           (1'b1          ),
  .i_DTC_A             (1'b0          ),
  .i_DTC_B             (1'b0          ),
  .o_TMO_0             (o_TMO_0       ),
  .o_TMO_1             (o_TMO_1       ),
  .o_CMIA0             (o_CMIA0       ),
  .o_CMIB0             (o_CMIB0       ),
  .o_OVI0              (o_OVI0        ),
  .o_CMIA1             (o_CMIA1       ),
  .o_CMIB1             (o_CMIB1       ),
  .o_OVI1              (o_OVI1        ),
  .o_adc_request       (o_adc_request ),
  .o_mux_reg_to_bus_out(prdata_reg    )
  );
  // Register to reduce long timing path for PRDATA
  param_d_ff #(
    .DATA_WIDTH(DATA_WIDTH),
    .SET_VALUE('0) // Reset value for PRDATA
  ) prdata_register (
    .i_clk  (PCLK      ),
    .i_rst_n(PRESETn   ),
    .i_en   (1'b1      ), 
    .d      (prdata_reg),
    .q      (PRDATA    )
  );

  // Error response logic
  assign addr_error           = (PADDR[ADDR_WIDTH-3:0] >= DEPTH)          ;
  assign access_timing_error  = wait_counter[0] & !access                 ;
  assign pslverr_logic        = access_timing_error_hold | addr_error_hold;

  param_d_ff #(
    .DATA_WIDTH(1),
    .SET_VALUE('0) // Reset value for access timing error
  ) access_timing_hold_reg (
    .i_clk  (PCLK                    ),
    .i_rst_n(PRESETn                 ),
    .i_en   (1'b1                    ), // At Setup or Access state PSEL = 1'b1
    .d      (access_timing_error     ),
    .q      (access_timing_error_hold)
  );

  param_d_ff #(
    .DATA_WIDTH(1),
    .SET_VALUE('0) // Reset value for address error
  ) addr_error_hold_reg (
    .i_clk  (PCLK           ),
    .i_rst_n(PRESETn        ),
    .i_en   (1'b1           ), // At Setup or Access state PSEL = 1'b1'b
    .d      (addr_error     ),
    .q      (addr_error_hold)
  );

  // D flip flop to hold PLSVERR logic
  param_d_ff #(
    .DATA_WIDTH(1),
    .SET_VALUE('0) // Reset value for PLSVERR logic
  ) pslverr_hold_reg (
    .i_clk  (PCLK         ),
    .i_rst_n(PRESETn      ),
    .i_en   (1'b1         ), // At Setup or Access state PSEL = 1'b1'b
    .d      (pslverr_logic),
    .q      (pslverr_hold )
  );
  assign PSLVERR = wait_counter[WAIT_CYCLE-1] & access & pslverr_hold; 

  //============================================================
  //              SLAVE TO MASTER PARITY CHECK                 
  //============================================================
  // APB slave parity check from slave to master for PRDATA
  generate
    for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin : gen_prdata_parity
      assign prdata_parity_bit[i] = ^PRDATA[i*8 +: 8];
    end
  endgenerate

  assign prdata_parity_en_reg = (!PWRITE & access);
  apb_register #(
    .WIDTH(DATA_WIDTH/8)
  ) apb_prdata_parity_check_register (
    .clk  (PCLK                ),
    .rst_n(PRESETn             ),
    .en   (prdata_parity_en_reg), // At Setup or Access state PSEL = 1'b1
    .d    (prdata_parity_bit   ),
    .q    (PRDATACHK_reg       )
  );

  assign PRDATACHK = (PREADY) ? PRDATACHK_reg : '0;

endmodule : apb_slave_timer
