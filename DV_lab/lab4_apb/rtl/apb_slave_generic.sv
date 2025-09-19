module apb_slave_generic.sv #(
	parameter	ADDR_WIDTH = 12,
	parameter	DATA_WIDTH = 32,
	parameter	DEPTH = 1024
)(
	input	logic	PCLK,
	input	logic	PRESETn,
	input	logic	PSEL,
	input	logic	PENABLE,
	input	logic	[ADDR_WIDTH-1:0]	PADDR,
	input	logic				PWRITE,
	input	logic	[DATA_WIDTH-1:0]	PSTRB,
	input	logic	[2:0]			PPROT,
	output	logic	[DATA_WIDTH-1:0]	PRDATA,
	output	logic				PREADY,
	output	logic				PSLVERR
	);

	//Simple reg file
	logic	[DATA_WIDTH-1:0] mem [0:DEPTH-1];

	//Ready module: parameterizable wait-states
	localparam int WAIT_STATES = 0;
	logic	[$clog2(WAIT_STAES+1)-1:0] wait_cnt;

	typedef enum logic [1:0] {IDLE, SETUP, ACCESS} state_e;
	state_e	state, nstate;

	//decode index
	logic [$clog2(DEPTH)-1:0] index;
	assign index = PADDR[$clog2(DEPTH)+1:2];

	//next-state
	always_comb begin
		nstate	= state;
		PREADY	= 1'b0;
		PSLVERR = 1'b0;
		PRDATA	= '0;

		unique case (state)
		IDLE	: if	(PSEL && !PENABLE) nstate = SETUP;
		SETUP	: if	(PSEL && PENABLE) nstate = ACCESS;
		ACCESS	: begin
			//complete when ready
			if (WAITT_STATES == 0) begin
				PREADY = 1'b1;
			end
			//data/resp
			if (!PWRITE) PRDATA = mem[index];
			//example error: out-of-range address
			if (index >= DEPTH) PSLVERR = 1'b1;

			if (PREADY) nstate = (PSEL && !PENABLE) ? SETUP: IDLE;
			end
		endcase
	end

	//state & write
	always_ff @(posedge PCLK or negedge PRESETn) begin
		if (!PRESETn) begin
			state	<= IDLE;
			wait_cnt <= '0;
		end else begin
			state <= nstate;
			if (state == ACCESS && PWRITE && PREADY && index < DEPTH) begin
				//byte-enable write
				for (int b = 0; b < DATA_WIDTH/8; b++) begin
					if (PSTR[b] mem [index][8*b +: 8] <= PWDATA [8*b +: 8];
				end
			end
		end
	end

endmodule
