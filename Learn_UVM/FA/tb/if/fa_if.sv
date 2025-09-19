interface	fa_if	(input logic clk);
	logic	rst_n;
	logic	[3:0]	a, b;
	logic	cin;
	logic	[3:0]	sum;
	logic	cout;

	//Clocking blocks for inputs and outputs
	clocking drv_cb @(posedge clk);
		output	a, b, cin;
		input	sum, cout;
	endclocking

	clocking mon_cb @(posedge clk);
		input	a, b, cin, sum, cout;
	endclocking

	modport DRV (clocking drv_cb, input clk, output rst_n);
	modport	MON (clocking mon_cb, input clk, input rst_n);

endinterface
