module counter_tb;

	//DUT signals
	logic	clk, rst, en;
	logic	[3:0]	count;

	//Call the DUT
	counter dut (
		.clk(clk),
		.rst(rst),
		.en(en),
		.count(count)
		);
	

	//Monitor
	initial begin
		$monitor ("%0t, rst = %b, en = %b, count =	%0h",
			$time, rst, en, count);
	end

	//Clock generation
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	//Reset generation
	initial begin
		rst = 1;
		repeat (2) @(posedge clk);
		rst = 0;
	end

	//Initial values
	initial begin
		rst = 1;
		en = 0;
	end

	//Test cases
	initial begin
		@(negedge rst);
		//20 cycles, en = 1
		$display("Coutern 20 ns");
		en = 1'b1;
		#20;

		//8 cycles, hold the counter value
		$display("Hold 10 ns");
		en = 1'b0;
		#10;

		//alternating en
		$display("alternating enable");
		repeat (16) begin
		en = ~en;
		@(negedge clk);
		end

		//randomize
		$display("Randomize");
		en = 1'b1;
		count = $urandom_range (0,15);
		repeat (20) @(negedge clk);
	$finish;
	end

endmodule
