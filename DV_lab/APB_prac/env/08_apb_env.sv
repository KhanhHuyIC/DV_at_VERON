// 07_apb_env.sv

import apb_pkg::*;
`include "05_apb_master_agent.sv"
`include "06_apb_score.sv"

class apb_env;
  // Virtual interface
  virtual apb_if.MASTER vif;

  // Elements
  apb_master_agent agent;
  apb_score        score;

  // Mailbox to push transactions to scoreboard
  mailbox #(apb_trans) mon2score;

  // Simple knob for generator random wait states
  int unsigned max_wait_cycles;
  bit	score_started;

  // Constructor
  function new(virtual apb_if.MASTER vif,
               int num_transaction = 20,
               int unsigned max_wait_cycles = 5);
    this.vif             = vif;
    this.mon2score       = new();
    this.max_wait_cycles = max_wait_cycles;

    // Pass knobs to agent (updated ctor)
    this.agent = new(this.vif, this.mon2score, num_transaction, this.max_wait_cycles);
    this.score = new(this.mon2score);
  endfunction

  // Optional runtime tuning
  function void set_num_transactions(int n);
    if (agent != null) agent.set_num_transactions(n);
  endfunction

  function void set_max_wait(int unsigned w);
    this.max_wait_cycles = w;
    if (agent != null) agent.set_max_wait(w);
  endfunction

  // Run agent and scoreboard
  task run(string mode = "random");
	  if (!score_started) begin
		  score_started = 1'b1;
		  fork
			  score.run();
		  join_none
	  end
	  agent.run (mode);
  endtask
endclass
