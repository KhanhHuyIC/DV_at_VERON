module fa_16b_tb;

	//inputs
	reg [15:0] a;
	reg [15:0] b;
	reg cin;
	
	//outputs
	wire cout;
	wire [15:0] sum;

	//DUT
	fa_16b dut (
		.a(a),
		.b(b),
		.cin(cin),
		.cout(cout),
		.sum(sum)
		);
	
	//task to check
	task check (input logic [15:0] as,
	       		 input logic [15:0] bs,
		 	 input logic cins,
			 input logic couts,
			 input logic [15:0] sums
			 );
	logic [16:0] expected;
	expected = as + bs + cins;

	if (sums == expected[15:0]) begin
		$display ("[PASS] a=%h, b=%h, cin=%h => sum=%h, cout=%b",
			as, bs, cins, sums, couts);
	end else begin
		$display ("[FAIL] a=%h, b=%h, cin=%h => sum=%h (expected=%h),cout=%b (expected=%b)",
			as, bs, cins, sums, expected[15:0], cout, expected[16]);
	end

	endtask

	initial begin
	a = $random;
	b = $random;
	cin = $random;
	#5;
	check (a, b, cin, cout, sum);
	#5;
	$finish;
end
endmodule
