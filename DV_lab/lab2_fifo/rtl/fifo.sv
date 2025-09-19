
module FIFO (
	input logic clk,
	input logic rst_n,
	input logic wr,
	input logic rd,
	input logic clear,
	input logic [7:0] data_in,

	output logic data_out_valid,
	output logic [7:0] data_out,
	output logic empty,
	output logic full
);

//Memory and pointer
	logic [7:0] mem [0:15];
	logic [3:0] wr_ptr, rd_ptr;
	logic [4:0] count;

	assign empty = (count == 0);
	assign full = (count == 16);

//Write data
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			wr_ptr <= '0;
		end
		else if (clear) begin
			wr_ptr <= '0;
		end
		else if (wr && !full) begin
			mem[wr_ptr] <= data_in;
			wr_ptr <= wr_ptr + 1'b1;
		end
	end

//Read data
always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		rd_ptr <= '0;
		data_out <= '0;
		data_out_valid <= 1'b0;
	end
	else if (clear) begin
		rd_ptr <= '0;
		data_out <= '0;
		data_out_valid <= 1'b0;
	end
	else if (rd && !empty) begin
        data_out    <= mem[rd_ptr];
        rd_ptr      <= rd_ptr + 1'b1;
        data_out_valid  <= 1'b1;
    end
else begin
    data_out_valid <= 1'b0;
end
end

//Count the elements in FIFO
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= '0;
    end
    else if (clear) begin
        count <= '0;
    end
    else begin
        unique case ({wr && !full, rd && !empty})
        2'b10: count <= count + 1'b1;
        2'b01: count <= count - 1'b1;
        default: count <= count;
        endcase
    end
end

//Clear the memory when reset and clear
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n || clear) begin
        integer k;
        for (k=0; k < 16; k=k+1) begin
            mem[k] <= '0;
        end
    end
end

endmodule
