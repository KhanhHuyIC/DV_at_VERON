package apb_pkg;

  // PARAMETERS (match RTL)
  parameter int ADDR_WIDTH = 16;
  parameter int DATA_WIDTH = 32;
  parameter int REG_NUM    = 8;

  // Width for WAIT_CYCLES input in RTL
  parameter int WAIT_W     = 16;

  // Derived (simple helpers)
  localparam int ADDR_LSB  = $clog2(DATA_WIDTH/8);
  localparam int REG_IDX_W = (REG_NUM > 1) ? $clog2(REG_NUM) : 1;

  // TYPEDEFs
  typedef logic [ADDR_WIDTH-1:0]  apb_addr_t;
  typedef logic [DATA_WIDTH-1:0]  apb_data_t;
  typedef logic [REG_IDX_W-1:0]   apb_reg_addr_t;
  typedef logic [WAIT_W-1:0]      apb_wait_t;

  // ENUM
  typedef enum logic {
    APB_READ,
    APB_WRITE
  } apb_op_t;

  // CLASS
  class apb_trans;
    // Fields
    rand apb_op_t   op;          // READ/WRITE
    rand apb_addr_t addr;        // Byte address
    rand apb_data_t wdata;       // Write data
         apb_data_t rdata;       // Read data
         bit        err;         // Error flag (PSLVERR)
    rand apb_wait_t wait_cycles; // Wait cycles (drives RTL WAIT_CYCLES)

    // Constructor
    function new(apb_op_t op = APB_WRITE,
                 apb_addr_t addr = '0,
                 apb_data_t wdata = '0,
                 apb_wait_t wait_cycles = '0);
      this.op          = op;
      this.addr        = addr;
      this.wdata       = wdata;
      this.rdata       = '0;
      this.err         = 0;
      this.wait_cycles = wait_cycles;
    endfunction

    // Randomization constraints:
    // Limit address range to existing registers (REG_NUM words of DATA_WIDTH)
    constraint addr_valid { addr < (REG_NUM << ADDR_LSB); }
    // (Optional) enforce alignment:
    // constraint addr_align { if (ADDR_LSB > 0) addr[ADDR_LSB-1:0] == '0; }

  endclass

endpackage
