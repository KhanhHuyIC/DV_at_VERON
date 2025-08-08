
module fa_1b (
	input wire a,
	input wire b,
	input wire cin,
	output wire sum,
	output wire cout
	);

	wire ha_sum, carry1, carry2;
	fa_1b fa1 (.a(a), .b(b), .sum(ha_sum), .carry(carry1));
	fa_1b fa2 (.a(ha_sum), b(cin), .sum(sum), .carry(carry2));

	assign cout = carry1 | carry2;

	endmodule
