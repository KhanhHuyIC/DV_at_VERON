module apb_slave #(
	parameter ADDR_WIDTH = 16,
	parameter DATA_WIDTH = 32,
	parameter REG_NUM = 8
)(
	input	logic	PCLK,
	input	logic	PRESETn,
	//APB interface
	input	logic	[ADDR_WIDTH-1:0] PADDR,
	input	logic	PSEL,
	input	logic	PENABLE,
	input	logic	PWRITE,
	input	logic	[DATA_WIDTH-1:0] PWDATA,

	output	logic	[DATA_WIDTH-1:0] PRDATA,
	output	logic	PREADY,
	output	logic 	PSLVERR
	);

	//Internal register array
	logic [DATA_WIDTH-1:0] regfile [0:REG_NUM-1];
	//logic [DATA_WIDTH-1:0] rdata_next;
	//logic error_next;

	//Address of register
	logic [$clog2(REG_NUM)-1:0] reg_addr;

	assign reg_addr = PADDR[$clog2(REG_NUM)+1:2];

	//Always ready to respond (not wait state)
	assign PREADY = 1'b1;

	//Read/write and error logic
	always_ff @(posedge PCLK or negedge PRESETn) begin
		if (!PRESETn) begin
			for (int i=0; i < REG_NUM; i++)
				regfile[i] <= '0;
			PRDATA	<= '0;
			PSLVERR <= 1'b0;
		end else begin
			PSLVERR <= 1'b0;
			if (PSEL && PENABLE && PREADY) begin
				//Check the address to access
				if (reg_addr < REG_NUM) begin
					if (PWRITE) begin
						regfile[reg_addr] <= PWDATA;
					end
					PRDATA <= regfile[reg_addr];
				end else begin
				// Access out of register
					PSLVERR <= 1'b1;
					PRDATA 	<= '0;
				end
			end else begin
				PRDATA <= '0;
			end
		end
	end

	endmodule
