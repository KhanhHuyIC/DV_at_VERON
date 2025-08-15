module apb_master #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32 ,
  parameter NUM_SLAVE  = 4
)(
  // Input declaration
  input  logic                                   PCLK                     ,    // APB clock signal
  input  logic                                   PRESETn                  ,    // Active-low reset signal
  input  logic [ADDR_WIDTH/8-1:0]                apb_paddr_parity_src_out ,    // Parity bit from source for apb_write_paddr
  input  logic [DATA_WIDTH/8-1:0]                write_data_parity_src_out,    // Parity bit from source for apb_write_data
  input  logic                                   pstrb_parity_src_out     ,    // Parity bit from source for PSTRB
  input  logic                                   transfer                 ,    // Initiates APB transfer when high
  input  logic                                   WRITE_READ               ,    // 1: Write, 0: Read operation
  input  logic [ADDR_WIDTH-1:0]                  apb_paddr                ,    // Address from master
  input  logic [DATA_WIDTH-1:0]                  apb_write_data           ,    // Data to be written to slave
  input  logic [DATA_WIDTH/8-1:0]                apb_pstrb                ,    // Byte write strobe (valid per byte)
  input  logic [NUM_SLAVE-1:0][DATA_WIDTH-1:0]   PRDATA                   ,    // Read data from all slaves
  input  logic [NUM_SLAVE-1:0]                   PREADY                   ,    // Slave ready signal
  input  logic [NUM_SLAVE-1:0]                   PSLVERR                  ,    // Slave error signal
  input  logic [NUM_SLAVE-1:0][DATA_WIDTH/8-1:0] PRDATACHK                ,    // Parity bit from slave for PRDATA
  // Output declaration
  output logic [ADDR_WIDTH/8-1:0]                apb_paddr_parity_chk     ,    // Parity check from source to master for apb_write_paddr
  output logic [DATA_WIDTH/8-1:0]                write_data_parity_chk    ,    // Parity check from source to master for apb_write_data
  output logic                                   pstrb_parity_chk         ,    // Parity check from source to master for PSTRB
  output logic                                   PENABLE                  ,    // Enable signal for APB transaction (n cycle)
  output logic [DATA_WIDTH/8-1:0]                PSTRB                    ,    // Byte write strobe (valid per byte)
  output logic [NUM_SLAVE-1:0]                   PSEL                     ,    // One-hot slave select signal
  output logic [ADDR_WIDTH-1:0]                  PADDR                    ,    // Address sent to slave
  output logic [DATA_WIDTH-1:0]                  PWDATA                   ,    // Data sent to slave for write
  output logic                                   PWRITE                   ,    // Write enable signal (1: Write, 0: Read)
  output logic [DATA_WIDTH-1:0]                  apb_read_data_out        ,    // Captured read data from slave
  output logic [DATA_WIDTH/8-1:0]                PADDRCHK                 ,    // Parity bit from master for PADDR
  output logic [DATA_WIDTH/8-1:0]                PWDATACHK                ,    // Parity bit from master for PWDATA
  output logic                                   PSTRBCHK                 ,    // Parity bit from master for PSTRB
  output logic [DATA_WIDTH/8-1:0]                prdata_parity_error            // Parity check from slave to master for PRDATA
 );

  // Local parameter
  localparam STRB_WIDTH = DATA_WIDTH / 8   ;
  localparam DEC_WIDTH  = $clog2(NUM_SLAVE);

  // Internal logics declaration
  genvar                        i                     ;
  // Parity internal logics for parity check from source to master
  logic [ADDR_WIDTH/8-1:0]      apb_paddr_parity_bit  ;
  logic [ADDR_WIDTH/8-1:0]      apb_paddr_parity_reg  ;
  logic [DATA_WIDTH/8-1:0]      write_data_parity_bit ;
  logic [DATA_WIDTH/8-1:0]      write_data_parity_reg ;
  logic                         pstrb_parity_bit      ;
  logic                         pstrb_parity_reg      ;

  // Internal logics for apb master 
  logic                         read_data_reg_en      ;
  logic                         PSELx_decoder_en      ;
  logic [DATA_WIDTH/8-1:0]      pwdata_parity_reg     ;
  logic                         PREADY_selected       ;
  logic                         PSLVERR_selected      ;
  logic [STRB_WIDTH-1:0]        pstrb_reg             ;
  logic [STRB_WIDTH-1:0]        pstrb_byte_mask       ;
  logic [DATA_WIDTH-1:0]        apb_write_data_reg    ;
  logic [DATA_WIDTH-1:0]        prdata_selected       ;
//  logic [DATA_WIDTH-1:0]        prdata_selected_reg   ;
  logic [DATA_WIDTH/8-1:0]      PRDATACHK_selected    ;
  logic [$clog2(NUM_SLAVE)-1:0] slave_addr_range      ;
  logic [DATA_WIDTH-1:0]        pwdata_reg            ;
  logic [DATA_WIDTH-1:0]        read_data_reg         ;

  // Parity internal logics for parity check from master to slave
  logic                         paddr_parity_en_reg   ;
  logic [ADDR_WIDTH/8-1:0]      paddr_parity_chk      ;
  logic                         pwdata_parity_en_reg  ;
  logic [DATA_WIDTH/8-1:0]      pwdata_parity_chk     ;

  // Parity internal logics for parity check from slave to master
  logic [DATA_WIDTH/8-1:0]      prdata_parity_bit     ;
  logic [DATA_WIDTH/8-1:0]      prdata_parity_reg     ;
  logic [DATA_WIDTH/8-1:0]      prdata_parity_internal;

  // Internal enum logics declaration
  logic [1:0]                   fsm_state             ;

  //============================================================
  //              SOURCE TO MASTER PARITY CHECK                 
  //============================================================

  // APB master parity check from source to master for apb_paddr
  generate
    for (i = 0; i < ADDR_WIDTH/8; i = i + 1) begin : gen_write_paddr_parity
      assign apb_paddr_parity_bit[i] = ^apb_paddr[i*8 +: 8];
    end
  endgenerate

  apb_register #(
    .WIDTH(ADDR_WIDTH/8)
  ) apb_write_paddr_parity_check_register (
    .clk  (PCLK                ),
    .rst_n(PRESETn             ),
    .en   (transfer            ), // Enable condition = (transfer == 1'b1)
    .d    (apb_paddr_parity_bit),
    .q    (apb_paddr_parity_reg)
  );
  assign apb_paddr_parity_chk = apb_paddr_parity_reg ^ apb_paddr_parity_src_out;

  // APB master parity check from source to master for apb_write_dataX
  generate
    for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin : gen_write_data_parity
      assign write_data_parity_bit[i] = ^apb_write_data[i*8 +: 8];
    end
  endgenerate

  apb_register #(
    .WIDTH(DATA_WIDTH/8)
  ) apb_write_data_parity_check_register (
    .clk  (PCLK                 ),
    .rst_n(PRESETn              ),
    .en   (transfer             ), // Enable condition = (transfer == 1'b1)
    .d    (write_data_parity_bit),
    .q    (write_data_parity_reg)
  );
  assign  write_data_parity_chk = write_data_parity_reg ^ write_data_parity_src_out;

  // APB master parity check from source to master for PSTRB
  assign  pstrb_parity_chk = pstrb_parity_reg ^ pstrb_parity_src_out;

  //============================================================
  //       APB MASTER COMBINATIONAL AND SEQUENTIAL LOGICS       
  //============================================================
  
  // FSM
  apb_master_fsm FSM(
    .PCLK    (PCLK           ),  // APB clock
    .PRESETn (PRESETn        ),  // APB active-low reset
    .transfer(transfer       ),  // Transfer request from master
    .PREADY  (PREADY_selected),  // Ready signal from slave
    .state   (fsm_state      )   // Current FSM state
  );
  // PREADY select to FSM
    param_mux #(
    .DATA_WIDTH(1               ),
    .NUM_SLAVE (NUM_SLAVE       )
  ) PREADY_mux (
    .in_data   (PREADY          ),
    .sel       (slave_addr_range), // Flexible select for param mux base on slave number
    .out_data  (PREADY_selected )
  );

  // PENABLE output logic
  assign PENABLE = fsm_state[1];

  // PSELx decoder for slave selection
  assign PSELx_decoder_en = fsm_state[0] | fsm_state[1]                     ;
  assign slave_addr_range = PADDR[ADDR_WIDTH-1:ADDR_WIDTH-$clog2(NUM_SLAVE)];
  decoder #(
    .N(DEC_WIDTH)
  ) slave_select_decoder (
    .in (slave_addr_range),
    .en (PSELx_decoder_en),
    .out(PSEL            )
  );

  assign PADDR = apb_paddr;

  generate
    for (i = 0; i < DATA_WIDTH; i = i + 1) begin : gen_buf_PWDATA
      buf bufi(PWDATA[i], apb_write_data[i]);
    end
  endgenerate

  buf buf_PWRITE(PWRITE, WRITE_READ);

  buf buf_PSTRB(PSTRB, apb_pstrb);

  // Mux to select read data from the chosen slave
  param_mux #(
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_SLAVE (NUM_SLAVE )
  ) PRDATA_mux (
    .in_data   (PRDATA          ),
    .sel       (slave_addr_range), // Flexible select for param mux base on slave number
    .out_data  (prdata_selected )
  );

  //Apb read data from master to source
  assign read_data_reg_en = !PWRITE;
  apb_register #(
    .WIDTH(DATA_WIDTH)
  ) apb_read_data_out_register (
    .clk  (PCLK             ),
    .rst_n(PRESETn          ),
    .en   (read_data_reg_en ),
    .d    (prdata_selected  ),
    .q    (read_data_reg    )
  );
  
  param_mux #(
    .DATA_WIDTH(1               ),
    .NUM_SLAVE (NUM_SLAVE       )
  ) PSLVERR_mux (
    .in_data   (PSLVERR         ),
    .sel       (slave_addr_range), // Flexible select for param mux base on slave number
    .out_data  (PSLVERR_selected)
  );

  assign apb_read_data_out = (!PSLVERR_selected)? read_data_reg : '0;

  //============================================================
  //              MASTER TO SLAVE PARITY CHECK                 
  //============================================================

  // APB master parity check from master to slave for PADDR
  generate
    for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin : gen_paddr_parity
      assign paddr_parity_chk[i] = ^PADDR[i*8 +: 8];
    end
  endgenerate

  apb_register #(
    .WIDTH(DATA_WIDTH/8)
  ) apb_paddr_parity_check_register (
    .clk  (PCLK                   ),
    .rst_n(PRESETn                ),
    .en   (PSELx_decoder_en       ), // At Setup or Access state PSELx = 1'b1
    .d    (paddr_parity_chk       ),
    .q    (PADDRCHK               )
  );

  // APB master parity check from master to slave for PWDATA
  generate
    for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin : gen_pwdata_parity
      assign pwdata_parity_chk[i] = ^PWDATA[i*8 +: 8];
    end
  endgenerate

  apb_register #(
    .WIDTH(DATA_WIDTH/8)
  ) apb_pwdata_parity_check_register (
    .clk  (PCLK                    ),
    .rst_n(PRESETn                 ),
    .en   (PSELx_decoder_en        ), // Enable condition = (PSELx == 1'b1) and PWRITE
    .d    (pwdata_parity_chk       ), 
    .q    (pwdata_parity_reg       )
  );

  assign PWDATACHK = pwdata_parity_reg & {4{PWRITE}};
  
  // APB master parity check from master to slave for PSTRB

assign pstrb_parity_bit = ^apb_pstrb;
  apb_register #(
    .WIDTH(1)
  ) apb_pstrb_parity_check_register (
    .clk  (PCLK            ),
    .rst_n(PRESETn         ),
    .en   (transfer        ), 
    .d    (pstrb_parity_bit),
    .q    (pstrb_parity_reg)
  );

  buf(PSTRBCHK, pstrb_parity_reg);
  //============================================================
  //              SLAVE TO MASTER PARITY CHECK                 
  //============================================================

  // APB master parity check from slave to master for PRDATA
  generate
    for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin : gen_prdata_parity
      assign prdata_parity_bit[i] = ^prdata_selected[i*8 +: 8];
    end
  endgenerate

  param_mux #(
    .DATA_WIDTH(DATA_WIDTH/8),
    .NUM_SLAVE (NUM_SLAVE )
  ) PRDATACHK_mux (
    .in_data   (PRDATACHK         ),
    .sel       (slave_addr_range  ), // Flexible select for param mux base on slave number
    .out_data  (PRDATACHK_selected)
  );

  apb_register #(
    .WIDTH(DATA_WIDTH/8)
  ) apb_prdata_parity_check_register (
    .clk  (PCLK             ),
    .rst_n(PRESETn          ),
    .en   (PREADY_selected  ), 
    .d    (prdata_parity_bit),
    .q    (prdata_parity_reg)
  );
  assign prdata_parity_error = prdata_parity_reg ^ PRDATACHK_selected;

endmodule: apb_master
