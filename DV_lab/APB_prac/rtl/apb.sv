
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
	output logic                   PSLVERR,

	//Wait state
	input  logic [15:0]            WAIT_CYCLES
);

  // Local parameters and signals
  // Register index width; keep at least 1 bit for REG_NUM=1 to avoid zero-width.
  localparam int REG_IDX_W = (REG_NUM > 1) ? $clog2(REG_NUM) : 1;

  // Byte-lane LSB bits used to discard within-word addressing.
  localparam int ADDR_LSB  = $clog2(DATA_WIDTH/8);

  // Simple register file memory.
  logic [DATA_WIDTH-1:0] regfile [0:REG_NUM-1];

  // Target register index extracted from address (word-aligned).
  wire [REG_IDX_W-1:0] reg_addr =
      PADDR[ADDR_LSB + REG_IDX_W - 1 : ADDR_LSB];

  // Alignment & validity
  wire	aligned = (ADDR_LSB == 0) ? 1'b1: (PADDR[ADDR_LSB - 1:0] == '0);
  wire	in_range = (reg_addr < REG_NUM);
  wire	addr_valid = aligned && in_range;

  // APB phase helpers.
  wire in_setup  = PSEL && !PENABLE;
  wire in_access = PSEL &&  PENABLE;

  // Wait-state counter (wider than WAIT_CYCLES for flexibility).
  logic [31:0] wait_cnt_q;

  // Read data is captured in SETUP so PRDATA is stable during ACCESS.
  logic [DATA_WIDTH-1:0] rd_data_q;

  // ------------------------------
  // PREADY: high only when ACCESS phase and wait counter is zero.
  // Combinational assignment to avoid extra unintended cycles.
  // ------------------------------
  assign PREADY = in_access && (wait_cnt_q == 0);

  // ------------------------------
  // Read data path (driven from registered value)
  // ------------------------------
  assign PRDATA = rd_data_q;

  // ------------------------------
  // Sequential logic
  // ------------------------------
  integer i;
  always_ff @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      // Asynchronous active-low reset
      wait_cnt_q <= '0;
      rd_data_q  <= '0;
      PSLVERR    <= 1'b0;
      for (i = 0; i < REG_NUM; i++) begin
        regfile[i] <= '0;
      end
    end else begin
      PSLVERR <= 1'b0;

      // SETUP: load wait counter and capture read data
      if (in_setup) begin
        wait_cnt_q <= {16'd0, WAIT_CYCLES};          // zero-extend to 32 bits
        rd_data_q  <= addr_valid ? regfile[reg_addr]  // capture read value
                                 : '0;                // default for invalid addr
      end
      // ACCESS: count down wait
      else if (in_access && (wait_cnt_q != 0)) begin
        wait_cnt_q <= wait_cnt_q - 1;
      end

      // ACCESS completion: perform write / flag error
      if (in_access && (wait_cnt_q == 0)) begin
        if (PWRITE && addr_valid) begin
          regfile[reg_addr] <= PWDATA;
        end
        if (!addr_valid) begin
          PSLVERR <= 1'b1;
        end
      end
    end
  end

endmodule
