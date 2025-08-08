module FIFO_8b #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)(
    input clk,
    input rst_n,
    input wr,
    input rd,
    input clear,
    input [DATA_WIDTH-1:0] data_in,

    output reg data_out_valid,
    output reg [DATA_WIDTH-1:0] data_out,
    output empty,
    output full
);

// Internal FIFO memory
reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
reg [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;
reg [ADDR_WIDTH:0] count;

assign empty = (count == 0);
assign full  = (count == DEPTH);

// Write logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n || clear) begin
        wr_ptr <= 0;
    end
    else if (wr && !full) begin
        mem[wr_ptr] <= data_in;
        wr_ptr <= wr_ptr + 1;
    end
end

//Prepare for reading
    wire [DATA_WIDTH-1:0] data_next;
    wire read_condition;
    assign read_condition = rd && (wr_ptr == rd_ptr) && !empty;
    assign data_next = (read_condition) ? data_in : mem[rd_ptr];

// Read logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n || clear) begin
        rd_ptr <= 0;
        data_out <= '0;
        data_out_valid <= 0;
    end
    else if (rd) begin
        data_out <= data_next;
        rd_ptr <= rd_ptr + 1;
        data_out_valid <= 1;
    end else begin
        data_out_valid <= 0;
    end
end

// Counter logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n || clear) begin
        count <= 0;
    end else begin
        case ({wr && !full, rd && !empty})
        2'b10: count <= count + 1; // Write
        2'b01: count <= count - 1; // Read
        2'b11: count <= count;     // Simultaneous read/write
        default: count <= count;   // Idle
        endcase
    end
end

endmodule
