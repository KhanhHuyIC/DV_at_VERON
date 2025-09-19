import apb_pkg::*;

class apb_mon;
  // Virtual interface to connect with DUT
  virtual apb_if.MASTER vif;

  // Mailbox to send the transaction to scoreboard
  mailbox #(apb_trans) mon2score;

  // Constructor
  function new(virtual apb_if.MASTER vif, mailbox #(apb_trans) mon2score);
    this.vif       = vif;
    this.mon2score = mon2score;
  endfunction

  // Monitor task
  task run();
    apb_trans tr;

    // Wait for reset deassertion before monitoring
    wait (vif.PRESETn === 1'b1);
    @(posedge vif.PCLK);

    forever begin
      @(posedge vif.PCLK);

      // Capture a completed APB transfer at ACCESS phase when PREADY=1
      if (vif.PSEL && vif.PENABLE && vif.PREADY) begin
        tr       = new();
        tr.op    = vif.PWRITE ? APB_WRITE : APB_READ;
        tr.addr  = vif.PADDR;
        tr.wdata = vif.PWDATA;
        tr.err   = vif.PSLVERR;

        // Also record the programmed wait cycles for this transfer
        tr.wait_cycles = vif.WAIT_CYCLES;

        // READ --> capture read data
        if (tr.op == APB_READ) begin
          tr.rdata = vif.PRDATA;
        end

        // Send to scoreboard
        mon2score.put(tr);
      end
    end
  endtask

endclass
