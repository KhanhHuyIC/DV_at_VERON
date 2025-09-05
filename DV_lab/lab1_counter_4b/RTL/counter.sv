module counter (
	input	logic		clk,
	input	logic		rst,
	input	logic		en,
	output	logic	[3:0]	count
	);

	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin
			count <= 4'b0;
		end else begin
		if (en) begin
			count <= count + 1'b1;
		end
	end
	end

endmodule
