module fa_16b (
	input wire [15:0] a,
	input wire [15:0] b,
	input wire cin,
	output wire cout,
	output wire [15:0] sum
	);

	wire [14:0] c;

	fa_1b	fa0	(.a(a[0]), .b(b[0]), .cin(cin), .cout(c[0]), .sum(sum[0]));
	fa_1b	fa1	(.a(a[1]), .b(b[1]), .cin(c[0]), .cout(c[1]), .sum(sum[1]));
	fa_1b	fa2	(.a(a[2]), .b(b[2]), .cin(c[1]), .cout(c[2]), .sum(sum[2]));
	fa_1b	fa3	(.a(a[3]), .b(b[3]), .cin(c[2]), .cout(c[3]), .sum(sum[3]));
	fa_1b	fa4	(.a(a[4]), .b(b[4]), .cin(c[3]), .cout(c[4]), .sum(sum[4]));
	fa_1b	fa5	(.a(a[5]), .b(b[5]), .cin(c[4]), .cout(c[5]), .sum(sum[5]));
	fa_1b	fa6	(.a(a[6]), .b(b[6]), .cin(c[5]), .cout(c[6]), .sum(sum[6]));
	fa_1b	fa7	(.a(a[7]), .b(b[7]), .cin(c[6]), .cout(c[7]), .sum(sum[7]));
	fa_1b	fa8	(.a(a[8]), .b(b[8]), .cin(c[7]), .cout(c[8]), .sum(sum[8]));
	fa_1b	fa9	(.a(a[9]), .b(b[9]), .cin(c[8]), .cout(c[9]), .sum(sum[9]));
	fa_1b	fa10	(.a(a[10]), .b(b[10]), .cin(c[9]), .cout(c[10]), .sum(sum[10]));
	fa_1b	fa11	(.a(a[11]), .b(b[11]), .cin(c[10]), .cout(c[11]), .sum(sum[11]));
	fa_1b	fa12	(.a(a[12]), .b(b[12]), .cin(c[11]), .cout(c[12]), .sum(sum[12]));
	fa_1b	fa13	(.a(a[13]), .b(b[13]), .cin(c[12]), .cout(c[13]), .sum(sum[13]));
	fa_1b	fa14	(.a(a[14]), .b(b[14]), .cin(c[13]), .cout(c[14]), .sum(sum[14]));
	fa_1b	fa15	(.a(a[15]), .b(b[15]), .cin(c[14]), .cout(cout), .sum(sum[15]));

endmodule
