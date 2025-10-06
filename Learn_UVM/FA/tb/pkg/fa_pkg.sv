package	fa_pkg;
	import	uvm_pkg::*; `include "uvm_macros.svh"
	`include "env/fa_txn.sv"
	`include "env/fa_sequencer.sv"
	`include "env/fa_driver.sv"
	`include "env/fa_monitor.sv"
	`include "env/fa_agent.sv"
	`include "env/fa_scoreboard.sv"
	`include "env/fa_env.sv"
	`include "seqs/fa_base_seq.sv"
	`include "seqs/fa_rand_seq.sv"
	`include "seqs/fa_directed.sv"
	`include "cov/fa_cov.sv"
endpackage
