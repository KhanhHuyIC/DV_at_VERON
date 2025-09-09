import apb_pkg::*;

interface apb_if;
	logic	[ADD_WIDTH-1:0] PADDR;
	logic			PSEL;
	logic			PENABLE;
	logic			PWRITE;
	logic	[DATA_WIDTH-1:0] PWDATA;
	logic 	[DATA_WIDTH-1:0] PRDATA;
	logic			PREADY;
	logic			PSLVERR;
	logic			PCLK;
	logic			PRESETn;

	//Clocking block
	clocking cb @(posedge PCLK)
		default input #1step output #1step;
		input PRDATA, PREADY, PSLVERR;
		output PADDR, PSEL, PENABLE, PWRITE, PWDATA;
	endclocking

	//Master modport
	modport MASTER (
		input PCLK, PRESETn, PRDATA, PREADY, PSLVERR,
		output PADDR, PSEL, PENABLE, PWRITE, PWDATA,
		clocking cb
			);
	//Slave modport
	modport SLAVE (
		input PCLK, PRESETn, PADDR, PSEL, PENABLE, PWRITE, PWDATA,
		output PRDATA, PREADY, PSLVERR
		);

	endinterface
