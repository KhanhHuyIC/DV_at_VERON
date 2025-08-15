module apb_slave_ram #(
  parameter ADDR_WIDTH = 32 ,
  parameter DATA_WIDTH = 32 ,
  parameter DEPTH      = 16
)(
  input  logic                  PCLK  ,
  input  logic                  ram_en,
  input  logic                  PRESETn,
  input  logic [ADDR_WIDTH-1:0] PADDR ,
  input  logic [DATA_WIDTH-1:0] PWDATA,
  output logic [DATA_WIDTH-1:0] PRDATA
);

  logic [DATA_WIDTH-1:0] ram [0:DEPTH-1];

  always_ff @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      for (int i = 0; i < DEPTH; i++) begin
        ram[i] <= '0;
      end
    end else if (ram_en) begin
      ram[PADDR] <= PWDATA;
    end
  end

  assign PRDATA = ram[PADDR];

endmodule : apb_slave_ram
