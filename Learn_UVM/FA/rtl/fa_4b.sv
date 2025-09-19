
module fa_4b (
	input wire [3:0] a,
	input wire [3:0] b,
	input wire cin,
	output wire [3:0] sum,
	output wire cout
	);

	wire [2:0] c;
	fa_1b fa0 (.a(a[0]), .b(b[0]), .cin(cin), .sum[sum[0]), .cout(c[0]));
	fa_1b fa1 (.a(a[1]), .b(b[1]), .cin(cout[0]), .sum[sum[1]), .cout(c[1]));
	fa_1b fa2 (.a(a[2]), .b(b[2]), .cin(cout[1]), .sum[sum[2]), .cout(c[2]));
	fa_1b fa3 (.a(a[3]), .b(b[3]), .cin(cout[2]), .sum[sum[3]), .cout(cout));

	endmodule
