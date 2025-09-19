interface apb_if #(
	parameter ADDR_WIDTH = 12,
	parameter DATA_WIDTH = 32
)(	input logic PCLK,
	input logic PRESETn
	);

	logic			PSEL, PENABLE, PWRITE;
	logic [ADDR_WIDTH-1:0]	PADDR;
	logic [DATA_WIDTH-1:0]	PWDATA, PRDATA;
	logic [DATA_WIDTH/8-1:0] PSTRB;
	logic [2:0]		PPROT;
	logic			PREADY, PSLVERR;

	//Clocking block
	clocking cb @(posedge PCLK);
		default input #1step output #1step;
		output	PSEL, PENABLE, PWRITE, PADDR, PWDATA, PSTRB, PPROT;
		input PRDATA, PREADY, PSLVERR;
	endclocking

	modport	drv	(clocking cb, input PRESETn);
	modport	mon	(input PSEL, PENABLE, PWRITE, PADDR, PWDATA, PSTRB, PPROT, PRDATA, PREADY, PSLVERR, PCLK, PRESETn);

endinterface
