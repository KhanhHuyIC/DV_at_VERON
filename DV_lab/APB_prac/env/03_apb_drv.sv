import apb_pkg::*;

class apb_drv;

  // virtual interface to drive the bus
  virtual apb_if.MASTER vif;

  // mailbox: get transactions from generator
  mailbox #(apb_trans) gen2drv;

  // Constructor
  function new(virtual apb_if.MASTER vif, mailbox #(apb_trans) gen2drv);
    this.vif      = vif;
    this.gen2drv  = gen2drv;
  endfunction

  task run();
    apb_trans tr;

    // Drive idle defaults and wait for reset deassertion
    vif.PSEL         <= 1'b0;
    vif.PENABLE      <= 1'b0;
    vif.PWRITE       <= 1'b0;
    vif.PADDR        <= '0;
    vif.PWDATA       <= '0;
    vif.WAIT_CYCLES  <= '0;
    wait (vif.PRESETn === 1'b1);
    @(posedge vif.PCLK);

    forever begin
      gen2drv.get(tr);
      drive_transaction(tr);
    end
  endtask

  // Drive one APB transaction (SETUP -> ACCESS)
  task drive_transaction(apb_trans tr);
    // local copies (typed from package)
    logic [ADDR_WIDTH-1:0] addr        = tr.addr;
    logic [DATA_WIDTH-1:0] wdata       = tr.wdata;
    logic [WAIT_W-1:0]     wait_cycles = tr.wait_cycles;

    // ---------------------------
    // SETUP phase
    // ---------------------------
    vif.PADDR        <= addr;
    vif.PWDATA       <= wdata;
    vif.PWRITE       <= (tr.op == APB_WRITE);
    vif.WAIT_CYCLES  <= wait_cycles;   // load wait cycles for this transfer
    vif.PSEL         <= 1'b1;
    vif.PENABLE      <= 1'b0;
    @(posedge vif.PCLK);

    // ---------------------------
    // ACCESS phase
    // ---------------------------
    vif.PENABLE <= 1'b1;

    // wait until DUT asserts PREADY
    do @(posedge vif.PCLK); while (!vif.PREADY);

    // READ: sample PRDATA
    if (tr.op == APB_READ) begin
      tr.rdata = vif.PRDATA;
    end

    // Error flag from DUT
    tr.err = vif.PSLVERR;

    // ---------------------------
    // End of transfer / return to IDLE
    // ---------------------------
    vif.PSEL         <= 1'b0;
    vif.PENABLE      <= 1'b0;
    vif.PWRITE       <= 1'b0;
    vif.PADDR        <= '0;
    vif.PWDATA       <= '0;
    vif.WAIT_CYCLES  <= '0;           // optional: clear to a known default

    @(posedge vif.PCLK);
  endtask

endclass
