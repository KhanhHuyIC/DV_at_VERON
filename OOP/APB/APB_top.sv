// APB_top.sv
`timescale 1ns/1ps

import apb_pkg::*;

module APB_top;

	//Interface instance
	apb_if apb_vif();

	//DUT instance
	apb_slave #(
		.ADDR_WIDTH(ADDR_WIDTH);
		.DATA_WIDTH(DATA_WIDTH);
		.REG_NUM(REG_NUM);
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
		env.run("corner"); //"random" / "directed" / "corner"

		//Wait the simulation run in a enough long time
		#2000;

		$display("=== [APB TB] Simulation finished! ===");
		$finish;
	end

	endmodule
