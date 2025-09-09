module apb_slave #(
  parameter int ADDR_WIDTH = 16,
  parameter int DATA_WIDTH = 32,
  parameter int REG_NUM    = 8
)(
  input  logic                   PCLK,
  input  logic                   PRESETn,
  input  logic [ADDR_WIDTH-1:0]  PADDR,
  input  logic                   PSEL,
  input  logic                   PENABLE,
  input  logic                   PWRITE,
  input  logic [DATA_WIDTH-1:0]  PWDATA,
  output logic [DATA_WIDTH-1:0]  PRDATA,
  output logic                   PREADY,
  output logic                   PSLVERR
);

  logic [DATA_WIDTH-1:0] regfile [0:REG_NUM-1];

  localparam int ADDR_LSB = $clog2(DATA_WIDTH/8);
  wire [$clog2(REG_NUM)-1:0] reg_addr =
      PADDR[ADDR_LSB + $clog2(REG_NUM)-1 : ADDR_LSB];

  // Always ready (no wait-states)
  assign PREADY = 1'b1;

  // Combinational read path: prepare for access phase
  always_comb begin
    PRDATA  = '0;
    PSLVERR = 1'b0;

    if (PSEL && PENABLE) begin
      if (reg_addr < REG_NUM) begin
        if (!PWRITE) begin
          PRDATA = regfile[reg_addr];
        end
      end else begin
        PSLVERR = 1'b1;
      end
    end
  end

  // Access phase
  always_ff @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      for (int i = 0; i < REG_NUM; i++) begin
        regfile[i] <= '0;
      end
    end else begin
      if (PSEL && PENABLE && PWRITE && (reg_addr < REG_NUM)) begin
        regfile[reg_addr] <= PWDATA;
      end
    end
  end

endmodule
