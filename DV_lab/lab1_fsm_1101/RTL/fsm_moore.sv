module fsm_moore (
	input	logic	clk,
	input	logic	rst,
	input	logic	data,

	output	logic	detected
	);

	//Declaration state
	typedef enum logic [2:0] {
		s0,
		s1,
		s2,
		s3,
		s4
		} state_t;
	state_t	state, next_state;

	//State_register
	always_comb begin
		next_state = state;
		unique	case (state)
			s0:	next_state = (data) ? s1 : s0;
			s1:	next_state = (data) ? s2 : s0;
			s2:	next_state = (data) ? s2 : s3;
			s3:	next_state = (data) ? s4 : s0;
			s4:	next_state = (data) ? s2 : s0;
			default: next_state = s0;
		endcase
	end

	//State logic
	always_ff @(posedge clk) begin
		if (rst) begin
			state <= s0;
		end else begin
			state <= next_state;
		end
	end

	//Output logic
	assign detected = (state == s4);

endmodule
