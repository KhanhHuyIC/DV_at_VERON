module fa_1b (
	input wire a,
	input wire b,
	input wire cin,
	output wire cout,
	output wire sum
	);

	reg ha_sum, ca1, ca2;

	ha_1b ha0 (.a(a),	.b(b),	.carry(ca1), .sum(ha_sum));
	ha_1b ha1 (.a(ha_sum),	.b(cin),	.carry(ca2), .sum(sum));
	
	assign	cout = ca1 | ca2;
endmodule
