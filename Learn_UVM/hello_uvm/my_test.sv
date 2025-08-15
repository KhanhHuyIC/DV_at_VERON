`ifndef MY_TEST_SV
`define MY_TEST_SV

`include "uvm_macros.svh"

import uvm_pkg::*;

class my_test extends uvm_test;
	`uvm_component_utils(my_test)

	function new(string name = "my_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	//Build phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("BUILD_PHASE", "Hello from build_phase", UVM_LOW)
	endfunction

	//Run phase
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		`uvm_info("RUN_PHASE", "Hello from run_phase! Simulation is running...", UVM_LOW)
		#10ns;
		phase.drop_objection(this);
	endtask

	//Report phase
	function void report_phase(uvm_phase phase);
		`uvm_info("REPORT_PHASE", "Hello from report_phase! Test completed", UVM_LOW)
	endfunction
endclass

`endif
