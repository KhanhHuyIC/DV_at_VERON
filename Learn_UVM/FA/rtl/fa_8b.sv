
module fa_8b (
	input wire [7:0] a,
	input wire [7:0] b,
	input wire cin,
	output wire [7:0] sum,
	output wire cout
	);

	wire c_mid;
	fa_4b lo (.a(a[3:0]), .b(b[3:0]), .cin(cin), 	.sum(sum[3:0]), .cout(c_mid));
	fa_4b hi (.a(a[7:4]), .b(b[7:4]), .cin(c_mid), 	.sum(sum[7:4]), .cout(cout));

	endmodule
