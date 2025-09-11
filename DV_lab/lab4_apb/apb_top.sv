// APB_top.sv
`timescale 1ns/1ps

import apb_pkg::*;
`include "OOP_TB/07_apb_env.sv"

module APB_top;

	//Interface instance
	apb_if apb_vif();

	//DUT instance
	apb_slave #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH),
		.REG_NUM(REG_NUM)
		) dut (
			.PCLK		(apb_vif.PCLK),
			.PRESETn	(apb_vif.PRESETn),
			.PADDR 		(apb_vif.PADDR),
			.PSEL		(apb_vif.PSEL),
			.PENABLE	(apb_vif.PENABLE),
			.PWRITE		(apb_vif.PWRITE),
			.PWDATA		(apb_vif.PWDATA),
			.PRDATA		(apb_vif.PRDATA),
			.PREADY		(apb_vif.PREADY),
			.PSLVERR	(apb_vif.PSLVERR)
		);

	//Environment instance
	apb_env env;

	//Clock/reset generation
	initial begin
		apb_vif.PCLK = 0;
		forever #5 apb_vif.PCLK = ~apb_vif.PCLK;
	end

	initial begin
		apb_vif.PRESETn = 0;
		#25;
		apb_vif.PRESETn = 1;
	end

	//Test sequence
	initial begin
		//Wait to reset be balance
		wait(apb_vif.PRESETn == 1);

		//Initialize the environment
		env = new(apb_vif, 50); //50 transaction

		//Run the environment
		//Run the directed cases
		$display ("Run directed cases");
		env.run ("directed");
		#20;

		//Run the random cases
		$display ("Run random cases");
		env.run("random");
		#20;

		//Run corner cases
		$display ("Run the corner cases");		
		env.run("corner"); //"random" / "directed" / "corner"
		//Wait the simulation run in a enough long time
		#2000;

		$display("=== [APB TB] Simulation finished! ===");
		$finish;
	end

	endmodule
