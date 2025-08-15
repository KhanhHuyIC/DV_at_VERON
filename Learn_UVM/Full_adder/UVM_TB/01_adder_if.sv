//Interface and modport

interface adder_if (input logic clk);
	logic 		rst_n;
	logic	[15:0]	a;
	logic	[15:0] 	b;
	logic		cin;
	logic	[15:0]	sum;
	logic		cout;

	//modport for driver and monitor
	modport	drv_mp	(input clk, rst_n, output a, b, cin, input sum, cout);
	modport mon_mp	(input clk, rst_n, a, b, cin, sum, cout);

	//Basic assertion
	property
	reset_clear; @(posedge clk) !rst_n |=> (sum==0 && cout==0);
	endproperty

endinterface
