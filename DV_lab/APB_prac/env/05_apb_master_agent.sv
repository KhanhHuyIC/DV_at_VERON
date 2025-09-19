import apb_pkg::*;
`include "02_apb_gen.sv"
`include "03_apb_drv.sv"
`include "04_apb_mon.sv"

class apb_master_agent;
  // Virtual interface
  virtual apb_if.MASTER vif;

  // Components
  apb_gen gen;
  apb_drv drv;
  apb_mon mon;

  // Mailboxes
  mailbox #(apb_trans) gen2drv;
  mailbox #(apb_trans) mon2score;

  // Simple knob for generator random wait states
  int unsigned max_wait_cycles;
  bit	io_started;

  // Constructor
  function new(virtual apb_if.MASTER vif,
               mailbox #(apb_trans) mon2score,
               int num_transaction = 20,
               int unsigned max_wait_cycles = 5);
    this.vif             = vif;
    this.mon2score       = mon2score;
    this.gen2drv         = new();
    this.max_wait_cycles = max_wait_cycles;

    // Pass knob into generator (constructor updated in 02_apb_gen.sv)
    this.gen = new(this.gen2drv, num_transaction, this.max_wait_cycles);
    this.drv = new(this.vif, this.gen2drv);
    this.mon = new(this.vif, this.mon2score);
  endfunction

  // Allow runtime change of generator knobs (optional, minimal)
  function void set_max_wait(int unsigned max_wait_cycles);
    this.max_wait_cycles = max_wait_cycles;
    if (this.gen != null) this.gen.max_wait_cycles = max_wait_cycles;
  endfunction

  function void set_num_transactions(int n);
    if (this.gen != null) this.gen.num_transactions = n;
  endfunction

  // Run agent
  task run(string mode = "random");
	  if (!io_started) begin
		  io_started = 1'b1;
		  fork
			  drv.run();
			  mon.run();
		  join_none
	  end
	  if (mode == "random")      gen.run_random();
	  else if (mode == "directed") gen.run_directed();
	  else if (mode == "corner")   gen.run_corner();
	  else                         gen.run_random(); // default fallback
  endtask
endclass
