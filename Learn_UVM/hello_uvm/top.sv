`timescale 1ns/1ps

//Include UVM
`include "uvm_macros.svh"
import uvm_pkg::*;

module top;
	initial begin
		// Call test my_test
		run_test("my_test");
	end
endmodule
