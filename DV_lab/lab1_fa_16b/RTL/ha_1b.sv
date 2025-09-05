module ha_1b (
	input wire a,
	input wire b,
	output wire carry,
	output wire sum
	);

	assign sum	= a ^ b;
	assign carry	= a & b;

endmodule
