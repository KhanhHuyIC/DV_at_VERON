module apb_slave #(
  parameter ADDR_WIDTH = 32 ,
  parameter DATA_WIDTH = 32 ,
  parameter STRB_WIDTH = DATA_WIDTH / 8,
  parameter DEPTH      = 16,
  parameter WAIT_CYCLE = 2
)(
  // Input declaration
  input  logic                    PCLK     ,    // APB clock signal
  input  logic                    PRESETn  ,    // Active-low reset signal
  input  logic                    PSEL     ,    // Slave select signal
  input  logic                    PENABLE  ,    // Enable signal for APB transaction (n cycle)
  input  logic                    PWRITE   ,    // Write enable signal (1: Write, 0: Read)
  input  logic [ADDR_WIDTH-1:0]   PADDR    ,    // Address sent to slave
  input  logic [DATA_WIDTH-1:0]   PWDATA   ,    // Data sent to slave for write
  input  logic [STRB_WIDTH-1:0]   PSTRB    ,    // Write strobe bit from master for PWDATA
  input  logic                    PSTRBCHK ,    // Parity bit from master for PSTRB
  input  logic [ADDR_WIDTH/8-1:0] PADDRCHK ,    // Parity bit from master for PADDR
  input  logic [DATA_WIDTH/8-1:0] PWDATACHK,    // Parity bit from master for PWDATA
   
  // Output declaration
  output logic                    PREADY   ,    // Slave ready signal
  output logic                    PSLVERR  ,    // Slave error signal
  output logic [DATA_WIDTH-1:0]   PRDATA   ,    // Read data from slave
  output logic [DATA_WIDTH/8-1:0] PRDATACHK     // Parity bit from slave for PRDATA
);

  // Internal signals
  genvar                    i                   ;
  // Parity internal logics for parity check from master to slave
  logic [DATA_WIDTH/8-1:0]  paddr_parity_bit      ;
  logic [DATA_WIDTH/8-1:0]  paddr_parity_reg      ;
  logic [DATA_WIDTH/8-1:0]  paddr_parity_internal ;
  logic [DATA_WIDTH/8-1:0]  pwdata_parity_bit     ;
  logic                     pwdata_parity_en_reg  ;
  logic [DATA_WIDTH/8-1:0]  pwdata_parity_reg     ;
  logic [DATA_WIDTH/8-1:0]  pwdata_parity_internal;
  logic                     pstrb_parity_bit      ;
  logic                     pstrb_parity_reg      ;

  // Internal logics for apb slave
  logic                     paritychk_bit           ;
  logic                     psel_reg                ;
  logic                     access                  ;
  logic                     ram_en                  ;
  logic [STRB_WIDTH-1:0]    pstrb_byte_mask         ;
  logic [WAIT_CYCLE-1:0]    wait_counter            ;
  logic [DATA_WIDTH-1:0]    pwdata_reg              ;
  logic [DATA_WIDTH-1:0]    pwdata_hold             ;
  logic                     addr_error              ;
  logic                     addr_error_hold         ;
  logic                     access_timing_error     ;
  logic                     access_timing_error_hold;
  logic [DATA_WIDTH/8-1:0]  PARITYCHK               ;
  logic                     pslverr_logic           ;
  logic                     pslverr_hold            ;
  logic [DATA_WIDTH-1:0]    prdata_reg              ;

  // Parity internal logics for parity check from slave to master
  logic [DATA_WIDTH/8-1:0]  prdata_parity_bit   ;
  logic                     prdata_parity_en_reg;
  logic [DATA_WIDTH/8-1:0]  PRDATACHK_reg       ;

  //============================================================
  //              MASTER TO SLAVE PARITY CHECK                 
  //============================================================

  // APB slave parity check from source to slave for PADDR

  generate
    for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin : gen_paddr_parity
      assign paddr_parity_bit[i] = ^PADDR[i*8 +: 8];
    end
  endgenerate

  apb_register #(
    .WIDTH(DATA_WIDTH/8)
  ) apb_paddr_parity_check_register (
    .clk  (PCLK            ),
    .rst_n(PRESETn         ),
    .en   (PSEL            ), // Enable condition = (PSEL == 1'b1)
    .d    (paddr_parity_bit),
    .q    (paddr_parity_reg)
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
  apb_register #(
    .WIDTH(DATA_WIDTH/8)
  ) apb_pwdata_parity_check_register (
    .clk  (PCLK                ),
    .rst_n(PRESETn             ),
    .en   (pwdata_parity_en_reg), // Enable condition = PSEL & PWRITE
    .d    (pwdata_parity_bit   ),
    .q    (pwdata_parity_reg   )
  );
  generate 
    for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin : gen_pwdata_parity_internal
      assign pwdata_parity_internal[i] = pwdata_parity_reg[i] ^ PWDATACHK[i];
    end
  endgenerate

  // APB slave parity check from source to slave for PSTRB

  apb_register #(
    .WIDTH(1)
  ) apb_pstrb_parity_check_register (
    .clk  (PCLK                ),
    .rst_n(PRESETn             ),
    .en   (pwdata_parity_en_reg), // Enable condition = PSEL & PWRITE
    .d    (pstrb_parity_bit    ),        
    .q    (pstrb_parity_reg    )
  );
  assign pstrb_parity_bit = ^PSTRB;
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
  apb_register #(
    .WIDTH(DATA_WIDTH)
  ) pwdata_register (
    .clk  (PCLK       ),
    .rst_n(PRESETn    ),
    .en   (1'b1       ), 
    .d    (pwdata_hold),   
    .q    (pwdata_reg )
  );

  // RAM block to store data for read/write access
  generate
    for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin : gen_parity_check
      assign PARITYCHK[i] = paddr_parity_internal[i] | pwdata_parity_internal[i];
    end
  endgenerate
  
  // Parity check for PADDR and PWDATA
  assign paritychk_bit = |PARITYCHK;
  assign ram_en = PWRITE & access & !paritychk_bit;
  apb_slave_ram #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH     (DEPTH     )
  ) ram_inst (
    .PCLK   (PCLK      ),
    .PRESETn(PRESETn   ),
    .ram_en (ram_en    ),
    .PADDR  (PADDR     ),
    .PWDATA (pwdata_reg),
    .PRDATA (prdata_reg)
  );

  // Register to reduce long timing path for PRDATA
  apb_register #(
    .WIDTH(DATA_WIDTH)
  ) prdata_register (
    .clk  (PCLK      ),
    .rst_n(PRESETn   ),
    .en   (1'b1      ), 
    .d    (prdata_reg),
    .q    (PRDATA    )
  );

  // Error response logic
  assign addr_error           = (PADDR[ADDR_WIDTH-3:0] >= DEPTH);
  assign access_timing_error  = wait_counter[0] & !access                 ;
  assign pslverr_logic        = access_timing_error_hold | addr_error_hold;

  apb_register #(
    .WIDTH(1)
  ) access_timing_hold_reg (
    .clk  (PCLK                     ),
    .rst_n(PRESETn                  ),
    .en   (1'b1                     ), // At Setup or Access state PSEL = 1'b1
    .d    (access_timing_error      ),
    .q    (access_timing_error_hold )      
  );

  apb_register #(
    .WIDTH(1)
  ) addr_error_hold_reg (
    .clk  (PCLK            ),
    .rst_n(PRESETn         ),
    .en   (1'b1            ), // At Setup or Access state PSEL = 1'b1'b
    .d    (addr_error      ),
    .q    (addr_error_hold )      
  );

  // D flip flop to hold PLSVERR logic
  apb_register #(
    .WIDTH(1)
  ) pslverr_hold_reg (
    .clk  (PCLK         ),
    .rst_n(PRESETn      ),
    .en   (1'b1), // At Setup or Access state PSEL = 1'b1'b
    .d    (pslverr_logic),
    .q    (pslverr_hold )      
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
    .clk  (PCLK                   ),
    .rst_n(PRESETn                ),
    .en   (prdata_parity_en_reg   ), // At Setup or Access state PSEL = 1'b1
    .d    (prdata_parity_bit      ),
    .q    (PRDATACHK_reg          )
  );

  assign PRDATACHK = (PREADY) ? PRDATACHK_reg : '0;

endmodule : apb_slave
