module apb_master #(
	parameter ADD_WIDTH = 16,
	parameter DATA_WIDTH = 32
)(
	input logic	PCLK,
	input logic	PRESETn,
	//APB interface
	output logic	[DATA_WIDTH-1:0] PADDR,
	output logic	PSEL,
	output logic	PENABLE,
	output logic	PWRITE,
	output logic	[DATA_WIDTH-1:0] PWDATA,

	input logic	[DATA_WIDTH-1:0] PRDATA,
	input logic	PREADY,
	input logic	PSLVERR,
	//User interface
	input logic	req,
	input logic	rw,
	input logic	[ADD_WIDTH-1:0] addr,
	input logic	[DATA_WIDTH-1:0] wdata,
	output logic	[DATA_WIDTH-1:0] rdata,
	output logic	resp_valid,
	output logic	error
);

	//State machine
	typedef enum logic [1:0] {
		IDLE,
		SETUP,
		ACCESS
	} apb_state_t;
	
	apb_state_t state, next_state;

	//Internal register
	logic [ADD_WIDTH-1:0] addr_reg;
	logic [DATA_WIDTH-1:0] wdata_reg;
	logic rw_reg;

	//Output assignments
	assign rdata = PRDATA;
	assign error = (state == ACCESS && PREADY && PSLVERR);
	assign resp_valid = (state == ACCESS && PREADY);

	//State transitions
	always_ff @(posedge PCLK or negedge PRESETn) begin
		if (!PRESETn) begin
			state <= IDLE
		end else begin
			state <= next_state;
		end
	end

	//Next state logic
	always_comb begin
		next_state = state;
		case (state)
			IDLE: next_state = (req) ? SETUP : IDLE;
			SETUP: next_state = ACCESS;
			ACCESS: next_state = (PREADY) ? IDLE : ACCESS;
			default: next_state = IDLE;
		endcase
	end

	//APB singals & register
	always_ff @(posedge PCLK or negedge PRESETn) begin
		if (!PRESETn) begin
			PSEL		<=	0;
			PENABLE		<=	0;
			PADDR		<=	'0;
			PWRITE		<=	0;
			PWDATA		<=	'0;
			addr_reg	<=	'0;
			wdata_reg	<=	'0;
			rw_reg		<=	0;
		end else begin
			case (state)
				IDLE: begin
					PSEL	<=	0;
					PENABLE	<=	0;
					if (req) begin
						addr_reg <= addr;
						wdata_reg <= wdata;
						rw_reg <= rw;
					end
				end
				SETUP: begin
					PSEL	<= 1;
					PENABLE <= 0;
					PADDR 	<= addr_reg;
					PWRITE	<= rw_reg;
					PWDATA	<= wdata_reg;
				end
				ACCESS: begin
					PSEL	<= 1;
					PENABLE <= 1;
				end
			endcase

			if (state == ACCESS && PREADY) begin
				PSEL	<= 0;
				PENABLE <= 0;
			end
		end
	end

	endmodule
