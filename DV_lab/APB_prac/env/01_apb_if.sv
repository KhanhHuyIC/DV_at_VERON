import apb_pkg::*;

interface apb_if;

  // APB bus signals (widths from package)
  logic [ADDR_WIDTH-1:0] PADDR;
  logic                  PSEL;
  logic                  PENABLE;
  logic                  PWRITE;
  logic [DATA_WIDTH-1:0] PWDATA;
  logic [DATA_WIDTH-1:0] PRDATA;
  logic                  PREADY;
  logic                  PSLVERR;
  logic                  PCLK;
  logic                  PRESETn;

  // Runtime-configurable wait cycles (driven by TB/master, input to slave)
  logic [WAIT_W-1:0]     WAIT_CYCLES;

  // Clocking block (master drives outputs; samples inputs)
  clocking cb @(posedge PCLK);
    default input #1step output #1step;
    input  PRDATA, PREADY, PSLVERR;
    output PADDR, PSEL, PENABLE, PWRITE, PWDATA, WAIT_CYCLES;
  endclocking

  // Master modport (for driver/generator side)
  modport MASTER (
    input  PCLK, PRESETn, PRDATA, PREADY, PSLVERR,
    output PADDR, PSEL, PENABLE, PWRITE, PWDATA, WAIT_CYCLES,
    clocking cb
  );

  // Slave modport (for DUT side - apb_slave)
  modport SLAVE (
    input  PCLK, PRESETn, PADDR, PSEL, PENABLE, PWRITE, PWDATA, WAIT_CYCLES,
    output PRDATA, PREADY, PSLVERR
  );

endinterface
