module apb_protocol #(
  parameter ADDR_WIDTH = 32 , // Parameter for address width
  parameter DATA_WIDTH = 32 , // Parameter for data width
  parameter WAIT_CYCLE = 2  , // Parameter for wait stage 
  parameter DEPTH      = 256, // Parameter for ram depth of slave
  parameter NUM_SLAVE  = 4    // Parameter for slave number
)(
  // Input declaration
  input  logic                    PCLK                      ,    // APB clock signal
  input  logic                    PRESETn                   ,    // Active-low reset signal
  input  logic [DATA_WIDTH/8-1:0] read_paddr_parity_src_out ,    // Parity bit from source for apb_read_paddr
  input  logic [DATA_WIDTH/8-1:0] write_paddr_parity_src_out,    // Parity bit from source for apb_write_paddr
  input  logic [DATA_WIDTH/8-1:0] write_data_parity_src_out ,    // Parity bit from source for apb_write_data
  input  logic                    pstrb_parity_src_out      ,    // Parity bit from source for PSTRB
  input  logic                    transfer                  ,    // Initiates APB transfer when high
  input  logic                    WRITE_READ                ,    // 1: Write, 0: Read operation
  input  logic [ADDR_WIDTH-1:0]   apb_write_paddr           ,    // Write address from master
  input  logic [ADDR_WIDTH-1:0]   apb_read_paddr            ,    // Read address from master
  input  logic [DATA_WIDTH-1:0]   apb_write_data            ,    // Data to be written to slave
  input  logic [DATA_WIDTH/8-1:0] PSTRB                     ,    // Byte write strobe (valid per byte)
  // Output declaration
  output logic [DATA_WIDTH/8-1:0] read_paddr_parity_chk     ,    // Parity check from source to master for apb_read_paddr
  output logic [DATA_WIDTH/8-1:0] write_paddr_parity_chk    ,    // Parity check from source to master for apd_write_paddr
  output logic [DATA_WIDTH/8-1:0] write_data_parity_chk     ,    // Parity check from source to master for apd_write_data
  output logic                    pstrb_parity_chk          ,    // Parity check from source to master for PSTRB
  output logic [DATA_WIDTH-1:0]   apb_read_data_out         ,    // Captured read data from slave
  output logic [DATA_WIDTH/8-1:0] PADDRCHK                  ,    // Parity check from master to slave for PADDR
  output logic [DATA_WIDTH/8-1:0] PWDATACHK                 ,    // Parity check from master to slave for PWDATA
  output logic [DATA_WIDTH/8-1:0] PRDATACHK                      // Parity check from slave to master for PRDATA
);

  // Internal logics declaration
  logic                                 PENABLE                 ;    // Enable signal for APB transaction (n cycle)
  logic [NUM_SLAVE-1:0]                 PSEL                    ;    // One-hot slave select signal 
  logic [ADDR_WIDTH-1:0]                PADDR                   ;    // Address sent to slave
  logic [DATA_WIDTH-1:0]                PWDATA                  ;    // Data sent to slave for write
  logic                                 PWRITE                  ;    // Write enable signal (1: Write, 0: Read)
  logic [DATA_WIDTH/8-1:0]              paddr_parity_master_out ;    // Parity bit from master for PADDR
  logic [DATA_WIDTH/8-1:0]              pwdata_parity_master_out;    // Parity bit from master for PWDATA
  logic                                 PREADY                  ;    // Slave ready signal
  logic                                 PSLVERR                 ;    // Slave error signal
  logic [NUM_SLAVE-1:0][DATA_WIDTH-1:0] PRDATA                  ;    // Read data from all slaves
  logic [DATA_WIDTH/8-1:0]              prdata_parity_slave_out ;    // Parity bit from slave for PRDATA

  // logic [DATA_WIDTH/8-1:0]              read_paddr_parity_chk   ;    // Parity check from source to master for apb_read_paddr
  // logic [DATA_WIDTH/8-1:0]              write_paddr_parity_chk  ;    // Parity check from source to master for apd_write_paddr
  // logic [DATA_WIDTH/8-1:0]              write_data_parity_chk   ;    // Parity check from source to master for apd_write_data
  // logic                                 pstrb_parity_chk        ;    // Parity check from source to master for PSTRB
  // logic [DATA_WIDTH-1:0]                apb_read_data_out       ;    // Captured read data from slave

  // Instantiate of Master
  apb_master #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_SLAVE (NUM_SLAVE )
  ) apb_master_inst (
    // Input of Master
    .PCLK                      (PCLK                      ),
    .PRESETn                   (PRESETn                   ),
    .read_paddr_parity_src_out (read_paddr_parity_src_out ),
    .write_paddr_parity_src_out(write_paddr_parity_src_out),
    .write_data_parity_src_out (write_data_parity_src_out ),
    .pstrb_parity_src_out      (pstrb_parity_src_out      ),
    .transfer                  (transfer                  ),
    .WRITE_READ                (WRITE_READ                ),
    .apb_write_paddr           (apb_write_paddr           ),
    .apb_read_paddr            (apb_read_paddr            ),
    .apb_write_data            (apb_write_data            ),
    .PSTRB                     (PSTRB                     ),
    .PRDATA                    (PRDATA                    ),
    .PREADY                    (PREADY                    ),
    .PSLVERR                   (PSLVERR                   ),
    .prdata_parity_slave_out   (prdata_parity_slave_out   ),
    // Output of Master
    .read_paddr_parity_chk     (read_paddr_parity_chk     ),
    .write_paddr_parity_chk    (write_paddr_parity_chk    ),
    .write_data_parity_chk     (write_data_parity_chk     ),
    .pstrb_parity_chk          (pstrb_parity_chk          ),
    .PENABLE                   (PENABLE                   ),
    .PSEL                      (PSEL                      ),
    .PADDR                     (PADDR                     ),
    .PWDATA                    (PWDATA                    ),
    .PWRITE                    (PWRITE                    ),
    .apb_read_data_out         (apb_read_data_out         ),
    .paddr_parity_master_out   (paddr_parity_master_out   ),
    .pwdata_parity_master_out  (pwdata_parity_master_out  ),
    .PRDATACHK                 (PRDATACHK                 ) 
  );

  apb_slave #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH     (DEPTH     ),
    .WAIT_CYCLE(2         )
  ) apb_slave_inst_0 (
    // Input declaration
    .PCLK                    (PCLK                    ),
    .PRESETn                 (PRESETn                 ),
    .paddr_parity_master_out (paddr_parity_master_out ),
    .pwdata_parity_master_out(pwdata_parity_master_out),
    .PSEL                    (PSEL[0]                 ),
    .PENABLE                 (PENABLE                 ),
    .PWRITE                  (PWRITE                  ),
    .PADDR                   (PADDR                   ),
    .PWDATA                  (PWDATA                  ),
    // Output declaration
    .PADDRCHK                (PADDRCHK                ),
    .PWDATACHK               (PWDATACHK               ),
    .PREADY                  (PREADY                  ),
    .PSLVERR                 (PSLVERR                 ),
    .PRDATA                  (PRDATA[0]               ),
    .prdata_parity_slave_out (prdata_parity_slave_out )
  );

endmodule : apb_protocol
