interface apb_if #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
) (
  input logic PCLK
);

  logic PRESETn;

  // Master to Slave Signals
  logic                    PSEL;
  logic                    PENABLE;
  logic                    PWRITE;
  logic [ADDR_WIDTH-1:0]   PADDR;
  logic [DATA_WIDTH-1:0]   PWDATA;
  logic [DATA_WIDTH/8-1:0] PSTRB;  // Byte enable strobe

  // Slave to Master Signals
  logic [DATA_WIDTH/8-1:0] PADDRCHK;
  logic [DATA_WIDTH/8-1:0] PWDATACHK;
  logic                    PSTRBCHK;  // Strobe parity check from slave
  logic                    PREADY;
  logic                    PSLVERR;
  logic [DATA_WIDTH-1:0]   PRDATA;
  logic [DATA_WIDTH/8-1:0] PRDATACHK;

  // Clocking block for driver
  clocking cb_drv @(posedge PCLK);
    default input #1step output #1step;
    output PSEL, PENABLE, PWRITE, PADDR, PWDATA, PSTRB;
    input  PRDATA, PREADY, PSLVERR, PRDATACHK;
    output  PADDRCHK, PWDATACHK;
    output  PSTRBCHK;
  endclocking

  // Clocking block for monitor
  clocking cb_mon @(posedge PCLK);
    default input #1step output #1step;
    input PSEL, PENABLE, PWRITE, PADDR, PWDATA;
    input PRDATA, PREADY, PSLVERR;
    input PADDRCHK, PWDATACHK, PRDATACHK, PSTRB, PSTRBCHK;
  endclocking

 // // Modport for driver
 // modport drv (
 //   input  PCLK, PRESETn,
 //   clocking cb_drv
 // );

 // // Modport for monitor
 // modport mon (
 //   input  PCLK, PRESETn,
 //   clocking cb_mon
 // );

 // // Modport for DUT connection
 // modport dut (
 //   input  PCLK, PRESETn,
 //   input  PSEL, PENABLE, PWRITE, PADDR, PWDATA, PSTRB,
 //   output PADDRCHK, PWDATACHK, PSTRBCHK, PREADY, PSLVERR, PRDATA, PRDATACHK
 // );

endinterface
