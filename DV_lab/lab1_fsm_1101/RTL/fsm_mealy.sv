module	fsm_mealy (
	input	logic	clk,
	input	logic	rst,
	input	logic	data,

	output	logic	detected
	);

	//Declaration state
	typedef enum logic	[2:0] {
		s0,
		s1,
		s2,
		s3
	}	state_t;

	state_t	state, next_state;

	//State register
	always_comb begin
		unique	case (state)
		s0:	next_state = (data) ? s1 : s0;
		s1:	next_state = (data) ? s2 : s0;
		s2:	next_state = (data) ? s2 : s3;
		s3:	next_state = (data) ? s2 : s0;
		default: next_state = s0;
	endcase
	end

	//Next state logic
	always_ff @(posedge clk) begin
		if (rst) begin
			state <= state_t'(3'b0);
		end else begin
			state <= next_state;
		end
	end

	//Output logic
	always_comb begin
		detected = ((state == s3) && data);
	end

endmodule
