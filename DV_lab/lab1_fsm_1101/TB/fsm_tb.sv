module fsm_test;
	//DUT signals
	logic	clk;
	logic	rst;
	logic	data;
	logic	detected;

	//DUT
	fsm_mealy	dut (
		.clk(clk),
		.rst(rst),
		.data(data),
		.detected (detected)
		);

	//Data generation
	bit	[31:0] 	pattern = 32'b1101_1101_1010_1011_0111_0111_1110_1011;

	//Clock generation
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	//Reset generation
	initial begin
		rst = 1;
		data = 0;
		repeat (2) @(posedge clk);
		@(negedge clk);
		rst = 0;
	end

	//Monitor
	initial begin
		$monitor ("%10t ns | rst = %b, clk = %b, data = %b, detected = %b",
			$time,rst, clk, data, detected);
	end

	//Testcase
	initial begin
		@(negedge rst);
		for (int i = 31; i >= 0; i--) begin
			@(negedge clk);
			data = pattern[i];
		end
	repeat (2) @(posedge clk);
	$finish;
	end

	endmodule
