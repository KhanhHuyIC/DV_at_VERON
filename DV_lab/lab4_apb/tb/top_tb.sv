`timescale 1ns/1ps
include	"apb_env.sv";
	module top_tb;
		localparam	ADDR_W	= 12;
		localparam	DATA_W	= 32;
		localparam	DEPTH	= 1024;
		
		logic		PCLK	= 0;
		logic		PRESETn	= 0;

		//Clock & reset
		initial begin
			PCLK	= 0;
			PRESETn	= 0;
			forever #5 PCLK = ~PCLK;
		end

		//APB interface
		apb_if #(ADDR_W, DATA_W) apb (PCLK, PRESETn) ;

		//DUT
		apb_slave_generic #(
			.ADDR_WIDTH(ADDR_W),
			.DATA_WIDTH(DATA_W),
			.DEPTH(DEPTH))
			dut (
				.PCLK,
				.PRESETn,
				.PSEL(apb.PSEL),
				.PENABLE(apb.PENABLE),
				.PADDR(apb.PADDR),
				.PWRITE(apb.PWRITE),
				.PWDATA(apb.PWDATA),
				.PSTRB(apb.PSTRB),
				.PPROT(apb.PPROT),
				.PRDATA(apb.PRDATA),
				.PREADY(apb.PREADY),
				.PSLVERR(apb.PSLVERR)
			);
		//Protocol assertions
		apb_protocol_sva sva (.vif(apb));

		//Environment
		apb_env	env;

		int	N_TXN = 200;

		initial begin
			//Reset
			repeat(5) @(posedge PCLK);
			PRESETn = 1;

			//Run the environment
			env = new(apb, apb, N_TXN);
			env.run();

			//wait scoreboard
			wait (env.sb.done_flag == 1);
			repeat (5) @(posedge PCLK);
			$display("[TB] Complete %0d transaction. Finishing simulation.", N_TXN);
			$finish;
		end

endmodule
