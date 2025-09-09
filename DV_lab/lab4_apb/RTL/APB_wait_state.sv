module apb_wait_state (
	input wire	pclk,
	input wire	preset_n,
	input wire	psel,
	input wire	penable,
	input wire	pwrite,
	input wire [7:0] addr,
	input wire [7:0] pwdata,

	output reg	pready,
	output reg	pselverr,
	output reg [7:0] prdata
	);

	//Internal register
	reg [7:0] reg_file [0:7];
	reg [2:0] wait_counter;
	parameter WAIT_CYCLES = 2;

	//Wait - state logic
	wire wait_done = (wait_counter == WAIT_CYCLES);

	//Reset logic
	integer i;
	always @(posedge pclk or negedge preset_n) begin
		if (!preset_n) begin
			for (i=0; i < 8; i = i + 1)
				reg_file[i] <= 8'h00;
			reg_file[2] <= 8'h12;
			reg_file[5] <= 8'hAD;

			wait_counter	<= 0;
			pready		<= 1'b0;
			pselverr	<= 1'b0;
			prdata		<= 8'h00;
		
		end else begin
			//Setup phase: reset counter if new transfer starts
			if (psel && !penable) begin
				wait_counter	<= 0;
				pready		<= 1'b0;
				pselverr	<= 1'b0;

			end
			//Access phase: increment counter until wait
